---@type Addon
local Addon = select(2, ...)

---@class ConsumablePanel : ContentPanel
local ConsumablePanel = setmetatable({}, { __index = Addon.ContentPanel })
ConsumablePanel.__index = ConsumablePanel

---@param equipment Equipment
---@return ConsumablePanel
function ConsumablePanel:create(consumable, consumableButton)
    ---@type ConsumablePanel
    local obj = Addon.ContentPanel.create(self)

    obj.itemIdFrame = Addon.Widget:createTextField(
            "Item ID",
            {
                numericOnly = true,
                min = 0,
                max = 9999999,
                clamp = true,
                text = consumable.itemId,
                onEnterPressed = function(val)
                    consumable:setItemId(val)
                    consumableButton:setButtonIcon(Addon.Utils:getItemTexture(consumable.itemId))
                    consumableButton:setButtonText(Addon.Utils:getItemNameByItemId(consumable.itemId))
                end
            }
    )
    obj.itemIdFrame:SetParent(obj.marginFrame)
    obj.itemIdFrame:SetPoint(Addon.FramePoint.TOPLEFT, obj.marginFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    obj.itemIdFrame:SetPoint(Addon.FramePoint.TOPRIGHT, obj.marginFrame, Addon.FramePoint.TOPRIGHT, 0, 0)
    obj.itemIdFrame:Show()

    return obj
end

Addon.ConsumablePanel = ConsumablePanel
return ConsumablePanel