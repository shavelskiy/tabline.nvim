local modules = require 'tabline.modules'
local is_buf_valid = require('tabline.api').is_buf_valid

local cover_nvim_tree = function() return '%#NvimTreeNormal#' .. string.rep(' ', modules.get_offset()) end

local get_buffer_width = function(buffers)
  local result, current = 0, ''

  for _, buffer in ipairs(buffers) do
    current = buffer:gsub("%%#%a*#", '')
    result = result + #current + 5
  end

  return result
end

local bufferlist = function()
  local buffers = {}
  local available_space = vim.o.columns - modules.get_offset() - modules.get_buttons_width()
  local current_buf = vim.api.nvim_get_current_buf()
  local has_current = false

  if vim.g.tbufpick_showNums then
    for index, value in ipairs(vim.g.visibuffers) do
      local name = value:gsub('', '(' .. index .. ')')
      table.insert(buffers, name)
    end
    return table.concat(buffers) .. '%#TblineFill#' .. '%='
  end

  vim.g.bufirst = 0
  for _, bufnr in ipairs(vim.t.bufs) do
    if is_buf_valid(bufnr) then
      if (get_buffer_width(buffers)) > available_space then
        if has_current then break end

        vim.g.bufirst = vim.g.bufirst + 1
        table.remove(buffers, 1)
      end

      has_current = (bufnr == current_buf and true) or has_current
      table.insert(buffers, modules.style_buffer_tab(bufnr))
    end
  end

  vim.g.visibuffers = buffers
  return table.concat(buffers) .. '%#TblineFill#%='
end

local tablist = function()
  local result, number_of_tabs = '', vim.fn.tabpagenr '$'

  if number_of_tabs > 1 then
    for i = 1, number_of_tabs, 1 do
      local tab_hl = ((i == vim.fn.tabpagenr()) and '%#TbLineTabOn# ') or '%#TbLineTabOff# '
      result = result .. tab_hl .. i .. ' '
    end
  end

  return result
end

return function() return cover_nvim_tree() .. bufferlist() .. tablist() end
