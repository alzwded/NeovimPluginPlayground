-- Basic usage examples for term-manager plugin

local term = require('term-manager')

-- Initialize the terminal manager
term.setup({
  height = 20,
  position = 'bottom'
})

-- Example 1: Basic terminal interaction
local function example_basic()
  print("=== Basic Terminal Interaction ===")
  
  -- Show the terminal
  term.show()
  
  -- Send a simple command
  term.write('echo "Hello from Neovim plugin!"\n')
  
  -- Wait and read the output
  vim.defer_fn(function()
    local screen = term.read_screen()
    print("Terminal output:")
    for i, line in ipairs(screen.lines) do
      print(string.format("  %2d: %s", i, line))
    end
  end, 200)
end

-- Example 2: Control character usage
local function example_control_chars()
  print("=== Control Character Examples ===")
  
  term.show()
  
  -- Start a process we can interrupt
  term.write('ping 8.8.8.8\n')
  
  -- Wait a moment, then interrupt with Ctrl+C
  vim.defer_fn(function()
    print("Sending Ctrl+C to interrupt ping...")
    term.write(term.keys.CTRL_C)
    
    -- Read the result
    vim.defer_fn(function()
      local screen = term.read_screen()
      print("After interrupt:")
      for _, line in ipairs(screen.lines) do
        if line:match('interrupted') or line:match('terminated') then
          print("  Found: " .. line)
        end
      end
    end, 100)
  end, 2000)
end

-- Example 3: Interactive shell session
local function example_interactive()
  print("=== Interactive Session Example ===")
  
  term.show()
  
  -- Start Python REPL
  term.write('python\n')
  
  vim.defer_fn(function()
    -- Send Python commands
    term.write('x = 42\n')
    term.write('y = 8\n')
    term.write('print(f"The answer is {x + y}")\n')
    
    -- Read output after commands
    vim.defer_fn(function()
      local screen = term.read_screen()
      print("Python REPL output:")
      for _, line in ipairs(screen.lines) do
        if line:match('answer') then
          print("  Found result: " .. line)
        end
      end
      
      -- Exit Python
      term.write('exit()\n')
    end, 500)
  end, 1000)
end

-- Example 4: Multi-step automation
local function example_automation()
  print("=== Automation Example ===")
  
  term.show()
  
  local steps = {
    { cmd = 'echo "Step 1: Creating directory"', delay = 100 },
    { cmd = 'mkdir -p test_dir 2>nul || mkdir test_dir', delay = 100 },
    { cmd = 'echo "Step 2: Listing contents"', delay = 100 },
    { cmd = 'dir', delay = 300 },
    { cmd = 'echo "Step 3: Cleanup"', delay = 100 },
    { cmd = 'rmdir test_dir', delay = 100 },
  }
  
  local function run_step(index)
    if index > #steps then
      print("Automation complete!")
      return
    end
    
    local step = steps[index]
    print(string.format("Running step %d: %s", index, step.cmd))
    term.write(step.cmd .. '\n')
    
    vim.defer_fn(function()
      run_step(index + 1)
    end, step.delay)
  end
  
  run_step(1)
end

-- Example 5: Screen monitoring
local function example_monitoring()
  print("=== Screen Monitoring Example ===")
  
  term.show()
  
  -- Start a command that produces output over time
  term.write('ping -n 5 8.8.8.8\n')
  
  local monitor_count = 0
  local function monitor_output()
    monitor_count = monitor_count + 1
    
    local screen = term.read_screen()
    print(string.format("Monitor check %d:", monitor_count))
    
    -- Look for specific patterns
    for _, line in ipairs(screen.lines) do
      if line:match('Reply from') then
        print("  ✓ Ping successful: " .. line:match('Reply from[^%s]*'))
      elseif line:match('Request timed out') then
        print("  ✗ Ping failed: timeout")
      end
    end
    
    -- Continue monitoring for a while
    if monitor_count < 10 then
      vim.defer_fn(monitor_output, 1000)
    else
      print("Monitoring complete")
    end
  end
  
  -- Start monitoring after initial delay
  vim.defer_fn(monitor_output, 1000)
end

-- Create commands to run examples
vim.api.nvim_create_user_command('TermExampleBasic', example_basic, {})
vim.api.nvim_create_user_command('TermExampleControl', example_control_chars, {})
vim.api.nvim_create_user_command('TermExampleInteractive', example_interactive, {})
vim.api.nvim_create_user_command('TermExampleAutomation', example_automation, {})
vim.api.nvim_create_user_command('TermExampleMonitoring', example_monitoring, {})

print("Term-manager examples loaded!")
print("Available commands:")
print("  :TermExampleBasic")
print("  :TermExampleControl")
print("  :TermExampleInteractive")
print("  :TermExampleAutomation")
print("  :TermExampleMonitoring")