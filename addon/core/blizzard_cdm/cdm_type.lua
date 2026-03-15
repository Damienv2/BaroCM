---@type Addon
local Addon = select(2, ...)

---@alias CdmTypeValue
---| "ESSENTIAL"
---| "UTILITY"
---| "BUFF_ICON"
---| "BUFF_BAR"

---@class CdmType
---@field ESSENTIAL CdmTypeValue
---@field UTILITY CdmTypeValue
---@field BUFF_ICON CdmTypeValue
---@field BUFF_BAR CdmTypeValue
local CdmType = {
    ESSENTIAL = "ESSENTIAL",
    UTILITY = "UTILITY",
    BUFF_ICON = "BUFF_ICON",
    BUFF_BAR = "BUFF_BAR",
}

---@param cdmType CdmType
function CdmType:getViewer(cdmType)
    local viewers = {
        [Addon.CdmType.ESSENTIAL] = _G.EssentialCooldownViewer,
        [Addon.CdmType.UTILITY] = _G.UtilityCooldownViewer,
        [Addon.CdmType.BUFF_ICON] = _G.BuffIconCooldownViewer,
        [Addon.CdmType.BUFF_BAR] = _G.BuffBarCooldownViewer,
    }

    return viewers[cdmType]
end

Addon.CdmType = CdmType
return CdmType
