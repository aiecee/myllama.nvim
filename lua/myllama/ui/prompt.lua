local events = require("myllama.events")

---@alias OnSubmitted fun(text: string) nil

---@class Prompt
---@field buffer integer
---@field window integer
---@field submit_event string
---@field on_submitted OnSubmitted
local Prompt = {}

local function emit_event(event)
  return function(text)
    events:emit(event, text)
  end
end

---@param buffer integer
---@param window integer
---@param submit_event string
---@return Prompt
function Prompt:new(buffer, window, submit_event)
  local on_submitted = emit_event(submit_event)
  local prompt = {
    buffer = buffer,
    window = window,
    submit_event = submit_event,
    on_submitted = on_submitted
  }
  self.__index = self

  vim.keymap.set("i", "<cr>", function()
    local text  = vim.api.nvim_get_current_line()
    on_submitted(text)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, true, {})
  end, { noremap = true, silent = true, buffer = prompt.buffer})

  return setmetatable(prompt, self)
end

---@return boolean
function Prompt:is_valid()
  return self.buffer ~= nil and self.window ~= nil and self.submit_event ~= nil and self.on_submitted ~= nil
end

function Prompt:hide()
  events:off(self.submit_event, self.on_submitted)
  vim.api.nvim_win_close(self.window, { force = true })
  self.buffer = nil
  self.window = nil
  self.submit_event = nil
  self.on_submitted = nil
end

---@alias Anchor "NW" | "NE" | "SW" | "SE"
---@alias Border "none" | "single" | "double" | "rounded" | "solid" | "shadow"

---@class PromptBuilder.WindowOptions
---@field title string
---@field width integer
---@field row integer
---@field col integer
---@field anchor Anchor
---@field border Border

---@class PromptBuilder
---@field window PromptBuilder.WindowOptions
---@field submit_event string
local PromptBuilder = {}

---@return PromptBuilder
function PromptBuilder:new()
  local options = {
    window = {
      title = "Prompt",
      width = 150,
      row = 1,
      col = 1,
      anchor = "NW",
      border = "rounded"
    },
    submit_event = "Prompt:submitted"
  }
  self.__index = self
  return setmetatable(options, self)
end

---@param title string
---@return PromptBuilder
function PromptBuilder:set_title(title)
  self.window.title = title
  return self
end

---@param width integer
---@return PromptBuilder
function PromptBuilder:set_width(width)
  self.window.width = width
  return self
end

---@param row integer
---@return PromptBuilder
function PromptBuilder:set_row(row)
  self.window.row = row
  return self
end

---@param col integer
---@return PromptBuilder
function PromptBuilder:set_col(col)
  self.window.col = col
  return self
end

---@param anchor Anchor
---@return PromptBuilder
function PromptBuilder:set_anchor(anchor)
  self.window.anchor = anchor
  return self
end

---@param border Border
---@return PromptBuilder
function PromptBuilder:set_border(border)
  self.window.border = border
  return self
end

---@param submit_event string
---@return PromptBuilder
function PromptBuilder:set_submit_event(submit_event)
  self.submit_event = submit_event
  return self
end

---@return Prompt
function PromptBuilder:show()
  local options = {
    relative = "editor",
    height = 1,
    style = "minimal"
  }
  local merged_options = vim.tbl_deep_extend("force", options, self.window)
  local buffer = vim.api.nvim_create_buf(false, true)
  local window = vim.api.nvim_open_win(buffer, true, merged_options)
  return Prompt:new(buffer, window, self.submit_event)
end

return PromptBuilder
