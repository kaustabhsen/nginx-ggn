resource "null_resource" "server" {

    count = "${var.servers}"

    connection {
        user = "${var.user}"
        host = "${element(split(",", var.vault_servers), count.index)}"
        type = "ssh"
        port = "22"
        private_key = "${file("${var.key_path}")}"
        agent = false
    }

    provisioner "file" {
            content = "${template_file.install.rendered}"
            destination = "/tmp/install.sh"
    }

    provisioner "file" {
            content = "${template_file.config.rendered}"
            destination = "/tmp/config"
    }

    provisioner "file" {
            content = "${template_file.consul.rendered}"
            destination = "/tmp/consul-install.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo chmod +x /tmp/install.sh && sudo chmod +x /tmp/consul-install.sh",
            "sudo /tmp/install.sh",

        ]
    }
}
