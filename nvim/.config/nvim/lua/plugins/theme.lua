-- Bajo Omarchy, delega en su tema activo (permite el hotreload).
-- En cualquier otra máquina, usa la copia versionada.
local omarchy = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
if vim.fn.filereadable(omarchy) == 1 then
  return dofile(omarchy)
end

return require("themes.default")
