local events = require("myllama.events")
local window_builder = require("myllama.ui.window")

---@class Prompt
---@field window Window
local Prompt = {}

---@param name string
---@return Prompt
function Prompt:new(name)
	local window = window_builder
		:new(name)
		:set_enter(true)
		:set_anchor("NW")
		:set_border("single")
		:set_relative("editor")
		:set_focusable(true)
		:set_style("minimal")
		:set_row(1)
		:set_col(1)
		:set_height(1)
		:set_width(150)
		:show()
	vim.keymap.set("i", "<CR>", function()
		local text = vim.api.nvim_get_current_line()
		events:emit("PromptSubmitted:" .. name, text)
		vim.api.nvim_buf_set_lines(window.buffer, 0, -1, false, {})
	end, { noremap = true, silent = true, buffer = window.buffer })
	vim.cmd("startinsert")
	self.__index = self
	return setmetatable({ window = window }, self)
end

function Prompt:close()
	vim.keymap.del("i", "<CR>", { buffer = self.window.buffer })
	self.window:close()
	self.window = nil
end

return Prompt
