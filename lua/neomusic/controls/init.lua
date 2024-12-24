local M = {}

---Toggle the window for the controls
function M.toggle_controls_window()
    local nm_state = require("neomusic.state")
    local nm_controls_win = require("neomusic.controls.window")
    local nm_controls_ui = require("neomusic.controls.ui")
    local nm_controls_state = require("neomusic.controls.state")
    local nm_controls_keys = require("neomusic.controls.keymaps")

    if nm_controls_win.win ~= nil and vim.api.nvim_win_is_valid(nm_controls_win.win) then
        nm_controls_win.close_window()
        nm_controls_state.win_is_open = false
        return
    end

    nm_controls_win.create_window("Neomsic Controls", nm_controls_ui.window_width, nm_controls_ui.window_height)
    nm_controls_state.win_is_open = true

    if nm_state.cur_song == nil then
        nm_state.cur_song = "No song playing"
        nm_state.song_name = "No song playing"
    end

    vim.api.nvim_buf_set_lines(nm_controls_win.bufnr, 0, -1, false, {
        string.rep(" ", nm_controls_ui.window_width),
        string.rep(" ", nm_controls_ui.window_width),
        string.rep(" ", nm_controls_ui.window_width),
        string.rep(" ", nm_controls_ui.window_width),
        string.rep(" ", nm_controls_ui.window_width),
        string.rep(" ", nm_controls_ui.window_width),
        string.rep(" ", nm_controls_ui.window_width)
    })

    nm_controls_ui.draw_song_title()

    ---@diagnostic disable-next-line:undefined-field
    local timer_pt = vim.uv.new_timer()
    timer_pt:start(0, 500, vim.schedule_wrap(function()
        if nm_controls_state.win_is_open then
            nm_controls_ui.draw_control_symbols()
        else
            timer_pt:stop()
            timer_pt:close()
        end
    end))

    nm_controls_state.tick_controls_playback_time()

    ---@diagnostic disable-next-line:undefined-field
    local timer_pbar = vim.uv.new_timer()
    timer_pbar:start(0, 500, vim.schedule_wrap(function()
        if not nm_state.song_finished then
            nm_controls_ui.draw_progressbar()
        else
            timer_pbar:stop()
            timer_pbar:close()
        end
    end))

    nm_controls_keys.load_keymaps()
end

return M
