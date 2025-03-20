#!/bin/bash

# GitHub Token
GITHUB_TOKEN="ghp_"
GITHUB_ORG="org-name"


# GitHub API URL
GITHUB_API="https://api.github.com"

# read repo list in file
if [[ ! -f repos.txt ]]; then
    echo "Error: repos.txt not found! Run get_repos.sh first."
    exit 1
fi

echo "Reading repositories from repos.txt..."

while read -r REPO; do
    echo "Ignoring notifications for $GITHUB_ORG/$REPO..."

    # ignore notified
    curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "$GITHUB_API/repos/$GITHUB_ORG/$REPO/subscription" \
        -d '{"ignored": true}'
    
    echo "Done!"
done < repos.txt

echo "All repositories are now ignored!"
