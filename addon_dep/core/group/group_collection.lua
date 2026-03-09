---@type Addon
local Addon = select(2, ...)

---@class GroupCollection
---@field groups Group[]
local GroupCollection = {}
GroupCollection.__index = GroupCollection

---@return GroupCollection
function GroupCollection.default()
    local self = setmetatable({}, GroupCollection)
    self.groups = {}

    return self
end

---@param serializedGroupCollection table
---@return GroupCollection
function GroupCollection.deserialize(serializedGroupCollection)
    local self = setmetatable({}, GroupCollection)
    self.groups = {}
    for _, serializedGroup in pairs(serializedGroupCollection) do
        table.insert(self.groups, Addon.Group.deserialize(serializedGroup, self))
    end

    for _, group in pairs(self.groups) do
        group:show()
    end

    return self
end

---@return table
function GroupCollection:serialize()
    local serializedGroupCollection = {}
    for _, group in pairs(self.groups) do
        table.insert(serializedGroupCollection, group:serialize())
    end

    return serializedGroupCollection
end

---@return Group
function GroupCollection:createGroup()
    local group = Addon.Group.default(self)
    table.insert(self.groups, group)
    group:show()
    self:save()

    return group
end

---@param groupToDelete Group
function GroupCollection:deleteGroup(groupToDelete)
    for idx, group in pairs(self.groups) do
        if group.id == groupToDelete.id then
            group:delete()
            self.groups[idx] = nil
            break
        end
    end

    self:save()
end

function GroupCollection:save()
    Addon.db.serializedGroupCollection = Addon.inst.groupCollection:serialize()
end

function GroupCollection:show()
    for _, group in pairs(self.groups) do
        group:show()
    end
end

function GroupCollection:hide()
    for _, group in pairs(self.groups) do
        group:hide()
    end
end

Addon.GroupCollection = GroupCollection
return GroupCollection