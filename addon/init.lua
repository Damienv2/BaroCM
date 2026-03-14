---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        BaroCooldownManagerDB2 = BaroCooldownManagerDB2 or {}
        Addon.db = BaroCooldownManagerDB2
        Addon.inst = {}
        if Addon.db.serializedRoot == nil then
            Addon.inst.root = Addon.Collection:default()
            Addon.inst.root:setName("Root")
        else
            --TODO make parent optional that defaults to nil
            Addon.inst.root = Addon.Node.deserialize(Addon.db.serializedRoot, nil)
        end
        Addon.EventBus:register("SAVE", function()
            Addon.db.serializedRoot = Addon.inst.root:serialize()
        end)
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
        BaroCooldownManagerDB2 = {}
        Addon.db = BaroCooldownManagerDB2
        if Addon.inst.root then
            Addon.inst.root:delete()
            Addon.inst.root = Addon.Collection:default()
            Addon.db.serializedRoot = Addon.inst.root:serialize()
        end
    elseif msg == "tst1" then
        local newGroup = Addon.Group:default()
        Addon.inst.root:appendChild(newGroup)
    elseif msg == "tst2" then
        print(Addon.inst.root.children[1].background:setShowBackground(not Addon.inst.root.children[1].background.showBackground))
    elseif msg == "p" then
        DevTools_Dump(Addon.inst.root)
    end

end
print("Welcome to BaroCM! Use /baro to access the options.")