# Git Configuration

## Aliases

### Add

| Alias | Command | Description |
|-------|---------|-------------|
| `ap` | `add -p` | Interactive staging (patch mode) |

### Branch

| Alias | Command | Description |
|-------|---------|-------------|
| `br` | `branch -v` | List branches with last commit |
| `bra` | `branch -a` | List all branches (incl. remote) |
| `brd` | `branch -D` | Force delete branch |
| `brm` | `branch -m` | Rename branch |

### Commit

| Alias | Command | Description |
|-------|---------|-------------|
| `ci` | `commit` | Commit |
| `civ` | `commit -v` | Commit with diff preview |
| `amend` | `commit --amend` | Amend last commit |

### Checkout

| Alias | Command | Description |
|-------|---------|-------------|
| `co` | `checkout` | Checkout |
| `cob` | `checkout -b` | Create and checkout branch |
| `co-pr` | fetch + checkout | Checkout PR by number (`git co-pr 123`) |

### Fetch

| Alias | Command | Description |
|-------|---------|-------------|
| `fo` | `fetch origin` | Fetch from origin |
| `fu` | `fetch upstream` | Fetch from upstream |
| `fro` | fetch + rebase | Fetch origin and rebase on master |
| `frod` | fetch + rebase | Fetch origin and rebase on development |
| `fru` | fetch + rebase | Fetch upstream and rebase on master |

### Fixup / Squash

| Alias | Command | Description |
|-------|---------|-------------|
| `fixup` | commit fixup | Create fixup commit for given SHA |
| `fixupn` | commit fixup | Create fixup commit (no verify) |
| `fixr` | fixup + rebase | Create fixup and auto-rebase |
| `squash` | commit squash | Create squash commit for given SHA |

### Log

| Alias | Command | Description |
|-------|---------|-------------|
| `lg` | log --graph | Pretty log with graph |
| `lost` | fsck | Find lost/dangling commits |
| `lostplus` | script | Extended lost commits finder |

### Push

| Alias | Command | Description |
|-------|---------|-------------|
| `pof` | push --force-with-lease | Safe force push to origin |
| `puf` | push -f | Force push (dangerous) |

### Rebase

| Alias | Command | Description |
|-------|---------|-------------|
| `rb` | `rebase` | Rebase |
| `ri` | `rebase -i --autosquash` | Interactive rebase with autosquash |
| `rim` | `rebase -i origin/master` | Interactive rebase on origin/master |
| `rba` | `rebase --abort` | Abort rebase |
| `rbc` | `rebase --continue` | Continue rebase |
| `rbskip` | `rebase --skip` | Skip current commit in rebase |

### Status

| Alias | Command | Description |
|-------|---------|-------------|
| `st` | `status` | Status |
| `stp` | script | Extended status with more info |

### Stash / Snapshot

| Alias | Command | Description |
|-------|---------|-------------|
| `snapshot` | stash + apply | Create named snapshot |
| `snapshots` | stash list | List all snapshots |

### WIP (Work in Progress)

| Alias | Command | Description |
|-------|---------|-------------|
| `wip` | add + commit | Quick WIP commit (no verify) |
| `unwip` | reset | Undo last WIP commit |

### Conflict Resolution

| Alias | Command | Description |
|-------|---------|-------------|
| `ours` | checkout --ours | Keep our version in conflict |
| `theirs` | checkout --theirs | Keep their version in conflict |

### Utils

| Alias | Command | Description |
|-------|---------|-------------|
| `recent-branches` | for-each-ref | List 5 most recent branches |
| `undo` | `reset --soft HEAD~1` | Undo last commit (keep changes) |
| `showfiles` | show --name-only | Show files changed in commit |
| `tree` | log --name-status | Show log with file changes |
| `cleanup` | git-delete-merged-branches | Delete merged branches |

### Ignore (assume-unchanged)

| Alias | Command | Description |
|-------|---------|-------------|
| `ignore` | update-index | Stop tracking file changes |
| `unignore` | update-index | Resume tracking file changes |
| `ignored` | ls-files | List ignored files |

### Diff

| Alias | Command | Description |
|-------|---------|-------------|
| `ds` | `diff --staged` | Show staged changes |
| `dom` | `diff origin/master` | Diff against origin/master |
| `dn` | `diff --name-only` | Show only changed file names |
| `dstat` | `diff --stat` | Show diff statistics |

