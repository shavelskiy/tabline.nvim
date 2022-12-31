local api = vim.api
local fn = vim.fn
local devicons_present, devicons = pcall(require, 'nvim-web-devicons')
local is_buf_valid = require('tabline.api').is_buf_valid
local utils = require 'tabline.utils'

local modules = {}

local new_hl = function(group1, group2)
  local fg = fn.synIDattr(fn.synIDtrans(fn.hlID(group1)), 'fg#')
  local bg = fn.synIDattr(fn.synIDtrans(fn.hlID(group2)), 'bg#')
  api.nvim_set_hl(0, 'Tabline' .. group1 .. group2, { fg = fg, bg = bg })
  return '%#' .. 'Tabline' .. group1 .. group2 .. '#'
end

local update_name = function(name, bufnr)
  for _, value in ipairs(vim.t.bufs) do
    if is_buf_valid(value) then
      if name == fn.fnamemodify(api.nvim_buf_get_name(value), ':t') and value ~= bufnr then
        name = utils.get_unique_name(bufnr, value)
      end
    end
  end

  return name
end

local add_fileInfo = function(name, bufnr)
  if devicons_present then
    local icon, icon_hl = devicons.get_icon(name, string.match(name, '%a+$'))

    if not icon then
      icon, icon_hl = ' ', '' -- todo default icon
    end

    icon = (
      api.nvim_get_current_buf() == bufnr and new_hl(icon_hl, 'TbLineBufOn') .. ' ' .. icon
      or new_hl(icon_hl, 'TbLineBufOff') .. ' ' .. icon
    )

    name = (#name > 40 and string.sub(name, 1, 35) .. '..') or name
    name = update_name(name, bufnr)

    if bufnr == api.nvim_get_current_buf() then
      name = ((vim.bo[0].modified and '%#TbLineBufOnModified# ') or '%#TbLineBufOn# ') .. name
    else
      name = ((vim.bo[bufnr].modified and '%#TbLineBufOffModified# ') or '%#TbLineBufOff# ') .. name
    end

    return '   ' .. icon .. name .. '   '
  end
end

modules.get_offset = function()
  for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
    if vim.bo[api.nvim_win_get_buf(win)].ft == 'NvimTree' then return api.nvim_win_get_width(win) + 1 end
  end
  return 0
end

modules.get_buttons_width = function()
  local result, number_of_tabs = 0, vim.fn.tabpagenr '$'

  if number_of_tabs > 1 then
    for i = 1, number_of_tabs, 1 do
      result = result + tostring(i):len() + 2
    end
  end

  return result
end

modules.style_buffer_tab = function(nr)
  local close_btn = ''
  local name = (#api.nvim_buf_get_name(nr) ~= 0) and fn.fnamemodify(api.nvim_buf_get_name(nr), ':t') or ' No Name '
  name = add_fileInfo(name, nr)

  if nr == api.nvim_get_current_buf() then
    close_btn = (vim.bo[0].modified and '%#TbLineBufOnModified# ') or '%#TbLineBufOnClose# '
    name = '%#TbLineBufOn#' .. name
  else
    close_btn = (vim.bo[nr].modified and '%#TbLineBufOffModified# ') or '%#TbLineBufOffClose# '
    name = '%#TbLineBufOff#' .. name
  end

  return name .. close_btn
end

return modules
