---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)
---@Type StyleVariables
local style = Addon.StyleVariables

---@class NavigatorPanel
---@field parentOptionsPanel OptionsPanel
---@field frame Frame
---@field frameWidth number
---@field frameHeight number
---@field scrollContentFrame Frame
---@field groupBtns GroupBtn[]
---@field createGroupBtn Frame
---@field selectedBtnFrame Frame
local NavigatorPanel = {}
NavigatorPanel.__index = NavigatorPanel

---@param parentOptionsPanel OptionsPanel
---@param frameWidth number
---@param frameHeight number
---@return NavigatorPanel
function NavigatorPanel.create(parentOptionsPanel, frameWidth, frameHeight)
    local self = setmetatable({}, NavigatorPanel)
    self.parentOptionsPanel = parentOptionsPanel

    self.frame = CreateFrame("Frame", nil, self.parentOptionsPanel.frame, "BackdropTemplate")
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight

    self.scrollContentFrame = nil
    self.groupBtns = {}
    self.createGroupBtn = nil
    self.selectedBtnFrame = nil

    self:initializeFrame()

    return self
end

function NavigatorPanel:initializeFrame()
    self.frame:SetSize(self.frameWidth, self.frameHeight)
    self.frame:SetBackdrop({
        bgFile = style.innerPanel.backgroundFile,
        edgeFile = style.innerPanel.borderFile,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    self.frame:SetBackdropColor(unpack(style.backgroundColor))
    self.frame:SetBackdropBorderColor(unpack(style.borderColor))

    self.scrollContentFrame = Addon.Widgets:createScrollBar(self.frame)

    -- Initialize the Group buttons
    for _, group in pairs(Addon.inst.groupCollection.groups) do
        local groupBtn = Addon.GroupBtn.create(self, group)
        table.insert(self.groupBtns, groupBtn)
    end

    -- Initialize the Create Group Button
    self.createGroupBtn = Addon.Widgets:createRectBtn(
            self.scrollContentFrame,
            self.scrollContentFrame:GetWidth(),
            math.floor(self.scrollContentFrame:GetWidth() / 4.5),
            nil,
            "Create Group"
    )
    self.createGroupBtn:SetScript("OnClick", function()
        local group = Addon.inst.groupCollection:createGroup()
        local groupBtn = Addon.GroupBtn.create(self, group)
        table.insert(self.groupBtns, groupBtn)

        self:applyBtnPositions()
        self:setSelectedBtnFrame(groupBtn.frame)
        Addon.inst.optionsPanel.propertiesPanel:setGroupPropertiesPanel(group)
    end)

    self:applyBtnPositions()
end

function NavigatorPanel:applyBtnPositions()
    local lastBtn = nil

    -- Position the Group Buttons
    for _, groupBtn in pairs(self.groupBtns) do
        groupBtn.frame:ClearAllPoints()
        if lastBtn == nil then
            groupBtn.frame:SetPoint(Addon.FramePoint.TOPRIGHT, self.scrollContentFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
        else
            groupBtn.frame:SetPoint(Addon.FramePoint.TOPRIGHT, lastBtn.frame, Addon.FramePoint.BOTTOMRIGHT, 0, 0)
        end
        lastBtn = groupBtn

        if groupBtn.isExpanded == true then
            for _, itemBtn in pairs(groupBtn.itemBtns) do
                itemBtn.frame:ClearAllPoints()
                itemBtn.frame:SetPoint(Addon.FramePoint.TOPRIGHT, lastBtn.frame, Addon.FramePoint.BOTTOMRIGHT, 0, 0)
                lastBtn = itemBtn
            end
        end
    end

    -- Position the Create Group Button
    self.createGroupBtn:ClearAllPoints()
    if lastBtn == nil then
        self.createGroupBtn:SetPoint(Addon.FramePoint.TOPRIGHT, self.scrollContentFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    else
        self.createGroupBtn:SetPoint(Addon.FramePoint.TOPRIGHT, lastBtn.frame, Addon.FramePoint.BOTTOMRIGHT, 0, 0)
    end
end

---@param groupBtnToDelete GroupBtn
function NavigatorPanel:deleteGroupBtn(groupBtnToDelete)
    for idx, groupBtn in ipairs(self.groupBtns) do
        if groupBtn.group.id == groupBtnToDelete.group.id then
            table.remove(self.groupBtns, idx)
            groupBtn:delete()
            break
        end
    end

    self:applyBtnPositions()
end

function NavigatorPanel:setSelectedBtnFrame(frame)
    if self.frame ~= nil then
        self.frame:SetBackdropBorderColor(unpack(style.borderColor))
    end

    self.frame = frame
    self.frame:SetBackdropBorderColor(unpack(style.highlightBorderColor))
end

function NavigatorPanel:refreshGroupBtns()
    for _, groupBtn in ipairs(self.groupBtns) do
        groupBtn:setIsExpanded(groupBtn.isExpanded)
    end
end

Addon.NavigatorPanel = NavigatorPanel
return NavigatorPanel