---@type Addon
local Addon = select(2, ...)

---@class ItemBindingWatcher
---@field poller Frame
local ItemBindingWatcher = {}
ItemBindingWatcher.__index = ItemBindingWatcher

---@return ItemBindingWatcher
function ItemBindingWatcher.default()
    local self = setmetatable({}, ItemBindingWatcher)
    self.poller = nil

    return self
end

function ItemBindingWatcher:watch()
    -- Loop through all groups
    for _, group in pairs(Addon.inst.groupCollection.groups) do
        -- Loop through all items
        for _, item in pairs(group.itemGrid.itemCollection.items) do
            -- Loop through all CDM Items seeing if any match the groups items
            for _, cdmItem in pairs(Addon.inst.cdmItemCollection.cdmItems) do
                if tostring(item.spellId) == tostring(cdmItem.spellId) and select(1, GetSpecializationInfo(GetSpecialization())) == item.specId then
                    item:bindCdmItem(cdmItem)
                    cdmItem:bind(item)
                end
            end

            -- Check if any trinkets match
            local trinket1 = Addon.inst.trinketCollection.trinket1
            if trinket1:isOnUseTrinket() == true and tostring(item.slotId) == tostring(trinket1.slotId) and select(1, GetSpecializationInfo(GetSpecialization())) == item.specId then
                item:bindTrinket(trinket1)
                trinket1:bind(item)
            end
            local trinket2 = Addon.inst.trinketCollection.trinket2
            if trinket2:isOnUseTrinket() == true and tostring(item.slotId) == tostring(trinket2.slotId) and select(1, GetSpecializationInfo(GetSpecialization())) == item.specId then
                item:bindTrinket(trinket2)
                trinket2:bind(item)
            end
        end
    end
end

function ItemBindingWatcher:startPolling(intervalSeconds)
    if self.poller then return end
    self.poller = CreateFrame("Frame")

    local pollInterval = intervalSeconds or 0.05 -- 20 times/sec

    local pollElapsed = 0
    self.poller:SetScript("OnUpdate", function(_, elapsed)
        pollElapsed = pollElapsed + elapsed
        if pollElapsed < pollInterval then
            return
        end

        pollElapsed = 0
        self:watch()
    end)
end

function ItemBindingWatcher:stopPolling()
    if not self.poller then return end
    self.poller:SetScript("OnUpdate", nil)
    self.poller = nil
end

function ItemBindingWatcher:getItemOptions()
    local options = {}
    local seen = {}

    for _, cdmItem in pairs(Addon.inst.cdmItemCollection.cdmItems) do
        local name = cdmItem.spellName
        if name and not seen[name] then
            seen[name] = true
            table.insert(options, {
                value = cdmItem,
                text = name,
            })
        end
    end

    table.sort(options, function(a, b)
        return a.text < b.text
    end)

    local trinket1 = Addon.inst.trinketCollection.trinket1
    seen[trinket1.slotName] = true
    table.insert(options, {
        value = trinket1,
        text = trinket1.slotName
    })
    local trinket2 = Addon.inst.trinketCollection.trinket2
    seen[trinket2.slotName] = true
    table.insert(options, {
        value = trinket2,
        text = trinket2.slotName
    })

    return options
end

Addon.ItemBindingWatcher = ItemBindingWatcher
return ItemBindingWatcher