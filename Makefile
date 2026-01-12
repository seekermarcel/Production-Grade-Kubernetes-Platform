CLUSTER_NAME ?= platform

.PHONY: kind-up kind-down bootstrap

kind-up:
	CLUSTER_NAME=$(CLUSTER_NAME) ./scripts/kind-up.sh

kind-down:
	CLUSTER_NAME=$(CLUSTER_NAME) ./scripts/kind-down.sh

bootstrap:
	cd platform/bootstrap && helmfile apply
