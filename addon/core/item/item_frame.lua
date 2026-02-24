---@type Addon
local Addon = select(2, ...)

---@class ItemFrame
---@field id string
---@field parentItem Item
---@field frame Frame
local ItemFrame = {}
ItemFrame.__index = ItemFrame

---@param parentItem Item
---@return ItemFrame
function ItemFrame.hidden(parentItem)
    local self = setmetatable({}, ItemFrame)
    self.id  = parentItem.id
    self.parentItem = parentItem
    self.frame = CreateFrame("Frame", parentItem.id, UIParent)
    self.frame.parentItem = parentItem
    local size = self.parentItem.parentItemCollection.parentGroup.itemGrid.itemSize
    self.frame:SetSize(size,  size)

    return self
end

function ItemFrame:applySize()
    local size = self.parentItem.parentItemCollection.parentGroup.itemGrid.itemSize
    self.frame:SetSize(size,  size)
end

---@param point FramePoint
---@param relativeTo Frame
---@param relativePoint FramePoint
---@param offsetX number
---@param offsetY number
function ItemFrame:setPosition(point, relativeTo, relativePoint, offsetX, offsetY)
    self.frame:ClearAllPoints()
    self.frame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
end

function ItemFrame:show()
    self.frame:Show()
end

function ItemFrame:hide()
    if not self.frame then return end

    self.frame:Hide()
end

function ItemFrame:delete()
    self:hide()
    self.frame:SetParent(nil)
    self.frame:ClearAllPoints()
    self.frame:UnregisterAllEvents()
    self.frame = nil
end

Addon.ItemFrame = ItemFrame
return ItemFrame