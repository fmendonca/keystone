#!/bin/sh
set -ex

echo "[*] Esperando o banco responder em ${KEYSTONE_DB_HOST}..."
until nc -z "${KEYSTONE_DB_HOST}" 3306; do
  sleep 1
done

echo "[*] Gerando keystone.conf..."
cat > /etc/keystone/keystone.conf <<EOF
[DEFAULT]
admin_token = ADMIN
[database]
connection = mysql+pymysql://keystone:${KEYSTONE_DB_PASS}@${KEYSTONE_DB_HOST}/keystone
[token]
provider = fernet
[cache]
backend = dogpile.cache.memory
[memcache]
servers = ${KEYSTONE_DB_HOST}:11211
[identity]
driver = sql
[oslo_messaging_rabbit]
rabbit_host = ${KEYSTONE_DB_HOST}
[DEFAULT]
log_dir = /var/log/keystone
EOF

echo "[*] Sincronizando banco de dados..."
keystone-manage db_sync

echo "[*] Inicializando o Keystone (Fernet + Bootstrap)..."
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

keystone-manage bootstrap \
  --bootstrap-password "${KEYSTONE_ADMIN_PASS}" \
  --bootstrap-admin-url http://${KEYSTONE_HOSTNAME}:5000/v3/ \
  --bootstrap-internal-url http://${KEYSTONE_HOSTNAME}:5000/v3/ \
  --bootstrap-public-url http://${KEYSTONE_HOSTNAME}:5000/v3/ \
  --bootstrap-region-id "${KEYSTONE_REGION}"
