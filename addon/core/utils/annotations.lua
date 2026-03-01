---@type Addon
local Addon = select(2, ...)

---@class BcmDatabase
---@field serializedGroupCollection table
---@field serializedItemCollection table

---@class BcmInstance
---@field optionsPanel OptionsPanel
---@field groupCollection GroupCollection
---@field cdmItemCollection CdmItemCollection
---@field itemBindingWatcher ItemBindingWatcher
---@field trinketCollection TrinketCollection
---@field isCinematicPlaying boolean

---@class Addon
---@field CdmItem CdmItem
---@field CdmItemCollection CdmItemCollection
---@field Trinket Trinket
---@field TrinketCollection TrinketCollection
---@field Group Group
---@field GroupCollection GroupCollection
---@field GroupFrame GroupFrame
---@field Item Item
---@field ItemCollection ItemCollection
---@field ItemFrame ItemFrame
---@field GroupBtn GroupBtn
---@field ItemBtn ItemBtn
---@field NavigatorPanel NavigatorPanel
---@field OptionsPanel OptionsPanel
---@field PropertiesPanel PropertiesPanel
---@field StyleVariables StyleVariables
---@field TitlePanel TitlePanel
---@field Widgets Widgets
---@field CdmType CdmType
---@field ColGrowth ColGrowth
---@field FramePoint FramePoint
---@field GrowthPrio GrowthPrio
---@field ItemType ItemType
---@field RowGrowth RowGrowth
---@field Utils Utils
---@field ItemBindingWatcher ItemBindingWatcher
---@field db BcmDatabase
---@field inst BcmInstance
Addon = Addon