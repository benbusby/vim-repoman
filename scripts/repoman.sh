#!/bin/bash
# Primary entry point for all external repoman commands
#
# Usage: ./repoman.sh <json>

SCRIPT_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
GITHUB_TOKEN="$SCRIPT_DIR/../.github.repoman"
GITLAB_TOKEN="$SCRIPT_DIR/../.gitlab.repoman"

# shellcheck source=/dev/null
source "$SCRIPT_DIR"/repoman_utils.sh

# The script accepts a single json formatted argument to use for each
# request.
#
# Example:
# {
#    "token_pw": "supersecret",
#    "command": "view_all"
# }
export JSON_ARG="$1"

# Run command dependent on github/gitlab location
export API_KEY
case $(git ls-remote --get-url) in
    *"github"*)
        API_KEY="$(openssl aes-256-cbc -d -a -pbkdf2 -in \
            "$GITHUB_TOKEN" -k "$(jq_read "$JSON_ARG" token_pw)")"
        "$SCRIPT_DIR"/repoman_github.sh
        ;;
    *"gitlab"*)
        API_KEY="$(openssl aes-256-cbc -d -a -pbkdf2 -in \
            "$GITLAB_TOKEN" -k "$(jq_read "$JSON_ARG" token_pw)")"
        "$SCRIPT_DIR"/repoman_gitlab.sh
        ;;
    *)
        echo "ERROR: Unrecognized repo location"
        exit 1
        ;;
esac