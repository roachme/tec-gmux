#!/bin/bash

# Configuration file path (default: ./git-repos-config.json)
CONFIG_FILE="${1:-./git-repos-config.json}"

# Check if jq is installed (required for JSON parsing)
if ! command -v jq &> /dev/null; then
    echo "❌ Error: 'jq' is required. Install it with:"
    echo "  Ubuntu/Debian: sudo apt install jq"
    echo "  macOS: brew install jq"
    exit 1
fi

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

# Read config
REPOS=$(jq -c '.repos[]' "$CONFIG_FILE")

# Function to execute Git command in all repos
function git_multiple_do() {
    local cmd="$1"
    echo "🚀 Running: '$cmd' on all repos..."
    echo "----------------------------------"

    while IFS= read -r repo; do
        local name=$(echo "$repo" | jq -r '.name')
        local path=$(echo "$repo" | jq -r '.path')
        local branch=$(echo "$repo" | jq -r '.branch // "main"')

        echo "📁 Repo: $name (Branch: $branch)"
        echo "📍 Path: $path"

        if [[ ! -d "$path" ]]; then
            echo "⚠️  Directory does not exist. Skipping."
            continue
        fi

        cd "$path" || { echo "❌ Failed to enter $path"; continue; }

        # Execute Git command
        echo "💻 Running: git $cmd"
        git $cmd

        cd - > /dev/null || exit
        echo "----------------------------------"
    done <<< "$REPOS"
}

# Function to create a branch in all repos
function git_create_branch() {
    local new_branch="$1"
    echo "🌿 Creating branch '$new_branch' in all repos..."
    echo "----------------------------------"

    while IFS= read -r repo; do
        local name=$(echo "$repo" | jq -r '.name')
        local path=$(echo "$repo" | jq -r '.path')
        local base_branch=$(echo "$repo" | jq -r '.branch // "main"')

        echo "📁 Repo: $name (Base: $base_branch)"
        echo "📍 Path: $path"

        if [[ ! -d "$path" ]]; then
            echo "⚠️  Directory does not exist. Skipping."
            continue
        fi

        cd "$path" || { echo "❌ Failed to enter $path"; continue; }

        # Check if branch already exists
        if git show-ref --quiet "refs/heads/$new_branch"; then
            echo "⚠️  Branch '$new_branch' already exists. Skipping."
        else
            git checkout "$base_branch"
            git pull origin "$base_branch"
            git checkout -b "$new_branch"
            echo "✅ Created branch '$new_branch'"
        fi

        cd - > /dev/null || exit
        echo "----------------------------------"
    done <<< "$REPOS"
}

# Function to delete a branch in all repos
function git_delete_branch() {
    local target_branch="$1"
    echo "🗑️  Deleting branch '$target_branch' in all repos..."
    echo "----------------------------------"

    while IFS= read -r repo; do
        local name=$(echo "$repo" | jq -r '.name')
        local path=$(echo "$repo" | jq -r '.path')
        local current_branch=$(echo "$repo" | jq -r '.branch // "main"')

        echo "📁 Repo: $name (Current: $current_branch)"
        echo "📍 Path: $path"

        if [[ ! -d "$path" ]]; then
            echo "⚠️  Directory does not exist. Skipping."
            continue
        fi

        cd "$path" || { echo "❌ Failed to enter $path"; continue; }

        # Check if branch exists
        if ! git show-ref --quiet "refs/heads/$target_branch"; then
            echo "⚠️  Branch '$target_branch' does not exist. Skipping."
        else
            git checkout "$current_branch"
            git branch -D "$target_branch"
            echo "✅ Deleted branch '$target_branch'"
        fi

        cd - > /dev/null || exit
        echo "----------------------------------"
    done <<< "$REPOS"
}

# Main menu
function show_menu() {
    echo "🔧 Git Multi-Repo Manager 🔧"
    echo "1. Pull all repos"
    echo "2. Fetch all repos"
    echo "3. Create branch in all repos"
    echo "4. Delete branch in all repos"
    echo "5. Exit"
    read -p "Choose an option (1-5): " choice

    case "$choice" in
        1) git_multiple_do "pull" ;;
        2) git_multiple_do "fetch --all" ;;
        3) read -p "Enter new branch name: " new_branch && git_create_branch "$new_branch" ;;
        4) read -p "Enter branch to delete: " del_branch && git_delete_branch "$del_branch" ;;
        5) exit 0 ;;
        *) echo "❌ Invalid choice" && show_menu ;;
    esac
}

show_menu
