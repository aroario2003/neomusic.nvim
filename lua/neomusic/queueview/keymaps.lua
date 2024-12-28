local M = {}

function M.load_keymaps()
    local nm = require("neomusic")
    local nm_qv_state = require("neomusic.queueview.state")
    local nm_qv_win = require("neomusic.queueview.window")

    vim.keymap.set('n', 'j', function()
        local cur_pos = vim.api.nvim_win_get_cursor(nm_qv_win.win)
        cur_pos[1] = cur_pos[1] + 1
        if cur_pos[1] > vim.api.nvim_buf_line_count(nm_qv_win.bufnr) then
            return
        else
            vim.api.nvim_win_set_cursor(nm_qv_win.win, cur_pos)
        end
        return nm_qv_state.update_hover()
    end, { buffer = nm_qv_win.bufnr, silent = true })

    vim.keymap.set('n', 'k', function()
        local cur_pos = vim.api.nvim_win_get_cursor(nm_qv_win.win)
        cur_pos[1] = cur_pos[1] - 1
        if cur_pos[1] < 1 then
            return
        else
            vim.api.nvim_win_set_cursor(nm_qv_win.win, cur_pos)
        end
        return nm_qv_state.update_hover()
    end, { buffer = nm_qv_win.bufnr, silent = true })
end

return M
