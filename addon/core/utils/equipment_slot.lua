---@type Addon
local Addon = select(2, ...)

---@alias EquipmentSlotValue
---| "HEAD"
---| "NECK"
---| "SHOULDER"
---| "SHIRT"
---| "CHEST"
---| "WAIST"
---| "LEGS"
---| "FEET"
---| "WRIST"
---| "HANDS"
---| "FINGER1"
---| "FINGER2"
---| "TRINKET1"
---| "TRINKET2"
---| "BACK"
---| "MAINHAND"
---| "OFFHAND"
---| "RANGED"
---| "TABARD"

---@class EquipmentSlot
---@field HEAD number
---@field NECK number
---@field SHOULDER number
---@field SHIRT number
---@field CHEST number
---@field WAIST number
---@field LEGS number
---@field FEET number
---@field WRIST number
---@field HANDS number
---@field FINGER1 number
---@field FINGER2 number
---@field TRINKET1 number
---@field TRINKET2 number
---@field BACK number
---@field MAINHAND number
---@field OFFHAND number
---@field RANGED number
---@field TABARD number
local EquipmentSlot = {
    HEAD = INVSLOT_HEAD,
    NECK = INVSLOT_NECK,
    SHOULDER = INVSLOT_SHOULDER,
    SHIRT = INVSLOT_BODY,
    CHEST = INVSLOT_CHEST,
    WAIST = INVSLOT_WAIST,
    LEGS = INVSLOT_LEGS,
    FEET = INVSLOT_FEET,
    WRIST = INVSLOT_WRIST,
    HANDS = INVSLOT_HAND,
    FINGER1 = INVSLOT_FINGER1,
    FINGER2 = INVSLOT_FINGER2,
    TRINKET1 = INVSLOT_TRINKET1,
    TRINKET2 = INVSLOT_TRINKET2,
    BACK = INVSLOT_BACK,
    MAINHAND = INVSLOT_MAINHAND,
    OFFHAND = INVSLOT_OFFHAND,
    RANGED = INVSLOT_RANGED,
    TABARD = INVSLOT_TABARD,
}

function EquipmentSlot:getOptions()
    local options = {}
    for key, value in pairs(EquipmentSlot) do
        if type(value) == "number" then
            table.insert(options, { value = value, text = key })
        end
    end

    table.sort(options, function(a, b) return a.text < b.text end)
    return options
end

---@param slotId number
---@return EquipmentSlotValue|nil
function EquipmentSlot:getEnumBySlotId(slotId)
    for key, value in pairs(EquipmentSlot) do
        if type(value) == "number" and value == slotId then
            return key
        end
    end
    return nil
end

---@param enumValue EquipmentSlotValue
---@return number|nil
function EquipmentSlot:getSlotIdByEnum(enumValue)
    local slotId = EquipmentSlot[enumValue]
    if type(slotId) == "number" then
        return slotId
    end
    return nil
end

Addon.EquipmentSlot = EquipmentSlot
return EquipmentSlot
