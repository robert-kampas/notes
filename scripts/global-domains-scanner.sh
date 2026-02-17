#!/usr/bin/env bash
# Improved global domain scanner
# - variable prefix length before a fixed suffix (default "mail")
# - configurable TLD, concurrency, output file, WHOIS throttle, resume, verbose
# - exclude letters v, w, z from scanning (per user request)
# - allow -f suffix to be "1" (or any string)
# - DNS-first, WHOIS second; conservative defaults
# - atomic appends with flock when available
#
# Usage:
#   ./global.sh -n 3 -f mail -t com -c 20 -o results.txt -s 0.6 -v -r
#   ./global.sh -n 1 -f 1    # example: single-letter prefix + "1" suffix (e.g. a1.com)
#
# Options:
#   -t TLD (default: com)
#   -c concurrency (default: 10)
#   -o output file (default: global_domains.txt)
#   -s seconds to sleep between WHOIS calls per worker (default: 0.5)
#   -v verbose
#   -r resume (skip domains already present in output file)
#   -n prefix length (number of letters before the suffix; default: 2)
#   -f suffix to append after the prefix (default: mail). NOTE: can be "1"
#   -h help

set -uo pipefail

# defaults
TLD="com"
CONCURRENCY=10
OUTPUT_FILE="global_domains.txt"
SLEEP_BETWEEN_WHOIS=0.5
VERBOSE=0
RESUME=0
PREFIX_LEN=2
SUFFIX="mail"

usage() {
  cat <<EOF
Usage: $0 [-t tld] [-c concurrency] [-o output_file] [-s whois_sleep] [-v] [-r] [-n prefix_length] [-f suffix] [-h]
  -t TLD (without dot), default: com
  -c concurrency (background workers), default: 10
  -o output file, default: global_domains.txt
  -s sleep seconds between WHOIS calls in each worker, default: 0.5
  -v verbose
  -r resume (skip domains already listed in the output file)
  -n prefix length (number of letters before the suffix), default: 2
  -f suffix to append after the prefix, default: mail (can be "1")
EOF
  exit 1
}

# parse options
while getopts 't:c:o:s:vrn:f:h' opt; do
  case "$opt" in
    t) TLD="$OPTARG" ;;
    c) CONCURRENCY="$OPTARG" ;;
    o) OUTPUT_FILE="$OPTARG" ;;
    s) SLEEP_BETWEEN_WHOIS="$OPTARG" ;;
    v) VERBOSE=1 ;;
    r) RESUME=1 ;;
    n) PREFIX_LEN="$OPTARG" ;;
    f) SUFFIX="$OPTARG" ;;
    h|*) usage ;;
  esac
done

# validate numeric args
if ! [[ "$CONCURRENCY" =~ ^[0-9]+$ ]] || [ "$CONCURRENCY" -le 0 ]; then
  echo "Invalid concurrency: $CONCURRENCY" >&2
  exit 2
fi
if ! [[ "$PREFIX_LEN" =~ ^[0-9]+$ ]] || [ "$PREFIX_LEN" -lt 1 ]; then
  echo "Invalid prefix length: $PREFIX_LEN (must be >=1)" >&2
  exit 2
fi

# required tools
for cmd in dig whois; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command '$cmd' not found" >&2
    exit 3
  fi
done

# optional timeout
USE_TIMEOUT=0
if command -v timeout >/dev/null 2>&1; then
  USE_TIMEOUT=1
  TIMEOUT_CMD="timeout 10"
fi

