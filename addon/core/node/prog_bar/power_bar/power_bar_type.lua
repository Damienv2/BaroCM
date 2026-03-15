---@type Addon
local Addon = select(2, ...)

---@alias PowerBarType
---| "MANA"
---| "RAGE"
---| "FOCUS"
---| "ENERGY"
---| "COMBO_POINTS"
---| "RUNES"
---| "RUNIC_POWER"
---| "SOUL_SHARDS"
---| "LUNAR_POWER"
---| "HOLY_POWER"
---| "MAELSTROM"
---| "CHI"
---| "INSANITY"
---| "ARCANE_CHARGES"
---| "FURY"
---| "PAIN"
---| "ESSENCE"

---@class PowerBarType
---@field MANA PowerBarType
---@field RAGE PowerBarType
---@field FOCUS PowerBarType
---@field ENERGY PowerBarType
---@field COMBO_POINTS PowerBarType
---@field RUNES PowerBarType
---@field RUNIC_POWER PowerBarType
---@field SOUL_SHARDS PowerBarType
---@field LUNAR_POWER PowerBarType
---@field HOLY_POWER PowerBarType
---@field MAELSTROM PowerBarType
---@field CHI PowerBarType
---@field INSANITY PowerBarType
---@field ARCANE_CHARGES PowerBarType
---@field FURY PowerBarType
---@field PAIN PowerBarType
---@field ESSENCE PowerBarType
local PowerBarType = {
    MANA = "MANA",
    RAGE = "RAGE",
    FOCUS = "FOCUS",
    ENERGY = "ENERGY",
    COMBO_POINTS = "COMBO_POINTS",
    RUNES = "RUNES",
    RUNIC_POWER = "RUNIC_POWER",
    SOUL_SHARDS = "SOUL_SHARDS",
    LUNAR_POWER = "LUNAR_POWER",
    HOLY_POWER = "HOLY_POWER",
    MAELSTROM = "MAELSTROM",
    CHI = "CHI",
    INSANITY = "INSANITY",
    ARCANE_CHARGES = "ARCANE_CHARGES",
    FURY = "FURY",
    PAIN = "PAIN",
    ESSENCE = "ESSENCE",
}

---@param powerBarType PowerBarType
---@return Enum.PowerBarType
function PowerBarType:toPowerBarType(powerBarType)
    local map = {
        [self.MANA] = Enum.PowerType.Mana,
        [self.RAGE] = Enum.PowerType.Rage,
        [self.FOCUS] = Enum.PowerType.Focus,
        [self.ENERGY] = Enum.PowerType.Energy,
        [self.COMBO_POINTS] = Enum.PowerType.ComboPoints,
        [self.RUNES] = Enum.PowerType.Runes,
        [self.RUNIC_POWER] = Enum.PowerType.RunicPower,
        [self.SOUL_SHARDS] = Enum.PowerType.SoulShards,
        [self.LUNAR_POWER] = Enum.PowerType.LunarPower,
        [self.HOLY_POWER] = Enum.PowerType.HolyPower,
        [self.MAELSTROM] = Enum.PowerType.Maelstrom,
        [self.CHI] = Enum.PowerType.Chi,
        [self.INSANITY] = Enum.PowerType.Insanity,
        [self.ARCANE_CHARGES] = Enum.PowerType.ArcaneCharges,
        [self.FURY] = Enum.PowerType.Fury,
        [self.PAIN] = Enum.PowerType.Pain,
        [self.ESSENCE] = Enum.PowerType.Essence,
    }

    local powerType = map[powerBarType]
    if powerType ~= nil then
        return powerType
    end

    error("Unsupported PowerBarType: " .. tostring(powerBarType), 2)
end

function PowerBarType:getOptions()
    local options = {}
    for key, value in pairs(Addon.PowerBarType) do
        if type(value) == "string" then
            table.insert(options, { value = value, text = key })
        end
    end

    -- Sort alphabetically if desired
    table.sort(options, function(a, b) return a.text < b.text end)

    return options
end

Addon.PowerBarType = PowerBarType
return PowerBarType
