#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
codex_home="${CODEX_HOME:-$HOME/.codex}"
agents_file="$codex_home/AGENTS.md"
index_file="$repo_root/knowledge/INDEX.md"

mkdir -p "$codex_home"

python3 - "$agents_file" "$index_file" <<'PY'
from pathlib import Path
import shutil
import sys

agents_file = Path(sys.argv[1])
index_file = Path(sys.argv[2]).resolve()
start = "<!-- codex-shared-knowledge:start -->"
end = "<!-- codex-shared-knowledge:end -->"

existing = agents_file.read_text(encoding="utf-8") if agents_file.exists() else ""
backup_file = agents_file.with_name("AGENTS.pre-shared-knowledge.md")
if agents_file.exists() and not backup_file.exists():
    shutil.copy2(agents_file, backup_file)

if start in existing and end in existing:
    before, rest = existing.split(start, 1)
    _, after = rest.split(end, 1)
    existing = (before.rstrip() + "\n" + after.lstrip()).strip()

block = f"""{start}
# Shared Codex knowledge

Shared knowledge index: `{index_file}`

- For non-trivial tasks that may benefit from prior methods, read the index first.
- Select only the 1–3 most relevant topic or project pages.
- Apply knowledge as constraints, checklists, risk gates, and acceptance criteria.
- Current task instructions take priority. External claims retain their evidence boundaries.
- A recorded Skill may be called only when it is actually available in the current environment.
{end}"""

output = (existing + "\n\n" + block).strip() + "\n"
agents_file.write_text(output, encoding="utf-8")
print(f"Installed shared knowledge entry in {agents_file}")
print(f"Index: {index_file}")
PY
