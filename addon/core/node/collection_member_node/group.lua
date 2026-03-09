---@type Addon
local Addon = select(2, ...)

---@class Group : CollectionMemberNode
---@field items table
Group = setmetatable({}, { __index = Addon.CollectionMemberNode }) -- inherit from Node
Group.__index = Group
Group.type = Addon.NodeType.GROUP

---@param parent Node?
---@param rank number?
---@return Group
function Group:new(parent, rank)
    ---@type Group
    local obj = Addon.CollectionMemberNode.new(self, parent, rank) -- parent constructor
    obj.name = "New Group"

    obj.pos = {
        point = Addon.FramePoint.CENTER,
        relativeTo = "UIParent",
        relativePoint = Addon.FramePoint.CENTER,
        offsetX = 0,
        offsetY = 0,
    }

    return obj
end

Addon.Group = Group
return Group