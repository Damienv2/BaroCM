---@type Addon
local Addon = select(2, ...)

---@class CdmBinder
---@field poller Frame
---@field adapters CdmAdapter[]
---@field cooldowns Cooldown[]
local CdmBinder = {}
CdmBinder.__index = CdmBinder

---@return CdmBinder
function CdmBinder:default()
    ---@type CdmBinder
    local obj = setmetatable({}, self)

    obj.poller = nil

    obj.adapters = {}
    Addon.EventBus:register("CREATE_CDM_ADAPTER", function(adapter)
        table.insert(obj.adapters, adapter)
    end)

    obj.cooldowns = {}
    Addon.EventBus:register("NEW_COOLDOWN", function(cooldown)
        table.insert(obj.cooldowns, cooldown)
    end)
    Addon.EventBus:register("NODE_DELETED", function(node)
        if node.type ~= Addon.NodeType.COOLDOWN then return end

        Addon.Utils:deleteFromTable(obj.cooldowns, node)
    end)

    obj:startPolling()

    return obj
end

function CdmBinder:startPolling()
    if self.poller then return end

    self.poller = CreateFrame("Frame")
    self.poller:SetScript("OnUpdate", function(_, elapsed)
        self:bind()
    end)
end

function CdmBinder:bind()
    local specId = select(1, GetSpecializationInfo(GetSpecialization()))
    local foundAny = false

    -- 1. Build a lookup map of active adapters for O(1) access
    local adapterMap = {}
    for _, adapter in ipairs(self.adapters) do
        adapterMap[adapter.cooldownId] = adapter
    end

    -- 2. Single pass to reconcile bindings
    for _, cooldown in ipairs(self.cooldowns) do
        -- A match only exists if it's the right spec AND the ID exists in our adapters
        local targetAdapter = (cooldown.specId == specId) and adapterMap[cooldown.cooldownId] or nil

        -- Only update if the binding has actually changed
        if cooldown.boundCdmAdapter ~= targetAdapter then
            -- Disconnect old adapter if it was pointing back to this cooldown
            if cooldown.boundCdmAdapter then
                cooldown.boundCdmAdapter:setBoundCooldown(nil)
            end

            -- Apply new binding
            cooldown:setBoundCdmAdapter(targetAdapter)

            if targetAdapter then
                targetAdapter:setBoundCooldown(cooldown)
                foundAny = true
            end
        end
    end

    for _, adapter in ipairs(self.adapters) do
        adapter:refreshAttachment()
    end

    if foundAny then
        Addon.EventBus:send("NEW_BINDING")
    end
end

function CdmBinder:stopPolling()
    if not self.poller then return end

    self.poller:SetScript("OnUpdate", nil)
    self.poller = nil
end

---@return CdmAdapter[]
function CdmBinder:getBoundAdapters()
    local boundAdapters = {}
    for _, adapter in pairs(self.adapters) do
        if adapter.boundCooldown ~= nil then
            table.insert(boundAdapters, adapter:serialize())
        end
    end

    return boundAdapters
end

---@return Cooldown[]
function CdmBinder:getBoundCooldowns()
    local boundCooldowns = {}
    for _, cooldown in pairs(self.cooldowns) do
        if cooldown.boundCdmAdapter ~= nil then
            table.insert(boundCooldowns, cooldown:serialize())
        end
    end

    return boundCooldowns
end

Addon.CdmBinder = CdmBinder
return CdmBinder