-- Community-recommended markdown plugins
return {
  -- In-buffer markdown rendering (Obsidian-like preview)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("render-markdown").setup({
        file_types = { "markdown" },
        render_modes = { "n", "c" }, -- normal and command mode
        anti_conceal = {
          enabled = false,
        },
      })
    end,
  },

  -- Wiki-style link navigation and management
  {
    "jakewvincent/mkdnflow.nvim",
    config = function()
      require("mkdnflow").setup()
    end,
  },
}
