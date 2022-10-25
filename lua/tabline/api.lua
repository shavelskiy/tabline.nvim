local render = require 'tabline.render'
local state = require 'tabline.state'
local utils = require 'tabline.utils'

return {
  goto_buffer = function(index)
    if index < 0 then
      index = #state.buffers + index + 1
    else
      index = math.min(index, #state.buffers)
    end

    vim.api.nvim_set_current_buf(state.buffers[math.max(1, index)])
  end,

  goto_buffer_relative = function(steps)
    render.get_updated_buffers()

    local current = render.set_current_win_listed_buffer()

    local idx = utils.index_of(state.buffers, current)

    if idx == nil then
      return
    else
      idx = (idx + steps - 1) % #state.buffers + 1
    end

    vim.api.nvim_set_current_buf(state.buffers[idx])
  end,

  move_current_buffer = function(steps)
    render.update()

    local current_bufnr = vim.api.nvim_get_current_buf()
    local idx = utils.index_of(state.buffers, current_bufnr)

    if idx == nil then
      return
    end

    local to_idx = math.max(1, math.min(#state.buffers, idx + steps))
    if to_idx == idx then
      return
    end

    local bufnr = state.buffers[idx]

    table.remove(state.buffers, idx)
    table.insert(state.buffers, to_idx, bufnr)

    render.update()
  end,

  order_by_buffer_number = function()
    table.sort(state.buffers, function(a, b)
      return a < b
    end)
    render.update()
  end,

  order_by_directory = function()
    table.sort(state.buffers, function(a, b)
      local name_of_a = vim.api.nvim_buf_get_name(a)
      local name_of_b = vim.api.nvim_buf_get_name(b)
      local a_less_than_b = name_of_b < name_of_a

      local level_of_a = #vim.split(name_of_a, '/')
      local level_of_b = #vim.split(name_of_b, '/')

      if level_of_a ~= level_of_b then
        return level_of_a < level_of_b
      end

      return a_less_than_b
    end)

    render.update()
  end,

  order_by_language = function()
    table.sort(state.buffers, function(a, b)
      return vim.api.nvim_buf_get_option(a, 'filetype') < vim.api.nvim_buf_get_option(b, 'filetype')
    end)

    render.update()
  end,

  order_by_window_number = function()
    table.sort(state.buffers, function(a, b)
      return vim.fn.bufwinnr(vim.api.nvim_buf_get_name(a)) < vim.fn.bufwinnr(vim.api.nvim_buf_get_name(b))
    end)

    render.update()
  end,
}
