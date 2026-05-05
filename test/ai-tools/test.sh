#!/usr/bin/env bash
set -e
source dev-container-features-test-lib

check "claude installed" command -v claude
check "codex installed" command -v codex
check "happy installed" command -v happy

reportResults
