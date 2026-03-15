---@type Addon
local Addon = select(2, ...)

---@class CooldownPanel : ContentPanel
local CooldownPanel = setmetatable({}, { __index = Addon.ContentPanel })
CooldownPanel.__index = CooldownPanel

---@param cooldown Cooldown
---@param cooldownButton NodeButton
---@return CooldownPanel
function CooldownPanel:create(cooldown, cooldownButton)
    ---@type CooldownPanel
    local obj = Addon.ContentPanel.create(self)

    obj.cooldownFrame = CreateFrame("Frame", nil, obj.marginFrame)
    obj.cooldownFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.marginFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.cooldownFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.marginFrame, Addon.FramePoint.TOPRIGHT, 0, 0)

    obj.cooldownHeaderFrame = Addon.Widget:createSectionHeader("Cooldown")
    obj.cooldownHeaderFrame:SetParent(obj.cooldownFrame)
    obj.cooldownHeaderFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.cooldownFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.cooldownHeaderFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.cooldownFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    obj.cooldownHeaderFrame:Show()

    obj.leftCooldownFrame = CreateFrame("Frame", nil, obj.cooldownFrame)
    obj.leftCooldownFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.cooldownHeaderFrame, Addon.FramePoint.BOTTOMLEFT, 0, -obj.margin)
    obj.leftCooldownFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.cooldownHeaderFrame, Addon.FramePoint.TOP, -obj.margin / 2, -obj.margin)

    obj.cooldownTypeFrame = Addon.Widget:createDropdown(
            "Cooldown Type",
            {
                options = Addon.CooldownType:getOptions(),
                selectedValue = cooldown.cooldownType,
                onSelect = function(val, text)
                    cooldown:setCooldownType(val)
                    if val == Addon.CooldownType.SPELL then
                        obj:createSpellFrame(cooldown, cooldownButton)
                    elseif val == Addon.CooldownType.AURA then
                        obj:createAuraFrame(cooldown, cooldownButton)
                    end
                end
            }
    )
    obj.cooldownTypeFrame:SetParent(obj.leftCooldownFrame)
    obj.cooldownTypeFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.leftCooldownFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.cooldownTypeFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.leftCooldownFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    obj.cooldownTypeFrame:Show()

    obj.leftCooldownFrame:SetHeight(obj.cooldownTypeFrame:GetHeight())

    obj.cooldownFrame:SetHeight(obj.cooldownHeaderFrame:GetHeight() + obj.margin + obj.leftCooldownFrame:GetHeight())

    if cooldown.cooldownType == Addon.CooldownType.SPELL then
        obj:createSpellFrame(cooldown, cooldownButton)
    elseif cooldown.cooldownType == Addon.CooldownType.AURA then
        obj:createAuraFrame(cooldown, cooldownButton)
    end

    return obj
end

