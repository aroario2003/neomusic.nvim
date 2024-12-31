local M = {}

---Highlight the current hover with cursor in the menu
local function highlight_current_hover()
    local nm_qv_win = require("neomusic.queueview.window")
    local cur_pos = vim.api.nvim_win_get_cursor(nm_qv_win.win)
    local row = cur_pos[1] - 1
    nm_qv_win.extm_id = vim.api.nvim_buf_set_extmark(nm_qv_win.bufnr, nm_qv_win.ns, row, 0,
        { end_line = row + 1, hl_eol = true, hl_group = "visual" })
end

function M.toggle_queue_view()
    local nm_state = require("neomusic.state")
    local nm_win = require("neomusic.window")
    local nm_qv_win = require("neomusic.queueview.window")
    local nm_qv_keys = require("neomusic.queueview.keymaps")

    if nm_qv_win.win and vim.api.nvim_win_is_valid(nm_qv_win.win) then
        nm_qv_win.close_window()
        return
    end

    if nm_state.song_queue then
        nm_qv_win.create_window("Song Queue Editor", 100, 30)

        local song_names = {}
        ---@diagnostic disable-next-line:undefined-field
        for _, song_path in ipairs(nm_state.song_queue.items) do
            table.insert(song_names, nm_state.song_queue.song_map[song_path])
        end

        vim.api.nvim_buf_set_lines(nm_qv_win.bufnr, 0, -1, false, song_names)
        highlight_current_hover()
        nm_qv_keys.load_keymaps()
    else
        nm_win.notification("No songs in queue")
        return
    end
end

return M
