---@type Addon
local Addon = select(2, ...)

---@class ChildrenGrid
---@field maxRows number
---@field maxCols number
---@field rowGrowth RowGrowthValue
---@field colGrowth ColGrowthValue
---@field growthPrio GrowthPrioValue
---@field childSpacing number
---@field childSize number

---@class Group : CollectionMemberNode
---@field movable MovableMixin
---@field background BackgroundMixin
---@field childrenGrid ChildrenGrid
local Group = setmetatable({}, { __index = Addon.CollectionMemberNode })
Group.__index = Group
Group.type = Addon.NodeType.GROUP

---@return Group
function Group:default()
    ---@type Group
    local obj = Addon.CollectionMemberNode.default(self)

    Addon.Mixin:embed(obj, "movable", Addon.MovableMixin)
    Addon.Mixin:embed(obj, "background", Addon.BackgroundMixin)

    obj.movable:registerMovableFrame(obj.frame)

    obj.name = "New Group"
    obj.childrenGrid = {
        maxRows = 1,
        maxCols = 6,
        rowGrowth = Addon.HorizontalAlignment.LEFT,
        colGrowth = Addon.VerticalAlignment.TOP,
        growthPrio = Addon.GrowthPrio.ROW_FIRST,
        childSpacing = 3,
        childSize = 48,
    }
    obj:refreshFrameSize()

    return obj
end

---@return table
function Group:serializeProps()
    local movable = self.movable:serializeMovableProps()
    local background = self.background:serializeBackgroundProps()
    return {
        childrenGrid = self.childrenGrid,
        movable = movable,
        background = background,
    }
end

---@param data table
function Group:deserializeProps(data)
    self.movable:deserializeMovableProps(data)
    self.background:deserializeBackgroundProps(data)
    self.childrenGrid = data.childrenGrid
    self:refreshFrameSize()
end

function Group:beforeDelete()
    self.background:setShowBackground(false)
    self.background.bgFrame = nil
end

---@param node Node
function Group:afterAppendChild(node)

end

function Group:afterSetParent()
    if self.parent.movable then
        self.movable:setIsLocked(true)
    end
end

function Group:refreshFrameSize()
    local grid = self.childrenGrid
    local w = (grid.childSize * grid.maxCols) + (grid.childSpacing * (grid.maxCols - 1))
    local h = (grid.childSize * grid.maxRows) + (grid.childSpacing * (grid.maxRows - 1))
    self.frame:SetSize(w, h)
end

Addon.Group = Group
return Group
