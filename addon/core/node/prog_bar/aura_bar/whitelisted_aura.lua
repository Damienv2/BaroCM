---@type Addon
local Addon = select(2, ...)

---@class WhitelistedAura
---@field aura WhitelistedAura
local WhitelistedAura = {}
WhitelistedAura.__index = WhitelistedAura

---@return WhitelistedAura
function WhitelistedAura:create(spellId, maxStacks)
    ---@type WhitelistedAura
    local obj = setmetatable({}, self)

    obj.name = C_Spell.GetSpellName(spellId)
    obj.spellId = spellId
    obj.minStacks = 0
    obj.maxStacks = maxStacks

    return obj
end

Addon.WhitelistedAura = WhitelistedAura
return WhitelistedAura