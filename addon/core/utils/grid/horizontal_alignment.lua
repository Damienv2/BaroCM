---@type Addon
local Addon = select(2, ...)

---@alias HorizontalAlignmentValue
---| "LEFT"
---| "CENTER"
---| "RIGHT"

---@class HorizontalAlignment
---@field LEFT HorizontalAlignmentValue
---@field CENTER HorizontalAlignmentValue
---@field RIGHT HorizontalAlignmentValue
local HorizontalAlignment = {
    LEFT = "LEFT",
    CENTER = "CENTER",
    RIGHT = "RIGHT",
}

Addon.HorizontalAlignment = HorizontalAlignment
return HorizontalAlignment