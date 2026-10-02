# fish

## Machine-local config

Put machine-specific settings in `~/.config/fish/config.fish.local`. Git ignores this file.

### Pi

Use `sol`, `luna`, `astra`, `terra`, `opus`, `sonnet`, or `fable` to launch the corresponding model. Bare `pi` defaults to Sol.

Configure subagent roles under `subagents.agentOverridesByProvider`; mappings follow the current parent provider, including model switches inside Pi.
