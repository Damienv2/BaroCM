---@type Addon
local Addon = select(2, ...)

---@class GroupMemberNode : Node
local GroupMemberNode = setmetatable({}, { __index = Addon.Node }) -- inherit from Node
GroupMemberNode.__index = GroupMemberNode
GroupMemberNode.type = Addon.NodeType.GROUP_MEMBER_NODE

---@return GroupMemberNode
function GroupMemberNode:default()
    ---@type GroupMemberNode
    local obj = Addon.CollectionMemberNode.default(self) -- parent constructor
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