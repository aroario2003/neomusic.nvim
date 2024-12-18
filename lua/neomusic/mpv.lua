local M = {mpv_pid = nil}

---Internal function to play a song with mpv
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

---Internal function to pause a song
function M._internal_pause_song()
    local nm_sock = require("neomusic.socket")
    nm_sock._write('{ \"command\": [\"set_property\", \"pause\", true] }')
end

---Internal function to unpause a song 
function M._internal_unpause_song()
    local nm_sock = require("neomusic.socket")
    nm_sock._write('{ \"command\": [\"set_property\", \"pause\", false] }')
end

---Internal function to set the volume of mpv
---@param vol number
function M._internal_set_volume(vol)
    local nm_sock = require("neomusic.socket")
    local nm_win = require("neomusic.window")

    if vol > 100 then
        nm_win.notification("Setting volume to more than 100% is not allowed, setting to 100%")
        vol = 100
    elseif vol < 0 then
        nm_win.notification("Setting volume to less than 0% is not allowed, setting to 0%")
        vol = 0
    end

    nm_sock._write(string.format('{\"command\": [\"set_property\", \"volume\", %d] }', vol))
end

---Internal function to increase the volume by some increment
---@param inc number
function M._internal_increase_volume(inc)
    local nm_win = require("neomusic.window")

    local vol = M._get_current_volume()
    vol = vol + inc
    if vol > 100 then
        nm_win.notification("The volume went over the max, setting to 100%")
        vol = 100
    end

    M._internal_set_volume(vol)
end

---Internal function to decrease the volume by some decrement
---@param dec number
function M._internal_decrease_volume(dec)
    local nm_win = require("neomusic.window")

    local vol = M._get_current_volume()
    vol = vol - dec
    if vol < 0 then
        nm_win.notification("The volume went below the minimum, setting to 0%")
        vol = 0
    end

    M._internal_set_volume(vol)
end

---Internal function to kill the mpv process if it is still running
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

---Internal function to get the song duration by using the mpv socket
---@return number
function M._get_song_duration()
    local nm_sock = require("neomusic.socket")

    local ret = nm_sock._write('{\"command\": [\"get_property\", \"duration\"]}')
    local split = string.gmatch(ret[1], "([^"..",".."]+)")
    local data_parts = {}

    for item in split do
        if string.find(item, "data") then
            local data = string.gmatch(item, "([^"..":".."]+)")
            for section in data do
               table.insert(data_parts, section)
            end
            break
        end
    end
    return tonumber(data_parts[2], 10)
end

---Internal function to get the current volume of mpv
---@return integer
function M._get_current_volume()
    local nm_sock = require("neomusic.socket")

    local ret = nm_sock._write('{\"command\": [\"get_property\", \"volume\"] }')
    local split = string.gmatch(ret[1], "([^"..",".."]+)")
    local data_parts = {}

    for item in split do
        if string.find(item, "data") then
            local data = string.gmatch(item, "([^"..":".."]+)")
            for section in data do
                table.insert(data_parts, section)
            end
            break
        end
    end
    return tonumber(data_parts[2], 10)
end

return M

