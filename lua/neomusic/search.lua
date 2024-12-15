local M = {}

---Recursivley list all playlists
---@return table
local function recursive_playlist_listing()
    local nm = require("neomusic")
    local recursive_listing = {}

    local playlist_listing = nm._get_dir_listing(nm.config.playlist_dir)
    for _, playlist in ipairs(playlist_listing) do
        local full_playlist_path = nm.config.playlist_dir .. '/' .. playlist
        local listing = nm._get_dir_listing(full_playlist_path)
        for i, item in ipairs(listing) do
            listing[i] = full_playlist_path .. '/' .. item
        end
        recursive_listing = vim.tbl_extend("keep", listing, recursive_listing)
    end
    return recursive_listing
end

---Search for a song
function M.search_playlists()
    local tscope_pickers = require("telescope.pickers")
    local tscope_finders = require("telescope.finders")
    local tscope_conf = require("telescope.config").values
    local tscope_state = require("telescope.actions.state")
    local tscope_actions = require("telescope.actions")

    local nm_state = require("neomusic.state")
    local nm_win = require("neomusic.window")
    local Queue = require("neomusic.queue")

    local opts = {}

    if nm_state.song_queue == nil then
        nm_state.song_queue = Queue:new()
    end

    tscope_pickers.new({}, {
        prompt_title = "Neomusic Search",
        finder = tscope_finders.new_table({
            results = recursive_playlist_listing()
        }),
        attach_mappings = function(prompt_bufnr, map)
            map('n', '<Enter>', function()
                local item = tscope_state.get_selected_entry()
                nm_state.song_queue:push(item[1])
                nm_win.notification("Song %s added to queue", item[1])
            end)
            map('n', 'q', function()
                tscope_actions.close(prompt_bufnr)
            end)
            return true
        end,
        sorter = tscope_conf.generic_sorter(opts),
        initial_mode = "normal"
    }):find()
end

return M
