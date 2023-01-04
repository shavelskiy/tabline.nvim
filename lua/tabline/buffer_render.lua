local render_with_size = function(parts)
  local result, lenght, tmp = parts.icon.hl, math.abs(parts.forse_size), ''
  if parts.forse_size > 0 then
    if lenght < 4 then
      result = result .. string.rep(' ', lenght)
    else
      result = result .. '   ' .. parts.icon.icon .. parts.hl
      lenght = lenght - 4
      if lenght < 1 then
      elseif lenght < 4 then
        result = result .. string.rep('.', lenght)
      elseif lenght < 8 then
        result = result .. ' ...' .. string.rep(' ', lenght - 4)
      else
        result = result .. ' '
        lenght = lenght - 1

        if #parts.name <= lenght then
          result = result .. parts.name
          lenght = lenght - #parts.name
        else
          tmp = string.sub(parts.name, 1, lenght - 3) .. '...'
          result = result .. tmp
          lenght = lenght - #tmp
        end

        if lenght > 3 then
          result = result .. '   ' .. parts.icon.close_icon
          lenght = lenght - 4
        end

        result = result .. string.rep(' ', lenght)
      end
    end
  else
    result = string.rep('j', math.abs(parts.forse_size))
  end

  return result
end

return function(parts)
  if parts.forse_size ~= nil then
    return render_with_size(parts)
  end

  return parts.icon.hl
    .. '   '
    .. parts.icon.icon
    .. parts.hl
    .. ' '
    .. parts.name
    .. '   '
    .. parts.icon.close_icon
    .. ' '
end
