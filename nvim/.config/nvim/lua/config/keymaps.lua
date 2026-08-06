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
