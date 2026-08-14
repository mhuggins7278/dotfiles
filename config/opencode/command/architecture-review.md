---
description: Find high-value opportunities to deepen a codebase's modules
agent: build
---

Audit the current codebase for architectural friction, using $ARGUMENTS as an
optional focus. Read relevant domain terminology and ADRs, then inspect places
where understanding or changing one behavior requires crossing many shallow
interfaces.

Use the `codebase-design` vocabulary where it clarifies the analysis, but do
not force every observation into that model. Delegate exploration only when
the repository is large enough to benefit.

Create a self-contained visual HTML report in the OS temporary directory with
three to five concrete candidates. For each, show the affected files, current
friction, a plausible direction, realistic benefits, risks, and recommendation
strength. End with the best first move. Do not modify the repository or begin
the refactor; ask which candidate the user wants to explore.
