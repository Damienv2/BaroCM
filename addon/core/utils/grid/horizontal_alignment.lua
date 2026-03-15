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

function HorizontalAlignment:getOptions()
    local options = {}
    for key, value in pairs(HorizontalAlignment) do
        if type(value) == "string" then
            table.insert(options, { value = value, text = key })
        end
    end

    -- Sort alphabetically if desired
    table.sort(options, function(a, b) return a.text < b.text end)

    return options
end

Addon.HorizontalAlignment = HorizontalAlignment
return HorizontalAlignment