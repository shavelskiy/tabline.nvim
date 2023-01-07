local reverse = function(list)
  local result = {}
  while #result < #list do
    result[#result + 1] = list[#list - #result]
  end
  return result
end

return function(parts)
  local groups = {
    { hl = parts.icon.hl, text = '   ' .. parts.icon.icon },
    { hl = parts.hl, text = ' ' .. parts.name .. '   ' },
  }

  if parts.pick ~= nil then
    table.insert(groups, { hl = parts.pick.hl, text = parts.pick.char .. ' ' })
  else
    table.insert(groups, { hl = parts.hl, text = parts.icon.close_icon .. ' ' })
  end

  if parts.forse_size ~= nil then
    local lenght = math.abs(parts.forse_size)

    if parts.forse_size < 0 then
      groups = reverse(groups)
    end

    for i, group in ipairs(groups) do
      group.text =
        vim.fn.strcharpart(group.text, parts.forse_size < 0 and vim.api.nvim_strwidth(group.text) - lenght or 0, lenght)
      lenght = lenght - vim.api.nvim_strwidth(group.text)
      groups[i] = group
    end

    if parts.forse_size < 0 then
      groups = reverse(groups)
    end
  end

  local result = ''
  for _, group in ipairs(groups) do
    result = result .. group.hl .. group.text
  end

  return result
end
