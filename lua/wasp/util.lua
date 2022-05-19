local M = {}

-- Do people use this pattern in lua too?
M.system = (function()
    local uname = vim.loop.os_uname()
    if uname.sysname:match("^Linux") then
        if uname.version:match("Microsoft") then
            return "WSL"
        else
            return "Linux"
        end
    else
        return "?"
    end
end)()

function M.default_viewer()
    local tab = {
        WSL = 'wslview',
        Linux = 'xdg-open',
        ['?'] = 'open',
    }
    return tab[M.system]
end

return M
