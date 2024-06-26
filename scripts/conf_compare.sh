#!/bin/bash

# this checks all php versions
process_php_version() {
    local PHP_VERSION=$1
    local PHP_HANDLER_ID="plesk-php${PHP_VERSION//./}-fpm"
    local CONF_DIR="/opt/plesk/php/$PHP_VERSION/etc/php-fpm.d"

    # getting dom_id for each handler
    DOM_IDS=$(plesk db "SELECT dom_id FROM hosting WHERE php_handler_id = '$PHP_HANDLER_ID';")

    # looping to domains table using dom_ids to get domains that using the handler
    echo "$DOM_IDS" | grep -oE '[0-9]+' | while read -r dom_id; do
        if [[ -n "$dom_id" ]]; then
            DOMAIN_NAME=$(plesk db "SELECT name FROM domains WHERE id = $dom_id;" | sed -n '2p' | tr -d ' ' | sed 's/|//g')

            # checking the existance of conf file
            CONF_FILE="$CONF_DIR/${DOMAIN_NAME}.conf"
            if [[ ! -f "$CONF_FILE" ]]; then
                echo "$DOMAIN_NAME"
                # if "f" has been added as argument, the repair will run
                if [[ "$FORCE_REPAIR" == "f" ]]; then
                    plesk repair web "$DOMAIN_NAME" -y
                fi
            fi
        fi
    done
}

# checking if arguments are provided
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 arguments required (ex 8.1, all or/and f)"
    exit 1
fi

# first argument goes for php version
PHP_VERSION=$1

# optional fix argument
FORCE_REPAIR=$2

# if argument all is being used, then the script will loop through /opt/plesk/php/
if [[ "$PHP_VERSION" == "all" ]]; then
    for version in $(ls /opt/plesk/php/); do
        echo "Processing PHP version $version"
        process_php_version $version
    done
else
    # if a specific php version added as argument
    process_php_version $PHP_VERSION
fi
