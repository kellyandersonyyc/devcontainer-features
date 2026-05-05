#!/usr/bin/env bash
set -euo pipefail

npm install -g @anthropic-ai/claude-code @openai/codex happy

cat > /usr/local/bin/ai-tools-fix-permissions <<'EOF'
#!/usr/bin/env bash
set -e
find /home/node/.claude /home/node/.codex /home/node/.happy \
  \( -path /home/node/.claude/skills -o -path /home/node/.codex/skills \) -prune \
  -o -exec chown -h node:node {} +
EOF
chmod +x /usr/local/bin/ai-tools-fix-permissions
