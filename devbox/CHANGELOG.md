# Changelog

All notable changes to the **devbox** image live here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com).
Nothing is tagged/released yet, so everything sits under _Unreleased_.

## [Unreleased] — 2026-08-14

### Security
- **Fixed a critical bug: the Neovim config was baked from the public GitHub
  remote (`DOTFILES_REF=main`), not this checkout** — so building on a branch
  that changes `common/nvim` (like the one that added the `NVIM_CONTAINER`
  guards) silently shipped a config *without* those guards. Build context moved
  to the repo root; the Dockerfile now `COPY`s `common/nvim` directly.
- SSH agent forwarding is now **opt-in** (`devbox --ssh`), not automatic on
  every invocation — a container code-exec no longer gets unlimited GitHub
  signing authority by default.
- Added a `$PWD` guard that refuses to mount `$HOME`, an ancestor of it, or
  known-sensitive dotdirs (`~/.ssh`, `~/.aws`, `~/.kube`, …) as `/workspace`;
  warns + confirms for other dotdirs. `--force`/`DEVBOX_FORCE=1` overrides.
- Dropped the passwordless-root sudoers entry; the launcher now runs with
  `--security-opt no-new-privileges --cap-drop ALL --pids-limit`.
- Nothing installs via `curl | bash` or a `latest`/moving tag anymore (was:
  five `curl | bash` as root, thirteen floating-version downloads).
  `common/nvim/lazy-lock.json` is committed and the bake now uses
  `Lazy! install` + `Lazy! restore` (not `sync`, which silently rewrote the
  lockfile to HEAD on every build).

### Changed
- **Install mechanism → `mise`.** `devbox/mise.toml` now pins every CLI tool
  (terraform, kubectl, helm, flux, k9s, aws-cli, gh, eza, zoxide, starship,
  uv, neovim, tree-sitter) in one place, checksum-verified by mise's `aqua`
  backend — replacing 12 separate hand-rolled `curl`/arch-detection/checksum
  blocks. Bumping a tool version is now a one-line edit.
- **Tool cuts:** dropped `aws-vault` from the image (the launcher already runs
  it on the *host*, the in-image copy was never invoked), `kustomize`
  (redundant with `kubectl -k` / Flux's embedded copy), `node` (only tether
  was `pyright`, see below), and the `--with ansible` community-collection
  bundle (nothing in this box's actual Ansible use touches `community.*`).
- **Python tooling → `ruff server`, replacing `pyright` + Mason's `isort`.**
  One binary does lint + format + import-sort + diagnostics; no type
  inference — a deliberate trade for a lighter image, not an oversight.
  `ruff` now installs via `uv tool install` (also fixes a real bug: Mason's
  copy was never on shell `$PATH`, so `ruff check` didn't work outside nvim).
- `codecompanion.nvim`/`obsidian.nvim` switched from `cond` to `enabled` in
  their lazy.nvim specs — `cond` still cloned them into the image even though
  `NVIM_CONTAINER=1` kept them from loading; `enabled` skips the clone.
- Dropped `nvim-lint` (redundant with `ruff server`'s LSP diagnostics).
- Treesitter parsers gained `dockerfile` and `yaml`.
- Base apt packages trimmed: `sudo`, `wget`, `gnupg`, `lsb-release`,
  `python3`/`pip`/`venv` all dropped — nothing in the image calls them anymore.
- `# syntax=` and `FROM debian:trixie-slim` are now pinned by digest.

### Added
- Initial **devbox**: a portable DevOps/SRE tool container. Run it from any
  directory (that dir becomes `/workspace`), host OS agnostic (macOS/Linux,
  amd64/arm64). Credentials are injected at launch and never baked in.
- Toolchain: Python (via `uv`, managed 3.13), Terraform, kubectl, Flux; k8s
  companions helm / kustomize / k9s; AWS `awscli` v2 + `aws-vault`; Ansible;
  git / gh; Neovim (config baked from the dotfiles repo) + tmux; bash with
  starship / fzf / zoxide / eza / bat.
- `bin/devbox` launcher: `$PWD` → `/workspace`, OS-detected SSH agent
  forwarding, `--kube` (read-only), `--aws PROFILE` (temporary creds via host
  `aws-vault`). `Makefile` build interface; `bake.lua` headless plugin/LSP bake.

### Fixed
- **Treesitter parsers now compile.** Switched the base image
  `debian:bookworm-slim` → `debian:trixie-slim`. Mason's prebuilt `tree-sitter`
  binary requires **glibc 2.39**; bookworm ships **2.36**, so parser compilation
  failed and syntax highlighting fell back to regex. Trixie ships **glibc 2.41**.
  (LSP servers were never affected — highlighting richness only.)
- **`python` command now works.** Symlinked `python` → the uv-managed Python
  3.13. Previously only `python3` (system 3.11) and `uv` were present, so a bare
  `python` was "command not found". System `python3` is left as-is for editor
  tooling (Mason/isort).

### Changed
- **Terraform** now installs from the direct HashiCorp release zip (version
  resolved via the checkpoint API) instead of the HashiCorp apt repo — removes
  the dependency on the Debian codename and keeps the trixie base robust.
- **Node.js** now installs from the official nodejs.org LTS tarball instead of
  the NodeSource apt repo, for the same codename-independence reason. (Node is
  required by the Neovim config's pyright + prettier.)
- `bin/devbox` allocates a TTY (`-t`) only when attached to one, so
  `devbox -- <cmd>` works from non-interactive scripts, not just an interactive
  shell.

### Fixed (initial bring-up)
- Container user creation failed with `useradd: not found` — added `/usr/sbin`
  back to `PATH` and installed `passwd` / `adduser` on the slim base.
- Ansible CLIs were missing — install `ansible-core --with ansible` so the
  `ansible` / `ansible-playbook` / … executables are exposed (the `ansible`
  bundle alone only ships `ansible-community`).
- kustomize download — resolve the latest `kustomize/*` release tag via the
  GitHub API (its tags are prefixed, so `latest/download` doesn't resolve).
- eza extraction — unpack the whole archive rather than a named member.
