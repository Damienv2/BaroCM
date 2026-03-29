---@type Addon
local Addon = select(2, ...)

---@class GroupPanel : ContentPanel
local GroupPanel = setmetatable({}, { __index = Addon.ContentPanel })
GroupPanel.__index = GroupPanel

---@param group Group
---@return GroupPanel
function GroupPanel:create(group)
    ---@type GroupPanel
    local obj = Addon.ContentPanel.create(self)

    obj.positionFrame, obj.positionFrameDispose = Addon.MovableMixinConfigPanel.getFrame(obj.marginFrame, group.movable, group.background)

    obj.layoutFrame = CreateFrame("Frame", nil, obj.marginFrame)
    obj.layoutFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.positionFrame, Addon.FramePoint.BOTTOMLEFT, 0, -obj.margin * 2)
    obj.layoutFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.positionFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -obj.margin * 2)

    obj.groupLayoutHeader = Addon.Widget:createSectionHeader("Group Layout")
    obj.groupLayoutHeader:SetParent(obj.layoutFrame)
    obj.groupLayoutHeader:SetPoint(Addon.FramePoint.TOPLEFT, obj.layoutFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.groupLayoutHeader:SetPoint(Addon.FramePoint.TOPRIGHT, obj.layoutFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    obj.groupLayoutHeader:Show()

    obj.leftGroupLayoutFrame = CreateFrame("Frame", nil, obj.layoutFrame)
    obj.leftGroupLayoutFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.groupLayoutHeader, Addon.FramePoint.BOTTOMLEFT, 0, -obj.margin)
    obj.leftGroupLayoutFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.groupLayoutHeader, Addon.FramePoint.TOP, -obj.margin / 2, -obj.margin)

    obj.numRowsFrame = Addon.Widget:createTextField(
            "Number of Rows",
            {
                numericOnly = true,
                min = -5000,
                max = 5000,
                clamp = true,
                text = group.childrenGrid.maxRows,
                onEnterPressed = function(val) group:setMaxRows(val) end
            }
    )
    obj.numRowsFrame:SetParent(obj.leftGroupLayoutFrame)
    obj.numRowsFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.leftGroupLayoutFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.numRowsFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.leftGroupLayoutFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    obj.numRowsFrame:Show()

    obj.rowGrowthFrame = Addon.Widget:createDropdown(
            "Row Growth",
            {
                options = Addon.HorizontalAlignment:getOptions(),
                selectedValue = group.childrenGrid.horizontalAlignment,
                onSelect = function(val, text) group:setHorizontalAlignment(val) end
            }
    )
    obj.rowGrowthFrame:SetParent(obj.leftGroupLayoutFrame)
    obj.rowGrowthFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.numRowsFrame, Addon.FramePoint.BOTTOMLEFT, 0, -obj.margin)
    obj.rowGrowthFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.numRowsFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -obj.margin)
    obj.rowGrowthFrame:Show()

    obj.growthPrioFrame = Addon.Widget:createDropdown(
            "Growth Priority",
            {
                options = Addon.GrowthPrio:getOptions(),
                selectedValue = group.childrenGrid.growthPrio,
                onSelect = function(val, text) group:setGrowthPrio(val) end
            }
    )
    obj.growthPrioFrame:SetParent(obj.leftGroupLayoutFrame)
    obj.growthPrioFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.rowGrowthFrame, Addon.FramePoint.BOTTOMLEFT, 0, -obj.margin)
    obj.growthPrioFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.rowGrowthFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -obj.margin)
    obj.growthPrioFrame:Show()

    obj.leftGroupLayoutFrame:SetHeight(obj.numRowsFrame:GetHeight() + obj.margin + obj.rowGrowthFrame:GetHeight() + obj.margin + obj.growthPrioFrame:GetHeight())

    obj.rightGroupLayoutFrame = CreateFrame("Frame", nil, obj.layoutFrame)
    obj.rightGroupLayoutFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.groupLayoutHeader, Addon.FramePoint.BOTTOM, obj.margin / 2, -obj.margin)
    obj.rightGroupLayoutFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.groupLayoutHeader, Addon.FramePoint.TOPRIGHT, 0, -obj.margin)

    obj.numColsFrame = Addon.Widget:createTextField(
            "Number of Columns",
            {
                numericOnly = true,
                min = -5000,
                max = 5000,
                clamp = true,
                text = group.childrenGrid.maxCols,
                onEnterPressed = function(val) group:setMaxCols(val) end
            }
    )
    obj.numColsFrame:SetParent(obj.rightGroupLayoutFrame)
    obj.numColsFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.rightGroupLayoutFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.numColsFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.rightGroupLayoutFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    obj.numColsFrame:Show()

    obj.colGrowthFrame = Addon.Widget:createDropdown(
            "Column Growth",
            {
                options = Addon.VerticalAlignment:getOptions(),
                selectedValue = group.childrenGrid.verticalAlignment,
                onSelect = function(val, text) group:setVerticalAlignment(val) end
            }
    )
    obj.colGrowthFrame:SetParent(obj.rightGroupLayoutFrame)
    obj.colGrowthFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.numColsFrame, Addon.FramePoint.BOTTOMLEFT, 0, -obj.margin)
    obj.colGrowthFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.numColsFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -obj.margin)
    obj.colGrowthFrame:Show()

    obj.rightGroupLayoutFrame:SetHeight(obj.numColsFrame:GetHeight() + obj.margin + obj.colGrowthFrame:GetHeight())

    obj.layoutFrame:SetHeight(obj.groupLayoutHeader:GetHeight() + obj.margin + math.max(obj.leftGroupLayoutFrame:GetHeight(),  obj.rightGroupLayoutFrame:GetHeight()))

    obj.iconFrame = CreateFrame("Frame", nil, obj.marginFrame)
    obj.iconFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.layoutFrame, Addon.FramePoint.BOTTOMLEFT, 0, -obj.margin * 2)
    obj.iconFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.layoutFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -obj.margin * 2)

    obj.iconHeader = Addon.Widget:createSectionHeader("Icon Styling")
    obj.iconHeader:SetParent(obj.iconFrame)
    obj.iconHeader:SetPoint(Addon.FramePoint.TOPLEFT, obj.iconFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.iconHeader:SetPoint(Addon.FramePoint.TOPRIGHT, obj.iconFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    obj.iconHeader:Show()

    obj.leftIconFrame = CreateFrame("Frame", nil, obj.iconFrame)
    obj.leftIconFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.iconHeader, Addon.FramePoint.BOTTOMLEFT, 0, -obj.margin)
    obj.leftIconFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.iconHeader, Addon.FramePoint.TOP, -obj.margin / 2, -obj.margin)

    obj.itemSizeFrame = Addon.Widget:createTextField(
            "Icon Size",
            {
                numericOnly = true,
                min = -5000,
                max = 5000,
                clamp = true,
                text = group.childrenGrid.childSize,
                onEnterPressed = function(val) group:setChildSize(val) end
            }
    )
    obj.itemSizeFrame:SetParent(obj.leftIconFrame)
    obj.itemSizeFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.leftIconFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.itemSizeFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.leftIconFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    obj.itemSizeFrame:Show()

    obj.leftIconFrame:SetHeight(obj.itemSizeFrame:GetHeight())

    obj.rightIconFrame = CreateFrame("Frame", nil, obj.iconFrame)
    obj.rightIconFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.iconHeader, Addon.FramePoint.BOTTOM, obj.margin / 2, -obj.margin)
    obj.rightIconFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.iconHeader, Addon.FramePoint.TOPRIGHT, 0, -obj.margin)

    obj.iconSpacingFrame = Addon.Widget:createTextField(
            "Icon Spacing",
            {
                numericOnly = true,
                min = -5000,
                max = 5000,
                clamp = true,
                text = group.childrenGrid.childSpacing,
                onEnterPressed = function(val) group:setChildSpacing(val) end
            }
    )
    obj.iconSpacingFrame:SetParent(obj.rightIconFrame)
    obj.iconSpacingFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.rightIconFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.iconSpacingFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.rightIconFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    obj.iconSpacingFrame:Show()

    obj.rightIconFrame:SetHeight(obj.iconSpacingFrame:GetHeight())

    obj.iconFrame:SetHeight(obj.iconHeader:GetHeight() + obj.margin + math.max(obj.leftIconFrame:GetHeight(), obj.rightIconFrame:GetHeight()))

    return obj
end

function GroupPanel:delete()
    Addon.ContentPanel.delete(self)

    if self.positionFrameDispose then
        self.positionFrameDispose()
    end
end

Addon.GroupPanel = GroupPanel
return GroupPanel