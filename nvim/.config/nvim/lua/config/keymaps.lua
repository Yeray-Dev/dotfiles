-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==")
vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==")
vim.keymap.set("n", "<A-S-Down>", "yyp")
vim.keymap.set("n", "<A-S-Up>", "yyP")

vim.keymap.set("i", "<A-Down>", "<Esc>:m .+1<CR>==gi")
vim.keymap.set("i", "<A-Up>", "<Esc>:m .-2<CR>==gi")
vim.keymap.set("i", "<A-S-Down>", "<Esc>yypi")
vim.keymap.set("i", "<A-S-Up>", "<Esc>yyPi")

vim.keymap.set("n", "<F13>", "i")
vim.keymap.set("i", "<F13>", "<Esc>")
vim.keymap.set("v", "<F13>", "<Esc>")
vim.keymap.set("n", "<C-Up>", "^") -- inicio de línea en Normal
vim.keymap.set("n", "<C-Down>", "$") -- final de línea en Normal
vim.keymap.set("i", "<C-Up>", "<Home>") -- inicio de línea en Insertar
vim.keymap.set("i", "<C-Down>", "<End>") -- final de línea en Insertar

vim.keymap.set("i", "<C-f>", "<End>")
vim.keymap.set("n", "<leader><space>", LazyVim.pick("files", { root = false }), { desc = "Find Files (cwd)" })

vim.api.nvim_create_user_command("Bd", function(opts)
  vim.cmd("bp | bd" .. (opts.bang and "!" or "") .. " #")
end, { bang = true, desc = "Cerrar buffer sin cerrar ventana" })

-- visual: pegar sin que la selección sustituida vaya al registro
vim.keymap.set("x", "p", [["_dP]], { desc = "Pegar sin sobrescribir" })

-- borrados que no ensucian el portapapeles
vim.keymap.set({ "n", "x" }, "x", [["_x]])
vim.keymap.set({ "n", "x" }, "c", [["_c]])
vim.keymap.set("n", "C", [["_C]])
vim.keymap.set({ "n", "x" }, "s", [["_s]])
vim.keymap.set("n", "S", [["_S]])
