#!/usr/bin/env bash
set -euo pipefail

# Hard-coded start date (local time)
START_DATE="2026-01-20"

start_epoch=$(date -d "${START_DATE} 00:00:00" +%s)
now_epoch=$(date +%s)

diff=$((now_epoch - start_epoch))
days=$((diff / 86400))

# If you want "0" for dates before the start, uncomment:
# if (( days < 0 )); then days=0; fi

# Waybar JSON output (lets you set tooltip, class, etc.)
printf '{"text":"%d","tooltip":"Days since %s","class":"days-since"}\n' "$days" "$START_DATE"
