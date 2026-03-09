---@type Addon
local Addon = select(2, ...)

---@class CollectionMemberNode : Node
---@field items table
CollectionMemberNode = setmetatable({}, { __index = Addon.Node }) -- inherit from Node
CollectionMemberNode.__index = CollectionMemberNode
CollectionMemberNode.type = Addon.NodeType.COLLECTION_MEMBER_NODE

---@param parent Node?
---@param rank number?
---@return CollectionMemberNode
function CollectionMemberNode:new(parent, rank)
    ---@type CollectionMemberNode
    local obj = Addon.Node.new(self, parent, rank) -- parent constructor
    obj.name = "New CollectionMemberNode"

    return obj
end

---@param parent Node
function CollectionMemberNode:validateParent(parent)
    if parent.type ~= Addon.NodeType.COLLECTION then
        error("Collection Member Node must have a Collection parent.")
    end
end

Addon.CollectionMemberNode = CollectionMemberNode
return CollectionMemberNode