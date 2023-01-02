local buffer_utils = require 'tabline.buffer'
local is_buf_valid = require('tabline.api').is_buf_valid

local get_offset = function()
  for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].ft == 'NvimTree' then
      return vim.api.nvim_win_get_width(win) + 1
    end
  end
  return 0
end

local get_buttons_width = function()
  local result, number_of_tabs = 0, vim.fn.tabpagenr '$'

  if number_of_tabs > 1 then
    for i = 1, number_of_tabs, 1 do
      result = result + tostring(i):len() + 2
    end
  end

  return result
end

local cover_nvim_tree = function()
  return '%#NvimTreeNormal#' .. string.rep(' ', get_offset())
end

local get_buffer_width = function(buffers)
  local result, current = 0, ''

  for _, buffer in ipairs(buffers) do
    current = buffer:gsub('%%#%a*#', '')
    result = result + #current + 5
  end

  return result
end

local bufferlist = function()
  local buffers = {}
  local available_space = vim.o.columns - get_offset() - get_buttons_width()
  local current_buf = vim.api.nvim_get_current_buf()
  local has_current = false

  for _, bufnr in ipairs(vim.t.bufs) do
    if is_buf_valid(bufnr) then
      if (get_buffer_width(buffers)) > available_space then
        if has_current then
          break
        end

        table.remove(buffers, 1)
      end

      has_current = (bufnr == current_buf and true) or has_current
      table.insert(buffers, buffer_utils.get_buffer_tab(bufnr))
    end
  end

  return table.concat(buffers) .. '%#TablineFill#%='
end

local tablist = function()
  local result, number_of_tabs = '', vim.fn.tabpagenr '$'

  if number_of_tabs > 1 then
    for i = 1, number_of_tabs, 1 do
      local tab_hl = ((i == vim.fn.tabpagenr()) and '%#TablineTabOn# ') or '%#TablineTabOff# '
      result = result .. tab_hl .. i .. ' '
    end
  end

  return result
end

return function()
  return cover_nvim_tree() .. bufferlist() .. tablist()
end
