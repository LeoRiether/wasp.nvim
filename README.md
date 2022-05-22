# wasp.nvim

> Disclaimer: wasp.nvim is still in alpha. Expect breaking changes!

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
- `:WaspTemplate` -- copies the template file into the current buffer 
- `:WaspLib` -- opens fzf over the files in `lib/` (or whatever path you configure)
  and writes the selected one to the buffer
- `:WaspComp` -- runs the `./comp` script with the current file as an argument 
- `:WaspTest` -- runs the `./test` script
- `:WaspOut` -- runs `./out` in a terminal window
- `:WaspRun` -- runs `:WaspComp`, then `:WaspTest`
- [Competitive Companion](https://github.com/jmerle/competitive-companion) integration -- copy test cases to an input file

## Example configuration
```lua
if not vim.fn.getcwd():match('/my-competitive-programming-folder') then return end

require('wasp').setup {
    template_path = function() return 'lib/template.' .. vim.fn.expand("%:e") end,
    lib_path = 'lib/',
    competitive_companion = { file = 'inp' },
}
require('wasp').set_default_keymaps()
```

`set_default_keymaps` will bind:
- `<leader>tem` to `:WaspTemplate`
- `<leader>lib` to `:WaspLib`
- `<leader>comp` to `:WaspComp`
- `<leader>test` to `:WaspTest`
- `<leader>out` to `:WaspOut`
- `<leader>run` to `:WaspRun`
