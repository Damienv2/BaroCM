---@type Addon
local Addon = select(2, ...)

---@class ProgressBarFrame
---@field id string
---@field parentProgressBarCollection ProgressBarCollection
local ProgressBarFrame = {}
ProgressBarFrame.__index = ProgressBarFrame

---@param parentProgressBar ProgressBar
---@return ProgressBarFrame
function ProgressBarFrame.hidden(parentProgressBar)
    local self = setmetatable({}, ProgressBarFrame)
    self.id = parentProgressBar.id
    self.parentProgressBar = parentProgressBar

    local c = {0.2, 0.65, 1.0, 1.0}

    self.container = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    self.container:SetSize(parentProgressBar.size.width, parentProgressBar.size.height)
    self.container:SetBackdrop({
        bgFile = "Interface/Buttons/WHITE8X8",
        edgeFile = "Interface/Buttons/WHITE8X8",
        edgeSize = 1,
    })
    self.container:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    self.container:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    self.container:SetPoint(Addon.FramePoint.CENTER, UIParent, Addon.FramePoint.CENTER, 0, 0)

    self.bar = CreateFrame("StatusBar", nil, self.container)
    self.bar:SetPoint(Addon.FramePoint.TOPLEFT, self.container, Addon.FramePoint.TOPLEFT, 1, -1)
    self.bar:SetPoint(Addon.FramePoint.BOTTOMRIGHT, self.container, Addon.FramePoint.BOTTOMRIGHT, -1, 1)
    self.bar:SetStatusBarTexture("Interface/Buttons/WHITE8X8")
    self.bar:SetStatusBarColor(c[1], c[2], c[3], c[4] or 1)
    self.bar:SetMinMaxValues(0, 1)
    self.bar:SetValue(0)

    self.text = self.container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.text:SetPoint("CENTER", self.container, "CENTER", 0, 0)

    return self
end

function ProgressBarFrame:setProgress(value, maxValue)
    self.bar:SetMinMaxValues(0, maxValue)
    self.bar:SetValue(value)
end

function ProgressBarFrame:setText(text)
    self.text:SetText(text)
end

function ProgressBarFrame:show()
    self.container:Show()
end

function ProgressBarFrame:hide()
    self.container:Hide()
end

function ProgressBarFrame:delete()
    self:hide()
end

function ProgressBarFrame:setColorFill(fill)
    self.bar:SetStatusBarColor(fill[1], fill[2], fill[3], fill[4] or 1)
end

Addon.ProgressBarFrame = ProgressBarFrame
return ProgressBarFrame