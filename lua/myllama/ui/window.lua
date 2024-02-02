local events = require("myllama.events")

---@alias WindowRelative "editor" | "win" | "cursor" | "mouse"
---@alias WindowAnchor "NW" | "NE" | "SW" | "SE"
---@alias WindowBorder "none" | "single" | "double" | "rounded" | "solid" | "shadow"
---@alias WindowStyle "minimal"
---@alias WindowTitlePosition "left" | "center" | "right"

---@class WindowOptions
---@field relative WindowRelative
---@field win integer
---@field anchor WindowAnchor
---@field width integer
---@field height integer
---@field row integer
---@field col integer
---@field focusable boolean
---@field zindex integer
---@field style WindowStyle
---@field border WindowBorder
---@field title string
---@field title_pos WindowTitlePosition

---@class Window
---@field name string
---@field buffer integer
---@field window_id integer
local Window = {}

---@param name string
---@param buffer integer
---@param window_id integer
---@return Window
function Window:new(name, buffer, window_id)
  local window = {
    name = name,
    buffer = buffer,
    window_id = window_id
  }
  self.__index = self
  return setmetatable(window, self)
end

---@return boolean
function Window:is_valid()
  return self.buffer ~= nil and self.window_id ~= nil
end

function Window:close()
  events:emit("WindowBufferClosing:"..self.name, self.buffer)
  events:emit("WindowClosing:"..self.name, self.window_id)
  vim.api.nvim_close_window(self.window_id, { force = true })
  events:emit("WindowBufferClosed:"..self.name, self.buffer)
  events:emit("WindowClosed:"..self.name, self.window_id)
  self.name = nil
  self.buffer = nil
  self.window_id = nil
end

---@class WindowBuilder
---@field name string
---@field enter boolean
---@field options WindowOptions
local WindowBuilder = {}

---@param name string
function WindowBuilder:new(name)
  local options = {
    title = name,
    focusable = true,
  }
  self.__index = self
  return setmetatable({
    name = name,
    options = options
  }, self)
end

---@param enter boolean
---@return WindowBuilder
function WindowBuilder:set_enter(enter)
  self.enter = enter
  return self
end

---@param relative WindowRelative
---@return WindowBuilder
function WindowBuilder:set_relative(relative)
  self.options.relative = relative
  return self
end

---@param win integer
---@return WindowBuilder
function WindowBuilder:set_win(win)
  self.options.win = win
  return self
end

---@param anchor WindowAnchor
---@return WindowBuilder
function WindowBuilder:set_anchor(anchor)
  self.options.anchor = anchor
  return self
end

---@param width integer
---@return WindowBuilder
function WindowBuilder:set_width(width)
  self.options.width = width
  return self
end

---@param height integer
---@return WindowBuilder
function WindowBuilder:set_height(height)
  self.options.height = height
  return self
end

---@param row integer
---@return WindowBuilder
function WindowBuilder:set_row(row)
  self.options.row = row
  return self
end

---@param col integer
---@return WindowBuilder
function WindowBuilder:set_col(col)
  self.options.col = col
  return self
end

---@param focusable boolean
---@return WindowBuilder
function WindowBuilder:set_focusable(focusable)
  self.options.focusable = focusable
  return self
end

---@param zindex integer
---@return WindowBuilder
function WindowBuilder:set_zindex(zindex)
  self.options.zindex = zindex
  return self
end

---@param style WindowStyle
---@return WindowBuilder
function WindowBuilder:set_style(style)
  self.options.style = style
  return self
end

---@param border WindowBorder
---@return WindowBuilder
function WindowBuilder:set_border(border)
  self.options.border = border
  return self
end

---@param title string
---@return WindowBuilder
function WindowBuilder:set_title(title)
  self.options.title = title
  return self
end

---@param title_pos WindowTitlePosition
---@return WindowBuilder
function WindowBuilder:set_title_pos(title_pos)
  self.options.title_pos = title_pos
  return self
end

---@return Window
function WindowBuilder:show()
  local buffer = vim.api.nvim_create_buf(false, true)
  events:emit("WindowBufferCreated:"..self.name, buffer)
  local window_id = vim.api.nvim_open_win(buffer, self.enter, self.options)
  events:emit("WindowCreated:"..self.name)
  return Window:new(self.name, buffer, window_id)
end

return WindowBuilder
