## tabline.nvim

Tabline for nvim

#### Default configuration

```lua
require('tabline').setup({
  highlight = true
})
```

## Screenshots

<p>
<img width='700' src='https://github.com/shavelskiy/tabline.nvim/blob/master/img/tabline.png'/>
</p>

## Exemple keymaps
```lua
local api = require 'tabline.api'
local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<S-Tab>', api.prev_tab, opts)
vim.keymap.set('n', '<Tab>', api.next_tab, opts)

vim.keymap.set('n', '<leader>dj', function() api.move_buf(-1) end, opts)
vim.keymap.set('n', '<leader>dl', function() api.move_buf(1) end, opts)

vim.keymap.set('n', '<Bslash>', api.pick, opts)
vim.keymap.set('n', '<leader>x', api.close_buffer, opts)
```

## Highlight groups
- TablineFill
- TablineBufOn
- TablineBufOff
- TablineBufOnModified
- TablineBufOffModified
- TablinePick
- TablineTabOn
- TablineTabOff
