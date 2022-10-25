return {
  basename = function(path)
    return vim.fn.fnamemodify(path, ':t')
  end,

  --- Return the index of element `n` in `list.
  --- @generic T
  --- @param list T[]
  --- @param t T
  --- @return nil|integer index
  index_of = function(list, t)
    for i, value in ipairs(list) do
      if value == t then
        return i
      end
    end
    return nil
  end,

  --- Run `vim.list_slice` on some `list`, `index`ed from the end of the list.
  --- @generic T
  --- @param list T[]
  --- @param index_from_end number
  --- @return T[] sliced
  list_slice_from_end = function(list, index_from_end)
    return vim.list_slice(list, #list - index_from_end + 1)
  end,

  --- Reverse the order of elements in some `list`.
  --- @generic T
  --- @param list T[]
  --- @return T[] reversed
  reverse = function(list)
    local reversed = {}
    while #reversed < #list do
      reversed[#reversed + 1] = list[#list - #reversed]
    end
    return reversed
  end,
}
