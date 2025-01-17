#!/bin/bash

# Define Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NO_COLOR='\033[0m'  # No Color

set -x  # Enable debug mode to print each command being executed

# Input parameters
GITHUB_TOKEN=$1
UPSTREAM_REPO=$2
UPSTREAM_BRANCH=$3
DOWNSTREAM_BRANCH=$4

# Function to print messages in color
print_msg() {
  echo -e "$1$2$NO_COLOR"
}

# Validate inputs with "Missing" message
if [[ -z "$GITHUB_TOKEN" ]]; then
  print_msg "$RED" "Missing: GitHub token."
  exit 1
fi
if [[ -z "$UPSTREAM_REPO" ]]; then
  print_msg "$RED" "Missing: Upstream repository URL."
  exit 1
fi
if [[ -z "$UPSTREAM_BRANCH" ]]; then
  print_msg "$RED" "Missing: Upstream branch."
  exit 1
fi
if [[ -z "$DOWNSTREAM_BRANCH" ]]; then
  print_msg "$RED" "Missing: Downstream branch."
  exit 1
fi

# Validate GitHub Token by making an authenticated request to the GitHub API
echo "::group::Validating GitHub token..."
print_msg "$CYAN" "Validating GitHub token..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)

if [[ "$RESPONSE" -ne 200 ]]; then
  print_msg "$RED" "Invalid GitHub token. HTTP Response: $RESPONSE"
  exit 1  # If the token is invalid, the script will exit here
else
  print_msg "$GREEN" "GitHub token is valid."
fi
echo "::endgroup::"

# Echo the parameters being used
echo "::group::Parameters"
print_msg "$YELLOW" "Using GitHub Token: $GITHUB_TOKEN"
print_msg "$YELLOW" "Using Upstream Repository: $UPSTREAM_REPO"
print_msg "$YELLOW" "Using Upstream Branch: $UPSTREAM_BRANCH"
print_msg "$YELLOW" "Using Downstream Branch: $DOWNSTREAM_BRANCH"
echo "::endgroup::"

# Ensure the repository URL ends with .git
if [[ ! "$UPSTREAM_REPO" =~ \.git$ ]]; then
  UPSTREAM_REPO="$UPSTREAM_REPO.git"
  print_msg "$CYAN" "Appended '.git' to upstream repository URL: $UPSTREAM_REPO"
else
  print_msg "$CYAN" "Upstream repository URL already has '.git' suffix: $UPSTREAM_REPO"
fi

# Clone the forked repository
echo "::group::Cloning the forked repository..."
print_msg "$BLUE" "Cloning the forked repository..."
git clone https://x-access-token:$GITHUB_TOKEN@github.com/${GITHUB_REPOSITORY}.git forked-repo
cd forked-repo
echo "::endgroup::"

# Configure Git using GitHub Actor
echo "::group::Configuring Git..."
print_msg "$BLUE" "Configuring Git with GitHub Actor details..."
git config user.name "$GITHUB_ACTOR"
git config user.email "$GITHUB_ACTOR@users.noreply.github.com"
echo "::endgroup::"

# Add the upstream repository and fetch updates
echo "::group::Adding upstream remote repository and fetching updates..."
print_msg "$CYAN" "Adding upstream remote repository and fetching updates..."
git remote add upstream $UPSTREAM_REPO
git fetch upstream
echo "::endgroup::"

# Checkout downstream branch
echo "::group::Checking out downstream branch..."
print_msg "$CYAN" "Checking out downstream branch: $DOWNSTREAM_BRANCH"
git checkout $DOWNSTREAM_BRANCH
echo "::endgroup::"

# Merging upstream branch into downstream branch
echo "::group::Merging upstream branch..."
print_msg "$CYAN" "Merging upstream branch: $UPSTREAM_BRANCH into downstream branch: $DOWNSTREAM_BRANCH"
if ! git merge upstream/$UPSTREAM_BRANCH --no-edit; then
  print_msg "$RED" "Error: Merge conflicts detected. Please resolve conflicts manually."
  exit 1
else
  print_msg "$GREEN" "Merge completed successfully."
fi
echo "::endgroup::"

# Check if there are any changes to push
echo "::group::Checking for changes to push..."
if [[ -z "$(git status --porcelain)" ]]; then
  print_msg "$GREEN" "Already up to date. No changes to push."
else
  print_msg "$BLUE" "Pushing changes to the downstream branch: $DOWNSTREAM_BRANCH..."
  git push origin $DOWNSTREAM_BRANCH
  print_msg "$GREEN" "Changes pushed successfully."
fi
echo "::endgroup::"

# Clean up by removing the cloned repository
echo "::group::Cleaning up..."
cd ..
rm -rf forked-repo
print_msg "$YELLOW" "Cleaned up by removing the cloned repository."
echo "::endgroup::"
