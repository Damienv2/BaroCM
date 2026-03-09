---@type Addon
local Addon = select(2, ...)

---@class ProgBar : CollectionMemberNode
ProgBar = setmetatable({}, { __index = Addon.CollectionMemberNode }) -- inherit from Node
ProgBar.__index = ProgBar
ProgBar.type = Addon.NodeType.PROG_BAR

---@return ProgBar
function ProgBar:default()
    ---@type ProgBar
    local obj = Addon.CollectionMemberNode.default(self) -- parent constructor
    obj.name = "New ProgBar"

    return obj
end

Addon.ProgBar = ProgBar
return ProgBar