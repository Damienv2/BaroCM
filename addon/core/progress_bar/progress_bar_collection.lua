---@type Addon
local Addon = select(2, ...)

---@class ProgressBarCollection
---@field progressBars ProgressBar[]
local ProgressBarCollection = {}
ProgressBarCollection.__index = ProgressBarCollection

---@return ProgressBarCollection
function ProgressBarCollection.default()
    local self = setmetatable({}, ProgressBarCollection)
    self.progressBars = {}

    return self
end

---@param serializedProgressBarCollection table
---@return ProgressBarCollection
function ProgressBarCollection.deserialize(serializedProgressBarCollection)
    local self = setmetatable({}, ProgressBarCollection)
    self.progressBars = {}
    for _, serializedProgressBar in pairs(serializedProgressBarCollection) do
        table.insert(self.groups, Addon.ProgressBar.deserialize(serializedProgressBar, self))
    end

    for _, progressBar in pairs(self.progressBars) do
        progressBar:show()
    end

    return self
end

---@return table
function ProgressBarCollection:serialize()
    local serializedProgressBarCollection = {}
    for _, progressBar in pairs(self.progressBars) do
        table.insert(serializedProgressBarCollection, progressBar:serialize())
    end

    return serializedProgressBarCollection
end

---@return ProgressBar
function ProgressBarCollection:createProgressBar()
    local progressBar = Addon.ProgressBar.default(self)
    table.insert(self.progressBars, progressBar)
    progressBar:show()
    self:save()

    return progressBar
end

---@param progressBarToDelete Group
function ProgressBarCollection:deleteProgressBar(progressBarToDelete)
    for idx, progressBar in pairs(self.progressBars) do
        if progressBar.id == progressBarToDelete.id then
            progressBar:delete()
            self.progressBars[idx] = nil
            break
        end
    end

    self:save()
end

function ProgressBarCollection:save()
    Addon.db.serializedProgressBarCollection = Addon.inst.ProgressBarCollection:serialize()
end

function ProgressBarCollection:show()
    for _, progressBar in pairs(self.progressBars) do
        progressBar:show()
    end
end

function ProgressBarCollection:hide()
    for _, progressBar in pairs(self.progressBars) do
        progressBar:hide()
    end
end

Addon.ProgressBarCollection = ProgressBarCollection
return ProgressBarCollection