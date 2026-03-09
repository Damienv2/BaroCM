---@type Addon
local Addon = select(2, ...)

---@class GroupPos
---@field point FramePointValue
---@field relativeTo string
---@field relativePoint FramePointValue
---@field offsetX number
---@field offsetY number

---@class ChildrenGrid
---@field maxRows number
---@field maxCols number
---@field rowGrowth RowGrowthValue
---@field colGrowth ColGrowthValue
---@field growthPrio GrowthPrioValue
---@field spacing number
---@field childSize number

---@class Group : CollectionMemberNode
---@field pos GroupPos
---@field childrenGrid ChildrenGrid
Group = setmetatable({}, { __index = Addon.CollectionMemberNode }) -- inherit from Node
Group.__index = Group
Group.type = Addon.NodeType.GROUP

---@return Group
function Group:default()
    ---@type Group
    local obj = Addon.CollectionMemberNode.default(self) -- parent constructor
    obj.name = "New Group"

    obj.pos = {
        point = Addon.FramePoint.CENTER,
        relativeTo = "UIParent",
        relativePoint = Addon.FramePoint.CENTER,
        offsetX = 0,
        offsetY = 0,
    }

    obj.childrenGrid = {
        maxRows = 1,
        maxCols = 6,
        rowGrowth = Addon.RowGrowth.RIGHT,
        colGrowth = Addon.ColGrowth.DOWN,
        growthPrio = Addon.GrowthPrio.ROW_FIRST,
        spacing = 3,
        childSize = 48,
    }

    return obj
end

---@return table
function Group:serializeProps()
    return {
        pos = {
            point = self.pos.point,
            relativeTo = self.pos.relativeTo,
            relativePoint = self.pos.relativePoint,
            offsetX = self.pos.offsetX,
            offsetY = self.pos.offsetY
        },
        childrenGrid = {
            maxRows = self.childrenGrid.maxRows,
            maxCols = self.childrenGrid.maxCols,
            rowGrowth = self.childrenGrid.rowGrowth,
            colGrowth = self.childrenGrid.colGrowth,
            growthPrio = self.childrenGrid.growthPrio,
            spacing = self.childrenGrid.spacing,
            childSize = self.childrenGrid.childSize
        }
    }
end

---@param data table
function Group:deserializeProps(data)
    local pos = data.pos
    self.pos = {
        point = pos.point,
        relativeTo = pos.relativeTo,
        relativePoint = pos.relativePoint,
        offsetX = pos.offsetX,
        offsetY = pos.offsetY,
    }

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
end

---@param point FramePoint
function Group:setPoint(point)
    self.pos.point = point

    Addon.EventBus:send("SAVE")
end

---@param relativeTo string
function Group:setRelativeTo(relativeTo)
    self.pos.relativeTo = relativeTo

    Addon.EventBus:send("SAVE")
end

---@param relativePoint FramePoint
function Group:setRelativePoint(relativePoint)
    self.pos.relativePoint = relativePoint

    Addon.EventBus:send("SAVE")
end

---@param offsetX number
function Group:setOffsetX(offsetX)
    self.pos.offsetX = offsetX

    Addon.EventBus:send("SAVE")
end

---@param offsetY number
function Group:setOffsetY(offsetY)
    self.pos.offsetY = offsetY

    Addon.EventBus:send("SAVE")
end

Addon.Group = Group
return Group