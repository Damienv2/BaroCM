---@type Addon
local Addon = select(2, ...)

---@class GroupPos
---@field point FramePointValue
---@field relativeTo string
---@field relativePoint FramePointValue
---@field offsetX number
---@field offsetY number

---@class GroupItemGrid
---@field maxRows number
---@field maxCols number
---@field rowGrowth RowGrowthValue
---@field colGrowth ColGrowthValue
---@field growthPrio GrowthPrioValue
---@field itemSpacing number
---@field itemSize number
---@field itemCollection ItemCollection

---@class Group
---@field id string
---@field name string
---@field pos GroupPos
---@field showBackground boolean
---@field isLocked boolean
---@field itemGrid GroupItemGrid
---@field groupFrame GroupFrame
---@field parentGroupCollection GroupCollection
local Group = {}
Group.__index = Group

---@param parentGroupCollection GroupCollection
---@return Group
function Group.default(parentGroupCollection)
    local self = setmetatable({}, Group)
    self.id = Addon.Utils:uuid4()
    self.name = "New Group"

    self.pos = {
        point = Addon.FramePoint.CENTER,
        relativeTo = "UIParent",
        relativePoint = Addon.FramePoint.CENTER,
        offsetX = 0,
        offsetY = 0,
    }

    self.showBackground = true
    self.isLocked = false

    self.itemGrid = {
        maxRows = 1,
        maxCols = 6,
        rowGrowth = Addon.RowGrowth.RIGHT,
        colGrowth = Addon.ColGrowth.DOWN,
        growthPrio = Addon.GrowthPrio.ROW_FIRST,
        itemSpacing = 3,
        itemSize = 48,
        itemCollection = Addon.ItemCollection.default(self)
    }

    self.groupFrame = Addon.GroupFrame.hidden(self)

    self.parentGroupCollection = parentGroupCollection

    return self
end

---@param serializedGroup table
---@param parentGroupCollection GroupCollection
---@return Group
function Group.deserialize(serializedGroup, parentGroupCollection)
    local self = setmetatable({}, Group)
    self.id = serializedGroup.id
    self.name = serializedGroup.name

    local pos = serializedGroup.pos
    self.pos = {
        point = pos.point,
        relativeTo = pos.relativeTo,
        relativePoint = pos.relativePoint,
        offsetX = pos.offsetX,
        offsetY = pos.offsetY,
    }

    self.showBackground = serializedGroup.showBackground
    self.isLocked = serializedGroup.isLocked

    local itemGrid = serializedGroup.itemGrid
    self.itemGrid = {
        maxRows = itemGrid.maxRows,
        maxCols = itemGrid.maxCols,
        rowGrowth = itemGrid.rowGrowth,
        colGrowth = itemGrid.colGrowth,
        growthPrio = itemGrid.growthPrio,
        itemSpacing = itemGrid.itemSpacing,
        itemSize = itemGrid.itemSize,
    }

    self.groupFrame = Addon.GroupFrame.hidden(self)

    self.parentGroupCollection = parentGroupCollection

    self.itemGrid.itemCollection = Addon.ItemCollection.deserialize(itemGrid.itemCollection, self)

    return self
end

---@return table
function Group:serialize()
    return {
        id = self.id,
        name = self.name,
        pos = {
            point = self.pos.point,
            relativeTo = self.pos.relativeTo,
            relativePoint = self.pos.relativePoint,
            offsetX = self.pos.offsetX,
            offsetY = self.pos.offsetY,
        },
        showBackground = self.showBackground,
        isLocked = self.isLocked,
        itemGrid = {
            maxRows = self.itemGrid.maxRows,
            maxCols = self.itemGrid.maxCols,
            colGrowth = self.itemGrid.colGrowth,
            rowGrowth = self.itemGrid.rowGrowth,
            growthPrio = self.itemGrid.growthPrio,
            itemSpacing = self.itemGrid.itemSpacing,
            itemSize = self.itemGrid.itemSize,
            itemCollection = self.itemGrid.itemCollection:serialize()
        },
    }
end

