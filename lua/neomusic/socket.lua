local M = { sock_path = "/tmp/mpvsocket" }

---Write to a socket, in this case the mpv socket for ipc
---@param message string
function M._write(message)
    local nm_win = require("neomusic.window")
    local command = string.format("echo '%s' | socat - %s", message, M.sock_path)
    local pfile = io.popen(command)
    if pfile == nil then
        nm_win.notification("Something went wrong writing to the mpv socket")
    end

    local output = {}

    ---@diagnostic disable-next-line:need-check-nil
    for str in pfile:lines() do
        table.insert(output, str)
    end

    return output
end

return M
