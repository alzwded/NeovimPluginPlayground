local M = {}

-- Plugin state
local state = {
  bufnr = nil,
  winnr = nil,
  job_id = nil,
  term_config = {
    height = 15,
    position = 'bottom'
  }
}

-- Get or create the terminal buffer
local function ensure_terminal()
  print("ensure_terminal", state.bufnr, state.job_id, state.winnr)
  if state.bufnr then
      print("...", vim.api.nvim_buf_is_valid(state.bufnr), vim.api.nvim_buf_get_name(state.bufnr))
  end
  if state.winnr then
      print("...", vim.api.nvim_win_is_valid(state.winnr))
  end

  -- Check if existing terminal is still valid
  if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
    local buf_name = vim.api.nvim_buf_get_name(state.bufnr)
    if buf_name:match('^term://') then
      return state.bufnr, state.job_id, state.winnr
    end
  end

  local prevwinnr = vim.api.nvim_get_current_win()
  local prevbufnr = vim.api.nvim_get_current_buf()
  print('previous winnr, bufnr', prevwinnr, prevbufnr)
  
  -- Create new terminal
  local bufnr = vim.api.nvim_create_buf(false, true)

  if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
    vim.api.nvim_set_current_win(state.winnr)
  else
    -- Create horizontal split at bottom
    vim.cmd('botright ' .. state.term_config.height .. 'split')
    local winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winnr, bufnr)
    
    state.winnr = winnr
  end
  
  vim.api.nvim_set_current_buf(bufnr)

  -- Start terminal job
  local job_id = vim.fn.termopen(vim.o.shell or 'cmd.exe', {
    on_exit = function()
      state.bufnr = nil
      state.job_id = nil
      state.winnr = nil
    end
  })
  
  state.bufnr = bufnr
  state.job_id = job_id

  vim.api.nvim_set_current_win(prevwinnr)
  
  return bufnr, job_id, state.winnr
end

-- Show terminal in a window
local function show_terminal()
  local bufnr, job_id, winnr = ensure_terminal()
  
  vim.api.nvim_set_current_win(winnr)

  return winnr
end

-- Write to terminal with support for control characters
function M.write(data)
  local bufnr, job_id, winnr = ensure_terminal()
  
  if not job_id then
    error("Terminal job not available")
  end
  
  -- Handle different input types
  if type(data) == 'table' then
    -- Array of bytes or key codes
    for _, item in ipairs(data) do
      if type(item) == 'string' then
        vim.api.nvim_chan_send(job_id, item)
      elseif type(item) == 'number' then
        -- Send raw byte
        vim.api.nvim_chan_send(job_id, string.char(item))
      end
    end
  elseif type(data) == 'string' then
    vim.api.nvim_chan_send(job_id, data)
  else
    error("Invalid data type for write")
  end
end

function M.write_line(data)
  M.write(data)
  if vim.fn.has('win32') then
    M.write({ "\r" })
  else
    M.write({ "\n" })
  end
end

-- Read current screen contents
function M.read_screen()
  local bufnr, job_id, winnr = ensure_terminal()
  
  if not bufnr then
    return {}
  end
  
  -- Get all lines from terminal buffer
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  print(vim.inspect(lines))
  
  -- Get terminal dimensions to determine visible area
  --local winnr = state.winnr
  if winnr and vim.api.nvim_win_is_valid(winnr) then
    local height = vim.api.nvim_win_get_height(winnr)
    local width = vim.api.nvim_win_get_width(winnr)
    print(height, width)
    
    -- Return visible portion (last 'height' lines)
    local visible_lines = {}
    local start_idx = math.max(1, #lines - height + 1)
    
    for i = start_idx, #lines do
      local line = lines[i] or ""
      print(">>>", i, line)
      -- Truncate to window width if needed
      if #line > width then
        line = line:sub(1, width)
      end
      table.insert(visible_lines, line)
    end
    
    return {
      lines = visible_lines,
      dimensions = { height = height, width = width },
      cursor_pos = M.get_cursor_position()
    }
  end
  
  return { lines = lines }
end

-- Get cursor position in terminal
function M.get_cursor_position()
  if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
    return nil
  end
  
  -- Switch to terminal window temporarily to get cursor
  local current_win = vim.api.nvim_get_current_win()
  if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
    vim.api.nvim_set_current_win(state.winnr)
    local cursor = vim.api.nvim_win_get_cursor(state.winnr)
    vim.api.nvim_set_current_win(current_win)
    return { row = cursor[1], col = cursor[2] }
  end
  
  return nil
end

-- Utility functions for common control sequences
M.keys = {
  CTRL_C = '\x03',
  CTRL_D = '\x04',
  CTRL_Z = '\x1a',
  ESC = '\x1b',
  ENTER = '\r',
  TAB = '\t',
  BACKSPACE = '\x08',
  DELETE = '\x7f',
}

-- Helper for Alt/Meta key combinations
function M.alt_key(char)
  return '\x1b' .. char
end

-- Helper for control key combinations  
function M.ctrl_key(char)
  local code = string.byte(char:upper()) - 64
  return string.char(code)
end

-- Plugin setup and commands
function M.setup(opts)
  opts = opts or {}
  state.term_config = vim.tbl_extend('force', state.term_config, opts)
  
  -- Create user commands
  vim.api.nvim_create_user_command('TermManagerShow', function()
    show_terminal()
  end, {})
  
  vim.api.nvim_create_user_command('TermManagerWrite', function(cmd_opts)
    M.write(cmd_opts.args)
  end, { nargs = 1 })

  vim.api.nvim_create_user_command('TermManagerWriteLine', function(cmd_opts)
    M.write_line(cmd_opts.args)
  end, { nargs = 1 })
  
  vim.api.nvim_create_user_command('TermManagerRead', function()
    local screen = M.read_screen()
    print(vim.inspect(screen))
  end, {})
end

-- Public API
M.show = show_terminal
M.hide = function()
  if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
    vim.api.nvim_win_close(state.winnr, false)
    state.winnr = nil
  end
end

M.toggle = function()
  if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
    M.hide()
  else
    M.show()
  end
end

return M
