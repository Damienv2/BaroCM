---@type Addon
local Addon = select(2, ...)

---@class Cooldown : GroupMemberNode
---@field cooldownId number
---@field cooldownType CooldownType
---@field spellId number
---@field spellName string
---@field hideIfMissing boolean
---@field boundCdmAdapter CdmAdapter
local Cooldown = setmetatable({}, { __index = Addon.GroupMemberNode })
Cooldown.__index = Cooldown
Cooldown.type = Addon.NodeType.COOLDOWN

---@return Cooldown
function Cooldown:default()
    ---@type Cooldown
    local obj = Addon.GroupMemberNode.default(self)
    obj.name = "New Cooldown"

    --TODO SETTERS AND IMPLEMENT SETTING COOLDOWN ID
    obj.cooldownId = nil
    obj.cooldownType = nil
    obj.spellId = nil
    obj.spellName = nil
    obj.hideIfMissing = true
    obj.boundCdmAdapter = nil

    Addon.EventBus:send("NEW_COOLDOWN", obj)

    return obj
end

---@return table
function Cooldown:serializeProps()
    return {
        spellId = self.spellId,
        spellName = self.spellName,
        hideIfMissing = self.hideIfMissing,
    }
end

---@param data table
function Cooldown:deserializeProps(data)
    self.spellId = data.spellId
    self.spellName = data.spellName
    self.hideIfMissing = data.hideIfMissing
end

function Cooldown:refreshVisibility()
    if self.cooldownType == Addon.CooldownType.SPELL then
        if self.boundCdmAdapter ~= nil then
            self.frame:Show()
        else
            self.frame:Hide()
        end
    elseif self.cooldownType == Addon.CooldownType.AURA then

    end
end

---@param spellId number
function Cooldown:setSpellId(spellId)
    self.spellId = spellId
    self.spellName = C_Spell.GetSpellInfo(spellId).name

    Addon.EventBus:send("SAVE")
end

---@param hideIfMissing boolean
function Cooldown:setHideIfMissing(hideIfMissing)
    self.hideIfMissing = hideIfMissing

    Addon.EventBus:send("SAVE")
end

---@param cdmAdapter CdmAdapter
function Cooldown:setBoundCdmAdapter(cdmAdapter)
    if self.boundCdmAdapter == cdmAdapter then return end

    self.boundCdmAdapter = cdmAdapter
end

Addon.Cooldown = Cooldown
return Cooldown