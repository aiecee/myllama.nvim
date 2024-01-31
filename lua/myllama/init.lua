local events = require("myllama.events")
local client = require("myllama.client")
local server = require("myllama.server")

---@class MyLlamaOptions
---@field client PartialClientOptions?
---@field server PartialServerOptions?

---@class MyLlama
---@field selected_model string
local MyLlama = {}

MyLlama.__index = MyLlama

---@return MyLlama
function MyLlama:new()
  local myLlama = setmetatable({ selected_model = nil}, self)
  return myLlama
end

function MyLlama:select_model()
  local models = client:get_models()
  vim.ui.select(
    models,
    { prompt = "Select model" },
    function(model)
      events:emit("MODEL_SELECTED", model)
    end
  )
end

local myLlama = MyLlama:new()

---@param self MyLlama
---@param options MyLlamaOptions?
---@return MyLlama
function MyLlama.setup(self, options)
  if self ~= myLlama then
    ---@diagnostic disable-next-line: cast-local-type
    options = self
    self = myLlama
  end

  local opts = options or {}

  client:setup(opts.client or {})
  server:setup(opts.server or {})

  events:on("MODEL_SELECTED", function(model) self.selected_model = model end)
  return self
end

return myLlama
