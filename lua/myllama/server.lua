local job = require("plenary.job")

local events = require("myllama.events")

---@class ServerOptions
---@field start ServerOptions.Command
---@field stop ServerOptions.Command

---@class PartialServerOptions
---@field start ServerOptions.Command?
---@field stop ServerOptions.Command?

---@class ServerOptions.Command
---@field command string
---@field args string[]?

---@class Server
---@field options ServerOptions
local Server = {}

---@type ServerOptions
local default_options = {
  start = {
    command = "ollama",
    args = { "serve" },
  },
  stop = {
    command = "pkill",
    args = { "-SIGTERM", "ollama" },
  }
}

Server.__index = Server

---@return Server
function Server:new()
  local options = default_options
  local server = setmetatable({options = options}, self)
  return server
end

function Server:start()
  local start_job = job:new({
    command = self.options.start.command,
    args = self.options.start.args,
    on_exit = function(_, code)
      events:emit("SERVER_PROCESS_STARTED", code)
    end,
  })
  start_job:start()
end

function Server:stop()
  local stop_job = job:new({
    command = self.options.stop.command,
    args = self.options.stop.args,
    on_exit = function(_, code)
      events:emit("SERVER_PROCESS_STOPPED", code)
    end
  })
  stop_job:start()
end

local server = Server:new()

---@param self Server
---@param options PartialServerOptions?
---@return Server
function Server.setup(self, options)
  if self ~= server then
    ---@diagnostic disable-next-line: cast-local-type
    options = self
    self = server
  end

  self.options = vim.tbl_deep_extend("force", self.options, options or {})

  return self
end

return server
