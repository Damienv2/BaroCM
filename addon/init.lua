---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

local calledAddonLoaded = false
local calledPlayerEnteringWorld = false
local function initUi()
    if calledAddonLoaded and calledPlayerEnteringWorld then
        local success, err = pcall(function()
            -- Put your existing logic here
            if not Addon.inst.settingsPanel then
                Addon.inst.settingsPanel = Addon.SettingsPanel:default()
            end
        end)

        if not success then
            error(err)
        end
    end
end
local function validateVersion()
    if not Addon.db.version or Addon.db.version < 200 then
        Addon.inst.root = Addon.Root:default()
        Addon.db.serializedRoot = Addon.inst.root:serialize()
    end
    Addon.db.version = 2203
end
f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Load saved data
        BaroCooldownManagerDB = BaroCooldownManagerDB or {}
        Addon.db = BaroCooldownManagerDB
        Addon.inst = {}

        validateVersion()

        if Addon.db.serializedRoot == nil then
            Addon.inst.root = Addon.Root:default()
        end

        calledAddonLoaded = true
        initUi()
    elseif event == "PLAYER_ENTERING_WORLD" then
        Addon.inst.cdmBinder = Addon.CdmBinder:default()

        Addon.inst.cdmAdapterRegistry = Addon.CdmAdapterRegistry:default()

        if Addon.db.serializedRoot ~= nil then
            Addon.inst.root = Addon.Root.deserialize(Addon.db.serializedRoot)
        end

        -- Register save event
        Addon.EventBus:register("SAVE", function()
            Addon.db.serializedRoot = Addon.inst.root:serialize()
        end)

        calledPlayerEnteringWorld = true
        initUi()

        f:UnregisterEvent("PLAYER_ENTERING_WORLD")
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        Addon.inst.cdmAdapterRegistry:resetAdapters()
        Addon.EventBus:send("BUTTON_REFRESH_REQUESTED")
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
        Addon.inst.settingsPanel:toggleSettings()
    elseif msg == "cdb" then
        BaroCooldownManagerDB = {}
        Addon.db = BaroCooldownManagerDB
        if Addon.inst.root then
            Addon.inst.root:delete()
            Addon.inst.root = Addon.Root:default()
            Addon.db.serializedRoot = Addon.inst.root:serialize()
        end
    elseif msg == "tst1" then
        Addon.Debug:printTable(Addon.inst.cdmAdapterRegistry:getAttachedAdapters())
    elseif msg == "tst2" then
        Addon.Debug:printTable(Addon.inst.cdmBinder:getBoundAdapters())
        print("-----------------------------------")
    elseif msg == "tst3"  then
        Addon.Debug:printTable(Addon.inst.cdmBinder:getBoundCooldowns())
        print("-----------------------------------")
    elseif msg == "tst4"  then
        Addon.Debug:printTable(Addon.inst.root.children[1]:serialize())
        print("-----------------------------------")
    elseif msg == "p" then
        Addon.inst.root.children[1]:refreshChildFrames()
    end

end
print("Welcome to BaroCM! Use /baro to access the options.")