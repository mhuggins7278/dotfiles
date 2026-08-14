---
description: Review changes independently against repository standards and the originating specification
agent: review
---

Review the change identified by $ARGUMENTS, defaulting to current staged and
unstaged work. Establish a fixed comparison point when reviewing a branch or
PR, and identify the originating specification only from supplied context or a
clear nearby reference.

Present Standards and Spec findings as independent axes so success in one
cannot mask failure in the other. Do not edit files or alter Git state. Keep
the review local unless the user explicitly requests submission in this
session.
