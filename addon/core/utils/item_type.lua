---@type Addon
local Addon = select(2, ...)

---@alias ItemTypeValue
---| "CDM"
---| "TRINKET"

---@class ItemType
---@field CDM ItemTypeValue
---@field TRINKET ItemTypeValue
local ItemType = {
    CDM = "CDM",
    TRINKET = "TRINKET",
}

Addon.ItemType = ItemType
return ItemType