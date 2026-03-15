---@type Addon
local Addon = select(2, ...)

---@class LabeledSectionPanel
local LabeledSectionPanel = {}
LabeledSectionPanel.__index = LabeledSectionPanel

---@param parentFrame Frame
---@param label string
---@param anchorFrame Frame?
---@return LabeledSectionPanel
function LabeledSectionPanel:create(parentFrame, label, anchorFrame)
    ---@type LabeledSectionPanel
    local obj = setmetatable({}, self)

    local margin = Addon.Styling.margin

    obj.sectionFrame = CreateFrame("Frame", nil, parentFrame)
    if anchorFrame == nil then
        obj.sectionFrame:SetPoint(Addon.FramePoint.TOPLEFT, parentFrame, Addon.FramePoint.TOPLEFT, 0, 0)
        obj.sectionFrame:SetPoint(Addon.FramePoint.TOPRIGHT, parentFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    else
        obj.sectionFrame:SetPoint(Addon.FramePoint.TOPLEFT, anchorFrame, Addon.FramePoint.BOTTOMLEFT, 0, -margin * 2)
        obj.sectionFrame:SetPoint(Addon.FramePoint.TOPRIGHT, anchorFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -margin * 2)
    end

    obj.sectionHeader = Addon.Widget:createSectionHeader(label)
    obj.sectionHeader:SetParent(obj.sectionFrame)
    obj.sectionHeader:SetPoint(Addon.FramePoint.TOPLEFT, obj.sectionFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.sectionHeader:SetPoint(Addon.FramePoint.TOPRIGHT, obj.sectionFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    obj.sectionHeader:Show()

    obj.sectionFrame:SetHeight(obj.sectionHeader:GetHeight())

    obj.leftSectionFrame = CreateFrame("Frame", nil, obj.sectionFrame)
    obj.leftSectionFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.sectionHeader, Addon.FramePoint.BOTTOMLEFT, 0, -margin)
    obj.leftSectionFrame:SetPoint(Addon.FramePoint.BOTTOMRIGHT, obj.sectionFrame, Addon.FramePoint.BOTTOM, -margin / 2, 0)

    obj.leftSectionFrames = {}
    table.insert(obj.leftSectionFrames,  obj.leftSectionFrame)

    obj.rightSectionFrame = CreateFrame("Frame", nil, obj.sectionFrame)
    obj.rightSectionFrame:SetPoint(Addon.FramePoint.BOTTOMLEFT, obj.sectionFrame, Addon.FramePoint.BOTTOM, margin / 2, -margin)
    obj.rightSectionFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.sectionHeader, Addon.FramePoint.BOTTOMRIGHT, 0, -margin)

    obj.rightSectionFrames = {}
    table.insert(obj.rightSectionFrames,  obj.rightSectionFrame)

    return obj
end

---@param frame Frame
function LabeledSectionPanel:appendToLeftSection(frame)
    self:_appendToSection(self.leftSectionFrames, frame)
end

---@param frame Frame
function LabeledSectionPanel:appendToRightSection(frame)
    self:_appendToSection(self.rightSectionFrames, frame)
end

---@param sectionFrames Frame[]
---@param frame Frame
function LabeledSectionPanel:_appendToSection(sectionFrames, frame)
    local margin = Addon.Styling.margin
    local lastFrame = sectionFrames[#sectionFrames]

    frame:SetParent(self.sectionFrame)
    if #sectionFrames == 1 then
        frame:SetPoint(Addon.FramePoint.TOPLEFT, lastFrame, Addon.FramePoint.TOPLEFT, 0, 0)
        frame:SetPoint(Addon.FramePoint.TOPRIGHT, lastFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    else
        frame:SetPoint(Addon.FramePoint.TOPLEFT, lastFrame, Addon.FramePoint.BOTTOMLEFT, 0, -margin)
        frame:SetPoint(Addon.FramePoint.TOPRIGHT, lastFrame, Addon.FramePoint.BOTTOMRIGHT, 0, -margin)
    end

    table.insert(sectionFrames, frame)
    frame:Show()

    self.leftSectionFrame:SetHeight(self:_getSectionHeight(self.leftSectionFrames))
    self.rightSectionFrame:SetHeight(self:_getSectionHeight(self.rightSectionFrames))
    self.sectionFrame:SetHeight(self.sectionHeader:GetHeight() + margin + math.max(self.leftSectionFrame:GetHeight(), self.rightSectionFrame:GetHeight()))
end

---@param sectionFrames Frame[]
function LabeledSectionPanel:_getSectionHeight(sectionFrames)
    local margin = Addon.Styling.margin
    local sectionHeight = 0
    for i = 2, #sectionFrames do
        sectionHeight = sectionHeight + sectionFrames[i]:GetHeight()
        if i < #sectionFrames then
            sectionHeight = sectionHeight + margin
        end
    end

    return sectionHeight
end

Addon.LabeledSectionPanel = LabeledSectionPanel
return LabeledSectionPanel
