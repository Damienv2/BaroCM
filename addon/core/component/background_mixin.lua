---@type Addon
local Addon = select(2, ...)

---@class BackgroundMixin
---@field parent Node
---@field showBackground boolean
---@field bgFrame Frame
local BackgroundMixin = {}

---@param parent Node
function BackgroundMixin:init(parent)
    self.parent = parent
    self.showBackground = true
    self.bgFrame = self:_initBgFrame()
end

function BackgroundMixin:serializeBackgroundProps()
    return {
        showBackground = self.showBackground,
    }
end

---@param data table
function BackgroundMixin:deserializeBackgroundProps(data)
    self.showBackground = data.background.showBackground
    self:refreshFrameVisibility()
end

---@param showBackground boolean
function BackgroundMixin:setShowBackground(showBackground)
    if self.showBackground == showBackground then return end

    if showBackground == true then
        self.bgFrame:Show()
    else
        self.bgFrame:Hide()
    end
    self.showBackground = showBackground

    Addon.EventBus:send("SAVE")
end

---@return Frame
function BackgroundMixin:_initBgFrame()
    local bgFrame = CreateFrame("Frame", nil, self.parent.frame)
    bgFrame:SetAllPoints()

    bgFrame.bg = bgFrame:CreateTexture(nil, "BACKGROUND")
    bgFrame.bg:ClearAllPoints()
    bgFrame.bg:SetPoint(Addon.FramePoint.TOPLEFT, self.parent.frame, Addon.FramePoint.TOPLEFT, 0, 0)
    bgFrame.bg:SetPoint(Addon.FramePoint.BOTTOMRIGHT, self.parent.frame, Addon.FramePoint.BOTTOMRIGHT, 0, 0)
    bgFrame.bg:SetColorTexture(0, 0, 0, 0.35)

    if not self.showBackground then
        bgFrame:Hide()
    end

    bgFrame:SetFrameStrata("BACKGROUND")
    bgFrame:SetFrameLevel(0)

    return bgFrame
end

function BackgroundMixin:refreshFrameVisibility()
    if not self.showBackground then
        self.bgFrame:Hide()
    else
        self.bgFrame:Show()
    end
end

Addon.BackgroundMixin = BackgroundMixin
return BackgroundMixin
