---@type Addon
local Addon = select(2, ...)

---@alias CdmTypeValue
---| "SPELL"
---| "AURA"

---@class CdmType
---@field SPELL CdmTypeValue
---@field AURA CdmTypeValue
local CdmType = {
    SPELL = "SPELL",
    AURA = "AURA",
}

---@param itemType ItemTypeValue|nil
---@return CdmTypeValue|nil
function CdmType.fromItemType(itemType)
    if itemType == Addon.ItemType.SPELL then
        return CdmType.SPELL
    end
    if itemType == Addon.ItemType.AURA then
        return CdmType.AURA
    end

    return nil
end

Addon.CdmType = CdmType
return CdmType
