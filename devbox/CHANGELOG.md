# Changelog

All notable changes to the **devbox** image live here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com).
Nothing is tagged/released yet, so everything sits under _Unreleased_.

## [Unreleased] — 2026-08-05

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
