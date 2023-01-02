local devicons_present, devicons = pcall(require, 'nvim-web-devicons')
local is_buf_valid = require('tabline.api').is_buf_valid
local utils = require 'tabline.utils'

local new_hl = function(group1, group2)
  local new_group = 'Tabline' .. group1 .. group2
  vim.api.nvim_set_hl(0, new_group, {
    fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group1)), 'fg#'),
    bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group2)), 'bg#'),
  })
  return '%#' .. new_group .. '#'
end

local get_icon = function(name, bufnr)
  if not devicons_present then
    return ''
  end

  local icon, icon_hl = devicons.get_icon(name, string.match(name, '%a+$'), { default = true })

  return {
    hl = new_hl(icon_hl, vim.api.nvim_get_current_buf() == bufnr and 'TablineBufOn' or 'TablineBufOff'),
    icon = icon,
  }
end

local update_name = function(name, bufnr)
  for _, value in ipairs(vim.t.bufs) do
    if is_buf_valid(value) then
      if name == vim.fn.fnamemodify(vim.api.nvim_buf_get_name(value), ':t') and value ~= bufnr then
        name = utils.get_unique_name(bufnr, value)
      end
    end
  end

  return name
end

local get_highlight = function(bufnr)
  if bufnr == vim.api.nvim_get_current_buf() then
    return vim.bo[bufnr].modified and '%#TablineBufOnModified#' or '%#TablineBufOn#'
  end

  return vim.bo[bufnr].modified and '%#TablineBufOffModified#' or '%#TablineBufOff#'
end

local get_parts = function(bufnr)
  local name = (#vim.api.nvim_buf_get_name(bufnr) ~= 0) and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
    or ' No Name '

  local icon_data = get_icon(name, bufnr)

  name = (#name > 40 and string.sub(name, 1, 30) .. '..') or name

  return {
    icon = {
      hl = icon_data.hl,
      icon = icon_data.icon,
      close_icon = vim.bo[bufnr].modified and '' or '',
    },
    hl = get_highlight(bufnr),
    name = update_name(name, bufnr),
  }
end

return {
  get_buffer_tab = function(bufnr)
    local parts = get_parts(bufnr)

    return parts.icon.hl
      .. '   '
      .. parts.icon.icon
      .. parts.hl
      .. ' '
      .. parts.name
      .. '  '
      .. parts.icon.close_icon
      .. ' '
  end,
}
