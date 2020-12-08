
docker-wireguard-client: docker-wireguard
	docker rm -f wireguard-client || true
	docker run --net=host --privileged --cap-add NET_ADMIN --cap-add SYS_MODULE --sysctl net.ipv6.conf.all.disable_ipv6=0 -e WIREGUARD_SERVER_IP=${WIREGUARD_SERVER_IP} -v $(PWD)/tmp/wg0.conf:/etc/wireguard/wg0.conf \
wireguard:local

docker-wireguard:
	docker build -f Dockerfile -t wireguard:local .
