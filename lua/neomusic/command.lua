local M = {}

---Initialize the Neomusic user command
function M.init_command()
    vim.api.nvim_create_user_command("Neomusic", M.parse_args, {
        nargs = '+',
        complete = M.command_completion,
    })
end

---Complete the arguments to the Neomusic user command
---@param arg_lead any
---@param cmd_line any
---@param cursor_pos any
---@return table
---@diagnostic disable-next-line:unused-local
function M.command_completion(arg_lead, cmd_line, cursor_pos)
    local options = {
        "toggle_playlist_menu",
        "next_song",
        "prev_song",
        "toggle_controls",
        "play_song",
        "pause_song",
        "unpause_song",
    }
    local results = {}

    for _, option in ipairs(options) do
        if option:find("^" .. arg_lead) then
            table.insert(results, option)
        end
    end

    return results
end

---Parse the arguments to the Neomusic user command
---@param data table
function M.parse_args(data)
    local nm = require("neomusic")
    local nm_state = require("neomusic.state")
    local nm_controls = require("neomusic.controls")

    if #data.fargs == 1 then
        if data.fargs[1] == "toggle_playlist_menu" then
            nm.toggle_playlist_menu()
        elseif data.fargs[1] == "next_song" then
            nm_state.next_song()
        elseif data.fargs[1] == "prev_song" then
            nm_state.prev_song()
        elseif data.fargs[1] == "pause_song" then
            nm_state.pause_song()
        elseif data.fargs[1] == "unpause_song" then
            nm_state.unpause_song()
        elseif data.fargs[1] == "toggle_controls" then
            nm_controls.toggle_controls_window()
        end
    elseif #data.fargs == 2 then
        if data.fargs[1] == "play_song" then
            nm_state.play_song(data.fargs[2])
        elseif data.fargs[1] == "set_volume" then
            local vol = tonumber(data.fargs[2], 10)
            nm_state.set_volume(vol)
        elseif data.fargs[1] == "increase_volume" then
            local inc = tonumber(data.fargs[2], 10)
            nm_state.increase_volume(inc)
        elseif data.fargs[1] == "decrease_volume" then
            local dec = tonumber(data.fargs[2], 10)
            nm_state.decrease_volume(dec)
        end
    end
end

return M
