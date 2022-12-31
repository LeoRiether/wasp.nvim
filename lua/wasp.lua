--
-- the Wrong Answer tool for Sports Programming
--

if vim.g.loaded_wasp == 1 then return end
vim.g.loaded_wasp = 1

local util = require('wasp.util')

local wasp = {}
local opts = {
    template_path = function() return 'template.' .. vim.fn.expand("%:e") end, -- either a function or a string
    lib = {
        finder = 'fzf',
        path = 'lib',
    },
    competitive_companion = nil,
    graph = {
        dot = 'dot',
        viewer = util.default_viewer()
    }
}

local function resolve_lib_path(args)
    local path = opts.lib.path
    if args.args ~= nil and args.args ~= "" then
        path = args.args
    elseif type(path) == "function" then
        path = path()
    end
    return path
end


-- NOTE: :WaspLib (requires either {fzf+fzf.vim+rg} or {telescope})
-- todo: support something that's not ripgrep (i'm pretty sure you can list files with `find`??)
local function fzf_lib_copy(args)
    local path = resolve_lib_path(args)
    vim.fn['fzf#run'](vim.fn['fzf#wrap'](vim.fn['fzf#vim#with_preview']({
        source = 'rg ' .. path .. ' --files',
        sink = 'read',
        options = { '--prompt', 'Lib> ', },
    })))
end

local function telescope_lib_copy(args)
    local path = resolve_lib_path(args)
    local telescope = require'telescope.builtin'
    local actions = require'telescope.actions'
    local action_state = require'telescope.actions.state'

    local function select(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd('read ' .. path .. '/' .. selection.value)
    end

    telescope.find_files {
        cwd = path,
        prompt_title = 'Lib',
        attach_mappings = function(_, _)
            actions.select_default:replace(select)
            return true
        end,
    }
end

-- :WaspTemplate
local function template()
    local path = opts.template_path
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
    vim.cmd('WaspComp')
    vim.cmd('WaspTest')
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
function wasp.setup(o)
    vim.validate {
        o = { o, 'table' }
    }

    opts = vim.tbl_deep_extend('force', opts, o)

    local command = vim.api.nvim_create_user_command
    command('WaspTemplate', template, {})

    if opts.lib.finder == 'fzf' then
        command('WaspLib', fzf_lib_copy, { nargs='?' })
    else
        command('WaspLib', telescope_lib_copy, { nargs='?' })
    end

    command('WaspComp', 'execute "!./comp " . @%', {})
    command('WaspTest', 'execute "!./test"', {})
    command('WaspOut', 'split term://./out', {})
    command('WaspRun', run, {})

    if opts.competitive_companion ~= nil then
        require('wasp.input').setup(opts.competitive_companion)
    end

    require('wasp.viewgraph').setup(opts.graph)
end

return wasp
