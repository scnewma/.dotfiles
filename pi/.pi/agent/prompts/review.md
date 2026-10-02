---
description: Run independent code-review and ponytail-review passes through reviewer
argument-hint: "[low|medium|high|xhigh|max] [target]"
---

Delegate this review to the `reviewer` agent. Do not review anything yourself.

Review args: `${@:-<none, review the current diff>}`

Enable the subagent tool if needed, then call `subagent({action:"list",capabilities:true})` to confirm `reviewer` is executable. Launch it with the current cwd, `context:"fresh"`, and `async:true`. Include the review args in its task and explicitly authorize its two independent delegate reviews.

Wait for its final result, then return the reviewer's report verbatim without additional commentary. If the reviewer fails, report the error; do not retry or review the change yourself.
