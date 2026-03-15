---@type Addon
local Addon = select(2, ...)

---@class Background
---@field color1 table
---@field color2 table
---@field borderColor1 string
---@field texture1 string
---@field texture2 string
---@field borderTexture1 string
---@field borderTexture2 string

---@class Styling
---@field margin number
---@field background Background
local Styling = {}

Styling.margin = 20

Styling.background = {}
Styling.background.color1 = { 0.05, 0.05, 0.05, 1 }
Styling.background.color2 = { 0.1, 0.1, 0.1, 1 }
Styling.background.borderColor1 = { 0.3, 0.3, 0.3, 1 }
Styling.background.texture1 = "Interface/Tooltips/UI-Tooltip-Background"
Styling.background.texture2 = "Interface/Buttons/WHITE8X8"
Styling.background.borderTexture1 = "Interface/Tooltips/UI-Tooltip-Border"
Styling.background.borderTexture2 = "Interface/Buttons/WHITE8X8"

Styling.button = {}
Styling.button.color1 = {0.1, 0.1, 0.1, 1}
Styling.button.borderColor1 = {0.3, 0.3, 0.3, 1}
Styling.button.texture1 = "Interface/Buttons/WHITE8X8"
Styling.button.borderTexture1 = "Interface/Buttons/WHITE8X8"
Styling.button.defaultIconTexture = "Interface/Icons/INV_Misc_QuestionMark"

---@param barHeight number
function Styling:getCooldownFontSize(iconWidth)
    local baseSize = 48
    local baseFontSize = 10

    return (iconWidth / baseSize) * baseFontSize
end

---@param barHeight number
function Styling:getChargesFontSize(iconWidth)
    local baseSize = 48
    local baseFontSize = 10

    return (iconWidth / baseSize) * baseFontSize
end

---@param barHeight number
function Styling:getProgBarFontSize(barHeight)
    local baseHeight = 30
    local baseFontSize = 16

    return (barHeight / baseHeight) * baseFontSize
end

Addon.Styling = Styling
return Styling