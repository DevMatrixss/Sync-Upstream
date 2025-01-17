#!/bin/bash

set -x  # Enable debug mode to print each command being executed

# Input parameters
GITHUB_TOKEN=$1
UPSTREAM_REPO=$2
UPSTREAM_BRANCH=$3
DOWNSTREAM_BRANCH=$4

# Validate inputs with "Missing" message
if [[ -z "$GITHUB_TOKEN" ]]; then echo "Missing: GitHub token."; exit 1; fi
if [[ -z "$UPSTREAM_REPO" ]]; then echo "Missing: Upstream repository URL."; exit 1; fi
if [[ -z "$UPSTREAM_BRANCH" ]]; then echo "Missing: Upstream branch."; exit 1; fi
if [[ -z "$DOWNSTREAM_BRANCH" ]]; then echo "Missing: Downstream branch."; exit 1; fi

# Validate GitHub Token by making an authenticated request to the GitHub API
echo "Validating GitHub token..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)

if [[ "$RESPONSE" -ne 200 ]]; then
  echo "Invalid GitHub token. HTTP Response: $RESPONSE"
  exit 1  # If the token is invalid, the script will exit here
else
  echo "GitHub token is valid."
fi

# Echo the parameters being used
echo "Using GitHub Token: $GITHUB_TOKEN"
echo "Using Upstream Repository: $UPSTREAM_REPO"
echo "Using Upstream Branch: $UPSTREAM_BRANCH"
echo "Using Downstream Branch: $DOWNSTREAM_BRANCH"

# Ensure the repository URL ends with .git
if [[ ! "$UPSTREAM_REPO" =~ \.git$ ]]; then
  UPSTREAM_REPO="$UPSTREAM_REPO.git"
  echo "Appended '.git' to upstream repository URL: $UPSTREAM_REPO"
else
  echo "Upstream repository URL already has '.git' suffix: $UPSTREAM_REPO"
fi

# Clone the forked repository
echo "Cloning the forked repository..."
git clone https://x-access-token:$GITHUB_TOKEN@github.com/${GITHUB_REPOSITORY}.git forked-repo
cd forked-repo

# Configure Git using GitHub Actor
echo "Configuring Git with GitHub Actor details..."
git config user.name "$GITHUB_ACTOR"
git config user.email "$GITHUB_ACTOR@users.noreply.github.com"

# Add the upstream repository and fetch updates
echo "Adding upstream remote repository and fetching updates..."
git remote add upstream $UPSTREAM_REPO
git fetch upstream

# Checkout downstream branch
echo "Checking out downstream branch: $DOWNSTREAM_BRANCH"
git checkout $DOWNSTREAM_BRANCH

# Merging upstream branch into downstream branch
echo "Merging upstream branch: $UPSTREAM_BRANCH into downstream branch: $DOWNSTREAM_BRANCH"
if ! git merge upstream/$UPSTREAM_BRANCH --no-edit; then
  echo "Error: Merge conflicts detected. Please resolve conflicts manually."
  exit 1
else
  echo "Merge completed successfully."
fi

# Check if there are any changes to push
if [[ -z "$(git status --porcelain)" ]]; then
  echo "Already up to date. No changes to push."
else
  echo "Pushing changes to the downstream branch: $DOWNSTREAM_BRANCH..."
  git push origin $DOWNSTREAM_BRANCH
fi

# Clean up by removing the cloned repository
cd ..
rm -rf forked-repo
echo "Cleaned up by removing the cloned repository."
