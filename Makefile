export AWS_PROFILE=${ENV}

setup:
		cd environments/${ENV}/${INF_REGION} && sh ../../../setup.sh

plan: setup
		cd environments/${ENV}/${INF_REGION} && terraform plan --module-depth=-1 ${ARGS}

apply:
		cd environments/${ENV}/${INF_REGION} && terraform remote pull
		cd environments/${ENV}/${INF_REGION} && terraform apply ${ARGS}
		cd environments/${ENV}/${INF_REGION} && terraform remote push

destroy:
		cd environments/${ENV}/${INF_REGION} && terraform remote pull
		cd environments/${ENV}/${INF_REGION} && terraform destroy ${ARGS}
		cd environments/${ENV}/${INF_REGION} && terraform remote push
