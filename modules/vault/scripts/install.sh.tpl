#!/usr/bin/env bash
set -e -x

# Install packages
# Not sure if this is really neeeded, as it takes a VERY long time
#apt-get update -y
#apt-get install -y curl unzip

# Download Vault into some temporary directory
curl -L "${download-url}" > /tmp/vault.zip

# Unzip it
cd /tmp
unzip -o vault.zip
mv -f vault /usr/local/bin
chmod 0755 /usr/local/bin/vault
chown root:root /usr/local/bin/vault

# Install StatsD Exporter
curl -L "https://github.com/prometheus/statsd_exporter/releases/download/0.2.0/statsd_exporter-0.2.0.linux-amd64.tar.gz" > statsd-exporter.tar.gz
echo "Installing StatsD Exporter..."
tar -zxf /tmp/statsd-exporter.tar.gz
mv -f statsd_exporter /usr/local/bin/statsd_exporter

# Setup the configuration
### Need to get the IP of the host, and trim the trailing space
MY_IP=`hostname -I | sed -e 's/[[:space:]]//'`
VAULT_ADVERTISE_ADDR="\$${MY_IP}:8200"
#VAULT_ADVERTISE_ADDR="${vault-address}"
cat <<EOF >/tmp/vault-config
${config}
EOF
mv -f /tmp/vault-config /usr/local/etc/vault-config.json

# Setup the init script
cat <<EOF >/tmp/upstart
description "Vault server"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

script
  if [ -f "/etc/service/vault" ]; then
    . /etc/service/vault
  fi

  # Make sure to use all our CPUs, because Vault can block a scheduler thread
  export GOMAXPROCS=`nproc`

  exec /usr/local/bin/vault server \
    -config="/usr/local/etc/vault-config.json" \
    \$${VAULT_FLAGS} \
    >>/var/log/vault.log 2>&1
end script

pre-stop script
  curl "http://localhost:8500/v1/agent/service/deregister/vault:`uname -n`"
end script
EOF
mv -f /tmp/upstart /etc/init/vault.conf

# Setup statsd init script
cat <<EOF >>/tmp/upstart-statsd
description "Starting StatsD Exporter"

start on started vault
stop on stopped vault

task

script
  if [ -f "/etc/service/statsd-exporter" ]; then
    . /etc/service/statsd-exporter
  fi

  set +e

  # Start statsd_exporter
  /usr/local/bin/statsd_exporter \
    -statsd.listen-address=":9125" \
    -statsd.mapping-config="" \
    -web.listen-address=":9102" \
    -web.telemetry-path="/prometheus" \
    >>/var/log/statsd-exporter.log 2>&1

  logger -t "statsd-exporter" "StatsD Exporter started!"
end script
EOF
mv -f /tmp/upstart-statsd /etc/init/statsd.conf

# Setup statsd registration init script
cat <<EOF > /tmp/statsd-exporter-reg
{
  "ID": "statsd_exporter:`uname -n`",
  "Name": "statsd_exporter",
  "Port": 9102,
  "Check": {
    "HTTP": "http://localhost:9102/prometheus",
    "Interval": "15s"
  }
}
EOF

cat <<EOF >>/tmp/upstart-statsd-register
description "Join StatsD Exporter with the consul cluster"

start on started vault
stop on stopped vault

task

script
  if [ -f "/etc/service/statsd-exporter-register" ]; then
    . /etc/service/statsd-exporter-register
  fi

  set +e

  # Once Consul is up and running, try registering the service:
  # Keep trying to join until it succeeds
  while :; do
    logger -t "statsd-exporter-register" "Attempting to register with Consul agent..."
    response=\$$(curl --silent --write-out "\n%{http_code}\n" -X PUT http://localhost:8500/v1/agent/service/register -d @/tmp/statsd-exporter-reg)
    status_code=\$$(echo "\$$response" | sed -n '\$$p')
    #  >>/var/log/statsd-exporter-consul-registration.log 2>&1
    logger -t "statsd-exporter-register" "Consul registration status: \$${status_code}"
    [ \$$status_code -eq 200 ] && break
    sleep 5
  done

  logger -t "statsd-exporter-register" "Join success!"
end script

pre-stop script
  curl "http://localhost:8500/v1/agent/service/deregister/statsd_exporter:`uname -n`"
end script
EOF
mv -f /tmp/upstart-statsd-register /etc/init/statsd-register.conf

# Consul Local Agent Install
${consul-install}

# Extra install steps (if any)
${extra-install}

# Start Vault
start vault

tmpfile=\$$( mktemp )

cat <<EOF > \$$tmpfile
{
    "ID": "vault:`uname -n`",
    "Name": "vault",
    "Port": 8200,
    "Check": {
        "HTTP": "http://\$${MY_IP}:8200/v1/sys/health?standbyok=true",
        "Interval": "15s"
    }
}
EOF

curl -X PUT http://localhost:8500/v1/agent/service/register -d @\$$tmpfile

rm -f \$$tmpfile
