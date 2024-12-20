local M = {
    cur_dir = nil,
    songs_populated = nil,
    is_playing = false,
    is_paused = false,
    cur_song = nil,
    song_name = nil,
    next_song_name = nil,
    prev_song_name = nil,
    song_queue = nil,
    mouse_clicked = 0,
    prev_mouse_row = nil,
    song_finished = false,
}

---Reset state of plugin (this happens when neovim is quit too)
function M.reset_state()
    M.cur_dir = nil
    M.songs_populated = nil
    M.is_playing = nil
    M.is_paused = nil
    M.cur_song = nil
    M.song_queue = nil
end

---Populate the menu with playlists
function M.populate_playlists()
    local nm = require("neomusic")
    local nm_win = require("neomusic.window")

    local playlists = nm._get_dir_listing(nm.config.playlist_dir)
    M.cur_dir = nm.config.playlist_dir
    vim.api.nvim_buf_set_lines(nm_win.bufnr, 0, -1, false, playlists)
end

---Populate the menu with songs in the playlist
---@param playlist_dir string
function M.populate_songs(playlist_dir)
    local nm = require("neomusic")
    local nm_win = require("neomusic.window")

    local songs = nm._get_dir_listing(playlist_dir)
    M.cur_dir = playlist_dir
    vim.api.nvim_buf_set_lines(nm_win.bufnr, 0, 1, false, { ".." })
    vim.api.nvim_buf_set_lines(nm_win.bufnr, 1, -1, false, songs)
    M.songs_populated = true
end

---Update the highlight based on cursor position in the menu
function M.update_hover()
    local nm_win = require("neomusic.window")

    local cur_pos = vim.api.nvim_win_get_cursor(nm_win.win)
    local row = cur_pos[1] - 1
    vim.api.nvim_buf_del_extmark(nm_win.bufnr, nm_win.ns, nm_win.extm_id)
    nm_win.extm_id = vim.api.nvim_buf_set_extmark(nm_win.bufnr, nm_win.ns, row, 0,
        { end_row = row + 1, hl_eol = true, hl_group = "visual" })
end

function M.handle_mouse_click()
    local nm_win = require("neomusic.window")

    local mouse_pos = vim.fn.getmousepos()
    local mouse_row = mouse_pos.line
    local lines = vim.api.nvim_buf_get_lines(nm_win.bufnr, 0, -1, false)

    if mouse_row > #lines then
        return
    end

    mouse_row = mouse_row - 1

    if M.prev_mouse_row then
        if mouse_row + 1 == M.prev_mouse_row then
            M.mouse_clicked = 0
            M.prev_mouse_row = nil
            require("neomusic").enter_selection()
            return
        end
    end

    vim.api.nvim_buf_del_extmark(nm_win.bufnr, nm_win.ns, nm_win.extm_id)
    nm_win.extm_id = vim.api.nvim_buf_set_extmark(nm_win.bufnr, nm_win.ns, mouse_row, 0,
        { end_row = mouse_row + 1, hl_eol = true, hl_group = "visual" })
    vim.api.nvim_win_set_cursor(nm_win.win, { mouse_row + 1, 0 })
    M.mouse_clicked = M.mouse_clicked + 1
    M.prev_mouse_row = mouse_row + 1
end

---Get the previous and next song
local function get_prev_next_songs()
    local nm = require("neomusic")

    local songs = nm._get_dir_listing(M.cur_dir)
    if #songs >= 2 then
        for i, song in ipairs(songs) do
            local full_song_path = M.cur_dir .. song
            if M.cur_song == full_song_path then
                if i == 1 then
                    M.next_song_name = songs[i + 1]
                    M.prev_song_name = nil
                elseif i == 2 and #songs == 2 then
                    M.prev_song_name = songs[i - 1]
                    M.next_song_name = nil
                elseif i == #songs then
                    M.prev_song_name = songs[i - 1]
                    M.next_song_name = nil
                else
                    M.prev_song_name = songs[i - 1]
                    M.next_song_name = songs[i + 1]
                end
            end
        end
    end
