---@type Addon
local Addon = select(2, ...)

---@class EventBus
---@field listeners table<string, fun(...):void[]
EventBus = {}
EventBus.listeners = {}

---@param event string
---@param handler fun(...):void
function EventBus:register(event, handler)
    if not self.listeners[event] then
        self.listeners[event] = {}
    end

    table.insert(self.listeners[event], handler)
end

---@param event string
---@vararg any
function EventBus:send(event, ...)
    local handlers = self.listeners[event]
    if not handlers then return end

    for _, handler in ipairs(handlers) do
        handler(...)
    end
end

Addon.EventBus = EventBus
return EventBus