local M = {bufnr=nil, win=nil, ns=vim.api.nvim_create_namespace("neomusic"), extm_id=nil}
M.config = {playlist_dir=os.getenv("HOME") .. "/Music"}

local function create_window(name, width, height)
    local win_settings = {
        relative='editor',
        style='minimal',
        border='single',
        row=(vim.o.lines-height)/2,
        col=(vim.o.columns-width)/2,
        width=width,
        height=height,
        title=name,
        title_pos='center'
    }

    M.bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[M.bufnr].filetype = 'neomusic'
    M.win = vim.api.nvim_open_win(M.bufnr, true, win_settings)
end

local function close_window()
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
    M.bufnr = nil
end

function M._get_dir_listing(dir)
    local listing = {}
    local i, pfile = 0, io.popen('ls "' .. dir .. '"')
    if pfile == nil then
        vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, {"Could not get directory listing for " .. dir})
    end
    for filename in pfile:lines() do
        i = i+1
        table.insert(listing, filename)
    end
    pfile:close()
    return listing
end

local function highlight_current_hover()
    local cur_pos = vim.api.nvim_win_get_cursor(M.win)
    local row = cur_pos[1]-1
    M.extm_id = vim.api.nvim_buf_set_extmark(M.bufnr, M.ns, row, 0, {end_line=row+1, hl_eol=true, hl_group="visual"})
end

function M.enter_selection()
    local state = require("neomusic.state")
    local nm_keys = require("neomusic.keymaps")

    local cur_pos = vim.api.nvim_win_get_cursor(M.win)
    local row = cur_pos[1]-1
    local text = vim.api.nvim_buf_get_lines(M.bufnr, row, row+1, false)
    -- indexing text for only one value because it should be a single line
    local full_playlist_dir_path = M.config.playlist_dir .. "/" .. text[1]
    if not state.songs_populated then
        vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, {})
        state.populate_songs(full_playlist_dir_path)
        highlight_current_hover()
        nm_keys.load_keymaps()
    else
        local song_name = vim.api.nvim_buf_get_lines(M.bufnr, row, row+1, false)
        if song_name[1] == ".." then
            vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, {})
            state.populate_playlists()
            state.cur_dir = M.config.playlist_dir
            state.songs_populated = false
        else
            state.play_song(state.cur_dir .. "/" .. song_name[1])
        end
    end
end

function M.toggle_playlist_menu()
    local nm_keys = require("neomusic.keymaps")
    local state = require("neomusic.state")

    if M.win ~= nil and vim.api.nvim_win_is_valid(M.win) then
       close_window()
       return
    end

    create_window("Neomusic Picker", 100, 20)
    if state.cur_dir == nil then
        state.populate_playlists()
    else
       local listing = M._get_dir_listing(state.cur_dir)
       vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, listing)
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
