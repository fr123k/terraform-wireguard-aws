WIREGUARD_SERVER_IP=$(shell terraform output -json wireguard_eips | jq -r ".[${SERVER_INDEX}]")

SERVER_INDEX?=0
PRIVATE_KEY_FILE?=./keys/wireguard.pem
TF_INIT_CLI_OPTIONS?="-input=true"
TF_PLAN_CLI_OPTIONS?="-input=true"
TF_APPLY_CLI_OPTIONS?="-input=true"
TF_DESTROY_CLI_OPTIONS?="-input=true"
TMP_FOLDER?="./test/tmp"

init:
	terraform init ${TF_INIT_CLI_OPTIONS}

ssh-keygen:
	echo -e 'n\n' | ssh-keygen -t rsa -b 4096 -q -N "" -f ${PRIVATE_KEY_FILE} || true

build: ssh-keygen
	terraform validate
	terraform plan -out terraform.plan ${TF_PLAN_CLI_OPTIONS}

create: build
	terraform apply ${TF_APPLY_CLI_OPTIONS} terraform.plan

clean:
	terraform destroy ${TF_DESTROY_CLI_OPTIONS}
	rm -rfv ./tmp

recreate: clean create

deploy: init create

travis: deploy
	sleep 120

pre-shell: #check if the wireguard virtual machine exists
	terraform state show -state=terraform.tfstate module.wireguard.data.aws_instances.wireguards

shell: pre-shell
	ssh -i "${PRIVATE_KEY_FILE}" -v ubuntu@${WIREGUARD_SERVER_IP}

prepare:
	mkdir -p ${TMP_FOLDER}

wireguard-client-keys: prepare
	wg genkey | tee ${TMP_FOLDER}/client_privatekey | wg pubkey > ${TMP_FOLDER}/client_publickey

wireguard-public-key: prepare pre-shell
	@ssh -i "${PRIVATE_KEY_FILE}" -o "StrictHostKeyChecking no" ubuntu@${WIREGUARD_SERVER_IP} 'sudo cat /var/log/cloud-init-output.log'
	@ssh -i "${PRIVATE_KEY_FILE}" -o "StrictHostKeyChecking no" ubuntu@${WIREGUARD_SERVER_IP} 'sudo cat /tmp/server_publickey' > ${TMP_FOLDER}/server_publickey

validate: wireguard-public-key
	$(MAKE) -C test -e WIREGUARD_SERVER_IP=${WIREGUARD_SERVER_IP} -e TMP_FOLDER=${TMP_FOLDER} wireguard-client
