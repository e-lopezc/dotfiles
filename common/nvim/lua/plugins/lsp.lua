-- LSP Configuration
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "terraformls", "marksman" },
      automatic_installation = true,
    })

    -- ruff and tree-sitter-cli are provisioned outside Mason: ruff via
    -- `uv tool install` (Dockerfile) so it's also on $PATH in a plain shell,
    -- tree-sitter-cli via mise (mise.toml) as a native binary.

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Configure servers using the new vim.lsp.config API
    -- ruff server replaces pyright: lint + format + import-sort + diagnostics
    -- in one binary. No type inference — that's a deliberate trade for a
    -- lighter box, not an oversight.
    vim.lsp.config("ruff", {
      cmd = { "ruff", "server" },
      capabilities = capabilities,
      root_markers = { "pyproject.toml", "setup.py", ".git" },
    })

    vim.lsp.config("terraformls", {
      cmd = { "terraform-ls", "serve" },
      capabilities = capabilities,
      root_markers = { "*.tf", ".terraform" },
    })

    vim.lsp.config("marksman", {
      cmd = { "marksman", "server" },
      capabilities = capabilities,
      root_markers = { ".git" },
    })

    -- terraformls/marksman are auto-enabled by mason-lspconfig's
    -- `automatic_enable` (default on), since they're in ensure_installed above.
    -- ruff isn't Mason-managed, so it needs an explicit enable.
    vim.lsp.enable("ruff")

    -- Keymaps
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      end,
    })
  end,
}
