---@type Addon
local Addon = select(2, ...)

---@class NavigatorPanel
---@field frame Frame
---@field contentFrame Frame
---@field buttonWidth number
---@field nodeButtons NodeButton[]
---@field otherButtons NavigatorButton[]
local NavigatorPanel = {}
NavigatorPanel.__index = NavigatorPanel

---@return NavigatorPanel
function NavigatorPanel:create(frameWidth,  frameHeight)
    local obj = setmetatable({}, self)

    obj.frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    obj.frame:Hide()
    obj.frame:SetSize(frameWidth, frameHeight)
    obj.frame:SetBackdrop({
        bgFile = Addon.Styling.background.texture2,
        edgeFile = Addon.Styling.background.borderTexture2,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    obj.frame:SetBackdropColor(unpack(Addon.Styling.background.color1))
    obj.frame:SetBackdropBorderColor(unpack(Addon.Styling.background.borderColor1))

    obj.contentFrame = Addon.Widget:createScrollBar(obj.frame)

    obj.buttonWidth = frameWidth - 20
    obj.nodeButtons = {}
    obj.otherButtons = {}
    obj:refreshButtons()

    Addon.EventBus:register("NODE_DELETED", function(node)
        obj:refreshButtons()
    end)
    Addon.EventBus:register("NODE_APPENDED", function(parentNode, childNode)
        obj:refreshButtons()
    end)
    Addon.EventBus:register("NODE_BUTTON_TOGGLED", function(parentNode, childNode)
        obj:refreshButtons()
    end)
    Addon.EventBus:register("BUTTON_REFRESH_REQUESTED", function()
        obj:refreshButtons()
    end)

    return obj
end

function NavigatorPanel:refreshButtons()
    for _, nodeButton in ipairs(self.nodeButtons) do
        nodeButton:delete()
    end
    self.nodeButtons = {}

    for _, otherButton in ipairs(self.otherButtons) do
        otherButton:delete()
    end
    self.otherButtons = {}

    self.nodeButtons = self:_nodesToButtons(self.buttonWidth, Addon.inst.root.children)
    local lastBtn = self:refreshButtonAnchors(self.nodeButtons)

    local newCollectionMemberButton = Addon.NewCollectionMemberButton:create(self.buttonWidth, Addon.inst.root)
    newCollectionMemberButton.buttonFrame:SetParent(self.contentFrame)
    newCollectionMemberButton.buttonFrame:Show()
    newCollectionMemberButton.buttonFrame:ClearAllPoints()
    if lastBtn == nil then
        newCollectionMemberButton.buttonFrame:SetPoint(Addon.FramePoint.TOPLEFT, self.contentFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    else
        newCollectionMemberButton.buttonFrame:SetPoint(Addon.FramePoint.TOPRIGHT, lastBtn.buttonFrame, Addon.FramePoint.BOTTOMRIGHT, 0, 0)
    end
    table.insert(self.otherButtons, newCollectionMemberButton)
end

---@param nodeButtons NodeButton[]
---@param lastBtn NavigatorButton?
function NavigatorPanel:refreshButtonAnchors(nodeButtons, lastBtn)
    -- Position the Group Buttons
    for _, nodeButton in pairs(nodeButtons) do
        nodeButton.buttonFrame:Show()
        nodeButton.buttonFrame:ClearAllPoints()

        local offsetX = nodeButton.level * 20

        if lastBtn == nil then
            nodeButton.buttonFrame:SetPoint(Addon.FramePoint.TOPLEFT, self.contentFrame, Addon.FramePoint.TOPLEFT, 0, 0)
        else
            nodeButton.buttonFrame:SetPoint(Addon.FramePoint.TOP, lastBtn.buttonFrame, Addon.FramePoint.BOTTOM, 0, 0)
            nodeButton.buttonFrame:SetPoint(Addon.FramePoint.LEFT, self.contentFrame, Addon.FramePoint.LEFT, offsetX, 0)
        end
        lastBtn = nodeButton

        if nodeButton.node.isExpanded == true then
            local childOffsetX = (nodeButton.level + 1) * 20

            if #nodeButton.children > 0 then
                lastBtn = self:refreshButtonAnchors(nodeButton.children, lastBtn)
            end

            local createButton = nil
            if nodeButton.node.type == Addon.NodeType.COLLECTION then
                createButton = Addon.NewCollectionMemberButton:create(self.contentFrame:GetWidth() - childOffsetX, nodeButton.node)
            elseif nodeButton.node.type == Addon.NodeType.GROUP then
                createButton = Addon.NewGroupMemberButton:create(self.contentFrame:GetWidth() - childOffsetX, nodeButton.node)
            end
            createButton.buttonFrame:SetParent(self.contentFrame)
            createButton.buttonFrame:Show()
            createButton:setLevel(nodeButton.level + 1)
            createButton.buttonFrame:ClearAllPoints()
            createButton.buttonFrame:SetPoint(Addon.FramePoint.TOP, lastBtn.buttonFrame, Addon.FramePoint.BOTTOM, 0, 0)
            createButton.buttonFrame:SetPoint(Addon.FramePoint.LEFT, self.contentFrame, Addon.FramePoint.LEFT, childOffsetX, 0)
            table.insert(self.otherButtons, createButton)

            lastBtn = createButton
        end
    end

    return lastBtn
end

---@param width number
---@param nodes Node[]
---@param level number?
function NavigatorPanel:_nodesToButtons(width, nodes, level)
    if nodes == nil or #nodes == 0 then return {} end
    if level == nil then level = 0 end

    local nodeButtons = {}

    for _, node in ipairs(nodes) do
        if node.type ~= Addon.NodeType.COOLDOWN
                and node.type ~= Addon.NodeType.ITEM
                and node.type ~= Addon.NodeType.CONSUMABLE
                or (node.specId and node.specId == select(1, GetSpecializationInfo(GetSpecialization()))) then
            local actualWidth = width - (20 * level)
            local nodeButton = Addon.NodeButton:create(actualWidth, node)
            nodeButton:setLevel(level)
            nodeButton.buttonFrame:SetParent(self.contentFrame)

            if #node.children > 0 then
                nodeButton.children = self:_nodesToButtons(width, node.children, level + 1)
            end

            table.insert(nodeButtons, nodeButton)
        end
    end

    return nodeButtons
end

Addon.NavigatorPanel = NavigatorPanel
return NavigatorPanel