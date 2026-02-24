---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)
---@Type StyleVariables
local style = Addon.StyleVariables

---@class ItemBtn
---@field parentNavigatorPanel NavigatorPanel
---@field parentGroupBtn GroupBtn
---@field item Item
---@field frame Frame
---@field menuFrame Frame
local ItemBtn = {}
ItemBtn.__index = ItemBtn

---@param parentNavigatorPanel NavigatorPanel
---@param parentGroupBtn GroupBtn
---@param item Item
---@return ItemBtn
function ItemBtn.create(parentNavigatorPanel, parentGroupBtn, item)
    local self = setmetatable({}, ItemBtn)
    self.parentNavigatorPanel = parentNavigatorPanel
    self.parentGroupBtn = parentGroupBtn
    self.item = item

    self.frame = Addon.Widgets:createRectBtn(
            self.parentNavigatorPanel.scrollContentFrame,
            self.parentNavigatorPanel.scrollContentFrame:GetWidth() * 0.9,
            math.floor((self.parentNavigatorPanel.scrollContentFrame:GetWidth() / 4.5) * 0.9),
            self:getIconPath(),
            self.item:getLabel()
    )
    self.menuFrame = CreateFrame("Frame", nil, UIParent, "UIDropDownMenuTemplate")

    self:initializeFrame()

    return self
end

function ItemBtn:initializeFrame()
    self.frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local localItem = self.item
    local localItemBtn = self
    self.frame:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            localItemBtn:showItemMenu()
        elseif button == "LeftButton" then
            Addon.inst.optionsPanel.navigatorPanel:setSelectedBtnFrame(localItemBtn.frame)
            Addon.inst.optionsPanel.propertiesPanel:setItemPropertiesPanel(localItem, localItemBtn)
        end
    end)
end

---@return string
function ItemBtn:getIconPath()
    if self.item.itemType == Addon.ItemType.CDM and self.item.spellId then
        return C_Spell.GetSpellTexture(self.item.spellId)
    elseif self.item.itemType == Addon.ItemType.TRINKET and self.item.itemId then
        return C_Item.GetItemIconByID(self.item.itemId)
    end
    return "Interface/Icons/INV_Misc_QuestionMark"
end

function ItemBtn:delete()
    self.frame:Hide()
    self.frame:SetParent(nil)
    self.frame:ClearAllPoints()
    self.frame = nil
end

function ItemBtn:deleteItem()
    self:delete()
    self.item.parentItemCollection:deleteItem(self.item)
end

---@field name string
function ItemBtn:setName(name)
    self.frame.text:SetText(name)
end

function ItemBtn:refreshIcon()
    Addon.Widgets:setButtonIcon(self.frame, self:getIconPath())
end

function ItemBtn:showItemMenu()
    local itemBtn = self
    local parentGroupBtn = self.parentGroupBtn
    UIDropDownMenu_Initialize(self.menuFrame, function(self, level)
        local titleMenuItem = UIDropDownMenu_CreateInfo()
        titleMenuItem.isTitle = true
        titleMenuItem.notCheckable = true
        titleMenuItem.text = "Item"
        UIDropDownMenu_AddButton(titleMenuItem, level)

        local deleteMenuItem = UIDropDownMenu_CreateInfo()
        deleteMenuItem.notCheckable = true
        deleteMenuItem.text = "Delete"
        deleteMenuItem.func = function()
            parentGroupBtn:deleteItemBtn(itemBtn)
            Addon.inst.optionsPanel.navigatorPanel:refreshGroupBtns()
        end
        UIDropDownMenu_AddButton(deleteMenuItem, level)
    end, "MENU")

    ToggleDropDownMenu(1, nil, self.menuFrame, "cursor", 0, 0)
end

Addon.ItemBtn = ItemBtn
return ItemBtn
