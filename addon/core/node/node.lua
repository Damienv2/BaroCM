---@type Addon
local Addon = select(2, ...)

---@class Node
---@field parent Node?
---@field id string
---@field name string
---@field rank number?
---@field children Node[]?
---@field frame Frame
---@field type NodeTypeValue
Node = {}
Node.__index = Node

---@type NodeTypeValue
Node.type = Addon.NodeType.NODE

---@return Node
function Node:default()
    local obj = setmetatable({}, self)
    obj.parent = nil
    obj.id = self:_create_uuid4()
    obj.name = "New Node"
    obj.rank = nil
    obj.children = {}

    return obj
end

---@return table
function Node:serializeProps()
    return {}
end

---@return table
function Node:serialize()
    local childrenDto = {}
    for i, child in ipairs(self.children or {}) do
        childrenDto[i] = child:serialize()
    end

    return {
        type = self.type,
        id = self.id,
        name = self.name,
        rank = self.rank,
        props = self:serializeProps(),
        children = childrenDto,
    }
end

---@param data table
function Node:deserializeProps(data)

end

---@param data table
---@param parent Node
function Node.deserialize(data, parent)
    local class = Addon.NodeType:getClass(data.type)
    local node = class:default()

    node.id = data.id
    node.name = data.name
    node.rank = data.rank
    node.children = {}
    node.parent = parent

    if node.deserializeProps then
        node:deserializeProps(data.props or {})
    end

    for _, childData in ipairs(data.children or {}) do
        local child = Node.deserialize(childData, node)
        table.insert(node.children, child)
    end

    return node
end

function Node:setParent(parent)
    if parent ~= nil then
        error("Node must have a NIL parent.")
    end
    
    self.parent = parent
end

---@return string
function Node:_create_uuid4()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return template:gsub("[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
    end)
end

function Node:setName(name)
    self.name = name

    Addon.EventBus:send("SAVE")
end

function Node:setRank(rank)
    self.rank = rank

    Addon.EventBus:send("SAVE")
end

---@return number
function Node:getNextChildRank()
    return #self.children
end

---@param node Node
function Node:appendChild(node)
    node:setParent(self)
    node:setRank(self:getNextChildRank())
    table.insert(self.children, node)

    local event = "APPEND_" .. node.type
    Addon.EventBus:send(event, node)
    Addon.EventBus:send("SAVE")
end

function Node:moveChild(node, newRank)
    for _, child in ipairs(self.children) do
        if child.rank >= newRank and child.rank < node.rank then
            child:setRank(child.rank + 1)
            Addon.EventBus:send("RANK_CHANGE", child)
        end
    end

    node.rank = newRank
    Addon.EventBus:send("RANK_CHANGE", node)
end

function Node:isRoot()
    return self.parent == nil
end

function Node:isFirstChild()
    return self.rank == 0
end

function Node:isLastChild()
    return self.rank == self.parent:getNextChildRank() - 1
end

function Node:beforeDelete()

end

function Node:delete()
    self:hide()

    for _, child in ipairs(self.children) do
        child:beforeDelete()
        child:delete()
    end

    if self.parent ~= nil then
        local idxToDelete = nil
        for idx, child in ipairs(self.parent.children) do
            if child.id == self.id then
                idxToDelete = idx
            end
        end
        table.remove(self.parent.children, idxToDelete)
    end

    local event = "DELETE_" .. self.type
    Addon.EventBus:send(event, self)

    if self.parent ~= nil then
        for _, child in ipairs(self.parent.children) do
            if child.rank > self.rank then
                child:setRank(child.rank - 1)
                Addon.EventBus:send("RANK_CHANGE", child)
            end
        end
    end
end

function Node:show()

end

function Node:showCascade()
    for _, child in ipairs(self.children) do
        child:show()
        child:showCascade()
    end
end

function Node:hide()

end

function Node:hideCascade()
    for _, child in ipairs(self.children) do
        child:hide()
        child:hideCascade()
    end
end

Addon.Node = Node
return Node