SERVER_INDEX?=0
PRIVATE_KEY_FILE?=./keys/wireguard.pem
TF_INIT_CLI_OPTIONS?="-input=true"
TF_PLAN_CLI_OPTIONS?="-input=true"
TF_APPLY_CLI_OPTIONS?="-input=true"
TF_DESTROY_CLI_OPTIONS?="-input=true"
TMP_FOLDER?="./tmp"

init:
	terraform init ${TF_INIT_CLI_OPTIONS}

build:
	terraform validate
	terraform plan -out terraform.plan ${TF_PLAN_CLI_OPTIONS}

create: build
	terraform apply ${TF_APPLY_CLI_OPTIONS} terraform.plan

clean:
	terraform destroy ${TF_DESTROY_CLI_OPTIONS}
	rm -rfv ./tmp

recreate: clean create

deploy: ssh-keygen init create

ssh-keygen:
	echo -e 'n\n' | ssh-keygen -t rsa -b 4096 -q -N "" -f ${PRIVATE_KEY_FILE} || true

pre-shell: #check if the wireguard virtual machine exists
	terraform state show -state=terraform.tfstate module.wireguard.data.aws_instances.wireguards

shell: pre-shell
	ssh -i "${PRIVATE_KEY_FILE}" -v ubuntu@$(shell terraform output -json wireguard_eip | jq -r ".[${SERVER_INDEX}]")

prepare:
	mkdir -p ./tmp

wireguard-client-keys: prepare
	wg genkey | tee ${TMP_FOLDER}/client_privatekey | wg pubkey > ${TMP_FOLDER}/client_publickey

wireguard-public-key: prepare
	mkdir -p ./tmp
	@ssh -i "${PRIVATE_KEY_FILE}" -o "StrictHostKeyChecking no" ubuntu@$(shell terraform output -json wireguard_eip | jq -r ".[${SERVER_INDEX}]") 'sudo cat /var/log/cloud-init-output.log'
	@ssh -i "${PRIVATE_KEY_FILE}" -o "StrictHostKeyChecking no" ubuntu@$(shell terraform output -json wireguard_eip | jq -r ".[${SERVER_INDEX}]") 'sudo cat /tmp/server_publickey' > ${TMP_FOLDER}/server_publickey

test: wireguard-public-key
	curl ipinfo.io/ip
	./scripts/wireguard-client-cfg.sh
	sudo wg-quick up ./tmp/wg0.conf
	sleep 30
	curl ipinfo.io/ip
	./scripts/wireguard-connection-validation.sh
