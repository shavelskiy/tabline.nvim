return function()
  local colors = {
    base00 = '#1b1f27',
    base01 = '#1e222a',
    base02 = '#252931',
    base03 = '#3e4451',
    base04 = '#565c64',
    base05 = '#abb2bf',
    base06 = '#b6bdca',
    base07 = '#eeffff',
    base08 = '#ff875f',
    base09 = '#d7875f',
    base0A = '#ecc48d',
    base0B = '#afd75f',
    base0C = '#87d7d7',
    base0D = '#87afff',
    base0E = '#c792ea',
    base0F = '#be5046',
  }

  local defaultHighlight = {
    { 'TablineFill', { bg = colors.base02 } },
    { 'TablineBufOn', { fg = colors.base07, bg = colors.base01 } },
    { 'TablineBufOff', { fg = colors.base04, bg = colors.base02 } },
    { 'TablineBufOnModified', { fg = colors.base08, bg = colors.base01 } },
    { 'TablineBufOffModified', { fg = colors.base08, bg = colors.base02 } },

    { 'TablinePick', { fg = colors.base08, bg = colors.base02 } },

    { 'TablineTabOn', { fg = colors.base01, bg = colors.base05, bold = true } },
    { 'TablineTabOff', { fg = colors.base05, bg = colors.base03 } },
  }

  for _, data in pairs(defaultHighlight) do
    vim.api.nvim_set_hl(0, data[1], data[2])
  end
end
