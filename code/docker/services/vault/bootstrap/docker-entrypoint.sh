#!/usr/bin/dumb-init /bin/sh
set -e

# Note above that we run dumb-init as PID 1 in order to reap zombie processes
# as well as forward signals to all processes in its session. Normally, sh
# wouldn't do either of these functions so we'd leak zombies as well as do
# unclean termination of all our sub-processes.


# Prevent core dumps
ulimit -c 0

# VAULT_CONFIG_DIR isn't exposed as a volume but you can compose additional
# config files in there if you use this image as a base, or use
# VAULT_LOCAL_CONFIG below.
VAULT_CONFIG_DIR=/vault/config

# You can also set the VAULT_LOCAL_CONFIG environment variable to pass some
# Vault configuration JSON without having to bind any volumes.
VAULT_LOCAL_CONFIG='{"backend": {"file": {"path": "/vault/file"}},"ui":true,"disable_mlock":true,"listener":{"tcp":{"address":"0.0.0.0:8200","tls_disable":1}}, "default_lease_ttl": "168h", "max_lease_ttl": "720h"}'

if [ -n "$VAULT_LOCAL_CONFIG" ]; then
    echo "$VAULT_LOCAL_CONFIG" > "$VAULT_CONFIG_DIR/local.json"
fi

# Changing permissions to vault User
chown -R vault:vault /vault/config
chown -R vault:vault /vault/logs
chown -R vault:vault /vault/file

# Starting Vault
vault server  -config="$VAULT_CONFIG_DIR" &


sleep 20 # wait for Vault to come up

#Unsealing Vault
vault operator init >> /vault/init.file
egrep -m3 '^Unseal Key' /vault/init.file | cut -f2- -d: | tr -d ' ' | while read key; do vault operator unseal ${key}; done
egrep -m3 '^Initial Root Token' /vault/init.file | cut -f2- -d: | tr -d ' ' | while read key; do vault login ${key}; done

# Enabling UserPass
vault auth enable userpass

# use secrets engine v1
vault secrets enable kv
vault kv put kv/$VAULT_SECRET foo=world
vault policy write $VAULT_POLICY -<<EOF
path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

# Creating policy with policy with Username and passowrd
vault write auth/userpass/users/$VAULT_USERNAME password=$VAULT_PASSWORD policies=$VAULT_POLICY

# block forever
tail -f /dev/null
