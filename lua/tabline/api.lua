local M = {}
local api = vim.api
local utils = require 'tabline.utils'

M.is_buf_valid = function(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
end

local bufilter = function()
  local bufs = vim.t.bufs or nil

  if not bufs then
    return {}
  end

  for i = #bufs, 1, -1 do
    if not M.is_buf_valid(bufs[i]) then
      table.remove(bufs, i)
    end
  end

  return bufs
end

M.next_tab = function()
  local bufs = bufilter() or {}

  for i, v in ipairs(bufs) do
    if api.nvim_get_current_buf() == v then
      vim.cmd(i == #bufs and 'b' .. bufs[1] or 'b' .. bufs[i + 1])
      break
    end
  end
end

M.prev_tab = function()
  local bufs = bufilter() or {}

  for i, v in ipairs(bufs) do
    if api.nvim_get_current_buf() == v then
      vim.cmd(i == 1 and 'b' .. bufs[#bufs] or 'b' .. bufs[i - 1])
      break
    end
  end
end

M.close_buffer = function(bufnr)
  if vim.bo.buftype == 'terminal' then
    vim.cmd(vim.bo.buflisted and 'set nobl | enew' or 'hide')
  else
    bufnr = bufnr or api.nvim_get_current_buf()
    M.prev_tab()
    vim.cmd('confirm bd' .. bufnr)
  end
end

M.move_buf = function(n)
  local bufs = vim.t.bufs

  for i, bufnr in ipairs(bufs) do
    if bufnr == vim.api.nvim_get_current_buf() then
      if n < 0 and i == 1 or n > 0 and i == #bufs then
        bufs[1], bufs[#bufs] = bufs[#bufs], bufs[1]
      else
        bufs[i], bufs[i + n] = bufs[i + n], bufs[i]
      end

      break
    end
  end

  vim.t.bufs = bufs
  vim.cmd 'redrawtabline'
end

M.pick = function()
  vim.g.tabline_show_pick = true
  vim.cmd 'redrawtabline'

  local key = utils.char_to_number(vim.fn.nr2char(vim.fn.getchar()))
  local bufid = vim.t.bufs[(key and key or 0)]
  if key and bufid then
    vim.cmd('b' .. bufid)
    api.nvim_echo({ { '' } }, false, {})
  end
  vim.cmd 'redraw'

  vim.g.tabline_show_pick = false
  vim.cmd 'redrawtabline'
end

return M
