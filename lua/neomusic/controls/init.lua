local M = {
    back_symbol = " ",
    pause_symbol = "",
    play_symbol = "",
    forward_symbol = " ",
    window_width = 60,
    window_height = 10,
    symbol_row = 3,
}


---Toggle the window for the controls
function M.toggle_controls_window()
    local nm_controls_win = require("neomusic.controls.window")
    local nm_controls_keys = require("neomusic.controls.keymaps")
    local nm_state = require("neomusic.state")

    if nm_controls_win.win ~= nil and vim.api.nvim_win_is_valid(nm_controls_win.win) then
        nm_controls_win.close_window()
        return
    end

    nm_controls_win.create_window("Neomsic Controls", M.window_width, M.window_height)
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

    local start_col = math.floor((M.window_width - nm_state.song_name:len()) / 2)
    local end_col = start_col + nm_state.song_name:len()
    if end_col > M.window_width then
        local char_cut_num = end_col - M.window_width
        nm_state.song_name = string.sub(nm_state.song_name, 1, nm_state.song_name:len() - char_cut_num - 9)
        nm_state.song_name = nm_state.song_name .. "..."
        start_col = math.floor((M.window_width - nm_state.song_name:len()) / 2)
        end_col = start_col + nm_state.song_name:len()
        print(end_col)
    end
    vim.api.nvim_buf_set_text(nm_controls_win.bufnr, 0, start_col, 1, end_col,
        { nm_state.song_name })

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
    nm_controls_keys.load_keymaps()
end

---Update the play/pause symbol when the song is either paused or playing
---@param row number
---@param col_start number
---@param col_end number
---@param mouse_row number
---@param mouse_col number
function M.update_play_pause_symbol(row, col_start, col_end, mouse_row, mouse_col)
    local nm_state = require("neomusic.state")
    local nm_controls_win = require("neomusic.controls.window")

    print("mouse row: " .. mouse_row .. " " .. "row: ", row + 1)
    if row + 1 == mouse_row then
        if mouse_col >= col_start + 1 and mouse_col <= col_end + 1 then
            if nm_state.is_playing then
                nm_state.pause_song()
                vim.api.nvim_buf_set_text(nm_controls_win.bufnr, row, col_start, row, col_end, { M.play_symbol })
            elseif nm_state.is_paused then
                nm_state.unpause_song()
                vim.api.nvim_buf_set_text(nm_controls_win.bufnr, row, col_start, row, col_end, { M.pause_symbol })
            end
        end
    end
end

return M
