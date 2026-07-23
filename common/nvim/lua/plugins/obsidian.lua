-- Obsidian integration (community fork - actively maintained)
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = { 
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    -- Enable conceallevel for Obsidian UI features
    vim.opt.conceallevel = 2
    vim.opt.concealcursor = "nc"
    
    -- Enable word wrap for markdown files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.breakindent = true
        vim.opt_local.showbreak = "↪ "
        vim.opt_local.colorcolumn = "80"
      end,
    })
    
    require("obsidian").setup({
      workspaces = {
        {
          name = "life-notes",
          path = "~/life-notes/life-notes",
        },
      },
      
      -- Disable legacy commands (use new format: "Obsidian command" instead of "ObsidianCommand")
      legacy_commands = false,
      
      -- Daily notes
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        alias_format = "%B %-d, %Y",
        default_tags = { "daily-notes" },
        template = nil,
      },
      
      -- Completion is provided by obsidian's built-in obsidian-ls LSP server.

      -- Templates
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        substitutions = {},
      },
      
      -- Note ID and path
      notes_subdir = "notes",
      new_notes_location = "notes_subdir",
      
      note_id_func = function(title)
        local suffix = ""
        if title ~= nil then
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. "-" .. suffix
      end,
      
      frontmatter = {
        func = function(note)
          local out = { 
            id = note.id, 
            aliases = note.aliases, 
            tags = note.tags,
            created = os.date("%Y-%m-%d %H:%M"),
          }
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end
          return out
        end,
      },
      
      -- Disable wiki links, use markdown links
      link = {
        style = "markdown",
      },
      
      -- Checkbox and rendering settings
      checkbox = {
        order = { " ", "x", ">", "~", "!" },
      },
      
      -- UI settings — disabled; in-buffer rendering is handled by
      -- render-markdown.nvim (the two conflict if both are enabled).
      ui = {
        enable = false,
        update_debounce = 200,
        max_file_length = 5000,
        bullets = { char = "•", hl_group = "ObsidianBullet" },
        external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        reference_text = { hl_group = "ObsidianRefText" },
        highlight_text = { hl_group = "ObsidianHighlightText" },
        tags = { hl_group = "ObsidianTag" },
        block_ids = { hl_group = "ObsidianBlockID" },
        hl_groups = {
          ObsidianTodo = { bold = true, fg = "#f78c6c" },
          ObsidianDone = { bold = true, fg = "#89ddff" },
          ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
          ObsidianTilde = { bold = true, fg = "#ff5370" },
          ObsidianImportant = { bold = true, fg = "#d73128" },
          ObsidianBullet = { bold = true, fg = "#89ddff" },
          ObsidianRefText = { underline = true, fg = "#c792ea" },
          ObsidianExtLinkIcon = { fg = "#c792ea" },
          ObsidianTag = { italic = true, fg = "#89ddff" },
          ObsidianBlockID = { italic = true, fg = "#89ddff" },
          ObsidianHighlightText = { bg = "#75662e" },
        },
      },

      -- Keep the footer, but avoid recursive backlink/status updates.
      statusline = {
        enabled = false,
      },
      footer = {
        format = "{{properties}} properties  {{words}} words  {{chars}} chars",
      },
      
      -- Attachments
      attachments = {
        folder = "assets/imgs",
        img_text_func = function(client, path)
          path = client:vault_relative_path(path) or path
          return string.format("![%s](%s)", path.name, path)
        end,
      },
      
      -- Picker (telescope)
      picker = {
        name = "telescope.nvim",
        note_mappings = {
          new = "<C-x>",
          insert_link = "<C-l>",
        },
        tag_mappings = {
          tag_note = "<C-x>",
          insert_tag = "<C-l>",
        },
      },
      
      -- Let vim.ui.open handle URL opening (system default)
      
      -- Callbacks for keymaps
      callbacks = {
        enter_note = function(note)
          vim.keymap.set("n", "<leader>ch", "<cmd>Obsidian toggle_checkbox<cr>", {
            buffer = true,
            desc = "Toggle checkbox",
          })
        end,
      },
    })

    -- Keymaps (using new command format)
    vim.keymap.set("n", "<leader>on", "<cmd>Obsidian new<cr>", { desc = "New note" })
    vim.keymap.set("n", "<leader>os", "<cmd>Obsidian search<cr>", { desc = "Search notes" })
    vim.keymap.set("n", "<leader>oq", "<cmd>Obsidian quickswitch<cr>", { desc = "Quick switch" })
    vim.keymap.set("n", "<leader>ot", "<cmd>Obsidian today<cr>", { desc = "Today's note" })
    vim.keymap.set("n", "<leader>oy", "<cmd>Obsidian yesterday<cr>", { desc = "Yesterday's note" })
    vim.keymap.set("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", { desc = "Backlinks" })
    vim.keymap.set("n", "<leader>ol", "<cmd>Obsidian links<cr>", { desc = "Links" })
    vim.keymap.set("n", "<leader>oc", "<cmd>Obsidian template<cr>", { desc = "Insert template" })
    vim.keymap.set("n", "<leader>op", "<cmd>Obsidian pasteimg<cr>", { desc = "Paste image" })
    vim.keymap.set("n", "<leader>or", "<cmd>Obsidian rename<cr>", { desc = "Rename note" })
  end,
}
