---@type Addon
local Addon = select(2, ...)

---@alias ItemTypeValue
---| "SPELL"
---| "AURA"
---| "ITEM"

---@class ItemType
---@field SPELL ItemTypeValue
---@field AURA ItemTypeValue
---@field ITEM ItemTypeValue
local ItemType = {
    SPELL = "SPELL",
    AURA = "AURA",
    ITEM = "ITEM",
}

Addon.ItemType = ItemType
return ItemType