local sw = vim.api.nvim_get_option("columns")
local sh = vim.api.nvim_get_option("lines")

local x_pos = (sw - 152) / 2
local y_pos = (sh - 24) / 2

local chat_buffer = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_option(chat_buffer, "buftype", "nofile")
vim.api.nvim_buf_set_option(chat_buffer, "filetype", "markdown")
vim.api.nvim_buf_set_option(chat_buffer, "modifiable", false)

local prompt_buffer = vim.api.nvim_create_buf(false, true)

local events = require("myllama.events")
local chat_buffer_content = ""
events:on("myllama:chat", function(message)
	local new_chat_content = chat_buffer_content .. message
	vim.api.nvim_buf_set_option(chat_buffer, "modifiable", true)
	vim.api.nvim_buf_set_lines(chat_buffer, 0, -1, false, vim.split(new_chat_content, "\n"))
	vim.api.nvim_buf_set_option(chat_buffer, "modifiable", false)
	chat_buffer_content = new_chat_content
end)

vim.keymap.set("i", "<CR>", function()
	local text = vim.api.nvim_get_current_line()
	local client = require("myllama.client")
	client:generate("codellama", text, {
		callback = function(response)
			if not response.done then
				events:emit("myllama:chat", response.response)
			end
		end,
	})
end, { noremap = true, silent = true, buffer = prompt_buffer })

local chat_win_options = {
	relative = "editor",
	title = "Chat",
	width = 150,
	height = 20,
	row = y_pos,
	col = x_pos,
	style = "minimal",
	border = "rounded",
}
local prompt_win_options = {
	relative = "editor",
	title = "Prompt",
	width = 150,
	height = 1,
	row = y_pos + 22,
	col = x_pos,
	style = "minimal",
	border = "rounded",
}

local chat_win = vim.api.nvim_open_win(chat_buffer, true, chat_win_options)
vim.api.nvim_win_set_option(chat_win, "wrap", true)
vim.api.nvim_open_win(prompt_buffer, true, prompt_win_options)
