local M = {
    win_is_open = false,
    song_cur_mins = 0,
    song_cur_secs = 0,
    timer_started = false,
}

---Update the play/pause symbol when the song is either paused or playing
---@param row number
---@param col_start number
---@param col_end number
---@param mouse_row number
---@param mouse_col number
function M.update_play_pause_symbol(row, col_start, col_end, mouse_row, mouse_col)
    local nm_state = require("neomusic.state")
    local nm_controls = require("neomusic.controls")
    local nm_controls_win = require("neomusic.controls.window")

    if row + 1 == mouse_row then
        if mouse_col >= col_start + 1 and mouse_col <= col_end + 1 then
            if nm_state.is_playing then
                nm_state.pause_song()
                vim.api.nvim_buf_set_text(nm_controls_win.bufnr, row, col_start, row, col_end,
                    { nm_controls.play_symbol })
            elseif nm_state.is_paused then
                nm_state.unpause_song()
                vim.api.nvim_buf_set_text(nm_controls_win.bufnr, row, col_start, row, col_end,
                    { nm_controls.pause_symbol })
            end
        end
    end
end

---Internal function for state management (do not use this function in other plugins)
function M.__playing_timer()
    local nm_state = require("neomusic.state")
    local nm_mpv = require("neomusic.mpv")
    local nm_controls_win = require("neomusic.controls.window")

    ---@diagnostic disable-next-line:undefined-field
    local timer = vim.uv.new_timer()
    M.timer_started = true
    timer:start(0, 1000, vim.schedule_wrap(function()
        if nm_state.is_paused then
            timer:stop()
            timer:close()
            M.__paused_timer()
        end

        if not nm_state.song_finished then
            local playback_time = nm_mpv._get_playback_time()
            M.song_cur_mins = math.floor(playback_time / 60)
            M.song_cur_secs = playback_time % 60
        end

        local cur_secs_str = ""
        local playback_time_str = ""
        if M.song_cur_secs < 10 then
            cur_secs_str = string.format("0%d", M.song_cur_secs)
            playback_time_str = string.format("%d:%s ", M.song_cur_mins, cur_secs_str)
        else
            playback_time_str = string.format("%d:%d ", M.song_cur_mins, M.song_cur_secs)
        end

        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, 5, 1, 5, playback_time_str:len(),
            { string.rep(" ", playback_time_str:len()) })
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, 5, 1, 5, playback_time_str:len(), { playback_time_str })

        if nm_state.song_finished then
            nm_state.is_playing = false
            nm_state.is_paused = false

            nm_state.cur_song = "No song playing"
            nm_state.song_name = "No song playing"

            nm_state.song_finished = false

            M.song_cur_mins = 0
            M.song_cur_secs = 0

            M.timer_started = false

            timer:stop()
            timer:close()
        end
    end))
end

---Internal function for state management (do not use this function in other plugins)
function M.__paused_timer()
    local nm_state = require("neomusic.state")

    ---@diagnostic disable-next-line:undefined-field
    local timer = vim.uv.new_timer()
    timer:start(0, 1000, function()
        if nm_state.is_playing then
            timer:stop()
            timer:close()
            M.__playing_timer()
        end
    end)
end

---Updates the current playback time
function M.tick_controls_playback_time()
    local nm_state = require("neomusic.state")
    local nm_controls_win = require("neomusic.controls.window")

    local playback_time_str = string.format("%d:%d ", M.song_cur_mins, M.song_cur_secs)
    vim.api.nvim_buf_set_text(nm_controls_win.bufnr, 5, 1, 5, playback_time_str:len() - 1, { playback_time_str })

    if not M.timer_started then
        if nm_state.is_playing then
            M.__playing_timer()
        end
    end
end

return M
