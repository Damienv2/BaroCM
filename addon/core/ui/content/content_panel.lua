---@type Addon
local Addon = select(2, ...)

---@class ContentPanel
---@field margin number
---@field frame Frame
---@field marginFrame Frame
local ContentPanel = {}
ContentPanel.__index = ContentPanel

---@return ContentPanel
function ContentPanel:create()
    local obj = setmetatable({}, self)

    obj.margin = Addon.Styling.margin

    obj.frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    obj.frame:Hide()
    obj.frame:SetBackdrop({
        bgFile = Addon.Styling.background.texture2,
        edgeFile = Addon.Styling.background.borderTexture2,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    obj.frame:SetBackdropColor(unpack(Addon.Styling.background.color1))
    obj.frame:SetBackdropBorderColor(unpack(Addon.Styling.background.borderColor1))

    obj.marginFrame = CreateFrame("Frame", nil, obj.frame)
    obj.marginFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.frame, Addon.FramePoint.TOPLEFT, obj.margin, -obj.margin)
    obj.marginFrame:SetPoint(Addon.FramePoint.BOTTOMRIGHT, obj.frame, Addon.FramePoint.BOTTOMRIGHT, -obj.margin, obj.margin)
    obj.marginFrame:Show()

    return obj
end

function ContentPanel:delete()
    self.marginFrame:Hide()
    self.marginFrame:SetParent(nil)
    self.marginFrame = nil
    self.frame:Hide()
    self.frame:SetParent(nil)
    self.frame = nil
end

Addon.ContentPanel = ContentPanel
return ContentPanel