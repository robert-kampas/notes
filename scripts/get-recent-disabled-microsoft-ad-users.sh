#!/bin/bash

# Get recently disabled users using refreshTokensValidFromDateTime
# Usage: ./get_recent_disabled_users.sh

ACCESS_TOKEN="SECRETKEYGOESHERE"

# Filter date (users disabled after this date)
FILTER_DATE="2026-02-01"

OUTPUT_FILE="disabled_users_$(date +%Y%m%d_%H%M%S).csv"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to sanitize JSON response
sanitize_json() {
  python3 -c "
import sys, re, json
data = sys.stdin.read()
# Fix invalid escape sequences
data = re.sub(r'\\\\x[0-9a-fA-F]{2}', '', data)
data = re.sub(r'[\\x00-\\x1f]', '', data)
print(data)
"
}

log "Starting disabled users export..."
log "Filtering for users disabled after: $FILTER_DATE"
log "Output file: $OUTPUT_FILE"

# Write CSV header
echo "displayName,userPrincipalName,mail,jobTitle,department,officeLocation,companyName,createdDateTime,disabledDateTime" > "$OUTPUT_FILE"

# Temp file to collect all users
TEMP_FILE=$(mktemp)

URL='https://graph.microsoft.com/beta/users?$filter=accountEnabled%20eq%20false&$select=id,displayName,userPrincipalName,mail,jobTitle,department,officeLocation,companyName,createdDateTime,refreshTokensValidFromDateTime&$count=true&$top=999'

PAGE=1

while [ -n "$URL" ]; do
  log "Fetching page $PAGE..."
  
  RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" -H "ConsistencyLevel: eventual" "$URL" | sanitize_json)
  
  # Check for errors
  ERROR=$(echo "$RESPONSE" | jq -r '.error.message // empty' 2>/dev/null)
  if [ -n "$ERROR" ]; then
    log "ERROR: $ERROR"
    rm -f "$TEMP_FILE"
    exit 1
  fi
  
  # Append users to temp file
  echo "$RESPONSE" | jq -c '.value[]?' 2>/dev/null >> "$TEMP_FILE"
  
  PAGE_COUNT=$(echo "$RESPONSE" | jq '.value | length' 2>/dev/null || echo "0")
  log "Page $PAGE: Found $PAGE_COUNT users"
  
  # Get next page URL
  URL=$(echo "$RESPONSE" | jq -r '.["@odata.nextLink"] // empty' 2>/dev/null)
  
  ((PAGE++))
done

# Filter by date, sort, and output to CSV
FILTERED_COUNT=$(cat "$TEMP_FILE" | jq -s --arg date "$FILTER_DATE" '
  map(select(.refreshTokensValidFromDateTime != null and .refreshTokensValidFromDateTime >= $date))
  | sort_by(.refreshTokensValidFromDateTime)
  | reverse
  | length
' 2>/dev/null || echo "0")

cat "$TEMP_FILE" | jq -rs --arg date "$FILTER_DATE" '
  map(select(.refreshTokensValidFromDateTime != null and .refreshTokensValidFromDateTime >= $date))
  | sort_by(.refreshTokensValidFromDateTime)
  | reverse
  | .[]
  | [
      (.displayName // ""),
      (.userPrincipalName // ""),
      (.mail // ""),
      (.jobTitle // ""),
      (.department // ""),
      (.officeLocation // ""),
      (.companyName // ""),
      (.createdDateTime // ""),
      (.refreshTokensValidFromDateTime // "")
    ]
  | @csv
' >> "$OUTPUT_FILE" 2>/dev/null

rm -f "$TEMP_FILE"

log "Export complete. Found $FILTERED_COUNT users disabled after $FILTER_DATE"
log "Output saved to: $OUTPUT_FILE"
