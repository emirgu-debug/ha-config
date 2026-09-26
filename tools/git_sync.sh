#!/bin/sh
# Commit + push /config changes to GitHub. $1 = optional commit message.
cd "$(dirname "$0")/.." || exit 1
MSG="${1:-Auto sync}"
git add -A
if git diff --cached --quiet; then echo "no changes"; exit 0; fi
# refuse secrets and files > 20 MB
if git diff --cached --name-only | grep -Eq '(^|/)secrets\.yaml$|^\.storage/(auth|core\.config_entries)|\.git-credentials|\.(pem|key)$'; then
  git reset -q; echo "ABORT: secret-looking file staged"; exit 2; fi
BIG=$(git diff --cached --name-only --diff-filter=AM -z | xargs -0 -r du -k 2>/dev/null | awk '$1>20480{print $2}')
if [ -n "$BIG" ]; then git reset -q; echo "ABORT: >20MB: $BIG"; exit 2; fi
git -c user.name="Home Assistant" -c user.email="ha@homeassistant.local" \
    commit -q -m "$MSG ($(date '+%Y-%m-%d %H:%M'))"
git push -q origin main 2>&1 && echo "pushed"
