---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)
---@Type StyleVariables
local style = Addon.StyleVariables

---@class GroupBtn
---@field parentNavigatorPanel NavigatorPanel
---@field group Group
---@field frame Frame
---@field menuFrame Frame
---@field isExpanded boolean
---@field itemBtns ItemBtn[]
local GroupBtn = {}
GroupBtn.__index = GroupBtn

---@param parentNavigatorPanel NavigatorPanel
---@param group Group
---@return GroupBtn
function GroupBtn.create(parentNavigatorPanel, group)
    local self = setmetatable({}, GroupBtn)
    self.parentNavigatorPanel = parentNavigatorPanel
    self.group = group
    self.frame = Addon.Widgets:createRectBtn(
            self.parentNavigatorPanel.scrollContentFrame,
            self.parentNavigatorPanel.scrollContentFrame:GetWidth(),
            math.floor(self.parentNavigatorPanel.scrollContentFrame:GetWidth() / 4.5),
            "Interface/Icons/INV_Misc_Note_01",
            self.group.name
    )
    self.menuFrame = CreateFrame("Frame", nil, UIParent, "UIDropDownMenuTemplate")
    self.isExpanded = false
    self.itemBtns = {}

    self:initializeFrame()

    return self
end

function GroupBtn:initializeFrame()
    self.frame.parentGroupBtn = self
    self.frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local localGroup = self.group
    local localGroupBtn = self
    self.frame:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            self.parentGroupBtn:showGroupMenu()
        elseif button == "LeftButton" then
            Addon.inst.optionsPanel.navigatorPanel:setSelectedBtnFrame(localGroupBtn.frame)
            localGroupBtn:toggleIsExpanded()
            Addon.inst.optionsPanel.propertiesPanel:setGroupPropertiesPanel(localGroup)
        end
    end)

    -- Initialize the itemBtns
    if self.isExpanded == true then
        for _, item in pairs(self.group.itemGrid.itemCollection.items) do
            local itemBtn = Addon.GroupBtn.create(self.parentNavigatorPanel, self, item)
            table.insert(self.itemBtns, itemBtn)
        end
    end
end

function GroupBtn:delete()
    self.frame:Hide()
    self.frame:SetParent(nil)
    self.frame:ClearAllPoints()
    self.frame = nil

    Addon.inst.groupCollection:deleteGroup(self.group)
end

local GROUP_POPUP_KEY = "BCM_GROUP_POPUP_KEY"

StaticPopupDialogs[GROUP_POPUP_KEY] = StaticPopupDialogs[GROUP_POPUP_KEY] or {
    text = "Rename Group",
    button1 = OKAY,
    button2 = CANCEL,
    hasEditBox = true,

    maxLetters = 50,
    OnShow = function(self, data)
        local editBox = self:GetEditBox()
        if not editBox then return end
        editBox:SetText(data.group.name or "")
        editBox:SetFocus()
        editBox:HighlightText()
    end,
    EditBoxOnEnterPressed = function(editBox)
        StaticPopup_OnClick(editBox:GetParent(), 1)
    end,
    EditBoxOnEscapePressed = function(editBox)
        StaticPopup_OnClick(editBox:GetParent(), 2) -- Cancel
    end,
    OnAccept = function(self, data)
        local editBox = self:GetEditBox()
        local newName = editBox and editBox:GetText() or ""
        if data then
            data.group:setName(newName)
            data.groupBtn.frame.text:SetText(newName)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function GroupBtn:showGroupMenu()
    local groupBtn = self
    local group = self.group
    UIDropDownMenu_Initialize(self.menuFrame, function(self, level)
        local titleMenuItem = UIDropDownMenu_CreateInfo()
        titleMenuItem.isTitle = true
        titleMenuItem.notCheckable = true
        titleMenuItem.text = "Group"
        UIDropDownMenu_AddButton(titleMenuItem, level)

        local renameMenuItem = UIDropDownMenu_CreateInfo()
        renameMenuItem.notCheckable = true
        renameMenuItem.text = "Rename"
        renameMenuItem.func = function()
            StaticPopup_Show(GROUP_POPUP_KEY, nil, nil, {
                groupBtn = groupBtn,
                group = group,
            })
        end
        UIDropDownMenu_AddButton(renameMenuItem, level)

        local newItemMenuItem = UIDropDownMenu_CreateInfo()
        newItemMenuItem.notCheckable = true
        newItemMenuItem.text = "New Item"
        newItemMenuItem.func = function()
            local item = group.itemGrid.itemCollection:createItem()
            groupBtn:setIsExpanded(true)
        end
        UIDropDownMenu_AddButton(newItemMenuItem, level)

        local deleteMenuItem = UIDropDownMenu_CreateInfo()
        deleteMenuItem.notCheckable = true
        deleteMenuItem.text = "Delete"
        deleteMenuItem.func = function()
            Addon.inst.optionsPanel.navigatorPanel:deleteGroupBtn(groupBtn)
        end
        UIDropDownMenu_AddButton(deleteMenuItem, level)
    end, "MENU")

    ToggleDropDownMenu(1, nil, self.menuFrame, "cursor", 0, 0)
end

function GroupBtn:setIsExpanded(isExpanded)
    self.isExpanded = isExpanded

    for _, item in pairs(self.itemBtns) do
        item:delete()
    end
    self.itemBtns = {}

    if self.isExpanded == true then
        for _, item in pairs(self.group.itemGrid.itemCollection.items) do
            if item.specId == select(1, GetSpecializationInfo(GetSpecialization())) then
                local itemBtn = Addon.ItemBtn.create(self.parentNavigatorPanel, self, item)
                table.insert(self.itemBtns, itemBtn)
            end
        end
    end

    Addon.inst.optionsPanel.navigatorPanel:applyBtnPositions()
end

function GroupBtn:toggleIsExpanded()
    if self.isExpanded == true then
        self:setIsExpanded(false)
    else
        self:setIsExpanded(true)
    end
end

---@param itemBtnToDelete ItemBtn
function GroupBtn:deleteItemBtn(itemBtnToDelete)
    for idx, itemBtn in ipairs(self.itemBtns) do
        if itemBtn.item.id == itemBtnToDelete.item.id then
            table.remove(self.itemBtns, idx)
            itemBtn:deleteItem()
            break
        end
    end
end

Addon.GroupBtn = GroupBtn
return GroupBtn