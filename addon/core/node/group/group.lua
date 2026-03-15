---@type Addon
local Addon = select(2, ...)

---@class ChildrenGrid
---@field maxRows number
---@field maxCols number
---@field horizontalAlignment HorizontalAlignmentValue
---@field verticalAlignment VerticalAlignmentValue
---@field growthPrio GrowthPrioValue
---@field childSpacing number
---@field childSize number

---@class Group : CollectionMemberNode
---@field movable MovableMixin
---@field background BackgroundMixin
---@field childrenGrid ChildrenGrid
---@field isExpanded boolean
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

    obj.refreshChildFramesTicker = CreateFrame("Frame")
    obj.refreshChildFramesTicker:SetScript("OnUpdate", function(_, elapsed)
        obj:refreshChildFrames()
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
    self:refreshChildFrames()

    Addon.EventBus:send("SAVE")
end

---@param verticalAlignment VerticalAlignment
function Group:setVerticalAlignment(verticalAlignment)
    self.childrenGrid.verticalAlignment = verticalAlignment

    Addon.EventBus:send("SAVE")
end

---@param growthPrio GrowthPrio
function Group:setGrowthPrio(growthPrio)
    self.childrenGrid.growthPrio = growthPrio

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
end

function Group:refreshChildFrames()
    local visibleChildren = {}

    for _, child in ipairs(self.children) do
        if child:shouldShow() == true then
            table.insert(visibleChildren, child)
        end
    end

    self:_refreshChildSize(visibleChildren)
    self:_refreshChildPoint(visibleChildren)
end

---@class childFrame
---@field rank number
---@field node GroupMemberNode
---@field frame Frame

---@param childFrames childFrame[]
function Group:_refreshChildPoint(childFrames)
    table.sort(childFrames, function(a, b)
        return a.rank < b.rank
    end)

    local activeCount = 0
    for _, child in ipairs(childFrames) do
        if child:shouldShow() == true then
            activeCount = activeCount + 1
        else
            child.frame:Hide()
        end
    end

    local rowIdx, colIdx = 0, 0
    for _, child in pairs(childFrames) do
        if child:shouldShow() == true then
            -- Hide the Item Frame if there is not enough room in the group
            if rowIdx >= self.childrenGrid.maxRows or colIdx >= self.childrenGrid.maxCols then
                child.frame:Hide()
            else
                -- Calculate the Frame Point
                local framePoint = nil
                if self.childrenGrid.horizontalAlignment == Addon.HorizontalAlignment.RIGHT then
                    if self.childrenGrid.verticalAlignment == Addon.VerticalAlignment.BOTTOM then
                        framePoint = Addon.FramePoint.TOPLEFT
                    elseif self.childrenGrid.verticalAlignment == Addon.VerticalAlignment.TOP then
                        framePoint = Addon.FramePoint.BOTTOMLEFT
                    elseif self.childrenGrid.verticalAlignment == Addon.VerticalAlignment.CENTER then
                        framePoint = Addon.FramePoint.TOPLEFT
                    end
                elseif self.childrenGrid.horizontalAlignment == Addon.HorizontalAlignment.LEFT then
                    if self.childrenGrid.verticalAlignment == Addon.VerticalAlignment.BOTTOM then
                        framePoint = Addon.FramePoint.TOPRIGHT
                    elseif self.childrenGrid.verticalAlignment == Addon.VerticalAlignment.TOP then
                        framePoint = Addon.FramePoint.BOTTOMRIGHT
                    elseif self.childrenGrid.verticalAlignment == Addon.VerticalAlignment.CENTER then
                        framePoint = Addon.FramePoint.TOPRIGHT
                    end
                elseif self.childrenGrid.horizontalAlignment == Addon.HorizontalAlignment.CENTER then
                    if self.childrenGrid.verticalAlignment == Addon.VerticalAlignment.BOTTOM then
                        framePoint = Addon.FramePoint.TOPLEFT
                    elseif self.childrenGrid.verticalAlignment == Addon.VerticalAlignment.TOP then
                        framePoint = Addon.FramePoint.BOTTOMLEFT
                    elseif self.childrenGrid.verticalAlignment == Addon.VerticalAlignment.CENTER then
                        framePoint = Addon.FramePoint.TOPLEFT
                    end
                end

                -- Calculate the offsetX
                local offsetX = nil
                local rowMaxWidth = (self.childrenGrid.childSize * self.childrenGrid.maxCols)  + (self.childrenGrid.childSpacing * (self.childrenGrid.maxCols - 1))
                if self.childrenGrid.horizontalAlignment == Addon.HorizontalAlignment.RIGHT then
                    offsetX = (self.childrenGrid.childSize + self.childrenGrid.childSpacing) * colIdx
                elseif self.childrenGrid.horizontalAlignment == Addon.HorizontalAlignment.LEFT then
                    offsetX = (self.childrenGrid.childSize + self.childrenGrid.childSpacing) * colIdx * -1
                elseif self.childrenGrid.horizontalAlignment == Addon.HorizontalAlignment.CENTER then
                    local remainingFrames = nil
                    if self.childrenGrid.growthPrio == Addon.GrowthPrio.ROW_FIRST then
                        remainingFrames = math.min(
                                math.max(activeCount - rowIdx * self.childrenGrid.maxCols, 0),
                                self.childrenGrid.maxCols
                        )
                    elseif self.childrenGrid.growthPrio == Addon.GrowthPrio.COL_FIRST then
                        remainingFrames = math.min(
                                math.max(math.ceil((activeCount - rowIdx) / self.childrenGrid.maxRows), 0),
                                self.childrenGrid.maxCols
                        )
                    end
                    local rowFinalWidth = (self.childrenGrid.childSize * remainingFrames) + (self.childrenGrid.childSpacing * (remainingFrames - 1))
                    local rowOffset = (rowMaxWidth - rowFinalWidth) / 2
                    offsetX = rowOffset + (self.childrenGrid.childSize + self.childrenGrid.childSpacing) * colIdx
                end

                -- Calculate the offsetY
                local offsetY = nil
                local colMaxHeight = (self.childrenGrid.childSize * self.childrenGrid.maxRows)  + (self.childrenGrid.childSpacing * (self.childrenGrid.maxRows - 1))
                if self.childrenGrid.verticalAlignment == Addon.VerticalAlignment.BOTTOM then
                    offsetY = (self.childrenGrid.childSize + self.childrenGrid.childSpacing) * rowIdx * -1
                elseif self.childrenGrid.verticalAlignment == Addon.VerticalAlignment.TOP then
                    offsetY = (self.childrenGrid.childSize + self.childrenGrid.childSpacing) * rowIdx
                elseif self.childrenGrid.verticalAlignment == Addon.VerticalAlignment.CENTER then
                    local remainingFrames = nil
                    if self.childrenGrid.growthPrio == Addon.GrowthPrio.ROW_FIRST then
                        remainingFrames = math.min(
                                math.max(math.ceil((activeCount - colIdx) / self.childrenGrid.maxCols), 0),
                                self.childrenGrid.maxRows
                        )
                    elseif self.childrenGrid.growthPrio == Addon.GrowthPrio.COL_FIRST then
                        remainingFrames = math.min(
                                math.max(activeCount - colIdx * self.childrenGrid.maxRows, 0),
                                self.childrenGrid.maxRows
                        )
                    end
                    local colFinalHeight = (self.childrenGrid.childSize * remainingFrames) + (self.childrenGrid.childSpacing * (remainingFrames - 1))
                    local colOffset = (colMaxHeight - colFinalHeight) / 2 * -1
                    offsetY = colOffset + (self.childrenGrid.childSize + self.childrenGrid.childSpacing) * rowIdx * -1
                end

                child.frame:ClearAllPoints()
                child.frame:SetPoint(framePoint, self.frame, framePoint, offsetX, offsetY)
                if child.frame:IsShown() == false then
                    child.frame:Show()
                end

                -- Calculate the row and column indices
                if self.childrenGrid.growthPrio == Addon.GrowthPrio.ROW_FIRST then
                    colIdx = colIdx + 1
                    if colIdx >= self.childrenGrid.maxCols then
                        rowIdx =  rowIdx + 1
                        colIdx = 0
                    end
                elseif self.childrenGrid.growthPrio == Addon.GrowthPrio.COL_FIRST then
                    rowIdx = rowIdx + 1
                    if rowIdx >= self.childrenGrid.maxRows then
                        rowIdx = 0
                        colIdx =  colIdx + 1
                    end
                end
            end
        end
    end
end

---@param childFrames childFrame[]
function Group:_refreshChildSize(childFrames)
    for _, childFrame in ipairs(childFrames) do
        childFrame.frame:SetSize(self.childrenGrid.childSize, self.childrenGrid.childSize)
    end
end

Addon.Group = Group
return Group