### Log Extras

| Alias | Command | Description |
|-------|---------|-------------|
| `last` | `log -1 HEAD --stat` | Show last commit with stats |
| `lf` | `log -1 --name-only` | Show files from last commit |
| `graph` | `log --graph --oneline --all` | Visual graph of all branches |
| `ll` | `log --oneline -20` | Quick log (20 commits) |

### Commit Extras

| Alias | Command | Description |
|-------|---------|-------------|
| `cam` | `commit -am` | Add all + commit with message |
| `empty` | `commit --allow-empty -m` | Empty commit (useful for CI triggers) |

### Switch (Git 2.23+)

| Alias | Command | Description |
|-------|---------|-------------|
| `sw` | `switch` | Switch branches |
| `swc` | `switch -c` | Create and switch to branch |

### Restore (Git 2.23+)

| Alias | Command | Description |
|-------|---------|-------------|
| `rs` | `restore` | Restore working tree files |
| `rss` | `restore --staged` | Unstage files |

### Pull

| Alias | Command | Description |
|-------|---------|-------------|
| `pl` | `pull` | Pull changes |
| `plr` | `pull --rebase` | Pull with rebase |

### Branch Extras

| Alias | Command | Description |
|-------|---------|-------------|
| `bclean` | branch --merged | Delete all merged branches |
| `btrack` | `branch -vv` | Show branches with tracking info |
| `current` | rev-parse | Show current branch name |

### Sync / Update

| Alias | Command | Description |
|-------|---------|-------------|
| `up` | `fetch --all --prune` | Fetch all remotes + prune |
| `sync` | fetch + rebase | Fetch origin and rebase on master |

### Remote

| Alias | Command | Description |
|-------|---------|-------------|
| `rv` | `remote -v` | List remotes with URLs |
| `url` | remote get-url | Show origin URL |

### Rebase Extras

| Alias | Command | Description |
|-------|---------|-------------|
| `ril` | rebase -i HEAD~N | Interactive rebase last N commits (`git ril 3`) |
| `continue` | add + rebase --continue | Stage all and continue rebase |

### Workflow

| Alias | Command | Description |
|-------|---------|-------------|
| `cowip` | add + wip + checkout | Save WIP and checkout branch (`git cowip feature-x`) |
| `back` | checkout - + unwip | Return to previous branch and restore WIP |

### Cherry-pick

| Alias | Command | Description |
|-------|---------|-------------|
| `cp` | `cherry-pick` | Cherry-pick commit |
| `cpa` | `cherry-pick --abort` | Abort cherry-pick |
| `cpc` | `cherry-pick --continue` | Continue cherry-pick |

### Utils Extras

| Alias | Command | Description |
|-------|---------|-------------|
| `contributors` | shortlog -sn | List contributors by commits |
| `root` | rev-parse | Show repo root directory |
| `count` | rev-list --count | Count total commits |
| `today` | log --since=midnight | Show today's commits |
| `aliases` | config --get-regexp | List all git aliases |

### Incoming / Outgoing

| Alias | Command | Description |
|-------|---------|-------------|
| `in` | `log ..@{u}` | Show incoming commits from remote |
| `out` | `log @{u}..` | Show outgoing commits to remote |

### Branch Cleanup

| Alias | Command | Description |
|-------|---------|-------------|
| `rmbranch` | branch -d + push --delete | Delete branch locally AND on remote |

### Switch Extras

| Alias | Command | Description |
|-------|---------|-------------|
| `swm` | switch to default | Switch to main/master (auto-detect) |

### Stash Extras

| Alias | Command | Description |
|-------|---------|-------------|
| `staa` | stash apply + drop | Apply and remove stash |
| `stashall` | stash --include-untracked | Stash all including new files |

### Nuclear

| Alias | Command | Description |
|-------|---------|-------------|
| `nope` | reset --hard + clean | Discard ALL changes (careful!) |

## Configuration

The git configuration is split into:

- `.gitconfig` - Main configuration
- `.gitaliases` - All aliases (included by .gitconfig)
- `.gitconfig.local` - Personal settings (user, signing keys)

### User Configuration

User email and name are configured during `./bootstrap install` and stored in `~/.gitconfig.local`.
