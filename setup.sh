if [ ! -f ".terraform/terraform.tfstate" ];
then
  terraform remote config \
    -backend=s3 \
    -backend-config="region=us-east-1" \
    -backend-config="bucket=egencia-tf-${ENV}" \
    -backend-config="key=infra/${ENV}/vault/${INF_REGION}.tfstate"
fi;

terraform get
