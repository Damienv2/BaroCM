---@type Addon
local Addon = select(2, ...)

---@class Debug
local Debug = {}
Debug.listeners = {}

---@param frame Frame
---@param r number?
---@param g number?
---@param b number?
function Debug:addDebugFrame(frame, r, g, b, a)
    if not frame then return end

    r, g, b, a = r or 1, g or 0, b or 0, a or 1

    if not frame.debugBg then
        frame.debugBg = frame:CreateTexture(nil, "BACKGROUND")
        frame.debugBg:SetAllPoints()
        frame.debugBg:SetTexture("Interface/Buttons/WHITE8X8")
    end
    frame.debugBg:SetVertexColor(r, g, b, a)
end

---@param aTable table
function Debug:printTable(aTable)
    DevTools_Dump(aTable)
end

Addon.Debug = Debug
return Debug