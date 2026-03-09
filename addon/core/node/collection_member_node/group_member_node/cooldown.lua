---@type Addon
local Addon = select(2, ...)

---@class Cooldown : GroupMemberNode
---@field items table
Cooldown = setmetatable({}, { __index = Addon.GroupMemberNode }) -- inherit from Node
Cooldown.__index = Cooldown
Cooldown.type = Addon.NodeType.COOLDOWN

---@param parent Node?
---@param rank number?
---@return Cooldown
function Cooldown:new(parent, rank)
    ---@type Cooldown
    local obj = Addon.GroupMemberNode.new(self, parent, rank) -- parent constructor
    obj.name = "New Cooldown"

    return obj
end

Addon.Cooldown = Cooldown
return Cooldown