end

local function get_song_name(song_path)
    local split = string.gmatch(song_path, "([^" .. "/" .. "]+)")
    local song_path_parts = {}
    for item in split do
        table.insert(song_path_parts, item)
    end
    return song_path_parts[#song_path_parts]
end

---Play the song with mpv
---@param song_path string
function M.play_song(song_path)
    local nm_win = require("neomusic.window")
    local nm_mpv = require("neomusic.mpv")

    nm_mpv._kill_mpv()
    nm_mpv._internal_play_song(song_path)
    nm_win.notification("Now Playing: %s", song_path)

    M.song_name = get_song_name(song_path)
    M.cur_song = song_path
    M.is_playing = true
    M.is_paused = false
    get_prev_next_songs()
end

---Pause the song with mpv
function M.pause_song()
    local nm_win = require("neomusic.window")
    local nm_mpv = require("neomusic.mpv")

    if M.cur_song == nil or M.cur_song == "No song playing" then
        nm_win.notification("No song is currently playing")
        return
    elseif M.is_paused then
        nm_win.notification("The song is already paused")
        return
    end

    nm_mpv._internal_pause_song()
    nm_win.notification("Paused song: %s", M.cur_song)
    M.is_paused = true
    M.is_playing = false
end

---Resume the song with mpv
function M.unpause_song()
    local nm_win = require("neomusic.window")
    local nm_mpv = require("neomusic.mpv")

    if M.cur_song == nil or M.cur_song == "No song playing" then
        nm_win.notification("No song is currently playing")
        return
    elseif M.is_playing then
        nm_win.notification("The song is already playing")
        return
    end

    nm_mpv._internal_unpause_song()
    nm_win.notification("Resuming song: %s", M.cur_song)
    M.is_paused = false
    M.is_playing = true
end

---Play the next song in the playlist
function M.next_song()
    local nm_mpv = require("neomusic.mpv")
    local nm_win = require("neomusic.window")

    if M.next_song_name ~= nil then
        nm_mpv._kill_mpv()
        nm_mpv._internal_play_song(M.next_song_name)
        M.cur_song = M.next_song_name
        M.song_name = get_song_name(M.cur_song)
        nm_win.notification("Playing next song: %s", M.cur_song)
        get_prev_next_songs()
    else
        nm_win.notification("No next song to play")
    end
end

---Play the previous song in the playlist
function M.prev_song()
    local nm_mpv = require("neomusic.mpv")
    local nm_win = require("neomusic.window")

    if M.prev_song_name ~= nil then
        nm_mpv._kill_mpv()
        nm_mpv._internal_play_song(M.prev_song_name)
        M.cur_song = M.prev_song_name
        M.song_name = get_song_name(M.cur_song)
        nm_win.notification("Playing previous song: %s", M.cur_song)
        get_prev_next_songs()
    else
        nm_win.notification("No previous song to play")
    end
end

--- Set the volume of mpv
--- @param vol number
function M.set_volume(vol)
    local nm_mpv = require("neomusic.mpv")
    local nm_win = require("neomusic.window")

    nm_mpv._internal_set_volume(vol)
    nm_win.notification("Volume set to %d%%", vol)
end

---Increase the volume of mpv
---@param inc number
function M.increase_volume(inc)
    local nm_mpv = require("neomusic.mpv")
    local nm_win = require("neomusic.window")

    nm_mpv._internal_increase_volume(inc)
    nm_win.notification("Volume increased to %d%%", nm_mpv._get_current_volume())
end

---Decrease the volume of mpv
---@param dec number
function M.decrease_volume(dec)
    local nm_mpv = require("neomusic.mpv")
    local nm_win = require("neomusic.window")

    nm_mpv._internal_decrease_volume(dec)
    nm_win.notification("Volume decreased to %d%%", nm_mpv._get_current_volume())
end

return M
