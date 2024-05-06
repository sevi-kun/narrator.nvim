local api = vim.api

local opt = {
    config = {
        rate = 0,
        pitch = 0,
        volume = 0,
        punctuation = "all",

    },
}

local zoe = function()
    options = ' ' .. "-r " .. opt.config.rate .. " -p " .. opt.config.pitch .. " -i " .. opt.config.volume .. ' -m ' .. opt.config.punctuation .. ' '
    local current_line = "'" .. api.nvim_get_current_line() .. "'"
    os.execute("spd-say " .. options .. current_line)
end

vim.keymap.set("n", "<leader>n", zoe)


