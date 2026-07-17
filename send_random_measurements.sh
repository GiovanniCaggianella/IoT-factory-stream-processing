#!/usr/bin/env bash

set -euo pipefail

api_url="${API_URL:-http://127.0.0.1:5001/predict}"
interval="${INTERVAL:-1}"

random_decimal() {
    local minimum="$1"
    local maximum="$2"
    local whole=$((minimum + RANDOM % (maximum - minimum + 1)))
    printf '%d.%d' "$whole" "$((RANDOM % 10))"
}

for sequence in {1..10}; do
    payload=$(printf '{"Air temperature": %s, "Process temperature": %s, "Rotational speed": %d, "Torque": %s, "Tool wear": %d}' \
        "$(random_decimal 293 313)" \
        "$(random_decimal 303 323)" \
        "$((1000 + RANDOM % 2001))" \
        "$(random_decimal 3 80)" \
        "$((RANDOM % 254))")

    response=$(curl --fail-with-body --silent --show-error \
        --request POST \
        --header 'Content-Type: application/json' \
        --data "$payload" \
        "$api_url")
    printf 'measurement=%d %s\n' "$sequence" "$response"

    if [[ "$sequence" -lt 10 ]]; then
        sleep "$interval"
    fi
done