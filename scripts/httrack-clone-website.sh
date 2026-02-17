#!/bin/bash
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

URL="$1"
OUTPUT_DIR="./cannes.mullenloweglobal.com"

# Common user-agent string
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"

# Domains to exclude
EXCLUDES=(
    "-.linkedin.com/"
    "-.console.aws.amazon.com/"
    "-.bing.com/"
    "-.instagram.com/"
    "-.x.com/"
    "-.matomo.cloud/"
    "-.cookielaw.org/"
    "-.ops.lowecloud.com/"
    "-.softwareadvice.com/"
    "-.socialsamosa.com/"
    "-.youtube.com/"
    "-.google.com/"
    "-.googletagmanager.com/"
    "-.twitter.com/"
    "-.matomo.org/"
    "-.hcaptcha.com/"
    "-.github.com/"
    "-.thedrum.com/"
    "-.gstatic.com/"
    "-.vimeo.com/"
    "-.player.vimeo.com/"
    "-.licdn.com/"
    "-.aboutamazon.com/"
    "-.w3.org/"
    "-.twitch.tv/"
    "-.capterra.com/"
    "-.secure.gravatar.com/"
    "-.cdninstagram.com/"
    "-.google-analytics.com/"
    "-.lintaslive.in/"
    "-.lowelintas.in/"
    "-.mullenlintas.in/"
    "-.mullenlowelintas.in/"
    "-.pointninelintas.in/"
    "-.zencdn.net/"
    "-.cdn.cookielaw.org/"
    "-.vjs.zencdn.net/"
)

# Run httrack
httrack "$URL" \
    -O "$OUTPUT_DIR" \
    -%v \
    --user-agent "$USER_AGENT" \
    --advanced-progressinfo \
    --near \
    --sockets=80 \
    --keep-alive \
    --continue \
    --max-rate=0 \
    --connection-per-second=50 \
    -r9999 \
    +"$URL/" \
    "${EXCLUDES[@]}" \
    --disable-security-limits \
    --mirror \
    --robots=0
