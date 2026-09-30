---
name: mermaid-diagrams
description: Author Mermaid diagrams for GitHub markdown (PR descriptions, READMEs, docs) that are accurate and readable in both light and dark themes. Use when asked to add a diagram, visual aid, flowchart, sequence diagram, or state diagram to docs or a PR.
---

# Mermaid diagrams

## 1. Scope comes from the request

Decide what the diagram must show before drawing.

- **"End-to-end flow" / "how X calls Y"** across components: `sequenceDiagram`, happy path only. Failure branches, retries, and flag checks go in prose. A branch that's a normal outcome (eligible vs ineligible, found vs not found) is not a failure: show it with `alt`. A periodic/background flow (cron, sweeper) gets its own block at the end.
- **"How it decides", "what happens on each failure", "logic", "branches", "lifecycle", a protocol spec**: the branches ARE the subject. Every branch in the source goes in the diagram, not the prose. `flowchart` for decisions, `stateDiagram-v2` for states.
- **"How X gets routed/dispatched/built"** (a general mechanism): draw the rule itself (the switch, the prefix order, the lookup table) as a flowchart. One example traced through a sequence diagram doesn't answer it; add the example as a second diagram if useful.
- If the user names a scope ("from the handler down to rsync"), don't draw past it.

Prose may summarize the diagram; it must never hold a branch, transition, or error path the request asked for. This applies to every diagram you draw, including secondary ones (a retry/sweep diagram gets its branches too, not one summary diamond).

Relevance cuts the other way: include a branch when it changes the answer to the question. Don't expand guards inside helper functions (e.g. "is the list empty?" inside `queueChainedTasks`) unless they change the outcome; label them as the helper's behavior, not the caller's decision.

## 2. Every arrow is a claim, check each one

Trace every hop in the source, including sibling repos. Docs are a lead, not proof. Then check the timing:

- **Concurrent work** (a 202 then polling, a user acting while a client polls): draw the poll starting right after the 202, or use `par`. Never draw polling after the work it's polling.
- **Phase blocks**: before putting a step in a block named for a condition ("postgres down", "offline"), confirm the condition is true at that step.
- **Literals are exact**: endpoint paths, CLI flags, state names, protocol values (`urn:ietf:params:oauth:grant-type:device_code`, not `device_code`). Shorten the prose around a literal, never the literal.

Finish by walking the source top to bottom and ticking off each call/branch/transition in the diagram. Anything in scope and missing is a bug. When failures are in scope, every awaited call that can throw (AWS, DB, HTTP, timeouts) is a failure edge, not just explicit `throw`s; retry paths must loop back to what they retry. If that's too much for one diagram, split into an overview plus one diagram per phase rather than dropping edges.

## 3. Readable shapes

- Sequence diagrams: at most ~6 participants; beyond that GitHub scales the text down until it's unreadable. Merge minor ones (e.g. `pg-meta` into `Project DB`) and say so in a label.

- Flowchart: diamonds `{}` only for real decisions; actions are rectangles. Label decision edges (`-->|yes|`).
- Keep one exit node per outcome (e.g. one `failRun → failed` node) instead of many crossing edges.
- Transitions from *any* state (abort, retry-from-anywhere): one note or a single edge from a labeled "any open state" node. Don't draw an edge from every state, and don't draw edges to/from a composite state box; both turn the render into a tangle.
- Sequence `alt` for a failure must end the flow inside the branch (a final return/`Note: exits`), and conditional steps (cleanup on error) go inside the `alt`/`opt` they depend on, never after it.
- Sequence: `rect` + `Note over A,Z: 1. STEP` for phases, `loop`, `alt`/`else`, `opt` for a guard with no else. Skip `autonumber`; its circles cover self-message labels.
- Legibility beats exhaustiveness in a single render: if the diagram is tangled after you look at it, split it rather than accept crossing edges through labels.
- Escape `<` / `>` as `&lt;` / `&gt;`; line breaks `<br/>`; quote flowchart labels containing `()[]{}:/`.

## 4. Theme-safe colors

GitHub renders with light or dark theme per viewer. Text color flips; hardcoded backgrounds don't.

- **Never** opaque light fills (`rect rgb(235,245,255)`, `style x fill:#d4edda`, `classDef ... fill:#f8d7da,color:#000`). They glare or go unreadable in dark mode.
- Use translucent tints: `rgba(66,135,245,0.15)` blue, `rgba(46,160,67,0.15)` green, `rgba(210,153,34,0.15)` amber, `rgba(137,87,229,0.15)` purple, `rgba(128,128,128,0.15)` gray, `rgba(248,81,73,0.15)` red. For flowchart nodes: `classDef err fill:rgba(248,81,73,0.15),stroke:#f85149` with no `color:`.
- Never set `theme` in `%%{init}%%` (`base`, `default`, `forest`...); pinning a theme breaks the other mode. Never set text colors (`textColor`, `signalTextColor`, `color:`).
- **Brand color requested**: make it visibly dominant using color-only `themeVariables` with no `theme` key, strokes solid and fills translucent:
  ```
  %%{init: {'themeVariables': {'actorBorder':'#3ECF8E','actorBkg':'rgba(62,207,142,0.2)','actorLineColor':'#3ECF8E','signalColor':'#3ECF8E','noteBkgColor':'rgba(62,207,142,0.2)','noteBorderColor':'#3ECF8E','labelBoxBkgColor':'rgba(62,207,142,0.2)','labelBoxBorderColor':'#3ECF8E'}}}%%
  ```
  plus `rect rgba(62,207,142,0.15)` phases. Flowchart: `classDef brand fill:rgba(62,207,142,0.2),stroke:#3ECF8E,stroke-width:2px` on every node and `linkStyle default stroke:#3ECF8E`.

## 5. Test in both themes

```sh
bunx -p @mermaid-js/mermaid-cli mmdc -i d.mmd -o light.png -b white
bunx -p @mermaid-js/mermaid-cli mmdc -i d.mmd -o dark.png -t dark -b '#0d1117'
```

Open both PNGs as images and check every label is legible in both, nothing overlaps, and arrows read in the real order. A clean parse is not a pass. Delete scratch renders and `.mmd` files; the deliverable is the markdown.

## 6. Placement

Prefer the doc that already explains the flow (a `## Flow diagram` section) and link it from the PR description. If asked for PR-body only, put it there, and keep it a compact overview a reviewer can scan in one screen (~15 messages or nodes); exhaustive detail belongs in a doc, not the PR body.
