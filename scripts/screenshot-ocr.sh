#!/usr/bin/env bash
# Screenshot + Mistral OCR => clipboard
# Usage: screenshot-ocr.sh <mistral-api-key>
# Takes a region screenshot, sends to Mistral OCR, copies text to clipboard
set -euo pipefail

API_KEY="${1:-}"
SCREENSHOT_FILE="/tmp/noctalia-ocr-$$.png"
PAYLOAD_FILE="/tmp/noctalia-ocr-$$.json"

notify() {
    if [ "${SCREENSHOT_OCR_NOTIFY:-}" = "1" ] && command -v notify-send &>/dev/null; then
        notify-send "Screenshot OCR" "$*" || true
    fi
}

die() {
    echo "$*" >&2
    notify "$*"
    rm -f "$SCREENSHOT_FILE" "$PAYLOAD_FILE"
    exit 1
}

# ── Check requirements ────────────────────────────────────────────
[ -n "$API_KEY" ] || die "Mistral API key not provided"

# ── Take screenshot (region select) ────────────────────────────────
if command -v grim &>/dev/null && command -v slurp &>/dev/null; then
    GEO=$(slurp -d 2>/dev/null) || die "Region selection cancelled"
    [ -n "$GEO" ] || die "Region selection returned no geometry"
    grim -g "$GEO" "$SCREENSHOT_FILE"
elif command -v grim &>/dev/null; then
    grim "$SCREENSHOT_FILE"
else
    die "No screenshot tool found (need grim+slurp)"
fi

# ── Resize if too large (Mistral rejects > ~800KB base64) ──────────
FILE_SIZE=$(stat -c%s "$SCREENSHOT_FILE" 2>/dev/null || stat -f%z "$SCREENSHOT_FILE")
if [ "$FILE_SIZE" -gt 600000 ]; then
    if command -v magick &>/dev/null; then
        magick "$SCREENSHOT_FILE" -resize 75% -quality 85 "$SCREENSHOT_FILE"
    elif command -v convert &>/dev/null; then
        convert "$SCREENSHOT_FILE" -resize 75% -quality 85 "$SCREENSHOT_FILE"
    fi
fi

# ── Base64 encode ──────────────────────────────────────────────────
B64=$(base64 -w 0 "$SCREENSHOT_FILE" 2>/dev/null || base64 "$SCREENSHOT_FILE" | tr -d '\n')

# If still too large, reduce further
if [ ${#B64} -gt 800000 ]; then
    if command -v magick &>/dev/null; then
        magick "$SCREENSHOT_FILE" -resize 50% -quality 70 "$SCREENSHOT_FILE"
    elif command -v convert &>/dev/null; then
        convert "$SCREENSHOT_FILE" -resize 50% -quality 70 "$SCREENSHOT_FILE"
    fi
    B64=$(base64 -w 0 "$SCREENSHOT_FILE" 2>/dev/null || base64 "$SCREENSHOT_FILE" | tr -d '\n')
fi

# ── Call Mistral OCR API ───────────────────────────────────────────
cat > "$PAYLOAD_FILE" <<ENDJSON
{
  "model": "mistral-ocr-4-0",
  "document": {
    "type": "image_url",
    "image_url": "data:image/png;base64,${B64}"
  },
  "include_image_base64": false
}
ENDJSON

RESPONSE=$(curl -s -X POST "https://api.mistral.ai/v1/ocr" \
    -H "Authorization: Bearer ${API_KEY}" \
    -H "Content-Type: application/json" \
    --data-binary "@${PAYLOAD_FILE}")

# ── Extract text ───────────────────────────────────────────────────
if command -v jq &>/dev/null; then
    TEXT=$(echo "$RESPONSE" | jq -r '.pages[0].markdown // .pages[0].text // .pages[0].raw_text // empty' 2>/dev/null)
else
    TEXT=$(echo "$RESPONSE" | grep -o '"markdown":"[^"]*"' | head -1 | sed 's/"markdown":"//;s/"$//;s/\\n/\n/g')
fi

if [ -z "$TEXT" ] || [ "$TEXT" = "null" ]; then
    ERR=$(echo "$RESPONSE" | jq -r '.message // .error // empty' 2>/dev/null || true)
    die "OCR failed: ${ERR:-no text in response}"
fi

# ── Copy to clipboard ──────────────────────────────────────────────
if command -v wl-copy &>/dev/null; then
    echo -n "$TEXT" | wl-copy
fi

# ── Cleanup ────────────────────────────────────────────────────────
rm -f "$SCREENSHOT_FILE" "$PAYLOAD_FILE"

# Output text for the plugin to read back (shown in toast)
notify "Copied ${#TEXT} characters to clipboard"
echo "$TEXT"
