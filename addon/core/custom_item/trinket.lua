---@type Addon
local Addon = select(2, ...)

---@class Trinket
---@field itemType ItemType
---@field slotId number
---@field itemId number
---@field slotName string
---@field initialActiveFrameWidth number
---@field initialActiveFrameHeight number
---@field activeFrame Frame
---@field item Item
---@field itemRatio number
local Trinket = {}
Trinket.__index = Trinket

---@param itemId number|nil
---@param slotId number
---@return Trinket
function Trinket.default(itemId, slotId)
    local self = setmetatable({}, Trinket)
    self.itemType = Addon.ItemType.TRINKET
    self.slotId = slotId
    self.itemId = itemId
    self.slotName = "Trinket Slot " .. tostring(slotId)

    self.initialActiveFrameWidth = 48
    self.initialActiveFrameHeight = 48
    self.activeFrame = self:createActiveFrame()
    self:refreshRuntimeState()

    self.item = nil
    self.itemRatio = nil

    return self
end

---@return Frame
function Trinket:createActiveFrame()
    local f = CreateFrame("Frame", name, parent)
    f:SetSize(self.initialActiveFrameWidth, self.initialActiveFrameHeight)

    -- ARTWORK: icon
    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    f.icon = icon

    -- ARTWORK: mask that clips icon
    local mask = f:CreateMaskTexture(nil, "ARTWORK")
    mask:SetAllPoints()
    mask:SetAtlas("UI-HUD-CoolDownManager-Mask")
    icon:AddMaskTexture(mask)
    f.iconMask = mask

    -- OVERLAY: decorative border/overlay
    local overlay = f:CreateTexture(nil, "OVERLAY")
    overlay:SetAtlas("UI-HUD-CoolDownManager-IconOverlay", false)
    overlay:SetPoint("TOPLEFT", -8, 7)
    overlay:SetPoint("BOTTOMRIGHT", 8, -7)
    f.overlay = overlay

    -- Cooldown frame with Blizzard swipe/edge textures
    local cd = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
    cd:SetAllPoints()
    cd:SetSwipeTexture("Interface\\HUD\\UI-HUD-CoolDownManager-Icon-Swipe")
    cd:SetEdgeTexture("Interface\\Cooldown\\UI-HUD-ActionBar-SecondaryCooldown")
    cd:SetCountdownFont("NumberFontNormalSmall")
    f.cooldown = cd

    return f
end

---@param item Item
function Trinket:bind(item)
    self.item = item
    self:pairToItem()
end

function Trinket:unbind()
    self.item = nil
    self.activeFrame:Hide()
end

function Trinket:pairToItem()
    self:refreshItemRatio()

    -- Adjust the size and position of the frame
    self.activeFrame:ClearAllPoints()
    self.activeFrame:SetAllPoints(self.item.itemFrame.frame)

    self.activeFrame.overlay:ClearAllPoints()
    self.activeFrame.overlay:SetPoint("TOPLEFT", -8, 7)
    self.activeFrame.overlay:SetPoint("BOTTOMRIGHT", 8, -7)
    self.activeFrame.overlay:SetScale(self.itemRatio)

    self.activeFrame.cooldown:SetScale(self.itemRatio)

    self:refreshRuntimeState()
    if self.activeFrame:IsVisible() == false then
        self.activeFrame:Show()
    end
end

function Trinket:refreshRuntimeState()
    if self.itemId == nil then
        self.itemId = GetInventoryItemID("player", self.slotId)
    end

    if self.itemId == nil then return end

    local texture = C_Item.GetItemIconByID(self.itemId)
    if texture then
        self.activeFrame.icon:SetTexture(texture)
    end

    local startTime, duration, enable = GetInventoryItemCooldown("player", self.slotId)
    if startTime and duration and duration > 0 and enable == 1 then
        self.activeFrame.cooldown:SetCooldown(startTime, duration)
        self.activeFrame.icon:SetDesaturated(true)
    else
        self.activeFrame.cooldown:Clear()
        self.activeFrame.icon:SetDesaturated(false)
    end

    self.isActive = true
end

---@return boolean
function Trinket:isOnUseTrinket()
    --local _, spellId = GetItemSpell(self.itemId)
    --
    --return spellId ~= nil
    return true
end

function Trinket:refreshItemRatio()
    local widthRatio, heightRatio = 1.0, 1.0
    if self.item ~= nil then
        local itemSize = self.item.parentItemCollection.parentGroup.itemGrid.itemSize
        widthRatio = itemSize / self.initialActiveFrameWidth
        heightRatio = itemSize / self.initialActiveFrameHeight
    end

    self.itemRatio = math.min(widthRatio, heightRatio)
end

Addon.Trinket = Trinket
return Trinket
