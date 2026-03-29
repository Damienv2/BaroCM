---@type Addon
local Addon = select(2, ...)

---@class PowerBar : ProgBar
local PowerBar = setmetatable({}, { __index = Addon.ProgBar })
PowerBar.__index = PowerBar
PowerBar.type = Addon.NodeType.POWER_BAR

---@return PowerBar
function PowerBar:_construct()
    ---@type PowerBar
    local obj = Addon.ProgBar._construct(self)

    obj.name = "New Power Bar"

    obj.powerBarType = nil

    return obj
end

---@return table
function PowerBar:serializeProps()
    local props = Addon.ProgBar.serializeProps(self)
    props.powerBarType = self.powerBarType

    return props
end

---@param data table
function PowerBar:deserializeProps(data)
    Addon.ProgBar.deserializeProps(self, data)
    self.powerBarType = data.powerBarType
end

function PowerBar:finalizeInit()
    Addon.ProgBar.finalizeInit(self)

    if self.powerBarType ~= nil then
        local powerBarColor = self:_resolvePowerBarColor()
        self.bar:SetStatusBarColor(
            powerBarColor.r or 1,
            powerBarColor.g or 1,
            powerBarColor.b or 1,
            powerBarColor.a or 1
        )

        if self.specId == select(1, GetSpecializationInfo(GetSpecialization())) then
            self:startRefreshingProgress()
        end
    end
end

---@param powerBarType PowerBarType
function PowerBar:setPowerBarType(powerBarType)
    if self.powerBarType == powerBarType then return end

    self.powerBarType = powerBarType

    local powerBarColor = self:_resolvePowerBarColor()
    self.bar:SetStatusBarColor(
        powerBarColor.r or 1,
        powerBarColor.g or 1,
        powerBarColor.b or 1,
        powerBarColor.a or 1
    )

    Addon.EventBus:send("SAVE")
end

---@return table
function PowerBar:_resolvePowerBarColor()
    local targetPowerType = Addon.PowerBarType:toPowerBarType(self.powerBarType)
    return PowerBarColor[targetPowerType]
            or PowerBarColor[self.powerBarType]
            or PowerBarColor.MANA
            or { r = 0.2, g = 0.65, b = 1.0, a = 1.0 }
end

function PowerBar:refreshProgress()
    Addon.ProgBar.refreshProgress(self)

    local targetPowerType = Addon.PowerBarType:toPowerBarType(self.powerBarType)
    local cur = UnitPower("player", targetPowerType)
    local max = UnitPowerMax("player", targetPowerType)
    self:setProgress(cur, max)
end

Addon.PowerBar = PowerBar
return PowerBar