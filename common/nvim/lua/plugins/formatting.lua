-- Formatting for Python and Terraform
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        -- No python entry: format_on_save.lsp_format = "fallback" below
        -- routes python formatting to ruff server (lint+format+import-sort).
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        markdown = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
    })
  end,
}
