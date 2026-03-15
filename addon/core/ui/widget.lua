---@type Addon
local Addon = select(2, ...)

---@class Widget
local Widget = {}

---@param parent Frame
---@return Frame
function Widget:createScrollBar(parent)
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
        bgFile = Addon.Styling.background.texture2,
        edgeFile = Addon.Styling.background.borderTexture2,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    scrollBarBackgroundFrame:SetBackdropColor(unpack(Addon.Styling.background.color1))
    scrollBarBackgroundFrame:SetBackdropBorderColor(unpack(Addon.Styling.background.borderColor1))
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

---@param text string
---@param width number
function Widget:createSectionHeader(text)
    local dividerThickness = 2
    local spacing = 10

    local sectionHeader = CreateFrame("Frame", nil, UIParent)
    sectionHeader:Hide()

    -- Label
    local label = sectionHeader:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", sectionHeader, "TOPLEFT", 0, 0)
    label:SetPoint("TOPRIGHT", sectionHeader, "TOPRIGHT", 0, 0)
    label:SetJustifyH("LEFT")
    label:SetText(text or "")

    local divider = sectionHeader:CreateTexture(nil, "BORDER")
    divider:SetPoint(Addon.FramePoint.TOPLEFT, label, Addon.FramePoint.BOTTOMLEFT, 0, -spacing)
    divider:SetPoint(Addon.FramePoint.TOPRIGHT, label, Addon.FramePoint.BOTTOMRIGHT, 0, -spacing)
    divider:SetColorTexture(0.3, 0.3, 0.3, 1)

    sectionHeader:SetHeight(label:GetStringHeight() + spacing + dividerThickness)

    return sectionHeader
end

function Widget:createTextField(labelText, config)
    config = config or {}
    local spacing = 6
    local editBoxHeight = config.height or 20

    local groupFrame = CreateFrame("Frame", nil, UIParent)
    groupFrame:Hide()
    -- Don't SetWidth; it will be inherited via anchoring later.
    -- Set height to cover label + spacing + editbox
    groupFrame:SetHeight(12 + spacing + editBoxHeight)

    local label = groupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", groupFrame, "TOPLEFT", 0, 0)
    label:SetPoint("TOPRIGHT", groupFrame, "TOPRIGHT", 0, 0)
    label:SetJustifyH("LEFT")
    label:SetText(labelText or "")

    local editBox = CreateFrame("EditBox", nil, groupFrame, "InputBoxTemplate")
    editBox:SetAutoFocus(false)
    editBox:SetHeight(editBoxHeight)
    -- Anchor both sides to the groupFrame (with slight offsets for InputBoxTemplate visuals)
    editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 5, -spacing)
    editBox:SetPoint("TOPRIGHT", groupFrame, "TOPRIGHT", -5, -spacing)

    if config.placeholder or config.text then
        editBox:SetText(config.placeholder or config.text)
    end

    -- Internal Logic Helpers
    local function applyNumericRules(text)
        if text == "" and config.allowEmpty then return "" end
        local n = tonumber(text) or (config.min or 0)
        if config.clamp then
            n = math.max(config.min or n, math.min(config.max or n, n))
        end
        return tostring(n)
    end

    -- Setup Scripts
    editBox:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        local text = self:GetText()

        if config.numericOnly then
            local cleaned = text:gsub("[^%d%-%.]", "")
            if cleaned ~= text then
                self:SetText(cleaned)
                text = cleaned
            end
        end

        if config.onChange then
            config.onChange(config.numericOnly and tonumber(text) or text)
        end
    end)

    editBox:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        if config.numericOnly then
            text = applyNumericRules(text)
            self:SetText(text)
        end
        if config.onEnterPressed then
            config.onEnterPressed(config.numericOnly and tonumber(text) or text)
        end
        self:ClearFocus()
    end)

    return groupFrame, editBox
end

