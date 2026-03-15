---@type Addon
local Addon = select(2, ...)

---@class NewGroupMemberButton : NavigatorButton
---@field node Node
---@field popupFrame Frame
---@field group Group
local NewGroupMemberButton = setmetatable({}, { __index = Addon.NavigatorButton })
NewGroupMemberButton.__index = NewGroupMemberButton

---@param frameWidth number
---@param node Node
---@return NewGroupMemberButton
function NewGroupMemberButton:create(frameWidth, group)
    ---@type NewGroupMemberButton
    local obj = Addon.NavigatorButton.create(self, frameWidth)

    obj.buttonText:ClearAllPoints()
    obj.buttonText:SetPoint(Addon.FramePoint.CENTER, obj.buttonFrame, Addon.FramePoint.CENTER, 0, 0)
    obj:setButtonText("New Group Member")

    obj.icon:Hide()
    obj.iconBorder:Hide()

    obj.group = group

    return obj
end

function NewGroupMemberButton:handleLeftClick()
    Addon.EventBus:send("NEW_GROUP_MEMBER_BUTTON_CLICKED", self.group)
end

Addon.NewGroupMemberButton = NewGroupMemberButton
return NewGroupMemberButton