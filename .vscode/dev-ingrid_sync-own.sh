#!/usr/bin/env bash

fail() { echo "FAILED: $1"; exit 1; }

REPO="/workspaces/home-assistant-core"

cd "$REPO" || fail "directory $REPO not found"

current_branch=$(git branch --show-current) || fail "could not determine current branch"

if [ "$current_branch" = "dev" ]; then
  fail "this task is for feature branches, not dev"
fi

git fetch origin || fail "git fetch origin failed"

# Abort any in-progress rebase silently
git rebase --abort >/dev/null 2>&1 || true

# Rebase with automatic conflict resolution: origin/dev-copy wins
git rebase -X ours origin/dev || {
  echo "FAILED: rebase onto origin/dev even with automatic conflict resolution"
  echo "HINT: try: git rebase --abort"
  exit 1
}

git push origin "$current_branch" --force-with-lease || {
  echo "FAILED: push rejected (remote changed?)"
  echo "HINT: run git fetch origin and retry"
  exit 1
}

echo "OK: $current_branch rebased onto origin/dev (origin/dev-copy wins) and pushed"