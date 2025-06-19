# Include Config

Includes extra configuration files from outside sources for setting up your machine.

## Usage

```bash
deno run -A main.ts
```

## Configuration

All downloads are defined in `config.yaml`. Each item in the YAML array supports the following properties:

- `path`: The relative path from `$HOME` where the file/directory should be placed
- `url`: The remote URL to download from
- `extract` (optional): Boolean flag to extract archives. When `true`, the `path` is treated as a directory to extract to. When `false` or omitted, the `path` is treated as a file destination.
- `strip_components` (optional): Number of leading directory components to strip from extracted files. Only used when `extract: true`.

### Examples

Download a single file:
```yaml
- path: .local/share/scripts/script.sh
  url: https://example.com/script.sh
```

Download and extract an archive:
```yaml
- path: .local/share/extracted-content
  url: https://example.com/archive.zip
  extract: true
```

Download and extract an archive with directory stripping:
```yaml
- path: .local/share/my-repo
  url: https://github.com/user/repo/archive/main.zip
  extract: true
  strip_components: 1  # Removes the top-level directory (e.g., "repo-main/")
```

### Supported Archive Formats

When `extract: true` is specified, the following archive formats are supported:
- `.zip`
- `.tar`
- `.tar.gz`
- `.tgz`
