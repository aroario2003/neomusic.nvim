local M = {
    back_symbol = " ",
    pause_symbol = "",
    play_symbol = "",
    forward_symbol = " ",
    window_width = 60,
    window_height = 10,
    symbol_row = 3,
}

---Function to draw the song title on the controls window
local function draw_song_title()
    local nm_state = require("neomusic.state")
    local nm_controls_win = require("neomusic.controls.window")

    local start_col = math.floor((M.window_width - nm_state.song_name:len()) / 2)
    local end_col = start_col + nm_state.song_name:len()
    if end_col > M.window_width then
        local char_cut_num = end_col - M.window_width
        nm_state.song_name = string.sub(nm_state.song_name, 1, nm_state.song_name:len() - char_cut_num - 9)
        nm_state.song_name = nm_state.song_name .. "..."
        start_col = math.floor((M.window_width - nm_state.song_name:len()) / 2)
        end_col = start_col + nm_state.song_name:len()
    end
    vim.api.nvim_buf_set_text(nm_controls_win.bufnr, 0, start_col, 1, end_col,
        { nm_state.song_name })
end

---Function to draw the control symbols on the controls window
local function draw_control_symbols()
    local nm_state = require("neomusic.state")
    local nm_controls_win = require("neomusic.controls.window")

    local center_col = math.floor(M.window_width / 2)
    local back_pos = center_col - 13
    local main_symbol_pos = center_col
    local forward_pos = center_col + 13

    if nm_state.is_playing then
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, M.symbol_row, back_pos, M.symbol_row,
            back_pos + M.back_symbol:len(), { M.back_symbol })
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, M.symbol_row, main_symbol_pos, M.symbol_row,
            main_symbol_pos + M.pause_symbol:len(), { M.pause_symbol })
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, M.symbol_row, forward_pos, M.symbol_row,
            forward_pos + M.forward_symbol:len(), { M.forward_symbol })
    else
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, M.symbol_row, back_pos, M.symbol_row,
            back_pos + M.back_symbol:len(), { M.back_symbol })
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, M.symbol_row, main_symbol_pos, M.symbol_row,
            main_symbol_pos + M.play_symbol:len(), { M.play_symbol })
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, M.symbol_row, forward_pos, M.symbol_row,
            forward_pos + M.forward_symbol:len(), { M.forward_symbol })
    end
end

---Toggle the window for the controls
function M.toggle_controls_window()
    local nm_state = require("neomusic.state")
    local nm_controls_win = require("neomusic.controls.window")
    local nm_controls_state = require("neomusic.controls.state")
    local nm_controls_keys = require("neomusic.controls.keymaps")

    if nm_controls_win.win ~= nil and vim.api.nvim_win_is_valid(nm_controls_win.win) then
        nm_controls_win.close_window()
        nm_controls_state.win_is_open = false
        return
    end

    nm_controls_win.create_window("Neomsic Controls", M.window_width, M.window_height)
    nm_controls_state.win_is_open = true

    if nm_state.cur_song == nil then
        nm_state.cur_song = "No song playing"
        nm_state.song_name = "No song playing"
    end

    vim.api.nvim_buf_set_lines(nm_controls_win.bufnr, 0, -1, false, {
        string.rep(" ", M.window_width),
        string.rep(" ", M.window_width),
        string.rep(" ", M.window_width),
        string.rep(" ", M.window_width),
        string.rep(" ", M.window_width),
        string.rep(" ", M.window_width),
        string.rep(" ", M.window_width)
    })

    draw_song_title()
    draw_control_symbols()
    nm_controls_state.tick_controls_playback_time()
    nm_controls_keys.load_keymaps()
end

return M
