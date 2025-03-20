#!/bin/bash

# GitHub Token 
GITHUB_TOKEN="ghp_"
GITHUB_ORG="org-name"

# GitHub API URL
GITHUB_API="https://api.github.com"

PAGE=1
PER_PAGE=100 

# clean if exists
> repos.txt

echo "Fetching repositories for organization: $GITHUB_ORG..."

while true; do
    RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "$GITHUB_API/orgs/$GITHUB_ORG/repos?per_page=$PER_PAGE&page=$PAGE")

    # break if null
    if [[ $(echo "$RESPONSE" | jq '. | length') -eq 0 ]]; then
        break
    fi

    echo "$RESPONSE" | jq -r '.[].name' >> repos.txt

    # next page
    PAGE=$((PAGE + 1))
done

echo "All repositories saved to repos.txt!"
