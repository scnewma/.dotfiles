#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "usage: $0 <commit message>" >&2
    exit 2
}

(($# > 0)) || usage

commit_message="$*"
repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

branch=$(git symbolic-ref --quiet --short HEAD) || {
    echo "error: detached HEAD is not supported" >&2
    exit 1
}

if [[ "$branch" == "master" ]]; then
    echo "error: run this from the branch that master should be merged back into" >&2
    exit 1
fi

old_master=$(git rev-parse --verify refs/heads/master) || {
    echo "error: local master branch does not exist" >&2
    exit 1
}
old_head=$(git rev-parse HEAD)

if git diff --cached --quiet; then
    echo "error: there are no staged changes to commit" >&2
    exit 1
fi

if [[ -n $(git diff --name-only --diff-filter=U) ]]; then
    echo "error: resolve index conflicts first" >&2
    exit 1
fi

if ! git merge-base --is-ancestor "$old_master" "$old_head"; then
    echo "error: merge master into $branch before staging changes" >&2
    exit 1
fi

if git worktree list --porcelain | grep -Fxq "branch refs/heads/master"; then
    echo "error: master is checked out in another worktree" >&2
    exit 1
fi

index_tree=$(git write-tree)
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/commit-staged-to-master.XXXXXX")
patch_file="$tmp_root/staged.patch"
master_worktree="$tmp_root/master"
branch_worktree="$tmp_root/branch"

git diff --cached --binary --full-index >"$patch_file"

cleanup() {
    git worktree remove --force "$branch_worktree" >/dev/null 2>&1 || true
    git worktree remove --force "$master_worktree" >/dev/null 2>&1 || true
    rm -rf "$tmp_root"
}
trap cleanup EXIT

git worktree add --quiet --detach "$master_worktree" "$old_master"
git -C "$master_worktree" apply --index --3way "$patch_file"
git -C "$master_worktree" commit -m "$commit_message"
new_master=$(git -C "$master_worktree" rev-parse HEAD)

git worktree add --quiet --detach "$branch_worktree" "$old_head"
git -C "$branch_worktree" merge --no-ff --no-edit \
    -m "Merge branch 'master' into $branch" "$new_master"
new_head=$(git -C "$branch_worktree" rev-parse HEAD)
merged_tree=$(git -C "$branch_worktree" rev-parse 'HEAD^{tree}')

if [[ "$merged_tree" != "$index_tree" ]]; then
    echo "error: merged tree differs from the staged tree; no branch refs were changed" >&2
    echo "The staged changes may depend on commits unique to $branch." >&2
    exit 1
fi

printf 'update refs/heads/master %s %s\nupdate refs/heads/%s %s %s\n' \
    "$new_master" "$old_master" "$branch" "$new_head" "$old_head" |
    git update-ref -m "commit staged changes to master and merge back" --stdin

printf 'Committed staged changes to master: %s\n' "$new_master"
printf 'Merged master into %s: %s\n' "$branch" "$new_head"
