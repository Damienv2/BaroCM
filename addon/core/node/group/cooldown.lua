---@type Addon
local Addon = select(2, ...)

---@class Cooldown : GroupMemberNode
---@field cooldownId number
---@field cooldownType CooldownType
---@field spellId number
---@field spellName string
---@field hideIfMissing boolean
---@field auraSwapEnabled boolean
---@field boundCdmAdapter CdmAdapter
local Cooldown = setmetatable({}, { __index = Addon.GroupMemberNode })
Cooldown.__index = Cooldown
Cooldown.type = Addon.NodeType.COOLDOWN

---@return Cooldown
function Cooldown:default()
    ---@type Cooldown
    local obj = Addon.GroupMemberNode.default(self)
    obj.name = "New Cooldown"

    obj.cooldownId = nil
    obj.cooldownType = nil
    obj.spellId = nil
    obj.spellName = nil
    obj.hideIfMissing = true
    obj.auraSwapEnabled = false
    obj.boundCdmAdapter = nil

    Addon.EventBus:send("NEW_COOLDOWN", obj)

    return obj
end

---@return table
function Cooldown:serializeProps()
    local props = Addon.GroupMemberNode.serializeProps(self)
    props.cooldownId = self.cooldownId
    props.cooldownType = self.cooldownType
    props.spellId = self.spellId
    props.spellName = self.spellName
    props.hideIfMissing = self.hideIfMissing
    props.auraSwapEnabled = self.auraSwapEnabled

    return props
end

---@param data table
function Cooldown:deserializeProps(data)
    Addon.GroupMemberNode.deserializeProps(self, data)
    self.cooldownId = data.cooldownId
    self.cooldownType = data.cooldownType
    self.spellId = data.spellId
    self.spellName = data.spellName
    self.hideIfMissing = data.hideIfMissing
    self.auraSwapEnabled = data.auraSwapEnabled
end

---@param cooldownId number
function Cooldown:setCooldownId(cooldownId)
    local cooldownInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownId)
    self.cooldownId = cooldownInfo.cooldownID
    self.spellId = cooldownInfo.spellID
    self.spellName = C_Spell.GetSpellInfo(self.spellId).name
    self.name = self.spellName

    Addon.EventBus:send("SAVE")
end

---@param cooldownType CooldownType
function Cooldown:setCooldownType(cooldownType)
    self.cooldownType = cooldownType

    Addon.EventBus:send("SAVE")
end

---@param spellId number
function Cooldown:setSpellId(spellId)
    self.spellId = spellId
    self.spellName = C_Spell.GetSpellInfo(spellId).name
    self.name = self.spellName

    Addon.EventBus:send("SAVE")
end

---@param hideIfMissing boolean
function Cooldown:setHideIfMissing(hideIfMissing)
    self.hideIfMissing = hideIfMissing

    Addon.EventBus:send("SAVE")
end

---@param auraSwapEnabled boolean
function Cooldown:setAuraSwapEnabled(auraSwapEnabled)
    self.auraSwapEnabled = auraSwapEnabled

    if self.boundCdmAdapter then
        self.boundCdmAdapter:applyAuraSwapSetting()
    end
    Addon.EventBus:send("SAVE")
end

---@param cdmAdapter CdmAdapter?
function Cooldown:setBoundCdmAdapter(cdmAdapter)
    if self.boundCdmAdapter == cdmAdapter then return end

    self.boundCdmAdapter = cdmAdapter

    if self.boundCdmAdapter then
        self.boundCdmAdapter:applyAuraSwapSetting()
    end
    self.parent:refreshChildFrames()
end

---@return boolean
function Cooldown:shouldShow()
    local parentShouldShow = Addon.GroupMemberNode.shouldShow(self)

    local shouldShow = false
    if self.boundCdmAdapter ~= nil and self.boundCdmAdapter:isAttachedToFrame() then
        if self.cooldownType == Addon.CooldownType.SPELL then
            shouldShow = true
        elseif self.cooldownType == Addon.CooldownType.AURA then
            shouldShow = self.boundCdmAdapter.cdmFrame:GetAuraSpellInstanceID() ~= nil or self.hideIfMissing == false
        end
    end

    return parentShouldShow and shouldShow
end

function Cooldown:afterSetParent()
    ---@type Group
    local parent = self.parent

    self.frame:SetSize(parent.childrenGrid.childSize, parent.childrenGrid.childSize)
end

Addon.Cooldown = Cooldown
return Cooldown