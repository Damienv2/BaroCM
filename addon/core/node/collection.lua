---@type Addon
local Addon = select(2, ...)

---@class CollectionBase : Node
local Collection = setmetatable({}, { __index = Addon.Node }) -- inherit from Node
Collection.__index = Collection
Collection.type = Addon.NodeType.COLLECTION

---@alias Collection CollectionBase | MovableMixin
---@type Collection
local Collection = Collection

---@return Collection
function Collection:default()
    ---@type Collection
    local obj = Addon.Node.default(self)

    Mixin(obj, Addon.MovableMixin)
    obj:initMovable()

    obj.name = "New Collection"

    return obj
end

---@param parent Node
function Collection:setParent(parent)
    if parent.type ~= Addon.NodeType.NODE and parent.type ~= Addon.NodeType.COLLECTION then
        error("Collection must have a Node or Collection parent.")
    end

    self.parent = parent
end

---@return table
function Collection:serializeProps()
    local movable = self:serializeMovableProps()
    return {
        pos = movable.pos,
    }
end

---@param data table
function Collection:deserializeProps(data)
    self:deserializeMovableProps(data)
end

Addon.Collection = Collection
return Collection