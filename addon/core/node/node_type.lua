---@type Addon
local Addon = select(2, ...)

---@alias NodeTypeValue
---| "NODE"
---| "ROOT"
---| "COLLECTION"
---| "COLLECTION_MEMBER_NODE"
---| "GROUP"
---| "GROUP_MEMBER_NODE"
---| "COOLDOWN"
---| "ITEM"
---| "EQUIPMENT"
---| "CONSUMABLE"
---| "PROG_BAR"
---| "POWER_BAR"
---| "AURA_BAR"

---@class NodeType
---@field NODE NodeTypeValue
---@field ROOT NodeTypeValue
---@field COLLECTION NodeTypeValue
---@field COLLECTION_MEMBER_NODE NodeTypeValue
---@field GROUP NodeTypeValue
---@field GROUP_MEMBER_NODE NodeTypeValue
---@field COOLDOWN NodeTypeValue
---@field ITEM NodeTypeValue
---@field EQUIPMENT NodeTypeValue
---@field CONSUMABLE NodeTypeValue
---@field PROG_BAR NodeTypeValue
---@field POWER_BAR NodeTypeValue
---@field AURA_BAR NodeTypeValue
local NodeType = {
    NODE = "NODE",
    ROOT = "ROOT",
    COLLECTION = "COLLECTION",
    COLLECTION_MEMBER_NODE = "COLLECTION_MEMBER_NODE",
    GROUP = "GROUP",
    GROUP_MEMBER_NODE = "GROUP_MEMBER_NODE",
    COOLDOWN = "COOLDOWN",
    ITEM = "ITEM",
    EQUIPMENT = "EQUIPMENT",
    CONSUMABLE = "CONSUMABLE",
    PROG_BAR = "PROG_BAR",
    POWER_BAR = "POWER_BAR",
    AURA_BAR = "AURA_BAR",
}

local CLASS_BY_TYPE = {
    [NodeType.NODE] = function() return Addon.Node end,
    [NodeType.ROOT] = function() return Addon.Root end,
    [NodeType.COLLECTION] = function() return Addon.Collection end,
    [NodeType.COLLECTION_MEMBER_NODE] = function() return Addon.CollectionMemberNode end,
    [NodeType.GROUP] = function() return Addon.Group end,
    [NodeType.GROUP_MEMBER_NODE] = function() return Addon.GroupMemberNode end,
    [NodeType.COOLDOWN] = function() return Addon.Cooldown end,
    [NodeType.ITEM] = function() return Addon.Item end,
    [NodeType.EQUIPMENT] = function() return Addon.Equipment end,
    [NodeType.CONSUMABLE] = function() return Addon.Consumable end,
    [NodeType.PROG_BAR] = function() return Addon.ProgBar end,
    [NodeType.POWER_BAR] = function() return Addon.PowerBar  end,
    [NodeType.AURA_BAR] = function() return Addon.AuraBar  end,
}

---@param nodeType NodeTypeValue
---@return table
function NodeType:getClass(nodeType)
    local getter = CLASS_BY_TYPE[nodeType]
    if not getter then
        error("Unknown node type: " .. tostring(nodeType))
    end

    local class = getter()
    if not class then
        error("Class not loaded for node type: " .. tostring(nodeType))
    end
    return class
end

Addon.NodeType = NodeType
return NodeType