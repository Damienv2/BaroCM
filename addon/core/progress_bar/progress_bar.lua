---@type Addon
local Addon = select(2, ...)

---@class ProgressBarPos
---@field point FramePointValue
---@field relativeTo string
---@field relativePoint FramePointValue
---@field offsetX number
---@field offsetY number

---@class ProgressBarSize
---@field width number
---@field height number

---@class ProgressBarColor
---@field fill number[]
---@field background number[]

---@class ProgressBar
---@field parentProgressBarCollection ProgressBarCollection
---@field id string
---@field name string
---@field pos ProgressBarPos
---@field isLocked boolean
---@field size ProgressBarSize
---@field color ProgressBarColor
---@field trigger Frame
---@field progressBarType ProgressBarType
---@field progressBarPowerType ProgressBarPowerType
---@field progressBarFrame ProgressBarFrame
local ProgressBar = {}
ProgressBar.__index = ProgressBar

---@param parentProgressBarCollection ProgressBarCollection
---@return ProgressBar
function ProgressBar.default(parentProgressBarCollection)
    local self = setmetatable({}, ProgressBar)
    self.parentProgressBarCollection = parentProgressBarCollection
    self.id = Addon.Utils:uuid4()
    self.name = "New Progress Bar"

    self.pos = {
        point = Addon.FramePoint.CENTER,
        relativeTo = "UIParent",
        relativePoint = Addon.FramePoint.CENTER,
        offsetX = 0,
        offsetY = 0,
    }
    self.isLocked = false
    self.size = {
        width = 200,
        height = 30
    }
    self.color = {
        fill = nil,
        background = nil
    }

    self.trigger = nil
    self.progressBarType = nil
    self.progressBarPowerType = nil

    self.progressBarFrame = Addon.ProgressBarFrame.hidden(self)
    self:show()

    return self
end

---@param serializedProgressBar table
---@field parentProgressBarCollection ProgressBarCollection
---@return ProgressBar
function ProgressBar.deserialize(serializedProgressBar, parentProgressBarCollection)
    local self = setmetatable({}, Group)
    self.id = serializedProgressBar.id
    self.name = serializedProgressBar.name

    local pos = serializedProgressBar.pos
    self.pos = {
        point = pos.point,
        relativeTo = pos.relativeTo,
        relativePoint = pos.relativePoint,
        offsetX = pos.offsetX,
        offsetY = pos.offsetY,
    }

    self.isLocked = serializedProgressBar.isLocked

    self.parentProgressBarCollection = parentProgressBarCollection

    return self
end

---@return table
function ProgressBar:serialize()
    return {
        id = self.id,
        name = self.name,
        pos = {
            point = self.pos.point,
            relativeTo = self.pos.relativeTo,
            relativePoint = self.pos.relativePoint,
            offsetX = self.pos.offsetX,
            offsetY = self.pos.offsetY,
        },
        isLocked = self.isLocked,
    }
end

function ProgressBar:show()
    self.progressBarFrame:show()
end

function ProgressBar:hide()
    self.progressBarFrame:hide()
end

function ProgressBar:delete()
    self:hide()
end

---@return Frame
function ProgressBar:refreshTrigger()
    local trigger = CreateFrame("Frame")
    if self.progressBarType == Addon.ProgressBarType.AURA then
        trigger:RegisterEvent("UNIT_AURA")
    elseif self.progressBarType == Addon.ProgressBarType.POWER then
        trigger:RegisterEvent("UNIT_POWER_UPDATE")
    end

    local targetPowerType = Addon.ProgressBarPowerType:toPowerType(self.progressBarPowerType)
    local progressBarFrame = self.progressBarFrame
    trigger:SetScript("OnEvent", function(_, event, unit, powerType)
        if unit ~= "player" then return end

        if event == "UNIT_AURA" then
            -- refresh buff stacks/duration bar
        elseif event == "UNIT_POWER_UPDATE" then
            local cur = UnitPower("player", targetPowerType)
            local max = UnitPowerMax("player", targetPowerType)
            progressBarFrame:setProgress(cur, max)
        end
    end)
    trigger:SetScript("OnUpdate", function(_, elapsed)
        local cur = UnitPower("player", targetPowerType)
        local max = UnitPowerMax("player", targetPowerType)
        progressBarFrame:setProgress(cur, max)
    end)

    self.trigger = trigger
end

---@param progressBarPowerType ProgressBarPowerType
function ProgressBar:setProgressBarPowerType(progressBarPowerType)
    self.progressBarType = Addon.ProgressBarType.POWER
    self.progressBarPowerType = progressBarPowerType

    local targetPowerType = Addon.ProgressBarPowerType:toPowerType(self.progressBarPowerType)
    local cur = UnitPower("player", targetPowerType)
    local max = UnitPowerMax("player", targetPowerType)
    self.progressBarFrame:setProgress(cur, max)

    local powerBarColor = PowerBarColor[targetPowerType]
    self:setColorFill({powerBarColor.r, powerBarColor.g, powerBarColor.b, powerBarColor.a})

    self:refreshTrigger()
end

---@param fill number[]
function ProgressBar:setColorFill(fill)
    self.color.fill = fill
    self.progressBarFrame:setColorFill(fill)
end

Addon.ProgressBar = ProgressBar
return ProgressBar