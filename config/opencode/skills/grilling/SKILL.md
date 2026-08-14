---
name: grilling
description: Grill the user relentlessly about a plan or design. Use when the user wants to stress-test a plan before building, or uses any 'grill' trigger phrases.
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Map the design tree: every decision branches into the decisions that depend on it.

Work in **rounds**. The **frontier** is every decision whose prerequisites are settled — the questions you can ask now without guessing at answers you have not heard yet. Ask the whole frontier in one round, number each question, and provide your recommended answer for each. Then wait for my answers before continuing.

Format each question like this:

```text
❓ **Q1** - **<question title>**: <question body, including choices when useful>

➡️ <your recommended answer>
```

When answers arrive, record the decisions, recompute the frontier, and ask the next round. A question whose answer depends on another question still open in the current round belongs in a later round.

If a *fact* can be found by exploring the environment, look it up rather than asking me. Dispatch a sub-agent for those lookups and do not block independent frontier questions while it runs. The *decisions*, though, are mine — put each one to me and wait for my answer.

The session is complete when the frontier is empty: every branch of the design tree has been visited and nothing remains silently assumed. Do not enact the plan until I confirm we have reached a shared understanding.
