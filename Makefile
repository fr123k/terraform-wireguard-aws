SERVER_INDEX?=0
PRIVATE_KEY_FILE~=

build:
	terraform validate
	terraform plan -out terraform.plan

create: build
	terraform apply terraform.plan

clean:
	terraform destroy

recreate: clean create

pre-shell: #check if the wireguard virtual machine exists
	terraform state show -state=terraform.tfstate module.wireguard.data.aws_instances.wireguards

shell: pre-shell
	ssh -i "~/.ssh/wireguard.pem" -v ubuntu@$(shell terraform output -json wireguard_eip | jq -r ".[${SERVER_INDEX}]")
