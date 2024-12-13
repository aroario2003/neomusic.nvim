local M = {bufnr = nil, win = nil, ns = vim.api.nvim_create_namespace("neomusic"), extm_id = nil}
M.notif_win_data = {bufnr = nil, win = nil, ns = vim.api.nvim_create_namespace("neomusic notification")}

---Creates a window
---@param name string
---@param width integer
---@param height integer
function M.create_window(name, width, height)
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

function M.close_window()
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
    M.bufnr = nil
end

---Creates a notification or a window which is only around temporarily
---@param message string
---@param ... unknown
function M.notification(message, ...)
    local nm = require("neomusic")

    message = string.format(message, ...)
    local width = 80
    local required_height = 0
    required_height = required_height + math.ceil(message:len() / width)


    local notif_win_settings = {
        relative='editor',
        style='minimal',
        border='single',
        row=0,
        col=(vim.o.columns-width),
        width=width,
        height=required_height,
        title="Neomusic Notification",
        title_pos='center',
        focusable=false
    }

    M.notif_win_data.bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[M.notif_win_data.bufnr].filetype = "notification"
    vim.api.nvim_set_option_value("wrap", true, {win = M.notif_win_data.win})
    M.notif_win_data.win = vim.api.nvim_open_win(M.notif_win_data.bufnr, false, notif_win_settings)
    vim.api.nvim_buf_set_lines(M.notif_win_data.bufnr, 0, 1, false, {message})

    local timer = vim.uv.new_timer()
    timer:start(nm.config.notif_timeout * 1000, 0, vim.schedule_wrap(function()
        if M.notif_win_data.win and vim.api.nvim_win_is_valid(M.notif_win_data.win) then
            vim.api.nvim_win_close(M.notif_win_data.win, true)
        end
        M.notif_win_data.bufnr = nil
        M.notif_win_data.win = nil
    end))
end

return M
