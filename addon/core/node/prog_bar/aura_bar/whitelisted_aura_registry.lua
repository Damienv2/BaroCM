---@type Addon
local Addon = select(2, ...)

---@class WhitelistedAuraRegistry
local WhitelistedAuraRegistry = {}

WhitelistedAuraRegistry.auras = {
    Addon.WhitelistedAura(1221167, 50),
}

Addon.WhitelistedAuraRegistry = WhitelistedAuraRegistry
return WhitelistedAuraRegistry