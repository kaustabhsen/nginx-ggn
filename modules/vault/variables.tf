//-------------------------------------------------------------------
// Vault settings
//-------------------------------------------------------------------

variable "download-url" {
    default = "https://releases.hashicorp.com/vault/0.6.0/vault_0.6.0_linux_amd64.zip"
    description = "URL to download Vault"
}

//variable "config" {
//    default = ""
//    description = "Configuration (text) for Vault"
//}

variable "extra-install" {
    default = ""
    description = "Extra commands to run in the install script"
}

variable "key_path" {
    description = "Path to the private key specified by key_name."
}

variable "region" {
    //    default = "us-west-2"
    description = "The region of AWS, for AMI lookups."
}

variable "environment_name" {
    description = "The environment of deployment, for example: lab, prod, pci"
}

variable "vault-url" {
    description = "The FQDN for Vault cluster in destination environment. for example: 'https://vault.infra.us-west2egelab.local'"
}

variable "consul_server" {
  description = "Consul server IP"
}

variable "vault_servers" {
  description = "Vault servers"
}

variable "servers" {
  description = "Number of servers"
}

variable "user" {
  description = "SSH user"
}
