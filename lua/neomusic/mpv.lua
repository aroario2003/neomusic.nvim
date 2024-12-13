local M = {}

function M._internal_play_song(song_path)
    local nm_sock = require("neomusic.socket")
    local nm_win = require("neomusic.window")
    vim.fn.jobstart('mpv --no-video --input-ipc-server=' .. nm_sock.sock_path .. ' ' .. song_path, {
        on_exit = function(_, exit_code, _)
            if exit_code ~= 0 then
                nm_win.notification("Something when wrong exiting mpv")
            else
                nm_win.notification("Song finished")
            end
        end,
    })
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

