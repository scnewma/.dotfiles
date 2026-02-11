---
name: python
description: Python language conventions, patterns, and tooling. This skill should be used when working with Python source files (.py), pyproject.toml, or writing Python scripts.
---

# Python

## Tooling

- Formatter/linter: `ruff`
- Package manager: `uv`

## Inline Script Dependencies

For single-file scripts, use uv inline script dependencies instead of a separate requirements file:

```python
# /// script
# dependencies = ["requests", "rich"]
# ///
```
