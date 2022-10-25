local Buffer = require 'tabline.buffer'

local state = {
  buffers = {},
  buffers_by_id = {},
  get_offset = function()
    for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].ft == 'NvimTree' then
        return vim.api.nvim_win_get_width(win) + 1
      end
    end
    return 0
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

-- Open/close buffers

--- Stop tracking the `bufnr` with barbar.
--- WARN: does NOT close the buffer in Neovim (see `:h nvim_buf_delete`)
--- @param bufnr integer
--- @param do_name_update? boolean refreshes all buffer names iff `true`
function state.close_buffer(bufnr, do_name_update)
  state.buffers = vim.tbl_filter(function(b)
    return b ~= bufnr
  end, state.buffers)
  state.buffers_by_id[bufnr] = nil

  if do_name_update then
    state.update_names()
  end
end

--- Update the names of all buffers in the bufferline.
function state.update_names()
  local buffer_index_by_name = {}

  -- Compute names
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
