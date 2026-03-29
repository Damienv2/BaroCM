---@type Addon
local Addon = select(2, ...)

---@class GroupMemberNode : Node
---@field specId number
local GroupMemberNode = setmetatable({}, { __index = Addon.Node })
GroupMemberNode.__index = GroupMemberNode
GroupMemberNode.type = Addon.NodeType.GROUP_MEMBER_NODE

---@return GroupMemberNode
function GroupMemberNode:_construct()
    ---@type GroupMemberNode
    local obj = Addon.CollectionMemberNode._construct(self)
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

---@return boolean
function GroupMemberNode:shouldShow()
    local parentShouldShow = Addon.Node.shouldShow(self)

    return parentShouldShow and self.specId == select(1, GetSpecializationInfo(GetSpecialization()))
end

Addon.GroupMemberNode = GroupMemberNode
return GroupMemberNode