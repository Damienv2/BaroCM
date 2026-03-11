---@type Addon
local Addon = select(2, ...)

---@class Debug
local Debug = {}
Debug.listeners = {}

---@param frame Frame
---@param r number?
---@param g number?
---@param b number?
function Debug:addDebugFrame(frame, r, g, b)
    if not frame then return end

    r, g, b = r or 1, g or 0, b or 0

    if not frame.debugBg then
        frame.debugBg = frame:CreateTexture(nil, "BACKGROUND")
        frame.debugBg:SetAllPoints()
        frame.debugBg:SetTexture("Interface/Buttons/WHITE8X8")
    end
    frame.debugBg:SetVertexColor(r, g, b, 1)
end

Addon.Debug = Debug
return Debug