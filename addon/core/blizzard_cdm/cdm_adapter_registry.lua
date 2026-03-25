---@type Addon
local Addon = select(2, ...)

---@class CdmAdapterRegistry
---@field adapters table<number, CdmAdapter>
local CdmAdapterRegistry = {}
CdmAdapterRegistry.__index = CdmAdapterRegistry

---@return CdmAdapterRegistry
function CdmAdapterRegistry:default()
    local obj = setmetatable({}, self)

    obj.adapters = obj:initAdapters()

    return obj
end

---@return table<number, CdmType>
function CdmAdapterRegistry:initAdapters()
    local adapters = {}

    local essentialCooldownIds = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.Essential, true)
    adapters = Addon.Utils:mergeTable(adapters, self:initAdaptersFromList(essentialCooldownIds, Addon.CdmType.ESSENTIAL))

    local utilityCooldownIds = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.Utility, true)
    adapters = Addon.Utils:mergeTable(adapters, self:initAdaptersFromList(utilityCooldownIds, Addon.CdmType.UTILITY))

    local trackedBuffCooldownIds = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBuff, true)
    adapters = Addon.Utils:mergeTable(adapters, self:initAdaptersFromList(trackedBuffCooldownIds, Addon.CdmType.BUFF_ICON))

    local trackedBarCooldownIds = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBar, true)
    adapters = Addon.Utils:mergeTable(adapters, self:initAdaptersFromList(trackedBarCooldownIds, Addon.CdmType.BUFF_BAR))

    return adapters
end

---@param cooldownIds table
---@param cdmType CdmType
---@return table<number, CdmType>
function CdmAdapterRegistry:initAdaptersFromList(cooldownIds, cdmType)
    local adapters = {}
    for _, cooldownId in pairs(cooldownIds) do
        local adapter = Addon.CdmAdapter:create(cooldownId, cdmType)
        adapters[cooldownId] = adapter
    end

    return adapters
end

---@param cooldownId number
---@param cdmType CdmType
function CdmAdapterRegistry:addAdapter(cooldownId, cdmType)
    if self.adapters[cooldownId] ~= nil then return end

    self.adapters[cooldownId] = Addon.CdmAdapter:create(cooldownId, cdmType)
end

---@param cooldownType CooldownType
function CdmAdapterRegistry:getOptions(cooldownType)
    local options = {}

    for _, adapter in pairs(self.adapters) do
        if Addon.CooldownType:supportsCdmType(cooldownType, adapter.cdmType) then
            table.insert(options, {
                value = adapter.cooldownId,
                text = adapter.spellName .. " - Spell ID: " .. adapter.spellId,
            })
        end
    end

    table.sort(options, function(a, b)
        return a.text < b.text
    end)

    return options
end

---@return CdmAdapter[]
function CdmAdapterRegistry:getAttachedAdapters()
    local attachedAdapters = {}
    for _, adapter in pairs(self.adapters) do
        if adapter:isAttachedToFrame() == true then
            table.insert(attachedAdapters, adapter)
        end
    end

    return attachedAdapters
end

function CdmAdapterRegistry:resetAdapters()
    Addon.EventBus:send("RESET_CDM_ADAPTER")
    self.adapters = self:initAdapters()
end

Addon.CdmAdapterRegistry = CdmAdapterRegistry
return CdmAdapterRegistry