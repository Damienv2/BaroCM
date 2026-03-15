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
    Addon.EventBus:register("DELETE_COOLDOWN", function(cooldown)
        Addon.Utils:deleteFromTable(obj.cooldowns, cooldown)
    end)

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
    for _, adapter in ipairs(self.adapters) do
        local cooldownFound = false
        for _, cooldown in ipairs(self.cooldowns) do
            if cooldown.specId == specId and cooldown.cooldownId == adapter.cooldownId and (cooldown.boundCdmAdapter ~= adapter or adapter.boundCooldown ~= cooldown) then
                cooldown:setBoundCdmAdapter(adapter)
                adapter:setBoundCooldown(cooldown)
                cooldown = true
                Addon.EventBus:send("NEW_BINDING")
                break
            end
        end

        if cooldownFound == false then
            adapter:setBoundCooldown(nil)
        end
    end

    -- Second loop to check if the Cooldown has a Bound Adapter
    for _, cooldown in ipairs(self.cooldowns) do
        local adapterFound = false
        if cooldown.specId == specId then
            for _, adapter in ipairs(self.adapters) do
                if adapter.cooldownId == cooldown.cooldownId then
                    adapterFound = true
                end
            end
        end

        if adapterFound == false then
            cooldown:setBoundCdmAdapter(nil)
        end
    end
end

function CdmBinder:stopPolling()
    if not self.poller then return end

    self.poller:SetScript("OnUpdate", nil)
    self.poller = nil
end

Addon.CdmBinder = CdmBinder
return CdmBinder