function Group:show()
    self.groupFrame:applyPosition()
    self.groupFrame:applySize()
    self.groupFrame:show()

    self.itemGrid.itemCollection:show()
end

function Group:hide()
    self.groupFrame:hide()

    self.itemGrid.itemCollection:hide()
end

function Group:delete()
    self:hide()

    self.groupFrame:delete()
    self.groupFrame = nil

    self.itemGrid.itemCollection:delete()
    self.itemGrid.itemCollection = nil
end

---@param name string
function Group:setName(name)
    self.name = name

    Addon.inst.groupCollection:save()
end

---@param point FramePointValue
function Group:setPoint(point)
    self.pos.point = point
    self.groupFrame:applyPosition()

    Addon.inst.groupCollection:save()
end

---@param frame Frame
function Group:setRelativeTo(frame)
    self.pos.relativeTo = frame
    self.groupFrame:applyPosition()

    Addon.inst.groupCollection:save()
end

---@param point FramePointValue
function Group:setRelativePoint(point)
    self.pos.relativePoint = point
    self.groupFrame:applyPosition()

    Addon.inst.groupCollection:save()
end

---@param offsetX number
function Group:setOffsetX(offsetX)
    self.pos.offsetX = offsetX
    self.groupFrame:applyPosition()

    Addon.inst.groupCollection:save()
end

---@param offsetY number
function Group:setOffsetY(offsetY)
    self.pos.offsetY = offsetY
    self.groupFrame:applyPosition()

    Addon.inst.groupCollection:save()
end

---@param maxRows number
function Group:setMaxRows(maxRows)
    self.itemGrid.maxRows = maxRows
    self.groupFrame:applySize()
    self.itemGrid.itemCollection:refreshItemPosition()

    Addon.inst.groupCollection:save()
end

---@param maxCols number
function Group:setMaxCols(maxCols)
    self.itemGrid.maxCols = maxCols
    self.groupFrame:applySize()
    self.itemGrid.itemCollection:refreshItemPosition()

    Addon.inst.groupCollection:save()
end

---@param rowGrowth RowGrowthValue
function Group:setRowGrowth(rowGrowth)
    self.itemGrid.rowGrowth = rowGrowth
    self.itemGrid.itemCollection:refreshItemPosition()

    Addon.inst.groupCollection:save()
end

---@param colGrowth ColGrowthValue
function Group:setColGrowth(colGrowth)
    self.itemGrid.colGrowth = colGrowth
    self.itemGrid.itemCollection:refreshItemPosition()

    Addon.inst.groupCollection:save()
end

---@param growthPrio GrowthPrioValue
function Group:setGrowthPrio(growthPrio)
    self.itemGrid.growthPrio = growthPrio
    self.itemGrid.itemCollection:refreshItemPosition()

    Addon.inst.groupCollection:save()
end

---@param itemSpacing number
function Group:setItemSpacing(itemSpacing)
    self.itemGrid.itemSpacing = itemSpacing
    self.groupFrame:applySize()
    self.itemGrid.itemCollection:refreshItemPosition()

    Addon.inst.groupCollection:save()
end

---@param itemSize number
function Group:setItemSize(itemSize)
    self.itemGrid.itemCollection:hide()
    self.itemGrid.itemSize = itemSize
    self.groupFrame:applySize()
    self.itemGrid.itemCollection:applySize()
    self.itemGrid.itemCollection:refreshItemPosition()
    self.itemGrid.itemCollection:show()

    Addon.inst.groupCollection:save()
end

---@param showBackground boolean
function Group:setShowBackground(showBackground)
    if self.showBackground ~= showBackground then
        self.groupFrame:showBackground(showBackground)
        self.showBackground = showBackground

        Addon.inst.groupCollection:save()
    end
end

---@param isLocked boolean
function Group:setIsLocked(isLocked)
    if self.isLocked ~= isLocked then
        self.isLocked = isLocked
        self.groupFrame:handleIsLockedChange()

        Addon.inst.groupCollection:save()
    end
end

Addon.Group = Group
return Group











