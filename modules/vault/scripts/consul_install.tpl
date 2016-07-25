# consul version to install
CONSUL_VERSION=0.6.4

echo "Fetching Consul..."
cd /tmp
curl -L "https://releases.hashicorp.com/consul/\$${CONSUL_VERSION}/consul_\$${CONSUL_VERSION}_linux_amd64.zip" > consul.zip
# Install Consul-UI as well
curl -L "https://releases.hashicorp.com/consul/\$${CONSUL_VERSION}/consul_\$${CONSUL_VERSION}_web_ui.zip" > consul-ui.zip

echo "Installing Consul..."
unzip -o consul.zip >/dev/null
chmod +x consul
mv -f consul /usr/local/bin/consul

mkdir -p /etc/consul.d
mkdir -p /mnt/consul
mkdir -p /etc/service

# Setup the init script
cat <<EOF >/tmp/consul_upstart
description "Consul agent"

start on runlevel [2345]
stop on runlevel [!2345]

respawn
# This is to avoid Upstart re-spawning the process upon 'consul leave'
normal exit 0 INT

script
  if [ -f "/etc/service/consul" ]; then
    . /etc/service/consul
  fi

  # Get the public IP
  #BIND=`ifconfig eth0 | grep 'inet addr' | awk '{ print substr(\$2,6) }'`
  BIND=`ip addr sho eth0 | grep -Po 'inet \K[\d.]+'`

  # Make sure to use all our CPUs, because Consul can block a scheduler thread
  export GOMAXPROCS=`nproc`

  exec /usr/local/bin/consul agent \
    -data-dir="/mnt/consul" \
    -config-dir="/etc/consul.d" \
    -bind=\$${BIND} \
    -client=0.0.0.0 \
    -join=${consul-join-address} \
    -dc=${consul-join-dc} \
    >>/var/log/consul.log 2>&1
end script

pre-stop script
  exec /usr/local/bin/consul leave
end script
EOF
mv -f /tmp/consul_upstart /etc/init/consul_agent.conf

start consul_agent
