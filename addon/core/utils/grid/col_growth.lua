---@type Addon
local Addon = select(2, ...)

---@alias ColGrowthValue
---| "UP"
---| "CENTER"
---| "DOWN"

---@class ColGrowth
---@field UP ColGrowthValue
---@field CENTER ColGrowthValue
---@field DOWN ColGrowthValue
local ColGrowth = {
    UP = "UP",
    CENTER = "CENTER",
    DOWN = "DOWN",
}

Addon.ColGrowth = ColGrowth
return ColGrowth