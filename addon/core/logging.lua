local addonName, Addon = ...

Addon.LOG_LEVELS = {
    INFO = 0,
    ERROR = 1,
    WARN = 2,
    DEBUG = 3
}

Addon.LOG_LEVEL_NAMES = {}
for name, value in pairs(Addon.LOG_LEVELS) do
  Addon.LOG_LEVEL_NAMES[value] = name
end

Addon.logLevel = Addon.LOG_LEVELS.DEBUG

local function getFormattedLogMsg(msg, logLevel)
    return "|cff66ccff" .. addonName .. " - " .. Addon.LOG_LEVEL_NAMES[logLevel] .. ":|r " .. tostring(msg)
end

function Addon:logInfo(msg)
    if Addon.logLevel >= Addon.LOG_LEVELS.INFO then
        DEFAULT_CHAT_FRAME:AddMessage(getFormattedLogMsg(msg, Addon.LOG_LEVELS.INFO))
    end
end

function Addon:logError(msg)
    if Addon.logLevel >= Addon.LOG_LEVELS.ERROR then
        DEFAULT_CHAT_FRAME:AddMessage(getFormattedLogMsg(msg, Addon.LOG_LEVELS.ERROR))
    end
end


function Addon:logWarn(msg)
    if Addon.logLevel >= Addon.LOG_LEVELS.WARN then
        DEFAULT_CHAT_FRAME:AddMessage(getFormattedLogMsg(msg, Addon.LOG_LEVELS.WARN))
    end
end

function Addon:logDebug(msg)
    if Addon.logLevel >= Addon.LOG_LEVELS.DEBUG then
        DEFAULT_CHAT_FRAME:AddMessage(getFormattedLogMsg(msg, Addon.LOG_LEVELS.DEBUG))
    end
end

function Addon:dumpTable(table)
    if Addon.logLevel >= Addon.LOG_LEVELS.DEBUG then
        DevTools_Dump(table)
    end
end

