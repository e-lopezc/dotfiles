# devbox

A **portable DevOps/SRE tool container**. The image carries the toolchain so the
host OS doesn't matter — build it once per machine and get an identical shell on
macOS (arm64) or Linux (amd64/arm64). Launch it from **any directory**; that
directory becomes `/workspace`.

**No credentials are baked into the image.** Secrets are injected only at launch,
and SSH agent forwarding is opt-in (see below).

## What's inside

- **Languages/IaC:** Python (via `uv`, managed 3.13) · Terraform · kubectl · Flux
- **k8s companions:** helm · k9s
- **AWS:** awscli v2 (`aws-vault` runs on the **host**, not baked into the image)
- **Config mgmt:** Ansible (`ansible-core` only, no community collection bundle)
- **Dev CLI:** git · gh · neovim (your `common/nvim` config, baked) · tmux
- **Shell:** bash + starship + fzf + zoxide + eza + bat + ripgrep, with
  completions for kubectl/flux/helm/gh/aws
- **Editor tooling:** `ruff` (lint + format + import-sort + LSP diagnostics for
  Python — no type inference, a deliberate trade for a lighter image),
  `terraform-ls`, `marksman`

Every tool version is pinned in [`mise.toml`](./mise.toml) and checksum-verified
at build time — that's the one file to edit to bump a version.

## Install

```sh
# 1. Build the image (per machine)
cd <dotfiles>/devbox
make build

# 2. Put the launcher on your PATH — handled by the repo's install.sh, which
#    symlinks ~/.local/bin/devbox -> devbox/bin/devbox. Or do it manually:
ln -sf "$PWD/bin/devbox" ~/.local/bin/devbox
```

## Usage

```sh
cd ~/anywhere/on/any/machine
devbox                     # shell here; this dir = /workspace
devbox --ssh                # + forward the SSH agent (git push, etc.)
devbox --kube               # + mount ~/.kube (read-only) for kubectl/flux/k9s
devbox --aws PROFILE        # + inject temporary AWS creds via aws-vault
devbox --force               # skip the $PWD safety guard (see Guardrails)
devbox --ssh --kube --aws prod   # combine
devbox -- terraform plan    # run a one-off command instead of a shell
devbox nvim .                # (a bare command works too)
```

`make build` · `make rebuild` (no cache) · `make shell` · `make clean`.

## Credential model (nothing baked, nothing persisted)

| Secret | How it's handled |
|---|---|
| **Git push (SSH)** | Only with `--ssh`. SSH **agent forwarding** — the agent *socket* is mounted, your private key never enters the container. OS-detected (`/run/host-services/ssh-auth.sock` on macOS, `$SSH_AUTH_SOCK` on Linux). Off by default: any code execution in the container otherwise had unlimited GitHub signing authority as you, just by being invoked. |
| **AWS** | `aws-vault exec PROFILE` runs on the **host** and passes **temporary STS** creds in as env vars. Long-lived keys stay in your host keychain; nothing is written to disk in the box and it's gone on exit. |
| **Kubernetes** | `--kube` mounts `~/.kube` **read-only**, and only when you ask. |
| Git identity | `~/.gitconfig` mounted read-only (name/email — not a secret). |

Persisted across runs (named volumes, **no secrets**): shell history
(`devbox-hist`) and the uv cache (`devbox-uv-cache`). Neovim plugins/LSPs are
baked into the image, so the nvim data dir is intentionally **not** volume-mounted.

## Guardrails

- **`$PWD` safety guard.** The launcher refuses to mount `$HOME` itself, any
  ancestor of it, or known-sensitive dotdirs (`~/.ssh`, `~/.aws`, `~/.kube`,
  `~/.gnupg`, `~/.docker`, `~/.config/gh`, `~/.local/bin`, `~/Library`) as
  `/workspace` — all of these would otherwise be exposed read-write to the
  container. Any other dotdir under `$HOME` warns and asks for confirmation.
  Override with `--force` or `DEVBOX_FORCE=1` (prints a loud warning either way).
- **No `sudo` in the image.** The container runs with `--security-opt
  no-new-privileges --cap-drop ALL`, which breaks setuid `sudo` anyway, so the
  sudoers entry was removed rather than left non-functional.
- **`--pids-limit`** defaults to 512; override with `DEVBOX_PIDS`.

## Cross-OS / arch notes

- Every tool is installed via `mise` (`mise.toml`), which resolves and
  checksum-verifies the right build for `linux/amd64` and `linux/arm64` at
  build time — no per-tool arch-detection logic in the Dockerfile itself.
- `USER_UID`/`USER_GID` are set from your host user at build (`make build`) so
  bind-mounted files aren't root-owned on Linux.

## Caveats

- **macOS SSH socket:** with `--ssh`, forwarding assumes Docker Desktop/OrbStack's
  `/run/host-services/ssh-auth.sock`. If `ssh -T git@github.com` fails inside the
  box, export `DEVBOX_SSH_SOCK=<path>` to override.
- **`~/.kube` is read-only**, so `kubectl config use-context` won't persist, and
  kubeconfigs that reference on-host cert files by absolute path won't resolve.
- **`ping`/`traceroute` don't work.** `--cap-drop ALL` removes `CAP_NET_RAW`,
  which Debian grants those binaries via file capabilities. Accepted as a
  deliberate trade for a hardened-by-default container — there's no flag to
  opt back in.
- The Neovim `obsidian` and `codecompanion` plugins are excluded in-container
  entirely (not just disabled) — they target a host vault / host Ollama that
  isn't reachable from the box. Gated by `NVIM_CONTAINER=1`, set only in the
  image; your host Neovim is unaffected.
- **Two residual risks, stated plainly rather than papered over:**
  - `--ssh` is all-or-nothing. Once forwarded, any command run in that
    invocation has unlimited signing authority as you for as long as the
    session lasts — the guard is opt-in, not scoped. A properly scoped agent
    (e.g. per-repo, confirmation-per-signature) is the real fix, not this flag.
  - The `$PWD` guard doesn't protect the launcher from itself: running `devbox`
    from *inside* this dotfiles checkout still mounts `devbox/bin/devbox`
    read-write, since the repo itself isn't a sensitive dotdir.

## Neovim first launch

Plugins, LSP servers (terraform-ls, marksman) and treesitter parsers are
pre-baked at build (`ruff` is provisioned separately via `uv tool install`, not
Mason). If the headless bake step didn't fully complete, the first `nvim`
inside the box finishes it (needs network).
