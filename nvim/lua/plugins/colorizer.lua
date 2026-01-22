return {
  "norcalli/nvim-colorizer.lua",
  event = "BufReadPre",
  config = function()
    require("colorizer").setup({
      "*",
      css = { rgb_fn = true },
    }, {
      -- enable 8-digit hex like #RRGGBBAA (rofi)
      RRGGBBAA = true,
      -- keep the normal ones too (optional; these are defaults)
      RGB = true,
      RRGGBB = true,
      names = true,
      mode = "background",
    })
  end,
}
