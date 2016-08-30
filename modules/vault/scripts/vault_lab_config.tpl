backend "consul" {
    address = "127.0.0.1:8500"
    path = "vault"
    advertise_addr = "http://\$${VAULT_ADVERTISE_ADDR}"
	scheme = "http"
}

listener "tcp" {
    address = "127.0.0.1:8200"
    tls_disable = 1
}

listener "tcp" {
    address = "\$${MY_IP}:8200"
    tls_disable = 1
}

telemetry {
   statsd_address = "127.0.0.1:9125"
}
