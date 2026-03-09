---@type Addon
local Addon = select(2, ...)

---@class Collection : Node
Collection = setmetatable({}, { __index = Addon.Node }) -- inherit from Node
Collection.__index = Collection
Collection.type = Addon.NodeType.COLLECTION

---@return Collection
function Collection:default()
    ---@type Collection
    local obj = Addon.Node.default(self) -- parent constructor
    obj.name = "New Collection"

    return obj
end

---@param parent Node
function Collection:setParent(parent)
    if parent.type ~= Addon.NodeType.NODE and parent.type ~= Addon.NodeType.COLLECTION then
        error("Collection must have a Node or Collection parent.")
    end
    
    self.parent = parent
end

Addon.Collection = Collection
return Collection