local M = {}

---Load the keymaps for the controls window
function M.load_keymaps()
    local nm_state = require("neomusic.state")
    local nm_controls = require("neomusic.controls")
    local nm_controls_win = require("neomusic.controls.window")
    local nm_controls_state = require("neomusic.controls.state")

    vim.keymap.set('n', '<LeftMouse>', function()
        local center_col = math.floor(nm_controls.window_width / 2)
        local main_symbol_pos = center_col
        local back_symbol_pos = center_col - nm_controls.symbol_offset
        local forward_symbol_pos = center_col + nm_controls.symbol_offset

        local mouse_pos = vim.fn.getmousepos()
        local mouse_row = mouse_pos.line
        local mouse_col = mouse_pos.column

        if nm_controls.symbol_row + 1 == mouse_row then
            if mouse_col >= back_symbol_pos + 1 and mouse_col <= back_symbol_pos + nm_controls.back_symbol:len() + 1 then
                nm_state.prev_song()
            elseif mouse_col >= forward_symbol_pos + 1 and mouse_col <= forward_symbol_pos + nm_controls.forward_symbol:len() + 1 then
                nm_state.next_song()
            end
        end

        if nm_state.is_playing then
            nm_controls_state.update_play_pause_symbol(nm_controls.symbol_row, main_symbol_pos,
                main_symbol_pos + nm_controls.pause_symbol:len(), mouse_row, mouse_col)
        elseif nm_state.is_paused then
            nm_controls_state.update_play_pause_symbol(nm_controls.symbol_row, main_symbol_pos,
                main_symbol_pos + nm_controls.play_symbol:len(), mouse_row, mouse_col)
        end
    end, { buffer = nm_controls_win.bufnr, silent = true })
end

return M
