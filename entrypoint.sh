#!/bin/bash

set -x  # Enable exit on error, so script stops on any failure

# Input parameters
GITHUB_TOKEN=$1
UPSTREAM_REPO=$2
UPSTREAM_BRANCH=$3
DOWNSTREAM_BRANCH=$4

# Validate inputs with "Missing" message
if [[ -z "$GITHUB_TOKEN" ]]; then 
  echo "Missing: GitHub token."; 
  exit 1; 
fi
if [[ -z "$UPSTREAM_REPO" ]]; then 
  echo "Missing: Upstream repository URL."; 
  exit 1; 
fi
if [[ -z "$UPSTREAM_BRANCH" ]]; then 
  echo "Missing: Upstream branch."; 
  exit 1; 
fi
if [[ -z "$DOWNSTREAM_BRANCH" ]]; then 
  echo "Missing: Downstream branch."; 
  exit 1; 
fi

# Validate token by calling GitHub API
echo "Validating token..."
VALID_TOKEN=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/user)

if [[ "$VALID_TOKEN" != "200" ]]; then
  echo "Invalid token. Exiting."
  exit 1
else
  echo "Token is valid."
fi

# Echo the parameters being used
echo "Using GitHub Token: $GITHUB_TOKEN"
echo "Using Upstream Repository: $UPSTREAM_REPO"
echo "Using Upstream Branch: $UPSTREAM_BRANCH"
echo "Using Downstream Branch: $DOWNSTREAM_BRANCH"

# Ensure the repository URL ends with .git
echo "Checking if upstream repo URL ends with .git..."
if [[ ! "$UPSTREAM_REPO" =~ \.git$ ]]; then
  UPSTREAM_REPO="$UPSTREAM_REPO.git"
  echo "Appended '.git' to upstream repository URL: $UPSTREAM_REPO"
else
  echo "Upstream repository URL already has '.git' suffix: $UPSTREAM_REPO"
fi

# Clone the forked repository
echo "Cloning the forked repository..."
echo "git clone https://x-access-token:$GITHUB_TOKEN@github.com/${GITHUB_REPOSITORY}.git forked-repo"
git clone https://x-access-token:$GITHUB_TOKEN@github.com/${GITHUB_REPOSITORY}.git forked-repo
cd forked-repo

# Ensure that the cloned repository exists
echo "Checking if 'forked-repo' directory exists..."
if [[ ! -d "forked-repo" ]]; then
  echo "Error: Repository clone failed. Directory 'forked-repo' does not exist."
  exit 1
fi

# Configure Git using GitHub Actor
echo "Configuring Git with GitHub Actor details..."
echo "git config user.name \"$GITHUB_ACTOR\""
git config user.name "$GITHUB_ACTOR"
echo "git config user.email \"$GITHUB_ACTOR@users.noreply.github.com\""
git config user.email "$GITHUB_ACTOR@users.noreply.github.com"

# Add the upstream repository and fetch updates
echo "Adding upstream remote repository and fetching updates..."
echo "git remote add upstream $UPSTREAM_REPO"
git remote add upstream $UPSTREAM_REPO
echo "git remote -v"
git remote -v | grep -q "upstream"

# Check if upstream remote has been added successfully
if [[ $? -ne 0 ]]; then
  echo "Error: 'upstream' remote not found. Exiting."
  exit 1
else
  echo "Upstream remote added successfully."
fi

echo "git fetch upstream"
git fetch upstream
echo "Upstream repository fetched successfully."

# Checkout downstream branch
echo "Checking out downstream branch: $DOWNSTREAM_BRANCH"
echo "git checkout $DOWNSTREAM_BRANCH"
git checkout $DOWNSTREAM_BRANCH

# Pre-merge check to see if there are changes in the upstream branch
echo "git diff upstream/$UPSTREAM_BRANCH"
git diff upstream/$UPSTREAM_BRANCH
if [[ $? -ne 0 ]]; then
  echo "There are changes in the upstream branch. Proceeding with merge."
else
  echo "No changes to merge."
fi

# Merging upstream branch into downstream branch
echo "Merging upstream branch: $UPSTREAM_BRANCH into downstream branch: $DOWNSTREAM_BRANCH"
echo "git merge upstream/$UPSTREAM_BRANCH --no-edit"
git merge upstream/$UPSTREAM_BRANCH --no-edit
echo "Merge completed successfully."

# Check if there are any changes to push
echo "git status --porcelain"
CHANGES=$(git status --porcelain)
if [[ -z "$CHANGES" ]]; then
  echo "Already up to date. No changes to push."
else
  echo "Changes detected. Committing changes before pushing."
  echo "git add ."
  git add .
  echo "git commit -m \"Merge upstream branch $UPSTREAM_BRANCH into $DOWNSTREAM_BRANCH\""
  git commit -m "Merge upstream branch $UPSTREAM_BRANCH into $DOWNSTREAM_BRANCH"
  echo "Changes committed successfully."
  
  echo "Pushing changes to the downstream branch: $DOWNSTREAM_BRANCH..."
  echo "git push origin $DOWNSTREAM_BRANCH"
  git push origin $DOWNSTREAM_BRANCH
  echo "Changes pushed successfully to downstream branch."
fi

# Clean up by removing the cloned repository
echo "Cleaning up by removing the cloned repository."
cd ..
echo "rm -rf forked-repo"
rm -rf forked-repo
echo "Cleaned up by removing the cloned repository."
