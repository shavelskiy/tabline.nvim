local buf_get_option = vim.api.nvim_buf_get_option
local strcharpart = vim.fn.strcharpart
local strwidth = vim.api.nvim_strwidth

local Buffer = require 'tabline.buffer'
local icons = require 'tabline.icons'
local Layout = require 'tabline.layout'
local state = require 'tabline.state'
local utils = require 'tabline.utils'

local HL_BY_ACTIVITY = { 'Inactive', 'Current' }

local last_tabline

local function hl_tabline(group)
  return '%#' .. group .. '#'
end

local scroll = 0

local function groups_to_string(groups)
  local result = ''

  for _, group in ipairs(groups) do
    result = result .. group.hl .. group.text:gsub('%%', '%%%%')
  end

  return result
end

local function groups_insert(groups, position, others)
  local current_position = 0

  local new_groups = {}

  local i = 1
  while i <= #groups do
    local group = groups[i]
    local group_width = strwidth(group.text)

    if current_position + group_width <= position then
      new_groups[#new_groups + 1] = group
      i = i + 1
      current_position = current_position + group_width
    else
      local available_width = position - current_position

      if available_width > 0 then
        new_groups[#new_groups + 1] = {
          text = strcharpart(group.text, 0, available_width),
          hl = group.hl,
        }
      end

      local others_width = 0
      for _, other in ipairs(others) do
        local other_width = strwidth(other.text)
        others_width = others_width + other_width
        new_groups[#new_groups + 1] = other
      end

      local end_position = position + others_width

      while i <= #groups do
        local previous_group = groups[i]
        local previous_group_width = strwidth(previous_group.text)
        local previous_group_start_position = current_position
        local previous_group_end_position = current_position + previous_group_width

        if previous_group_end_position <= end_position and previous_group_width ~= 0 then
          -- continue
        elseif previous_group_start_position >= end_position then
          new_groups[#new_groups + 1] = previous_group
        else
          local remaining_width = previous_group_end_position - end_position
          local start = previous_group_width - remaining_width
          local end_ = previous_group_width
          local new_group = { hl = previous_group.hl, text = strcharpart(previous_group.text, start, end_) }
          new_groups[#new_groups + 1] = new_group
        end

        i = i + 1
        current_position = current_position + previous_group_width
      end

      break
    end
  end

  return new_groups
end

local function slice_groups_right(groups, width)
  local accumulated_width = 0

  local new_groups = {}

  for _, group in ipairs(groups) do
    local text_width = strwidth(group.text)
    accumulated_width = accumulated_width + text_width

    if accumulated_width >= width then
      local diff = text_width - (accumulated_width - width)
      local new_group = { hl = group.hl, text = strcharpart(group.text, 0, diff) }
      new_groups[#new_groups + 1] = new_group
      break
    end

    new_groups[#new_groups + 1] = group
  end

  return new_groups
end

local function slice_groups_left(groups, width)
  local accumulated_width = 0

  local new_groups = {}

  for _, group in ipairs(utils.reverse(groups)) do
    local text_width = strwidth(group.text)
    accumulated_width = accumulated_width + text_width

    if accumulated_width >= width then
      local length = text_width - (accumulated_width - width)
      local start = text_width - length
      local new_group = { hl = group.hl, text = strcharpart(group.text, start, length) }
      table.insert(new_groups, 1, new_group)
      break
    end

    table.insert(new_groups, 1, group)
  end

  return new_groups
end

local render = {}

function render.close_buffer(bufnr, do_name_update)
  state.close_buffer(bufnr, do_name_update)
  render.update()
end

local function open_buffers(new_buffers)
  local new_index = utils.index_of(state.buffers, state.last_current_buffer)
  if new_index ~= nil then
    new_index = new_index + 1
  else
    new_index = #state.buffers + 1
  end

  for _, new_buffer in ipairs(new_buffers) do
    if utils.index_of(state.buffers, new_buffer) == nil then
      local actual_index = new_index
          or buf_get_option(new_buffer, 'buftype') ~= ''

      actual_index = #state.buffers + 1

      table.insert(state.buffers, actual_index, new_buffer)
    end
  end
end

function render.get_updated_buffers(update_names)
  local current_buffers = state.get_buffer_list()
  local new_buffers = vim.tbl_filter(function(b)
    return not vim.tbl_contains(state.buffers, b)
  end, current_buffers)

  local did_change = false

  local closed_buffers = vim.tbl_filter(function(b)
    return not vim.tbl_contains(current_buffers, b)
  end, state.buffers)

  for _, buffer_number in ipairs(closed_buffers) do
    did_change = true

    render.close_buffer(buffer_number)
  end

  if #new_buffers > 0 then
    did_change = true

    open_buffers(new_buffers)
  end

  state.buffers = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_is_valid(b)
  end, state.buffers)

  if did_change or update_names then
    state.update_names()
  end

  return state.buffers
end

function render.set_current_win_listed_buffer()
  local current = vim.api.nvim_get_current_buf()
  local is_listed = buf_get_option(current, 'buflisted')

  if not is_listed then
    vim.api.nvim_command 'wincmd p'
    current = vim.api.nvim_get_current_buf()
    is_listed = buf_get_option(current, 'buflisted')
  end

  if not is_listed then
    local wins = vim.api.nvim_list_wins()
    for _, win in ipairs(wins) do
      current = vim.api.nvim_win_get_buf(win)
      is_listed = buf_get_option(current, 'buflisted')
      if is_listed then
        vim.api.nvim_set_current_win(win)
        break
      end
    end
  end

  return current
end

local tablist = function()
  local result, number_of_tabs = '%=', vim.fn.tabpagenr '$'

  if number_of_tabs > 1 then
    for i = 1, number_of_tabs, 1 do
      result = result .. hl_tabline(vim.fn.tabpagenr() == i and 'BufferTabOn' or 'BufferTabOff') .. ' ' .. i .. ' '
    end
  end

  return result
end

render.generate_tabline = function(bufnrs)
  local current = vim.api.nvim_get_current_buf()

  if buf_get_option(current, 'buflisted') then
    if vim.b.empty_buffer then
      state.last_current_buffer = nil
    else
      state.last_current_buffer = current
    end
  end

  local layout = Layout.calculate()

  local items = {}

  local current_buffer_position = 0

  for i, bufnr in ipairs(bufnrs) do
    local buffer_data = state.get_buffer_data(bufnr)
    local buffer_name = buffer_data.name

    buffer_data.real_position = current_buffer_position

    local activity = Buffer.get_activity(bufnr)
    local is_inactive = activity == 1
    local is_current = activity == 2
    local is_modified = buf_get_option(bufnr, 'modified')

    local status = HL_BY_ACTIVITY[activity]

    local namePrefix = hl_tabline('Buffer' .. status .. (is_modified and 'Mod' or ''))
    local iconChar, iconHl = icons.get_icon(buffer_name, buf_get_option(bufnr, 'filetype'), status)

    local padding = (' '):rep(layout.padding_width)

    local item = {
      is_current = is_current,
      width = layout.base_widths[i] + (2 * layout.padding_width),
      position = current_buffer_position,
      groups = {
        { hl = namePrefix, text = padding },
        { hl = hl_tabline(is_inactive and 'BufferInactive' or iconHl), text = iconChar .. ' ' },
        { hl = namePrefix, text = buffer_name },
        { hl = namePrefix, text = padding },
        { hl = namePrefix, text = not is_modified and ' ' or '● ' },
      },
    }

    if is_current then
      local start = current_buffer_position
      local end_ = current_buffer_position + item.width

      if scroll > start then
        scroll = start
      elseif scroll + layout.buffers_width < end_ then
        scroll = scroll + (end_ - (scroll + layout.buffers_width))
      end
    end

    items[#items + 1] = item
    current_buffer_position = current_buffer_position + item.width
  end

  local result = ''

  if state.get_offset() > 0 then
    result = groups_to_string { { hl = hl_tabline 'BufferOffset', text = ' ' } } .. (' '):rep(state.get_offset() - 1)
  end

  local bufferline_groups = {
    { hl = hl_tabline 'BufferTabpageFill', text = (' '):rep(layout.actual_width) },
  }

  for _, item in ipairs(items) do
    bufferline_groups = groups_insert(bufferline_groups, item.position, item.groups)
  end

  local max_scroll = math.max(layout.actual_width - layout.buffers_width, 0)
  local scroll_current = math.min(scroll, max_scroll)
  local buffers_end = layout.actual_width - scroll_current

  if buffers_end > layout.buffers_width then
    bufferline_groups = slice_groups_right(bufferline_groups, scroll_current + layout.buffers_width)
  end
  if scroll_current > 0 then
    bufferline_groups = slice_groups_left(bufferline_groups, layout.buffers_width)
  end

  return result .. groups_to_string(bufferline_groups) .. hl_tabline 'BufferTabpageFill' .. tablist()
end

function render.update(update_names)
  local result = render.generate_tabline(render.get_updated_buffers(update_names))
  if result ~= last_tabline then
    last_tabline = result
    vim.opt.tabline = last_tabline
  end
end

return render
