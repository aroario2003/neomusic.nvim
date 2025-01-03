<div align="center">
    <h1>neomusic.nvim</h1>
    <img src="./assets/logo.webp" width=300 height=300></img>
</div>

> [!WARNING]
> This plugin is in very early development, many bugs are present. Use at your own risk.

## About

Some people like to listen to music while they code, however, in order to do so they must use another application in order to play their songs, which interrupts the workflow and flowstate that maybe present. This plugin gets rid of that need and lets you stay in neovim while you play your favorite playlist. Less distractions = More productivity.

## Dependencies

- `nvim 0.10.0+`
- `socat`
- `mpv`
- `telescope.nvim` (neovim plugin)

The `telescope.nvim` dependency should be handled by `lazy.nvim`

## Install

With `lazy.nvim`

```lua
require("lazy").setup({
    spec = {
        {
            "aroario2003/neomusic.nvim",
            dependencies = { "nvim-telescope/telescope.nvim" },
            config = function()
                require("neomusic").setup()
            end
        },
        -- ...other plugins,
    }
})
```

# Default Setup Options

```lua
{
    --The directory that you have your playlists are in
    playlist_dir = os.getenv("HOME") .. "/Music",

    --Any notifications recieved from neomusic will
    --timeout after this amount of seconds
    notif_timeout = 5,

    --Max items that can be put into the song queue at a time,
    --nil means use the default (1,000)
    song_queue_max_items = nil,

    --Neovim global keymaps, which are not buffer local,
    --make sure these dont conflict with existing keybinds
    global_keymaps = {
        keybinds = {
            { 'n', '<leader>nt', ':Neomusic toggle_playlist_menu<CR>' },
            { 'n', '<leader>nc', ':Neomusic toggle_controls<CR>' },
            { 'n', '<leader>ps', ':Neomusic unpause_song<CR>' },
            { 'n', '<leader>Ps', ':Neomusic pause_song<CR>' },
            { 'n', '<leader>nns', ':Neomusic next_song<CR>' },
            { 'n', '<leader>nps', ':Neomusic prev_song<CR>' },
            { 'n', '<leader>nis', ':Neomusic increase_volume 5<CR>' },
            { 'n', '<leader>nds', ':Neomusic decrease_volume 5<CR>' },
            { 'n', '<leader>nqv', ':Neomusic toggle_queue_view<CR>' },
            { 'n', '<leader>npq', ':Neomusic play_queue<CR>' },
            { 'n', '<leader>nsp', ':Neomusic search_playlists<CR>' },
        }
    }
}
```

# After Install

Once neomusic is installed with your plugin manager, it is recommended that you run `:checkhealth neomusic` inside of neovim.

# Usage

The idea behind this plugin is that you have your own collection of music in some directory on your system that can be played with mpv. This plugin essentially acts as a middle man between you and mpv. Most of how to use the plugin is self explanatory given the keybindings above.
