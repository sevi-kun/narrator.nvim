local opt = {
    config = {
        rate = 0,
        pitch = 0,
        volume = 0,
        spell = false,
    },
}

local current_line = "Hello world"

local function voice_output(string)
    vim.cmd.system("spd-say " .. string)

  return true
end


return {
    voice_output(current_line)
}
