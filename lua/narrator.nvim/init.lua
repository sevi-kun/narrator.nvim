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
  setup = function(conf)
    conf = conf or {}
    opt.current = conf.current or true
    opt.exclude = vim.tbl_extend(
      'force',
      { 'dashboard', 'lazy', 'help', 'markdown', 'nofile', 'terminal' },
      conf.exclude or {}
    )
    -- opt.config.virt_text = { { conf.char or '│' } }
    -- set_decoration_provider(ns, { on_win = on_win, on_line = on_line })
    voice_output(current_line)
  end,
}
