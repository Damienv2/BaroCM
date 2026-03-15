---@type Addon
local Addon = select(2, ...)

---@class GroupMemberNode : Node
---@field specId number
local GroupMemberNode = setmetatable({}, { __index = Addon.Node })
GroupMemberNode.__index = GroupMemberNode
GroupMemberNode.type = Addon.NodeType.GROUP_MEMBER_NODE

---@return GroupMemberNode
function GroupMemberNode:default()
    ---@type GroupMemberNode
    local obj = Addon.CollectionMemberNode.default(self)
    obj.name = "New GroupMemberNode"
    obj.specId = select(1, GetSpecializationInfo(GetSpecialization()))

    return obj
end

---@param parent Node
function GroupMemberNode:validateParent(parent)
    if parent.type ~= Addon.NodeType.GROUP then
        error("Group Member Node must have a Group parent.")
    end
end

---@return table
function GroupMemberNode:serializeProps()
    return {
        specId = self.specId
    }
end

---@param data table
function GroupMemberNode:deserializeProps(data)
    self.specId = data.specId
end

function GroupMemberNode:refreshVisibility()

end

Addon.GroupMemberNode = GroupMemberNode
return GroupMemberNode