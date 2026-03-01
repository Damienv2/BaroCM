---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("COOLDOWN_VIEWER_DATA_LOADED")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

f:RegisterEvent("CINEMATIC_START")
f:RegisterEvent("CINEMATIC_STOP")
f:RegisterEvent("PLAY_MOVIE")
f:RegisterEvent("STOP_MOVIE")

f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        BaroCooldownManagerDB = BaroCooldownManagerDB or {}
        Addon.db = BaroCooldownManagerDB
        Addon.inst = {}
        Addon.inst.isCinematicPlaying = false
    elseif event == "COOLDOWN_VIEWER_DATA_LOADED" then
        if Addon.db.serializedGroupCollection == nil then
            Addon.inst.groupCollection = Addon.GroupCollection.default()
        else
            Addon.inst.groupCollection = Addon.GroupCollection.deserialize(Addon.db.serializedGroupCollection)
        end

        Addon.inst.trinketCollection = Addon.TrinketCollection.default()

        Addon.inst.cdmItemCollection = Addon.CdmItemCollection.default()
        Addon.inst.cdmItemCollection:startPolling(0.0)

        Addon.inst.itemBindingWatcher = Addon.ItemBindingWatcher.default()
        Addon.inst.itemBindingWatcher:startPolling(0.0)

        Addon.inst.optionsPanel = Addon.OptionsPanel.default()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        Addon.inst.cdmItemCollection:stopPolling()
        Addon.inst.itemBindingWatcher:stopPolling()

        for _, group in pairs(Addon.inst.groupCollection.groups) do
            -- Loop through all items
            for _, item in pairs(group.itemGrid.itemCollection.items) do
                item:unbind()
            end
        end
        Addon.inst.optionsPanel.navigatorPanel:refreshGroupBtns()

        Addon.inst.cdmItemCollection = Addon.CdmItemCollection.default()
        Addon.inst.cdmItemCollection:startPolling(0.0)
        Addon.inst.itemBindingWatcher:startPolling(0.0)
    elseif event == "CINEMATIC_START" or event == "PLAY_MOVIE" then
        Addon.inst.isCinematicPlaying = true
        Addon.inst.groupCollection:hide()
    elseif event == "CINEMATIC_STOP" or event == "STOP_MOVIE" then
        Addon.inst.isCinematicPlaying = false
        Addon.inst.groupCollection:show()
    end
end)

SLASH_OPENCDM1 = "/cdm"
SlashCmdList.OPENCDM = function()
    -- Ensure Blizzard CDM addon is loaded
    if not CooldownViewerSettings then
        if C_AddOns and C_AddOns.LoadAddOn then
            C_AddOns.LoadAddOn("Blizzard_CooldownViewer")
        else
            LoadAddOn("Blizzard_CooldownViewer")
        end
    end

    if CooldownViewerSettings and CooldownViewerSettings.TogglePanel then
        CooldownViewerSettings:TogglePanel()
    else
        print("Cooldown Viewer settings UI is not available.")
    end
end

SLASH_BAROCOOLDOWNMANAGER1 = "/baro"
SLASH_BAROCOOLDOWNMANAGER2 = "/barocm"
SlashCmdList.BAROCOOLDOWNMANAGER = function(msg)
    msg = (msg or ""):lower()

    if msg == "" then
        Addon.inst.optionsPanel:toggleOptionsPanel()
    elseif msg == "cdb" then
        BaroCooldownManagerDB = {}
        Addon.db = BaroCooldownManagerDB
        Addon.inst.groupCollection = Addon.GroupCollection.default()
    elseif msg == "tst" then
        Addon.inst.groupCollection:hide()
    end

end
print("Welcome to BaroCM! Use /baro to access the options.")