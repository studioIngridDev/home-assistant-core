#!/usr/bin/env bash

fail() { echo "FAILED: $1"; exit 1; }

REPO="/workspaces/home-assistant-core"

cd "$REPO" || fail "directory $REPO not found"

current_branch=$(git branch --show-current) || fail "could not determine current branch"

git checkout dev || fail "could not checkout dev"

git fetch upstream || fail "git fetch upstream failed (is upstream configured?)"

git rebase upstream/dev || {
  echo "FAILED: rebase onto upstream/dev (likely conflicts)"
  echo "HINT: resolve conflicts, then run: git rebase --continue or git rebase --abort"
  exit 1
}

git push origin dev --force-with-lease || {
  echo "FAILED: push rejected (remote changed?)"
  echo "HINT: run git fetch origin and retry"
  exit 1
}

git checkout "$current_branch" || fail "could not switch back to $current_branch"

echo "OK: dev synced with upstream and returned to $current_branch"
