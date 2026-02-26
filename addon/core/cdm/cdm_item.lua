---@type Addon
local Addon = select(2, ...)

---@class CdmItem
---@field itemType ItemType
---@field cooldownId number
---@field cdmType CdmType
---@field spellId number
---@field spellName string
---@field isActive boolean
---@field activeFrame Frame
---@field activeViewerName string
---@field initialActiveFrameWidth number
---@field initialActiveFrameHeight number
---@field item Item
---@field itemRatio number
local CdmItem = {}
CdmItem.__index = CdmItem

---@param cooldownId number
---@param cdmType CdmType
---@return CdmItem
function CdmItem.default(cooldownId, cdmType)
    local self = setmetatable({}, CdmItem)
    self.itemType = Addon.ItemType.CDM
    local cooldownInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownId)
    self.cooldownId = cooldownInfo.cooldownID
    self.cdmType = cdmType
    self.spellId = cooldownInfo.spellID
    self.spellName = C_Spell.GetSpellInfo(self.spellId).name

    self.isActive = false
    self.activeFrame = nil
    self.activeViewerName = nil
    self.initialActiveFrameWidth = nil
    self.initialActiveFrameHeight = nil

    self.item = nil
    self.itemRatio = nil

    return self
end

---@param frame Frame
---@param viewerName string
function CdmItem:setActiveBinding(frame, viewerName)
    self.isActive = true
    self.activeFrame = frame
    self.activeViewerName = viewerName
    if self.initialActiveFrameWidth == nil or self.initialActiveFrameHeight == nil then
        self.initialActiveFrameWidth = self.activeFrame:GetWidth()
        self.initialActiveFrameHeight = self.activeFrame:GetHeight()
    end

    local cooldownFrame = self.activeFrame:GetCooldownFrame()
    cooldownFrame:SetCountdownFont("NumberFontNormalSmall")

    if self.item ~= nil then
        self:pairToItem()
    else
        self.activeFrame:Hide()
    end
end

function CdmItem:clearActiveBinding()
    self.isActive = false
    self.activeFrame = nil
    self.activeViewerName = nil
end

---@param item Item
function CdmItem:bind(item)
    self.item = item
    if self.isActive == true then
        self:pairToItem()
    end
end

function CdmItem:unbind()
    if self.activeFrame == nil then return end

    self.item = nil
    self.activeFrame:Hide()
end

function CdmItem:pairToItem()
    if self.activeFrame == nil then return end

    -- Capture frame ratio for later scaling
    self:refreshItemRatio()

    -- Adjust the size and position of the frame
    self.activeFrame:ClearAllPoints()
    self.activeFrame:SetAllPoints(self.item.itemFrame.frame)

    -- Adjust the border scale
    local regions = { self.activeFrame:GetRegions() }
    local borderTex = regions[3]
    borderTex:SetScale(self.itemRatio)

    -- Adjust the glow scale
    if self.activeFrame.SpellActivationAlert then
        self.activeFrame.SpellActivationAlert:ClearAllPoints()
        self.activeFrame.SpellActivationAlert:SetPoint(Addon.FramePoint.CENTER, self.item.itemFrame.frame, Addon.FramePoint.CENTER, 0, 0)
        self.activeFrame.SpellActivationAlert:SetSize(self.item.itemFrame.frame:GetSize())

        -- TODO Might not all be needed
        -- Resize the flash in glow
        if self.activeFrame.SpellActivationAlert.ProcActiveGlow then
            self.activeFrame.SpellActivationAlert.ProcActiveGlow:SetScale(self.itemRatio)
        end
        if self.activeFrame.SpellActivationAlert.ProcStartFlipbook then
            self.activeFrame.SpellActivationAlert.ProcStartFlipbook:SetScale(self.itemRatio)
        end
        if self.activeFrame.SpellActivationAlert.ProcAltGlow then
            self.activeFrame.SpellActivationAlert.ProcAltGlow:SetScale(self.itemRatio)
        end
    end

    if self.activeFrame.GetChargeCountFrame then
        local chargeCountFrame = self.activeFrame:GetChargeCountFrame()
        chargeCountFrame:SetScale(self.itemRatio)
    end

    local cooldownFrame = self.activeFrame:GetCooldownFrame()
    cooldownFrame:SetScale(self.itemRatio)

    if self.activeFrame:IsVisible() == false then
        self.activeFrame:Show()
    end
end

function CdmItem:refreshItemRatio()
    local widthRatio, heightRatio = 1.0, 1.0
    if self.item ~= nil then
        local itemSize = self.item.parentItemCollection.parentGroup.itemGrid.itemSize
        widthRatio = itemSize / self.initialActiveFrameWidth
        heightRatio = itemSize / self.initialActiveFrameHeight
    end

    self.itemRatio = math.min(widthRatio, heightRatio)
end

Addon.CdmItem = CdmItem
return CdmItem