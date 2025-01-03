local M = {
    bufnr = nil,
    win = nil,
    ns = vim.api.nvim_create_namespace("neomusic queueview"),
    extm_id = nil,
}

---Creates a window
---@param name string
---@param width integer
---@param height integer
function M.create_window(name, width, height)
    local win_settings = {
        relative = 'editor',
        style = 'minimal',
        border = 'rounded',
        row = (vim.o.lines - height) / 2,
        col = (vim.o.columns - width) / 2,
        width = width,
        height = height,
        title = name,
        title_pos = 'center'
    }

    M.bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[M.bufnr].filetype = 'neomusic'
    M.win = vim.api.nvim_open_win(M.bufnr, true, win_settings)
end

function M.close_window()
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
    M.bufnr = nil
end

return M
