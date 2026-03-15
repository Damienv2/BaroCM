---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)

---@class SettingsPanel
---@field backdropFrame Frame
---@field contentFrame Frame
---@field titleFrame Frame
---@field bodyFrame Frame
---@field navigatorPanel NavigatorPanel
---@field parametersPanel ParametersPanel
local SettingsPanel = {}
SettingsPanel.__index = SettingsPanel

---@return SettingsPanel
function SettingsPanel:default()
    local obj = setmetatable({}, self)

    local margin = Addon.Styling.margin

    local backdropFrameWidth = 1024
    local backdropFrameHeight = 768
    obj.backdropFrame = CreateFrame("Frame", addonName .. "SettingsPanel", UIParent, "BackdropTemplate")
    obj.backdropFrame:Hide()
    obj.backdropFrame:SetPoint(Addon.FramePoint.CENTER, UIParent, Addon.FramePoint.CENTER, 0, 0)
    obj.backdropFrame:SetSize(backdropFrameWidth, backdropFrameHeight)
    obj.backdropFrame:SetFrameStrata("HIGH")
    obj.backdropFrame:SetMovable(true)
    obj.backdropFrame:EnableMouse(true)
    obj.backdropFrame:RegisterForDrag("LeftButton")
    obj.backdropFrame:SetScript("OnDragStart", obj.backdropFrame.StartMoving)
    obj.backdropFrame:SetScript("OnDragStop", obj.backdropFrame.StopMovingOrSizing)
    obj.backdropFrame:SetBackdrop({
        bgFile = Addon.Styling.background.texture1,
        edgeFile = Addon.Styling.background.borderTexture1,
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    obj.backdropFrame:SetBackdropColor(unpack(Addon.Styling.background.color1))
    tinsert(UISpecialFrames, obj.backdropFrame:GetName())

    local closeBtn = CreateFrame("Button", nil, obj.backdropFrame, "UIPanelCloseButton")
    closeBtn:SetPoint(Addon.FramePoint.TOPRIGHT, -5, -5)

    local contentFrameWidth = backdropFrameWidth - margin * 2
    local contentFrameHeight = backdropFrameHeight - margin * 2
    obj.contentFrame = CreateFrame("Frame", nil, obj.backdropFrame)
    obj.contentFrame:SetPoint(Addon.FramePoint.CENTER, obj.backdropFrame, Addon.FramePoint.CENTER, 0, 0)
    obj.contentFrame:SetSize(contentFrameWidth, contentFrameHeight)

    local titleFrameHeight = 60
    obj.titleFrame = CreateFrame("Frame", nil, obj.contentFrame)
    obj.titleFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.contentFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.titleFrame:SetSize(contentFrameWidth,  titleFrameHeight)
    obj.titleFrame.txt = obj.titleFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    obj.titleFrame.txt:SetPoint(Addon.FramePoint.BOTTOMLEFT, obj.titleFrame, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    obj.titleFrame.txt:SetText(addonName)

    local bodyFrameHeight = contentFrameHeight - titleFrameHeight - margin
    obj.bodyFrame = CreateFrame("Frame", nil, obj.contentFrame)
    obj.bodyFrame:SetPoint(Addon.FramePoint.TOPLEFT,  obj.titleFrame, Addon.FramePoint.BOTTOMLEFT, 0, margin * -1)
    obj.bodyFrame:SetSize(contentFrameWidth, bodyFrameHeight)

    local navigatorPanelWidth = 350
    obj.navigatorPanel = Addon.NavigatorPanel:create(navigatorPanelWidth, bodyFrameHeight)
    obj.navigatorPanel.frame:SetParent(obj.bodyFrame)
    obj.navigatorPanel.frame:ClearAllPoints()
    obj.navigatorPanel.frame:SetPoint(Addon.FramePoint.TOPLEFT, obj.bodyFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.navigatorPanel.frame:Show()

    local contentPanelWidth = contentFrameWidth - navigatorPanelWidth - margin
    obj.contentPanel = Addon.ContentPanel:create(contentPanelWidth, nil)
    obj.contentPanel.frame:SetParent(obj.bodyFrame)
    obj.contentPanel.frame:ClearAllPoints()
    obj.contentPanel.frame:SetPoint(Addon.FramePoint.TOPLEFT, obj.navigatorPanel.frame, Addon.FramePoint.TOPRIGHT, margin, 0)
    obj.contentPanel.frame:SetSize(contentPanelWidth, bodyFrameHeight)
    obj.contentPanel.frame:Show()

    Addon.EventBus:register("NEW_COLLECTION_MEMBER_BUTTON_CLICKED", function(parent)
        if obj.contentPanel ~= nil then
            obj.contentPanel:delete()
            obj.contentPanel = nil
        end

        local newCollectionMemberPanel = Addon.NewCollectionMemberPanel:create(contentPanelWidth, parent)
        obj.contentPanel = newCollectionMemberPanel
        obj.contentPanel.frame:SetParent(obj.bodyFrame)
        obj.contentPanel.frame:ClearAllPoints()
        obj.contentPanel.frame:SetPoint(Addon.FramePoint.TOPLEFT, obj.navigatorPanel.frame, Addon.FramePoint.TOPRIGHT, margin, 0)
        obj.contentPanel.frame:SetSize(contentPanelWidth, bodyFrameHeight)
        obj.contentPanel.frame:Show()
    end)
    Addon.EventBus:register("NEW_GROUP_MEMBER_BUTTON_CLICKED", function(parent)
        if obj.contentPanel ~= nil then
            obj.contentPanel:delete()
            obj.contentPanel = nil
        end

        local newGroupMemberPanel = Addon.NewGroupMemberPanel:create(contentPanelWidth, parent)
        obj.contentPanel = newGroupMemberPanel
        obj.contentPanel.frame:SetParent(obj.bodyFrame)
        obj.contentPanel.frame:ClearAllPoints()
        obj.contentPanel.frame:SetPoint(Addon.FramePoint.TOPLEFT, obj.navigatorPanel.frame, Addon.FramePoint.TOPRIGHT, margin, 0)
        obj.contentPanel.frame:SetSize(contentPanelWidth, bodyFrameHeight)
        obj.contentPanel.frame:Show()
    end)
    Addon.EventBus:register("GROUP_BUTTON_CLICKED", function(group)
        if obj.contentPanel ~= nil then
            obj.contentPanel:delete()
            obj.contentPanel = nil
        end

        local groupPanel = Addon.GroupPanel:create(group)
        obj.contentPanel = groupPanel
        obj.contentPanel.frame:SetParent(obj.bodyFrame)
        obj.contentPanel.frame:ClearAllPoints()
        obj.contentPanel.frame:SetPoint(Addon.FramePoint.TOPLEFT, obj.navigatorPanel.frame, Addon.FramePoint.TOPRIGHT, margin, 0)
        obj.contentPanel.frame:SetSize(contentPanelWidth, bodyFrameHeight)
        obj.contentPanel.frame:Show()
    end)
    Addon.EventBus:register("COOLDOWN_BUTTON_CLICKED", function(cooldown, cooldownButton)
        if obj.contentPanel ~= nil then
            obj.contentPanel:delete()
            obj.contentPanel = nil
        end

        local cooldownPanel = Addon.CooldownPanel:create(cooldown, cooldownButton)
        obj.contentPanel = cooldownPanel
        obj.contentPanel.frame:SetParent(obj.bodyFrame)
        obj.contentPanel.frame:ClearAllPoints()
        obj.contentPanel.frame:SetPoint(Addon.FramePoint.TOPLEFT, obj.navigatorPanel.frame, Addon.FramePoint.TOPRIGHT, margin, 0)
        obj.contentPanel.frame:SetSize(contentPanelWidth, bodyFrameHeight)
        obj.contentPanel.frame:Show()
    end)
    Addon.EventBus:register("EQUIPMENT_BUTTON_CLICKED", function(equipment, equipmentButton)
        if obj.contentPanel ~= nil then
            obj.contentPanel:delete()
            obj.contentPanel = nil
        end

        local equipmentPanel = Addon.EquipmentPanel:create(equipment, equipmentButton)
        obj.contentPanel = equipmentPanel
        obj.contentPanel.frame:SetParent(obj.bodyFrame)
        obj.contentPanel.frame:ClearAllPoints()
        obj.contentPanel.frame:SetPoint(Addon.FramePoint.TOPLEFT, obj.navigatorPanel.frame, Addon.FramePoint.TOPRIGHT, margin, 0)
        obj.contentPanel.frame:SetSize(contentPanelWidth, bodyFrameHeight)
        obj.contentPanel.frame:Show()
    end)
    Addon.EventBus:register("CONSUMABLE_BUTTON_CLICKED", function(equipment, equipmentButton)
        if obj.contentPanel ~= nil then
            obj.contentPanel:delete()
            obj.contentPanel = nil
        end

        local consumablePanel = Addon.ConsumablePanel:create(equipment, equipmentButton)
        obj.contentPanel = consumablePanel
        obj.contentPanel.frame:SetParent(obj.bodyFrame)
        obj.contentPanel.frame:ClearAllPoints()
        obj.contentPanel.frame:SetPoint(Addon.FramePoint.TOPLEFT, obj.navigatorPanel.frame, Addon.FramePoint.TOPRIGHT, margin, 0)
        obj.contentPanel.frame:SetSize(contentPanelWidth, bodyFrameHeight)
        obj.contentPanel.frame:Show()
    end)
    Addon.EventBus:register("POWER_BAR_BUTTON_CLICKED", function(progBar, progBarButton)
        if obj.contentPanel ~= nil then
            obj.contentPanel:delete()
            obj.contentPanel = nil
        end

        local progBarPanel = Addon.PowerBarPanel:create(progBar, progBarButton)
        obj.contentPanel = progBarPanel
        obj.contentPanel.frame:SetParent(obj.bodyFrame)
        obj.contentPanel.frame:ClearAllPoints()
        obj.contentPanel.frame:SetPoint(Addon.FramePoint.TOPLEFT, obj.navigatorPanel.frame, Addon.FramePoint.TOPRIGHT, margin, 0)
        obj.contentPanel.frame:SetSize(contentPanelWidth, bodyFrameHeight)
        obj.contentPanel.frame:Show()
    end)

    return obj
end

function SettingsPanel:toggleSettings()
    if self.backdropFrame:IsShown() then
        self.backdropFrame:Hide()
    else
        self.backdropFrame:Show()
    end
end

Addon.SettingsPanel = SettingsPanel
return SettingsPanel