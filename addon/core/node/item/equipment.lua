---@type Addon
local Addon = select(2, ...)

---@class Equipment : Item
---@field slotId number
local Equipment = setmetatable({}, { __index = Addon.Item })
Equipment.__index = Equipment
Equipment.type = Addon.NodeType.EQUIPMENT

---@return Equipment
function Equipment:_construct()
    ---@type Equipment
    local obj = Addon.Item._construct(self)
    obj.name = "New Equipment"

    obj.slotId = nil

    obj.equipmentChangeWatcher = CreateFrame("Frame")
    obj.equipmentChangeWatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    obj.equipmentChangeWatcher:SetScript("OnEvent", function(_, event, slotId, hasItem)
        if obj.slotId == slotId then
            obj:setSlotId(slotId)
            Addon.EventBus:send("BUTTON_REFRESH_REQUESTED")
        end
    end)
    
    return obj
end

function Equipment:serializeProps()
    local props = Addon.Item.serializeProps(self)
    props.slotId = self.slotId
    
    return props
end

function Equipment:deserializeProps(data)
    Addon.Item.deserializeProps(self, data)
    self:setSlotId(data.slotId)
end

---@return boolean
function Equipment:shouldShow()
    local parentShouldShow = Addon.Item.shouldShow(self)

    local shouldShow = self.slotId ~= nil

    return parentShouldShow and shouldShow
end

function Equipment:delete()
    Addon.Item.delete(self)

    self.equipmentChangeWatcher:SetScript("OnEvent", nil)
    self.equipmentChangeWatcher:UnregisterAllEvents()
    self.equipmentChangeWatcher:Hide()
    self.equipmentChangeWatcher:SetParent(nil)
    self.equipmentChangeWatcher = nil
end

function Equipment:setSlotId(slotId)
    if slotId ~= nil then
        self:startRefreshingRuntimeState()
        self.itemId = GetInventoryItemID("player", slotId)
        self.name = Addon.Utils:getItemNameByItemId(self.itemId)
    else
        self:stopRefreshingRuntimeState()
        self.slotId = nil
    end
    self.slotId = slotId
    
    Addon.EventBus:send("SAVE")
end

function Equipment:refreshRuntimeState()
    if self.slotId == nil or self.itemId == nil then return end

    local texture = C_Item.GetItemIconByID(self.itemId)
    if texture then
        self.frame.icon:SetTexture(texture)
    end

    local startTime, duration, enable = GetInventoryItemCooldown("player", self.slotId)
    if startTime and duration and duration > 0 and enable == 1 then
        self.frame.cooldown:SetCooldown(startTime, duration)
        self.frame.icon:SetDesaturated(true)
    else
        self.frame.cooldown:Clear()
        self.frame.icon:SetDesaturated(false)
    end
end

Addon.Equipment = Equipment
return Equipment