# fish

## Machine-local config

Put machine-specific settings in `~/.config/fish/config.fish.local`. Git ignores this file.

### `PI_ENABLED_MODELS`

The `pi` function passes these models to `pi --models` for startup selection and Ctrl+P cycling. `config.fish` sets the default OpenAI models. Append machine-specific models:

```fish
set -gxa PI_ENABLED_MODELS claude-opus-5 claude-sonnet-5
```

Do not set `enabledModels` in `~/.pi/agent/settings.json`.

### `PI_OPENAI_MCP_CONFIG`

Required by the `astra`, `sol`, `terra`, and `luna` abbreviations. They exit with an error when the file is missing.

Set the path to an MCP config file for OpenAI Pi sessions:

```fish
set -gx PI_OPENAI_MCP_CONFIG $HOME/.local/share/pi/mcp-openai.json
```

Pi loads this file with `--mcp-config` in place of `~/.pi/agent/mcp.json`. `~/.config/mcp/mcp.json` still loads first. Disable any shared server by name:

```json
{
  "mcpServers": {
    "linear": { "disabled": true }
  }
}
```

To add a server that only OpenAI sessions get, give its full definition:

```json
{
  "mcpServers": {
    "supabase": { "url": "https://mcp.supabase.com/mcp" }
  }
}
```

Copy any adapter `settings` you need from `~/.pi/agent/mcp.json`, because the replaced file's settings do not load.
