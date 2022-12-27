local get_current_buf = vim.api.nvim_get_current_buf

local state = require 'tabline.state'
local utils = require 'tabline.utils'

local function err(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = 'bbye' })
  vim.v.errmsg = msg
end

local empty_buffer = nil

local function new()
  vim.api.nvim_command 'enew'

  empty_buffer = get_current_buf()
  vim.b.empty_buffer = true

  vim.opt_local.buftype = ''
  vim.opt_local.swapfile = false
  vim.opt_local.bufhidden = 'wipe'

  vim.api.nvim_create_autocmd('BufWipeout', {
    buffer = 0,
    callback = function()
      state.close_buffer(empty_buffer)
    end,
    group = vim.api.nvim_create_augroup('bbye_empty_buffer', {}),
  })
end

return {
  delete = function()
    local buffer_number = get_current_buf()

    if buffer_number < 0 then
      return
    end

    if vim.api.nvim_buf_get_option(buffer_number, 'modified') then
      err('E89: No write since last change for buffer ' .. buffer_number .. ' (add ! to override)')
      return
    end

    local current_window = vim.api.nvim_get_current_win()

    local window_ids_reversed = utils.reverse(vim.api.nvim_list_wins())

    for _, window_number in ipairs(window_ids_reversed) do
      if vim.api.nvim_win_get_buf(window_number) == buffer_number then
        vim.api.nvim_set_current_win(window_number)

        local no_errors = pcall(function()
          local previous_buffer = vim.fn.bufnr '#'
          if previous_buffer > 0 and vim.fn.buflisted(previous_buffer) == 1 then
            vim.api.nvim_set_current_buf(previous_buffer)
          else
            vim.api.nvim_command 'bprevious'
          end
        end)

        if not (no_errors or vim.v.errmsg:match 'E85') then
          err(vim.v.errmsg)
          return
        end

        if get_current_buf() == buffer_number then
          new()
        end
      end
    end

    if vim.api.nvim_win_is_valid(current_window) then
      vim.api.nvim_set_current_win(current_window)
    end

    if vim.fn.buflisted(buffer_number) == 1 and buffer_number ~= get_current_buf() then
      vim.cmd['bdelete'] { count = buffer_number }
    end

    vim.api.nvim_exec_autocmds('BufWinEnter', {})
  end,
}
