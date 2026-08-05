-- bake.lua — pre-install LSP servers + treesitter parsers at image-build time.
--
-- Run headless: `nvim --headless -c "luafile /opt/devbox/bake.lua"`.
-- Because devbox runs containers with `--rm` and does NOT volume-mount the nvim
-- data dir, anything not installed here would be re-downloaded every launch — so
-- we install synchronously and block until done (or a generous timeout).

local function log(msg)
  io.stderr:write("[bake] " .. msg .. "\n")
end

-- Give lazy.nvim a moment to finish loading start plugins (mason, treesitter).
vim.wait(2000, function() return false end)

-- 1) Mason: LSP servers + tools used by the config -------------------------------
local mason_pkgs = {
  "pyright",        -- python LSP (node)
  "terraform-ls",   -- terraform LSP
  "marksman",       -- markdown LSP
  "ruff",           -- python linter/formatter (prebuilt binary)
  "isort",          -- python import sorter (pip)
  "tree-sitter-cli", -- required by nvim-treesitter (main branch)
}

local ok_registry, registry = pcall(require, "mason-registry")
if ok_registry then
  pcall(function() registry.refresh() end)
  for _, name in ipairs(mason_pkgs) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and not pkg:is_installed() then
      log("installing " .. name)
      pcall(function() pkg:install() end)
    end
  end

  -- Block until every package is installed (or 12 min timeout).
  local done = vim.wait(720000, function()
    for _, name in ipairs(mason_pkgs) do
      local ok, pkg = pcall(registry.get_package, name)
      if not ok or not pkg:is_installed() then return false end
    end
    return true
  end, 1000)
  log(done and "mason packages installed" or "mason bake timed out (first launch will finish)")
else
  log("mason-registry not available; skipping LSP bake")
end

-- 2) Treesitter parsers (main branch async API, best-effort) ---------------------
local parsers = {
  "python", "lua", "vim", "vimdoc",
  "markdown", "markdown_inline", "hcl", "terraform",
}
local ok_ts, ts = pcall(require, "nvim-treesitter")
if ok_ts then
  log("installing treesitter parsers")
  local ok_install, handle = pcall(function() return ts.install(parsers) end)
  if ok_install and type(handle) == "table" and handle.wait then
    pcall(function() handle:wait(300000) end)
  else
    -- Fall back to giving the async install time to finish.
    vim.wait(180000, function() return false end)
  end
  log("treesitter parser bake done")
else
  log("nvim-treesitter not available; skipping parser bake")
end

vim.cmd("qa!")
