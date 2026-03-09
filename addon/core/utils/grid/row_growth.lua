---@type Addon
local Addon = select(2, ...)

---@alias RowGrowthValue
---| "LEFT"
---| "CENTER"
---| "RIGHT"

---@class RowGrowth
---@field LEFT RowGrowthValue
---@field CENTER RowGrowthValue
---@field RIGHT RowGrowthValue
local RowGrowth = {
    LEFT = "LEFT",
    CENTER = "CENTER",
    RIGHT = "RIGHT",
}

Addon.RowGrowth = RowGrowth
return RowGrowth