#!/bin/bash

set -e

echo "Waiting for database..."
until mysql -h"$TAO_DB_HOST" -u"$TAO_DB_USER" -p"$TAO_DB_PASS" "$TAO_DB_NAME" -e "SELECT 1;" &> /dev/null
do
  echo "Database not ready..."
  sleep 3
done

# Install only on first run
if [ ! -f /var/www/html/tao/installed.flag ]; then
  echo "Running TAO installer..."

  sudo -u www-data php tao/scripts/taoInstall.php \
    --db_driver pdo_mysql \
    --db_host "$TAO_DB_HOST" \
    --db_name "$TAO_DB_NAME" \
    --db_user "$TAO_DB_USER" \
    --db_pass "$TAO_DB_PASS" \
    --module_namespace "$TAO_BASE_URL/first.rdf" \
    --module_url "$TAO_BASE_URL" \
    --user_login "$TAO_ADMIN_USER" \
    --user_pass "$TAO_ADMIN_PASS" \
    -e taoCe

  touch /var/www/html/tao/installed.flag
  echo "TAO installation complete."
fi

exec apache2-foreground
