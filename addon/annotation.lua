---@type Addon
local Addon = select(2, ...)

---@class BcmDatabase
---@field serializedRoot Node

---@class BcmInstance
---@field root Node
---@field cdmAdapterRegistry CdmAdapterRegistry
---@field cdmBinder CdmBinder
---@field isCinematicPlaying boolean
---@field version number

---@class Addon
---@field FramePoint FramePoint
---@field EventBus EventBus
---@field Debug Debug
---@field Mixin Mixin
---@field Orientation Orientation
---@field Utils Utils
---@field GrowthPrio GrowthPrio
---@field HorizontalAlignment HorizontalAlignment
---@field VerticalAlignment VerticalAlignment
---@field BackgroundMixin BackgroundMixin
---@field DynamicSizingMixin DynamicSizingMixin
---@field MovableMixin MovableMixin
---@field NodeType NodeType
---@field Node Node
---@field Root Root
---@field Collection Collection
---@field CollectionMemberNode CollectionMemberNode
---@field Group Group
---@field ProgBar ProgBar
---@field GroupMemberNode GroupMemberNode
---@field Cooldown Cooldown
---@field CooldownType CooldownType
---@field Item Item
---@field Equipment Equipment
---@field Consumable Consumable
---@field CdmType CdmType
---@field CdmAdapter CdmAdapter
---@field CdmAdapterRegistry CdmAdapterRegistry
---@field CdmBinder CdmBinder
---@field inst BcmInstance
Addon = Addon