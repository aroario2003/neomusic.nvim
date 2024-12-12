local M = {cur_dir = nil, songs_populated = nil, is_playing = nil, is_paused = nil, cur_song = nil}

function M.reset_state()
    M.cur_dir = nil
    M.songs_populated = nil
    M.is_playing = nil
    M.is_paused = nil
    M.cur_song = nil
end

function M.populate_playlists()
    local nm = require("neomusic")
    local playlists = nm._get_dir_listing(nm.config.playlist_dir)
    M.cur_dir = nm.config.playlist_dir
    vim.api.nvim_buf_set_lines(nm.bufnr, 0, -1, false, playlists)
end

function M.populate_songs(playlist_dir)
    local nm = require("neomusic")
    local songs = nm._get_dir_listing(playlist_dir)
    M.cur_dir = playlist_dir
    vim.api.nvim_buf_set_lines(nm.bufnr, 0, 1, false, {".."})
    vim.api.nvim_buf_set_lines(nm.bufnr, 1, -1, false, songs)
    M.songs_populated = true
end

function M.update_hover()
    local nm = require("neomusic")
    local cur_pos = vim.api.nvim_win_get_cursor(nm.win)
    local row = cur_pos[1]-1
    vim.api.nvim_buf_del_extmark(nm.bufnr, nm.ns, nm.extm_id)
    nm.extm_id = vim.api.nvim_buf_set_extmark(nm.bufnr, nm.ns, row, 0, {end_line=row+1, hl_eol=true, hl_group="visual"})
end

function M.play_song(song_path)
    print("Playing song: ", song_path)
    M.cur_song = song_path
    M.is_playing = true
    M.is_paused = false
end

function M.pause_song()
    print("Paused song: ", M.cur_song)
    M.is_paused = true
    M.is_playing = false
end

function M.next_song()
end

function M.prev_song()
end

return M
