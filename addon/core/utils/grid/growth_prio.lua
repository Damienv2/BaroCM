---@type Addon
local Addon = select(2, ...)

---@alias GrowthPrioValue
---| "ROW_FIRST"
---| "COL_FIRST"

---@class GrowthPrio
---@field ROW_FIRST GrowthPrioValue
---@field COL_FIRST GrowthPrioValue
local GrowthPrio = {
    ROW_FIRST = "ROW_FIRST",
    COL_FIRST = "COL_FIRST",
}

function GrowthPrio:getOptions()
    local options = {}
    for key, value in pairs(GrowthPrio) do
        if type(value) == "string" then
            table.insert(options, { value = value, text = key })
        end
    end

    -- Sort alphabetically if desired
    table.sort(options, function(a, b) return a.text < b.text end)

    return options
end

Addon.GrowthPrio = GrowthPrio
return GrowthPrio