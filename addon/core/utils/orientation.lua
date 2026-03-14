---@type Addon
local Addon = select(2, ...)

---@alias OrientationValue
---| "VERTICAL"
---| "HORIZONTAL"

---@class Orientation
---@field VERTICAL OrientationValue
---@field HORIZONTAL OrientationValue
local Orientation = {
    VERTICAL = "VERTICAL",
    HORIZONTAL = "HORIZONTAL",
}

Addon.Orientation = Orientation
return Orientation