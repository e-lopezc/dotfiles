-- AI chat and inline assistant via Ollama (local LLMs)
-- Requires: ollama running at http://localhost:11434
-- Usage:
--   <leader>cc  → open chat buffer
--   <leader>ca  → action palette (prompt library)
--   <leader>ci  → inline assistant (visual selection → prompt)
--   :CodeCompanionChat  → chat
--   :CodeCompanion <prompt>  → inline
return {
  "olimorris/codecompanion.nvim",
  -- Excluded inside the devbox container (host Ollama isn't reachable there).
  -- `enabled`, not `cond` — cond still clones the plugin, just skips loading it.
  enabled = vim.env.NVIM_CONTAINER ~= "1",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    -- Use Ollama as the default adapter for all strategies
    strategies = {
      chat = { adapter = "ollama" },
      inline = { adapter = "ollama" },
      agent = { adapter = "ollama" },
    },
    adapters = {
      -- Extend the built-in ollama adapter and pin the default model
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          schema = {
            model = {
              default = "qwen3:8b",
            },
          },
        })
      end,
    },
  },
  keys = {
    { "<leader>cc", "<cmd>CodeCompanionChat toggle<cr>", mode = { "n", "v" }, desc = "Toggle AI chat" },
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>",     mode = { "n", "v" }, desc = "AI action palette" },
    { "<leader>ci", "<cmd>CodeCompanion<cr>",            mode = "v",          desc = "AI inline assist" },
  },
}
