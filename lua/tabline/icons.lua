local status, web = pcall(require, 'nvim-web-devicons')

return {
  get_icon = function(buffer_name, filetype, buffer_status)
    if status == false then
      return '', ''
    end

    local basename
    local extension
    local icon_char
    local icon_hl

    if filetype == 'netrw' or filetype == 'LuaTree' then
      icon_char = ''
      icon_hl = 'Directory'
    else
      if filetype == 'fugitive' or filetype == 'gitcommit' then
        basename = 'git'
        extension = 'git'
      else
        basename = vim.fn.fnamemodify(buffer_name, ':t')
        extension = vim.fn.matchstr(basename, [[\v\.@<=\w+$]], '', '')
      end

      icon_char, icon_hl = web.get_icon(basename, extension, { default = true })
    end

    if icon_hl and vim.fn.hlexists(icon_hl .. buffer_status) < 1 then
      local hl = vim.api.nvim_get_hl_by_name(icon_hl, true)
      if hl['foreground'] then
        vim.api.nvim_set_hl(0, icon_hl .. buffer_status, { fg = hl['foreground'] })
      end
    end

    return icon_char, icon_hl .. buffer_status
  end,
}
