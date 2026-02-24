---@type Addon
local Addon = select(2, ...)

---@class Utils
local Utils = {}

---@return string
function Utils:uuid4()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return template:gsub("[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
    end)
end

---@param frame Frame
---@param r number
---@param g number
---@param b number
function Utils:addDebugFrame(frame, r, g, b)
    if not frame then return end

    r, g, b = r or 1, g or 0, b or 0

    if not frame.debugBg then
        frame.debugBg = frame:CreateTexture(nil, "BACKGROUND")
        frame.debugBg:SetAllPoints()
        frame.debugBg:SetTexture("Interface/Buttons/WHITE8X8")
    end
    frame.debugBg:SetVertexColor(r, g, b, 1)
end

---@param pTable table
function Utils:dumpAllKeys(pTable)
    print("Dumping table...")
    for k, v in pairs(pTable) do
        print(tostring(k), tostring(v))
    end
end

Addon.Utils = Utils
return Utils