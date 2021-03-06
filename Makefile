#VER='1.0'

CHART_NAME=$(shell cat mychart/Chart.yaml | yq -r .name)
CHART_VERSION=$(shell cat mychart/Chart.yaml | yq -r .version)

APP_VERSION ?= $(shell cat mychart/values.yaml | yq -r .image.tag)

#CHART_BUCKET ?= spin-helm-demo-bucket
DOCKER_REPO ?= away168/mysite
SPINNAKER_API ?= https://away-gate.armory-dev.armory.io

docker:
	docker build -t $(DOCKER_REPO):$(APP_VERSION) .
	docker tag $(DOCKER_REPO):$(APP_VERSION) $(DOCKER_REPO):latest

dockerpush: docker
	docker push $(DOCKER_REPO):$(APP_VERSION)
	docker push $(DOCKER_REPO):latest

compile:
	helm package mychart

#upload:
#	aws s3 cp $(CHART_NAME)-$(CHART_VERSION).tgz s3://$(CHART_BUCKET)/packages/
#	aws s3 cp values/dev.yaml s3://$(CHART_BUCKET)/packagevalues/$(CHART_NAME)/dev.yaml
#	aws s3 cp values/prod.yaml s3://$(CHART_BUCKET)/packagevalues/$(CHART_NAME)/prod.yaml

trigger:
	curl -L -vvv -X POST \
		-k \
		-H"Content-Type: application/json" $(SPINNAKER_API)/webhooks/webhook/websiteviahelm 
#		\	-d '{"artifacts": [{"type": "docker/image", "name": "$(CHART_NAME)", "reference": "$(DOCKER_REPO):$(APP_VERSION)", "kind": "docker"}]}'

#triggerchart:
#	curl -L -vvv -X POST \
		-k \
		-H"Content-Type: application/json" $(SPINNAKER_API)/webhooks/webhook/spinhelmdemo \
		-d '{"artifacts": [{"type": "s3/object", "name": "s3://$(CHART_BUCKET)/packages/spin-helm-demo-0.1.0.tgz", "reference": "s3://$(CHART_BUCKET)/packages/spin-helm-demo-$(CHART_VERSION).tgz", "kind": "s3"}]}'