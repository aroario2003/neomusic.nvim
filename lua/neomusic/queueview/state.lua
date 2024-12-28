local M = {}

---Update the highlight based on cursor position in the menu
function M.update_hover()
    local nm_qv_win = require("neomusic.queueview.window")

    local cur_pos = vim.api.nvim_win_get_cursor(nm_qv_win.win)
    local row = cur_pos[1] - 1
    vim.api.nvim_buf_del_extmark(nm_qv_win.bufnr, nm_qv_win.ns, nm_qv_win.extm_id)
    nm_qv_win.extm_id = vim.api.nvim_buf_set_extmark(nm_qv_win.bufnr, nm_qv_win.ns, row, 0,
        { end_row = row + 1, hl_eol = true, hl_group = "visual" })
end

return M
