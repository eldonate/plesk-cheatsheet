#!/bin/bash

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 php_version [f]"
    exit 1
fi

PHP_VERSION=$1

FORCE_REPAIR=$2

PHP_HANDLER_ID="plesk-php${PHP_VERSION//./}-fpm"

CONF_DIR="/opt/plesk/php/$PHP_VERSION/etc/php-fpm.d"

DOM_IDS=$(plesk db "SELECT dom_id FROM hosting WHERE php_handler_id = '$PHP_HANDLER_ID';")

echo "$DOM_IDS" | grep -oE '[0-9]+' | while read -r dom_id; do
    if [[ -n "$dom_id" ]]; then
        DOMAIN_NAME=$(plesk db "SELECT name FROM domains WHERE id = $dom_id;" | sed -n '4p' | tr -d ' ' | sed 's/|//g')

        CONF_FILE="$CONF_DIR/${DOMAIN_NAME}.conf"
        if [[ ! -f "$CONF_FILE" ]]; then
            echo "$DOMAIN_NAME"
            if [[ "$FORCE_REPAIR" == "f" ]]; then
                plesk repair web "$DOMAIN_NAME" -y
            fi
        fi
    fi
done
