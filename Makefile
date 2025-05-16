APP_NAME := gestion-produits
REGISTRY := registry.germainleignel.com/library
TAG ?= latest

.PHONY: all build tag push deploy run dev-up dev-down dev-build dev-logs dev-shell dev-db-shell dev-clean dev-test help dev-migrate

all: build

build:
	docker build -t $(APP_NAME):$(TAG) .

tag:
	docker tag $(APP_NAME):$(TAG) $(REGISTRY)/$(APP_NAME):$(TAG)

push:
	docker push $(REGISTRY)/$(APP_NAME):$(TAG)

deploy: build tag push

# Development commands
help:
	@echo "Available targets:"
	@echo "  build     - Build production image"
	@echo "  tag       - Tag the image for registry"
	@echo "  push      - Push image to registry"
	@echo "  deploy    - Build, tag and push"
	@echo "  dev-up    - Start development environment"
	@echo "  dev-down  - Stop development environment"
	@echo "  dev-build - Rebuild development containers"
	@echo "  dev-logs  - View development container logs"
	@echo "  dev-shell - Get a shell in the web container"
	@echo "  dev-db-shell - Get a MySQL shell in the database container"
	@echo "  dev-clean - Remove development containers and volumes"
	@echo "  dev-test  - Test the development environment"
	@echo "  dev-migrate - Run database migrations"

# Start dev containers
dev-up:
	docker-compose up -d

# Stop dev containers
dev-down:
	docker-compose down

# Build dev containers
dev-build:
	docker-compose build

# View dev logs
dev-logs:
	docker-compose logs -f

# Get a shell in the web container
dev-shell:
	docker-compose exec web bash || docker-compose exec web sh

# Get a MySQL shell in the database container
dev-db-shell:
	docker-compose exec db mysql -u$$(grep DB_USER .env | cut -d= -f2) -p$$(grep DB_PASSWORD .env | cut -d= -f2) $$(grep DB_NAME .env | cut -d= -f2)

# Remove containers, volumes, and orphaned images
dev-clean:
	docker-compose down -v --remove-orphans

# Run test page
dev-test:
	@echo "Testing database connection..."
	@echo "Visit http://localhost:$$(grep -v '^#' .env | grep WEB_PORT | cut -d= -f2 || echo 8080)/env_test.php"

# Run database migrations
dev-migrate:
	docker-compose up --build migration