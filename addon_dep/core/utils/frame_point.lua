---@type Addon
local Addon = select(2, ...)

---@alias FramePointValue
---| "TOPLEFT"
---| "TOP"
---| "TOPRIGHT"
---| "LEFT"
---| "CENTER"
---| "RIGHT"
---| "BOTTOMLEFT"
---| "BOTTOM"
---| "BOTTOMRIGHT"

---@class FramePoint
---@field TOPLEFT FramePointValue
---@field TOP FramePointValue
---@field TOPRIGHT FramePointValue
---@field LEFT FramePointValue
---@field CENTER FramePointValue
---@field RIGHT FramePointValue
---@field BOTTOMLEFT FramePointValue
---@field BOTTOM FramePointValue
---@field BOTTOMRIGHT FramePointValue
local FramePoint = {
    TOPLEFT = "TOPLEFT",
    TOP = "TOP",
    TOPRIGHT = "TOPRIGHT",
    LEFT = "LEFT",
    CENTER = "CENTER",
    RIGHT = "RIGHT",
    BOTTOMLEFT = "BOTTOMLEFT",
    BOTTOM = "BOTTOM",
    BOTTOMRIGHT = "BOTTOMRIGHT",
}

Addon.FramePoint = FramePoint
return FramePoint