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

function VerticalAlignment:getOptions()
    local options = {}
    for key, value in pairs(VerticalAlignment) do
        if type(value) == "string" then
            table.insert(options, { value = value, text = key })
        end
    end

    -- Sort alphabetically if desired
    table.sort(options, function(a, b) return a.text < b.text end)

    return options
end

Addon.VerticalAlignment = VerticalAlignment
return VerticalAlignment