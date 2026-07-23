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
      ensure_installed = { "pyright", "terraformls", "marksman" },
      automatic_installation = true,
    })

    -- Non-LSP tools managed by Mason, resolved via Mason's prepended PATH:
    --   ruff/isort -> nvim-lint & conform
    --   tree-sitter-cli -> required by nvim-treesitter (main branch) to build parsers
    require("mason-tool-installer").setup({
      ensure_installed = { "ruff", "isort", "tree-sitter-cli" },
      run_on_start = true,
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Configure servers using the new vim.lsp.config API
    vim.lsp.config("pyright", {
      cmd = { "pyright-langserver", "--stdio" },
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

    -- Servers are auto-enabled and attached by mason-lspconfig's
    -- `automatic_enable` (default on), using the vim.lsp.config definitions above.

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
