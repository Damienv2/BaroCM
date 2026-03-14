---@type Addon
local Addon = select(2, ...)

---@class DynamicSizingMixin
---@field parent Node
---@field orientation Orientation
---@field horizontalAlignment HorizontalAlignment?
---@field verticalAlignment VerticalAlignment?
---@field spacing number
local DynamicSizingMixin = {}

---@param parent Node
function DynamicSizingMixin:init(parent)
    self.parent = parent
    self.orientation = Addon.Orientation.VERTICAL
    self.horizontalAlignment = Addon.HorizontalAlignment.CENTER
    self.verticalAlignment = Addon.VerticalAlignment.TOP
    self.spacing = 3

    self:refreshParentPoint()
end

---@return table
function DynamicSizingMixin:serializeDynamicSizingProps()
    return {
        orientation = self.orientation,
        horizontalAlignment = self.horizontalAlignment,
        verticalAlignment = self.verticalAlignment,
        spacing = self.spacing,
    }
end

---@param data table
function DynamicSizingMixin:deserializeDynamicSizingProps(data)
    self.orientation = data.dynamicSizing.orientation
    self.horizontalAlignment = data.dynamicSizing.horizontalAlignment
    self.verticalAlignment = data.dynamicSizing.verticalAlignment
    self.spacing = data.dynamicSizing.spacing

    self:refreshParentPoint()
end

---@param orientation Orientation
function DynamicSizingMixin:setOrientation(orientation)
    if orientation == self.orientation then return end

    self.orientation = orientation

    self:refreshParentPoint()
    self:refresh()

    Addon.EventBus:send("SAVE")
end

---@param horizontalAlignment HorizontalAlignment
function DynamicSizingMixin:setHorizontalAlignment(horizontalAlignment)
    if self.orientation == Addon.Orientation.HORIZONTAL then return end

    self.horizontalAlignment = horizontalAlignment
    self:refresh()

    Addon.EventBus:send("SAVE")
end

---@param verticalAlignment VerticalAlignment
function DynamicSizingMixin:setVerticalAlignment(verticalAlignment)
    if self.orientation == Addon.Orientation.VERTICAL then return end

    self.verticalAlignment = verticalAlignment
    self:refresh()

    Addon.EventBus:send("SAVE")
end

---@param spacing number
function DynamicSizingMixin:setSpacing(spacing)
    self.spacing = spacing
    self:refresh()

    Addon.EventBus:send("SAVE")
end

function DynamicSizingMixin:refresh()
    local primary_size = 0
    local secondary_size = 0
    for i, child in ipairs(self.parent.children) do
        -- Update child anchoring
        if self.orientation == Addon.Orientation.VERTICAL then
            child.frame:ClearAllPoints()
            child.frame:SetPoint(self:_getFramePoint(), self.parent.frame, self:_getFramePoint(), 0, primary_size * -1)
        else
            child.frame:ClearAllPoints()
            child.frame:SetPoint(self:_getFramePoint(), self.parent.frame, self:_getFramePoint(), primary_size, 0)
        end

        -- Calculate the size change
        if self.orientation == Addon.Orientation.VERTICAL then
            primary_size = primary_size + child.frame:GetHeight()
            secondary_size = math.max(secondary_size, child.frame:GetWidth())
        else
            primary_size = primary_size + child.frame:GetWidth()
            secondary_size = math.max(secondary_size, child.frame:GetHeight())
        end

        if i < #self.parent.children then
            primary_size = primary_size + self.spacing
        end
    end

    if self.orientation == Addon.Orientation.VERTICAL then
        self.parent.frame:SetSize(secondary_size, primary_size)
    else
        self.parent.frame:SetSize(primary_size, secondary_size)
    end
end

---@return FramePoint
function DynamicSizingMixin:_getFramePoint()
    local point = nil
    if self.horizontalAlignment == Addon.HorizontalAlignment.LEFT then
        if self.verticalAlignment == Addon.VerticalAlignment.TOP then
            point = Addon.FramePoint.TOPLEFT
        elseif self.verticalAlignment == Addon.VerticalAlignment.CENTER then
            point = Addon.FramePoint.LEFT
        elseif self.verticalAlignment == Addon.VerticalAlignment.BOTTOM then
            point = Addon.FramePoint.BOTTOMLEFT
        end
    elseif self.horizontalAlignment == Addon.HorizontalAlignment.CENTER then
        if self.verticalAlignment == Addon.VerticalAlignment.TOP then
            point = Addon.FramePoint.TOP
        elseif self.verticalAlignment == Addon.VerticalAlignment.CENTER then
            point = Addon.FramePoint.CENTER
        elseif self.verticalAlignment == Addon.VerticalAlignment.BOTTOM then
            point = Addon.FramePoint.BOTTOM
        end
    elseif self.horizontalAlignment == Addon.HorizontalAlignment.RIGHT then
        if self.verticalAlignment == Addon.VerticalAlignment.TOP then
            point = Addon.FramePoint.TOPRIGHT
        elseif self.verticalAlignment == Addon.VerticalAlignment.CENTER then
            point = Addon.FramePoint.RIGHT
        elseif self.verticalAlignment == Addon.VerticalAlignment.BOTTOM then
            point = Addon.FramePoint.BOTTOMRIGHT
        end
    end

    return point
end

function DynamicSizingMixin:refreshParentPoint()
    local parentFrame = UIParent
    if not self.parent:isRoot() then
        parentFrame = self.parent.parent.frame
    end
    if self.orientation == Addon.Orientation.VERTICAL then
        self.verticalAlignment = Addon.VerticalAlignment.TOP

        self.parent.frame:ClearAllPoints()
        self.parent.frame:SetPoint(Addon.FramePoint.TOP, parentFrame, Addon.FramePoint.CENTER, 0, 0)
    else
        self.horizontalAlignment = Addon.HorizontalAlignment.LEFT

        self.parent.frame:ClearAllPoints()
        self.parent.frame:SetPoint(Addon.FramePoint.LEFT, parentFrame, Addon.FramePoint.CENTER, 0, 0)
    end
end

Addon.DynamicSizingMixin = DynamicSizingMixin
return DynamicSizingMixin
