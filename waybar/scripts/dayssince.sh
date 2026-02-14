#!/usr/bin/env bash
set -euo pipefail

# Hard-coded start date (local time)
START_DATE="2026-01-20"

start_epoch=$(date -d "${START_DATE} 20:00:00" +%s)
now_epoch=$(date +%s)

diff=$((now_epoch - start_epoch))
days=$(awk "BEGIN {printf \"%.1f\", $diff / 86400}")

# Waybar JSON output (lets you set tooltip, class, etc.)
printf '{"text":"%s","tooltip":"Days since %s at 8 PM","class":"days-since"}\n' "$days" "$START_DATE"
