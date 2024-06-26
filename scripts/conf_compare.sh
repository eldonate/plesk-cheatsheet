#!/bin/bash

# Check if the argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 php_version"
    exit 1
fi

# Assign the first argument to a variable
PHP_VERSION=$1

# Convert the version number to the format used in the database query
PHP_HANDLER_ID="plesk-php${PHP_VERSION//./}-fpm"

# Directory where .conf files are stored
CONF_DIR="/opt/plesk/php/$PHP_VERSION/etc/php-fpm.d"

# First query to get dom_id
DOM_IDS=$(plesk db "SELECT dom_id FROM hosting WHERE php_handler_id = '$PHP_HANDLER_ID';")

# Loop through each dom_id and execute the second query
echo "$DOM_IDS" | grep -oE '[0-9]+' | while read -r dom_id; do
    if [[ -n "$dom_id" ]]; then
        # Run the query and capture the output
        DOMAIN_NAME=$(plesk db "SELECT name FROM domains WHERE id = $dom_id;" | sed -n '4p' | tr -d ' ' | sed 's/|//g')

        # Check if the .conf file exists
        CONF_FILE="$CONF_DIR/${DOMAIN_NAME}.conf"
        if [[ ! -f "$CONF_FILE" ]]; then
            echo "$DOMAIN_NAME"
        fi
    fi
done
