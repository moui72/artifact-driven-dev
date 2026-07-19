---
slug: rejected-feature-status
status: backlogged
logged: 2026-07-19
---

Add a 'rejected' status to the feature register's status enum (backlogged/planned/tasked/implemented/retired) for a backlogged or planned idea the team decides not to pursue and that never gets built — a terminal state distinct from retired (shipped then deliberately removed).
Why: the register currently has no way to close out a feature that's decided against without either leaving it dangling at backlogged/planned forever or forcing it through a workaround status that doesn't really fit. A related, illustrative wrinkle from a consumer project: a feature whose scope ended up shipping under a *different* plan/feature entry (not removed, not independently built) also didn't fit 'retired' (which means shipped-then-removed) or cleanly fit 'implemented' either — that consumer worked around it by closing the entry as 'implemented', bound to the other plan/tasks files, with an explanatory note. 'rejected' addresses the decided-against-and-never-built case specifically; the shipped-under-a-different-entry case is a separate, distinct outcome (a 'subsumed' status, or similar) not solved by this same change — flagged here as a related gap worth a future look, not folded into this one.
