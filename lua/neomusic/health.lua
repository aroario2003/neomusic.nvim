local M = {}

function M.check()
    vim.health.start("Neomusic health check")
    if not vim.fn.executable("mpv") then
        vim.health.error("mpv is not installed on the system, please install mpv")
    else
        vim.health.ok("mpv is installed")
    end

    if not vim.fn.executable("socat") then
        vim.health.error("socat is not installed on the system, please install socat")
    else
        vim.health.ok("socat is installed")
    end

    local nvim_ver = vim.version()
    if nvim_ver.major == 0 and nvim_ver.minor < 10 then
        vim.health.warn("neovim is not version 0.10+, you should consider upgrading neovim")
    else
        vim.health.ok("neovim version is acceptable")
    end
end

return M
