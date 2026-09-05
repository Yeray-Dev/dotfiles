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

-- C / C++ : tabuladores, cindent y punto -> flecha
local function dot_to_arrow()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  if col < 2 then
    return
  end

  vim.lsp.buf_request(buf, "textDocument/hover", {
    textDocument = vim.lsp.util.make_text_document_params(buf),
    position = { line = row - 1, character = col - 2 },
  }, function(err, result)
    if err or not result or not result.contents then
      return
    end

    local c = result.contents
    local texto = type(c) == "string" and c or (c.value or "")
    local tipo = texto:match("Type:%s*`?([^`\n]+)")
    if not tipo or not tipo:find("%*") then
      return
    end

    local linea = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
    if not linea or linea:sub(col, col) ~= "." then
      return
    end

    vim.api.nvim_buf_set_text(buf, row - 1, col - 1, row - 1, col, { "->" })
    if vim.api.nvim_get_current_win() == win then
      vim.api.nvim_win_set_cursor(win, { row, col + 1 })
    end
  end)
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("yeray_c", { clear = true }),
  pattern = { "c", "cpp" },
  callback = function(ev)
    vim.bo[ev.buf].expandtab = false
    vim.bo[ev.buf].tabstop = 4
    vim.bo[ev.buf].softtabstop = 4
    vim.bo[ev.buf].shiftwidth = 4
    vim.bo[ev.buf].cindent = true

    vim.keymap.set("i", ".", function()
      vim.schedule(dot_to_arrow)
      return "."
    end, { buffer = ev.buf, expr = true, desc = "Punto a flecha si es puntero" })
  end,
})

vim.api.nvim_create_user_command("DotDebug", function()
  local buf = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local clients = vim.lsp.get_clients({ bufnr = buf })
  print("clientes: " .. #clients)
  for _, c in ipairs(clients) do
    print("  -> " .. c.name)
  end
  vim.lsp.buf_request(buf, "textDocument/hover", {
    textDocument = vim.lsp.util.make_text_document_params(buf),
    position = { line = row - 1, character = col },
  }, function(err, result)
    print("err: " .. vim.inspect(err))
    print("result: " .. vim.inspect(result))
  end)
end, {})