# Character set: lowercase letters excluding v, w, z
chars=(a b c d e f g h i j k l m n o p q r s t u x y)
LETTER_COUNT=${#chars[@]}

# prepare output file
if [ "$RESUME" -eq 0 ]; then
  : > "$OUTPUT_FILE"
else
  touch "$OUTPUT_FILE"
fi

# flock FD for atomic appends if available
FLOCK_AVAILABLE=0
if command -v flock >/dev/null 2>&1; then
  FLOCK_AVAILABLE=1
  exec 200>>"$OUTPUT_FILE"
fi

log() {
  [ "$VERBOSE" -eq 1 ] && echo "$@"
}

append_available() {
  local fqdn="$1"
  if [ "$FLOCK_AVAILABLE" -eq 1 ]; then
    flock 200
    printf '%s\n' "$fqdn" >&200
    flock -u 200
  else
    printf '%s\n' "$fqdn" >> "$OUTPUT_FILE"
  fi
}

whois_shows_available() {
  local out="$1"
  if echo "$out" | egrep -qi 'No match for|NOT FOUND|No Data Found|has not been registered|No entries found|Status: free|No Object Found|AVAILABLE'; then
    return 0
  fi
  return 1
}

whois_shows_taken() {
  local out="$1"
  if echo "$out" | egrep -qi 'Registrar:|Creation Date:|Updated Date:|Registry Expiry Date:|Domain Name:|Registrant|Domain Status:|Domain ID:'; then
    return 0
  fi
  return 1
}

# check a single domain label (label is prefix + suffix appended inside function)
check_domain() {
  local label="$1"
  local fqdn="${label}.${TLD}"

  # resume: skip if already recorded
  if [ "$RESUME" -eq 1 ]; then
    if grep -Fxq "$fqdn" "$OUTPUT_FILE" 2>/dev/null; then
      log "Skipping (already recorded): $fqdn"
      return 1
    fi
  fi

  log "Checking: $fqdn"

  # DNS checks
  local types=(A AAAA NS MX CNAME)
  for t in "${types[@]}"; do
    local r
    r=$(dig +short "$fqdn" $t 2>/dev/null || true)
    if [ -n "$r" ]; then
      log "  - DNS $t present -> TAKEN ($fqdn)"
      return 1
    fi
  done

  log "  - No DNS records; querying WHOIS..."
  sleep "$SLEEP_BETWEEN_WHOIS"

  local whois_out
  if [ "$USE_TIMEOUT" -eq 1 ]; then
    whois_out=$($TIMEOUT_CMD whois "$fqdn" 2>/dev/null || true)
  else
    whois_out=$(whois "$fqdn" 2>/dev/null || true)
  fi

  if [ -z "$whois_out" ]; then
    log "  - WHOIS empty/timed out -> assume TAKEN ($fqdn)"
    return 1
  fi

  if whois_shows_taken "$whois_out"; then
    log "  - WHOIS shows registration data -> TAKEN ($fqdn)"
    return 1
  fi

  if whois_shows_available "$whois_out"; then
    log "  - WHOIS shows available -> AVAILABLE ($fqdn)"
    append_available "$fqdn"
    return 0
  fi

  log "  - WHOIS unclear -> assume TAKEN ($fqdn)"
  return 1
}

running_jobs() {
  jobs -rp 2>/dev/null | wc -l
}

on_exit() {
  log "Cleaning up background jobs..."
  jobs -pr | xargs -r kill 2>/dev/null || true
  wait 2>/dev/null || true
  [ "$FLOCK_AVAILABLE" -eq 1 ] && exec 200>&- || true
}
trap on_exit EXIT

# recursive generator that launches checks concurrently but respects concurrency limit
generate_prefixes() {
  local prefix="$1"
  local depth="$2"

  if [ "$depth" -eq 0 ]; then
    local label="${prefix}${SUFFIX}"
    check_domain "$label" &

    # throttle background jobs
    while [ "$(running_jobs)" -ge "$CONCURRENCY" ]; do
      # try to reap one job faster if wait -n exists
      if wait -n 2>/dev/null; then
        :
      else
        sleep 0.05
      fi
    done
    return
  fi

  for ch in "${chars[@]}"; do
    # optionally prevent immediate repeated consecutive characters:
    if [ -n "$prefix" ]; then
      local last="${prefix: -1}"
      if [ "$last" = "$ch" ]; then
        continue
      fi
    fi
    generate_prefixes "${prefix}${ch}" $((depth - 1))
  done
}

# warn about explosion
COMBINATIONS=$((LETTER_COUNT ** PREFIX_LEN))
if [ "$PREFIX_LEN" -gt 4 ] && [ -t 1 ]; then
  echo "Warning: prefix length $PREFIX_LEN -> up to $COMBINATIONS combinations (alphabet excludes v,w,z)."
  echo "Press Enter to continue or Ctrl-C to abort."
  read -r _
fi

# start generation
generate_prefixes "" "$PREFIX_LEN"

# wait for remaining workers
wait

echo "Finished. Available domains saved to $OUTPUT_FILE"