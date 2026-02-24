---@type Addon
local Addon = select(2, ...)

---@class ItemCollection
---@field items Item[]
---@field parentGroup Group
local ItemCollection = {}
ItemCollection.__index = ItemCollection

---@param parentGroup Group
---@return ItemCollection
function ItemCollection.default(parentGroup)
    local self = setmetatable({}, ItemCollection)
    self.items = {}
    self.parentGroup = parentGroup

    return self
end

---@param serializedItemCollection table
---@param parentGroup Group
---@return ItemCollection
function ItemCollection.deserialize(serializedItemCollection, parentGroup)
    local self = setmetatable({}, ItemCollection)

    self.parentGroup = parentGroup

    self.items = {}
    local items = serializedItemCollection.items or {}
    for _, serializedItem in pairs(items) do
        table.insert(self.items, Addon.Item.deserialize(serializedItem, self))
    end
    self:refreshItemPosition()

    return self
end

---@return table
function ItemCollection:serialize()
    local serializedItems = {}
    for _, item in pairs(self.items) do
        table.insert(serializedItems, item:serialize())
    end

    return {
        items = serializedItems,
        nextId = self.nextId
    }
end

---@return Item
function ItemCollection:createItem()
    local item = Addon.Item.default(self)
    table.insert(self.items, item)
    Addon.inst.groupCollection:save()

    self:refreshItemPosition()

    return item
end

function ItemCollection:show()
    for _, item in pairs(self.items) do
        item:show()
    end
end

function ItemCollection:hide()
    for _, item in pairs(self.items) do
        item:hide()
    end
end

function ItemCollection:delete()
    self:hide()

    for _, item in pairs(self.items) do
        item:delete()
    end
    self.items = {}
end

---@param itemToDelete Item
function ItemCollection:deleteItem(itemToDelete)
    for idx, item in ipairs(self.items) do
        if item.id == itemToDelete.id then
            item:delete()
            table.remove(self.items, idx)
            break
        end
    end

    Addon.inst.groupCollection:save()
end

