---@type Addon
local Addon = select(2, ...)

---@class StyleVariables
local StyleVariables = {
    backgroundColor = { 0.05, 0.05, 0.05, 0.96 },
    borderColor = { 0.3, 0.3, 0.3, 1 },
    highlightBorderColor = { 1, 0.85, 0.2, 1 },
    margin = 20,
    negMargin = -20,
    optionsPanel = {
        backgroundFile = "Interface/Tooltips/UI-Tooltip-Background",
        borderFile = "Interface/Tooltips/UI-Tooltip-Border",
    },
    innerPanel = {
        backgroundFile = "Interface/Buttons/WHITE8X8",
        borderFile = "Interface/Buttons/WHITE8X8",
    }
}

Addon.StyleVariables = StyleVariables
return StyleVariables