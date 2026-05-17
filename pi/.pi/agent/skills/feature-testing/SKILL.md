---
name: feature-testing
description: |
  Guidance for designing, writing, reviewing, or refactoring tests in this
  project. Use when adding tests for features or bugs, deciding unit vs
  integration boundaries, choosing what to mock, improving test structure,
  or reducing brittle/slow/flaky tests.
---

# Feature Testing

Use this skill when working on tests. Prefer tests that validate user-visible
features and durable behavior rather than implementation details.

This guidance is based on:

- https://matklad.github.io/2021/05/31/how-to-test.html
- https://matklad.github.io/2022/07/04/unit-and-integration-tests.html

## Core Principles

- Test features, not code. A good test should remain useful if the internal
  implementation is rewritten.
- Prefer data-driven tests: inputs and expected outputs should be explicit
  data, with one or a few shared `check`/`renderAndCheck`/`setup` helpers that
  adapt to internal API changes.
- Optimize for low friction. Adding a regression case should usually mean
  adding one small input/expected pair, not duplicating setup and assertions.
- Optimize purity before extent. Fast, deterministic tests avoid disk, network,
  real timers, subprocesses, and environment-sensitive behavior. Exercising a
  lot of application code is fine if the test remains pure and fast.
- Let tests have their natural extent. Do not mock project code merely to make
  a test look smaller. Mock or fake impure boundaries instead.
- Keep tests refactor-friendly. Tests should constrain behavior, not function
  signatures, component internals, hook call order, CSS implementation details,
  or transient DOM structure unless those are the behavior.

## Mental Model: Purity And Extent

Avoid arguing about whether something is a "unit" or "integration" test.
Classify tests using two axes:

- **Purity**: how much generalized IO the test performs. Pure tests are local,
  deterministic, single-process, and independent of clocks, network, disk, and
  real browser/OS state. Purity strongly affects speed and flakiness.
- **Extent**: how much production code the test exercises. High extent is not
  bad. A test can exercise most of the app and still be excellent if it is pure,
  deterministic, and feature-focused.

Prescriptions:

- Ruthlessly improve purity: replace network with fake API data, real timers
  with controlled timers, disk with in-memory data, and subprocesses with seams.
- Do not artificially reduce extent by mocking internal modules unless there is
  a specific reason, such as isolating an impure boundary or avoiding an
  extremely expensive dependency.

## What To Test

Prefer tests for:

- User-observable behavior: rendered content, state transitions, command
  effects, events emitted, errors shown, persisted data shape, accessibility
  affordances, and public API results.
- Feature scenarios and regressions: especially bugs that escaped before.
- Edge cases at feature boundaries: empty input, invalid input, missing data,
  duplicate data, permission errors, cancellation, cleanup, and race-sensitive
  lifecycle behavior.
- Data transformations and reducers as value-in/value-out checks.
- Integration between layers when it can be tested purely and quickly.
- Slow or impure behavior only when necessary, clearly separated from the fast
  default test suite.

## What Not To Test

Avoid tests that primarily assert:

- Private helper functions just because they exist.
- Exact internal component structure, hook usage, class names, or implementation
  details that users cannot observe.
- Third-party library behavior.
- Mock call sequences for project-internal functions when the final behavior is
  easier and more meaningful to assert.
- Snapshots of large, noisy trees unless they are intentionally curated and
  reviewed as feature output.
- Behavior that is already covered at a better feature boundary.

## Test Structure

Use a small number of helpers per feature area.

```ts
function check(input: InputCase, expected: ExpectedResult) {
  const actual = runFeature(input);
  expect(actual).toEqual(expected);
}

it("handles empty input", () => {
  check({ items: [] }, { visibleItems: [], message: "No items" });
});
```

For React/Vitest tests, prefer helpers that express feature setup and expected
behavior:

```ts
function renderFeature(overrides: Partial<Props> = {}) {
  const props = { ...defaultProps, ...overrides }
  render(<Feature {...props} />)
  return { props, user: userEvent.setup() }
}
```

Guidelines:

- Put repetitive arrange/act/assert plumbing in helpers.
- Keep each test case concise and named by behavior.
- Make expected output readable and local to the case.
- Add custom assertion messages only when they improve debugging.
- If outputs are complex, consider curated inline expectations or focused
  assertions over broad snapshots.
- If cases become numerous, table-drive them, but keep failure output clear.

## Mocks, Fakes, And Boundaries

- Mock impure boundaries: network, Tauri commands/events, filesystem, time,
  randomness, OS APIs, and subprocesses.
- Prefer realistic fakes with explicit data over mocks that assert internal call
  choreography.
- Avoid mocking this project’s own pure logic just to isolate a component.
- If testing cache hits, skipped work, or other invisible behavior, add explicit
  observability such as logs, counters, status values, or debug output and
  assert that as part of the feature result.

## Slow And Flaky Tests

- Keep the default local suite fast and deterministic.
- Mark or gate genuinely slow tests so they can run in CI or on demand.
- Do not hide slow tests with conditional compilation or by making them hard to
  discover.
- Avoid sleeps and real-time waiting. Use controlled timers, awaited events, or
  explicit completion handles.
- Concurrent/background APIs should expose a way for tests to wait for cleanup
  and completion. Background work that outlives its test is a design smell.

## When Adding A Test

Before writing the test, ask:

1. What feature behavior or regression should this protect?
2. What is the most user-facing or durable boundary where it can be asserted?
3. Can the test be pure: no real network, disk, timers, subprocesses, or global
   environment dependence?
4. Can setup and assertions reuse or improve an existing `check`/render helper?
5. Would this test still be valuable after an internal rewrite?

If the answer to #5 is no, move the assertion outward or rewrite it in terms of
observable behavior.

## Reviewing Tests

When reviewing or editing tests, look for:

- Brittle coupling to implementation details.
- Excessive mocks of project-internal code.
- Repeated setup that should become a helper.
- Slow/impure operations in the default test path.
- Missing regression coverage for the actual bug or feature.
- Assertions that are too broad to diagnose or too narrow to matter.
- Tests that force many edits during harmless refactors.
