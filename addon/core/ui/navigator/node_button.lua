---@type Addon
local Addon = select(2, ...)

---@class NodeButton : NavigatorButton
---@field node Node
---@field popupFrame Frame
local NodeButton = setmetatable({}, { __index = Addon.NavigatorButton })
NodeButton.__index = NodeButton

---@param frameWidth number
---@param node Node
---@return NodeButton
function NodeButton:create(frameWidth, node)
    ---@type NodeButton
    local obj = Addon.NavigatorButton.create(self, frameWidth)

    obj.node = node
    obj.children = {}

    obj.popupFrame = CreateFrame("Frame", nil, UIParent, "UIDropDownMenuTemplate")

    if obj.node.type == Addon.NodeType.COLLECTION then
        obj:setButtonIcon(Addon.Utils.collectionTexture)
    elseif obj.node.type == Addon.NodeType.GROUP then
        obj:setButtonIcon(Addon.Utils.groupTexture)
    elseif obj.node.type == Addon.NodeType.COOLDOWN then
        if obj.node.spellId then
            obj:setButtonIcon(Addon.Utils:getSpellTexture(obj.node.spellId))
        else
            obj:setButtonIcon(Addon.Utils.cooldownTexture)
        end
    elseif obj.node.type == Addon.NodeType.EQUIPMENT then
        if obj.node.itemId then
            obj:setButtonIcon(Addon.Utils:getItemTexture(obj.node.itemId))
        else
            obj:setButtonIcon(Addon.Utils.equipmentTexture)
        end
    elseif obj.node.type == Addon.NodeType.CONSUMABLE then
        if obj.node.itemId then
            obj:setButtonIcon(Addon.Utils:getItemTexture(obj.node.itemId))
        else
            obj:setButtonIcon(Addon.Utils.consumableTexture)
        end
    elseif obj.node.type == Addon.NodeType.POWER_BAR then
        obj:setButtonIcon(Addon.Utils.progBarTexture)
    end
    obj:setButtonText(node.name)

    return obj
end

function NodeButton:handleLeftClick()
    Addon.EventBus:send(self.node.type .. "_BUTTON_CLICKED", self.node, self)
    self:toggleIsExpanded()
end

local NAVIGATOR_BUTTON_POPUP_KEY = "NAVIGATOR_BUTTON_POPUP_KEY"
StaticPopupDialogs[NAVIGATOR_BUTTON_POPUP_KEY] = StaticPopupDialogs[NAVIGATOR_BUTTON_POPUP_KEY] or {
    text = "Rename",
    button1 = OKAY,
    button2 = CANCEL,
    hasEditBox = true,

    maxLetters = 50,
    OnShow = function(self, data)
        local editBox = self:GetEditBox()
        if not editBox then return end
        editBox:SetText(data.nodeButton.node.name or "")
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
            data.nodeButton.node:setName(newName)
            data.nodeButton:setButtonText(newName)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function NodeButton:handleRightClick()
    local nodeButton = self
    UIDropDownMenu_Initialize(self.popupFrame, function(self, level)
        local titleMenuItem = UIDropDownMenu_CreateInfo()
        titleMenuItem.isTitle = true
        titleMenuItem.notCheckable = true
        titleMenuItem.text = "Options"
        UIDropDownMenu_AddButton(titleMenuItem, level)

        local renameMenuItem = UIDropDownMenu_CreateInfo()
        renameMenuItem.notCheckable = true
        renameMenuItem.text = "Rename"
        renameMenuItem.func = function()
            StaticPopup_Show(NAVIGATOR_BUTTON_POPUP_KEY, nil, nil, {
                nodeButton = nodeButton,
            })
        end
        UIDropDownMenu_AddButton(renameMenuItem, level)

        local deleteMenuItem = UIDropDownMenu_CreateInfo()
        deleteMenuItem.notCheckable = true
        deleteMenuItem.text = "Delete"
        deleteMenuItem.func = function()
            nodeButton.node:delete()
        end
        UIDropDownMenu_AddButton(deleteMenuItem, level)
    end, "MENU")

    ToggleDropDownMenu(1, nil, self.popupFrame, "cursor", 0, 0)
end

function NodeButton:delete()
    Addon.NavigatorButton.delete(self)

    for _, child in ipairs(self.children) do
        child:delete()
    end
    self.children = nil

    if self.popupFrame then
        self.popupFrame:Hide()
        self.popupFrame:SetParent(nil)
    end
    self.node = nil
    self.popupFrame = nil
end

function NodeButton:toggleIsExpanded()
    if self.node.type ~= Addon.NodeType.COLLECTION and self.node.type ~= Addon.NodeType.GROUP then return end

    if self.node.isExpanded == true then
        self.node.isExpanded = false
    else
        self.node.isExpanded = true
    end

    Addon.EventBus:send("NODE_BUTTON_TOGGLED")
end

Addon.NodeButton = NodeButton
return NodeButton