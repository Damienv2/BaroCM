---@type Addon
local Addon = select(2, ...)

---@class Mixin
local Mixin = {}

---@param target table The object receiving the mixin
---@param key string The name of the sub-table
---@param mixin table The mixin table
function Mixin:embed(target, key, mixin)
    target[key] = {}
    for k, v in pairs(mixin) do
        target[key][k] = v
    end

    if target[key].init then
        target[key]:init(target)
    end
end

Addon.Mixin = Mixin
return Mixin