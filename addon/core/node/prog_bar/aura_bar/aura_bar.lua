---@type Addon
local Addon = select(2, ...)

---@class AuraBar : ProgBar
---@field aura WhitelistedAura
local AuraBar = setmetatable({}, { __index = Addon.ProgBar })
AuraBar.__index = AuraBar
AuraBar.type = Addon.NodeType.AURA_BAR

---@return AuraBar
function AuraBar:_construct()
    ---@type AuraBar
    local obj = Addon.ProgBar._construct(self)

    obj.name = "New Aura Bar"

    obj.aura = nil

    return obj
end

---@return table
function AuraBar:serializeProps()
    local props = Addon.ProgBar.serializeProps(self)
    props.aura = self.aura

    return props
end

---@param data table
function AuraBar:deserializeProps(data)
    Addon.ProgBar.deserializeProps(self, data)
    self.aura = data.aura
end

---@param aura WhitelistedAura
function AuraBar:setAura(aura)
    self.aura = aura
end

-----@param powerBarType AuraBarType
--function AuraBar:setAuraBarType(powerBarType)
--    if self.powerBarType == powerBarType then return end
--
--    self.powerBarType = powerBarType
--
--    if powerBarType ~= nil then
--        local targetPowerType = Addon.AuraBarType:toAuraBarType(self.powerBarType)
--        local cur = UnitPower("player", targetPowerType)
--        local max = UnitPowerMax("player", targetPowerType)
--        self:setProgress(cur, max)
--A
--        local powerBarColor = AuraBarColor[targetPowerType]
--        self.bar:SetStatusBarColor(unpack({powerBarColor.r, powerBarColor.g, powerBarColor.b, powerBarColor.a}))
--
--        self:startRefreshingProgress()
--        self.frame:Show()
--    else
--        self:stopRefreshingProgress()
--        self.frame:Hide()
--    end
--
--    Addon.EventBus:send("SAVE")
--end

function AuraBar:refreshProgress()
    Addon.ProgBar.refreshProgress(self)

    local auraState = C_UnitAuras.GetPlayerAuraBySpellID(self.auraId)

    if auraState then
        local cur = auraState.applications or 0
        local max = UnitPowerMax("player", targetPowerType)
        self:setProgress(cur, max)
    end
end

Addon.AuraBar = AuraBar
return AuraBar