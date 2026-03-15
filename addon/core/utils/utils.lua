---@type Addon
local Addon = select(2, ...)

---@class Utils
local Utils = {}

Utils.collectionTexture = "Interface/Icons/INV_Misc_Note_02"
Utils.groupTexture = "Interface/Icons/INV_Misc_Bag_08"
Utils.cooldownTexture = "Interface/Icons/INV_Misc_PocketWatch_01"
Utils.progBarTexture = "Interface/Icons/INV_Misc_Spyglass_02"
Utils.equipmentTexture = "Interface/Icons/INV_Jewelry_TrinketPVP_01"
Utils.consumableTexture = "Interface/Icons/INV_Potion_118"

---@param table1 table
---@param table2 table
---@return table
function Utils:mergeTable(table1, table2)
    local outTable = {}
    for key, value in pairs(table1) do
        outTable[key] = value
    end

    for key, value in pairs(table2) do
        outTable[key] = value
    end

    return outTable
end

---@param tbl table
---@param objectToDelete any
---@return boolean
function Utils:deleteFromTable(tbl, objectToDelete)
    for index, child in ipairs(tbl) do
        if child == objectToDelete then
            table.remove(tbl, index)

            return true
        end
    end

    return false
end

---@param spellId number
function Utils:getSpellTexture(spellId)
    if not spellId then
        return "Interface/Icons/INV_Misc_QuestionMark"
    end

    local texture = C_Spell.GetSpellTexture(spellId)

    return texture or "Interface/Icons/INV_Misc_QuestionMark"
end

---@param itemId number
function Utils:getItemTexture(itemId)
    if not itemId then
        return "Interface/Icons/INV_Misc_QuestionMark"
    end

    -- C_Item.GetItemIconByID is the direct modern equivalent to C_Spell.GetSpellTexture
    local texture = C_Item.GetItemIconByID(itemId)

    return texture or "Interface/Icons/INV_Misc_QuestionMark"
end

---@param itemId number
---@return string
function Utils:getItemNameByItemId(itemId)
    local name = C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemId)
    if not name then
        name = GetItemInfo(itemId)
    end

    return name or "Unknown Item"
end

---@param fontString FontString
---@param fontObjectName string
---@param size number
function Utils:setFontSize(fontString, fontObjectName, size)
    local fontObject = _G[fontObjectName]
    if not (fontString and fontObject) then return end

    local file, _, flags = fontObject:GetFont()
    local scale = fontString:GetEffectiveScale()
    if not scale or scale == 0 then scale = UIParent:GetEffectiveScale() end

    -- compensate for parent scaling
    fontString:SetFont(file, size / scale, flags)
end

Addon.Utils = Utils
return Utils