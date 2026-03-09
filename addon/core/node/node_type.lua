---@type Addon
local Addon = select(2, ...)

---@alias NodeTypeValue
---| "NODE"
---| "COLLECTION"
---| COLLECTION_MEMBER_NODE
---| "GROUP"
---| "GROUP_MEMBER_NODE"
---| "COOLDOWN"
---| "ITEM"
---| "PROG_BAR"

---@class NodeType
---@field NODE NodeTypeValue
---@field COLLECTION NodeTypeValue
---@field COLLECTION_MEMBER_NODE NodeTypeValue
---@field GROUP NodeTypeValue
---@field GROUP_MEMBER_NODE NodeTypeValue
---@field COOLDOWN NodeTypeValue
---@field ITEM NodeTypeValue
---@field PROG_BAR NodeTypeValue
local NodeType = {
    NODE = "NODE",
    COLLECTION = "COLLECTION",
    COLLECTION_MEMBER_NODE = "COLLECTION_MEMBER_NODE",
    GROUP = "GROUP",
    GROUP_MEMBER_NODE = "GROUP_MEMBER_NODE",
    COOLDOWN = "COOLDOWN",
    ITEM = "ITEM",
    PROG_BAR = "PROG_BAR",
}

Addon.NodeType = NodeType
return NodeType