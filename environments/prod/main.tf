module "vault" {
  source = "../../modules/vault/"
  region = "prod"
  environment_name = "prod"
  vault-url = "http://localhost"
  servers = 2
  vault_servers = "10.178.169.177,10.178.169.176"
  consul_server = "10.178.169.174"
  user = "vault"
  key_path = "vault.key"
}
