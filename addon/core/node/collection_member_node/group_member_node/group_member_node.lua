---@type Addon
local Addon = select(2, ...)

---@class GroupMemberNode : CollectionMemberNode
---@field items table
GroupMemberNode = setmetatable({}, { __index = Addon.CollectionMemberNode }) -- inherit from Node
GroupMemberNode.__index = GroupMemberNode
GroupMemberNode.type = Addon.NodeType.GROUP_MEMBER_NODE

---@param parent Node?
---@param rank number?
---@return GroupMemberNode
function GroupMemberNode:new(parent, rank)
    ---@type GroupMemberNode
    local obj = Addon.CollectionMemberNode.new(self, parent, rank) -- parent constructor
    obj.name = "New GroupMemberNode"

    return obj
end

---@param parent Node
function GroupMemberNode:validateParent(parent)
    if parent.type ~= Addon.NodeType.GROUP then
        error("Group Member Node must have a Group parent.")
    end
end

Addon.GroupMemberNode = GroupMemberNode
return GroupMemberNode