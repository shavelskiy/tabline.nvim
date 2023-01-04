local buffer_utils = require 'tabline.buffer'
local buffer_render = require 'tabline.buffer_render'
local is_buf_valid = require('tabline.api').is_buf_valid

local get_offset = function()
  local result = 0
  for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].ft == 'NvimTree' then
      result = result + vim.api.nvim_win_get_width(win) + 1
    end
  end
  return result
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

local get_buffer_width = function(buffers_parts)
  local result = 0

  for _, parts in ipairs(buffers_parts) do
    result = result + buffer_render.get_length(parts)
  end

  return result
end

local bufferlist = function()
  local buffers_parts = {}
  local current_parts = nil
  local available_space = vim.o.columns - get_offset() - get_buttons_width()
  local current_buf = vim.api.nvim_get_current_buf()
  local has_current = false

  for _, bufnr in ipairs(vim.t.bufs) do
    if is_buf_valid(bufnr) then
      current_parts = buffer_utils.get_parts(bufnr)
      if get_buffer_width(buffers_parts) + buffer_render.get_length(current_parts) > available_space then
        if has_current then
          current_parts.forse_size = get_buffer_width(buffers_parts)
            + buffer_render.get_length(current_parts)
            - available_space
          table.insert(buffers_parts, current_parts)
          break
        end

        table.remove(buffers_parts, 1)
      end

      has_current = bufnr == current_buf and true or has_current
      table.insert(buffers_parts, current_parts)
    end
  end

  local buffers = {}
  for _, parts in ipairs(buffers_parts) do
    table.insert(buffers, buffer_render.render(parts))
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
