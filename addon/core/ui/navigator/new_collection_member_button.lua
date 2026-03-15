---@type Addon
local Addon = select(2, ...)

---@class NewCollectionMemberButton : NavigatorButton
---@field collection Collection
local NewCollectionMemberButton = setmetatable({}, { __index = Addon.NavigatorButton })
NewCollectionMemberButton.__index = NewCollectionMemberButton

---@param frameWidth number
---@param collection Collection
---@return NewCollectionMemberButton
function NewCollectionMemberButton:create(frameWidth, collection)
    ---@type NewCollectionMemberButton
    local obj = Addon.NavigatorButton.create(self, frameWidth)

    obj.buttonText:ClearAllPoints()
    obj.buttonText:SetPoint(Addon.FramePoint.CENTER, obj.buttonFrame, Addon.FramePoint.CENTER, 0, 0)
    obj:setButtonText("New Collection Member")

    obj.icon:Hide()
    obj.iconBorder:Hide()

    obj.collection = collection

    return obj
end

function NewCollectionMemberButton:handleLeftClick()
    Addon.EventBus:send("NEW_COLLECTION_MEMBER_BUTTON_CLICKED", self.collection)
end

Addon.NewCollectionMemberButton = NewCollectionMemberButton
return NewCollectionMemberButton