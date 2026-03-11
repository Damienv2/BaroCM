---@type Addon
local Addon = select(2, ...)

---@class Pos
---@field point FramePointValue
---@field relativeTo string
---@field relativePoint FramePointValue
---@field offsetX number
---@field offsetY number
---@field isLocked boolean

---@class MovableMixin
---@field pos Pos
local MovableMixin = {}

function MovableMixin:initMovable()
    self.pos = {
        point = Addon.FramePoint.CENTER,
        relativeTo = "UIParent",
        relativePoint = Addon.FramePoint.CENTER,
        offsetX = 0,
        offsetY = 0,
        isLocked = false
    }
end

function MovableMixin:serializeMovableProps()
    return {
        pos = {
            point = self.pos.point,
            relativeTo = self.pos.relativeTo,
            relativePoint = self.pos.relativePoint,
            offsetX = self.pos.offsetX,
            offsetY = self.pos.offsetY,
            isLocked = self.pos.isLocked,
        },
    }
end

---@param data {pos: Pos}
function MovableMixin:deserializeMovableProps(data)
    self.pos = data.pos
end

---@param point FramePointValue
function MovableMixin:setPoint(point) self.pos.point = point; Addon.EventBus:send("SAVE") end
---@param relativeTo string
function MovableMixin:setRelativeTo(relativeTo) self.pos.relativeTo = relativeTo; Addon.EventBus:send("SAVE") end
---@param relativePoint FramePointValue
function MovableMixin:setRelativePoint(relativePoint) self.pos.relativePoint = relativePoint; Addon.EventBus:send("SAVE") end
---@param offsetX number
function MovableMixin:setOffsetX(offsetX) self.pos.offsetX = offsetX; Addon.EventBus:send("SAVE") end
---@param offsetY number
function MovableMixin:setOffsetY(offsetY) self.pos.offsetY = offsetY; Addon.EventBus:send("SAVE") end
---@param isLocked boolean
function MovableMixin:setIsLocked(isLocked) self.pos.isLocked = isLocked; Addon.EventBus:send("SAVE") end

function MovableMixin:registerMovableFrame(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)

    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(f)
        if InCombatLockdown() or self.pos.isLocked == true then return end
        f:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()

        local point, relativeTo, relativePoint, offsetX, offsetY = f:GetPoint(1)
        self.pos.point = point
        self.pos.relativeTo = (relativeTo and relativeTo:GetName()) or "UIParent"
        self.pos.relativePoint = relativePoint
        self.pos.offsetX = offsetX
        self.pos.offsetY = offsetY

        Addon.EventBus:send("SAVE")
        Addon.EventBus:send("FRAME_MOVED", self, frame:GetName())
    end)
end

Addon.MovableMixin = MovableMixin
return MovableMixin
