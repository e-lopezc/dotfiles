# Neovim Minimalistic Configuration

A clean, focused Neovim setup with support for Python, Terraform, Markdown, and Obsidian.

## 📦 Installed Plugins

### Core
- **lazy.nvim** - Plugin manager
- **tokyonight.nvim** - Color scheme
- **nvim-treesitter** - Syntax highlighting

### Language Support
- **nvim-lspconfig** - LSP configurations
- **mason.nvim** - LSP/formatter installer
- **pyright** - Python LSP
- **terraformls** - Terraform LSP
- **marksman** - Markdown LSP

### Editing
- **nvim-cmp** - Autocompletion
- **LuaSnip** - Snippet engine
- **conform.nvim** - Formatting (black, isort, terraform fmt, prettier)
- **nvim-lint** - Linting (ruff for Python)

### Navigation
- **telescope.nvim** - Fuzzy finder
- **nvim-tree** - File explorer

### Obsidian
- **obsidian.nvim** - Obsidian vault integration
- Vault: `~/life-notes/life-notes`

### Utilities
- **gitsigns.nvim** - Git integration
- **lualine.nvim** - Status line
- **Comment.nvim** - Easy commenting
- **nvim-autopairs** - Auto close brackets

## ⌨️ Key Bindings

### General
- `<Space>` - Leader key
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<leader>e` - File explorer (netrw)
- `<leader>t` - Toggle file tree

### Telescope (Fuzzy Finder)
- `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>fb` - Find buffers
- `<leader>fh` - Help tags

### LSP (Language Server)
- `gd` - Go to definition
- `gr` - Go to references
- `K` - Hover documentation
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code action

### Obsidian
- `<leader>on` - New note
- `<leader>os` - Search notes
- `<leader>ot` - Today's daily note
- `<leader>ob` - Show backlinks
- `<leader>ch` - Toggle checkbox (in markdown)
- `gf` - Follow link under cursor

### Editing
- `gcc` - Comment line (normal mode)
- `gc` - Comment selection (visual mode)
- `J` - Move line down (visual mode)
- `K` - Move line up (visual mode)

## 🚀 First Time Setup

1. Open Neovim:
   ```bash
   nvim
   ```

2. Lazy.nvim will automatically install all plugins

3. Install language servers and formatters:
   - Open Mason: `:Mason`
   - Or let Mason auto-install when you open files

4. Install Python tools (optional, for formatting/linting):
   ```bash
   pip install black isort ruff
   ```

5. Install Prettier (optional, for markdown formatting):
   ```bash
   npm install -g prettier
   ```

## 📝 Configuration Files

```
~/.config/nvim/
├── init.lua
└── lua/plugins/
    ├── colorscheme.lua
    ├── completion.lua
    ├── formatting.lua
    ├── linting.lua
    ├── lsp.lua
    ├── obsidian.lua
    ├── telescope.lua
    ├── treesitter.lua
    └── utils.lua
```

## 🔧 Customization

- Change color scheme: Edit `lua/plugins/colorscheme.lua`
- Modify Obsidian vault path: Edit `lua/plugins/obsidian.lua`
- Add more languages: Update `lua/plugins/lsp.lua` and `lua/plugins/treesitter.lua`
- Adjust keybindings: Edit respective plugin files or `init.lua`

## 📚 Useful Commands

- `:Lazy` - Open plugin manager
- `:Mason` - Manage LSP servers/formatters
- `:TSUpdate` - Update treesitter parsers
- `:checkhealth` - Check Neovim health
- `:ObsidianWorkspace` - Switch Obsidian workspace
- `:ConformInfo` - Show formatting info

## 🎨 Features

- **Auto-format on save** for Python, Terraform, and Markdown
- **Auto-completion** with LSP integration
- **Syntax highlighting** via Treesitter
- **Git integration** with gitsigns
- **Fuzzy finding** with Telescope
- **Obsidian vault** integration for note-taking
