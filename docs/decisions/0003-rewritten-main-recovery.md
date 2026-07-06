# 0003 — Recovering from the 2026-07-04 rewritten `main`

_Moved from README 2026-07-06; a one-time event, not normal practice._

`main`'s history was rewritten once (2026-07-04) to add commit signatures
retroactively — content is identical, but every commit hash after
`bbc2595` changed. If your local clone or fork still has the old history,
`git pull` will refuse or produce a mess. If you have no local work on
`main`, the simplest fix is to reset to match the remote:

```sh
git fetch origin
git checkout main
git reset --hard origin/main
```

If you have unpushed commits on top of the old `main`, rebase them onto
the new history instead of resetting (which would drop them):

```sh
git fetch origin
git rebase --onto origin/main <old-main-tip> <your-branch>
```

This shouldn't happen again — it was a one-time cleanup, not a normal
practice for this repo.
