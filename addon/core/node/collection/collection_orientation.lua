---@type Addon
local Addon = select(2, ...)

---@alias CollectionOrientationValue
---| "VERTICAL"
---| "HORIZONTAL"

---@class CollectionOrientation
---@field VERTICAL CollectionOrientationValue
---@field HORIZONTAL CollectionOrientationValue
local CollectionOrientation = {
    VERTICAL = "VERTICAL",
    HORIZONTAL = "HORIZONTAL",
}

Addon.CollectionOrientation = CollectionOrientation
return CollectionOrientation