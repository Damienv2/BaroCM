---@type Addon
local Addon = select(2, ...)

---@class NewGroupMemberPanel : ContentPanel
local NewGroupMemberPanel = setmetatable({}, { __index = Addon.ContentPanel })
NewGroupMemberPanel.__index = NewGroupMemberPanel

---@param frameWidth number
---@param parentNode Node
---@return NewGroupMemberPanel
function NewGroupMemberPanel:create(frameWidth, parentNode)
    ---@type NewGroupMemberPanel
    local obj = Addon.ContentPanel.create(self)

    obj.createCooldownButton = Addon.NavigatorButton:create(frameWidth)
    obj.createCooldownButton:setButtonText("Create Cooldown")
    obj.createCooldownButton.buttonFrame:SetParent(obj.frame)
    obj.createCooldownButton.buttonFrame:ClearAllPoints()
    obj.createCooldownButton.buttonFrame:SetPoint(Addon.FramePoint.TOP, obj.frame, Addon.FramePoint.TOP, 0, 0)
    obj.createCooldownButton:setButtonIcon(Addon.Utils.cooldownTexture)
    obj.createCooldownButton.buttonFrame:Show()
    obj.createCooldownButton.handleLeftClick = function(self, ...)
        local newCooldown = Addon.Cooldown:default()
        parentNode:appendChild(newCooldown)
    end

    obj.createEquipmentButton = Addon.NavigatorButton:create(frameWidth)
    obj.createEquipmentButton:setButtonText("Create Equipment")
    obj.createEquipmentButton.buttonFrame:SetParent(obj.frame)
    obj.createEquipmentButton.buttonFrame:ClearAllPoints()
    obj.createEquipmentButton.buttonFrame:SetPoint(Addon.FramePoint.TOP, obj.createCooldownButton.buttonFrame, Addon.FramePoint.BOTTOM, 0, 0)
    obj.createEquipmentButton:setButtonIcon(Addon.Utils.equipmentTexture)
    obj.createEquipmentButton.buttonFrame:Show()
    obj.createEquipmentButton.handleLeftClick = function(self, ...)
        local newEquipment = Addon.Equipment:default()
        parentNode:appendChild(newEquipment)
    end

    obj.createConsumableButton = Addon.NavigatorButton:create(frameWidth)
    obj.createConsumableButton:setButtonText("Create Consumable")
    obj.createConsumableButton.buttonFrame:SetParent(obj.frame)
    obj.createConsumableButton.buttonFrame:ClearAllPoints()
    obj.createConsumableButton.buttonFrame:SetPoint(Addon.FramePoint.TOP, obj.createEquipmentButton.buttonFrame, Addon.FramePoint.BOTTOM, 0, 0)
    obj.createConsumableButton:setButtonIcon(Addon.Utils.consumableTexture)
    obj.createConsumableButton.buttonFrame:Show()
    obj.createConsumableButton.handleLeftClick = function(self, ...)
        local newConsumable = Addon.Consumable:default()
        parentNode:appendChild(newConsumable)
    end

    return obj
end

Addon.NewGroupMemberPanel = NewGroupMemberPanel
return NewGroupMemberPanel