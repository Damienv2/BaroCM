---@type Addon
local Addon = select(2, ...)

---@class ProgBar : CollectionMemberNode
---@field movable MovableMixin
local ProgBar = setmetatable({}, { __index = Addon.CollectionMemberNode }) -- inherit from Node
ProgBar.__index = ProgBar
ProgBar.type = Addon.NodeType.PROG_BAR

---@return ProgBar
function ProgBar:default()
    ---@type ProgBar
    local obj = Addon.CollectionMemberNode.default(self)

    Addon.Mixin:embed(obj, "movable", Addon.MovableMixin)

    obj.movable:registerMovableFrame(obj.frame)

    obj.name = "New ProgBar"

    return obj
end

---@return table
function ProgBar:serializeProps()
    local movable = self:serializeMovableProps()
    return {
        pos = movable.pos,
    }
end

---@param data table
function ProgBar:deserializeProps(data)
    self:deserializeMovableProps(data)
end

function ProgBar:afterSetParent()
    if self.parent.movable then
        self.movable:setIsLocked(true)
    end
end

Addon.ProgBar = ProgBar
return ProgBar