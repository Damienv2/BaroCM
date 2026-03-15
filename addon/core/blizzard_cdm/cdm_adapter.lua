---@type Addon
local Addon = select(2, ...)

---@class CdmAdapter
---@field cdmType CdmType
---@field cooldownId number
---@field spellId number
---@field spellName string
---@field cdmFrame Frame
---@field cdmViewerName string
---@field initialCdmFrameWidth number
---@field initialCdmFrameHeight number
---@field cdmFramePoller Frame
---@field boundCooldown Cooldown
local CdmAdapter = {}
CdmAdapter.__index = CdmAdapter

---@param cooldownId number
---@param cdmType CdmType
---@return CdmAdapter
function CdmAdapter:create(cooldownId, cdmType)
    local obj = setmetatable({}, self)
    obj.cdmType = cdmType

    -- Cooldown info
    local cooldownInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownId)
    obj.cooldownId = cooldownInfo.cooldownID
    obj.spellId = cooldownInfo.spellID
    obj.spellName = C_Spell.GetSpellInfo(obj.spellId).name

    -- CDM Frame
    obj.cdmFrame = nil
    obj.cdmViewerName = nil
    obj.initialCdmFrameWidth = nil
    obj.initialCdmFrameHeight = nil
    obj.cdmFramePoller = nil
    obj:startPolling()

    -- Bound Item
    obj.boundCooldown = nil

    Addon.EventBus:send("CREATE_CDM_ADAPTER", obj)

    return obj
end

---@param frame Frame
---@param viewerName string
function CdmAdapter:setCdmFrame(frame, viewerName)
    self.cdmFrame = frame
    self.viewerName = viewerName
    if self.initialCdmFrameWidth == nil and self.initialCdmFrameHeight == nil then
        self.initialCdmFrameWidth = frame:GetWidth()
        self.initialCdmFrameHeight = frame:GetHeight()
    end

    if self.boundCooldown == nil then
        self.cdmFrame:Hide()
    end
end

function CdmAdapter:clearCdmFrame()
    self.cdmFrame = nil
    self.viewerName = nil
    self.initialCdmFrameWidth = nil
    self.initialCdmFrameHeight = nil
end

function CdmAdapter:startPolling()
    if self.cdmFramePoller then return end

    self.cdmFramePoller = CreateFrame("Frame")
    self.cdmFramePoller:SetScript("OnUpdate", function(_, elapsed)
        self:refreshCdmFrame()
    end)
end

function CdmAdapter:refreshCdmFrame()
    local VIEWERS = {
        EssentialCooldownViewer,
        UtilityCooldownViewer,
        BuffIconCooldownViewer,
    }

    local cdmFrameFound = false
    for _, viewer in ipairs(VIEWERS) do
        for itemFrame in viewer.itemFramePool:EnumerateActive() do
            local cooldownId = itemFrame.cooldownID or (itemFrame.GetCooldownID and itemFrame:GetCooldownID())

            if cooldownId == self.cooldownId and self.cdmFrame ~= itemFrame then
                self:setCdmFrame(itemFrame, viewer:GetName())
                cdmFrameFound = true
            end
        end
    end

    if cdmFrameFound == false then
        self:clearCdmFrame()
    end
end

function CdmAdapter:stopPolling()
    if not self.cdmFramePoller then return end

    self.cdmFramePoller:SetScript("OnUpdate", nil)
    self.cdmFramePoller = nil
end

---@param cooldown Cooldown
function CdmAdapter:setBoundCooldown(cooldown)
    if self.boundCooldown == cooldown then return end

    self.boundCooldown = cooldown

    if cooldown ~= nil then
        self.cdmFrame:SetParent(cooldown.frame)
        self.cdmFrame:ClearAllPoints()
        self.cdmFrame:SetPoint(Addon.FramePoint.CENTER, cooldown.frame, Addon.FramePoint.CENTER, 0, 0)
    else
        self.cdmFrame:Hide()
    end
end

Addon.CdmAdapter = CdmAdapter
return CdmAdapter