---@param cooldown Cooldown
---@param cooldownButton NodeButton
function CooldownPanel:createSpellFrame(cooldown, cooldownButton)
    self:clearSpellAuraFrame()

    self.spellFrame = CreateFrame("Frame", nil, self.marginFrame)
    self.spellFrame:SetPoint(Addon.FramePoint.TOPLEFT, self.cooldownFrame, Addon.FramePoint.BOTTOMLEFT, 0, -self.margin * 2)
    self.spellFrame:SetPoint(Addon.FramePoint.TOPRIGHT, self.cooldownFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -self.margin * 2)

    self.spellHeaderFrame = Addon.Widget:createSectionHeader("Spell Options")
    self.spellHeaderFrame:SetParent(self.spellFrame)
    self.spellHeaderFrame:SetPoint(Addon.FramePoint.TOPLEFT, self.spellFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    self.spellHeaderFrame:SetPoint(Addon.FramePoint.TOPRIGHT, self.spellFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    self.spellHeaderFrame:Show()

    self.spellSelectionFrame = Addon.Widget:createDropdown(
            "Spell",
            {
                options = Addon.inst.cdmAdapterRegistry:getOptions(cooldown.cooldownType),
                selectedValue = cooldown.cooldownId,
                onSelect = function(val, text)
                    cooldown:setCooldownId(val)
                    cooldownButton:setButtonIcon(Addon.Utils:getSpellTexture(cooldown.spellId))
                    cooldownButton:setButtonText(cooldown.spellName)
                end
            }
    )
    UIDropDownMenu_SetWidth(self.spellSelectionFrame.dropdown, 250)
    self.spellSelectionFrame:SetParent(self.spellFrame)
    self.spellSelectionFrame:SetPoint(Addon.FramePoint.TOPLEFT, self.spellHeaderFrame, Addon.FramePoint.BOTTOMLEFT, 0, -self.margin)
    self.spellSelectionFrame:SetPoint(Addon.FramePoint.TOPRIGHT, self.spellHeaderFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -self.margin)
    self.spellSelectionFrame:Show()

    self.auraSwapEnabledFrame = Addon.Widget:createCheckbox(
            "Aura Swap Enabled",
            {
                checked = cooldown.auraSwapEnabled,
                tooltip = "Toggle aura swapping on cooldown use.",
                onChange = function(checked) cooldown:setAuraSwapEnabled(checked) end
            }
    )
    self.auraSwapEnabledFrame:SetParent(self.spellFrame)
    self.auraSwapEnabledFrame:SetPoint(Addon.FramePoint.TOPLEFT, self.spellSelectionFrame, Addon.FramePoint.BOTTOMLEFT, 0, -self.margin)
    self.auraSwapEnabledFrame:SetPoint(Addon.FramePoint.TOPRIGHT, self.spellSelectionFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -self.margin)
    self.auraSwapEnabledFrame:Show()

    self.spellFrame:SetHeight(self.spellHeaderFrame:GetHeight() + self.margin + self.spellSelectionFrame:GetHeight() + self.margin + self.auraSwapEnabledFrame:GetHeight())
end

---@param cooldown Cooldown
---@param cooldownButton NodeButton
function CooldownPanel:createAuraFrame(cooldown, cooldownButton)
    self:clearSpellAuraFrame()

    self.auraFrame = CreateFrame("Frame", nil, self.marginFrame)
    self.auraFrame:SetPoint(Addon.FramePoint.TOPLEFT, self.cooldownFrame, Addon.FramePoint.BOTTOMLEFT, 0, -self.margin * 2)
    self.auraFrame:SetPoint(Addon.FramePoint.TOPRIGHT, self.cooldownFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -self.margin * 2)

    self.auraHeaderFrame = Addon.Widget:createSectionHeader("Spell Options")
    self.auraHeaderFrame:SetParent(self.auraFrame)
    self.auraHeaderFrame:SetPoint(Addon.FramePoint.TOPLEFT, self.auraFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    self.auraHeaderFrame:SetPoint(Addon.FramePoint.TOPRIGHT, self.auraFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    self.auraHeaderFrame:Show()

    self.auraSelectionFrame = Addon.Widget:createDropdown(
            "Spell",
            {
                options = Addon.inst.cdmAdapterRegistry:getOptions(cooldown.cooldownType),
                selectedValue = cooldown.cooldownId,
                onSelect = function(val, text)
                    cooldown:setCooldownId(val)
                    cooldownButton:setButtonIcon(Addon.Utils:getSpellTexture(cooldown.spellId))
                    cooldownButton:setButtonText(cooldown.spellName)
                end
            }
    )
    UIDropDownMenu_SetWidth(self.auraSelectionFrame.dropdown, 250)
    self.auraSelectionFrame:SetParent(self.auraFrame)
    self.auraSelectionFrame:SetPoint(Addon.FramePoint.TOPLEFT, self.auraHeaderFrame, Addon.FramePoint.BOTTOMLEFT, 0, -self.margin)
    self.auraSelectionFrame:SetPoint(Addon.FramePoint.TOPRIGHT, self.auraHeaderFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -self.margin)
    self.auraSelectionFrame:Show()

    self.auraFrame:SetHeight(self.auraHeaderFrame:GetHeight() + self.margin + self.auraSelectionFrame:GetHeight())
end

function CooldownPanel:clearSpellAuraFrame()
    if self.spellFrame ~= nil then
        self.spellFrame:Hide()
        self.spellHeaderFrame:Hide()
        self.spellSelectionFrame:Hide()
        self.spellFrame = nil
        self.spellHeaderFrame = nil
        self.spellSelectionFrame = nil
    end

    if self.auraFrame ~= nil then
        self.auraFrame:Hide()
        self.auraHeaderFrame:Hide()
        self.auraSelectionFrame:Hide()
        self.auraFrame = nil
        self.auraHeaderFrame = nil
        self.auraSelectionFrame = nil
    end
end

Addon.CooldownPanel = CooldownPanel
return CooldownPanel