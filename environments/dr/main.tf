module "vault" {
  source = "../../modules/vault/"
  region = "dr"
  environment_name = "dr"
  vault-url = "10.205.245.11"
  servers = 2
  vault_servers = "10.205.245.11,10.205.245.13"
  consul_server = "10.205.245.9"
  user = "vault"
  key_path = "vault.key"
}
