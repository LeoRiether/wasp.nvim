# wasp.nvim

wasp.nvim is a plugin for Neovim that automate many tasks related to
Competitive/Sports Programming, such as copying the template, compiling and
testing the program, copying library files, and typing sample inputs.
 
## Dependencies
 - Neovim ≥0.7
 - fzf, fzf.vim and ripgrep for the `Lib` command

## Installing
You can install wasp.nvim with your favorite plugin manager, such as vim-plug or
packer.
```vimscript
" With vim-plug
Plug 'LeoRiether/wasp.nvim'
```

```lua
-- With packer.nvim
use 'LeoRiether/wasp.nvim'
```

## Features
- `:Template` -- copies the template file into the current buffer 
- `:Lib` -- opens fzf over the files in `lib/` (or whatever path you configure)
  and writes the selected one to the buffer
- `:Comp` -- runs the `./comp` script with the current file as an argument 
- `:Test` -- runs the `./test` script
- `:Out` -- runs `./out` in a terminal window
- `:Run` -- runs `:Comp`, then `Test`
- [Competitive Companion](https://github.com/jmerle/competitive-companion) integration -- copy test cases to an input file

## Example configuration
```lua
require('wasp').setup {
    template_path = function() return 'lib/template.' .. vim.fn.expand("%:e") end,
    lib_path = 'lib/',
    competitive_companion = { file = 'inp' },
}
require('wasp').set_default_keymaps()
```

`set_default_keymaps` will bind:
- `<leader>tem` to `:Template`
- `<leader>lib` to `:Lib`
- `<leader>comp` to `:Comp`
- `<leader>test` to `:Test`
- `<leader>out` to `:Out`
- `<leader>run` to `:Run`
