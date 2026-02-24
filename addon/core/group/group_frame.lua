---@type Addon
local Addon = select(2, ...)

---@class GroupFrame
---@field id string
---@field parentGroup Group
---@field frame Frame
local GroupFrame = {}
GroupFrame.__index = GroupFrame

---@param parentGroup Group
---@return GroupFrame
function GroupFrame.hidden(parentGroup)
    local self = setmetatable({}, GroupFrame)
    self.id  = parentGroup.id
    self.parentGroup = parentGroup
    self.frame = CreateFrame("Frame", parentGroup.id, UIParent)
    self.frame.parentGroup = parentGroup
    self:initialize()

    return self
end

function GroupFrame:initialize()
    local frame = self.frame

    if self.parentGroup.showBackground == true then
        frame.bg = frame:CreateTexture(nil, "BACKGROUND")
        frame.bg:SetAllPoints()
        frame.bg:SetColorTexture(0, 0, 0, 0.35)
    end

    if self.parentGroup.isLocked == false then
        frame:SetMovable(true)
        frame:EnableMouse(true)
    end

    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(f)
        if InCombatLockdown() or self.parentGroup.isLocked == true then return end
        f:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()

        local point, relativeTo, relativePoint, offsetX, offsetY = f:GetPoint(1)
        self.parentGroup.pos.point = point
        self.parentGroup.pos.relativeTo = (relativeTo and relativeTo:GetName()) or "UIParent"
        self.parentGroup.pos.relativePoint = relativePoint
        self.parentGroup.pos.offsetX = offsetX
        self.parentGroup.pos.offsetY = offsetY

        Addon.inst.groupCollection:save()
    end)
end

function GroupFrame:applyPosition()
    local pos = self.parentGroup.pos
    self.frame:ClearAllPoints()
    self.frame:SetPoint(
        pos.point,
        _G[pos.relativeTo],
        pos.relativePoint,
        pos.offsetX,
        pos.offsetY
    )
end

function GroupFrame:applySize()
    local grid = self.parentGroup.itemGrid
    local w = (grid.itemSize * grid.maxCols) + (grid.itemSpacing * (grid.maxCols - 1))
    local h = (grid.itemSize * grid.maxRows) + (grid.itemSpacing * (grid.maxRows - 1))
    self.frame:SetSize(w, h)
end

function GroupFrame:show()
    self.frame:Show()
end

function GroupFrame:hide()
    if not self.frame then return end

    self.frame:Hide()
end

function GroupFrame:delete()
    self:hide()
    self.frame:SetParent(nil)
    self.frame:ClearAllPoints()
    self.frame = nil
end

function GroupFrame:showBackground(showBackground)
    if showBackground == true then
        self.frame.bg = self.frame:CreateTexture(nil, "BACKGROUND")
        self.frame.bg:SetAllPoints()
        self.frame.bg:SetColorTexture(0, 0, 0, 0.35)
    else
        self.frame.bg:Hide()
        self.frame.bg = nil
    end
end

function GroupFrame:handleIsLockedChange()
    if self.parentGroup.isLocked == false then
        self.frame:SetMovable(true)
        self.frame:EnableMouse(true)
    else
        self.frame:SetMovable(false)
        self.frame:EnableMouse(false)
    end
end

Addon.GroupFrame = GroupFrame
return GroupFrame