export WIREGUARD_SERVER_IP=$(shell terraform output -json wireguard_eip | jq -r ".[${SERVER_INDEX}]")

SERVER_INDEX?=0
PRIVATE_KEY_FILE?=./keys/wireguard.pem
TF_INIT_CLI_OPTIONS?="-input=true"
TF_PLAN_CLI_OPTIONS?="-input=true"
TF_APPLY_CLI_OPTIONS?="-input=true"
TF_DESTROY_CLI_OPTIONS?="-input=true"
TMP_FOLDER?="./test/tmp"

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
	mkdir -p ${TMP_FOLDER}

wireguard-client-keys: prepare
	wg genkey | tee ${TMP_FOLDER}/client_privatekey | wg pubkey > ${TMP_FOLDER}/client_publickey

wireguard-public-key: prepare
	@ssh -i "${PRIVATE_KEY_FILE}" -o "StrictHostKeyChecking no" ubuntu@${WIREGUARD_SERVER_IP} 'sudo cat /var/log/cloud-init-output.log'
	@ssh -i "${PRIVATE_KEY_FILE}" -o "StrictHostKeyChecking no" ubuntu@${WIREGUARD_SERVER_IP} 'sudo cat /tmp/server_publickey' > ${TMP_FOLDER}/server_publickey

validate: wireguard-public-key
	$(MAKE) -C test -e WIREGUARD_SERVER_IP=${WIREGUARD_SERVER_IP} -e TMP_FOLDER=${TMP_FOLDER} docker-wireguard-client

docker-wireguard-client:
	docker run --privileged --restart=always --name wireguard-client --cap-add NET_ADMIN --cap-add SYS_MODULE --sysctl net.ipv6.conf.all.disable_ipv6=0 -e WATCH_CHANGES=1 -v $(PWD)/tmp/wg0.conf:/etc/wireguard/wg0.conf \
cmulk/wireguard-docker:alpine

docker-wireguard:
	docker build -f test/Dockerfile -t wireguard:local .
