# syntax=docker/dockerfile:1
#
# devbox — a portable DevOps/SRE tool image.
# Built per machine (see Makefile); carries the toolchain so the host OS does not
# matter. Runs on linux/amd64 and linux/arm64 — every download resolves its arch
# at build time. NO credentials are baked in; secrets are injected at launch by
# bin/devbox.

FROM debian:trixie-slim

# Match the invoking user's UID/GID so bind-mounted files aren't root-owned on
# Linux (the Makefile passes these). Harmless on macOS/OrbStack.
ARG USER_UID=1000
ARG USER_GID=1000
ARG USERNAME=dev

# Where the baked Neovim config comes from, and a cache-bust knob (see Makefile).
ARG DOTFILES_REPO=https://github.com/e-lopezc/dotfiles.git
ARG DOTFILES_REF=main
ARG DOTFILES_CACHEBUST=0

# Which Neovim channel to bake: "stable" or "nightly" (both are moving release tags).
ARG NVIM_RELEASE=stable

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    NVIM_CONTAINER=1 \
    UV_PYTHON_INSTALL_DIR=/opt/uv/python \
    UV_TOOL_DIR=/opt/uv/tools \
    UV_TOOL_BIN_DIR=/usr/local/bin \
    PATH=/usr/local/sbin:/usr/local/bin:/home/dev/.local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# --- base packages -----------------------------------------------------------
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg lsb-release \
        git openssh-client sudo less passwd adduser \
        bash-completion \
        ripgrep fzf tmux jq unzip tar xz-utils \
        python3 python3-pip python3-venv \
        bat \
        build-essential; \
    ln -sf /usr/bin/batcat /usr/local/bin/bat; \
    rm -rf /var/lib/apt/lists/*

# --- non-root user -----------------------------------------------------------
RUN set -eux; \
    groupadd --gid "${USER_GID}" "${USERNAME}" 2>/dev/null || true; \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USERNAME}"; \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/"${USERNAME}"; \
    chmod 0440 /etc/sudoers.d/"${USERNAME}"

# --- terraform (direct release binary — codename-independent, arch-aware) -----
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    TF_VER="$(curl -fsSL https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r '.current_version')"; \
    curl -fsSL -o /tmp/tf.zip "https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_${ARCH}.zip"; \
    unzip -o /tmp/tf.zip -d /usr/local/bin; \
    rm -f /tmp/tf.zip; \
    terraform version

# --- Node.js LTS (official tarball — codename-independent; needed by pyright) --
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in amd64) NODE_ARCH=x64 ;; arm64) NODE_ARCH=arm64 ;; *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;; esac; \
    NODE_VER="$(curl -fsSL https://nodejs.org/dist/index.json | jq -r '[.[] | select(.lts != false)][0].version')"; \
    curl -fsSL -o /tmp/node.tar.xz "https://nodejs.org/dist/${NODE_VER}/node-${NODE_VER}-linux-${NODE_ARCH}.tar.xz"; \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1; \
    rm -f /tmp/node.tar.xz; \
    node --version; npm --version

# --- Kubernetes / GitOps CLIs (arch-aware, latest) ---------------------------
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    # kubectl
    KVER="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"; \
    curl -fsSL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/${KVER}/bin/linux/${ARCH}/kubectl"; \
    chmod +x /usr/local/bin/kubectl; \
    # helm
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; \
    # kustomize (tags are prefixed "kustomize/vX"; resolve the latest via the API)
    KTAG="$(curl -fsSL https://api.github.com/repos/kubernetes-sigs/kustomize/releases | jq -r '[.[] | select(.tag_name | startswith("kustomize/"))][0].tag_name')"; \
    KVER2="${KTAG#kustomize/}"; \
    curl -fsSL -o /tmp/kustomize.tgz "https://github.com/kubernetes-sigs/kustomize/releases/download/${KTAG}/kustomize_${KVER2}_linux_${ARCH}.tar.gz"; \
    tar -xzf /tmp/kustomize.tgz -C /usr/local/bin kustomize; \
    rm -f /tmp/kustomize.tgz; \
    # flux
    curl -fsSL https://fluxcd.io/install.sh | bash; \
    # k9s
    curl -fsSL -o /tmp/k9s.tgz "https://github.com/derailed/k9s/releases/latest/download/k9s_linux_${ARCH}.tar.gz"; \
    tar -xzf /tmp/k9s.tgz -C /usr/local/bin k9s; \
    rm -f /tmp/k9s.tgz; \
    ( kubectl version --client; helm version; kustomize version; flux --version; k9s version ) || true

# --- AWS toolkit: awscli v2 + aws-vault (arch-aware) -------------------------
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    UNAME_M="$(uname -m)"; \
    curl -fsSL -o /tmp/awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-${UNAME_M}.zip"; \
    unzip -q /tmp/awscliv2.zip -d /tmp; \
    /tmp/aws/install; \
    rm -rf /tmp/awscliv2.zip /tmp/aws; \
    curl -fsSL -o /usr/local/bin/aws-vault "https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-${ARCH}"; \
    chmod +x /usr/local/bin/aws-vault; \
    aws --version; aws-vault --version

# --- GitHub CLI (apt repo — the "stable main" suite is codename-independent) --
RUN set -eux; \
    install -m 0755 -d /etc/apt/keyrings; \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /etc/apt/keyrings/githubcli.gpg; \
    chmod a+r /etc/apt/keyrings/githubcli.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends gh; \
    rm -rf /var/lib/apt/lists/*

# --- shell niceties: eza, zoxide, starship (arch-aware, latest) --------------
RUN set -eux; \
    UNAME_M="$(uname -m)"; \
    # eza
    curl -fsSL -o /tmp/eza.tgz "https://github.com/eza-community/eza/releases/latest/download/eza_${UNAME_M}-unknown-linux-gnu.tar.gz"; \
    tar -xzf /tmp/eza.tgz -C /usr/local/bin; \
    chmod +x /usr/local/bin/eza; \
    rm -f /tmp/eza.tgz; \
    # zoxide (installs to /usr/local/bin)
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash -s -- --bin-dir /usr/local/bin; \
    # starship
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir /usr/local/bin; \
    eza --version; zoxide --version; starship --version

# --- uv + managed Python 3.13 + ansible --------------------------------------
RUN set -eux; \
    curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin INSTALLER_NO_MODIFY_PATH=1 sh; \
    uv python install 3.13; \
    # expose the uv-managed 3.13 as `python` (system python3 stays for tooling)
    ln -sf "$(uv python find 3.13)" /usr/local/bin/python; \
    # ansible-core exposes the ansible/ansible-playbook/... CLIs; --with ansible
    # pulls in the full community collection bundle alongside them.
    uv tool install --python 3.13 --with ansible ansible-core; \
    chmod -R a+rX /opt/uv; \
    uv --version; ansible --version

# --- Neovim (recent release, arch-aware) -------------------------------------
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
        amd64) NV=x86_64 ;; \
        arm64) NV=arm64 ;; \
        *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/nvim.tgz "https://github.com/neovim/neovim/releases/download/${NVIM_RELEASE}/nvim-linux-${NV}.tar.gz"; \
    tar -xzf /tmp/nvim.tgz -C /opt; \
    ln -sf "/opt/nvim-linux-${NV}/bin/nvim" /usr/local/bin/nvim; \
    rm -f /tmp/nvim.tgz; \
    nvim --version | head -1

# --- baked shell config ------------------------------------------------------
COPY bashrc /home/dev/.bashrc
COPY starship.toml /home/dev/.config/starship.toml

# --- baked Neovim config (cloned from the public dotfiles repo) ---------------
# DOTFILES_CACHEBUST busts the layer cache so a new push is picked up.
RUN set -eux; \
    echo "cachebust=${DOTFILES_CACHEBUST}"; \
    git clone --depth 1 --branch "${DOTFILES_REF}" "${DOTFILES_REPO}" /tmp/dotfiles; \
    mkdir -p /home/dev/.config; \
    cp -r /tmp/dotfiles/common/nvim /home/dev/.config/nvim; \
    rm -rf /tmp/dotfiles

COPY bake.lua /opt/devbox/bake.lua

RUN chown -R "${USER_UID}:${USER_GID}" /home/dev /opt/uv

# --- pre-bake nvim plugins + LSP servers + treesitter parsers (as dev) --------
# Runs headless with NVIM_CONTAINER=1 so obsidian/codecompanion are skipped.
# Tolerant (|| true): if the async Mason bake doesn't fully complete, first
# launch finishes it — but with the ephemeral run model we try hard to bake now.
USER dev
ENV HOME=/home/dev
RUN set -eux; \
    nvim --headless "+Lazy! sync" +qa 2>&1 | tail -n 20 || true; \
    timeout 900 nvim --headless -c "luafile /opt/devbox/bake.lua" 2>&1 | tail -n 40 || true

WORKDIR /workspace
CMD ["bash"]
