---@type Addon
local Addon = select(2, ...)

---@class CollectionBase : Node
---@field orientation CollectionOrientation
local Collection = setmetatable({}, { __index = Addon.Node }) -- inherit from Node
Collection.__index = Collection
Collection.type = Addon.NodeType.COLLECTION

---@alias Collection CollectionBase | MovableMixin | BackgroundMixin
---@type Collection
local Collection = Collection

---@return Collection
function Collection:default()
    ---@type Collection
    local obj = Addon.Node.default(self)

    Mixin(obj, Addon.MovableMixin)
    Mixin(obj, Addon.BackgroundMixin)

    obj:initMovable()
    obj:initBackground()

    obj:registerMovableFrame(obj.frame)

    obj.name = "New Collection"
    obj.orientation = Addon.CollectionOrientation.VERTICAL

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
    local background = self:serializeBackgroundProps()
    return {
        pos = movable.pos,
        showBackground = background.showBackground,
        orientation = self.orientation,
    }
end

---@param data table
function Collection:deserializeProps(data)
    self:deserializeMovableProps(data)
    self:deserializeBackgroundProps(data)
    self.orientation = data.orientation
end

function Collection:wrapChildren()
    if #self.children == 0 then return end

    local maxY = math.huge
    local maxX = math.huge
    local minY = -math.huge
    local minX = -math.huge
    for _, child in ipairs(self.children) do
        maxY = math.max(child.frame:GetTop() or 0, maxY)
        maxX = math.max(child.frame:GetRight() or 0, maxX)
        minY = math.min(child.frame:GetBottom() or 0, minY)
        minX = math.min(child.frame:GetLeft() or 0, minX)
    end

    self.frame:SetSize(maxX - minX, maxY - minY)
end

---@param node Node
function Collection:afterAppendChild(node)
    self:wrapChildren()

    local collection = self
    node.frame:SetScript("OnSizeChanged", function(f, width, height)
        collection:wrapChildren()
        print("C")
    end)
    node.frame:SetScript("OnMove", function(f)
        collection:wrapChildren()
        print("C2")
    end)
end

---@param orientation CollectionOrientation
function Collection:setOrientation(orientation)
    self.orientation = orientation

    Addon.EventBus.send("SAVE")
end

Addon.Collection = Collection
return Collection