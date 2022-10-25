local render = require 'tabline.render'

local function create_augroups()
  return vim.api.nvim_create_augroup('tabline', {}), vim.api.nvim_create_augroup('tabline_update', {})
end

local augroup_tablien, augroup_tabline_update = create_augroups()

return {
  setup = function()
    vim.api.nvim_create_autocmd('BufModifiedSet', {
      callback = function(tbl)
        local is_modified = vim.api.nvim_buf_get_option(tbl.buf, 'modified')
        if is_modified ~= vim.b[tbl.buf].checked then
          vim.api.nvim_buf_set_var(tbl.buf, 'checked', is_modified)
          render.update()
        end
      end,
      group = augroup_tablien,
    })

    vim.api.nvim_create_autocmd({ 'BufNew', 'BufEnter' }, {
      callback = function()
        render.update(true)
      end,
      group = augroup_tabline_update,
    })

    vim.api.nvim_create_autocmd({
      'BufEnter',
      'BufWinEnter',
      'BufWinLeave',
      'BufWritePost',
      'SessionLoadPost',
      'TabEnter',
      'VimResized',
      'WinEnter',
      'WinLeave',
    }, {
      callback = function()
        render.update()
      end,
      group = augroup_tabline_update,
    })

    vim.api.nvim_create_autocmd('WinClosed', {
      callback = function()
        vim.schedule(render.update)
      end,
      group = augroup_tabline_update,
    })

    vim.api.nvim_create_autocmd('TermOpen', {
      callback = function()
        vim.defer_fn(function()
          render.update(true)
        end, 500)
      end,
      group = augroup_tabline_update,
    })

    vim.opt.showtabline = 2

    render.update()
  end,
}
