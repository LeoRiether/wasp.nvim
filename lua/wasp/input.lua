--
-- Gets input data from Competitive Companion and writes to
-- some input file
-- (https://github.com/jmerle/competitive-companion)
--
--

local M = {}
local opts = {
    file = 'inp',
}

local function write(filename, content)
    local file = io.open(filename, "w")
    file:write(content)
    file:close()
end

local function input(problem)
    local file = opts.file

    -- Ensure we have a buffer called `file` in the first place
    if vim.fn.bufnr(file) == -1 then
        vim.api.nvim_err_writeln("Wasp: file buffer not found")
        return
    end

    -- Get test cases
    local cases = {}
    for _, test in pairs(problem.tests) do
        cases[#cases+1] = test.input
    end
    cases = table.concat(cases, string.rep('-' , 35) .. '\n')

    -- Format a header with padded '-' like "---- Problem Name ----"
    local pad0 = (35 - #problem.name - 2 + 1) / 2
    local pad1 = (35 - #problem.name - 2) / 2
    if pad0 < 3 then pad0 = 3 end

    -- Format the final input text
    local text = string.format('%s %s %s\n%s', string.rep('-', pad0), problem.name, string.rep('-', pad1), cases)

    -- Write it to `file`
    write(file, text)

    -- Reload the `file` buffer, then go back to the original one
    local cur_buf = vim.fn.bufnr("%")
    vim.cmd(string.format('b %s | e | b %d', file, cur_buf))

    vim.api.nvim_out_write("Wasp updated test cases\n")
end

-- :h tcp
local function create_server(host, port, on_connect)
    local server = vim.loop.new_tcp()
    server:bind(host, port)
    server:listen(128, function(err)
        assert(not err, err)  -- Check for errors.
        local sock = vim.loop.new_tcp()
        server:accept(sock)  -- Accept client connection.
        on_connect(sock)  -- Start reading messages.
    end)
    return server
end

local function on_receive(body)
    local idx = body:match("^.*()\r\n") -- copied from p00f/cphelper.nvim
    if idx == nil then return end -- ensure the message is in the right format
    body = body:sub(idx + 1)
    vim.schedule(function()
        input(vim.json.decode(body))
    end)
end

function M.setup(o)
    opts = vim.tbl_extend('force', opts, o)

    create_server('127.0.0.1', 10043, function(sock)
        local buffer = {}
        sock:read_start(function(err, chunk)
            assert(not err, err)  -- Check for errors.
            if chunk then
                buffer[#buffer+1] = chunk
            else  -- EOF (stream closed).
                local body = table.concat(buffer, "")
                on_receive(body)
                sock:close() -- Always close handles to avoid leaks.
                buffer = {}
            end
        end)
    end)
end

return M
