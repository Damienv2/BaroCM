---@type Addon
local Addon = select(2, ...)

---@class MovableMixin
---@field point FramePointValue
---@field relativeTo string
---@field relativePoint FramePointValue
---@field offsetX number
---@field offsetY number
---@field isLocked boolean
local MovableMixin = {}

---@param parent Node
function MovableMixin:init(parent)
    self.parent = parent
    self.point = Addon.FramePoint.CENTER
    self.relativeTo = "UIParent"
    self.relativePoint = Addon.FramePoint.CENTER
    self.offsetX = 0
    self.offsetY = 0
    self.isLocked = false
end

function MovableMixin:serializeMovableProps()
    return {
        point = self.point,
        relativeTo = self.relativeTo,
        relativePoint = self.relativePoint,
        offsetX = self.offsetX,
        offsetY = self.offsetY,
        isLocked = self.isLocked,
    }
end

---@param data table
function MovableMixin:deserializeMovableProps(data)
    self.point = data.movable.point
    self.relativeTo = data.movable.relativeTo
    self.relativePoint = data.movable.relativePoint
    self.offsetX = data.movable.offsetX
    self.offsetY = data.movable.offsetY
    self.isLocked = data.movable.isLocked
end

---@param point FramePointValue
function MovableMixin:setPoint(point) self.point = point; Addon.EventBus:send("SAVE") end
---@param relativeTo string
function MovableMixin:setRelativeTo(relativeTo) self.relativeTo = relativeTo; Addon.EventBus:send("SAVE") end
---@param relativePoint FramePointValue
function MovableMixin:setRelativePoint(relativePoint) self.relativePoint = relativePoint; Addon.EventBus:send("SAVE") end
---@param offsetX number
function MovableMixin:setOffsetX(offsetX) self.offsetX = offsetX; Addon.EventBus:send("SAVE") end
---@param offsetY number
function MovableMixin:setOffsetY(offsetY) self.offsetY = offsetY; Addon.EventBus:send("SAVE") end
---@param isLocked boolean
function MovableMixin:setIsLocked(isLocked) self.isLocked = isLocked; Addon.EventBus:send("SAVE") end

---@param frame Frame
function MovableMixin:registerMovableFrame(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)

    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(f)
        if InCombatLockdown() or self.isLocked == true then return end
        f:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()

        local point, relativeTo, relativePoint, offsetX, offsetY = f:GetPoint(1)
        self.point = point
        self.relativeTo = (relativeTo and relativeTo:GetName()) or "UIParent"
        self.relativePoint = relativePoint
        self.offsetX = offsetX
        self.offsetY = offsetY

        Addon.EventBus:send("SAVE")
        Addon.EventBus:send("FRAME_MOVED", self, frame:GetName())
    end)
end

Addon.MovableMixin = MovableMixin
return MovableMixin
