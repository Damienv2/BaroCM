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

---@class GroupBase : CollectionMemberNode
---@field childrenGrid ChildrenGrid
---@field showBackground boolean
---@field bgFrame Frame
local Group = setmetatable({}, { __index = Addon.CollectionMemberNode })
Group.__index = Group
Group.type = Addon.NodeType.GROUP

---@alias Group GroupBase | MovableMixin | BackgroundMixin
---@type Group
local Group = Group

---@return Group
function Group:default()
    ---@type Group
    local obj = Addon.CollectionMemberNode.default(self)

    Mixin(obj, Addon.MovableMixin)
    Mixin(obj, Addon.BackgroundMixin)

    obj:initMovable()
    obj:initBackground()

    obj:registerMovableFrame(obj.frame)

    obj.name = "New Group"
    obj.childrenGrid = {
        maxRows = 1,
        maxCols = 6,
        rowGrowth = Addon.RowGrowth.RIGHT,
        colGrowth = Addon.ColGrowth.DOWN,
        growthPrio = Addon.GrowthPrio.ROW_FIRST,
        childSpacing = 3,
        childSize = 48,
    }
    obj:refreshFrameSize()

    return obj
end

---@return table
function Group:serializeProps()
    local movable = self:serializeMovableProps()
    local background = self:serializeBackgroundProps()
    return {
        childrenGrid = self.childrenGrid,
        pos = movable.pos,
        showBackground = background.showBackground
    }
end

---@param data table
function Group:deserializeProps(data)
    self:deserializeMovableProps(data)
    self:deserializeBackgroundProps(data)
    self.childrenGrid = data.childrenGrid
    self.showBackground = data.showBackground
end

---@param node Node
function Group:afterAppendChild(node)

end

function Group:refreshFrameSize()
    local grid = self.childrenGrid
    local w = (grid.childSize * grid.maxCols) + (grid.childSpacing * (grid.maxCols - 1))
    local h = (grid.childSize * grid.maxRows) + (grid.childSpacing * (grid.maxRows - 1))
    self.frame:SetSize(w, h)
end

Addon.Group = Group
return Group
