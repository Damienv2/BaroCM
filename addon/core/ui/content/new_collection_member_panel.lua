---@type Addon
local Addon = select(2, ...)

---@class NewCollectionMemberPanel : ContentPanel
local NewCollectionMemberPanel = setmetatable({}, { __index = Addon.ContentPanel })
NewCollectionMemberPanel.__index = NewCollectionMemberPanel

---@param frameWidth number
---@param parentNode Node
---@return NewCollectionMemberPanel
function NewCollectionMemberPanel:create(frameWidth, parentNode)
    ---@type NewCollectionMemberPanel
    local obj = Addon.ContentPanel.create(self)

    obj.createCollectionButton = Addon.NavigatorButton:create(frameWidth)
    obj.createCollectionButton:setButtonText("Create Collection")
    obj.createCollectionButton.buttonFrame:SetParent(obj.frame)
    obj.createCollectionButton.buttonFrame:ClearAllPoints()
    obj.createCollectionButton.buttonFrame:SetPoint(Addon.FramePoint.TOP, obj.frame, Addon.FramePoint.TOP, 0, 0)
    obj.createCollectionButton:setButtonIcon(Addon.Utils.collectionTexture)
    obj.createCollectionButton.buttonFrame:Show()
    obj.createCollectionButton.handleLeftClick = function(self, ...)
        local newCollection = Addon.Collection:default()
        parentNode:appendChild(newCollection)
    end

    obj.createGroupButton = Addon.NavigatorButton:create(frameWidth)
    obj.createGroupButton:setButtonText("Create Group")
    obj.createGroupButton.buttonFrame:SetParent(obj.frame)
    obj.createGroupButton.buttonFrame:ClearAllPoints()
    obj.createGroupButton.buttonFrame:SetPoint(Addon.FramePoint.TOP, obj.createCollectionButton.buttonFrame, Addon.FramePoint.BOTTOM, 0, 0)
    obj.createGroupButton:setButtonIcon(Addon.Utils.groupTexture)
    obj.createGroupButton.buttonFrame:Show()
    obj.createGroupButton.handleLeftClick = function(self, ...)
        local newGroup = Addon.Group:default()
        parentNode:appendChild(newGroup)
    end

    obj.createPowerBarButton = Addon.NavigatorButton:create(frameWidth)
    obj.createPowerBarButton:setButtonText("Create Progress Bar")
    obj.createPowerBarButton.buttonFrame:SetParent(obj.frame)
    obj.createPowerBarButton.buttonFrame:ClearAllPoints()
    obj.createPowerBarButton.buttonFrame:SetPoint(Addon.FramePoint.TOP, obj.createGroupButton.buttonFrame, Addon.FramePoint.BOTTOM, 0, 0)
    obj.createPowerBarButton:setButtonIcon(Addon.Utils.progBarTexture)
    obj.createPowerBarButton.buttonFrame:Show()
    obj.createPowerBarButton.handleLeftClick = function(self, ...)
        local newPowerBar = Addon.PowerBar:default()
        parentNode:appendChild(newPowerBar)
    end

    return obj
end

Addon.NewCollectionMemberPanel = NewCollectionMemberPanel
return NewCollectionMemberPanel