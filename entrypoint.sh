#!/bin/sh
set -ex

# Executa o script de configuração apenas se não existir o banco
if [ ! -f /var/lib/keystone/.bootstrapped ]; then
    /usr/local/bin/keystone-setup.sh
    touch /var/lib/keystone/.bootstrapped
fi

echo "[*] Iniciando Keystone com Apache..."
exec /usr/sbin/httpd -DFOREGROUND
