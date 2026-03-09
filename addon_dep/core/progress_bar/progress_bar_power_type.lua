---@type Addon
local Addon = select(2, ...)

---@alias ProgressBarPowerTypeValue
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

---@class ProgressBarPowerType
---@field MANA ProgressBarPowerTypeValue
---@field RAGE ProgressBarPowerTypeValue
---@field FOCUS ProgressBarPowerTypeValue
---@field ENERGY ProgressBarPowerTypeValue
---@field COMBO_POINTS ProgressBarPowerTypeValue
---@field RUNES ProgressBarPowerTypeValue
---@field RUNIC_POWER ProgressBarPowerTypeValue
---@field SOUL_SHARDS ProgressBarPowerTypeValue
---@field LUNAR_POWER ProgressBarPowerTypeValue
---@field HOLY_POWER ProgressBarPowerTypeValue
---@field MAELSTROM ProgressBarPowerTypeValue
---@field CHI ProgressBarPowerTypeValue
---@field INSANITY ProgressBarPowerTypeValue
---@field ARCANE_CHARGES ProgressBarPowerTypeValue
---@field FURY ProgressBarPowerTypeValue
---@field PAIN ProgressBarPowerTypeValue
---@field ESSENCE ProgressBarPowerTypeValue
local ProgressBarPowerType = {
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
    ESSENCE = "ESSENCE"
}

---@param progressBarPowerType ProgressBarPowerTypeValue
---@return Enum.PowerType
function ProgressBarPowerType:toPowerType(progressBarPowerType)
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

    local powerType = map[progressBarPowerType]
    if powerType ~= nil then
        return powerType
    end

    error("Unsupported ProgressBarPowerType: " .. tostring(progressBarPowerType), 2)
end

Addon.ProgressBarPowerType = ProgressBarPowerType
return ProgressBarPowerType
