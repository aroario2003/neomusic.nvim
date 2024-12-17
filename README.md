# neomusic.nvim

> [!WARNING]
> This plugin is in very early development, many bugs are present. Use at your own risk.

## About

Some people like to listen to music while they code, however, in order to do so they must use another application in order to play their songs, which interrupts the workflow and flowstate that maybe present. This plugin gets rid of that need and lets you stay in neovim while you play your favorite playlist. Less distractions = More productivity.

## Dependencies

- `nvim 0.8.0+`
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
            dependencies = { "nvim-telescope/telescope.nvim" }
        },
        -- ...other plugins,
    }
})
```

## Setup

```lua
local nm = require("neomusic")
nm.setup({
    --The directory that you have your playlists are in
    playlist_dir=os.getenv("HOME") .. "/Music",

    --Any notifications recieved from neomusic will
    --timeout after this amount of seconds
    notif_timeout = 5,

    --Neovim global keymaps, which are not buffer local,
    --make sure these dont conflict with existing keybinds
    global_keymaps = {
        keybinds = {
            {'n', '<leader>nt', ':Neomusic toggle_playlist_menu<CR>'},
            {'n', '<leader>ps', ':Neomusic unpause_song<CR>'},
            {'n', '<leader>Ps', ':Neomusic pause_song<CR>'},
            {'n', '<leader>nns', ':Neomusic next_song<CR>'},
            {'n', '<leader>nps', ':Neomusic prev_song<CR>'},
        }
    }
})
```

The default configuration is above, if you are ok with that configuration then you can just do:

```lua
require("neomusic").setup()
```
