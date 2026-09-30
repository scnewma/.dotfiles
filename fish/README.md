# fish

## Machine-local config

Put machine-specific settings in `~/.config/fish/config.fish.local`. Git ignores this file.

### `PI_ENABLED_MODELS`

The `pi` function passes these models to `pi --models` for startup selection and Ctrl+P cycling. `config.fish` sets the default OpenAI models. Append machine-specific models:

```fish
set -gxa PI_ENABLED_MODELS claude-opus-5 claude-sonnet-5
```

Do not set `enabledModels` in `~/.pi/agent/settings.json`.
