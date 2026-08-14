# devbox — build interface.
# Day-to-day you use the `devbox` launcher (bin/devbox); this Makefile just
# builds the image. The build context is the repo root (one level up from
# this file) so the Dockerfile can COPY common/nvim directly — the image
# bakes your local checkout, not a cloned ref.

IMAGE ?= devbox:latest

MK_DIR  := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
CONTEXT := $(abspath $(MK_DIR)/..)

USER_UID := $(shell id -u)
USER_GID := $(shell id -g)

BUILD_ARGS := \
  --build-arg USER_UID=$(USER_UID) \
  --build-arg USER_GID=$(USER_GID)

.DEFAULT_GOAL := help

.PHONY: help build rebuild shell clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-9s\033[0m %s\n", $$1, $$2}'

build: ## Build the image for this machine's arch
	@if [ -n "$$(git -C $(CONTEXT) status --porcelain -- common/nvim 2>/dev/null)" ]; then \
	  echo "devbox: warning — common/nvim has uncommitted changes; the image will bake your working tree, not HEAD" >&2; \
	fi
	docker build $(BUILD_ARGS) -f $(MK_DIR)/Dockerfile -t $(IMAGE) $(CONTEXT)

rebuild: ## Rebuild from scratch (no layer cache)
	docker build --no-cache $(BUILD_ARGS) -f $(MK_DIR)/Dockerfile -t $(IMAGE) $(CONTEXT)

shell: ## Open a shell in the container ($PWD -> /workspace)
	$(MK_DIR)/bin/devbox

clean: ## Remove the image and cache volumes
	-docker image rm $(IMAGE)
	-docker volume rm devbox-hist devbox-uv-cache
