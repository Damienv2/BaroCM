---@type Addon
local Addon = select(2, ...)

---@class Consumable : Item
local Consumable = setmetatable({}, { __index = Addon.Item })
Consumable.__index = Consumable
Consumable.type = Addon.NodeType.CONSUMABLE

---@return Consumable
function Consumable:default()
    ---@type Consumable
    local obj = Addon.Item.default(self)
    obj.name = "New Consumable"

    return obj
end

function Consumable:setItemId(itemId)
    if itemId ~= nil then
        self:startRefreshingRuntimeState()
        self.name = Addon.Utils:getItemNameByItemId(itemId)
    else
        self:stopRefreshingRuntimeState()
        self.name = nil
    end
    self.itemId = itemId

    Addon.EventBus:send("SAVE")
end

function Consumable:refreshRuntimeState()
    if self.itemId == nil then return end

    local texture = C_Item.GetItemIconByID(self.itemId)
    if texture then
        self.frame.icon:SetTexture(texture)
    end

    local startTime, duration, enable = C_Container.GetItemCooldown(self.itemId)
    if startTime and duration and duration > 0 and enable == 1 then
        self.frame.cooldown:SetCooldown(startTime, duration)
        self.frame.icon:SetDesaturated(true)
    else
        self.frame.cooldown:Clear()
        self.frame.icon:SetDesaturated(false)
    end
end

Addon.Consumable = Consumable
return Consumable