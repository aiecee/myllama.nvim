local curl = require("plenary.curl")

---@class ClientOptions
---@field base_url string
---@field port integer

---@class PartialClientOptions
---@field base_url string?
---@field port integer?

---@class ClientGenerateChunk
---@field model string
---@field created_at string
---@field response string
---@field done boolean
---@field context integer[]?

---@alias ClientChunkCallback fun(chunk: ClientGenerateChunk) nil

---@class ClientGenerateOptions
---@field callback ClientChunkCallback?
---@field context integer[]?

---@type ClientOptions
local default_options = {
  base_url = "http://127.0.0.1",
  port = 11434,
}

---@class Client
---@field options ClientOptions
local Client = {}

Client.__index = Client

---@return Client
function Client:new()
  local options = default_options
  local client = setmetatable({options = options}, self)
  return client
end

---@return string[]
function Client:get_models()
  local res = curl.get(self.options.base_url..":"..self.options.port.."/api/tags")
  local success, body = pcall(function() return vim.json.decode(res.body) end)
  local models = {}

  if not success or body == nil then
    return models
  end

  for _, model in pairs(body.models) do
    table.insert(models, model.name)
  end

  return models
end

---@param model string
---@param prompt string
---@param options ClientGenerateOptions?
function Client:generate(model, prompt, options)
  local opts = options or {}
  local body = { model = model, prompt = prompt, stream = true, context = opts.context or nil }

  curl.post(self.options.base_url..":"..self.options.port.."/api/generate", {
    body = vim.json.encode(body),
    ---@param chunk ClientGenerateChunk
    stream = function(_, chunk)
      if opts.callback ~= nil then
        opts.callback(chunk)
      end
    end
  })
end

local client = Client:new()

---@param self Client
---@param options PartialClientOptions?
---@return Client
function Client.setup(self, options)
  if self ~= client then
    ---@diagnostic disable-next-line: cast-local-type
    options = self
    self = client
  end

  self.options = vim.tbl_deep_extend("force", self.options, options or {})

  return self
end

return client
