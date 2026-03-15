---@type Addon
local Addon = select(2, ...)

---@class Utils
local Utils = {}

---@param table1 table
---@param table2 table
---@return table
function Utils:mergeTable(table1, table2)
    local outTable = {}
    for key, value in pairs(table1) do
        outTable[key] = value
    end

    for key, value in pairs(table2) do
        outTable[key] = value
    end

    return outTable
end

---@param tbl table
---@param objectToDelete any
---@return boolean
function Utils:deleteFromTable(tbl, objectToDelete)
    for index, child in ipairs(tbl) do
        if child == objectToDelete then
            tbl.remove(tbl, index)

            return true
        end
    end

    return false
end

Addon.Utils = Utils
return Utils