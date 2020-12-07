SERVER_INDEX?=0
PRIVATE_KEY_FILE?=./keys/wireguard.pem
TF_INIT_CLI_OPTIONS?="-input=true"
TF_PLAN_CLI_OPTIONS?="-input=true"
TF_APPLY_CLI_OPTIONS?="-input=true"
TF_DESTROY_CLI_OPTIONS?="-input=true"

init:
	terraform init ${TF_INIT_CLI_OPTIONS}

build:
	terraform validate
	terraform plan -out terraform.plan ${TF_PLAN_CLI_OPTIONS}

create: build
	terraform apply ${TF_APPLY_CLI_OPTIONS} terraform.plan

clean:
	terraform destroy ${TF_DESTROY_CLI_OPTIONS}

recreate: clean create

deploy: ssh-keygen init create

ssh-keygen:
	 ssh-keygen -t rsa -b 4096 -q -N "" -f ${PRIVATE_KEY_FILE} <<<n || true

pre-shell: #check if the wireguard virtual machine exists
	terraform state show -state=terraform.tfstate module.wireguard.data.aws_instances.wireguards

shell: pre-shell
	ssh -i "${PRIVATE_KEY_FILE}" -v ubuntu@$(shell terraform output -json wireguard_eip | jq -r ".[${SERVER_INDEX}]")

wireguard-public-key:
	@ssh -i "${PRIVATE_KEY_FILE}" ubuntu@$(shell terraform output -json wireguard_eip | jq -r ".[${SERVER_INDEX}]") sudo cat /tmp/server_privatekey
