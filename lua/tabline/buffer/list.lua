local buffer_parts = require 'tabline.buffer.parts'
local is_buf_valid = require('tabline.api').is_buf_valid

local get_length = function(parts)
  return parts.forse_size == nil and 10 + #parts.name or math.abs(parts.forse_size)
end
local get_buffer_width = function(buffers_parts, skip_first)
  local result = 0

  for i, parts in ipairs(buffers_parts) do
    if skip_first == false or i ~= 1 then
      result = result + get_length(parts)
    end
  end

  return result
end

return function(available_space)
  local current_buf = vim.api.nvim_get_current_buf()
  local has_current = false

  local buffers_parts = {}
  local current_parts, tmp = nil, nil

  for i, bufnr in ipairs(vim.t.bufs) do
    if is_buf_valid(bufnr) and (bufnr == current_buf) and vim.g.tabline_offset >= i then
      vim.g.tabline_offset = i - 1
    end
  end

  for i, bufnr in ipairs(vim.t.bufs) do
    if i > vim.g.tabline_offset then
      if is_buf_valid(bufnr) then
        current_parts = buffer_parts(bufnr)
        if get_buffer_width(buffers_parts, false) + get_length(current_parts) > available_space then
          if has_current then
            current_parts.forse_size = available_space - get_buffer_width(buffers_parts, false)
            table.insert(buffers_parts, current_parts)
            break
          end

          if buffers_parts[1].forse_size ~= nil then
            vim.g.tabline_offset = vim.g.tabline_offset + 1
            table.remove(buffers_parts, 1)
          end

          tmp = buffers_parts[1]
          tmp.forse_size = get_buffer_width(buffers_parts, true) + get_length(current_parts) - available_space
          buffers_parts[1] = tmp
        end

        has_current = bufnr == current_buf and true or has_current
        table.insert(buffers_parts, current_parts)
      end
    end
  end

  return buffers_parts
end
