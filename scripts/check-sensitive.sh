#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pattern="(/Users/|/private/|sender_open_id|open_id|身份证号|手机号|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|(api[_ -]?key|secret|token|cookie)[[:space:]]*[:=][[:space:]]*[\"'][^\"']+|^[A-Z0-9_]*(API_KEY|SECRET|TOKEN|COOKIE)=.+)"

env_example="$repo_root/examples/feishu-content-inbox/.env.example"
cd "$repo_root"

if command -v rg >/dev/null 2>&1; then
  if rg -n -i "$pattern" . --glob '!.git/**' --glob '!scripts/check-sensitive.sh' --glob '!examples/feishu-content-inbox/.env.example'; then
    echo "Potential sensitive content found. Review before publishing." >&2
    exit 1
  fi
else
  if grep -R -n -E -i "$pattern" . --exclude-dir=.git --exclude=check-sensitive.sh --exclude=.env.example; then
    echo "Potential sensitive content found. Review before publishing." >&2
    exit 1
  fi
fi

if [[ -f "$env_example" ]]; then
  if grep -v -E '^(#.*|$|FEISHU_APP_ID=cli_xxx|FEISHU_APP_SECRET=replace_me|QUEUE_DIR=/absolute/path/to/knowledge/inbox/pending|ALLOWED_HOSTS=v\.douyin\.com,www\.douyin\.com)$' "$env_example" | grep -q .; then
    echo "The public .env.example contains an unexpected value." >&2
    exit 1
  fi
fi

echo "Sensitive-content scan passed."
