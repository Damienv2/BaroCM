---@type Addon
local Addon = select(2, ...)

---@class Cooldown : GroupMemberNode
Cooldown = setmetatable({}, { __index = Addon.GroupMemberNode }) -- inherit from Node
Cooldown.__index = Cooldown
Cooldown.type = Addon.NodeType.COOLDOWN

---@return Cooldown
function Cooldown:default()
    ---@type Cooldown
    local obj = Addon.GroupMemberNode.default(self) -- parent constructor
    obj.name = "New Cooldown"

    return obj
end

Addon.Cooldown = Cooldown
return Cooldown