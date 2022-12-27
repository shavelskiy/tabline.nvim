return {
  basename = function(path)
    return vim.fn.fnamemodify(path, ':t')
  end,

  is_from_offset = function(win)
    local filetype = vim.bo[vim.api.nvim_win_get_buf(win)].ft
    return filetype == 'NvimTree' or filetype == 'git.nvim' or filetype == 'DiffviewFiles'
  end,

  index_of = function(list, t)
    for i, value in ipairs(list) do
      if value == t then
        return i
      end
    end
    return nil
  end,

  list_slice_from_end = function(list, index_from_end)
    return vim.list_slice(list, #list - index_from_end + 1)
  end,

  reverse = function(list)
    local reversed = {}
    while #reversed < #list do
      reversed[#reversed + 1] = list[#list - #reversed]
    end
    return reversed
  end,
}
