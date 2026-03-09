---@type Addon
local Addon = select(2, ...)

---@class Collection : Node
---@field items table
Collection = setmetatable({}, { __index = Addon.Node }) -- inherit from Node
Collection.__index = Collection
Collection.type = Addon.NodeType.COLLECTION

---@param parent Node?
---@param rank number?
---@return Collection
function Collection:new(parent, rank)
    ---@type Collection
    local obj = Addon.Node.new(self, parent, rank) -- parent constructor
    obj.name = "New Collection"

    return obj
end

---@param parent Node
function Collection:validateParent(parent)
    if parent.type ~= Addon.NodeType.NODE and parent.type ~= Addon.NodeType.COLLECTION then
        error("Collection must have a Node or Collection parent.")
    end
end

Addon.Collection = Collection
return Collection