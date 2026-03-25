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
---@field _jailFrame Frame
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
    obj._jailFrame = CreateFrame("Frame")
    obj._jailFrame:Hide()

    -- Bound Item
    obj.boundCooldown = nil

    Addon.EventBus:send("CREATE_CDM_ADAPTER", obj)

    return obj
end

function CdmAdapter:serialize()
    local serialized = {
        cdmType = self.cdmType,
        cooldownId = self.cooldownId,
        spellId = self.spellId,
        spellName = self.spellName,
        cdmViewerName = self.cdmViewerName,
        initialCdmFrameWidth = self.initialCdmFrameWidth,
        initialCdmFrameHeight = self.initialCdmFrameHeight,
        boundCooldown = self.boundCooldown ~= nil and self.boundCooldown:serialize() or {},
        hasCdmFrame = self.cdmFrame ~= nil,
    }
    if self.boundCooldown ~= nil then
        serialized.parentedByCooldown = self.cdmFrame ~= nil and self.boundCooldown.frame == self.cdmFrame:GetParent() or false
    end

    return serialized
end

---@param frame Frame
---@param viewerName string
function CdmAdapter:setCdmFrame(frame, viewerName)
    self.cdmFrame = frame
    self.cdmViewerName = viewerName
    if self.initialCdmFrameWidth == nil and self.initialCdmFrameHeight == nil then
        self.initialCdmFrameWidth = frame:GetWidth()
        self.initialCdmFrameHeight = frame:GetHeight()
    end

    self:applyAuraSwapSetting()
    self:stylizeCdmFrame()
    self:refreshAttachment()
end

function CdmAdapter:clearCdmFrame()
    self.cdmFrame = nil
    self.cdmViewerName = nil
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

            if cooldownId == self.cooldownId then
                cdmFrameFound = true

                if self.cdmFrame ~= itemFrame then
                    self:setCdmFrame(itemFrame, viewer:GetName())
                end
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

    self:applyAuraSwapSetting()
    self:refreshAttachment()
    self:stylizeCdmFrame()
end

function CdmAdapter:refreshAttachment()
    if not self.cdmFrame then return end

    local target = self.boundCooldown and self.boundCooldown.frame or self._jailFrame
    if self.cdmFrame:GetParent() ~= target then
        self.cdmFrame:SetParent(target)
    end

    local p1, relTo1, rp1, x1, y1 = self.cdmFrame:GetPoint(1)
    local p2, relTo2, rp2, x2, y2 = self.cdmFrame:GetPoint(2)
    local wrongPoint = p1 ~= Addon.FramePoint.TOPLEFT
            or relTo1 ~= target
            or rp1 ~= Addon.FramePoint.TOPLEFT
            or x1 ~= 0 or y1 ~= 0
            or p2 ~= Addon.FramePoint.BOTTOMRIGHT
            or relTo2 ~= target
            or rp2 ~= Addon.FramePoint.BOTTOMRIGHT
            or x2 ~= 0 or y2 ~= 0

    if wrongPoint then
        self.cdmFrame:ClearAllPoints()
        self.cdmFrame:SetPoint(Addon.FramePoint.TOPLEFT, target, Addon.FramePoint.TOPLEFT, 0, 0)
        self.cdmFrame:SetPoint(Addon.FramePoint.BOTTOMRIGHT, target, Addon.FramePoint.BOTTOMRIGHT, 0, 0)
    end
end

---@return boolean
function CdmAdapter:isAttachedToFrame()
    return self.cdmFrame ~= nil
end

---@return boolean
function CdmAdapter:isBound()
    return self.boundCooldown ~= nil
end

function CdmAdapter:stylizeCdmFrame()
    local font = "NumberFontNormal"

    if self:isAttachedToFrame() and self:isBound() then
        -- Hide the border
        local regions = { self.cdmFrame:GetRegions() }
        local borderTex = regions[3]
        borderTex:Hide()

        -- Get the parent charge frame
        local chargeFrame = self.cdmFrame.GetChargeCountFrame and self.cdmFrame:GetChargeCountFrame()
        if chargeFrame then
            -- Fallback: Loop children of the chargeFrame to find any FontString
            for _, region in ipairs({chargeFrame:GetRegions()}) do
                if region:IsObjectType("FontString") then
                    Addon.Utils:setFontSize(region, font, Addon.Styling:getChargesFontSize(self.boundCooldown.frame:GetWidth()))
                end
            end
        end

        -- Scale the cooldown font
        local cooldown
        for _, child in ipairs({self.cdmFrame:GetChildren()}) do
            if child:IsObjectType("Cooldown") then
                cooldown = child
                break
            end
        end
        if cooldown then
            cooldown:SetCountdownFont(font)
            local fontString = cooldown:GetCountdownFontString()
            Addon.Utils:setFontSize(fontString, font, Addon.Styling:getCooldownFontSize(self.boundCooldown.frame:GetWidth()))
        end
    end
end

function CdmAdapter:applyAuraSwapSetting()
    --if not self.cdmFrame then return end
    --if not self.cdmFrame.CanUseAuraForCooldown then return end
    --
    ---- Only relevant for cooldown items that can switch to aura visuals.
    --if self.cdmType ~= Addon.CdmType.ESSENTIAL and self.cdmType ~= Addon.CdmType.UTILITY then
    --    return
    --end
    --
    ---- Capture original once per frame object.
    --if self.cdmFrame._barocmOriginalCanUseAuraForCooldown == nil then
    --    self.cdmFrame._barocmOriginalCanUseAuraForCooldown = self.cdmFrame.CanUseAuraForCooldown
    --end
    --
    --local disableAuraSwap = self.boundCooldown and self.boundCooldown.auraSwapEnabled == false
    --
    --if disableAuraSwap then
    --    self.cdmFrame.CanUseAuraForCooldown = function()
    --        return false
    --    end
    --else
    --    self.cdmFrame.CanUseAuraForCooldown = self.cdmFrame._barocmOriginalCanUseAuraForCooldown
    --end
    --
    --if self.cdmFrame.RefreshData then
    --    self.cdmFrame:RefreshData()
    --end
end

Addon.CdmAdapter = CdmAdapter
return CdmAdapter