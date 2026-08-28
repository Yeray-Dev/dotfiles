-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- AUTOSAVE --
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  command = "silent! wall",
})

-- COLORES PROPIOS --
local function set_hl()
  -- const y demás modificadores
  local const_hl = { fg = "#ff3b3b", bold = true }
  vim.api.nvim_set_hl(0, "@keyword.modifier", const_hl)
  vim.api.nvim_set_hl(0, "@type.qualifier", const_hl)
  for _, lang in ipairs({ "c", "cpp" }) do
    vim.api.nvim_set_hl(0, "@keyword.modifier." .. lang, const_hl)
    vim.api.nvim_set_hl(0, "@type.qualifier." .. lang, const_hl)
  end

  -- flags de comentario
  vim.api.nvim_set_hl(0, "CommentAlert", { fg = "#ff3b3b", bold = true })
  vim.api.nvim_set_hl(0, "CommentQuery", { fg = "#3b9eff", bold = true })
  vim.api.nvim_set_hl(0, "CommentNote", { fg = "#ff9e3b", bold = true })
end

-- Reaplicar al cambiar de tema (Omarchy lo recarga en caliente)
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })
set_hl()

local flags = {
  { group = "CommentAlert", pattern = [[//!.*$]] },
  { group = "CommentQuery", pattern = [[//?.*$]] },
  { group = "CommentNote", pattern = [[//\*.*$]] },
}

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinNew" }, {
  callback = function()
    if vim.w.comment_flags_ok then
      return
    end
    vim.w.comment_flags_ok = true
    for _, f in ipairs(flags) do
      vim.fn.matchadd(f.group, f.pattern, 200)
    end
  end,
})
