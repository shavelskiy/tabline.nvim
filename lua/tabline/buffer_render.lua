local render_with_size = function(parts)
  return string.rep('s', parts.forse_size)
end

return {
  get_length = function(parts)
    print(parts.name, 10 + #parts.name)
    return 10 + #parts.name
  end,
  render = function(parts)
    if parts.forse_size ~= nil then
      return render_with_size(parts)
    end

    return parts.icon.hl
      .. '   '
      .. parts.icon.icon
      .. ' '
      .. parts.hl
      .. parts.name
      .. '   '
      .. (parts.pick == nil and parts.icon.close_icon or parts.pick)
      .. ' '
  end,
}
