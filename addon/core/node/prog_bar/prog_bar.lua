---@type Addon
local Addon = select(2, ...)

---@class ProgBar : CollectionMemberNode
---@field movable MovableMixin
---@field width number
---@field height number
---@field container Frame
---@field barColor number[]
---@field bar Frame
---@field text FontString
---@field refreshProgressTicker Frame
local ProgBar = setmetatable({}, { __index = Addon.CollectionMemberNode })
ProgBar.__index = ProgBar
ProgBar.type = Addon.NodeType.PROG_BAR

---@return ProgBar
function ProgBar:default()
    ---@type ProgBar
    local obj = Addon.CollectionMemberNode.default(self)

    Addon.Mixin:embed(obj, "movable", Addon.MovableMixin)

    obj.movable:registerMovableFrame(obj.frame)

    obj.name = "New Progress Bar"
    obj.specId = select(1, GetSpecializationInfo(GetSpecialization()))

    obj.width = 300
    obj.height = 30
    obj.frame:SetSize(obj.width, obj.height)

    obj.container = CreateFrame("Frame", nil, obj.frame, "BackdropTemplate")
    obj.container:SetPoint(Addon.FramePoint.TOPLEFT, obj.frame, Addon.FramePoint.TOPLEFT, 1, -1)
    obj.container:SetPoint(Addon.FramePoint.BOTTOMRIGHT, obj.frame, Addon.FramePoint.BOTTOMRIGHT, -1, 1)
    obj.container:SetBackdrop({
        bgFile = "Interface/Buttons/WHITE8X8",
        edgeFile = "Interface/Buttons/WHITE8X8",
        edgeSize = 1,
    })
    obj.container:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    obj.container:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    obj.barColor = {0.2, 0.65, 1.0, 1.0}
    obj.bar = CreateFrame("StatusBar", nil, obj.container)
    obj.bar:SetPoint(Addon.FramePoint.TOPLEFT, obj.container, Addon.FramePoint.TOPLEFT, 1, -1)
    obj.bar:SetPoint(Addon.FramePoint.BOTTOMRIGHT, obj.container, Addon.FramePoint.BOTTOMRIGHT, -1, 1)
    obj.bar:SetStatusBarTexture("Interface/Buttons/WHITE8X8")
    obj.bar:SetStatusBarColor(unpack(obj.barColor))
    obj.bar:SetMinMaxValues(0, 1)
    obj.bar:SetValue(0)

    obj.textOverlay = CreateFrame("Frame", nil, obj.container)
    obj.textOverlay:SetAllPoints(obj.container)
    obj.textOverlay:SetFrameLevel(obj.bar:GetFrameLevel() + 1)

    obj.text = obj.textOverlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    obj.text:SetPoint(Addon.FramePoint.CENTER, obj.textOverlay, Addon.FramePoint.CENTER, 0, 0)
    obj.text:SetDrawLayer("OVERLAY", 7)
    obj.text:SetFont("Fonts/FRIZQT__.TTF", Addon.Styling:getProgBarFontSize(obj.height), "OUTLINE")

    obj.refreshProgressTicker = CreateFrame("Frame")

    obj.frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    obj.frame:SetScript("OnEvent", function(_, event, arg1)
        if event == "PLAYER_SPECIALIZATION_CHANGED" then
            if obj:shouldShow() == true then
                obj:startRefreshingProgress()
            else
                obj:stopRefreshingProgress()
            end
        end
    end)

    return obj
end

---@return table
function ProgBar:serializeProps()
    local movable = self.movable:serializeMovableProps()
    return {
        movable = movable,
        specId = self.specId,
        width = self.width,
        height = self.height,
        barColor = self.barColor,
    }
end

---@param data table
function ProgBar:deserializeProps(data)
    self.movable:deserializeMovableProps(data)
    self.specId = data.specId
    self.width = data.width
    self.height = data.height
    self.barColor = data.barColor
end

function ProgBar:afterDeserialize()
    if not self:shouldShow() then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end

function ProgBar:delete()
    Addon.CollectionMemberNode.delete(self)

    self:stopRefreshingProgress()
end

function ProgBar:afterSetParent()
    Addon.CollectionMemberNode.afterSetParent(self)

    if self.parent.movable then
        self.movable:setIsLocked(true)
    end
end

function ProgBar:shouldShow()
    local parentShouldShow = Addon.CollectionMemberNode.shouldShow(self)
    local shouldShow = self.specId == select(1, GetSpecializationInfo(GetSpecialization()))

    return parentShouldShow and shouldShow
end

---@param barColor number[]
function ProgBar:setBarColor(barColor)
    if self.barColor == barColor then return end

    self.barColor = barColor
    self.bar:SetStatusBarColor(unpack(self.barColor))

    Addon.EventBus:send("SAVE")
end

function ProgBar:setProgress(value, maxValue)
    self.bar:SetMinMaxValues(0, maxValue)
    self.bar:SetValue(value)
    self.text:SetText(value)
end

function ProgBar:startRefreshingProgress()
    if self:shouldShow() == false then return end

    self.frame:Show()
    self.refreshProgressTicker:SetScript("OnUpdate", function(_, elapsed)
        self:refreshProgress()
    end)
end

function ProgBar:refreshProgress()

end

function ProgBar:stopRefreshingProgress()
    self.frame:Hide()
    self.refreshProgressTicker:SetScript("OnUpdate", nil)
end

---@param specId number
function ProgBar:setSpecId(specId)
    self.specId = specId

    Addon.EventBus:send("SAVE")
end

---@param width number
function ProgBar:setWidth(width)
    self.width = width

    self.frame:SetSize(self.width, self.height)

    Addon.EventBus:send("SAVE")
end

---@param height number
function ProgBar:setHeight(height)
    self.height = height

    self.frame:SetSize(self.width, self.height)
    self.text:SetFont("Fonts/FRIZQT__.TTF", Addon.Styling:getProgBarFontSize(self.height), "OUTLINE")


    Addon.EventBus:send("SAVE")
end

Addon.ProgBar = ProgBar
return ProgBar