-- Treesitter for syntax highlighting.
-- Uses the `main` branch: the legacy `master` branch is frozen and does not
-- support Neovim 0.12+ (its injection-query directive handler crashes on the
-- new multi-node capture API).
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- main branch does not support lazy-loading
  build = ":TSUpdate",
  config = function()
    local parsers = {
      "python", "lua", "vim", "vimdoc",
      "markdown", "markdown_inline", "hcl", "terraform",
      "dockerfile", "yaml",
    }

    -- Install/update the parsers we use (async, no-op if already current).
    require("nvim-treesitter").install(parsers)

    -- Enable treesitter highlighting + indentation per filetype.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
      pattern = { "python", "lua", "vim", "help", "markdown", "hcl", "terraform", "dockerfile", "yaml" },
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
