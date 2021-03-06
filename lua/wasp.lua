--
-- the Wrong Answer tool for Sports Programming
--

if vim.g.loaded_wasp == 1 then return end
vim.g.loaded_wasp = 1

local wasp = {}
local gconfig = {
    template_path = function() return 'template.' .. vim.fn.expand("%:e") end, -- either a function or a string
    lib_path = 'lib', -- either a function or a string
    competitive_companion = nil,
}

-- :Lib (requires FZF and ripgrep for now!)
-- TODO: support Telescope & other fuzzy finders as well
-- TODO: support something that's not ripgrep (I'm pretty sure you can list files with `find`??)
local function lib_copy()
    local path = gconfig.lib_path
    if type(path) == "function" then
        path = path()
    end

    vim.fn['fzf#run'](vim.fn['fzf#wrap'](vim.fn['fzf#vim#with_preview']({
        source = 'rg ' .. path .. ' --files',
        sink = 'read',
        options = { '--prompt', 'Lib> ', },
    })))
end

-- :Template
local function template()
    local path = gconfig.template_path
    local t = type(path)
    if t == "function" then
        path = path()
    end

    vim.cmd(string.format([[
        normal! ggdG
        silent execute "0r %s"
        redraw!
        normal! gg
    ]], path))
end

local function run()
    vim.cmd('Comp')
    vim.cmd('Test')
end

-- Keymaps
function wasp.set_default_keymaps()
    local map = vim.api.nvim_set_keymap
    local function lmap(lhs, rhs) -- leader map
        map('n', '<leader>'..lhs, rhs, {noremap=true})
    end

    lmap('comp', ':WaspComp<cr>')
    lmap('test', ':WaspTest<cr>')
    lmap('run', ':WaspRun<cr>')
    lmap('lib', ':WaspLib<cr>')
    lmap('tem', ':WaspTemplate<cr>')
    lmap('vg', ':WaspViewGraph<cr>')
end

-- Commands
-- TODO: make these configurable
function wasp.setup(config)
    vim.validate {
        config = { config, 'table' }
    }

    gconfig = vim.tbl_deep_extend('force', gconfig, config)

    local command = vim.api.nvim_create_user_command
    command('WaspTemplate', template, {})
    command('WaspLib', lib_copy, {})
    command('WaspComp', 'execute "!./comp " . @%', {})
    command('WaspTest', 'execute "!./test"', {})
    command('WaspOut', 'split term://./out', {})
    command('WaspRun', run, {})

    if gconfig.competitive_companion ~= nil then
        require('wasp.input').setup(config.competitive_companion)
    end
end

return wasp
