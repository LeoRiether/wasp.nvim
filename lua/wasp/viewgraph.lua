local M = {}
local opts = {}

function M.generate_and_view(input_file)
    local img = vim.fn.tempname() .. '.jpg'

    pcall(function()
        vim.cmd(string.format('!"%s" -Tjpg -o "%s" "%s"', opts.dot, img, input_file))
        vim.cmd(string.format('!"%s" "%s"', opts.viewer, img))
    end)
end

function M.setup(o)
    opts = vim.tbl_extend('force', opts, o)
    vim.api.nvim_create_user_command('WaspViewGraph', function()
        M.generate_and_view('inp') -- TODO: make input file configurable
                                   -- (probably will be a scratch buffer)
    end, {})
end

return M
