# A simple NVIDIA Deepstream 5 example for open-horizon

SERVICE_NAME:="deepstream-open-horizon"
SERVICE_VERSION:="1.0.0"

# Get the Open-Horizon architecture type, and IP address for this host
ARCH:=$(shell ./helper -a)

run: validate-rtspinput clean
	@echo "\n\n"
	@echo "***   Using RTSP input URI: $(RTSPINPUT)"
	@echo "***   Output stream URI is: rtsp://localhost:8554/ds-test"
	@echo "\n\n"
	#docker run -d --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 -p 8554:8554 $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION)
	docker run -d \
	  --name ${SERVICE_NAME} \
	  -e RTSPINPUT=${RTSPINPUT} \
	  -p 8554:8554 \
	  $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION)

dev: validate-rtspinput clean
	docker run -it -v `pwd`:/outside \
	  --name ${SERVICE_NAME} \
	  -p 8554:8554 \
	  -e RTSPINPUT=${RTSPINPUT} \
	  $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) /bin/bash

build: validate-dockerhubid
	docker build -t $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) .

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

validate-rtspinput:
	@if [ -z "${DOCKERHUB_ID}" ]; \
          then { echo "***** ERROR: \"DOCKERHUB_ID\" is not set!"; exit 1; }; \
          else echo "  NOTE: Using DockerHubID: \"${DOCKERHUB_ID}\""; \
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
