---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)
---@Type StyleVariables
local style = Addon.StyleVariables

---@class TitlePanel
---@field parentOptionsPanel OptionsPanel
---@field frame Frame
---@field frameWidth number
---@field frameHeight number
local TitlePanel = {}
TitlePanel.__index = TitlePanel

---@param parentOptionsPanel OptionsPanel
---@param frameWidth number
---@param frameHeight number
---@return TitlePanel
function TitlePanel.create(parentOptionsPanel, frameWidth, frameHeight)
    local self = setmetatable({}, TitlePanel)
    self.parentOptionsPanel = parentOptionsPanel

    self.frame = CreateFrame("Frame", nil, self.parentOptionsPanel.frame, "BackdropTemplate")
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight

    self:initializeFrame()

    return self
end

function TitlePanel:initializeFrame()
    self.frame:SetSize(self.frameWidth, self.frameHeight)

    local titleText = self.frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleText:SetPoint(Addon.FramePoint.BOTTOMLEFT, self.frame, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    titleText:SetText(addonName)
end

Addon.TitlePanel = TitlePanel
return TitlePanel