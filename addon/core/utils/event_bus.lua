---@type Addon
local Addon = select(2, ...)

---@class EventBus
---@field listeners table<string, table<fun(...):void, boolean>>
local EventBus = {}
EventBus.listeners = {}

---@param event string
---@param handler fun(...):void
---@return fun() unsubscribe
function EventBus:register(event, handler)
    if not self.listeners[event] then
        self.listeners[event] = {}
    end

    self.listeners[event][handler] = true

    -- return disposer
    return function()
        EventBus:unregister(event, handler)
    end
end

---@param event string
---@param handler fun(...):void
---@return boolean removed
function EventBus:unregister(event, handler)
    local handlers = self.listeners[event]
    if not handlers or not handlers[handler] then
        return false
    end

    handlers[handler] = nil
    if next(handlers) == nil then
        self.listeners[event] = nil
    end
    return true
end

---@param event string
---@vararg any
function EventBus:send(event, ...)
    local handlers = self.listeners[event]
    if not handlers then return end

    -- snapshot so unregister during send is safe
    local snapshot = {}
    for handler in pairs(handlers) do
        table.insert(snapshot, handler)
    end

    for _, handler in ipairs(snapshot) do
        if handlers[handler] then
            handler(...)
        end
    end
end

Addon.EventBus = EventBus
return EventBus