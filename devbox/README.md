# devbox

A **portable DevOps/SRE tool container**. The image carries the toolchain so the
host OS doesn't matter — build it once per machine and get an identical shell on
macOS (arm64) or Linux (amd64/arm64). Launch it from **any directory**; that
directory becomes `/workspace`.

**No credentials are baked into the image.** Secrets are injected only at launch.

## What's inside

- **Languages/IaC:** Python (via `uv`, managed 3.13) · Terraform · kubectl · Flux
- **k8s companions:** helm · kustomize · k9s
- **AWS:** awscli v2 · aws-vault
- **Config mgmt:** Ansible
- **Dev CLI:** git · gh · neovim (your `common/nvim` config, baked) · tmux
- **Shell:** bash + starship + fzf + zoxide + eza + bat + ripgrep, with
  completions for kubectl/flux/helm/gh/aws

## Install

```sh
# 1. Build the image (per machine)
cd <dotfiles>/repos/dotfiles/devbox
make build

# 2. Put the launcher on your PATH — handled by the repo's install.sh, which
#    symlinks ~/.local/bin/devbox -> devbox/bin/devbox. Or do it manually:
ln -sf "$PWD/bin/devbox" ~/.local/bin/devbox
```

## Usage

```sh
cd ~/anywhere/on/any/machine
devbox                     # shell here; this dir = /workspace
devbox --kube              # + mount ~/.kube (read-only) for kubectl/flux/k9s
devbox --aws PROFILE       # + inject temporary AWS creds via aws-vault
devbox --kube --aws prod   # combine
devbox -- terraform plan   # run a one-off command instead of a shell
devbox nvim .              # (a bare command works too)
```

`make build` · `make rebuild` (no cache) · `make shell` · `make clean`.

## Credential model (nothing baked, nothing persisted)

| Secret | How it's handled |
|---|---|
| **Git push (SSH)** | SSH **agent forwarding** — only the agent *socket* is mounted; your private key never enters the container. OS-detected (`/run/host-services/ssh-auth.sock` on macOS, `$SSH_AUTH_SOCK` on Linux). |
| **AWS** | `aws-vault exec PROFILE` runs on the **host** and passes **temporary STS** creds in as env vars. Long-lived keys stay in your host keychain; nothing is written to disk in the box and it's gone on exit. |
| **Kubernetes** | `--kube` mounts `~/.kube` **read-only**, and only when you ask. |
| Git identity | `~/.gitconfig` mounted read-only (name/email — not a secret). |

Persisted across runs (named volumes, **no secrets**): shell history
(`devbox-hist`) and the uv cache (`devbox-uv-cache`). Neovim plugins/LSPs are
baked into the image, so the nvim data dir is intentionally **not** volume-mounted.

## Cross-OS / arch notes

- Every tool download resolves its architecture at build time, so the same
  `Dockerfile` builds on amd64 and arm64.
- `USER_UID`/`USER_GID` are set from your host user at build (`make build`) so
  bind-mounted files aren't root-owned on Linux.

## Caveats

- **macOS SSH socket:** the forwarding path assumes Docker Desktop/OrbStack's
  `/run/host-services/ssh-auth.sock`. If `ssh -T git@github.com` fails inside the
  box, export `DEVBOX_SSH_SOCK=<path>` to override.
- **`~/.kube` is read-only**, so `kubectl config use-context` won't persist, and
  kubeconfigs that reference on-host cert files by absolute path won't resolve.
- The Neovim `obsidian` and `codecompanion` plugins are disabled in-container
  (they target a host vault / host Ollama). This is gated by `NVIM_CONTAINER=1`,
  which is set only in the image — your host Neovim is unaffected.

## Neovim first launch

Plugins, LSP servers (pyright, terraform-ls, marksman, ruff, isort) and
treesitter parsers are pre-baked at build. If a headless bake step didn't fully
complete, the first `nvim` inside the box finishes it (needs network).
