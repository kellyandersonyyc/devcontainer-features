#!/usr/bin/env bash
set -euo pipefail

npm install -g @anthropic-ai/claude-code @openai/codex happy

TARGET_USER="${_REMOTE_USER:-${USERNAME:-node}}"
TARGET_HOME="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6)"
TARGET_HOME="${TARGET_HOME:-/home/$TARGET_USER}"

mkdir -p /usr/local/share/ai-tools
cat > /usr/local/share/ai-tools/entrypoint.sh <<EOF
#!/usr/bin/env bash
set -e

USER_NAME="$TARGET_USER"
USER_HOME="$TARGET_HOME"
VOLUME_DIR="/home/node/.claude"

for dir in /home/node/.claude /home/node/.codex /home/node/.happy; do
  [ -d "\$dir" ] || continue
  find "\$dir" \\( -path "\$dir/skills" -o -path "\$dir/agents" \\) -prune \\
    -o -exec chown -h "\$USER_NAME:" {} + 2>/dev/null || true
done

PERSISTED_HOME_DIR="\$VOLUME_DIR/_persisted"
mkdir -p "\$PERSISTED_HOME_DIR"
PERSISTED_CLAUDE_JSON="\$PERSISTED_HOME_DIR/.claude.json"
LIVE_CLAUDE_JSON="\$USER_HOME/.claude.json"

if [ ! -e "\$PERSISTED_CLAUDE_JSON" ]; then
  if [ -f "\$LIVE_CLAUDE_JSON" ] && [ ! -L "\$LIVE_CLAUDE_JSON" ]; then
    mv "\$LIVE_CLAUDE_JSON" "\$PERSISTED_CLAUDE_JSON"
  else
    echo '{}' > "\$PERSISTED_CLAUDE_JSON"
  fi
fi

if [ ! -L "\$LIVE_CLAUDE_JSON" ] || [ "\$(readlink "\$LIVE_CLAUDE_JSON")" != "\$PERSISTED_CLAUDE_JSON" ]; then
  rm -f "\$LIVE_CLAUDE_JSON"
  ln -s "\$PERSISTED_CLAUDE_JSON" "\$LIVE_CLAUDE_JSON"
fi

chmod 600 "\$PERSISTED_CLAUDE_JSON" 2>/dev/null || true
chown -h "\$USER_NAME:" "\$PERSISTED_CLAUDE_JSON" "\$LIVE_CLAUDE_JSON" "\$PERSISTED_HOME_DIR" 2>/dev/null || true

if [ -d "\$USER_HOME" ] && [ "\$USER_HOME" != "/home/node" ]; then
  for name in .claude .codex .happy .agents; do
    if [ -d "/home/node/\$name" ] && [ ! -e "\$USER_HOME/\$name" ]; then
      ln -s "/home/node/\$name" "\$USER_HOME/\$name"
      chown -h "\$USER_NAME:" "\$USER_HOME/\$name" 2>/dev/null || true
    fi
  done
fi

exec "\$@"
EOF
chmod +x /usr/local/share/ai-tools/entrypoint.sh

cat > /usr/local/bin/ai-tools-fix-permissions <<'EOF'
#!/usr/bin/env bash
exec /usr/local/share/ai-tools/entrypoint.sh true
EOF
chmod +x /usr/local/bin/ai-tools-fix-permissions
