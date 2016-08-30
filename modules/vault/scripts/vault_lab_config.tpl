backend "consul" {
    address = "127.0.0.1:8500"
    path = "vault"
    advertise_addr = "https://\$${VAULT_ADVERTISE_ADDR}"
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
