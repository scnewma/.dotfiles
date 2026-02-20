---
name: go
description: Go language conventions, patterns, and tooling. This skill should be used when working with Go source files (.go), go.mod, or building Go CLI programs.
---

# Go

## Tooling

- Formatter: `gofmt`
- Linter: `go vet`

## Style

- Use `any` instead of `interface{}`.
- Prefer Go 1.18+ stdlib helpers over manual loops:
  - `maps.Copy`, `maps.Clone`, `maps.Keys`, `maps.Values` instead of manual map iteration.
  - `slices.Contains`, `slices.Sort`, `slices.Clone`, `slices.Concat` instead of hand-rolled equivalents.
  - `min()` / `max()` builtins (Go 1.21+) instead of custom helpers.
  - `cmp.Or` (Go 1.22+) for first-non-zero-value selection.

## Logging

Use Go's `slog` package for structured logging. Do not use `log` for application logging.

## CLI Patterns

### Simple commands

For simple single-purpose tools without subcommands, use a minimal `main()` that delegates to `run()`:

```go
package main

import (
	"log"
	"os"
)

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
	os.Exit(0)
}

func run() error {
	// actual program logic here
	return nil
}
```

Add arguments to `run()` (like `context.Context`) only when actually needed.

### CLI applications

For programs with subcommands, flags, or any non-trivial CLI interface, use [cobra](https://github.com/spf13/cobra).
