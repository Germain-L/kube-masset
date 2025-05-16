APP_NAME := gestion-produits
REGISTRY := registry.germainleignel.com/library
TAG ?= latest

.PHONY: all build tag push deploy run

all: build

build:
	docker build -t $(APP_NAME):$(TAG) .

tag:
	docker tag $(APP_NAME):$(TAG) $(REGISTRY)/$(APP_NAME):$(TAG)

push:
	docker push $(REGISTRY)/$(APP_NAME):$(TAG)

deploy: build tag push