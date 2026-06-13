
# AI CLI tools (ai-tools)

Installs Claude Code, OpenAI Codex, and Happy globally. Mounts persistent config volumes for each tool and bind-mounts a shared agent bundle (skills, subagents, lib) from the host: the full bundle at ~/.agents, with skills and subagents also surfaced into each tool's config dir (~/.claude, ~/.codex). Skills reference shared resources via ~/.agents/lib. Persists ~/.claude.json (onboarding state, project trust, MCP config) by symlinking into the .claude volume.

## Example Usage

```json
"features": {
    "ghcr.io/kellyandersonyyc/devcontainer-features/ai-tools:1": {}
}
```





---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/kellyandersonyyc/devcontainer-features/blob/main/src/ai-tools/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
