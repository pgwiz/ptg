# PTG - Push to Git

A collection of automation scripts for streamlining Git operations with GitHub repositories.

## Overview

PTG provides simple scripts to automate the process of adding, committing, and pushing changes to GitHub repositories. It handles authentication using Personal Access Tokens and supports both Windows (PowerShell) and Unix-like systems (Bash).

## Features

- Automatic Git configuration setup
- Environment-based authentication using Personal Access Tokens
- Repository initialization if needed
- Interactive prompts for branch names and commit messages
- Secure credential handling with automatic cleanup
- Cross-platform support (Windows PowerShell and Unix/Linux Bash)

## Prerequisites

- Git installed on your system
- GitHub account
- GitHub Personal Access Token with appropriate permissions

## Setup

1. Create a `.env` file in the project directory with the following variables:

```env
USERN=your-github-username
PASS=your-github-personal-access-token
```

2. Ensure the `.env` file is added to `.gitignore` to prevent committing sensitive credentials

## Usage

### Windows (PowerShell)

```powershell
.\ptg.ps1
```

### Linux/Mac (Bash)

```bash
chmod +x ptg.sh
./ptg.sh
```

### Interactive Workflow

When you run the script, it will:

1. Load credentials from `.env` file
2. Configure Git with your username and email
3. Initialize Git repository (if not already initialized)
4. Prompt for the target branch name (default: main)
5. Stage all changes (`git add .`)
6. Prompt for a commit message
7. Commit the changes
8. Push to the specified branch on GitHub
9. Clean up authentication credentials

## Security Notes

- The scripts create temporary `.netrc` files for authentication
- Credentials are automatically removed after pushing
- The `.netrc` file is secured with appropriate permissions
- Never commit your `.env` file to version control

## Files

- `ptg.ps1` - PowerShell version for Windows
- `ptg.sh` - Bash version for Unix/Linux/Mac
- `ptg2.ps1` - Alternative PowerShell implementation

## License

This project is provided as-is for automation convenience.