local nm = require("neomusic")

local vim = vim
local M = {}

function M.load_keymaps()
   local state = require("neomusic.state")

   vim.keymap.set('n', '<Enter>', function()
        return nm.enter_selection()
    end, {buffer = nm.bufnr, silent = true})

    vim.keymap.set('n', 'j', function()
        local cur_pos = vim.api.nvim_win_get_cursor(nm.win)
        cur_pos[1] = cur_pos[1] + 1
        if cur_pos[1] > vim.api.nvim_buf_line_count(nm.bufnr) then
            return
        else
            vim.api.nvim_win_set_cursor(nm.win, cur_pos)
        end
        return state.update_hover()
    end, { buffer = nm.bufnr, silent = true })

    vim.keymap.set('n', 'k', function()
        local cur_pos = vim.api.nvim_win_get_cursor(nm.win)
        cur_pos[1] = cur_pos[1] - 1
        if cur_pos[1] < 1 then
            return
        else
            vim.api.nvim_win_set_cursor(nm.win, cur_pos)
        end
        return state.update_hover()
    end, { buffer = nm.bufnr, silent = true })
end

return M
