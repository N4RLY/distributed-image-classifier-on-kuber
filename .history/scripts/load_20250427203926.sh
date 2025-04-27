#!/usr/bin/env bash
set -euo pipefail

### ─── CONFIGURE AS NEEDED ────────────────────────────────────────────────────
# The full URL to your classify endpoint (default via Ingress → port 80)
ENDPOINT_URL="${ENDPOINT_URL:-http://localhost/api/v1/classify}"
# Directory containing your test images
IMAGES_DIR="${1:-test-images}"
# Total number of requests to fire
TOTAL=100
### ─────────────────────────────────────────────────────────────────────────────

if [ ! -d "${IMAGES_DIR}" ]; then
  echo "❌ Directory not found: ${IMAGES_DIR}"
  exit 1
fi

echo "🔁 Firing ${TOTAL} concurrent requests to ${ENDPOINT_URL}"
files=( "${IMAGES_DIR}"/* )
count=${#files[@]}

for i in $(seq 1 ${TOTAL}); do
  img="${files[$(( (i-1) % count ))]}"
  {
    curl -s -w "REQ ${i}: %{http_code} in %{time_total}s\n" \
      -X POST "${ENDPOINT_URL}" \
      -H "Content-Type: multipart/form-data" \
      -F "file=@${img}" \
      > /dev/null
  } &
done

wait
echo "✅ All ${TOTAL} done."
