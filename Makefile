

shell:
	ssh -i "~/.ssh/development.pem" -vvvv ubuntu@$(shell pulumi stack output publicDns)
