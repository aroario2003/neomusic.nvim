local M = {
    back_symbol = " ",
    pause_symbol = "",
    play_symbol = "",
    forward_symbol = " ",
    window_width = 60,
    window_height = 7,
    symbol_row = 3,
    symbol_offset = 13,
    pbar_row = 5,
}

---Draw the current progress of the song on top of the progressbar underline
---@param pbar_width number
---@param pbar_start_col number
local function draw_progressbar_overline(pbar_width, pbar_start_col)
    local nm_mpv = require("neomusic.mpv")
    local nm_state = require("neomusic.state")
    local nm_controls_state = require("neomusic.controls.state")
    local nm_controls_win = require("neomusic.controls.window")

    local cur_mins_to_secs = nm_controls_state.song_cur_mins * 60
    local cur_total_secs = cur_mins_to_secs + nm_controls_state.song_cur_secs

    if not nm_state.song_finished then
        local song_duration = nm_mpv._get_song_duration()
        local overline_reps = math.ceil(pbar_width * (cur_total_secs / song_duration))

        if nm_controls_state.extm_id_pbar_ol then
            vim.api.nvim_buf_del_extmark(nm_controls_win.bufnr, nm_controls_win.ns, nm_controls_state.extm_id_pbar_ol)
        end

        nm_controls_state.extm_id_pbar_ol = vim.api.nvim_buf_set_extmark(nm_controls_win.bufnr, nm_controls_win.ns,
            M.pbar_row,
            pbar_start_col,
            {
                end_row = M.pbar_row,
                end_col = M.window_width - 1,
                virt_text = { { string.rep("╸", overline_reps), "@markup.strong" } },
                virt_text_pos = "overlay"
            })
    end
end

---Draw the entire progress bar
local function draw_progressbar()
    local nm_controls_win = require("neomusic.controls.window")
    local nm_controls_state = require("neomusic.controls.state")

    local pbar_start_col = nm_controls_state.ptime_str_len + 1
    local pbar_width = M.window_width - pbar_start_col

    if nm_controls_state.extm_id_pbar_ul then
        vim.api.nvim_buf_del_extmark(nm_controls_win.bufnr, nm_controls_win.ns, nm_controls_state.extm_id_pbar_ul)
    end

    nm_controls_state.extm_id_pbar_ul = vim.api.nvim_buf_set_extmark(nm_controls_win.bufnr, nm_controls_win.ns,
        M.pbar_row,
        pbar_start_col,
        {
            end_row = M.pbar_row,
            end_col = M.window_width - 1,
            virt_text = { { string.rep("╸", pbar_width), "CursorLineFold" } },
            virt_text_pos = "overlay"
        })

    draw_progressbar_overline(pbar_width, pbar_start_col)
end


---Function to draw the song title on the controls window
function M.draw_song_title()
    local nm_state = require("neomusic.state")
    local nm_controls_win = require("neomusic.controls.window")
    local nm_controls_state = require("neomusic.controls.state")

    local start_col = math.floor((M.window_width - nm_state.song_name:len()) / 2)
    local end_col = start_col + nm_state.song_name:len()

    if end_col > M.window_width then
        local char_cut_num = end_col - M.window_width

        nm_state.song_name = string.sub(nm_state.song_name, 1, nm_state.song_name:len() - char_cut_num - 9)
        nm_state.song_name = nm_state.song_name .. "..."

        start_col = math.floor((M.window_width - nm_state.song_name:len()) / 2)
        end_col = start_col + nm_state.song_name:len()
    end

    if nm_controls_state.extm_id_st then
        vim.api.nvim_buf_del_extmark(nm_controls_win.bufnr, nm_controls_win.ns, nm_controls_state.extm_id_st)
    end

    nm_controls_state.extm_id_st = vim.api.nvim_buf_set_extmark(nm_controls_win.bufnr, nm_controls_win.ns, 0, start_col,
        { virt_text = { { nm_state.song_name } }, virt_text_pos = "overlay", end_row = 0, end_col = end_col })
end

---Function to draw the control symbols on the controls window
local function draw_control_symbols()
    local nm_state = require("neomusic.state")
    local nm_controls_win = require("neomusic.controls.window")

    local center_col = math.floor(M.window_width / 2)
    local back_pos = center_col - M.symbol_offset
    local main_symbol_pos = center_col
    local forward_pos = center_col + M.symbol_offset

    if nm_state.is_playing then
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, M.symbol_row, back_pos, M.symbol_row,
            back_pos + M.back_symbol:len(), { M.back_symbol })
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, M.symbol_row, main_symbol_pos, M.symbol_row,
            main_symbol_pos + M.pause_symbol:len(), { M.pause_symbol })
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, M.symbol_row, forward_pos, M.symbol_row,
            forward_pos + M.forward_symbol:len(), { M.forward_symbol })
    else
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, M.symbol_row, back_pos, M.symbol_row,
            back_pos + M.back_symbol:len(), { M.back_symbol })
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, M.symbol_row, main_symbol_pos, M.symbol_row,
            main_symbol_pos + M.play_symbol:len(), { M.play_symbol })
        vim.api.nvim_buf_set_text(nm_controls_win.bufnr, M.symbol_row, forward_pos, M.symbol_row,
            forward_pos + M.forward_symbol:len(), { M.forward_symbol })
    end
end

---Toggle the window for the controls
function M.toggle_controls_window()
    local nm_state = require("neomusic.state")
    local nm_controls_win = require("neomusic.controls.window")
    local nm_controls_state = require("neomusic.controls.state")
    local nm_controls_keys = require("neomusic.controls.keymaps")

    if nm_controls_win.win ~= nil and vim.api.nvim_win_is_valid(nm_controls_win.win) then
        nm_controls_win.close_window()
        nm_controls_state.win_is_open = false
        return
    end

    nm_controls_win.create_window("Neomsic Controls", M.window_width, M.window_height)
    nm_controls_state.win_is_open = true

    if nm_state.cur_song == nil then
        nm_state.cur_song = "No song playing"
        nm_state.song_name = "No song playing"
    end

    vim.api.nvim_buf_set_lines(nm_controls_win.bufnr, 0, -1, false, {
        string.rep(" ", M.window_width),
        string.rep(" ", M.window_width),
        string.rep(" ", M.window_width),
        string.rep(" ", M.window_width),
        string.rep(" ", M.window_width),
        string.rep(" ", M.window_width),
        string.rep(" ", M.window_width)
    })

    M.draw_song_title()

    ---@diagnostic disable-next-line:undefined-field
    local timer_pt = vim.uv.new_timer()
    timer_pt:start(0, 500, vim.schedule_wrap(function()
        if nm_controls_state.win_is_open then
            draw_control_symbols()
        else
            timer_pt:stop()
            timer_pt:close()
        end
    end))

    nm_controls_state.tick_controls_playback_time()

    ---@diagnostic disable-next-line:undefined-field
    local timer_pbar = vim.uv.new_timer()
    timer_pbar:start(0, 1000, vim.schedule_wrap(function()
        if not nm_state.song_finished then
            draw_progressbar()
        else
            timer_pbar:stop()
            timer_pbar:close()
        end
    end))

    nm_controls_keys.load_keymaps()
end

return M
