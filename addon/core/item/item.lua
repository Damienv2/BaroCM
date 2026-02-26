---@type Addon
local Addon = select(2, ...)

---@class Item
---@field id string
---@field specId number
---@field parentItemCollection ItemCollection
---@field itemFrame ItemFrame
---@field itemType ItemType
---@field cooldownId number
---@field spellId number
---@field spellName string
---@field boundCdmItem CdmItem
---@field slotId number
---@field itemId number
---@field boundTrinket Trinket
local Item = {}
Item.__index = Item

---@param parentItemCollection ItemCollection
---@return Item
function Item.default(parentItemCollection)
    local self = setmetatable({}, Item)
    self.id = Addon.Utils:uuid4()
    self.specId = select(1, GetSpecializationInfo(GetSpecialization()))
    self.parentItemCollection = parentItemCollection
    self.itemFrame = nil
    self.itemType = nil

    self.cooldownId = nil
    self.spellId = nil
    self.spellName = nil
    self.boundCdmItem = nil

    self.slotId = nil
    self.itemId = nil
    self.boundTrinket = nil

    return self
end

---@param serializedItem table
---@param parentItemCollection ItemCollection
---@return Item
function Item.deserialize(serializedItem, parentItemCollection)
    local self = setmetatable({}, Item)
    self.id = serializedItem.id
    self.specId = serializedItem.specId
    self.parentItemCollection = parentItemCollection
    self.itemFrame = nil
    self.itemType = serializedItem.itemType
    self.cooldownId = serializedItem.cooldownId
    self.spellId = serializedItem.spellId
    self.spellName = serializedItem.spellName
    self.boundCdmItem = nil
    self.slotId = serializedItem.slotId
    self.itemId = serializedItem.itemId
    self.boundTrinket = nil

    return self
end

---@return table
function Item:serialize()
    return {
        id = self.id,
        specId = self.specId,
        itemType = self.itemType,
        cooldownId = self.cooldownId,
        spellId = self.spellId,
        spellName = self.spellName,
        slotId = self.slotId,
        itemId = self.itemId,
    }
end

function Item:show()
    if not self.itemFrame then return end

    self.itemFrame:show()
end

function Item:hide()
    if not self.itemFrame then return end

    self.itemFrame:hide()
end

function Item:delete()
    self:hide()

    self.spellId = nil
    if self.boundCdmItem ~= nil then
        self.boundCdmItem:unbind()
    end
    if self.boundTrinket ~= nil then
        self.boundTrinket:unbind()
    end

    if self.itemFrame then
        self.itemFrame:delete()
        self.itemFrame =  nil
    end

    Addon.inst.groupCollection:save()
end

---@param cooldownId number
---@param spellId number
---@param cooldownType ItemType
function Item:setSpell(cooldownId, spellId, cooldownType)
    self.slotId = nil
    self.itemId = nil

    self.itemType = cooldownType
    self.cooldownId = cooldownId
    self.spellId = spellId
    self.spellName = C_Spell.GetSpellInfo(spellId).name

    Addon.inst.groupCollection:save()
end

---@param slotId number
function Item:setSlotId(slotId)
    self.cooldownId = nil
    self.spellId = nil
    self.spellName = nil

    self.itemType = Addon.ItemType.ITEM
    self.slotId = slotId
    self.itemId = GetInventoryItemID("player", slotId)

    Addon.inst.groupCollection:save()
end

---@param parentItemCollection ItemCollection
function Item:setParentItemCollection(parentItemCollection)
    self.parentItemCollection = parentItemCollection

    Addon.inst.groupCollection:save()
end

---@param cdmItem CdmItem
function Item:bindCdmItem(cdmItem)
    if cdmItem == nil then return false end

    local changed = (self.boundCdmItem ~= cdmItem)

    -- If switching to a different CDM item, detach old one.
    if changed and self.boundCdmItem ~= nil then
        self.boundCdmItem:unbind()
    end

    -- Create once, reuse afterwards.
    if self.itemFrame == nil then
        self.itemFrame = Addon.ItemFrame.hidden(self)
    end

    self.boundCdmItem = cdmItem

    -- Important for reload/reinit: always restore reverse association.
    cdmItem:bind(self)

    self.itemFrame:show()
    self.parentItemCollection:refreshItemPosition()

    return changed
end

---@param trinket Trinket
function Item:bindTrinket(trinket)
    if trinket == nil then return false end

    local changed = self.boundTrinket ~= trinket
    if changed and self.boundTrinket ~= nil then
        self.boundTrinket:unbind()
    end

    -- Create once, reuse afterwards.
    if self.itemFrame == nil then
        self.itemFrame = Addon.ItemFrame.hidden(self)
    end

    self.boundTrinket = trinket

    trinket:bind(self)

    self.itemFrame:show()
    self.parentItemCollection:refreshItemPosition()

    return changed
end

function Item:unbind()
    self:delete()
    self.boundCdmItem = nil
    self.boundTrinket = nil
end

function Item:getLabel()
    if self.itemType == Addon.ItemType.SPELL or self.itemType == Addon.ItemType.AURA then
        return self.spellName
    elseif self.itemType == Addon.ItemType.ITEM then
        return "Trinket Slot " .. tostring(self.slotId)
    end
end

function Item:shouldDisplay()
    return (self.boundCdmItem and self.boundCdmItem.isActive == true) or (self.boundTrinket and self.boundTrinket.itemId ~= nil)
end

Addon.Item = Item
return Item