local Buffer = require 'tabline.buffer'
local utils = require 'tabline.utils'

local state = {
  buffers = {},
  buffers_by_id = {},
  get_offset = function()
    local result = 0
    for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
      if utils.is_from_offset(win) then
        result = result + vim.api.nvim_win_get_width(win) + 1
      end
    end
    return result
  end,
}

function state.get_buffer_data(id)
  local data = state.buffers_by_id[id]

  if data ~= nil then
    return data
  end

  state.buffers_by_id[id] = {
    name = nil,
    position = nil,
  }

  return state.buffers_by_id[id]
end

function state.get_buffer_list()
  local buffers = vim.api.nvim_list_bufs()
  local result = {}

  for _, buffer in ipairs(buffers) do
    if vim.api.nvim_buf_get_option(buffer, 'buflisted') then
      result[#result + 1] = buffer
    end
  end

  return result
end

function state.close_buffer(bufnr, do_name_update)
  state.buffers = vim.tbl_filter(function(b)
    return b ~= bufnr
  end, state.buffers)
  state.buffers_by_id[bufnr] = nil

  if do_name_update then
    state.update_names()
  end
end

function state.update_names()
  local buffer_index_by_name = {}

  for i, buffer_n in ipairs(state.buffers) do
    local name = Buffer.get_name(buffer_n)

    if buffer_index_by_name[name] == nil then
      buffer_index_by_name[name] = i
      state.get_buffer_data(buffer_n).name = name
    else
      local other_i = buffer_index_by_name[name]
      local other_n = state.buffers[other_i]
      local new_name, new_other_name =
        Buffer.get_unique_name(vim.api.nvim_buf_get_name(buffer_n), vim.api.nvim_buf_get_name(state.buffers[other_i]))

      state.get_buffer_data(buffer_n).name = new_name
      state.get_buffer_data(other_n).name = new_other_name
      buffer_index_by_name[new_name] = i
      buffer_index_by_name[new_other_name] = other_i
      buffer_index_by_name[name] = nil
    end
  end
end

return state
