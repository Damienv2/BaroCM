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

function FramePoint:getOptions()
    local options = {}
    for key, value in pairs(Addon.FramePoint) do
        if type(value) == "string" then
            table.insert(options, { value = value, text = key })
        end
    end

    -- Sort alphabetically if desired
    table.sort(options, function(a, b) return a.text < b.text end)

    return options
end

Addon.FramePoint = FramePoint
return FramePoint