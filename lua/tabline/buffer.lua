local devicons_present, devicons = pcall(require, 'nvim-web-devicons')
local is_buf_valid = require('tabline.api').is_buf_valid
local utils = require 'tabline.utils'

local new_hl = function(group1, group2)
  local fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group1)), 'fg#')
  local bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group2)), 'bg#')
  vim.api.nvim_set_hl(0, 'Tabline' .. group1 .. group2, { fg = fg, bg = bg })
  return '%#' .. 'Tabline' .. group1 .. group2 .. '#'
end

local get_icon = function(name, bufnr)
  if not devicons_present then
    return ''
  end
  local icon, icon_hl = devicons.get_icon(name, string.match(name, '%a+$'))

  if not icon then
    icon, icon_hl = ' ', '' -- todo default icon
  end

  local space = '   '

  return (
    vim.api.nvim_get_current_buf() == bufnr and new_hl(icon_hl, 'TbLineBufOn') .. space .. icon
    or new_hl(icon_hl, 'TbLineBufOff') .. space .. icon
  )
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

return {
  get_buffer_tab = function(bufnr)
    local name = (#vim.api.nvim_buf_get_name(bufnr) ~= 0) and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
      or ' No Name '

    local icon = get_icon(name, bufnr)

    name = (#name > 40 and string.sub(name, 1, 30) .. '..') or name
    name = update_name(name, bufnr)

    local name_hl = ''
    local close_btn = ''
    if bufnr == vim.api.nvim_get_current_buf() then
      close_btn = (vim.bo[0].modified and '%#TbLineBufOnModified# ') or '%#TbLineBufOnClose# '
      name_hl = ((vim.bo[0].modified and '%#TbLineBufOnModified#') or '%#TbLineBufOn#')
    else
      close_btn = (vim.bo[bufnr].modified and '%#TbLineBufOffModified# ') or '%#TbLineBufOffClose# '
      name_hl = ((vim.bo[bufnr].modified and '%#TbLineBufOffModified#') or '%#TbLineBufOff#')
    end

    return icon .. name_hl .. ' ' .. name .. '  ' .. close_btn
  end,
}
