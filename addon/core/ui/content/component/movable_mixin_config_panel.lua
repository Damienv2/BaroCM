---@type Addon
local Addon = select(2, ...)

---@class MovableMixinConfigPanel
local MovableMixinConfigPanel = {}

---@param parentFrame Frame
---@param movable MovableMixin
---@param background BackgroundMixin?
---@param anchorFrame Frame?
---@return Frame
function MovableMixinConfigPanel.getFrame(parentFrame, movable, background, anchorFrame)
    local margin = Addon.Styling.margin

    local positionFrame = CreateFrame("Frame", nil, parentFrame)
    if anchorFrame == nil then
        positionFrame:SetPoint(Addon.FramePoint.TOPLEFT, parentFrame, Addon.FramePoint.TOPLEFT, 0, 0)
        positionFrame:SetPoint(Addon.FramePoint.TOPRIGHT, parentFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    else
        positionFrame:SetPoint(Addon.FramePoint.TOPLEFT, anchorFrame, Addon.FramePoint.BOTTOMLEFT, 0, -margin * 2)
        positionFrame:SetPoint(Addon.FramePoint.TOPRIGHT, anchorFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -margin * 2)
    end

    local groupPositionHeader = Addon.Widget:createSectionHeader("Position")
    groupPositionHeader:SetParent(positionFrame)
    groupPositionHeader:SetPoint(Addon.FramePoint.TOPLEFT, positionFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    groupPositionHeader:SetPoint(Addon.FramePoint.TOPRIGHT, positionFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    groupPositionHeader:Show()

    local leftGroupPositionFrame = CreateFrame("Frame", nil, positionFrame)
    leftGroupPositionFrame:SetPoint(Addon.FramePoint.TOPLEFT, groupPositionHeader, Addon.FramePoint.BOTTOMLEFT, 0, -margin)
    leftGroupPositionFrame:SetPoint(Addon.FramePoint.TOPRIGHT, groupPositionHeader, Addon.FramePoint.TOP, -margin / 2, -margin)

    local offsetXFrame, offsetXBox = Addon.Widget:createTextField(
            "X-Offset",
            {
                numericOnly = true,
                min = -5000,
                max = 5000,
                clamp = true,
                text = movable.offsetX,
                onEnterPressed = function(val) movable:setOffsetX(val) end
            }
    )
    offsetXFrame:SetParent(leftGroupPositionFrame)
    offsetXFrame:SetPoint(Addon.FramePoint.TOPLEFT, leftGroupPositionFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    offsetXFrame:SetPoint(Addon.FramePoint.TOPRIGHT, leftGroupPositionFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    offsetXFrame:Show()
    Addon.EventBus:register("MOVABLE_MOVED", function(movedNode)
        if movedNode == movable.parent then
            offsetXBox:SetText(movable.offsetX)
        end
    end)

    local anchorPointFrame = Addon.Widget:createDropdown(
            "Anchor Point",
            {
                options = Addon.FramePoint:getOptions(),
                selectedValue = movable.point,
                onSelect = function(val, text) movable:setPoint(val) end
            }
    )
    anchorPointFrame:SetParent(leftGroupPositionFrame)
    anchorPointFrame:SetPoint(Addon.FramePoint.TOPLEFT, offsetXFrame, Addon.FramePoint.BOTTOMLEFT, 0, -margin)
    anchorPointFrame:SetPoint(Addon.FramePoint.TOPRIGHT, offsetXFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -margin)
    anchorPointFrame:Show()

    leftGroupPositionFrame:SetHeight(offsetXFrame:GetHeight() + margin + anchorPointFrame:GetHeight())

    local rightGroupPositionFrame = CreateFrame("Frame", nil, positionFrame)
    rightGroupPositionFrame:SetPoint(Addon.FramePoint.TOPLEFT, groupPositionHeader, Addon.FramePoint.BOTTOM, margin / 2, -margin)
    rightGroupPositionFrame:SetPoint(Addon.FramePoint.TOPRIGHT, groupPositionHeader, Addon.FramePoint.TOPRIGHT, 0, -margin)

    local offsetYFrame, offsetYBox = Addon.Widget:createTextField(
            "Y-Offset",
            {
                numericOnly = true,
                min = -5000,
                max = 5000,
                clamp = true,
                text = movable.offsetY,
                onEnterPressed = function(val) movable:setOffsetY(val) end
            }
    )
    offsetYFrame:SetParent(rightGroupPositionFrame)
    offsetYFrame:SetPoint(Addon.FramePoint.TOPLEFT, rightGroupPositionFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    offsetYFrame:SetPoint(Addon.FramePoint.TOPRIGHT, rightGroupPositionFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    offsetYFrame:Show()
    Addon.EventBus:register("MOVABLE_MOVED", function(movedNode)
        if movedNode == movable.parent then
            offsetYBox:SetText(movable.offsetY)
        end
    end)

    local lockAnchor = offsetYFrame
    local rightHeight = offsetYFrame:GetHeight()
    if background ~= nil then
        local showBackgroundFrame = Addon.Widget:createCheckbox(
            "Show Background",
            {
                checked = background.showBackground,
                tooltip = "Toggle the visibility of the groups background.",
                onChange = function(checked) background:setShowBackground(checked) end
            }
        )
        showBackgroundFrame:SetParent(rightGroupPositionFrame)
        showBackgroundFrame:SetPoint(Addon.FramePoint.TOPLEFT, offsetYFrame, Addon.FramePoint.BOTTOMLEFT, 0, -margin)
        showBackgroundFrame:SetPoint(Addon.FramePoint.TOPRIGHT, offsetYFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -margin)
        showBackgroundFrame:Show()

        lockAnchor = showBackgroundFrame
        rightHeight = rightHeight + margin + showBackgroundFrame:GetHeight()
    end

    local lockedFrame = Addon.Widget:createCheckbox(
            "Locked",
            {
                checked = movable.isLocked,
                tooltip = "Toggle Group movement.",
                onChange = function(checked) movable:setIsLocked(checked) end
            }
    )
    lockedFrame:SetParent(rightGroupPositionFrame)
    lockedFrame:SetPoint(Addon.FramePoint.TOPLEFT, lockAnchor, Addon.FramePoint.BOTTOMLEFT, 0, -margin)
    lockedFrame:SetPoint(Addon.FramePoint.TOPRIGHT, lockAnchor, Addon.FramePoint.BOTTOMRIGHT, 0, -margin)
    lockedFrame:Show()

    rightGroupPositionFrame:SetHeight(rightHeight + margin + lockedFrame:GetHeight())

    positionFrame:SetHeight(groupPositionHeader:GetHeight() + math.max(leftGroupPositionFrame:GetHeight(), rightGroupPositionFrame:GetHeight()))

    return positionFrame
end

Addon.MovableMixinConfigPanel = MovableMixinConfigPanel
return MovableMixinConfigPanel
