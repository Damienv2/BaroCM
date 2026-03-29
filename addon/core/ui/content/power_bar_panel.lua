---@type Addon
local Addon = select(2, ...)

---@class PowerBarPanel : ContentPanel
local PowerBarPanel = setmetatable({}, { __index = Addon.ContentPanel })
PowerBarPanel.__index = PowerBarPanel

---@param powerBar PowerBar
---@return PowerBarPanel
function PowerBarPanel:create(powerBar, powerBarButton)
    ---@type PowerBarPanel
    local obj = Addon.ContentPanel.create(self)

    obj.movableConfigPanel, obj.movableConfigPanelDispose = Addon.MovableMixinConfigPanel.getFrame(obj.marginFrame, powerBar.movable)

    obj.powerSelectionSection = Addon.LabeledSectionPanel:create(obj.marginFrame, "Power Settings", obj.movableConfigPanel)
    obj.powerSelectionSection:appendToLeftSection(
        Addon.Widget:createDropdown(
            "Power Bar Type",
            {
                options = Addon.PowerBarType:getOptions(),
                selectedValue = powerBar.powerBarType,
                onSelect = function(val, text)
                    local name = text .. " Power Bar"
                    powerBar:setPowerBarType(val)
                    powerBar:setName(name)
                    powerBarButton:setButtonIcon(Addon.Utils.progBarTexture)
                    powerBarButton:setButtonText(name)
                end
            }
        )
    )

    obj.sizeConfigSection = Addon.LabeledSectionPanel:create(obj.marginFrame, "Appearance Settings", obj.powerSelectionSection.sectionFrame)
    obj.sizeConfigSection:appendToLeftSection(
        Addon.Widget:createTextField(
            "Width",
            {
                numericOnly = true,
                min = 0,
                max = 5000,
                clamp = true,
                text = powerBar.width,
                onEnterPressed = function(val) powerBar:setWidth(val) end
            }
        )
    )
    obj.sizeConfigSection:appendToRightSection(
        Addon.Widget:createTextField(
            "Height",
            {
                numericOnly = true,
                min = 0,
                max = 5000,
                clamp = true,
                text = powerBar.height,
                onEnterPressed = function(val) powerBar:setHeight(val) end
            }
        )
    )

    return obj
end

function PowerBarPanel:delete()
    Addon.ContentPanel.delete(self)

    if self.movableConfigPanelDispose then
        self.movableConfigPanelDispose()
    end
end

Addon.PowerBarPanel = PowerBarPanel
return PowerBarPanel