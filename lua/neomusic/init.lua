local M = {}
M.config = {
    playlist_dir=os.getenv("HOME") .. "/Music",
    notif_timeout = 5,
    global_keymaps = {
        keybinds = {
            {'n', '<leader>nt', ':lua require("neomusic").toggle_playlist_menu()<CR>'},
            {'n', '<leader>ps', ':lua require("neomusic.state").unpause_song()<CR>'},
            {'n', '<leader>Ps', ':lua require("neomusic.state").pause_song()<CR>'}
        }
    }
}

function M._get_dir_listing(dir)
    local window = require("neomusic.window")
    local listing = {}
    local i, pfile = 0, io.popen('ls "' .. dir .. '"')
    if pfile == nil then
        vim.api.nvim_buf_set_lines(window.bufnr, 0, -1, false, {"Could not get directory listing for " .. dir})
    end
    for filename in pfile:lines() do
        i = i+1
        table.insert(listing, filename)
    end
    pfile:close()
    return listing
end

local function highlight_current_hover()
    local window = require("neomusic.window")
    local cur_pos = vim.api.nvim_win_get_cursor(window.win)
    local row = cur_pos[1]-1
    window.extm_id = vim.api.nvim_buf_set_extmark(window.bufnr, window.ns, row, 0, {end_line=row+1, hl_eol=true, hl_group="visual"})
end

function M.enter_selection()
    local state = require("neomusic.state")
    local nm_keys = require("neomusic.keymaps")
    local window = require("neomusic.window")

    local cur_pos = vim.api.nvim_win_get_cursor(window.win)
    local row = cur_pos[1]-1
    local text = vim.api.nvim_buf_get_lines(window.bufnr, row, row+1, false)
    -- indexing text for only one value because it should be a single line
    local full_playlist_dir_path = M.config.playlist_dir .. "/" .. text[1]
    if not state.songs_populated then
        vim.api.nvim_buf_set_lines(window.bufnr, 0, -1, false, {})
        state.populate_songs(full_playlist_dir_path)
        highlight_current_hover()
        nm_keys.load_keymaps()
    else
        local song_name = vim.api.nvim_buf_get_lines(window.bufnr, row, row+1, false)
        if song_name[1] == ".." then
            vim.api.nvim_buf_set_lines(window.bufnr, 0, -1, false, {})
            state.populate_playlists()
            state.cur_dir = M.config.playlist_dir
            state.songs_populated = false
            highlight_current_hover()
        else
            state.play_song(state.cur_dir .. "/" .. song_name[1])
        end
    end
end

function M.toggle_playlist_menu()
    local nm_keys = require("neomusic.keymaps")
    local state = require("neomusic.state")
    local window = require("neomusic.window")

    if window.win ~= nil and vim.api.nvim_win_is_valid(window.win) then
       window.close_window()
       return
    end

    window.create_window("Neomusic Playlist Picker", 100, 20)
    if state.cur_dir == nil or state.cur_dir == M.config.playlist_dir then
        state.populate_playlists()
    else
       local listing = M._get_dir_listing(state.cur_dir)
       vim.api.nvim_buf_set_lines(window.bufnr, 0, 1, false, {".."})
       vim.api.nvim_buf_set_lines(window.bufnr, 1, -1, false, listing)
    end
    highlight_current_hover()
    nm_keys.load_keymaps()
end

function M.setup(conf)
    if not conf then
        return
    end

    M.config = conf
end

return M
