local M = {sock_path = "/tmp/mpvsocket"}

---Write to a socket, in this case the mpv socket for ipc
---@param message string
function M._write(message)
    local nm_win = require("neomusic.window")
    local command = string.format("echo '%s' | socat - %s", message, M.sock_path)
    local pfile = io.popen(command)
    if pfile == nil then
        nm_win.notification("Error writting to mpv socket at: %s", M.sock_path)
        return
    end
    local _ = pfile:lines()
end

return M
