# Syncing the feature register with an issue tracker

`/ardd-tracker` mirrors `.project/features/` to and from an external issue
tracker — GitHub Issues today. Use it when stakeholders live in the
tracker and the register would otherwise drift out of their view.

## The ownership rule

The **register owns what a feature is** (name, slug, description — design
intent). The **tracker owns how it's going** (issue state, labels,
discussion — execution visibility). Every field syncs in exactly one
direction, which is why sync conflicts can't occur:

- A description edited in the register later does **not** propagate to
  the issue — deliberate, not a gap.
- An issue closed by hand does **not** flip the register — it's *reported*
  as divergence in `TRACKER.md`, never applied. Status transitions belong
  to the lifecycle skills (`/ardd-plan`, `/ardd-implement`).

## Day-to-day flow

```
/ardd-tracker           # push then pull
/ardd-tracker push      # register → issues: create missing, advance labels, close implemented
/ardd-tracker pull      # issues → register: import ardd-import-labeled issues; report divergence
```

Feature status maps to labels: `ardd:backlogged` / `ardd:planned` /
`ardd:tasked`; `implemented` has no label — a closed issue *is* the
implemented state.

**Intake from stakeholders**: anyone can file an issue and label it
`ardd-import`; the next pull creates a `backlogged` register entry from it
and swaps the issue's label from `ardd-import` to `ardd:backlogged` so it
isn't re-imported. The label is applied by humans, never inferred — a
stray bug report never becomes a feature idea.

**Divergence** lands in `.project/TRACKER.md` (full overwrite each run,
explicit all-clear when clean). You reconcile manually or via
`/ardd-feedback`.

## Running it unattended

Push is crash-retry idempotent (a persistent slug marker in each issue
body is exact-matched before any create), so it's safe on a schedule.
A GitHub Actions workflow — hourly, plus prompt pickup of newly labeled
imports:

```yaml
on:
  schedule:
    - cron: "0 * * * *"
  issues:
    types: [labeled]
jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: claude -p "/ardd-tracker"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Known limitation: two *genuinely simultaneous* pushes can both create an
issue for the same slug (GitHub's search index lags creation by seconds).
Fine for anything run hourly or less often.

## Reference

Full mechanics — prerequisites, the marker scheme, the decision scripts —
on the [/ardd-tracker reference page](../reference/skills/ardd-tracker.md).
