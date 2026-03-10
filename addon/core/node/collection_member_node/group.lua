---@type Addon
local Addon = select(2, ...)

---@class ChildrenGrid
---@field maxRows number
---@field maxCols number
---@field rowGrowth RowGrowthValue
---@field colGrowth ColGrowthValue
---@field growthPrio GrowthPrioValue
---@field spacing number
---@field childSize number

---@class Group : CollectionMemberNode
---@field childrenGrid ChildrenGrid
Group = setmetatable({}, { __index = Addon.CollectionMemberNode }) -- inherit from Node
Group.__index = Group
Group.type = Addon.NodeType.GROUP

---@return Group
function Group:default()
    ---@type Group
    local obj = Addon.CollectionMemberNode.default(self) -- parent constructor
    obj.name = "New Group"

    obj.childrenGrid = {
        maxRows = 1,
        maxCols = 6,
        rowGrowth = Addon.RowGrowth.RIGHT,
        colGrowth = Addon.ColGrowth.DOWN,
        growthPrio = Addon.GrowthPrio.ROW_FIRST,
        spacing = 3,
        childSize = 48,
    }

    Addon.MovableMixin:apply(obj)
    ---@cast obj Group
    ---@cast obj MovableMixin

    return obj
end

---@return table
function Group:serializeProps()
    return {
        childrenGrid = {
            maxRows = self.childrenGrid.maxRows,
            maxCols = self.childrenGrid.maxCols,
            rowGrowth = self.childrenGrid.rowGrowth,
            colGrowth = self.childrenGrid.colGrowth,
            growthPrio = self.childrenGrid.growthPrio,
            spacing = self.childrenGrid.spacing,
            childSize = self.childrenGrid.childSize
        },
        pos = {
            point = self.pos.point,
            relativeTo = self.pos.relativeTo,
            relativePoint = self.pos.relativePoint,
            offsetX = self.pos.offsetX,
            offsetY = self.pos.offsetY
        },
        isLocked = self.isLocked
    }
end

---@param data table
function Group:deserializeProps(data)
    local childrenGrid = data.childrenGrid
    self.childrenGrid = {
        maxRows = childrenGrid.maxRows,
        maxCols = childrenGrid.maxCols,
        rowGrowth = childrenGrid.rowGrowth,
        colGrowth = childrenGrid.colGrowth,
        growthPrio = childrenGrid.growthPrio,
        spacing = childrenGrid.spacing,
        childSize = childrenGrid.childSize,
    }

    local pos = data.pos
    self.pos = {
        point = pos.point,
        relativeTo = pos.relativeTo,
        relativePoint = pos.relativePoint,
        offsetX = pos.offsetX,
        offsetY = pos.offsetY,
    }
    self.isLocked = data.isLocked
end

Addon.Group = Group
return Group