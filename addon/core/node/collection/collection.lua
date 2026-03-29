---@type Addon
local Addon = select(2, ...)

---@class Collection : Node
---@field movable MovableMixin
---@field background BackgroundMixin
---@field dynamicSizing DynamicSizingMixin
---@field offset number
local Collection = setmetatable({}, { __index = Addon.CollectionMemberNode }) -- inherit from Node
Collection.__index = Collection
Collection.type = Addon.NodeType.COLLECTION

---@return Collection
function Collection:_construct()
    ---@type Collection
    local obj = Addon.CollectionMemberNode._construct(self)

    Addon.Mixin:embed(obj, "movable", Addon.MovableMixin)
    Addon.Mixin:embed(obj, "background", Addon.BackgroundMixin)
    Addon.Mixin:embed(obj, "dynamicSizing", Addon.DynamicSizingMixin)

    obj.movable:registerMovableFrame(obj.frame)

    obj.name = "New Collection"
    obj.offset = 0

    return obj
end

---@return table
function Collection:serializeProps()
    local movable = self.movable:serializeMovableProps()
    local background = self.background:serializeBackgroundProps()
    local dynamicSizing = self.dynamicSizing:serializeDynamicSizingProps()
    return {
        movable = movable,
        background = background,
        dynamicSizing = dynamicSizing
    }
end

---@param data table
function Collection:deserializeProps(data)
    self.movable:deserializeMovableProps(data)
    self.background:deserializeBackgroundProps(data)
    self.dynamicSizing:deserializeDynamicSizingProps(data)
end

function Collection:beforeDelete()
    self.background:setShowBackground(false)
    self.background.bgFrame = nil
end

---@param node Node
function Collection:afterAppendChild(node)
    local parent = self
    node.frame:HookScript("OnSizeChanged", function()
        parent.dynamicSizing:refresh()
    end)

    self.dynamicSizing:refresh()
end

function Collection:afterSetParent()
    if self.parent ~= nil and self.parent.movable then
        self.movable:setIsLocked(true)
    end
end

Addon.Collection = Collection
return Collection