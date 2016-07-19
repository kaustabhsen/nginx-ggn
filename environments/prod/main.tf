module "vault" {
  source = "../../../modules/vault/"
  region = "us-west-2"
  environment_name = "prod"
  vault-url = "https://vault.infra.us-west2egeprod.local"

  elb_ssl_certificate_id = "arn:aws:iam::059453199592:server-certificate/vault.us-west2.egeprod.local"
  aws_route_53_zone_id = "Z37WXJWAMCYTTW"

  core_remote_state_bucket_key = "/infra/prod/us-west-2.tfstate"
  core_remote_state_bucket_name = "egencia-tf-prod"

  consul_remote_state_bucket_key = "/infra/prod/consul/us-west-2.tfstate"
  consul_remote_state_bucket_name = "egencia-tf-prod"

  key_name = "us-west-2-prod"
  key_path = "~/.ssh/us-west-2-prod_decrypted"

  account_ids = "059453199592"
}
