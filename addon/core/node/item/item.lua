---@type Addon
local Addon = select(2, ...)

---@class Item : GroupMemberNode
---@field itemId number
---@field refreshRuntimeStateTicker Frame
local Item = setmetatable({}, { __index = Addon.GroupMemberNode })
Item.__index = Item
Item.type = Addon.NodeType.ITEM

---@return Item
function Item:default()
    ---@type Item
    local obj = Addon.GroupMemberNode.default(self)
    obj.name = "New Item"

    obj.itemId = nil
    obj.refreshRuntimeStateTicker = nil

    -- ARTWORK: icon
    local icon = obj.frame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    obj.frame.icon = icon

    -- ARTWORK: mask that clips icon
    local mask = obj.frame:CreateMaskTexture(nil, "ARTWORK")
    mask:SetAllPoints()
    mask:SetAtlas("UI-HUD-CoolDownManager-Mask")
    icon:AddMaskTexture(mask)
    obj.frame.iconMask = mask

    -- OVERLAY: decorative border/overlay
    local overlay = obj.frame:CreateTexture(nil, "OVERLAY")
    overlay:SetAtlas("UI-HUD-CoolDownManager-IconOverlay", false)
    overlay:SetPoint(Addon.FramePoint.TOPLEFT, -8, 7)
    overlay:SetPoint(Addon.FramePoint.BOTTOMRIGHT, 8, -7)
    obj.frame.overlay = overlay

    -- Cooldown frame with Blizzard swipe/edge textures
    local cd = CreateFrame("Cooldown", nil, obj.frame, "CooldownFrameTemplate")
    cd:SetAllPoints()
    cd:SetSwipeTexture("Interface\\HUD\\UI-HUD-CoolDownManager-Icon-Swipe")
    cd:SetEdgeTexture("Interface\\Cooldown\\UI-HUD-ActionBar-SecondaryCooldown")
    cd:SetCountdownFont("NumberFontNormal")
    cd:SetDrawEdge(false)
    obj.frame.cooldown = cd

    return obj
end

function Item:serializeProps()
    local props = Addon.GroupMemberNode.serializeProps(self)
    props.itemId = self.itemId

    return props
end

function Item:deserializeProps(data)
    Addon.GroupMemberNode.deserializeProps(self, data)
    self:setItemId(data.itemId)
end

function Item:afterSetParent()
    local cooldownFontString = self.frame.cooldown:GetCountdownFontString()
    if cooldownFontString then
        local fontObjName = cooldownFontString:GetFontObject():GetName()
        Addon.Utils:setFontSize(cooldownFontString, fontObjName, Addon.Styling:getCooldownFontSize(self.parent.childrenGrid.childSize))
    end
end

---@param itemId number
function Item:setItemId(itemId)
    self.itemId = itemId
end

---@return boolean
function Item:shouldShow()
    local parentShouldShow = Addon.GroupMemberNode.shouldShow(self)

    local shouldShow = self.itemId ~= nil

    return parentShouldShow and shouldShow
end

function Item:startRefreshingRuntimeState()
    if self.refreshRuntimeStateTicker then return end

    self.refreshRuntimeStateTicker = CreateFrame("Frame")
    self.refreshRuntimeStateTicker:SetScript("OnUpdate", function(_, elapsed)
        self:refreshRuntimeState()
    end)
end

function Item:refreshRuntimeState()

end

function Item:stopRefreshingRuntimeState()
    if not self.refreshRuntimeStateTicker then return end

    self.refreshRuntimeStateTicker:SetScript("OnUpdate", nil)
    self.refreshRuntimeStateTicker = nil
end

Addon.Item = Item
return Item