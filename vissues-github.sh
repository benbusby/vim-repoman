#!/bin/bash
# Script for testing creation/viewing of github issues
#
# Usage: ./vissues.sh <command (create|view)> <username> <api key>

PREFIXES=("https://github.com/" "git@github.com:" "https://gitlab.com/" "git@gitlab.com:")
SUFFIXES=(".git")
USAGE="./vissues.sh <command (create|view)> <username> <api key>"
FOOTER="\n\n<hr>\n\n<sub>_This issue was created with [Vissues](https://github.com/benbusby/vissues)!_</sub>"

COMMAND=$1
USERNAME=$2
API_KEY=$3
REPO_PATH=$(git remote get-url origin)

# Exit early if not in a git repo
if [[ -z "$REPO_PATH" ]]; then
    echo "Not in a git repo"
    exit 1
elif [[ $# -ne 3 ]]; then
    echo "Wrong number of arguments"
    echo "$USAGE"
    exit 1
fi

# Clean up prefixes/suffixes
for PREFIX in ${PREFIXES[@]}; do
    REPO_PATH=${REPO_PATH#"$PREFIX"}
done

for SUFFIX in ${SUFFIXES[@]}; do
    REPO_PATH=${REPO_PATH%"$SUFFIX"}
done

# Create new issue
if [[ "$COMMAND" == "create" ]]; then
    curl -o /dev/null -s -w "%{http_code}" \
        -A "$USERNAME" \
        -bc /tmp/vissues-cookies \
        -u $USERNAME:$API_KEY \
        --data '{"title": "Vissues Test", "body": "Test\n\n<hr>\n\n<sub>_This issue was created with [Vissues](https://github.com/benbusby/vissues)!_</sub>", "labels": ["ignore"]}' \
        -X POST "https://api.github.com/repos/$REPO_PATH/issues"
elif [[ "$COMMAND" == "view" ]]; then
    curl -v -A "$USERNAME" -bc /tmp/vissues-cookies -u "$USERNAME:$API_KEY" "https://api.github.com/repos/${REPO_PATH}/issues"
else
    echo "Unknown command (should be 'create' or 'view')"
fi
