---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)
---@Type StyleVariables
local style = Addon.StyleVariables

---@class PropertiesPanel
---@field parentOptionsPanel OptionsPanel
---@field frame Frame
---@field frameWidth number
---@field frameHeight number
---@field scrollContentFrame Frame
---@field activeFrames Frame[]
local PropertiesPanel = {}
PropertiesPanel.__index = PropertiesPanel

---@param parentOptionsPanel OptionsPanel
---@param frameWidth number
---@param frameHeight number
---@return PropertiesPanel
function PropertiesPanel.create(parentOptionsPanel, frameWidth, frameHeight)
    local self = setmetatable({}, PropertiesPanel)
    self.parentOptionsPanel = parentOptionsPanel

    self.frame = CreateFrame("Frame", nil, self.parentOptionsPanel.frame, "BackdropTemplate")
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight

    self.scrollContentFrame = nil
    self.activeFrames = {}

    self:initializeFrame()

    return self
end

function PropertiesPanel:initializeFrame()
    self.frame:SetSize(self.frameWidth, self.frameHeight)
    self.frame:SetBackdrop({
        bgFile = style.innerPanel.backgroundFile,
        edgeFile = style.innerPanel.borderFile,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    self.frame:SetBackdropColor(unpack(style.backgroundColor))
    self.frame:SetBackdropBorderColor(unpack(style.borderColor))

    self.scrollContentFrame = Addon.Widgets:createScrollBar(self.frame)
end

---@param group Group
function PropertiesPanel:setGroupPropertiesPanel(group)
    self:clearScrollContent()

    local heightIncrement = math.floor(self.frameHeight / 20)

    -- Setup the Position region
    local positionRegion = CreateFrame("Frame", nil, self.scrollContentFrame)
    positionRegion:SetPoint(Addon.FramePoint.TOPLEFT, self.scrollContentFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    positionRegion:SetSize(self.scrollContentFrame:GetWidth(), heightIncrement * 6)
    local positionHeader = Addon:getSectionHeader(self.scrollContentFrame, "Group Position", self.scrollContentFrame:GetWidth() - style.margin * 2)
    positionHeader:SetPoint(Addon.FramePoint.TOPLEFT, positionRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)
    local leftPositionRegion = CreateFrame("Frame", nil, positionRegion)
    leftPositionRegion:SetPoint(Addon.FramePoint.TOPLEFT, positionHeader, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    leftPositionRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 6 - positionHeader:GetHeight())
    local rightPositionRegion = CreateFrame("Frame", nil, positionRegion)
    rightPositionRegion:SetPoint(Addon.FramePoint.TOPLEFT, leftPositionRegion, Addon.FramePoint.TOPRIGHT, 0, 0)
    rightPositionRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 6 - positionHeader:GetHeight())

    -- Setup the X Offset frame
    local xOffsetFrame, _ = Addon:createTextField(leftPositionRegion, "X-Offset", {
        width = 175,
        text = tostring(group.pos.offsetX or 1),
        numericOnly = true,
        min = -9999,
        max = 9999,
        clamp = true,
        onEnterPressed = function(value)
            group:setOffsetX(value)
        end
    })
    xOffsetFrame:SetPoint(Addon.FramePoint.TOPLEFT, leftPositionRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)

    -- Setup the anchor dropdown
    local anchorPointFrame, setAnchorPointOptions = Addon:createDropdown(leftPositionRegion, "Anchor Point", nil, {
        width = 175,
        selectedValue = group.pos.point
    })
    setAnchorPointOptions(
            Addon.FramePoint,
            function(value, text)
                group:setPoint(value)
            end
    )
    anchorPointFrame:SetPoint(Addon.FramePoint.TOPLEFT, xOffsetFrame, Addon.FramePoint.BOTTOMLEFT, 0, style.negMargin)

    -- Setup the Y Offset frame
    local yOffsetFrame, _ = Addon:createTextField(rightPositionRegion, "Y-Offset", {
        width = 175,
        text = tostring(group.pos.offsetY or 1),
        numericOnly = true,
        min = -9999,
        max = 9999,
        clamp = true,
        onEnterPressed = function(value)
            group:setOffsetY(value)
        end
    })
    yOffsetFrame:SetPoint(Addon.FramePoint.TOPLEFT, rightPositionRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)

    -- Setup the show background frame
    local showBackgroundFrame = Addon.Widgets:createCheckbox(rightPositionRegion, "Show Background", {
        checked = group.showBackground,
        onChange = function(v) group:setShowBackground(v) end
    })
    showBackgroundFrame:SetPoint(Addon.FramePoint.TOPLEFT, yOffsetFrame, Addon.FramePoint.BOTTOMLEFT, 0, style.negMargin)

    -- Setup the is locked frame
    local isLockedFrame = Addon.Widgets:createCheckbox(rightPositionRegion, "Locked", {
        checked = group.isLocked,
        onChange = function(v) group:setIsLocked(v) end
    })
    isLockedFrame:SetPoint(Addon.FramePoint.TOPLEFT, showBackgroundFrame, Addon.FramePoint.BOTTOMLEFT, 0, style.negMargin)

    table.insert(self.activeFrames, positionRegion)

    -- Setup the layout region two column split with header
    local layoutRegion = CreateFrame("Frame", nil, self.scrollContentFrame)
    layoutRegion:SetPoint(Addon.FramePoint.TOPLEFT, positionRegion, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    layoutRegion:SetSize(self.frame:GetWidth(), heightIncrement * 8)
    local layoutHeader = Addon:getSectionHeader(layoutRegion, "Group Layout", self.frame:GetWidth() - style.margin * 2)
    layoutHeader:SetPoint(Addon.FramePoint.TOPLEFT, layoutRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)
    local leftLayoutRegion = CreateFrame("Frame", nil, layoutRegion)
    leftLayoutRegion:SetPoint(Addon.FramePoint.TOPLEFT, layoutHeader, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    leftLayoutRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 8 - layoutHeader:GetHeight())
    local rightLayoutRegion = CreateFrame("Frame", nil, layoutRegion)
    rightLayoutRegion:SetPoint(Addon.FramePoint.TOPLEFT, leftLayoutRegion, Addon.FramePoint.TOPRIGHT, 0, 0)
    rightLayoutRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 8 - layoutHeader:GetHeight())

    -- Setup the Number of Rows text field
    local maxRowsFrame, _ = Addon:createTextField(leftLayoutRegion, "Number of Rows", {
        width = 175,
        text = tostring(group.itemGrid.maxRows or 1),
        numericOnly = true,
        min = 1,
        max = 12,
        clamp = true,
        onEnterPressed = function(value)
            group:setMaxRows(value)
        end
    })
    maxRowsFrame:SetPoint(Addon.FramePoint.TOPLEFT, leftLayoutRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)

    -- Setup the Row Growth frame
    local rowGrowthFrame, setRowGrowthOptions = Addon:createDropdown(leftLayoutRegion, "Row Growth", nil, {
        width = 175,
        selectedValue = group.itemGrid.rowGrowth
    })
    setRowGrowthOptions(
            Addon.RowGrowth,
            function(value, text)
                group:setRowGrowth(value)
            end
    )
    rowGrowthFrame:SetPoint(Addon.FramePoint.TOPLEFT, maxRowsFrame, Addon.FramePoint.BOTTOMLEFT, 0, style.negMargin)

    -- Setup the Growth Priority frame
    local growthPrioFrame, setGrowthPriosOption = Addon:createDropdown(leftLayoutRegion, "Growth Priority", nil, {
        width = 175,
        selectedValue = group.itemGrid.growthPrio
    })
    setGrowthPriosOption(
            Addon.GrowthPrio,
            function(value, text)
                group:setGrowthPrio(value)
            end
    )
    growthPrioFrame:SetPoint(Addon.FramePoint.TOPLEFT, rowGrowthFrame, Addon.FramePoint.BOTTOMLEFT, 0, style.negMargin)

    -- Setup the Number of Columns frame
    local maxColsFrame, _ = Addon:createTextField(rightLayoutRegion, "Number of Columns", {
        width = 175,
        text = tostring(group.itemGrid.maxCols or 1),
        numericOnly = true,
        min = 1,
        max = 12,
        clamp = true,
        onEnterPressed = function(value)
            group:setMaxCols(value)
        end
    })
    maxColsFrame:SetPoint(Addon.FramePoint.TOPLEFT, rightLayoutRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)

    -- Setup the Column Growth frame
    local colGrowthFrame, setColGrowthOption = Addon:createDropdown(rightLayoutRegion, "Column Growth", nil, {
        width = 175,
        selectedValue = group.itemGrid.colGrowth
    })
    setColGrowthOption(
            Addon.ColGrowth,
            function(value, text)
                group:setColGrowth(value)
            end
    )
    colGrowthFrame:SetPoint(Addon.FramePoint.TOPLEFT, maxColsFrame, Addon.FramePoint.BOTTOMLEFT, 0, style.negMargin)

    table.insert(self.activeFrames, layoutRegion)

    -- Setup the Icon Region
    local iconRegion = CreateFrame("Frame", nil, self.scrollContentFrame)
    iconRegion:SetPoint(Addon.FramePoint.TOPLEFT, layoutRegion, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    iconRegion:SetSize(self.frame:GetWidth(), heightIncrement * 7)
    local iconHeader = Addon:getSectionHeader(iconRegion, "Icon Styling", self.frame:GetWidth() - style.margin * 2)
    iconHeader:SetPoint(Addon.FramePoint.TOPLEFT, iconRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)
    local leftIconRegion = CreateFrame("Frame", nil, layoutRegion)
    leftIconRegion:SetPoint(Addon.FramePoint.TOPLEFT, iconHeader, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    leftIconRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 8 - iconHeader:GetHeight())
    local rightIconRegion = CreateFrame("Frame", nil, layoutRegion)
    rightIconRegion:SetPoint(Addon.FramePoint.TOPLEFT, leftIconRegion, Addon.FramePoint.TOPRIGHT, 0, 0)
    rightIconRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 8 - iconHeader:GetHeight())

    -- Setup the Item Size selection
    local itemSizeFrame, _ = Addon:createTextField(leftIconRegion, "Item Size", {
        width = 175,
        text = tostring(group.itemGrid.itemSize or 1),
        numericOnly = true,
        min = -9999,
        max = 9999,
        clamp = true,
        onEnterPressed = function(value)
            group:setItemSize(value)
        end
    })
    itemSizeFrame:SetPoint(Addon.FramePoint.TOPLEFT, leftIconRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)

    -- Setup the Item Spacing selection
    local itemSpacingFrame, _ = Addon:createTextField(rightIconRegion, "Item Spacing", {
        width = 175,
        text = tostring(group.itemGrid.itemSpacing or -1),
        numericOnly = true,
        min = -9999,
        max = 9999,
        clamp = true,
        onEnterPressed = function(value)
            group:setItemSpacing(value)
        end
    })
    itemSpacingFrame:SetPoint(Addon.FramePoint.TOPLEFT, rightIconRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)
end

---@param item Item
---@param itemBtn ItemBtn
function PropertiesPanel:setItemPropertiesPanel(item, itemBtn)
    self:clearScrollContent()

    local heightIncrement = math.floor(self.frameHeight / 20)

    local spellRegion = CreateFrame("Frame", nil, self.scrollContentFrame)
    local spellWarningText = spellRegion:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local auraRegion = CreateFrame("Frame", nil, self.scrollContentFrame)
    local auraWarningText = spellRegion:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local itemRegion = CreateFrame("Frame", nil, self.scrollContentFrame)

    -- Setup the Item Type
    local cooldownTypeRegion = CreateFrame("Frame", nil, self.scrollContentFrame)
    cooldownTypeRegion:SetPoint(Addon.FramePoint.TOPLEFT, self.scrollContentFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    cooldownTypeRegion:SetSize(self.scrollContentFrame:GetWidth(), heightIncrement * 4)
    local cooldownTypeHeader = Addon:getSectionHeader(cooldownTypeRegion, "Cooldown", self.scrollContentFrame:GetWidth() - style.margin * 2)
    cooldownTypeHeader:SetPoint(Addon.FramePoint.TOPLEFT, cooldownTypeRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)
    local leftCooldownTypeRegion = CreateFrame("Frame", nil, cooldownTypeRegion)
    leftCooldownTypeRegion:SetPoint(Addon.FramePoint.TOPLEFT, cooldownTypeHeader, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    leftCooldownTypeRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 4 - cooldownTypeHeader:GetHeight())
    local rightCooldownTypeRegion = CreateFrame("Frame", nil, cooldownTypeRegion)
    rightCooldownTypeRegion:SetPoint(Addon.FramePoint.TOPLEFT, leftCooldownTypeRegion, Addon.FramePoint.TOPRIGHT, 0, 0)
    rightCooldownTypeRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 4 - cooldownTypeHeader:GetHeight())
    local cooldownTypeFrame, setCooldownTypeOption = Addon:createDropdown(leftCooldownTypeRegion, "Type", nil, {
        width = 175,
        selectedValue = item.itemType
    })
    setCooldownTypeOption(
            Addon.ItemType,
            function(value, text)
                if value == Addon.ItemType.SPELL then
                    spellRegion:Show()
                    auraRegion:Hide()
                    itemRegion:Hide()
                elseif value == Addon.ItemType.AURA then
                    spellRegion:Hide()
                    auraRegion:Show()
                    itemRegion:Hide()
                elseif value == Addon.ItemType.ITEM then
                    spellRegion:Hide()
                    auraRegion:Hide()
                    itemRegion:Show()
                end
            end
    )
    cooldownTypeFrame:SetPoint(Addon.FramePoint.TOPLEFT, leftCooldownTypeRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)

    spellRegion:SetPoint(Addon.FramePoint.TOPLEFT, cooldownTypeRegion, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    spellRegion:SetSize(self.scrollContentFrame:GetWidth(), heightIncrement * 6)
    local spellHeader = Addon:getSectionHeader(spellRegion, "Spell Options", self.scrollContentFrame:GetWidth() - style.margin * 2)
    spellHeader:SetPoint(Addon.FramePoint.TOPLEFT, spellRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)
    local leftSpellRegion = CreateFrame("Frame", nil, spellRegion)
    leftSpellRegion:SetPoint(Addon.FramePoint.TOPLEFT, spellHeader, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    leftSpellRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 6 - spellHeader:GetHeight())
    local rightSpellRegion = CreateFrame("Frame", nil, spellRegion)
    rightSpellRegion:SetPoint(Addon.FramePoint.TOPLEFT, leftSpellRegion, Addon.FramePoint.TOPRIGHT, 0, 0)
    rightSpellRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 6 - spellHeader:GetHeight())
    local spellFrame, setSpellOption = Addon:createDropdown(leftSpellRegion, "Spell", nil, {
        width = 175,
        selectedValue = item.spellName
    })
    setSpellOption(
            Addon.inst.cdmItemCollection:getOptions(Addon.CdmType.SPELL),
            function(value, text)
                if item.boundCdmItem then
                    item.boundCdmItem:unbind()
                end
                if item.boundTrinket then
                    item.boundTrinket:unbind()
                end

                item:setSpell(value.cooldownId, value.spellId, Addon.ItemType.SPELL)
                itemBtn:setName(value.spellName)
                itemBtn:refreshIcon()
                local cdmItem = Addon.inst.cdmItemCollection:getCdmItem(value.spellId)
                if cdmItem.isActive == false then
                    spellWarningText:Show()
                else
                    spellWarningText:Hide()
                end
            end
    )
    spellFrame:SetPoint(Addon.FramePoint.TOPLEFT, leftSpellRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)
    spellWarningText:SetText("The selected spell has not been enabled in Blizzard's CDM. Due to API limitations, please move the spell to Essential Cooldowns, Utility Cooldowns, or Tracked Buffs in Blizzard's CDM to enable tracking in BaroCM. It is recommended to do this for all spells while using BaroCM.")
    spellWarningText:SetTextColor(1, 0.1, 0.1, 1)
    spellWarningText:SetWidth(spellRegion:GetWidth() - style.margin * 3)
    spellWarningText:SetJustifyH("LEFT")
    spellWarningText:SetPoint(Addon.FramePoint.TOPLEFT, spellFrame, Addon.FramePoint.BOTTOMLEFT, 0, style.negMargin)
    spellWarningText:Hide()
    spellRegion:Hide()

    auraRegion:SetPoint(Addon.FramePoint.TOPLEFT, cooldownTypeRegion, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    auraRegion:SetSize(self.scrollContentFrame:GetWidth(), heightIncrement * 6)
    local auraHeader = Addon:getSectionHeader(auraRegion, "Aura Options", self.scrollContentFrame:GetWidth() - style.margin * 2)
    auraHeader:SetPoint(Addon.FramePoint.TOPLEFT, auraRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)
    local leftAuraRegion = CreateFrame("Frame", nil, auraRegion)
    leftAuraRegion:SetPoint(Addon.FramePoint.TOPLEFT, auraHeader, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    leftAuraRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 6 - auraHeader:GetHeight())
    local rightAuraRegion = CreateFrame("Frame", nil, auraRegion)
    rightAuraRegion:SetPoint(Addon.FramePoint.TOPLEFT, leftAuraRegion, Addon.FramePoint.TOPRIGHT, 0, 0)
    rightAuraRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 6 - auraHeader:GetHeight())
    local auraFrame, setAuraOption = Addon:createDropdown(leftAuraRegion, "Spell", nil, {
        width = 175,
        selectedValue = item.spellName
    })
    setAuraOption(
            Addon.inst.cdmItemCollection:getOptions(Addon.CdmType.AURA),
            function(value, text)
                if item.boundCdmItem then
                    item.boundCdmItem:unbind()
                end
                if item.boundTrinket then
                    item.boundTrinket:unbind()
                end

                item:setSpell(value.cooldownId, value.spellId, Addon.ItemType.AURA)
                itemBtn:setName(value.spellName)
                itemBtn:refreshIcon()
                local cdmItem = Addon.inst.cdmItemCollection:getCdmItem(value.spellId)
                if cdmItem.isActive == false then
                    spellWarningText:Show()
                else
                    spellWarningText:Hide()
                end
            end
    )
    auraFrame:SetPoint(Addon.FramePoint.TOPLEFT, leftAuraRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)
    auraWarningText:SetText("The selected spell has not been enabled in Blizzard's CDM. Due to API limitations, please move the spell to Essential Cooldowns, Utility Cooldowns, or Tracked Buffs in Blizzard's CDM to enable tracking in BaroCM. It is recommended to do this for all spells while using BaroCM.")
    auraWarningText:SetTextColor(1, 0.1, 0.1, 1)
    auraWarningText:SetWidth(auraRegion:GetWidth() - style.margin * 3)
    auraWarningText:SetJustifyH("LEFT")
    auraWarningText:SetPoint(Addon.FramePoint.TOPLEFT, auraFrame, Addon.FramePoint.BOTTOMLEFT, 0, style.negMargin)
    auraWarningText:Hide()
    auraRegion:Hide()

    itemRegion:SetPoint(Addon.FramePoint.TOPLEFT, cooldownTypeRegion, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    itemRegion:SetSize(self.scrollContentFrame:GetWidth(), heightIncrement * 6)
    local itemHeader = Addon:getSectionHeader(itemRegion, "Item Options", self.scrollContentFrame:GetWidth() - style.margin * 2)
    itemHeader:SetPoint(Addon.FramePoint.TOPLEFT, itemRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)
    local leftItemRegion = CreateFrame("Frame", nil, itemRegion)
    leftItemRegion:SetPoint(Addon.FramePoint.TOPLEFT, itemHeader, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    leftItemRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 6 - itemHeader:GetHeight())
    local rightItemRegion = CreateFrame("Frame", nil, itemRegion)
    rightItemRegion:SetPoint(Addon.FramePoint.TOPLEFT, leftItemRegion, Addon.FramePoint.TOPRIGHT, 0, 0)
    rightItemRegion:SetSize(self.frame:GetWidth() / 2, heightIncrement * 6 - itemHeader:GetHeight())
    local itemFrame, setItemOption = Addon:createDropdown(leftItemRegion, "Spell", nil, {
        width = 175,
        selectedValue = item.spellName
    })
    setItemOption(
            Addon.inst.trinketCollection:getOptions(),
            function(value, text)
                if item.boundCdmItem then
                    item.boundCdmItem:unbind()
                end
                if item.boundTrinket then
                    item.boundTrinket:unbind()
                end

                item:setSlotId(value.slotId)
                itemBtn:setName(value.slotName)
                itemBtn:refreshIcon()
                spellWarningText:Hide()
                auraWarningText:Hide()
            end
    )
    itemFrame:SetPoint(Addon.FramePoint.TOPLEFT, leftItemRegion, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)
    itemRegion:Hide()

    if item.itemType == Addon.ItemType.SPELL then
        spellRegion:Show()
    elseif item.itemType == Addon.ItemType.AURA then
        auraRegion:Show()
    elseif item.itemType == Addon.ItemType.ITEM then
        itemRegion:Show()
    end
end

function PropertiesPanel:getItemTypeFrame()

end

function PropertiesPanel:clearScrollContent()
    local children = { self.scrollContentFrame:GetChildren() }
    for i = 1, #children do
        local frame = children[i]
        frame:Hide()
        frame:SetParent(nil)
        frame:ClearAllPoints()
    end
end

Addon.PropertiesPanel = PropertiesPanel
return PropertiesPanel