setup:
	cd environments/${ENV}/ && sh ../../setup.sh

plan: setup
		cd environments/${ENV}/ && terraform plan --module-depth=-1 ${ARGS}

apply:
		cd environments/${ENV}/ && terraform apply ${ARGS}
