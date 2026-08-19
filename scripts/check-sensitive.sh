#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pattern='(/Users/|/private/|sender_open_id|open_id|身份证号|手机号|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|api[_ -]?key[[:space:]]*[:=]|secret[[:space:]]*[:=]|token[[:space:]]*[:=]|cookie[[:space:]]*[:=])'

if command -v rg >/dev/null 2>&1; then
  if rg -n -i "$pattern" "$repo_root" --glob '!.git/**' --glob '!scripts/check-sensitive.sh'; then
    echo "Potential sensitive content found. Review before publishing." >&2
    exit 1
  fi
else
  if grep -R -n -E -i "$pattern" "$repo_root" --exclude-dir=.git --exclude=check-sensitive.sh; then
    echo "Potential sensitive content found. Review before publishing." >&2
    exit 1
  fi
fi

echo "Sensitive-content scan passed."

