local buffer_render = require 'tabline.buffer_render'

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

local bufferlist = function()
  local available_space = vim.o.columns - get_offset() - get_buttons_width()

  local buffers = {}
  for _, parts in ipairs(buffer_render.get_buffer_parts(available_space)) do
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
