---@type string
local addonName = ...
---@type Addon
local Addon = select(2, ...)
---@Type StyleVariables
local style = Addon.StyleVariables

---@class Widgets
local Widgets = {}

---@param parent Frame
---@param width number
---@param height number
---@param iconPath string
---@param text string
---@return Frame
function Widgets:createRectBtn(parent, width, height, iconPath, text)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, height)

    btn:SetBackdrop({
        bgFile = style.innerPanel.backgroundFile,
        edgeFile = style.innerPanel.borderFile,
        tile = false,
        edgeSize = 1,
        insets = { left = 0, right = -1, top = 0, bottom = 0 },
    })

    btn:SetBackdropColor(0.12, 0.12, 0.12, 0.95)
    btn:SetBackdropBorderColor(unpack(style.borderColor))

    btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    btn.text:SetPoint(Addon.FramePoint.CENTER)
    btn.text:SetText(text)

    btn:SetHighlightTexture("Interface/Buttons/WHITE8X8")
    btn:GetHighlightTexture():SetVertexColor(0.25, 0.55, 0.9, 0.2)

    btn:SetPushedTexture("Interface/Buttons/WHITE8X8")
    btn:GetPushedTexture():SetVertexColor(0.25, 0.55, 0.9, 0.4)

    if iconPath then
        Addon.Widgets:setButtonIcon(btn, iconPath)
    end

    return btn
end

---@param btn Frame
---@param iconPath string
function Widgets:setButtonIcon(btn, iconPath)
    local height = btn:GetHeight()
    local iconSize = height * 0.7

    if not btn.icon then
        btn.icon = btn:CreateTexture(nil, "ARTWORK")
        btn.icon:SetSize(iconSize, iconSize)
        btn.icon:SetPoint(Addon.FramePoint.LEFT, (height - iconSize) / 2, 0)
        btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    btn.icon:SetTexture(iconPath)

    if not btn.iconBorder then
        btn.iconBorder = CreateFrame("Frame", nil, btn, "BackdropTemplate")
        btn.iconBorder:SetBackdrop({ edgeFile = "Interface/Buttons/WHITE8X8", edgeSize = 1 })
        btn.iconBorder:SetBackdropBorderColor(unpack(style.borderColor))
        btn.iconBorder:SetBackdropColor(0, 0, 0, 0)
        btn.iconBorder:SetFrameLevel(btn:GetFrameLevel() + 1)
    end
end

