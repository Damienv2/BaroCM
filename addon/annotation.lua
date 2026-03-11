---@type Addon
local Addon = select(2, ...)

---@class BcmDatabase
---@field serializedRoot Node

---@class BcmInstance
---@field root Node

---@class Addon
---@field FramePoint FramePoint
---@field EventBus EventBus
---@field RowGrowth RowGrowth
---@field ColGrowth ColGrowth
---@field GrowthPrio GrowthPrio
---@field BackgroundMixin BackgroundMixin
---@field MovableMixin MovableMixin
---@field NodeType NodeType
---@field Node Node
---@field Collection Collection
---@field CollectionMemberNode CollectionMemberNode
---@field Group Group
---@field ProgBar ProgBar
---@field GroupMemberNode GroupMemberNode
---@field Cooldown Cooldown
---@field Item Item
Addon = Addon