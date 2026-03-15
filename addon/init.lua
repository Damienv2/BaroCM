---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Load saved data
        BaroCooldownManagerDB2 = BaroCooldownManagerDB2 or {}
        Addon.db = BaroCooldownManagerDB2
        Addon.inst = {}
        if Addon.db.serializedRoot == nil then
            Addon.inst.root = Addon.Collection:default()
            Addon.inst.root:setName("Root")
        else
            Addon.inst.root = Addon.Node.deserialize(Addon.db.serializedRoot)
        end

        -- Register save event
        Addon.EventBus:register("SAVE", function()
            Addon.db.serializedRoot = Addon.inst.root:serialize()
        end)
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Setup CDM Adapter Registry
        Addon.inst.cdmAdapterRegistry = Addon.CdmAdapterRegistry:default()

        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
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
        Addon.Debug:printTable(Addon.inst.cdmAdapterRegistry.adapters)
    elseif msg == "p" then
        Addon.Debug:printTable(Addon.inst.root)
    end

end
print("Welcome to BaroCM! Use /baro to access the options.")