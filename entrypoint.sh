#!/bin/bash

set -e

GITHUB_TOKEN=$1
UPSTREAM_REPO=$2
UPSTREAM_BRANCH=$3
DOWNSTREAM_BRANCH=$4

if [[ -z "$GITHUB_TOKEN" || -z "$UPSTREAM_REPO" || -z "$UPSTREAM_BRANCH" || -z "$DOWNSTREAM_BRANCH" ]]; then 
    echo "Missing: GitHub token, Upstream repository URL, Upstream branch, or Downstream branch."
    exit 1
fi

echo "Validating token..."
VALID_TOKEN=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    https://api.github.com/user)
echo "Response code from GitHub API: $VALID_TOKEN"

if [[ "$VALID_TOKEN" != "200" ]]; then
    echo "Invalid token. Exiting."
    exit 1
else
    echo "Token is valid."
fi

echo "Using GitHub Token: $GITHUB_TOKEN"
echo "Using Upstream Repository: $UPSTREAM_REPO"
echo "Using Upstream Branch: $UPSTREAM_BRANCH"
echo "Using Downstream Branch: $DOWNSTREAM_BRANCH"

echo "Checking if upstream repo URL ends with .git..."
if [[ ! "$UPSTREAM_REPO" =~ \.git$ ]]; then
    UPSTREAM_REPO="$UPSTREAM_REPO.git"
    echo "Appended '.git' to upstream repo URL: $UPSTREAM_REPO"
else
    echo "Upstream repo URL already ends with '.git'"
fi

echo "Setting remote URL for repository..."
echo "git remote set-url origin \
https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

echo "Cloning the repository..."
echo "git clone \
https://x-access-token:$GITHUB_TOKEN@github.com/${GITHUB_REPOSITORY}.git forked-repo"
git clone https://x-access-token:$GITHUB_TOKEN@github.com/${GITHUB_REPOSITORY}.git forked-repo

if [[ ! -d "forked-repo" ]]; then
    echo "Error: Repository not cloned. Exiting."
    exit 1
else
    echo "Repository cloned successfully."
fi

cd forked-repo

echo "Configuring Git user..."
echo "git config user.name \"$GITHUB_ACTOR\""
git config user.name "$GITHUB_ACTOR"
echo "git config user.email \"$GITHUB_ACTOR@users.noreply.github.com\""
git config user.email "$GITHUB_ACTOR@users.noreply.github.com"

echo "Adding upstream remote repository..."
echo "git remote add upstream $UPSTREAM_REPO"
git remote add upstream $UPSTREAM_REPO
echo "git remote -v"
git remote -v | grep -q "upstream"

if [[ $? -ne 0 ]]; then
    echo "Error: 'upstream' remote not found. Exiting."
    exit 1
else
    echo "Upstream remote added successfully."
fi

echo "Fetching upstream changes..."
echo "git fetch upstream"
git fetch upstream

echo "Checking out downstream branch: $DOWNSTREAM_BRANCH"
echo "git checkout $DOWNSTREAM_BRANCH"
git checkout $DOWNSTREAM_BRANCH

echo "Merging upstream branch: $UPSTREAM_BRANCH into downstream branch: $DOWNSTREAM_BRANCH"
echo "git merge upstream/$UPSTREAM_BRANCH"
git merge upstream/$UPSTREAM_BRANCH

if [[ $? -ne 0 ]]; then
    echo "Merge conflict detected. Please resolve conflicts manually."

echo "Checking for changes to push..."
echo "git status --porcelain"
CHANGES=$(git status --porcelain)

if [[ -z "$CHANGES" ]]; then
    echo "Already up to date. No changes to push."
else
    echo "Changes detected. Committing changes before pushing."
    echo "git add ."
    git add .
    echo "git commit -m \"Sync upstream changes to $DOWNSTREAM_BRANCH\""
    git commit -m "Sync upstream changes to $DOWNSTREAM_BRANCH"
    echo "git push origin $DOWNSTREAM_BRANCH"
    git push origin $DOWNSTREAM_BRANCH
    echo "Changes pushed successfully."
fi

echo "Cleaning up by removing the cloned repository."
cd ..
echo "rm -rf forked-repo"
rm -rf forked-repo
echo "Cleaned up by removing the cloned repository."
