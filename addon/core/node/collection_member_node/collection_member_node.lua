---@type Addon
local Addon = select(2, ...)

---@class CollectionMemberNode : Node
CollectionMemberNode = setmetatable({}, { __index = Addon.Node }) -- inherit from Node
CollectionMemberNode.__index = CollectionMemberNode
CollectionMemberNode.type = Addon.NodeType.COLLECTION_MEMBER_NODE

---@return CollectionMemberNode
function CollectionMemberNode:default()
    ---@type CollectionMemberNode
    local obj = Addon.Node.default(self) -- parent constructor
    obj.name = "New CollectionMemberNode"

    return obj
end

---@param parent Node
function CollectionMemberNode:setParent(parent)
    if parent.type ~= Addon.NodeType.COLLECTION then
        error("Collection Member Node must have a Collection parent.")
    end
    
    self.parent = parent
end

Addon.CollectionMemberNode = CollectionMemberNode
return CollectionMemberNode