# neomusic.nvim

## About

Some people like to listen to music while they code, however, in order to do so they must use another application in order to play their songs, which interrupts the workflow and flowstate that maybe present. This plugin gets rid of that need and lets you stay in neovim while you play your favorite playlist. Less distractions = More productivity.

## Setup

With `lazy.nvim`

```lua
require("lazy").setup({
    spec = {
        {
            "aroario2003/neomusic.nvim"
        },
        -- ...other plugins,
    }
})
```

Plugin configuration:

```lua
local nm = require("neomusic")
local nm_keys = require("neomusic.keymaps")
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
            {'n', '<leader>nt', ':lua require("neomusic").toggle_playlist_menu()<CR>'},
            {'n', '<leader>ps', ':lua require("neomusic.state").unpause_song()<CR>'},
            {'n', '<leader>Ps', ':lua require("neomusic.state").pause_song()<CR>'}
        }
    }
})
nm_keys.load_global_keymaps()

```

The default configuration is above, if you are ok with that configuration then you can just do:

```lua
require("neomusic").setup()
require("neomusic.keymaps").load_global_keymaps()
```

