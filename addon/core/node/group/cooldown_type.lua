---@type Addon
local Addon = select(2, ...)

---@alias CooldownTypeValue
---| "SPELL"
---| "AURA"

---@class CooldownType
---@field SPELL CooldownTypeValue
---@field AURA CooldownTypeValue
local CooldownType = {
    SPELL = "SPELL",
    AURA = "AURA",
}

function CooldownType:getOptions()
    local options = {}
    for key, value in pairs(CooldownType) do
        if type(value) == "string" then
            table.insert(options, { value = value, text = key })
        end
    end

    -- Sort alphabetically if desired
    table.sort(options, function(a, b) return a.text < b.text end)

    return options
end

---@param cooldownType CooldownType
---@param cdmType CdmType
function CooldownType:supportsCdmType(cooldownType, cdmType)
    local validItemTypeByCdmType = {
        [Addon.CdmType.ESSENTIAL] = Addon.CooldownType.SPELL,
        [Addon.CdmType.UTILITY] = Addon.CooldownType.SPELL,
        [Addon.CdmType.BUFF_ICON] = Addon.CooldownType.AURA,
        [Addon.CdmType.BUFF_BAR] = Addon.CooldownType.AURA,
    }

    return validItemTypeByCdmType[cdmType] == cooldownType
end

Addon.CooldownType = CooldownType
return CooldownType
