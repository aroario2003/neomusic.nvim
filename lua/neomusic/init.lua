local M = {}

M.config = {
    playlist_dir = os.getenv("HOME") .. "/Music",
    notif_timeout = 5,
    song_queue_max_items = nil,
    global_keymaps = {
        keybinds = {
            { 'n', '<leader>nt',  ':Neomusic toggle_playlist_menu<CR>' },
            { 'n', '<leader>nc',  ':Neomusic toggle_controls<CR>' },
            { 'n', '<leader>ps',  ':Neomusic unpause_song<CR>' },
            { 'n', '<leader>Ps',  ':Neomusic pause_song<CR>' },
            { 'n', '<leader>nns', ':Neomusic next_song<CR>' },
            { 'n', '<leader>nps', ':Neomusic prev_song<CR>' },
            { 'n', '<leader>nis', ':Neomusic increase_volume 5<CR>' },
            { 'n', '<leader>nds', ':Neomusic decrease_volume 5<CR>' },
            { 'n', '<leader>nqv', ':Neomusic toggle_queue_view<CR>' },
            { 'n', '<leader>npq', ':Neomusic play_queue<CR>' },
            { 'n', '<leader>nsp', ':Neomusic search_playlists<CR>' },
        }
    }
}

---Internal function to list directories
---@param dir string
---@return table
function M._get_dir_listing(dir)
    local nm_win = require("neomusic.window")
    local listing = {}
    local i, pfile = 0, io.popen('ls "' .. dir .. '"')
    if pfile == nil then
        nm_win.notification("Could not get directory listing for %s", dir)
    end
    ---@diagnostic disable-next-line:need-check-nil
    for filename in pfile:lines() do
        i = i + 1
        table.insert(listing, filename)
    end
    ---@diagnostic disable-next-line:need-check-nil
    pfile:close()
    return listing
end

---Highlight the current hover with cursor in the menu
local function highlight_current_hover()
    local nm_win = require("neomusic.window")
    local cur_pos = vim.api.nvim_win_get_cursor(nm_win.win)
    local row = cur_pos[1] - 1
    nm_win.extm_id = vim.api.nvim_buf_set_extmark(nm_win.bufnr, nm_win.ns, row, 0,
        { end_line = row + 1, hl_eol = true, hl_group = "visual" })
end

---Enter the current hover if possible
function M.enter_selection()
    local nm_state = require("neomusic.state")
    local nm_keys = require("neomusic.keymaps")
    local nm_win = require("neomusic.window")

    local cur_pos = vim.api.nvim_win_get_cursor(nm_win.win)
    local row = cur_pos[1] - 1
    local text = vim.api.nvim_buf_get_lines(nm_win.bufnr, row, row + 1, false)
    -- indexing text for only one value because it should be a single line
    local full_playlist_dir_path = M.config.playlist_dir .. "/" .. text[1]
    if not nm_state.songs_populated then
        vim.api.nvim_buf_set_lines(nm_win.bufnr, 0, -1, false, {})
        nm_state.populate_songs(full_playlist_dir_path)
        highlight_current_hover()
        nm_keys.load_keymaps()
    else
        local song_name = vim.api.nvim_buf_get_lines(nm_win.bufnr, row, row + 1, false)
        if song_name[1] == ".." then
            vim.api.nvim_buf_set_lines(nm_win.bufnr, 0, -1, false, {})
            nm_state.populate_playlists()
            nm_state.cur_dir = M.config.playlist_dir
            nm_state.songs_populated = false
            highlight_current_hover()
        else
            if nm_state.queue_is_playing then
                nm_state.queue_is_playing = false
            end

            nm_state.play_song(nm_state.cur_dir .. "/" .. song_name[1])
        end
    end
end

---Toggle the menu of playlists and songs
function M.toggle_playlist_menu()
    local nm_keys = require("neomusic.keymaps")
    local nm_state = require("neomusic.state")
    local nm_win = require("neomusic.window")

    if nm_win.win ~= nil and vim.api.nvim_win_is_valid(nm_win.win) then
        nm_win.close_window()
        return
    end

    nm_win.create_window("Neomusic Playlist Picker", 100, 20)
    if nm_state.cur_dir == nil or nm_state.cur_dir == M.config.playlist_dir then
        nm_state.populate_playlists()
    else
        local listing = M._get_dir_listing(nm_state.cur_dir)
        vim.api.nvim_buf_set_lines(nm_win.bufnr, 0, 1, false, { ".." })
        vim.api.nvim_buf_set_lines(nm_win.bufnr, 1, -1, false, listing)
    end

    highlight_current_hover()
    nm_keys.load_keymaps()
end

---Setup and configuration for the plugin
---@param conf table
function M.setup(conf)
    local nm_keys = require("neomusic.keymaps")
    local nm_command = require("neomusic.command")

    if conf then
        for key, val in pairs(M.config) do
            if conf[key] == nil then
                conf[key] = val
            end
        end
    end
    M.config = conf or M.config
    nm_keys.load_global_keymaps()
    nm_command.init_command()
end

return M
