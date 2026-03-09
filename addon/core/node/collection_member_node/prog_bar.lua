---@type Addon
local Addon = select(2, ...)

---@class ProgBar : CollectionMemberNode
---@field items table
ProgBar = setmetatable({}, { __index = Addon.CollectionMemberNode }) -- inherit from Node
ProgBar.__index = ProgBar
ProgBar.type = Addon.NodeType.PROG_BAR

---@param parent Node?
---@param rank number?
---@return ProgBar
function ProgBar:new(parent, rank)
    ---@type ProgBar
    local obj = Addon.CollectionMemberNode.new(self, parent, rank) -- parent constructor
    obj.name = "New ProgBar"

    return obj
end

Addon.ProgBar = ProgBar
return ProgBar