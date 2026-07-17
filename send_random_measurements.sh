#!/usr/bin/env bash

set -euo pipefail

api_url="${API_URL:-http://127.0.0.1:5001/predict}"
interval="${INTERVAL:-1}"

print_json() {
    sed -e 's/{/{\n  /' -e 's/,/,\n  /g' -e 's/}/\n}/'
}

measurements=(
    '{"Air temperature":298.0,"Process temperature":308.5,"Rotational speed":1510,"Torque":42.6,"Tool wear":12}'
    '{"Air temperature":298.4,"Process temperature":308.8,"Rotational speed":1422,"Torque":47.1,"Tool wear":34}'
    '{"Air temperature":298.7,"Process temperature":309.1,"Rotational speed":1655,"Torque":31.3,"Tool wear":56}'
    '{"Air temperature":299.1,"Process temperature":309.5,"Rotational speed":1518,"Torque":43.2,"Tool wear":74}'
    '{"Air temperature":299.4,"Process temperature":309.8,"Rotational speed":1386,"Torque":49.4,"Tool wear":91}'
    '{"Air temperature":299.7,"Process temperature":310.2,"Rotational speed":1760,"Torque":30.2,"Tool wear":108}'
    '{"Air temperature":299.9,"Process temperature":310.4,"Rotational speed":1486,"Torque":44.8,"Tool wear":98}'
    '{"Air temperature":300.2,"Process temperature":310.9,"Rotational speed":1584,"Torque":39.1,"Tool wear":145}'
    '{"Air temperature":300.0,"Process temperature":310.5,"Rotational speed":1480,"Torque":46.0,"Tool wear":110}'
    '{"Air temperature":299.6,"Process temperature":310.0,"Rotational speed":1620,"Torque":36.8,"Tool wear":82}'
    '{"Air temperature":298.85,"Process temperature":309.05,"Rotational speed":2840,"Torque":5.2,"Tool wear":146}'
    '{"Air temperature":298.95,"Process temperature":309.05,"Rotational speed":1402,"Torque":66.4,"Tool wear":188}'
    '{"Air temperature":298.75,"Process temperature":308.85,"Rotational speed":1448,"Torque":42.0,"Tool wear":211}'
    '{"Air temperature":298.35,"Process temperature":308.15,"Rotational speed":1276,"Torque":61.4,"Tool wear":214}'
    '{"Air temperature":298.25,"Process temperature":308.05,"Rotational speed":1418,"Torque":53.5,"Tool wear":221}'
    '{"Air temperature":298.45,"Process temperature":308.35,"Rotational speed":1440,"Torque":63.0,"Tool wear":24}'
    '{"Air temperature":298.15,"Process temperature":308.45,"Rotational speed":2645,"Torque":11.4,"Tool wear":90}'
    '{"Air temperature":298.35,"Process temperature":308.75,"Rotational speed":1415,"Torque":61.5,"Tool wear":123}'
    '{"Air temperature":297.95,"Process temperature":308.25,"Rotational speed":1352,"Torque":59.7,"Tool wear":205}'
    '{"Air temperature":297.65,"Process temperature":308.55,"Rotational speed":1495,"Torque":50.5,"Tool wear":226}'
)

scenario_names=(
    nominal nominal nominal nominal nominal nominal nominal nominal nominal nominal
    "anomaly pattern" "anomaly pattern" "anomaly pattern" "anomaly pattern" "anomaly pattern"
    "anomaly pattern" "anomaly pattern" "anomaly pattern" "anomaly pattern" "anomaly pattern"
)

for index in "${!measurements[@]}"; do
    sequence=$((index + 1))
    payload="${measurements[$index]}"
    scenario="${scenario_names[$index]}"

    response=$(curl --fail-with-body --silent --show-error \
        --request POST \
        --header 'Content-Type: application/json' \
        --data "$payload" \
        "$api_url")
    printf 'Measurement %d (%s) request:\n' "$sequence" "$scenario"
    printf '%s\n' "$payload" | print_json
    printf 'Response:\n'
    printf '%s\n\n' "$response" | print_json

    if [[ "$sequence" -lt "${#measurements[@]}" ]]; then
        sleep "$interval"
    fi
done