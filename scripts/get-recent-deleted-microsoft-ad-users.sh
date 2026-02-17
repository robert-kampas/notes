#!/bin/bash

# Get recently deleted users
# Usage: ./get_recent_deleted_users.sh

ACCESS_TOKEN="SECRETKEYGOESHERE"

# Filter date (users deleted after this date)
FILTER_DATE="2025-12-08"

OUTPUT_FILE="deleted_users_$(date +%Y%m%d_%H%M%S).csv"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting deleted users export..."
log "Filtering for users deleted after: $FILTER_DATE"
log "Output file: $OUTPUT_FILE"

# Write CSV header
echo "displayName,userPrincipalName,mail,jobTitle,department,officeLocation,companyName,deletedDateTime" > "$OUTPUT_FILE"

# Temp file to collect all users
TEMP_FILE=$(mktemp)

URL='https://graph.microsoft.com/beta/directory/deletedItems/microsoft.graph.user?$select=id,displayName,userPrincipalName,mail,jobTitle,department,officeLocation,companyName,deletedDateTime&$top=999'

PAGE=1

while [ -n "$URL" ]; do
  log "Fetching page $PAGE..."
  
  RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" -H "ConsistencyLevel: eventual" "$URL")
  
  # Check for errors
  ERROR=$(echo "$RESPONSE" | jq -r '.error.message // empty')
  if [ -n "$ERROR" ]; then
    log "ERROR: $ERROR"
    rm -f "$TEMP_FILE"
    exit 1
  fi
  
  # Append users to temp file
  echo "$RESPONSE" | jq -c '.value[]' >> "$TEMP_FILE"
  
  PAGE_COUNT=$(echo "$RESPONSE" | jq '.value | length')
  log "Page $PAGE: Found $PAGE_COUNT users"
  
  # Get next page URL
  URL=$(echo "$RESPONSE" | jq -r '.["@odata.nextLink"] // empty')
  
  ((PAGE++))
done

# Filter by date, sort, and output to CSV
FILTERED_COUNT=$(cat "$TEMP_FILE" | jq -s --arg date "$FILTER_DATE" '
  map(select(.deletedDateTime != null and .deletedDateTime >= $date))
  | sort_by(.deletedDateTime)
  | reverse
  | length
')

cat "$TEMP_FILE" | jq -rs --arg date "$FILTER_DATE" '
  map(select(.deletedDateTime != null and .deletedDateTime >= $date))
  | sort_by(.deletedDateTime)
  | reverse
  | .[]
  | [.displayName, .userPrincipalName, .mail, .jobTitle, .department, .officeLocation, .companyName, .deletedDateTime]
  | @csv
' >> "$OUTPUT_FILE"

rm -f "$TEMP_FILE"

log "Export complete. Found $FILTERED_COUNT users deleted after $FILTER_DATE"
log "Output saved to: $OUTPUT_FILE"
