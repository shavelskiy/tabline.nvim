local icons = require 'tabline.icons'
local state = require 'tabline.state'

local maximum_padding, minimum_padding = 4, 2

local SIDES_OF_BUFFER = 2

--- @class tabline.layout.data
--- @field actual_width integer
--- @field available_width integer
--- @field base_widths integer[]
--- @field buffers_width integer
--- @field padding_width integer
--- @field tabpages_width integer
--- @field used_width integer

local calculate_tabpages_width = function()
  local result, number_of_tabs = 0, vim.fn.tabpagenr '$'

  if number_of_tabs > 1 then
    for i = 1, number_of_tabs, 1 do
      result = result + tostring(i):len() + 2
    end
  end

  return result
end

local calculate_buffer_width = function(bufnr)
  local buffer_data = state.get_buffer_data(bufnr)
  local buffer_name = buffer_data.name or '[no name]'

  local width = vim.api.nvim_strwidth(buffer_name) + 1

  local file_icon = icons.get_icon(vim.api.nvim_buf_get_name(bufnr), vim.api.nvim_buf_get_option(bufnr, 'filetype'), '')
  width = width + vim.api.nvim_strwidth(file_icon)

  return width + 2
end

local calculate_buffers_width = function()
  local sum = 0
  local widths = {}

  for _, bufnr in ipairs(state.buffers) do
    local width = calculate_buffer_width(bufnr)
    sum = sum + width
    widths[#widths + 1] = width
  end

  return sum, widths
end

return {
  --- Calculate the current layout of the tabline.
  --- @return tabline.layout.data
  calculate = function()
    local used_width, base_widths = calculate_buffers_width()

    local buffers_width = vim.o.columns - state.get_offset() - calculate_tabpages_width()

    local remaining_width = math.max(buffers_width - used_width, 0)
    local remaining_width_per_buffer = math.floor(remaining_width / #base_widths)
    local remaining_padding_per_buffer = math.floor(remaining_width_per_buffer / SIDES_OF_BUFFER)
    local padding_width = math.max(minimum_padding, math.min(remaining_padding_per_buffer, maximum_padding))

    return {
      actual_width = used_width + (#base_widths * padding_width * SIDES_OF_BUFFER),
      base_widths = base_widths,
      buffers_width = buffers_width,
      padding_width = padding_width,
    }
  end,
}
