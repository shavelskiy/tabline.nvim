local is_buf_valid = require('tabline.api').is_buf_valid

return {
  setup = function()
    -- store listed buffers in tab local var
    vim.t.bufs = vim.api.nvim_list_bufs()
    vim.g.tabline_offset = 0

    -- autocmds for tabufline -> store bufnrs on bufadd, bufenter events
    -- thx to https://github.com/ii14 & stores buffer per tab -> table
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufEnter', 'tabnew' }, {
      callback = function(args)
        if vim.t.bufs == nil then
          vim.t.bufs = vim.api.nvim_get_current_buf() == args.buf and {} or { args.buf }
        else
          local bufs = vim.t.bufs

          -- check for duplicates
          if
            not vim.tbl_contains(bufs, args.buf)
            and (args.event == 'BufEnter' or vim.bo[args.buf].buflisted)
            and (args.event == 'BufEnter' or args.buf ~= vim.api.nvim_get_current_buf())
            and is_buf_valid(args.buf)
          then
            table.insert(bufs, args.buf)
            vim.t.bufs = bufs
          end
        end
      end,
    })

    vim.api.nvim_create_autocmd('BufDelete', {
      callback = function(args)
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
          local bufs = vim.t[tab].bufs
          if bufs then
            for i, bufnr in ipairs(bufs) do
              if bufnr == args.buf then
                table.remove(bufs, i)
                vim.t[tab].bufs = bufs
                break
              end
            end
          end
        end
      end,
    })

    vim.opt.showtabline = 2
    vim.opt.tabline = "%!v:lua.require('tabline.render')()"
  end,
}
