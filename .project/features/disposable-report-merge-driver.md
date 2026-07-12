---
slug: disposable-report-merge-driver
status: tasked
logged: 2026-07-11
plan: plan-disposable-report-merge-driver-2026-07-12-c310.md
tasks: tasks-disposable-report-merge-driver-7dbf.md
---

The disposable-report rule for single-writer files (STATUS.md, DEFECTS.md, SYNC.md, critique.md) is mechanized as a git merge driver — .gitattributes marks those paths merge=ours with the driver enabled per clone alongside core.hooksPath — so parallel work-branch merges never conflict on generated reports.
Why: take-either-side-never-reconcile is currently prose an LLM must remember mid-conflict; a merge driver is git's own idiom for exactly this (Principles II and VIII), and it is what makes auto-merging parallel delegated runs safe. Decide source-vs-target side: targets need it too, so install.sh likely ships/wires it.
