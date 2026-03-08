---@type Addon
local Addon = select(2, ...)

---@alias ProgressBarTypeValue
---| "AURA"
---| "POWER"

---@class ProgressBarType
---@field AURA ProgressBarTypeValue
---@field POWER ProgressBarTypeValue
local ProgressBarType = {
    AURA = "AURA",
    POWER = "POWER",
}

Addon.ProgressBarType = ProgressBarType
return ProgressBarType
