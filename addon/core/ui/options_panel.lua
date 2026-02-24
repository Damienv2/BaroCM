---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)
---@Type StyleVariables
local style = Addon.StyleVariables

---@class OptionsPanel
---@field frame Frame
---@field frameWidth number
---@field frameHeight number
---@field titlePanel TitlePanel
---@field propertiesPanel PropertiesPanel
---@field navigatorPanel NavigatorPanel
local OptionsPanel = {}
OptionsPanel.__index = OptionsPanel

---@return OptionsPanel
function OptionsPanel.default()
    local self = setmetatable({}, OptionsPanel)
    self.frame = CreateFrame("Frame", addonName .. "OptionsPanel", UIParent, "BackdropTemplate")
    self.frameWidth = 1024
    self.frameHeight = 768

    local titleFrameWidth = self.frameWidth - style.margin * 2
    local titleFrameHeight = math.floor(self.frameHeight * 0.06)
    self.titlePanel = Addon.TitlePanel.create(self, titleFrameWidth, titleFrameHeight)

    local navigatorFrameWidth = math.floor((self.frameWidth - style.margin * 3) * 0.3)
    local navigatorFrameHeight = self.frameHeight - titleFrameHeight - style.margin * 3
    self.navigatorPanel = Addon.NavigatorPanel.create(self, navigatorFrameWidth, navigatorFrameHeight)

    local propertiesFrameWidth = math.ceil((self.frameWidth - style.margin * 3) * 0.7)
    local propertiesFrameHeight = navigatorFrameHeight
    self.propertiesPanel = Addon.PropertiesPanel.create(self, propertiesFrameWidth, propertiesFrameHeight)

    self:initializeFrame()

    return self
end

function OptionsPanel:initializeFrame()
    tinsert(UISpecialFrames, self.frame:GetName())
    self.frame:SetSize(self.frameWidth, self.frameHeight)
    self.frame:SetPoint(Addon.FramePoint.CENTER)
    self.frame:SetFrameStrata("HIGH")
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", self.frame.StartMoving)
    self.frame:SetScript("OnDragStop", self.frame.StopMovingOrSizing)
    self.frame:Hide()

    self.frame:SetBackdrop({
        bgFile = style.optionsPanel.backgroundFile,
        edgeFile = style.optionsPanel.borderFile,
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    self.frame:SetBackdropColor(unpack(style.backgroundColor))

    local closeBtn = CreateFrame("Button", nil, self.frame, "UIPanelCloseButton")
    closeBtn:SetPoint(Addon.FramePoint.TOPRIGHT, -5, -5)

    self.titlePanel.frame:SetPoint(Addon.FramePoint.TOPLEFT, self.frame, Addon.FramePoint.TOPLEFT, style.margin, style.negMargin)
    --Addon.Utils:addDebugFrame(self.titlePanel.frame, 1, 0, 0)

    self.navigatorPanel.frame:SetPoint(Addon.FramePoint.TOPLEFT, self.titlePanel.frame, Addon.FramePoint.BOTTOMLEFT, 0, style.negMargin)
    --Addon.Utils:addDebugFrame(self.navigatorPanel.frame, 0, 1, 0)

    self.propertiesPanel.frame:SetPoint(Addon.FramePoint.TOPLEFT, self.navigatorPanel.frame, Addon.FramePoint.TOPRIGHT, style.margin, 0)
    --Addon.Utils:addDebugFrame(self.propertiesPanel.frame, 0, 0, 1)
end

function OptionsPanel:show()
    self.frame:Show()
end

function OptionsPanel:hide()
    self.frame:Hide()
end

function OptionsPanel:toggleOptionsPanel()
    if self.frame:IsShown() then
        self:hide()
    else
        self:show()
    end
end

Addon.OptionsPanel = OptionsPanel
return OptionsPanel