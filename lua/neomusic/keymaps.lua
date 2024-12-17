local nm = require("neomusic")

local vim = vim
local M = {}

function M.load_keymaps()
   local nm_state = require("neomusic.state")
   local nm_win = require("neomusic.window")

   vim.keymap.set('n', '<Enter>', function()
        return nm.enter_selection()
    end, {buffer = nm_win.bufnr, silent = true})

    vim.keymap.set('n', 'j', function()
        local cur_pos = vim.api.nvim_win_get_cursor(nm_win.win)
        cur_pos[1] = cur_pos[1] + 1
        if cur_pos[1] > vim.api.nvim_buf_line_count(nm_win.bufnr) then
            return
        else
            vim.api.nvim_win_set_cursor(nm_win.win, cur_pos)
        end
        return nm_state.update_hover()
    end, { buffer = nm_win.bufnr, silent = true })

    vim.keymap.set('n', 'k', function()
        local cur_pos = vim.api.nvim_win_get_cursor(nm_win.win)
        cur_pos[1] = cur_pos[1] - 1
        if cur_pos[1] < 1 then
            return
        else
            vim.api.nvim_win_set_cursor(nm_win.win, cur_pos)
        end
        return nm_state.update_hover()
    end, { buffer = nm_win.bufnr, silent = true })

    vim.keymap.set('n', '<LeftMouse>', function()
        return nm_state.handle_mouse_click()
    end, {buffer = nm_win.bufnr, silent = true})
end

function M.load_global_keymaps()
    for _, keybind in ipairs(nm.config["global_keymaps"].keybinds) do
        vim.api.nvim_set_keymap(keybind[1], keybind[2], keybind[3], {silent=true})
    end
end

return M
