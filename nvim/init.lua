-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local theme_file = vim.fn.expand("~/.config/custom/current/theme/neovim.lua")

if vim.fn.filereadable(theme_file) == 1 then
  dofile(theme_file)
end
