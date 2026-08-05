# devbox — build interface.
# Day-to-day you use the `devbox` launcher (bin/devbox); this Makefile just
# builds the image. Build context is this directory; the nvim config is cloned
# from the dotfiles repo at build time, so the context stays tiny.

IMAGE         ?= devbox:latest
DOTFILES_REPO ?= https://github.com/e-lopezc/dotfiles.git
DOTFILES_REF  ?= main

USER_UID := $(shell id -u)
USER_GID := $(shell id -g)
# Bust the clone/bake layer only when the dotfiles ref actually moves.
CACHEBUST := $(shell git ls-remote $(DOTFILES_REPO) $(DOTFILES_REF) 2>/dev/null | cut -f1)

BUILD_ARGS := \
  --build-arg USER_UID=$(USER_UID) \
  --build-arg USER_GID=$(USER_GID) \
  --build-arg DOTFILES_REPO=$(DOTFILES_REPO) \
  --build-arg DOTFILES_REF=$(DOTFILES_REF) \
  --build-arg DOTFILES_CACHEBUST=$(CACHEBUST)

.DEFAULT_GOAL := help

.PHONY: help build rebuild shell clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-9s\033[0m %s\n", $$1, $$2}'

build: ## Build the image for this machine's arch
	docker build $(BUILD_ARGS) -t $(IMAGE) .

rebuild: ## Rebuild from scratch (no layer cache)
	docker build --no-cache $(BUILD_ARGS) -t $(IMAGE) .

shell: ## Open a shell in the container ($PWD -> /workspace)
	./bin/devbox

clean: ## Remove the image and cache volumes
	-docker image rm $(IMAGE)
	-docker volume rm devbox-hist devbox-uv-cache
