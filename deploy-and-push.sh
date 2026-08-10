#!/usr/bin/env bash
set -euo pipefail

MESSAGE="${1:-Deploy $(date '+%Y-%m-%d %H:%M:%S')}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository."
  exit 1
fi

REMOTE_NAME="origin"
if ! git remote get-url "${REMOTE_NAME}" >/dev/null 2>&1; then
  echo "No git remote named '${REMOTE_NAME}' is configured."
  echo "Add one first, for example:"
  echo "  git remote add origin git@github.com:<your-user>/willowhousephotography.com.git"
  exit 1
fi

BRANCH="$(git branch --show-current)"
if [[ -z "${BRANCH}" ]]; then
  echo "Unable to detect current branch."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "${MESSAGE}"
else
  echo "No local changes to commit."
fi

bash upload-site.sh

git push -u "${REMOTE_NAME}" "${BRANCH}"

echo "Deployment complete and commit pushed to ${REMOTE_NAME}/${BRANCH}."
