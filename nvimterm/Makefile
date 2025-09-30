# Makefile for nvimterm plugin development

.PHONY: help install test lint format clean docs

# Default target
help:
	@echo "Available targets:"
	@echo "  install    - Install plugin locally for testing"
	@echo "  test       - Run tests"
	@echo "  lint       - Run linter"
	@echo "  format     - Format code"
	@echo "  clean      - Clean build artifacts"
	@echo "  docs       - Generate documentation"

# Install plugin locally for testing
install:
	@echo "Installing plugin locally..."
	@if not exist "%LOCALAPPDATA%\nvim\pack\local\start" mkdir "%LOCALAPPDATA%\nvim\pack\local\start"
	@if exist "%LOCALAPPDATA%\nvim\pack\local\start\nvimterm" rmdir /s /q "%LOCALAPPDATA%\nvim\pack\local\start\nvimterm"
	@xcopy /e /i /y "." "%LOCALAPPDATA%\nvim\pack\local\start\nvimterm"
	@echo "Plugin installed to %LOCALAPPDATA%\nvim\pack\local\start\nvimterm"

# Run basic tests
test:
	@echo "Running tests..."
	@nvim --headless -c "lua require('examples.basic_usage')" -c "qa"

# Lint Lua files
lint:
	@echo "Linting Lua files..."
	@for /r %%f in (*.lua) do @echo Checking %%f && luacheck "%%f" || exit /b 1

# Format Lua files (requires stylua)
format:
	@echo "Formatting Lua files..."
	@for /r %%f in (*.lua) do stylua "%%f"

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	@if exist "*.tmp" del "*.tmp"
	@if exist "*.log" del "*.log"
	@echo "Clean complete"

# Generate help tags
docs:
	@echo "Generating documentation..."
	@nvim --headless -c "helptags doc/" -c "qa"
	@echo "Documentation generated"