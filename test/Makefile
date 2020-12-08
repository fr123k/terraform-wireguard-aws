TMP_FOLDER?="./test/tmp"

wireguard-client:
	mkdir -p ${TMP_FOLDER}
	./scripts/wireguard-client-cfg.sh
	cat ./tmp/wg0.conf

docker-wireguard-client: docker-wireguard wireguard-client
	curl ipinfo.io/ip
	docker run --privileged --cap-add NET_ADMIN --cap-add SYS_MODULE -e WIREGUARD_SERVER_IP=${WIREGUARD_SERVER_IP} -v $(PWD)/test/tmp/wg0.conf:/etc/wireguard/wg0.conf \
wireguard:local

docker-wireguard:
	docker build -f Dockerfile -t wireguard:local .
