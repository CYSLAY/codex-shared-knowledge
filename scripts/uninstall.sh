#!/usr/bin/env bash
set -euo pipefail

codex_home="${CODEX_HOME:-$HOME/.codex}"
agents_file="$codex_home/AGENTS.md"

python3 - "$agents_file" <<'PY'
from pathlib import Path
import shutil
import sys

agents_file = Path(sys.argv[1])
start = "<!-- codex-shared-knowledge:start -->"
end = "<!-- codex-shared-knowledge:end -->"

if not agents_file.exists():
    print("No AGENTS.md found; nothing to remove.")
    raise SystemExit(0)

existing = agents_file.read_text(encoding="utf-8")
if start not in existing or end not in existing:
    print("Managed shared-knowledge block not found; nothing to remove.")
    raise SystemExit(0)

backup_file = agents_file.with_name("AGENTS.before-shared-knowledge-uninstall.md")
if not backup_file.exists():
    shutil.copy2(agents_file, backup_file)
before, rest = existing.split(start, 1)
_, after = rest.split(end, 1)
output = (before.rstrip() + "\n\n" + after.lstrip()).strip()
agents_file.write_text((output + "\n") if output else "", encoding="utf-8")
print(f"Removed shared knowledge entry from {agents_file}")
PY
