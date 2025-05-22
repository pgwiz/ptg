#Requires -RunAsAdministrator

# Check for administrative privileges and restart with elevation if needed
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting administrator privileges..." -ForegroundColor Yellow
    Start-Process pwsh "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath'`"" -Verb RunAs
    exit
}

# Load environment variables from .env file
if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^(.*?)=(.*)$') {
            Set-Item -Path "env:$($matches[1])" -Value $matches[2]
        }
    }
} else {
    Write-Host "Error: .env file not found!" -ForegroundColor Red
    exit 1
}

# Set Git user details
git config --global user.name $env:USERN
git config --global user.email "$env:USERN@users.noreply.github.com"

# Set safe directory
git config --global --add safe.directory (Get-Location)

# Repository initialization workflow
$tempDir = $null
if (-Not (Test-Path .git)) {
    Write-Host "No Git repository found. Initializing..." -ForegroundColor Yellow
    
    $repo_url = Read-Host "Enter GitHub repository URL (e.g., https://github.com/username/repo.git)"
    
    # Create temp directory for existing files
    $tempDir = Join-Path $env:TEMP "git_temp_$(Get-Date -Format 'yyyyMMddHHmmss')"
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    # Move existing files to temp directory (except .env and .git)
    Get-ChildItem -Path . -Exclude @('.env','.git*') | Move-Item -Destination $tempDir -Force
    
    try {
        # Clone repository
        git clone $repo_url . 2>&1 | Out-Null
        
        # Move files back from temp directory
        Get-ChildItem -Path $tempDir | Move-Item -Destination . -Force -ErrorAction Stop
        
        # Cleanup temp directory
        Remove-Item $tempDir -Recurse -Force
    }
    catch {
        Write-Host "Error during repository setup: $_" -ForegroundColor Red
        if ($tempDir -and (Test-Path $tempDir)) {
            Write-Host "Restoring files from temp directory..." -ForegroundColor Yellow
            Get-ChildItem -Path $tempDir | Move-Item -Destination . -Force
            Remove-Item $tempDir -Recurse -Force
        }
        exit 1
    }
}

# Verify remote exists
if (-Not (git remote show origin 2>&1 | Select-String "Fetch URL:")) {
    $repo_url = Read-Host "Enter GitHub repository URL (e.g., https://github.com/username/repo.git)"
    git remote add origin $repo_url
}

# Branch handling
$branch = Read-Host "Enter branch to push to (default: main)"
if ([string]::IsNullOrWhiteSpace($branch)) { $branch = "main" }
git branch -M $branch

# Pull latest changes before push
try {
    git pull origin $branch --rebase --autostash
}
catch {
    Write-Host "Pull failed - proceeding with local changes" -ForegroundColor Yellow
}

# Commit workflow
git add .
$commit_message = Read-Host "Enter commit message"
git commit -m $commit_message

# Authentication setup
$netrcPath = "$HOME\_netrc"
@"
machine github.com
login $env:USERN
password $env:PASS
"@ | Out-File -Encoding ASCII -FilePath $netrcPath

# Set permissions for cleanup
icacls $netrcPath /inheritance:r /grant:r "$($env:USERNAME):M" > $null

# Push changes
git push -u origin $branch

# Cleanup credentials
Remove-Item -Force $netrcPath

Write-Host "Changes pushed successfully!" -ForegroundColor Green
