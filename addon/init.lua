---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        BaroCooldownManagerDB = BaroCooldownManagerDB or {}
        Addon.db = BaroCooldownManagerDB
        Addon.inst = {}
        if Addon.db.serializedRoot == nil then
            Addon.inst.root = Addon.Node:new(nil)
        else
            Addon.inst.root = Addon.Node:deserialize(Addon.db.serializedRoot, nil)
        end
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

    elseif msg == "cdb" then
        BaroCooldownManagerDB = {}
        Addon.db = BaroCooldownManagerDB
        Addon.inst.root:delete()
        Addon.inst.root = Addon.Node:new(nil)
    elseif msg == "tst" then

    end

end
print("Welcome to BaroCM! Use /baro to access the options.")