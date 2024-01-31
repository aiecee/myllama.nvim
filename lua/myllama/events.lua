---@alias Listener fun(...) nil

---@class EventTable
---@field [string] Listener[]
local event_table = {}

---@class Events
---@field listeners EventTable
---@field onceListeners EventTable
local Events = {}

Events.__index = Events

function Events.new()
    local self = {
        listeners = {},
        onceListeners = {}
    }
    return setmetatable(self, Events)
end

function Events:on(eventName, listener)
    if not self.listeners[eventName] then
        self.listeners[eventName] = {}
    end
    table.insert(self.listeners[eventName], listener)
end

function Events:off(eventName, listener)
    if self.listeners[eventName] then
        for i, v in ipairs(self.listeners[eventName]) do
            if v == listener then
                table.remove(self.listeners[eventName], i)
            end
        end
    end
end

function Events:once(eventName, listener)
    if not self.onceListeners[eventName] then
        self.onceListeners[eventName] = {}
    end
    table.insert(self.onceListeners[eventName], listener)
end

function Events:emit(eventName, ...)
    if self.listeners[eventName] then
        for _, v in ipairs(self.listeners[eventName]) do
            vim.schedule_wrap(v)(...)
        end
    end
    if self.onceListeners[eventName] then
        for _, v in ipairs(self.onceListeners[eventName]) do
            vim.schedule_wrap(v)(...)
        end
        self.onceListeners[eventName] = nil
    end
end

local events = Events:new()

return events
