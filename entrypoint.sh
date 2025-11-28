#!/bin/bash

echo "Waiting for database..."
sleep 10

if [ ! -f /var/www/html/tao/INSTALLED ]; then
  echo "Running TAO installer..."

  sudo -u www-data php tao/scripts/taoInstall.php \
    --db_driver pdo_mysql \
    --db_host "$DB_HOST" \
    --db_name "$DB_NAME" \
    --db_user "$DB_USER" \
    --db_pass "$DB_PASS" \
    --module_namespace "$BASE_URL/first.rdf" \
    --module_url "$BASE_URL" \
    --user_login "$ADMIN_USER" \
    --user_pass "$ADMIN_PASS" \
    -e taoCe

  touch /var/www/html/tao/INSTALLED
fi

exec "$@"
