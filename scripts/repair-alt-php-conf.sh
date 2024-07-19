#!/bin/bash

DOM_IDS=$(plesk db "SELECT dom_id FROM hosting WHERE php_handler_id LIKE '%alt%';")

echo "$DOM_IDS" | grep -oE '[0-9]+' | while read -r dom_id; do
    if [[ -n "$dom_id" ]]; then
        DOMAIN_NAME=$(plesk db "SELECT name FROM domains WHERE id = $dom_id;" | sed -n '4p' | tr -d ' ' | sed 's/|//g')
        echo "$DOMAIN_NAME"
        if [[ -n "$DOMAIN_NAME" ]]; then
            plesk repair web "$DOMAIN_NAME" -y
        fi
    fi
done
