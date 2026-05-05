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

for dir in /home/node/.claude /home/node/.codex /home/node/.happy; do
  [ -d "\$dir" ] || continue
  find "\$dir" \\( -path "\$dir/skills" \\) -prune \\
    -o -exec chown -h "\$USER_NAME:\$USER_NAME" {} + 2>/dev/null || true
done

if [ -d "\$USER_HOME" ] && [ "\$USER_HOME" != "/home/node" ]; then
  for name in .claude .codex .happy; do
    if [ -d "/home/node/\$name" ] && [ ! -e "\$USER_HOME/\$name" ]; then
      ln -s "/home/node/\$name" "\$USER_HOME/\$name"
      chown -h "\$USER_NAME:\$USER_NAME" "\$USER_HOME/\$name" 2>/dev/null || true
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
