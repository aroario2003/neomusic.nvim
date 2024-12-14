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
        border='rounded',
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

    local active_notifs = {}

    message = string.format(message, ...)
    local width = 80
    local required_height = 0
    required_height = required_height + math.ceil(message:len() / width)

    local notif_win_settings = {
        relative='editor',
        style='minimal',
        border='rounded',
        row=0,
        col=(vim.o.columns-width),
        width=width,
        height=required_height,
        title="Neomusic Notification",
        title_pos='center',
        focusable=false
    }

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].filetype = "notification"
    local win = vim.api.nvim_open_win(bufnr, false, notif_win_settings)
    vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, {message})
    vim.api.nvim_set_option_value("wrap", true, {win = win})
    table.insert(active_notifs, {bufnr = M.notif_win_data.bufnr, win = M.notif_win_data.win})

    local timer = vim.uv.new_timer()
    timer:start(nm.config.notif_timeout * 1000, 0, vim.schedule_wrap(function()
        if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_close, win, true)
        end

        for i, notif in ipairs(active_notifs) do
            if notif.win == win then
                table.remove(active_notifs, i)
            end
        end

        if vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_buf_delete(bufnr, {force = true})
        end
        timer:close()
    end))
end

return M
