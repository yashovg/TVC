#!/bin/zsh

# Check the status of the repository
git status

# Add all changes to the staging area
git add .

# Commit the changes with a message
git commit -m "updates"

# Push the changes to the main branch
git push origin main
