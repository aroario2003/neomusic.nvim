local M = {cur_dir = nil, songs_populated = nil, is_playing = nil, is_paused = nil, cur_song = nil}

---Reset state of plugin (this happens when neovim is quit too)
function M.reset_state()
    M.cur_dir = nil
    M.songs_populated = nil
    M.is_playing = nil
    M.is_paused = nil
    M.cur_song = nil
end

---Populate the menu with playlists
function M.populate_playlists()
    local nm = require("neomusic")
    local window = require("neomusic.window")
    local playlists = nm._get_dir_listing(nm.config.playlist_dir)
    M.cur_dir = nm.config.playlist_dir
    vim.api.nvim_buf_set_lines(window.bufnr, 0, -1, false, playlists)
end

---Populate the menu with songs in the playlist
---@param playlist_dir string
function M.populate_songs(playlist_dir)
    local nm = require("neomusic")
    local window = require("neomusic.window")
    local songs = nm._get_dir_listing(playlist_dir)
    M.cur_dir = playlist_dir
    vim.api.nvim_buf_set_lines(window.bufnr, 0, 1, false, {".."})
    vim.api.nvim_buf_set_lines(window.bufnr, 1, -1, false, songs)
    M.songs_populated = true
end

---Update the highlight based on cursor position in the menu
function M.update_hover()
    local window = require("neomusic.window")
    local cur_pos = vim.api.nvim_win_get_cursor(window.win)
    local row = cur_pos[1]-1
    vim.api.nvim_buf_del_extmark(window.bufnr, window.ns, window.extm_id)
    window.extm_id = vim.api.nvim_buf_set_extmark(window.bufnr, window.ns, row, 0, {end_line=row+1, hl_eol=true, hl_group="visual"})
end

---Play the song with mpv
---@param song_path string
function M.play_song(song_path)
    local nm_win = require("neomusic.window")
    local nm_mpv = require("neomusic.mpv")
    nm_mpv._internal_play_song(song_path)
    nm_win.notification("Now Playing: %s", song_path)
    M.cur_song = song_path
    M.is_playing = true
    M.is_paused = false
end

---Pause the song with mpv
function M.pause_song()
    local nm_win = require("neomusic.window")
    local nm_mpv = require("neomusic.mpv")
    nm_mpv._internal_pause_song()
    nm_win.notification("Paused song: %s", M.cur_song)
    M.is_paused = true
    M.is_playing = false
end

---Resume the song with mpv
function M.unpause_song()
    local nm_win = require("neomusic.window")
    local nm_mpv = require("neomusic.mpv")
    nm_mpv._internal_unpause_song()
    nm_win.notification("Resuming song: %s", M.cur_song)
    M.is_paused = false
    M.is_playing = true
end

function M.next_song()
end

function M.prev_song()
end

return M
