---@type Addon
local Addon = select(2, ...)

---@class NavigatorButton
---@field buttonFrame Frame
---@field buttonText table
---@field icon table
---@field iconBorder table
---@field level number
local NavigatorButton = {}
NavigatorButton.__index = NavigatorButton

---@return NavigatorButton
function NavigatorButton:create(frameWidth)
    local obj = setmetatable({}, self)

    local frameHeight = frameWidth / 5.5
    obj.buttonFrame = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
    obj.buttonFrame:Hide()
    obj.buttonFrame:SetSize(frameWidth, frameHeight)
    obj.buttonFrame:SetBackdrop({
        bgFile = Addon.Styling.button.texture1,
        edgeFile = Addon.Styling.button.borderTexture1,
        edgeSize = 1,
        insets = { left = 0, right = -1, top = 0, bottom = 0 },
    })
    obj.buttonFrame:SetBackdropColor(unpack(Addon.Styling.button.color1))
    obj.buttonFrame:SetBackdropBorderColor(unpack(Addon.Styling.button.borderColor1))

    obj.buttonFrame:SetHighlightTexture("Interface/Buttons/WHITE8X8")
    obj.buttonFrame:GetHighlightTexture():SetVertexColor(0.25, 0.55, 0.9, 0.2)

    obj.buttonFrame:SetPushedTexture("Interface/Buttons/WHITE8X8")
    obj.buttonFrame:GetPushedTexture():SetVertexColor(0.25, 0.55, 0.9, 0.4)

    local iconSize = frameHeight * 0.7
    local iconMargin = (frameHeight - iconSize) / 2
    obj.icon = obj.buttonFrame:CreateTexture(nil, "ARTWORK")
    obj.icon:SetSize(iconSize, iconSize)
    obj.icon:SetPoint(Addon.FramePoint.LEFT, obj.buttonFrame, Addon.FramePoint.LEFT, iconMargin, 0)
    obj.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    obj.icon:SetTexture(Addon.Styling.button.defaultIconTexture)

    obj.iconBorder = CreateFrame("Frame", nil, obj.buttonFrame, "BackdropTemplate")
    obj.iconBorder:SetSize(iconSize + 2, iconSize + 2)
    obj.iconBorder:SetPoint(Addon.FramePoint.CENTER, obj.icon, Addon.FramePoint.CENTER, 0, 0)
    obj.iconBorder:SetBackdrop({ edgeFile = Addon.Styling.button.borderTexture1, edgeSize = 1 })
    obj.iconBorder:SetBackdropBorderColor(unpack(Addon.Styling.button.borderColor1))
    obj.iconBorder:SetBackdropColor(0, 0, 0, 0)
    obj.iconBorder:SetFrameLevel(obj.buttonFrame:GetFrameLevel() + 1)

    obj.buttonText = obj.buttonFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    obj.buttonText:SetFont(STANDARD_TEXT_FONT, math.floor(frameHeight * 0.22), "")
    obj.buttonText:SetPoint(Addon.FramePoint.LEFT, obj.iconBorder, Addon.FramePoint.RIGHT, iconMargin, 0)
    obj.buttonText:SetText("New Button")

    obj.buttonFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    obj.buttonFrame:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            obj:handleRightClick()
        elseif button == "LeftButton" then
            local key = obj:getSelectionKey()
            Addon.EventBus:send("NAVIGATOR_BUTTON_SELECTED", key)
            obj:handleLeftClick()
        end
    end)

    obj.level = 0
    obj.isSelected = false

    return obj
end

function NavigatorButton:handleLeftClick()

end

function NavigatorButton:handleRightClick()

end

---@param buttonText string
function NavigatorButton:setButtonText(buttonText)
    if #buttonText > 25 then
        buttonText = string.sub(buttonText, 1, 22) .. "..."
    end

    self.buttonText:SetText(buttonText)
end

---@param texture string
function NavigatorButton:setButtonIcon(texture)
    self.icon:SetTexture(texture)
end

function NavigatorButton:delete()
    if self.buttonFrame then
        self.buttonFrame:Hide()
        self.buttonFrame:SetScript("OnClick", nil)
        self.buttonFrame:SetParent(nil)
    end
    self.buttonFrame = nil
    self.icon = nil
    self.iconBorder = nil
    self.buttonText = nil
    self.level = nil
    self.isSelected = nil
end

---@param level number
function NavigatorButton:setLevel(level)
    self.level = level
end

function NavigatorButton:setSelected(selected)
    self.isSelected = selected == true

    if self.isSelected then
        self.buttonFrame:SetBackdropColor(0.18, 0.45, 0.75, 0.35)
        self.buttonFrame:SetBackdropBorderColor(0.35, 0.7, 1.0, 1.0)
    else
        self.buttonFrame:SetBackdropColor(unpack(Addon.Styling.button.color1))
        self.buttonFrame:SetBackdropBorderColor(unpack(Addon.Styling.button.borderColor1))
    end
end

function NavigatorButton:getSelectionKey()
    if self.node and self.node.id then
        return self.node.id
    end
    return nil
end

Addon.NavigatorButton = NavigatorButton
return NavigatorButton