---@param parent Frame
---@return Frame
function Widgets:createScrollBar(parent)
    -- Create the Scroll Bar
    local scrollBarWidth = 20
    local scrollBarHeightOffset = 18
    local scrollBarFrame = CreateFrame("Slider", nil, parent, "UIPanelScrollBarTemplate")
    scrollBarFrame:SetSize(scrollBarWidth, parent:GetHeight() - (scrollBarHeightOffset * 2))
    scrollBarFrame:SetPoint(Addon.FramePoint.TOPRIGHT, parent, Addon.FramePoint.TOPRIGHT, 0, scrollBarHeightOffset * -1)

    -- Create the Scroll Bar Background
    local scrollBarBackgroundWidth = scrollBarWidth + 1
    local scrollBarBackgroundFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    scrollBarBackgroundFrame:SetSize(scrollBarBackgroundWidth, parent:GetHeight())
    scrollBarBackgroundFrame:SetBackdrop({
        bgFile = style.innerPanel.backgroundFile,
        edgeFile = style.innerPanel.borderFile,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    scrollBarBackgroundFrame:SetBackdropColor(unpack(style.backgroundColor))
    scrollBarBackgroundFrame:SetBackdropBorderColor(unpack(style.borderColor))
    scrollBarBackgroundFrame:SetPoint(Addon.FramePoint.TOPRIGHT, parent, Addon.FramePoint.TOPRIGHT, 0, 0)

    -- Create the Scroll Frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent)
    scrollFrame:SetPoint(Addon.FramePoint.TOPLEFT, parent, Addon.FramePoint.TOPLEFT, 0, 0)
    scrollFrame:SetPoint(Addon.FramePoint.BOTTOMRIGHT, scrollBarBackgroundFrame, Addon.FramePoint.BOTTOMLEFT, 0, 0)
    scrollFrame:EnableMouseWheel(true)

    -- Create the content of the Scroll Frame
    local scrollContentFrameWidth = parent:GetWidth() - scrollBarBackgroundWidth
    local scrollContentFrame = CreateFrame("Frame", nil, scrollFrame)
    scrollContentFrame:SetSize(scrollContentFrameWidth, parent:GetHeight() * 2)
    scrollFrame:SetScrollChild(scrollContentFrame)

    -- Wire scrollbar -> scroll frame
    scrollBarFrame:SetScript("OnValueChanged", function(self, value)
        scrollFrame:SetVerticalScroll(value)
    end)

    -- Optional: mouse wheel -> scrollbar
    scrollFrame:SetScript("OnMouseWheel", function(_, delta)
        local step = 20
        local cur = scrollBarFrame:GetValue()
        scrollBarFrame:SetValue(cur - delta * step)
    end)

    -- Keep range in sync
    local function UpdateScrollRange()
        local viewH = scrollFrame:GetHeight()
        local childH = scrollFrame:GetScrollChild():GetHeight()
        local max = math.max(0, childH - viewH)
        scrollBarFrame:SetMinMaxValues(0, max)
        scrollBarFrame:SetValue(math.min(scrollBarFrame:GetValue(), max))
    end

    scrollFrame:HookScript("OnSizeChanged", UpdateScrollRange)
    scrollContentFrame:HookScript("OnSizeChanged", UpdateScrollRange)
    UpdateScrollRange()

    return scrollContentFrame
end

function Addon:createDropdown(parent, labelText, options, config)
    local groupFrame = CreateFrame("Frame", nil, parent)
    groupFrame:SetSize(config.width or 180, 40) -- adjust height to fit label+dropdown

    -- Label
    local label = groupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint(Addon.FramePoint.TOPLEFT, groupFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    label:SetText(labelText or "")

    -- Dropdown
    local dropdown = CreateFrame("Frame", nil, groupFrame, "UIDropDownMenuTemplate")
    dropdown:SetPoint(Addon.FramePoint.TOPLEFT, label, Addon.FramePoint.BOTTOMLEFT, -16, -6)
    UIDropDownMenu_SetWidth(dropdown, config.width or 180)
    UIDropDownMenu_SetText(dropdown, config.placeholder or "Select...")

    local function normalizeOptions(opts)
        local list = {}
        if not opts then return list end
        if #opts > 0 then
            return opts -- already array
        end
        for value, text in pairs(opts) do
            table.insert(list, { value = value, text = text })
        end
        return list
    end

    local function initDropdown(opts, onSelect)
        local list = normalizeOptions(opts)
        UIDropDownMenu_Initialize(dropdown, function(_, level)
            for _, opt in ipairs(list) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = opt.text
                info.value = opt.value
                info.checked = (UIDropDownMenu_GetSelectedValue(dropdown) == opt.value)
                info.func = function()
                    UIDropDownMenu_SetSelectedValue(dropdown, opt.value)
                    UIDropDownMenu_SetText(dropdown, opt.text)
                    if onSelect then
                        onSelect(opt.value, opt.text)
                    end
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        if config.selectedValue then
            UIDropDownMenu_SetSelectedValue(dropdown, config.selectedValue)
            UIDropDownMenu_SetText(dropdown, config.selectedValue)
        end
    end

    initDropdown(options, config.onSelect)

    return groupFrame, initDropdown
end

function Addon:getSectionHeader(parent, text, width)
    local dividerThickness = 2

    local groupFrame = CreateFrame("Frame", nil, parent)

    -- Label
    local label = groupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint(Addon.FramePoint.TOPLEFT, groupFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    label:SetText(text or "")
    groupFrame:SetSize(width, label:GetStringHeight() + 10 + dividerThickness)

    local divider = groupFrame:CreateTexture(nil, "BORDER")
    divider:SetPoint(Addon.FramePoint.TOPLEFT, label, Addon.FramePoint.BOTTOMLEFT, 0, -10)
    divider:SetSize(width, dividerThickness)
    divider:SetColorTexture(0.3, 0.3, 0.3, 1)

    return groupFrame
end

function Addon:createTextField(parent, labelText, config)
    config = config or {}

    local groupFrame = CreateFrame("Frame", nil, parent)
    groupFrame:SetSize(config.width or 180, 40)

    local label = groupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint(Addon.FramePoint.TOPLEFT, groupFrame, Addon.FramePoint.TOPLEFT, 0, 0)
    label:SetText(labelText or "")

    local editBox = CreateFrame("EditBox", nil, groupFrame, "InputBoxTemplate")
    editBox:SetAutoFocus(false)
    editBox:SetSize(config.width or 180, config.height or 20)
    editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 5, -6)

    if config.placeholder then editBox:SetText(config.placeholder) end
    if config.text then editBox:SetText(config.text) end

    local function clampNumber(n)
        if config.min and n < config.min then return config.min end
        if config.max and n > config.max then return config.max end
        return n
    end

    local function sanitizeNumber(text)
        -- allow digits, optional minus and dot
        local cleaned = text:gsub("[^%d%-%.]", "")
        return cleaned
    end

    local function applyNumericRules(text)
        if text == "" and config.allowEmpty then
            return ""
        end

        local n = tonumber(text)
        if not n then
            return config.allowEmpty and "" or tostring(config.min or 0)
        end

        if config.clamp then
            n = clampNumber(n)
        end
        return tostring(n)
    end

    local function initTextField(onChange, onEnterPressed)
        editBox:SetScript("OnTextChanged", function(self, userInput)
            local text = self:GetText()

            if config.numericOnly and userInput then
                local cleaned = sanitizeNumber(text)
                if cleaned ~= text then
                    self:SetText(cleaned)
                    self:SetCursorPosition(#cleaned)
                    text = cleaned
                end
            end

            if onChange and userInput then
                if config.numericOnly then
                    onChange(tonumber(text), text)
                else
                    onChange(text)
                end
            end
        end)

        editBox:SetScript("OnEnterPressed", function(self)
            local text = self:GetText()
            if config.numericOnly then
                local finalText = applyNumericRules(text)
                self:SetText(finalText)
                if onEnterPressed then
                    onEnterPressed(tonumber(finalText), finalText)
                end
            else
                if onEnterPressed then
                    onEnterPressed(text)
                end
            end
            self:ClearFocus()
        end)
    end

    if config.onChange or config.onEnterPressed or config.numericOnly then
        initTextField(config.onChange, config.onEnterPressed)
    end

    return groupFrame, initTextField
end

---@param parent Frame
---@param labelText string
---@param config table|nil
---@return Frame
---@return fun(checked:boolean, enabled:boolean|nil)
function Widgets:createCheckbox(parent, labelText, config)
    config = config or {}

    local groupFrame = CreateFrame("Frame", nil, parent)
    groupFrame:SetSize(config.width or 220, config.height or 24)

    local checkbox = CreateFrame("CheckButton", nil, groupFrame, "UICheckButtonTemplate")
    checkbox:SetPoint(Addon.FramePoint.LEFT, groupFrame, Addon.FramePoint.LEFT, 0, 0)
    checkbox:SetChecked(config.checked == true)

    local label = groupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint(Addon.FramePoint.LEFT, checkbox, Addon.FramePoint.RIGHT, 4, 0)
    label:SetText(labelText or "")

    if config.tooltip then
        checkbox.tooltipText = config.tooltip
    end

    local function setEnabled(enabled)
        if enabled == false then
            checkbox:Disable()
            label:SetTextColor(0.5, 0.5, 0.5)
        else
            checkbox:Enable()
            label:SetTextColor(1, 0.82, 0)
        end
    end

    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked() == true
        if config.onChange then
            config.onChange(checked)
        end
    end)

    if config.enabled ~= nil then
        setEnabled(config.enabled)
    end

    local function initCheckbox(checked, enabled)
        checkbox:SetChecked(checked == true)
        if enabled ~= nil then
            setEnabled(enabled)
        end
    end

    groupFrame.checkbox = checkbox
    groupFrame.label = label

    return groupFrame, initCheckbox
end

Addon.Widgets = Widgets
return Widgets