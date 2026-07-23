-- Color scheme - Kanagawa (softer than Gruvbox)
return {
  "rebelot/kanagawa.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("kanagawa").setup({
      theme = "wave", -- wave (soft), dragon (darker), lotus (light)
      background = {
        dark = "wave",
      },
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
    })
    vim.cmd([[colorscheme kanagawa-wave]])
  end,
}
