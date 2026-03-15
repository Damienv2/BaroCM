---@type Addon
local Addon = select(2, ...)

---@alias CooldownTypeValue
---| "SPELL"
---| "AURA"

---@class CooldownType
---@field SPELL CooldownTypeValue
---@field AURA CooldownTypeValue
local CooldownType = {
    SPELL = "SPELL",
    AURA = "AURA",
}

Addon.CooldownType = CooldownType
return CooldownType
