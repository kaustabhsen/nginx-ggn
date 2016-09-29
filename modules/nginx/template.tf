resource "template_file" "config" {
    template = "${file("${path.module}/scripts/vault_lab_config.tpl")}"
 }

resource "template_file" "consul" {
    template = "${file("${path.module}/scripts/consul_install.tpl")}"

    vars {
        environment-name = "${var.environment_name}"
        region-name = "${var.region}"
        consul-join-address = "${var.consul_server}"
        consul-join-dc = "${var.environment_name}"
    }
}

resource "template_file" "install" {
    template = "${file("${path.module}/scripts/install.sh.tpl")}"

    vars {
        download-url  = "${var.download-url}"
        config        = "${template_file.config.rendered}"
        consul-install = "${template_file.consul.rendered}"
        extra-install = "${var.extra-install}"
        vault-address = "${var.vault-url}"
    }
}
