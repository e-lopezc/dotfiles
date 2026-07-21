-- Auto-save plugin
return {
  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
        defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      condition = function(buf)
        local filetype = vim.fn.getbufvar(buf, "&filetype")
        local excluded = { "", "help", "TelescopePrompt" }
        for _, ft in ipairs(excluded) do
          if filetype == ft then return false end
        end
        return true
      end,
      debounce_delay = 1000,
    },
  },
}
