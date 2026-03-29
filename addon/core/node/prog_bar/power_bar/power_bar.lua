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
    if self.powerBarType ~= nil then
        local targetPowerType = Addon.PowerBarType:toPowerBarType(self.powerBarType)
        local powerBarColor = PowerBarColor[targetPowerType]
        self.bar:SetStatusBarColor(unpack({powerBarColor.r, powerBarColor.g, powerBarColor.b, powerBarColor.a}))

        if self.specId == select(1, GetSpecializationInfo(GetSpecialization())) then
            self:startRefreshingProgress()
        end
    end
end

---@param powerBarType PowerBarType
function PowerBar:setPowerBarType(powerBarType)
    if self.powerBarType == powerBarType then return end

    self.powerBarType = powerBarType

    local targetPowerType = Addon.PowerBarType:toPowerBarType(self.powerBarType)
    local powerBarColor = PowerBarColor[targetPowerType]
    self.bar:SetStatusBarColor(unpack({powerBarColor.r, powerBarColor.g, powerBarColor.b, powerBarColor.a}))

    Addon.EventBus:send("SAVE")
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