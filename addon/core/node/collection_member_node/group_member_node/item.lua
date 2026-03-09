---@type Addon
local Addon = select(2, ...)

---@class Item : GroupMemberNode
---@field items table
Item = setmetatable({}, { __index = Addon.GroupMemberNode }) -- inherit from Node
Item.__index = Item
Item.type = Addon.NodeType.ITEM

---@param parent Node?
---@param rank number?
---@return Item
function Item:new(parent, rank)
    ---@type Item
    local obj = Addon.GroupMemberNode.new(self, parent, rank) -- parent constructor
    obj.name = "New Item"

    return obj
end

Addon.Item = Item
return Item