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

Addon.GrowthPrio = GrowthPrio
return GrowthPrio