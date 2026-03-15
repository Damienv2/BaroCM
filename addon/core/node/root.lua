---@type Addon
local Addon = select(2, ...)

---@class Root : Node
local Root = setmetatable({}, { __index = Addon.Node })
Root.__index = Root
Root.type = Addon.NodeType.ROOT

---@return Root
function Root:default()
    ---@type Root
    local obj = Addon.Node.default(self)

    obj.name = "ROOT"
    obj.rank = 0
    obj.frame:ClearAllPoints()
    obj.frame:SetAllPoints()

    return obj
end

Addon.Root = Root
return Root