function Widget:createDropdown(labelText, config)
    config = config or {}
    local options = config.options or {}
    local spacing = 6
    local dropdownHeight = 32

    local groupFrame = CreateFrame("Frame", nil, UIParent)
    groupFrame:Hide()
    -- Height covers Label (12) + Spacing (6) + Dropdown (32)
    groupFrame:SetHeight(12 + spacing + dropdownHeight)

    -- Label
    local label = groupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", groupFrame, "TOPLEFT", 0, 0)
    label:SetPoint("TOPRIGHT", groupFrame, "TOPRIGHT", 0, 0)
    label:SetJustifyH("LEFT")
    label:SetText(labelText or "")

    -- Dropdown (Using the standard Blizzard Template)
    local dropdown = CreateFrame("Frame", nil, groupFrame, "UIDropDownMenuTemplate")
    -- -16 offset aligns the visual text box with the label above it
    dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -16, -spacing)
    dropdown:SetPoint("TOPRIGHT", groupFrame, "TOPRIGHT", 0, -spacing)

    -- Internal Helper: Convert { value = text } to [{value, text}]
    local function getNormalizedOptions(opts)
        if not opts or #opts > 0 then return opts or {} end
        local list = {}
        for val, txt in pairs(opts) do table.insert(list, { value = val, text = txt }) end
        return list
    end

    -- Menu Initialization Logic
    local function updateMenu(newOptions)
        local currentOptions = getNormalizedOptions(newOptions or options)

        UIDropDownMenu_Initialize(dropdown, function(self, level)
            local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown)
            for _, opt in ipairs(currentOptions) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = opt.text
                info.value = opt.value
                info.arg1 = opt.value
                info.arg2 = opt.text
                info.func = function(btn, arg1, arg2)
                    UIDropDownMenu_SetSelectedValue(dropdown, arg1)
                    UIDropDownMenu_SetText(dropdown, arg2)
                    if config.onSelect then config.onSelect(arg1, arg2) end
                end
                info.checked = (selectedValue == opt.value)
                UIDropDownMenu_AddButton(info, level)
            end
        end)
    end

    -- Initial setup
    updateMenu()

    -- Set Initial Selection
    if config.selectedValue then
        UIDropDownMenu_SetSelectedValue(dropdown, config.selectedValue)
        -- Find text for the value or fallback to placeholder
        local initialText = config.placeholder or "Select..."
        for _, opt in ipairs(getNormalizedOptions(options)) do
            if opt.value == config.selectedValue then initialText = opt.text break end
        end
        UIDropDownMenu_SetText(dropdown, initialText)
    else
        UIDropDownMenu_SetText(dropdown, config.placeholder or "Select...")
    end

    UIDropDownMenu_JustifyText(dropdown, "LEFT")
    groupFrame.dropdown = dropdown

    -- Returns the container and the update function (for dynamic lists)
    return groupFrame, updateMenu
end

function Widget:createCheckbox(labelText, config)
    config = config or {}
    local boxSize = 26 -- Standard Blizzard CheckButton size

    local groupFrame = CreateFrame("Frame", nil, UIParent)
    groupFrame:Hide()
    groupFrame:SetHeight(boxSize)

    local checkbox = CreateFrame("CheckButton", nil, groupFrame, "UICheckButtonTemplate")
    checkbox:SetSize(boxSize, boxSize)
    checkbox:SetPoint("LEFT", groupFrame, "LEFT", 0, 0)
    checkbox:SetChecked(config.checked == true)

    local label = groupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
    label:SetPoint("RIGHT", groupFrame, "RIGHT", 0, 0)
    label:SetJustifyH("LEFT")
    label:SetText(labelText or "")

    if config.tooltip then
        checkbox.tooltipText = config.tooltip
    end

    -- Logic for enabling/disabling visuals
    local function setEnabled(enabled)
        if enabled == false then
            checkbox:Disable()
            label:SetTextColor(0.5, 0.5, 0.5)
        else
            checkbox:Enable()
            label:SetTextColor(1, 0.82, 0) -- GameFontNormal default gold
        end
    end

    -- Scripts
    checkbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        if config.onChange then
            config.onChange(isChecked)
        end
    end)

    -- Initial state
    if config.enabled ~= nil then setEnabled(config.enabled) end

    -- Return the frame and a refresh function
    local function updateCheckbox(checked, enabled)
        if checked ~= nil then checkbox:SetChecked(checked) end
        if enabled ~= nil then setEnabled(enabled) end
    end

    return groupFrame, updateCheckbox
end


Addon.Widget = Widget
return Widget