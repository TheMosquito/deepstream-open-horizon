# A simple NVIDIA Deepstream 5 example for open-horizon

# An example public RTSP stream you can use for development:
#  export RTSPINPUT=rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov

SERVICE_NAME:="deepstream-open-horizon"
SERVICE_VERSION:="1.0.0"

# Get the Open-Horizon architecture type, and IP address for this host
ARCH:=$(shell ./helper -a)
IPADDR:=$(shell ./helper -i)

# Different base images for different hardware architectures:
BASE_IMAGE.aarch64:=nvcr.io/nvidia/deepstream-l4t:5.0-dp-20.04-samples
BASE_IMAGE.amd64:=nvcr.io/nvidia/deepstream:5.0-dp-20.04-triton

run: validate-rtspinput clean
	@echo "\n\n"
	@echo "***   Using RTSP input URI: $(RTSPINPUT)"
	@echo "***   Output stream URI is: rtsp://$(IPADDR):8554/ds"
	@echo "\n\n"
	# Optional: --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864
	docker run -d \
	  --name ${SERVICE_NAME} \
	  -e RTSPINPUT=${RTSPINPUT} \
	  -e ARCH=$(ARCH) \
	  -e IPADDR=$(IPADDR) \
	  -p 8554:8554 \
	  $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION)

dev: validate-rtspinput clean
	# Optional: --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864
	docker run -it -v `pwd`:/outside \
	  --name ${SERVICE_NAME} \
	  -e RTSPINPUT=${RTSPINPUT} \
	  -e ARCH=$(ARCH) \
	  -e IPADDR=$(IPADDR) \
	  -p 8554:8554 \
	  $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) /bin/bash

build: validate-dockerhubid validate-python-binding
	docker build --build-arg BASE_IMAGE=$(BASE_IMAGE.$(ARCH)) -t $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) .

push: validate-dockerhubid
	docker push $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) 

clean: validate-dockerhubid
	@docker rm -f ${SERVICE_NAME} >/dev/null 2>&1 || :

#
# Targets to publish service/pattern to an Open-Horizon Exhange, and to register
#
# NOTE: You must install the Open-Horizon CLI in order to use these targets!
#

publish-service: validate-dockerhubid validate-org
	ARCH=$(ARCH) \
          HZN_ORG_ID="$(HZN_ORG_ID)" \
          SERVICE_NAME="$(SERVICE_NAME)" \
          SERVICE_VERSION="$(SERVICE_VERSION)"\
          DOCKER_IMAGE_BASE="$(DOCKERHUB_ID)/$(SERVICE_NAME)"\
          hzn exchange service publish -O -f service.json --pull-image

publish-pattern: validate-org
	ARCH=$(ARCH) \
          HZN_ORG_ID="$(HZN_ORG_ID)" \
          SERVICE_NAME="$(SERVICE_NAME)" \
          SERVICE_VERSION="$(SERVICE_VERSION)"\
          DOCKER_IMAGE_BASE="$(DOCKERHUB_ID)/$(SERVICE_NAME)"\
	  hzn exchange pattern publish -f pattern.json

register-pattern: validate-org
	HZN_ORG_ID="$(HZN_ORG_ID)" \
          SERVICE_NAME="$(SERVICE_NAME)" \
	  RTSPINPUT="$(RTSPINPUT)" \
	  hzn register --pattern "${HZN_ORG_ID}/pattern-deepstream" --input-file ./input-file.json

#
# Sanity check targets
#


validate-python-binding:
	@if [ "" = "$(wildcard deepstream_python_v*.tbz2)" ]; \
	  then { echo "***** ERROR: First download the Deepstream Python bindings into this directory!"; echo "*****        USE this URL:  https://developer.nvidia.com/deepstream_python_v0.5"; exit 1; }; \
        fi
	@sleep 1

validate-rtspinput:
	@if [ -z "${RTSPINPUT}" ]; \
          then { echo "***** ERROR: \"RTSPINPUT\" is not set!"; exit 1; }; \
          else echo "  NOTE: Using RTSP input stream: \"${RTSPINPUT}\""; \
        fi
	@sleep 1

validate-dockerhubid:
	@if [ -z "${DOCKERHUB_ID}" ]; \
          then { echo "***** ERROR: \"DOCKERHUB_ID\" is not set!"; exit 1; }; \
          else echo "  NOTE: Using DockerHubID: \"${DOCKERHUB_ID}\""; \
        fi
	@sleep 1

validate-org:
	@if [ -z "${HZN_ORG_ID}" ]; \
          then { echo "***** ERROR: \"HZN_ORG_ID\" is not set!"; exit 1; }; \
          else echo "  NOTE: Using Exchange Org ID: \"${HZN_ORG_ID}\""; \
        fi
	@sleep 1


.PHONY: build run dev push clean publish-service publish-pattern validate-dockerhubid validate-org
