---@type Addon
local Addon = select(2, ...)

---@alias VerticalAlignmentValue
---| "TOP"
---| "CENTER"
---| "BOTTOM"

---@class VerticalAlignment
---@field TOP VerticalAlignmentValue
---@field CENTER VerticalAlignmentValue
---@field BOTTOM VerticalAlignmentValue
local VerticalAlignment = {
    TOP = "TOP",
    CENTER = "CENTER",
    BOTTOM = "BOTTOM",
}

Addon.VerticalAlignment = VerticalAlignment
return VerticalAlignment