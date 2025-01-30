#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found!"
    exit 1
fi

# Set Git user details
git config --global user.name "$USERN"
git config --global user.email "$USERN@users.noreply.github.com"  # Use a noreply email for privacy

# Set the current directory as a safe Git directory
git config --global --add safe.directory "$(pwd)"

# Check if inside a Git repository
if [ ! -d ".git" ]; then
    echo "Not a git repository. Initializing..."
    git init
    read -p "Enter the full GitHub repository URL (e.g., https://github.com/org/repo.git): " repo_url
    git remote add origin "$repo_url"
fi

# Prompt for branch name (default: main)
read -p "Enter the branch to push to (default: main): " branch
branch=${branch:-main}

# Ensure the branch name is correctly set
git branch -M "$branch"

# Add all changes
git add .

# Prompt for commit message
read -p "Enter commit message: " commit_message
git commit -m "$commit_message"

# Authenticate using Personal Access Token
echo "machine github.com login $USERN password $PASS" > ~/.netrc
chmod 600 ~/.netrc  # Secure the credentials file

# Push changes
git push -u origin "$branch"

# Cleanup after pushing
rm -f ~/.netrc

echo "Changes pushed successfully!"
