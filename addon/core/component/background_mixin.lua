---@type Addon
local Addon = select(2, ...)

---@class BackgroundMixin
---@field showBackground boolean
---@field bgFrame Frame
local BackgroundMixin = {}

function BackgroundMixin:initBackground()
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
    self.showBackground = data.showBackground
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
end

---@return Frame
function BackgroundMixin:_initBgFrame()
    local bgFrame = CreateFrame(self.id .. "_bgFrame", nil, self.frame)

    bgFrame.bg = bgFrame:CreateTexture(nil, "BACKGROUND")
    bgFrame.bg:SetAllPoints()
    bgFrame.bg:SetColorTexture(0, 0, 0, 0.35)

    if not self.showBackground then
        bgFrame:Hide()
    end

    bgFrame.bg:SetFrameStrata("BACKGROUND")
    bgFrame.bg:SetFrameLevel(0)

    return bgFrame
end

Addon.BackgroundMixin = BackgroundMixin
return BackgroundMixin
