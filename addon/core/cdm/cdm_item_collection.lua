---@type Addon
local Addon = select(2, ...)

---@class CdmItemCollection
---@field cdmItems table<number, CdmItem>
---@field poller Frame
local CdmItemCollection = {}
CdmItemCollection.__index = CdmItemCollection

---@return CdmItemCollection
function CdmItemCollection.default()
    local self = setmetatable({}, CdmItemCollection)

    -- TODO - Replace ticker with event driven solution
    -- Load CDM Items
    self.cdmItems = {}
    local attempts = 0
    local maxAttempts = 100
    local ticker
    ticker = C_Timer.NewTicker(0.01, function()
        attempts = attempts + 1

        local essentialCooldownIds = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.Essential, true)
        self:loadCooldownIds(essentialCooldownIds, Addon.CdmType.SPELL)
        local utilityCooldownIds = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.Utility, true)
        self:loadCooldownIds(utilityCooldownIds, Addon.CdmType.SPELL)
        local trackedBuffCooldownIds = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBuff, true)
        self:loadCooldownIds(trackedBuffCooldownIds, Addon.CdmType.AURA)
        --local trackedBarCooldownIds = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBar, true)
        --self:loadCooldownIds(trackedBarCooldownIds, Addon.CdmType.SPELL)

        if next(self.cdmItems) ~= nil then
            ticker:Cancel()
            return
        end

        if attempts >= maxAttempts then
            ticker:Cancel()
            Addon:logError("Failed to load Cooldown Viewer Category Set. Please reload.")
            return
        end
    end)

    self.poller = nil

    return self
end

---@param cooldownIds table
---@param cdmType CdmType
function CdmItemCollection:loadCooldownIds(cooldownIds, cdmType)
    for _, cooldownId in pairs(cooldownIds) do
        local cdmItem = Addon.CdmItem.default(cooldownId, cdmType)
        self.cdmItems[cooldownId] = cdmItem
    end
end

function CdmItemCollection:refreshActiveBindings()
    -- clear old runtime bindings
    for _, cdmItem in pairs(self.cdmItems) do
        cdmItem:clearActiveBinding()
    end

    local VIEWERS = {
        EssentialCooldownViewer,
        UtilityCooldownViewer,
        BuffIconCooldownViewer,
    }

    for _, viewer in ipairs(VIEWERS) do
        assert(viewer and viewer.itemFramePool and viewer.itemFramePool.EnumerateActive, "Viewer/pool missing")

        for itemFrame in viewer.itemFramePool:EnumerateActive() do
            local cooldownId = itemFrame.cooldownID or (itemFrame.GetCooldownID and itemFrame:GetCooldownID())

            -- nil is expected for placeholder frames; skip those
            if cooldownId ~= nil then
                assert(type(cooldownId) == "number", ("Non-numeric cooldownID: %s"):format(tostring(cooldownId)))

                local cdmItem = self.cdmItems[cooldownId]
                if cdmItem ~= nil then
                    cdmItem:setActiveBinding(itemFrame, viewer:GetName() or "UnknownViewer")
                end
            end
        end
    end
end

function CdmItemCollection:startPolling(intervalSeconds)
    if self.poller then return end
    self.poller = CreateFrame("Frame")

    local pollInterval = intervalSeconds or 0.05 -- 20 times/sec

    local pollElapsed = 0
    self.poller:SetScript("OnUpdate", function(_, elapsed)
        pollElapsed = pollElapsed + elapsed
        if pollElapsed < pollInterval then
            return
        end

        pollElapsed = 0
        self:refreshActiveBindings()
    end)
end

function CdmItemCollection:stopPolling()
    if not self.poller then return end
    self.poller:SetScript("OnUpdate", nil)
    self.poller = nil
end

---@param cdmType CdmType
function CdmItemCollection:getOptions(cdmType)
    local options = {}

    for _, cdmItem in pairs(self.cdmItems) do
        if cdmItem.cdmType == cdmType then
            table.insert(options, {
                value = cdmItem,   -- keep callback behavior: value.spellId
                text = cdmItem.spellName .. " - Spell ID: " .. cdmItem.spellId,       -- must be string for dropdown label
            })
        end
    end

    table.sort(options, function(a, b)
        return a.text < b.text
    end)

    return options
end

---@param spellId number
---@return CdmItem
function CdmItemCollection:getCdmItem(spellId)
    local outCdmItem = nil
    for _, cdmItem in pairs(self.cdmItems) do
        if tostring(cdmItem.spellId) == tostring(spellId) then
            outCdmItem = cdmItem
            break
        end
    end

    return outCdmItem
end

Addon.CdmItemCollection = CdmItemCollection
return CdmItemCollection