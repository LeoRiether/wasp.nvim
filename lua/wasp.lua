--
-- the Wrong Answer tool for Sports Programming
--

if vim.g.loaded_wasp == 1 then return end
vim.g.loaded_wasp = 1

local wasp = {}

-- :Lib
-- TODO: support Telescope & other fuzzy finders as well 
local function lib_copy()
    vim.fn['fzf#run'](vim.fn['fzf#wrap'](vim.fn['fzf#vim#with_preview']({
        source = 'rg lib/ --files',
        sink = 'read',
        options = { '--prompt', 'Lib> ', },
    })))
end

-- :Template
local function template(path)
    local t = type(path)
    if t == "function" then
        path = path()
    end
    vim.cmd(string.format([[
        normal! ggdG
        silent execute "0r '%s'"
        redraw!
        normal! gg
    ]]), path)
end

-- Keymaps
function wasp.set_default_keymaps()
    local map = vim.api.nvim_set_keymap
    local function lmap(lhs, rhs) -- leader map
        map('n', '<leader>'..lhs, rhs, {noremap=true})
    end

    lmap('comp', ':Comp<cr>')
    lmap('test', ':Test<cr>')
    lmap('run', ':Run<cr>')
    lmap('lib', ':Lib<cr>')
    lmap('tem', ':Template<cr>')
end

-- Commands
-- TODO: make these configurable
function wasp.setup(config)
    config.template_path = config.template_path or
        function() return 'template.' .. vim.fn.expand("%:e") end

    local command = vim.api.nvim_create_user_command
    command('Template', template, {})
    command('Lib', lib_copy, {})
    command('Comp', 'execute "!./comp " . @%', {})
    command('Test', 'execute "!./test"', {})
    command('Out', 'split term://./out', {})
    command('Run', 'execute "Comp | Test"', {})

    if config.competitive_companion ~= nil then
        require('input').setup(config.competitive_companion)
    end
end

return wasp
