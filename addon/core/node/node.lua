---@type Addon
local Addon = select(2, ...)

---@class Node
---@field parent Node?
---@field id string
---@field name string
---@field rank number
---@field children Node[]?
---@field frame Frame
---@field type NodeTypeValue
Node = {}
Node.__index = Node

---@type NodeTypeValue
Node.type = Addon.NodeType.NODE

---@param parent Node?
---@param rank number?
---@return Node
function Node:new(parent, rank)
    if rank == nil then rank = 0 end
    self:validateParent(parent)

    local obj = setmetatable({}, self)
    obj.parent = parent
    obj.id = self:_create_uuid4()
    obj.name = "New Node"
    obj.rank = rank
    obj.children = {}
    local parentFrame = parent ~= nil and parent.frame or UIParent
    obj.frame = CreateFrame("Frame", obj.id, parentFrame)

    return obj
end

function Node:deserialize(data, parent)
    local class = Addon.NodeRegistry[data.type]
    assert(class, "Unknown node type: " .. tostring(data.type))

    local node = class:new(parent, data.rank or 0)
    node.id = data.id or node.id
    node.name = data.name or node.name
    node.children = {}
    node:fromData(data)

    for _, childData in ipairs(data.children or {}) do
        node.children[#node.children + 1] = Node.deserialize(childData, node)
    end

    table.sort(node.children, function(a, b) return a.rank < b.rank end)
    return node
end

function Node:serialize()
    local children = {}
    for _, c in ipairs(self.children) do
        children[#children + 1] = c:serialize()
    end

    local data = {
        v = 1,
        type = self.type,
        id = self.id,
        name = self.name,
        rank = self.rank,
        children = children,
    }

    for k, v in pairs(self:toData()) do data[k] = v end
    return data
end

---@return table
function Node:toData()
    return {}
end

---@param data table
function Node:fromData(data)

end

function Node:validateParent(parent)
    if parent ~= nil then
        error("Node must have a NIL parent.")
    end
end

---@return string
function Node:_create_uuid4()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return template:gsub("[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
    end)
end

function Node:show()
    for _, child in ipairs(self.children) do
        child:show()
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

---@return number
function Node:getNextChildRank()
    return #self.children
end

---@param node Node
function Node:appendChild(node)
    local childRank = self:getNextChildRank()
    table.insert(self.children, node)
    node.rank = childRank

    local event = "APPEND_" .. node.type
    Addon.EventBus:send(event, node)
end

function Node:moveChild(node, newRank)
    for _, child in ipairs(self.children) do
        if child.rank >= newRank and child.rank < node.rank then
            child.rank = child.rank + 1
            Addon.EventBus:send("RANK_CHANGE", child)
        end
    end

    node.rank = newRank
    Addon.EventBus:send("RANK_CHANGE", node)
end

function Node:beforeDelete()

end

function Node:delete()
    self:hide()

    for _, child in ipairs(self.children) do
        child:beforeDelete()
        child:delete()
    end

    local idxToDelete = nil
    for idx, child in ipairs(self.parent.children) do
        if child.id == self.id then
            idxToDelete = idx
        end
    end
    table.remove(self.parent.children, idxToDelete)

    local event = "DELETE_" .. self.type
    Addon.EventBus:send(event, self)

    for _, child in ipairs(self.parent.children) do
        if child.rank > self.rank then
            child.rank = child.rank - 1
            Addon.EventBus:send("RANK_CHANGE", child)
        end
    end
end

function Node:isFirst()
    return self.rank == 0
end

function Node:isLast()
    return self.rank == self.parent:getNextChildRank() - 1
end

Addon.Node = Node
return Node