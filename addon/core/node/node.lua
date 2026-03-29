---@type Addon
local Addon = select(2, ...)

---@class Node
---@field parent Node?
---@field id string
---@field name string
---@field rank number?
---@field children Node[]
---@field frame Frame
---@field isCinematicPlaying boolean
---@field type NodeTypeValue
---@field isExpanded boolean
local Node = {}
Node.__index = Node

---@type NodeTypeValue
Node.type = Addon.NodeType.NODE

---@return Node
function Node:_construct()
    local obj = setmetatable({}, self)
    obj.parent = nil
    obj.id = self:_create_uuid4()
    obj.name = "New Node"
    obj.rank = nil
    obj.children = {}
    obj.frame = CreateFrame("Frame", obj.id, UIParent)
    obj.frame:SetPoint(Addon.FramePoint.CENTER, UIParent, Addon.FramePoint.CENTER, 0, 0)
    obj.frame:SetSize(0, 0)

    obj.isCinematicPlaying = false

    obj.frame:RegisterEvent("CINEMATIC_START")
    obj.frame:RegisterEvent("CINEMATIC_STOP")
    obj.frame:RegisterEvent("PLAY_MOVIE")
    obj.frame:RegisterEvent("STOP_MOVIE")
    obj.frame:SetScript("OnEvent", function(_, event, arg1)
        if event == "CINEMATIC_START" or event == "PLAY_MOVIE" then
            obj.isCinematicPlaying = true
            obj:refreshVisibility()
        elseif event == "CINEMATIC_STOP" or event == "STOP_MOVIE" then
            obj.isCinematicPlaying = false
            obj:refreshVisibility()
        end
    end)


    obj.isExpanded = false

    return obj
end

function Node:default()
    local obj = self:_construct()
    obj:finalizeInit()

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
---@param parent Node?
function Node.deserialize(data, parent)
    local class = Addon.NodeType:getClass(data.type)
    local node = class:default()

    node.parent = nil
    node.id = data.id
    node.name = data.name
    node.rank = data.rank
    node.children = {}
    node:setParent(parent)

    if node.deserializeProps then
        node:deserializeProps(data.props or {})
    end

    for _, childData in ipairs(data.children or {}) do
        local child = Node.deserialize(childData, node)
        table.insert(node.children, child)
        node:afterAppendChild(child)
    end

    node:finalizeInit()

    return node
end

function Node:finalizeInit()
    if self._isFinalized then return end
    self._isFinalized = true
end

---@param parent Node
function Node:setParent(parent)
    self:validateParent(parent)

    self.parent = parent

    self.frame:SetFrameStrata("BACKGROUND")
    if parent ~= nil then
        self.frame:SetParent(parent.frame)
        self.frame:ClearAllPoints()
        self.frame:SetPoint(Addon.FramePoint.CENTER, parent.frame, Addon.FramePoint.CENTER, 0, 0)
        self.frame:SetFrameLevel(parent.frame:GetFrameLevel() + 1)
    else
        self.frame:SetFrameLevel(0)
    end

    self:afterSetParent()
end

function Node:validateParent(parent)
    if parent ~= nil then
        error("Node must have a NIL parent.")
    end
end

function Node:afterSetParent()

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

---@param rank number
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

    Addon.EventBus:send("SAVE")
    Addon.EventBus:send("NODE_APPENDED", self, node)

    self:afterAppendChild(node)
end

---@param node Node
function Node:afterAppendChild(node)

end

---@param node Node
---@param newRank number
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

---@return boolean
function Node:isRoot()
    return self.parent == nil
end

---@return boolean
function Node:isFirstChild()
    return self.rank == 0
end

---@return boolean
function Node:isLastChild()
    if not self.parent then return true end
    return self.rank == self.parent:getNextChildRank() - 1
end

function Node:beforeDelete()

end

function Node:delete()
    self:hide()

    self:beforeDelete()

    for _, child in ipairs(self.children) do
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

    if self.parent ~= nil then
        for _, child in ipairs(self.parent.children) do
            if child.rank > self.rank then
                child:setRank(child.rank - 1)
                Addon.EventBus:send("RANK_CHANGED", child)
            end
        end
    end

    self.frame:SetScript("OnEvent", nil)
    self.frame:UnregisterAllEvents()
    self.frame:SetScript("OnUpdate", nil)
    self.frame:Hide()
    self.frame:SetParent(nil)
    self.frame = nil

    Addon.EventBus:send("SAVE")
    Addon.EventBus:send("NODE_DELETED", self)
end

function Node:show()
    if self.frame:IsShown() == true then return end

    self.frame:Show()
end

function Node:showChildren()
    for _, child in ipairs(self.children) do
        child:show()
        child:showChildren()
    end
end

function Node:hide()
    if self.frame:IsShown() == false then return end

    self.frame:Hide()
end

function Node:hideChildren()
    for _, child in ipairs(self.children) do
        child:hide()
        child:hideChildren()
    end
end

---@return boolean
function Node:shouldShow()
    return not self.isCinematicPlaying and not UnitInVehicle("player")
end

function Node:refreshVisibility()
    if self:shouldShow() == true then
        self:show()
    else
        self:hide()
    end
end

Addon.Node = Node
return Node