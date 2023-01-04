local list_slice_from_end = function(list, index_from_end)
  return vim.list_slice(list, #list - index_from_end + 1)
end

local separator = package.config:sub(1, 1)
local chars = 'abcdefghijklmnopqrstuvwxyz'

return {
  get_unique_name = function(bufnr, second_bufnr)
    local first = vim.api.nvim_buf_get_name(bufnr)
    local second = vim.api.nvim_buf_get_name(second_bufnr)

    local first_parts = vim.split(first, separator)
    local second_parts = vim.split(second, separator)

    local length = 1
    local first_result = table.concat(list_slice_from_end(first_parts, length), separator)
    local second_result = table.concat(list_slice_from_end(second_parts, length), separator)

    while first_result == second_result and length < math.max(#first_parts, #second_parts) do
      length = length + 1
      first_result = table.concat(list_slice_from_end(first_parts, math.min(#first_parts, length)), separator)
      second_result = table.concat(list_slice_from_end(second_parts, math.min(#second_parts, length)), separator)
    end

    return first_result
  end,
  number_to_char = function(number)
    return string.sub(chars, number, number)
  end,
  char_to_number = function(char)
    local i, _ = string.find(chars, char)
    return i
  end,
}
