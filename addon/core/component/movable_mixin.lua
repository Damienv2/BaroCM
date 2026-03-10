---@type Addon
local Addon = select(2, ...)

---@class GroupPos
---@field point FramePointValue
---@field relativeTo string
---@field relativePoint FramePointValue
---@field offsetX number
---@field offsetY number
---@field isLocked boolean

---@class MovableMixin
---@field pos GroupPos
---@field setPoint fun(self: table, point: FramePointValue)
---@field setRelativeTo fun(self: table, relativeTo: string)
---@field setRelativePoint fun(self: table, relativePoint: FramePointValue)
---@field setOffsetX fun(self: table, offsetX: number)
---@field setOffsetY fun(self: table, offsetY: number)
---@field setIsLocked fun(self: table, isLocked: boolean)
MovableMixin = {}
MovableMixin.__index = MovableMixin

---@param obj table
---@return table
function MovableMixin:apply(obj)
    ---@type GroupPos
    obj.pos = {
        point = Addon.FramePoint.CENTER,
        relativeTo = "UIParent",
        relativePoint = Addon.FramePoint.CENTER,
        offsetX = 0,
        offsetY = 0,
        isLocked = false,
    }
    obj.setPoint = self.setPoint
    obj.setRelativeTo = self.setRelativeTo
    obj.setRelativePoint = self.setRelativePoint
    obj.setOffsetX = self.setOffsetX
    obj.setOffsetY = self.setOffsetY
    obj.setIsLocked = self.setIsLocked

    return obj
end

---@param point FramePoint
function MovableMixin:setPoint(point)
    self.pos.point = point

    Addon.EventBus:send("SAVE")
end

---@param relativeTo string
function MovableMixin:setRelativeTo(relativeTo)
    self.pos.relativeTo = relativeTo

    Addon.EventBus:send("SAVE")
end

---@param relativePoint FramePoint
function MovableMixin:setRelativePoint(relativePoint)
    self.pos.relativePoint = relativePoint

    Addon.EventBus:send("SAVE")
end

---@param offsetX number
function MovableMixin:setOffsetX(offsetX)
    self.pos.offsetX = offsetX

    Addon.EventBus:send("SAVE")
end

---@param offsetY number
function MovableMixin:setOffsetY(offsetY)
    self.pos.offsetY = offsetY

    Addon.EventBus:send("SAVE")
end

---@param isLocked boolean
function MovableMixin:setIsLocked(isLocked)
    self.pos.isLocked = isLocked

    Addon.EventBus:send("SAVE")
end

Addon.MovableMixin = MovableMixin
return MovableMixin