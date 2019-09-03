images: envoy-qat envoy-qat-clr envoy-boringssl-qat intel-qat-plugin

envoy-qat:
	docker image build -t envoy-qat:devel -f Dockerfile.envoy . --no-cache

envoy-qat-clr:
	docker image build -t envoy-qat-clr:devel -f Dockerfile.clr.envoy . --no-cache

envoy-boringssl-qat:
	docker image build -t envoy-boringssl-qat:devel -f Dockerfile-boringssl-envoy .  --no-cache

intel-qat-plugin:
	cd ./intel-device-plugins-for-kubernetes && make intel-qat-plugin
