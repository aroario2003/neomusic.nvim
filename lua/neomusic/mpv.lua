local M = {mpv_pid = nil}

function M._internal_play_song(song_path)
    local nm_sock = require("neomusic.socket")
    local nm_win = require("neomusic.window")
    local job_id = vim.fn.jobstart('mpv --no-video --input-ipc-server=' .. nm_sock.sock_path .. ' ' .. song_path, {
        on_exit = function(_, exit_code, _)
            if exit_code ~= 0 then
                M.mpv_pid = nil
                nm_win.notification("Something when wrong exiting mpv")
            else
                M.mpv_pid = nil
                nm_win.notification("Song finished")
            end
        end,
    })
    M.mpv_pid = vim.fn.jobpid(job_id)
end

function M._internal_pause_song()
    local nm_sock = require("neomusic.socket")
    nm_sock._write('{ \"command\": [\"set_property\", \"pause\", true] }')
end

function M._internal_unpause_song()
    local nm_sock = require("neomusic.socket")
    nm_sock._write('{ \"command\": [\"set_property\", \"pause\", false] }')
end

function M._kill_mpv()
    local nm_win = require("neomusic.window")
   if not M.mpv_pid then
        return
    end

    local success = os.execute("kill -9 " .. M.mpv_pid)
    if not success then
       nm_win.notification("Something went wrong trying to kill mpv process with pid: %d", M.mpv_pid)
    end
end

return M

