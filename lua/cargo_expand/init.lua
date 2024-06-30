M = {}

M.config = {}

---@class Metadata
---@field packages Package[]
local Metadata = {}

---@class Package
---@field name string
---@field targets Target[]
local Package = {}

---@class Target
---@field name string
---@field crate_types CrateType
local Target = {}

---@alias CrateType
---| '"bin"'
---| '"lib"'

function M.setup() end

local metadata_command = {
	"cargo",
	"metadata",
	"--format-version=1",
	"--no-deps",
	"--quiet",
	"--color=never",
}

---comment
---@param target Target
local function expand_command(target)
	local crate_type, name = target.crate_types, target.name
	local command
    vim.print(crate_type)
    local joined = vim.iter(crate_type):join("")
	if string.match(joined, "lib") then
		command = { "cargo", "expand", "--lib", "--package=" .. name }
	else
		command = { "cargo", "expand", "--bin", name, "--package=" .. name }
	end
	return command
end

---@param event vim.SystemCompleted
local function fill_buffer(event)
	if event.code ~= 0 then
		return
	end

	local output = event.stdout
	local buffer = vim.api.nvim_create_buf(false, true)
	if output == nil then
		return
	end

	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(output, "\n"))
	vim.api.nvim_set_option_value("filetype", "rust", { buf = buffer })
	vim.treesitter.start(buffer)
	vim.api.nvim_open_win(buffer, true, {
		split = "right",
		win = 0,
	})
end

---@param target Target
local function on_choice(target)
	if target == nil then
		return
	end
	vim.system(expand_command(target), { text = true }, vim.schedule_wrap(fill_buffer))
end

---@param event vim.SystemCompleted
local function on_exit(event)
	local code = event.code
	if code ~= 0 then
		vim.notify(event.stderr, vim.log.levels.ERROR)
		return
	end

	---@type Metadata
	local metadata = vim.json.decode(event.stdout)

	local targets = vim.iter(metadata.packages)
		:map(function(pkg)
			return pkg.targets
		end)
		:flatten()

	local results = targets:totable()
	vim.ui.select(results, {
		format_item = function(target)
			return "[" .. target.crate_types[1] .. "] " .. target.name
		end,
	}, on_choice)
end

local function run()
	vim.system(metadata_command, { text = true }, vim.schedule_wrap(on_exit))
end

function M.expand()
	run()
end

return M
