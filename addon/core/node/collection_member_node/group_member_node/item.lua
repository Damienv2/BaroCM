---@type Addon
local Addon = select(2, ...)

---@class Item : GroupMemberNode
local Item = setmetatable({}, { __index = Addon.GroupMemberNode }) -- inherit from Node
Item.__index = Item
Item.type = Addon.NodeType.ITEM

---@return Item
function Item:default()
    ---@type Item
    local obj = Addon.GroupMemberNode.default(self) -- parent constructor
    obj.name = "New Item"

    return obj
end

Addon.Item = Item
return Item