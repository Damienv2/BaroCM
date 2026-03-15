---@type Addon
local Addon = select(2, ...)

---@class EquipmentPanel : ContentPanel
local EquipmentPanel = setmetatable({}, { __index = Addon.ContentPanel })
EquipmentPanel.__index = EquipmentPanel

---@param equipment Equipment
---@return EquipmentPanel
function EquipmentPanel:create(equipment, equipmentButton)
    ---@type EquipmentPanel
    local obj = Addon.ContentPanel.create(self)

    obj.slotIdFrame = Addon.Widget:createDropdown(
            "Slot ID",
            {
                options = Addon.EquipmentSlot:getOptions(),
                selectedValue = Addon.EquipmentSlot:getEnumBySlotId(equipment.slotId),
                onSelect = function(val, text)
                    equipment:setSlotId(val)
                    equipmentButton:setButtonIcon(Addon.Utils:getItemTexture(equipment.itemId))
                    equipmentButton:setButtonText(Addon.Utils:getItemNameByItemId(equipment.itemId))
                end
            }
    )
    obj.slotIdFrame:SetParent(obj.marginFrame)
    obj.slotIdFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.marginFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.slotIdFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.marginFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    obj.slotIdFrame:Show()

    return obj
end

Addon.EquipmentPanel = EquipmentPanel
return EquipmentPanel