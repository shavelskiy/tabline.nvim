local utils = require 'tabline.utils'

local maximum_length = 30

--- The character used to delimit paths (e.g. `/` or `\`).
local separator = package.config:sub(1, 1)

local function terminalname(name)
  local result = vim.fn.matchlist(name, [===[term://.\{-}//\d\+:\(.*\)]===])
  if next(result) == nil then
    return name
  else
    return result[2]
  end
end

return {
  get_activity = function(bufnr)
    if vim.api.nvim_get_current_buf() == bufnr then
      return 2
    elseif vim.fn.bufwinnr(bufnr) ~= -1 and vim.bo[vim.api.nvim_win_get_buf(0)].ft == 'NvimTree' then
      return 2
    end

    return 1
  end,

  get_name = function(bufnr)
    --- @type nil|string
    local name = vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_name(bufnr) or nil

    if name then
      name = vim.api.nvim_buf_get_option(bufnr, 'buftype') == 'terminal' and terminalname(name) or utils.basename(name)
    end

    if name == '' or name == nil then
      name = 'No name'
    end

    local ellipsis = '…'
    if #name > maximum_length then
      local ext_index = name:reverse():find '%.'

      if ext_index ~= nil and (ext_index < maximum_length - #ellipsis) then
        local extension = name:sub(-ext_index)
        name = name:sub(1, maximum_length - #ellipsis - #extension) .. ellipsis .. extension
      else
        name = name:sub(1, maximum_length - #ellipsis) .. ellipsis
      end

      -- safety to prevent recursion in any future edge case
      name = name:sub(1, maximum_length)
    end

    return name
  end,

  get_unique_name = function(first, second)
    local first_parts = vim.split(first, separator)
    local second_parts = vim.split(second, separator)

    local length = 1
    local first_result = table.concat(utils.list_slice_from_end(first_parts, length), separator)
    local second_result = table.concat(utils.list_slice_from_end(second_parts, length), separator)

    while first_result == second_result and length < math.max(#first_parts, #second_parts) do
      length = length + 1
      first_result = table.concat(utils.list_slice_from_end(first_parts, math.min(#first_parts, length)), separator)
      second_result = table.concat(utils.list_slice_from_end(second_parts, math.min(#second_parts, length)), separator)
    end

    return first_result, second_result
  end,
}
