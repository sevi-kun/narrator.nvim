local api = vim.api

local narrator_disabled = false
local narrator_auto_read = false
local current_line = nil

local opt = {
    config = {
        rate = 0,
        pitch = 0,
        volume = 0,
        method = "key",
        punctuation = "all",
    },
}


-- functions

-- Stop reading
local function cancle_reading()
    os.execute("spd-say -C")
end

-- Text to speach using spd-say
local function say(text, method)
    cancle_reading()

    local options = ' ' ..
        "--rate " .. opt.config.rate ..
        " --pitch " .. opt.config.pitch ..
        " --volume " .. opt.config.volume ..
        ' --punctuation-mode ' .. opt.config.punctuation ..
        ' --application-name ' .. 'narrator.nvim' ..
        ' --connection-name ' .. 'narrator.nvim' ..
        ' --wait '

    if method == "character" then
        options = options .. ' --character '
    elseif method == "key" then
        options = options .. ' --key '
    end

    os.execute("spd-say " .. options .. "'" .. text .. "'" .. " > /dev/null &")
end

-- Get active buffer
local function buffer_switch()
    local buf_name = api.nvim_buf_get_name(0)

    -- check if narrator is active
    if narrator_disabled then
        return
    end

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

-- Speak when entering function
local function context_switch()
    cancle_reading()

    -- check if narrator is active
    if narrator_disabled then
        return
    end

    -- check if buffer is empty
    if api.nvim_get_current_line() == "" or api.nvim_get_current_line() == 'tsplayground' then
        return
    end

    -- check if buffer is a file
    if vim.fn.isdirectory(api.nvim_buf_get_name(0)) == 1 then
        return
    end

    -- Get current function name from treesitter

    local parser = vim.treesitter.get_parser(0, vim.bo.filetype)
    local tree = parser:parse()[1]
    local root = tree:root()
    local row, col = unpack(api.nvim_win_get_cursor(0))

    local cursor_node = root:descendant_for_range(row, col, row, col)

    while cursor_node do
        if cursor_node:type() == 'function' then
            local function_name_node = cursor_node:named_child(0)
            print(vim.treesitter.get_node_text(function_name_node, 0))
        end
        cursor_node = cursor_node:parent()
    end
end

-- Read line
local function read_line()
    if api.nvim_get_current_line() == current_line then
      return
    end

    current_line = api.nvim_get_current_line()
    say(current_line)
end

-- Speak single
local function say_single()
    local pos = api.nvim_win_get_cursor(0)[2] + 1
    local line = api.nvim_get_current_line()
    if line:sub(pos, pos) ~= " " then
        say(line:sub(pos, pos), opt.config.method)
    end
end


-- Toggle auto read line
local function toggle_auto_read()
    if narrator_auto_read then
        cancle_reading()
        narrator_auto_read = false
    else
        narrator_auto_read = true
    end
end

local function toggle_narrator()
    if narrator_disabled then
        narrator_disabled = false
    else
        cancle_reading()
        narrator_disabled = true
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

-- Runs when moving cursor
-- api.nvim_create_autocmd("CursorMoved", {
--     callback = function()
--         context_switch()
--     end
-- })


-- Keymaps
vim.keymap.set("n", "<leader>na", toggle_auto_read)
vim.keymap.set("n", "<leader>nn", toggle_narrator)
vim.keymap.set("n", "<leader>nl", read_line)
vim.keymap.set("n", "<leader>nc", cancle_reading)
vim.keymap.set("n", "<leader>ns", say_single)
