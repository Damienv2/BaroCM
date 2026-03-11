---@type Addon
local Addon = select(2, ...)

---@class ProgBarBase : CollectionMemberNode
local ProgBar = setmetatable({}, { __index = Addon.CollectionMemberNode }) -- inherit from Node
ProgBar.__index = ProgBar
ProgBar.type = Addon.NodeType.PROG_BAR

---@alias ProgBar ProgBarBase | MovableMixin
---@type ProgBar
local ProgBar = ProgBar

---@return ProgBar
function ProgBar:default()
    ---@type ProgBar
    local obj = Addon.CollectionMemberNode.default(self)

    Mixin(obj, Addon.MovableMixin)
    obj:initMovable()

    obj.name = "New ProgBar"

    return obj
end

---@return table
function Group:serializeProps()
    local movable = self:serializeMovableProps()
    return {
        pos = movable.pos,
    }
end

---@param data table
function Group:deserializeProps(data)
    self:deserializeMovableProps(data)
end

Addon.ProgBar = ProgBar
return ProgBar