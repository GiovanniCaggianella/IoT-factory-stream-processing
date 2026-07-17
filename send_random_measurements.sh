#!/usr/bin/env bash

set -euo pipefail

api_url="${API_URL:-http://127.0.0.1:5001/predict}"
interval="${INTERVAL:-1}"

print_json() {
    sed -e 's/{/{\n  /' -e 's/,/,\n  /g' -e 's/}/\n}/'
}

measurements=(
    '{"Air temperature":298.1,"Process temperature":308.6,"Rotational speed":1551,"Torque":42.8,"Tool wear":0}'
    '{"Air temperature":298.2,"Process temperature":308.7,"Rotational speed":1408,"Torque":46.3,"Tool wear":3}'
    '{"Air temperature":298.1,"Process temperature":308.5,"Rotational speed":1498,"Torque":49.4,"Tool wear":5}'
    '{"Air temperature":298.2,"Process temperature":308.6,"Rotational speed":1433,"Torque":39.5,"Tool wear":7}'
    '{"Air temperature":298.2,"Process temperature":308.7,"Rotational speed":1408,"Torque":40.0,"Tool wear":9}'
    '{"Air temperature":298.1,"Process temperature":308.6,"Rotational speed":1425,"Torque":41.9,"Tool wear":11}'
    '{"Air temperature":298.1,"Process temperature":308.6,"Rotational speed":1558,"Torque":42.4,"Tool wear":14}'
    '{"Air temperature":298.1,"Process temperature":308.6,"Rotational speed":1527,"Torque":40.2,"Tool wear":16}'
    '{"Air temperature":298.3,"Process temperature":308.7,"Rotational speed":1667,"Torque":28.6,"Tool wear":18}'
    '{"Air temperature":298.5,"Process temperature":309.0,"Rotational speed":1741,"Torque":28.0,"Tool wear":21}'
    '{"Air temperature":298.4,"Process temperature":308.9,"Rotational speed":1782,"Torque":23.9,"Tool wear":24}'
    '{"Air temperature":298.6,"Process temperature":309.1,"Rotational speed":1423,"Torque":44.3,"Tool wear":29}'
    '{"Air temperature":298.6,"Process temperature":309.1,"Rotational speed":1339,"Torque":51.1,"Tool wear":34}'
    '{"Air temperature":298.6,"Process temperature":309.2,"Rotational speed":1742,"Torque":30.0,"Tool wear":37}'
    '{"Air temperature":298.6,"Process temperature":309.2,"Rotational speed":2035,"Torque":19.6,"Tool wear":40}'
    '{"Air temperature":298.6,"Process temperature":309.2,"Rotational speed":1542,"Torque":48.4,"Tool wear":42}'
    '{"Air temperature":298.6,"Process temperature":309.2,"Rotational speed":1311,"Torque":46.6,"Tool wear":44}'
    '{"Air temperature":298.7,"Process temperature":309.2,"Rotational speed":1410,"Torque":45.6,"Tool wear":47}'
    '{"Air temperature":298.8,"Process temperature":309.2,"Rotational speed":1306,"Torque":54.5,"Tool wear":50}'
    '{"Air temperature":298.9,"Process temperature":309.3,"Rotational speed":1632,"Torque":32.5,"Tool wear":55}'
)

for index in "${!measurements[@]}"; do
    sequence=$((index + 1))
    payload="${measurements[$index]}"

    response=$(curl --fail-with-body --silent --show-error \
        --request POST \
        --header 'Content-Type: application/json' \
        --data "$payload" \
        "$api_url")
    printf 'Measurement %d request:\n' "$sequence"
    printf '%s\n' "$payload" | print_json
    printf 'Response:\n'
    printf '%s\n\n' "$response" | print_json

    if [[ "$sequence" -lt "${#measurements[@]}" ]]; then
        sleep "$interval"
    fi
done