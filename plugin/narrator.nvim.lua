local api = vim.api

local narrator_auto_read = false
local current_line = nil

local opt = {
    config = {
        rate = 0,
        pitch = 0,
        volume = 0,
        punctuation = "all",
    },
}


-- functions

-- Stop reading
local function stop_reading()
    os.execute("spd-say -C")
end

-- Text to speach using spd-say
local function say(text)
    stop_reading()

    local options = ' ' ..
        "-r " .. opt.config.rate ..
        " -p " .. opt.config.pitch ..
        " -i " .. opt.config.volume ..
        ' -m ' .. opt.config.punctuation ..
        ' -s ' ..
        ' -N ' .. 'narrator.nvim' ..
        ' -n ' .. 'narrator.nvim' ..
        ' -w ' .. ' '

    os.execute("spd-say " .. options .. "'" .. text .. "'" .. " > /dev/null &")
end

-- Get active buffer
local function buffer_switch()
    local buf_name = api.nvim_buf_get_name(0)

    -- check if buffer is empty
    if buf_name == "" then
        return
    end

    -- check if buffer is a file
    if vim.fn.isdirectory(buf_name) == 1 then
        return
    end

    buf_name = vim.fn.fnamemodify(buf_name, ":t")
    say(buf_name)
end

-- Read line
local function read_line()
    if api.nvim_get_current_line() == current_line then
        return
    end

    current_line = api.nvim_get_current_line()
    say(current_line)
end

-- Toggle auto read line
local function toggle_auto_read()
    if narrator_auto_read then
        stop_reading()
        narrator_auto_read = false
    else
        narrator_auto_read = true
    end
end


-- Runtime

-- Call function on cursor move
api.nvim_create_autocmd("CursorMoved", {
    callback = function()
        if api.nvim_get_mode().mode == "n" and narrator_auto_read then
            read_line()
        end
    end
})

api.nvim_create_autocmd("BufEnter", {
    callback = function()
        buffer_switch()
    end
})


-- Keymaps
vim.keymap.set("n", "<leader>na", toggle_auto_read)
vim.keymap.set("n", "<leader>nl", read_line)
vim.keymap.set("n", "<leader>ns", stop_reading)
