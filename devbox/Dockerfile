# syntax=docker/dockerfile:1@sha256:ecfaec9ed6d810b56388c508f4121597bfbba70d41a6dfeee4d8cad5f295fc32
#
# devbox — a portable DevOps/SRE tool image.
# Built per machine (see Makefile); carries the toolchain so the host OS does not
# matter. Runs on linux/amd64 and linux/arm64. NO credentials are baked in;
# secrets are injected at launch by bin/devbox.
#
# Tool versions are pinned in mise.toml (COPY'd in below), not hardcoded here —
# bump a version by editing that file, not this one.

FROM debian:trixie-slim@sha256:3a39a0592364683e6bab97937b72cad5a8fa6dcbbee90edb3bb48c7f8e94f258

# Match the invoking user's UID/GID so bind-mounted files aren't root-owned on
# Linux (the Makefile passes these). Harmless on macOS/OrbStack.
ARG USER_UID=1000
ARG USER_GID=1000
ARG USERNAME=dev

# mise itself is the one thing in this image still pinned by hand — it's the
# bootstrap for every other tool's version. Checksums are from mise's own
# upstream SHASUMS256.txt (github.com/jdx/mise/releases/<ver>).
ARG MISE_VERSION=v2026.8.5
ARG MISE_SHA256_AMD64=ee362b6d96c648e27325a8bc7ee866bde4fffc20c88c777c5eb5c3b5c6f3e226
ARG MISE_SHA256_ARM64=d2bde76b1f87ab50b6f456e05332bb02de56a6bf3c5d19343cc3661e5d294681

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    NVIM_CONTAINER=1 \
    UV_PYTHON_INSTALL_DIR=/opt/uv/python \
    UV_TOOL_DIR=/opt/uv/tools \
    UV_TOOL_BIN_DIR=/usr/local/bin \
    MISE_DATA_DIR=/opt/mise \
    MISE_GLOBAL_CONFIG_FILE=/opt/devbox/mise.toml \
    PATH=/opt/mise/shims:/usr/local/sbin:/usr/local/bin:/home/dev/.local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# --- base packages -------------------------------------------------------------
# unzip/tar/xz-utils stay: mise's own bootstrap needs system tar, and none of
# these three carry any version-maintenance burden of their own. No sudo (see
# below), no wget/gnupg/lsb-release/python3 — nothing left in this image calls
# them (see mise.toml for what replaced their old purpose).
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates curl \
        git openssh-client less passwd adduser \
        bash-completion \
        ripgrep fzf tmux jq unzip tar xz-utils \
        bat \
        build-essential; \
    ln -sf /usr/bin/batcat /usr/local/bin/bat; \
    rm -rf /var/lib/apt/lists/*

# --- non-root user ---------------------------------------------------------------
# No sudoers entry — the launcher runs the container with --cap-drop ALL
# --security-opt no-new-privileges, which breaks setuid sudo anyway.
RUN set -eux; \
    groupadd --gid "${USER_GID}" "${USERNAME}" 2>/dev/null || true; \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USERNAME}"

# --- mise (checksum-verified bootstrap; everything else pins via mise.toml) ----
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in amd64) MARCH=x64; MSUM="${MISE_SHA256_AMD64}" ;; \
                       arm64) MARCH=arm64; MSUM="${MISE_SHA256_ARM64}" ;; \
                       *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;; esac; \
    curl -fsSL -o /usr/local/bin/mise \
        "https://github.com/jdx/mise/releases/download/${MISE_VERSION}/mise-${MISE_VERSION}-linux-${MARCH}"; \
    echo "${MSUM}  /usr/local/bin/mise" | sha256sum -c -; \
    chmod +x /usr/local/bin/mise; \
    mise --version

COPY devbox/mise.toml /opt/devbox/mise.toml

# aqua (mise's default backend for most of these tools) verifies each download
# against upstream-published checksums itself — that's the whole reason this
# replaces 12 separate hand-rolled curl/verify blocks.
RUN set -eux; \
    cd /opt/devbox; \
    mise trust mise.toml; \
    mise install --yes; \
    chmod -R a+rX /opt/mise; \
    mise exec -- sh -c 'terraform version; kubectl version --client; helm version --short; \
        flux --version; k9s version -s; aws --version; gh --version; \
        eza --version; zoxide --version; starship --version; uv --version; \
        nvim --version | head -1; tree-sitter --version'

# --- uv-managed Python tooling (uv itself comes from mise, see mise.toml) ------
RUN set -eux; \
    uv python install 3.13; \
    ln -sf "$(uv python find 3.13)" /usr/local/bin/python; \
    uv tool install --python 3.13 ansible-core; \
    uv tool install --python 3.13 ruff; \
    chmod -R a+rX /opt/uv; \
    ansible --version; ruff --version

# --- baked shell config ------------------------------------------------------
COPY devbox/bashrc /home/dev/.bashrc
COPY devbox/starship.toml /home/dev/.config/starship.toml

# --- baked Neovim config (copied from this checkout, not cloned) --------------
COPY --chown=${USER_UID}:${USER_GID} common/nvim /home/dev/.config/nvim

COPY devbox/bake.lua /opt/devbox/bake.lua

RUN chown -R "${USER_UID}:${USER_GID}" /home/dev /opt/uv

# --- pre-bake nvim plugins + LSP servers + treesitter parsers (as dev) --------
# Runs headless with NVIM_CONTAINER=1 so obsidian/codecompanion are excluded
# entirely (enabled = false, not just cond — they're never installed).
# Tolerant (|| true): if the async Mason bake doesn't fully complete, first
# launch finishes it — but with the ephemeral run model we try hard to bake now.
USER dev
ENV HOME=/home/dev
RUN set -eux; \
    nvim --headless "+Lazy! install" "+Lazy! restore" +qa 2>&1 | tail -n 20 || true; \
    timeout 900 nvim --headless -c "luafile /opt/devbox/bake.lua" 2>&1 | tail -n 40 || true

WORKDIR /workspace
CMD ["bash"]
