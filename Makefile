
ORG:=chao123# your org name
BUILD_PRE:=xpp

help: ## Show this help menu.
	@grep -E '^[a-zA-Z_%-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

versions: ## Print the "imporant" tools versions out for easier debugging.
	@echo "=== BEGIN Version Info ==="
	@echo "=== END Version Info ==="


image:
	# @cp $(VPPDEV_FILE) $(IMAGE_DIR)
	# docker build ${SQUASH} --pull --network=host \
	# 	--build-arg http_proxy=${DOCKER_BUILD_PROXY} \
	# 	--build-arg WITH_GDB=${WITH_GDB} \
	# 	-t $(ORG)/$(BUILD_PRE):$(TAG) $(IMAGE_DIR)

xpp: clone-xpp clean-xpp xpp-build-env
	docker run --rm \
		-e APP_BUILD_DIR=$(CURDIR) \
		-v $(CURDIR):$(CURDIR):delegated \
		--network=host \
		$(ORG)/$(BUILD_PRE)-build:latest

clone-xpp:
	# bash $(VPPLINK_DIR)/generated/vpp_clone_current.sh ./vpp_build

clean: clean-xpp

clean-xpp:
	# git -C vpp_build clean -ffdx || true
	# rm -f ./vpp_build/build-root/*.deb
	# rm -f ./vpp_build/build-root/*.buildinfo
	# rm -f $(IMAGE_DIR)/*.deb

rebuild-xpp: xpp-build-env
	docker run --rm \
		-e APP_BUILD_DIR=$(CURDIR) \
		-v $(CURDIR):$(CURDIR):delegated \
		--env NO_BUILD_DEBS=true \
		--network=host \
		$(ORG)/$(BUILD_PRE)-build:latest

xpp-build-env: ## docker image for build $(BUILD_PRE) application.
	docker build --network=host \
		--build-arg http_proxy=${DOCKER_BUILD_PROXY} \
		-t $(ORG)/$(BUILD_PRE)-build:latest .

xpp-build-env-dbg: ## debug 
	docker run --rm \
		-e APP_BUILD_DIR=$(CURDIR) \
		-v $(CURDIR):$(CURDIR):delegated \
		--network=host \
		-it \
		$(ORG)/$(BUILD_PRE)-build:latest /bin/bash

pull: ## pull the new built image to registry.
	docker push $(ORG)/$(BUILD_PRE)-build:latest

.PHONY: help versions image clean all