function ItemCollection:refreshItemPosition()
    local activeCount = 0
    for _, item in ipairs(self.items) do
        if item:shouldDisplay() then
            activeCount = activeCount + 1
        end
    end

    local rowIdx, colIdx = 0, 0
    for _, item in pairs(self.items) do
        if item:shouldDisplay() then
            -- Hide the Item Frame if there is not enough room in the group
            if rowIdx >= self.parentGroup.itemGrid.maxRows or colIdx >= self.parentGroup.itemGrid.maxCols then
                item:hide()
            else
                -- Calculate the Frame Point
                local framePoint = nil
                if self.parentGroup.itemGrid.rowGrowth == Addon.RowGrowth.RIGHT then
                    if self.parentGroup.itemGrid.colGrowth == Addon.ColGrowth.DOWN then
                        framePoint = Addon.FramePoint.TOPLEFT
                    elseif self.parentGroup.itemGrid.colGrowth == Addon.ColGrowth.UP then
                        framePoint = Addon.FramePoint.BOTTOMLEFT
                    elseif self.parentGroup.itemGrid.colGrowth == Addon.ColGrowth.CENTER then
                        framePoint = Addon.FramePoint.TOPLEFT
                    end
                elseif self.parentGroup.itemGrid.rowGrowth == Addon.RowGrowth.LEFT then
                    if self.parentGroup.itemGrid.colGrowth == Addon.ColGrowth.DOWN then
                        framePoint = Addon.FramePoint.TOPRIGHT
                    elseif self.parentGroup.itemGrid.colGrowth == Addon.ColGrowth.UP then
                        framePoint = Addon.FramePoint.BOTTOMRIGHT
                    elseif self.parentGroup.itemGrid.colGrowth == Addon.ColGrowth.CENTER then
                        framePoint = Addon.FramePoint.TOPRIGHT
                    end
                elseif self.parentGroup.itemGrid.rowGrowth == Addon.RowGrowth.CENTER then
                    if self.parentGroup.itemGrid.colGrowth == Addon.ColGrowth.DOWN then
                        framePoint = Addon.FramePoint.TOPLEFT
                    elseif self.parentGroup.itemGrid.colGrowth == Addon.ColGrowth.UP then
                        framePoint = Addon.FramePoint.BOTTOMLEFT
                    elseif self.parentGroup.itemGrid.colGrowth == Addon.ColGrowth.CENTER then
                        framePoint = Addon.FramePoint.TOPLEFT
                    end
                end

                -- Calculate the offsetX
                local offsetX = nil
                local rowMaxWidth = (self.parentGroup.itemGrid.itemSize * self.parentGroup.itemGrid.maxCols)  + (self.parentGroup.itemGrid.itemSpacing * (self.parentGroup.itemGrid.maxCols - 1))
                if self.parentGroup.itemGrid.rowGrowth == Addon.RowGrowth.RIGHT then
                    offsetX = (self.parentGroup.itemGrid.itemSize + self.parentGroup.itemGrid.itemSpacing) * colIdx
                elseif self.parentGroup.itemGrid.rowGrowth == Addon.RowGrowth.LEFT then
                    offsetX = (self.parentGroup.itemGrid.itemSize + self.parentGroup.itemGrid.itemSpacing) * colIdx * -1
                elseif self.parentGroup.itemGrid.rowGrowth == Addon.RowGrowth.CENTER then
                    local remainingFrames = nil
                    if self.parentGroup.itemGrid.growthPrio == Addon.GrowthPrio.ROW_FIRST then
                        remainingFrames = math.min(
                                math.max(activeCount - rowIdx * self.parentGroup.itemGrid.maxCols, 0),
                                self.parentGroup.itemGrid.maxCols
                        )
                    elseif self.parentGroup.itemGrid.growthPrio == Addon.GrowthPrio.COL_FIRST then
                        remainingFrames = math.min(
                                math.max(math.ceil((activeCount - rowIdx) / self.parentGroup.itemGrid.maxRows), 0),
                                self.parentGroup.itemGrid.maxCols
                        )
                    end
                    local rowFinalWidth = (self.parentGroup.itemGrid.itemSize * remainingFrames) + (self.parentGroup.itemGrid.itemSpacing * (remainingFrames - 1))
                    local rowOffset = (rowMaxWidth - rowFinalWidth) / 2
                    offsetX = rowOffset + (self.parentGroup.itemGrid.itemSize + self.parentGroup.itemGrid.itemSpacing) * colIdx
                end

                -- Calculate the offsetY
                local offsetY = nil
                local colMaxHeight = (self.parentGroup.itemGrid.itemSize * self.parentGroup.itemGrid.maxRows)  + (self.parentGroup.itemGrid.itemSpacing * (self.parentGroup.itemGrid.maxRows - 1))
                if self.parentGroup.itemGrid.colGrowth == Addon.ColGrowth.DOWN then
                    offsetY = (self.parentGroup.itemGrid.itemSize + self.parentGroup.itemGrid.itemSpacing) * rowIdx * -1
                elseif self.parentGroup.itemGrid.colGrowth == Addon.ColGrowth.UP then
                    offsetY = (self.parentGroup.itemGrid.itemSize + self.parentGroup.itemGrid.itemSpacing) * rowIdx
                elseif self.parentGroup.itemGrid.colGrowth == Addon.ColGrowth.CENTER then
                    local remainingFrames = nil
                    if self.parentGroup.itemGrid.growthPrio == Addon.GrowthPrio.ROW_FIRST then
                        remainingFrames = math.min(
                                math.max(math.ceil((activeCount - colIdx) / self.parentGroup.itemGrid.maxCols), 0),
                                self.parentGroup.itemGrid.maxRows
                        )
                    elseif self.parentGroup.itemGrid.growthPrio == Addon.GrowthPrio.COL_FIRST then
                        remainingFrames = math.min(
                                math.max(activeCount - colIdx * self.parentGroup.itemGrid.maxRows, 0),
                                self.parentGroup.itemGrid.maxRows
                        )
                    end
                    local colFinalHeight = (self.parentGroup.itemGrid.itemSize * remainingFrames) + (self.parentGroup.itemGrid.itemSpacing * (remainingFrames - 1))
                    local colOffset = (colMaxHeight - colFinalHeight) / 2 * -1
                    offsetY = colOffset + (self.parentGroup.itemGrid.itemSize + self.parentGroup.itemGrid.itemSpacing) * rowIdx * -1
                end

                item.itemFrame:setPosition(framePoint, self.parentGroup.groupFrame.frame, framePoint, offsetX, offsetY)
                item:show()

                -- Calculate the row and column indices
                if self.parentGroup.itemGrid.growthPrio == Addon.GrowthPrio.ROW_FIRST then
                    colIdx = colIdx + 1
                    if colIdx >= self.parentGroup.itemGrid.maxCols then
                        rowIdx =  rowIdx + 1
                        colIdx = 0
                    end
                elseif self.parentGroup.itemGrid.growthPrio == Addon.GrowthPrio.COL_FIRST then
                    rowIdx = rowIdx + 1
                    if rowIdx >= self.parentGroup.itemGrid.maxRows then
                        rowIdx = 0
                        colIdx =  colIdx + 1
                    end
                end
            end
        end
    end
end

function ItemCollection:applySize()
    for _, item in pairs(self.items) do
        if item.itemFrame ~= nil  then
            item.itemFrame:applySize()
        end
    end
end

Addon.ItemCollection = ItemCollection
return ItemCollection