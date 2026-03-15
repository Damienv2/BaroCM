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
        horizontalAlignment = Addon.HorizontalAlignment.LEFT,
        verticalAlignment = Addon.VerticalAlignment.TOP,
        growthPrio = Addon.GrowthPrio.ROW_FIRST,
        childSpacing = 3,
        childSize = 48,
    }
    obj:refreshFrameSize()

    Addon.EventBus:register("NEW_BINDING", function()
        obj:refreshChildren()
    end)

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
    self:refreshChildren()
end

function Group:afterSetParent()
    if self.parent.movable then
        self.movable:setIsLocked(true)
    end
end

---@param maxRows number
function Group:setMaxRows(maxRows)
    self.childrenGrid.maxRows = maxRows
    self:refreshFrameSize()

    Addon.EventBus:send("SAVE")
end

---@param maxCols number
function Group:setMaxCols(maxCols)
    self.childrenGrid.maxCols = maxCols
    self:refreshFrameSize()

    Addon.EventBus:send("SAVE")
end

---@param horizontalAlignment HorizontalAlignment
function Group:setHorizontalAlignment(horizontalAlignment)
    self.childrenGrid.horizontalAlignment = horizontalAlignment
    self:refreshChildren()

    Addon.EventBus:send("SAVE")
end

---@param verticalAlignment VerticalAlignment
function Group:setVerticalAlignment(verticalAlignment)
    self.childrenGrid.verticalAlignment = verticalAlignment
    self:refreshChildren()

    Addon.EventBus:send("SAVE")
end

---@param growthPrio GrowthPrio
function Group:setGrowthPrio(growthPrio)
    self.childrenGrid.growthPrio = growthPrio
    self:refreshChildren()

    Addon.EventBus:send("SAVE")
end

---@param childSpacing number
function Group:setChildSpacing(childSpacing)
    self.childrenGrid.childSpacing = childSpacing
    self:refreshFrameSize()

    Addon.EventBus:send("SAVE")
end

---@param childSize number
function Group:setChildSize(childSize)
    self.childrenGrid.childSize = childSize
    self:refreshFrameSize()

    Addon.EventBus:send("SAVE")
end

function Group:refreshFrameSize()
    local grid = self.childrenGrid
    local w = (grid.childSize * grid.maxCols) + (grid.childSpacing * (grid.maxCols - 1))
    local h = (grid.childSize * grid.maxRows) + (grid.childSpacing * (grid.maxRows - 1))
    self.frame:SetSize(w, h)

    self:refreshChildren()
end

function Group:refreshChildren()
    for _, child in ipairs(self.children) do
        child:refreshVisibility()
    end
end

Addon.Group = Group
return Group
