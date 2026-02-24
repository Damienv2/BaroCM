---@type Addon
local Addon = select(2, ...)

---@class TrinketCollection
---@field trinket1 Trinket
---@field trinket2 Trinket
---@field trinketEventMonitor Frame
local TrinketCollection = {}
TrinketCollection.__index = TrinketCollection

---@return TrinketCollection
function TrinketCollection.default()
    local self = setmetatable({}, TrinketCollection)
    self.trinket1 = Addon.Trinket.default(GetInventoryItemID("player", 13), 13)
    self.trinket2 = Addon.Trinket.default(GetInventoryItemID("player", 14), 14)

    self.trinketEventMonitor = CreateFrame("Frame")
    self.trinketEventMonitor:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self.trinketEventMonitor:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self.trinketEventMonitor:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_EQUIPMENT_CHANGED" then
            self.trinket1 = Addon.Trinket.default(GetInventoryItemID("player", 13), 13)
            self.trinket2 = Addon.Trinket.default(GetInventoryItemID("player", 14), 14)
            self.trinket1:refreshRuntimeState()
            self.trinket2:refreshRuntimeState()
        elseif event == "SPELL_UPDATE_COOLDOWN" then
            self.trinket1:refreshRuntimeState()
            self.trinket2:refreshRuntimeState()
        end
    end)

    return self
end

Addon.TrinketCollection = TrinketCollection
return TrinketCollection