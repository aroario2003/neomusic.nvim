local M = {}

function M._internal_play_song(song_path)
    local nm_sock = require("neomusic.socket")
    local nm_win = require("neomusic.window")
    local pfile = io.popen('mpv --no-video --input-ipc-server=' .. nm_sock.sock_path .. ' ' .. song_path)
    if pfile == nil then
        nm_win.notification("Error: Could not execute mpv command to play music")
        return
    end
end

function M._internal_pause_song()
    local nm_sock = require("neomusic.socket")
    nm_sock._write('{ \"command\": [\"set_property\", \"pause\", true] }')
end

function M._internal_unpause_song()
    local nm_sock = require("neomusic.socket")
    nm_sock._write('{ \"command\": [\"set_property\", \"pause\", false] }')
end

return M
