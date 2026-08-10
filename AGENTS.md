# Agent instructions

## GitHub authentication and agent branches

- Run `/home/ubuntu/authenticate-github.sh` before GitHub operations when credentials are missing or expired.
- Agent branches must use the `x-ai/ardentperf/` prefix; never push directly to `main`.
- Create or update commits with the GitHub Git Data API via `gh api repos/ardentperf/{repo}/git/...`.
- Do not use `git commit` or `git push` for agent branches; API-created commits are signed automatically.
- If authentication fails with HTTP 401, `Bad credentials`, or an invalid-token message, rerun the authentication script.

## Running `act`

Use `act` from the repository root to run the regression workflow locally.

Recommended invocation for the PostgreSQL 18 job:

```bash
act -j test -W .github/workflows/regression.yml -e .act/event.json --matrix pg:18 --network bridge
```

Notes:

- The `--network bridge` flag is required to avoid port conflicts when multiple tests run in parallel.
- Run from the repo root so `act` can copy the current workspace into the container.
- If you change test SQL or expected output, rerun the same command after the edit.

## GitHub API signed commits

Use the GitHub App auth script before publishing agent branches:

```sh
~/authenticate-github.sh
```

The script configures a short-lived GitHub App token for `gh` and Git. Branches must use the protected agent prefix:

```text
x-ai/ardentperf/
```

Direct `git push` can upload local commits, but repository rules reject them because they are not verified signatures. To get verified commits, create commit objects with the GitHub Git Data API and omit explicit author/committer fields.

Minimal flow for one branch:

```sh
base=$(git rev-parse gh/master)
branch=x-ai/ardentperf/example-branch

gh api -X POST repos/ardentperf/pgsentinel/git/refs \
  -f ref="refs/heads/$branch" \
  -f sha="$base"

base_tree=$(gh api repos/ardentperf/pgsentinel/git/commits/$base --jq '.tree.sha')

tree_sha=$( 
  jq -n \
    --arg base_tree "$base_tree" \
    --rawfile file path/to/local/file \
    '{base_tree:$base_tree, tree:[
      {path:"path/in/repo", mode:"100644", type:"blob", content:$file}
    ]}' |
  gh api repos/ardentperf/pgsentinel/git/trees --input - --jq '.sha'
)

commit_sha=$(
  jq -n \
    --arg message "Commit subject"$'\n\n'"Commit body" \
    --arg tree "$tree_sha" \
    --arg parent "$base" \
    '{message:$message, tree:$tree, parents:[$parent]}' |
  gh api repos/ardentperf/pgsentinel/git/commits --input - --jq '.sha'
)

gh api -X PATCH "repos/ardentperf/pgsentinel/git/refs/heads/$branch" \
  -f sha="$commit_sha" \
  -F force=false
```

Verify the resulting commit signature:

```sh
gh api repos/ardentperf/pgsentinel/commits/$commit_sha \
  --jq '{sha:.sha, verified:.commit.verification.verified, reason:.commit.verification.reason}'
```

Expected result:

```json
{"verified":true,"reason":"valid"}
```

After creating or updating a signed commit through the API, synchronize the
local checkout with the remote branch. The API-created commit is not added to
the local branch automatically:

```sh
git fetch origin "$branch"
git rebase "origin/$branch"
```

Resolve any rebase conflicts, run the relevant tests, and verify the branch
with `git status` and `git log`. If the local branch has no commits or changes
that need to be preserved and is only a stale checkout of the API-created
branch, it may instead be aligned directly with `git reset --hard
"origin/$branch"`; confirm the working tree is disposable before using that
command.
