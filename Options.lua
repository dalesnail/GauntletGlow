local ADDON_NAME, ns = ...
local CursorGlow = ns.CursorGlow

------------------------------------------------------------------------------------
-- WINDOW LAYOUT CONSTANTS
------------------------------------------------------------------------------------
local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil
local PANEL_MIN_WIDTH = 820
local PANEL_MIN_HEIGHT = 560
local NAV_WIDTH = 130
local NAV_TOP_PADDING = 18
local CURSORS_LIST_WIDTH = 165
local PAGE_INSET_X = 8
local PAGE_HEADER_TOP = -22
local PAGE_HEADER_HEIGHT = 58

------------------------------------------------------------------------------------
-- WINDOW SIZE / OFFSET TUNING
------------------------------------------------------------------------------------
local WINDOW_RESIZE_OFFSET_X = -6 -- Resize grip x offset from the bottom-right frame corner.
local WINDOW_RESIZE_OFFSET_Y = 6 -- Resize grip y offset from the bottom-right frame corner.
local WINDOW_RESIZE_FRAME_LEVEL_OFFSET = 18 -- Resize grip stays above the default frame edge.

------------------------------------------------------------------------------------
-- SHARED COLOR / FONT HELPERS
------------------------------------------------------------------------------------
local GOLD_TEXT = { 1.00, 0.82, 0.00 }
local GOLD_TEXT_DIM = { 0.94, 0.80, 0.34 }
local BODY_TEXT = { 0.92, 0.88, 0.80 }
local MUTED_TEXT = { 0.72, 0.68, 0.60 }
local SECTION_TEXT = { 0.98, 0.92, 0.78 }
local PANEL_BORDER = { 0.70, 0.62, 0.45, 0.16 }
local PANEL_BACKGROUND_DARK = { 0.00, 0.00, 0.00, 0.20 }
local PANEL_HEADER_SHADE = { 0.18, 0.17, 0.14, 0.12 }
local PANEL_FOOTER_SHADE = { 0.00, 0.00, 0.00, 0.20 }
local SELECTED_FILL = { 0.22, 0.17, 0.08, 0.58 }
local SELECTED_BORDER = { 0.90, 0.77, 0.30, 0.00 }
local SUBTLE_HOVER_FILL = { 0.18, 0.14, 0.08, 0.10 }
local SUBTLE_IDLE_FILL = { 0.00, 0.00, 0.00, 0.00 }
local NAV_HOVER_FILL = { 0.22, 0.17, 0.08, 0.34 }
local CURSOR_HOVER_FILL = { 0.16, 0.13, 0.08, 0.10 }

local FONT_STYLES = {
    pageTitle = { template = "GameFontNormalLarge", size = 20, color = GOLD_TEXT, shadow = 0.95 },
    pageSubtitle = { template = "GameFontHighlight", size = 13, color = BODY_TEXT, shadow = 0.55 },
    sectionTitle = { template = "GameFontNormal", size = 14, color = SECTION_TEXT, shadow = 0.75 },
    body = { template = "GameFontHighlight", size = 13, color = BODY_TEXT, shadow = 0.45 },
    bodySmall = { template = "GameFontHighlightSmall", size = 12, color = BODY_TEXT, shadow = 0.35 },
    muted = { template = "GameFontHighlightSmall", size = 12, color = MUTED_TEXT, shadow = 0.25 },
    value = { template = "GameFontHighlight", size = 14, color = GOLD_TEXT, shadow = 0.75 },
    nav = { template = "GameFontNormalLarge", size = 19, color = { 0.54, 0.54, 0.54 }, shadow = 0.55 },
    navSelected = { template = "GameFontNormalLarge", size = 19, color = GOLD_TEXT, shadow = 0.85 },
    list = { template = "GameFontHighlightSmall", size = 12, color = { 0.54, 0.54, 0.54 }, shadow = 0.55 },
    listHover = { template = "GameFontHighlightSmall", size = 12, color = GOLD_TEXT, shadow = 0.80 },
    listSelected = { template = "GameFontNormal", size = 12, color = GOLD_TEXT, shadow = 0.55 },
}

------------------------------------------------------------------------------------
-- PAGE DEFINITIONS
------------------------------------------------------------------------------------
local PAGES = {
    { key = "general", title = "General" },
    { key = "cursors", title = "Cursors", subtitle = "Tweak cursors size and position" },
    { key = "appearance", title = "Appearance" },
    { key = "about", title = "About" },
}

------------------------------------------------------------------------------------
-- CURSOR STATE DATA
------------------------------------------------------------------------------------
local CURSOR_STATE_ORDER = {
    "DEFAULT",
    "ATTACK",
    "LOOT",
    "AUTOLOOT",
    "HERBALISM",
    "MINING",
    "FLIGHTMASTER",
    "BATTLEMASTER",
    "TRAINER",
    "DIRECTIONS_GUARD",
    "INNKEEPER",
    "STABLEMASTER",
    "MAILBOX",
    "SKINNABLE",
    "VENDOR",
    "SELL_ITEM",
    "REPAIR_VENDOR",
}

local CURSOR_STATE_LABELS = {
    AUTOLOOT = "Auto Loot",
    FLIGHTMASTER = "Flight Master",
    STABLEMASTER = "Stable Master",
    SELL_ITEM = "Sell Item",
    REPAIR_VENDOR = "Repair Vendor",
}

local CURSOR_STATE_CONFIG = {
    DEFAULT = {
        widthKey = "sizeX",
        heightKey = "sizeY",
        offsetXKey = "offsetX",
        offsetYKey = "offsetY",
    },
    ATTACK = {
        widthKey = "swordSizeX",
        heightKey = "swordSizeY",
        offsetXKey = "swordOffsetX",
        offsetYKey = "swordOffsetY",
    },
    LOOT = {
        widthKey = "lootSizeX",
        heightKey = "lootSizeY",
        offsetXKey = "lootOffsetX",
        offsetYKey = "lootOffsetY",
    },
    AUTOLOOT = {
        widthKey = "autoLootSizeX",
        heightKey = "autoLootSizeY",
        offsetXKey = "autoLootOffsetX",
        offsetYKey = "autoLootOffsetY",
    },
    HERBALISM = {
        widthKey = "herbSizeX",
        heightKey = "herbSizeY",
        offsetXKey = "herbOffsetX",
        offsetYKey = "herbOffsetY",
    },
    MINING = {
        widthKey = "miningSizeX",
        heightKey = "miningSizeY",
        offsetXKey = "miningOffsetX",
        offsetYKey = "miningOffsetY",
    },
    FLIGHTMASTER = {
        widthKey = "flightMasterSizeX",
        heightKey = "flightMasterSizeY",
        offsetXKey = "flightMasterOffsetX",
        offsetYKey = "flightMasterOffsetY",
    },
    BATTLEMASTER = {
        widthKey = "battlemasterSizeX",
        heightKey = "battlemasterSizeY",
        offsetXKey = "battlemasterOffsetX",
        offsetYKey = "battlemasterOffsetY",
    },
    TRAINER = {
        widthKey = "trainerSizeX",
        heightKey = "trainerSizeY",
        offsetXKey = "trainerOffsetX",
        offsetYKey = "trainerOffsetY",
    },
    DIRECTIONS_GUARD = {
        widthKey = "directionsGuardSizeX",
        heightKey = "directionsGuardSizeY",
        offsetXKey = "directionsGuardOffsetX",
        offsetYKey = "directionsGuardOffsetY",
    },
    INNKEEPER = {
        widthKey = "innkeeperSizeX",
        heightKey = "innkeeperSizeY",
        offsetXKey = "innkeeperOffsetX",
        offsetYKey = "innkeeperOffsetY",
    },
    STABLEMASTER = {
        widthKey = "stableMasterSizeX",
        heightKey = "stableMasterSizeY",
        offsetXKey = "stableMasterOffsetX",
        offsetYKey = "stableMasterOffsetY",
    },
    MAILBOX = {
        widthKey = "mailboxSizeX",
        heightKey = "mailboxSizeY",
        offsetXKey = "mailboxOffsetX",
        offsetYKey = "mailboxOffsetY",
    },
    SKINNABLE = {
        widthKey = "skinnableSizeX",
        heightKey = "skinnableSizeY",
        offsetXKey = "skinnableOffsetX",
        offsetYKey = "skinnableOffsetY",
    },
    VENDOR = {
        widthKey = "vendorSizeX",
        heightKey = "vendorSizeY",
        offsetXKey = "vendorOffsetX",
        offsetYKey = "vendorOffsetY",
    },
    SELL_ITEM = {
        widthKey = "sellItemSizeX",
        heightKey = "sellItemSizeY",
        offsetXKey = "sellItemOffsetX",
        offsetYKey = "sellItemOffsetY",
    },
    REPAIR_VENDOR = {
        widthKey = "repairVendorSizeX",
        heightKey = "repairVendorSizeY",
        offsetXKey = "repairVendorOffsetX",
        offsetYKey = "repairVendorOffsetY",
    },
}

local CURSOR_SLIDER_DEFS = {
    { id = "width", label = "Width", min = 16, max = 128, step = 1 },
    { id = "height", label = "Height", min = 16, max = 128, step = 1 },
    { id = "offsetX", label = "Offset X", min = -32, max = 32, step = 0.5 },
    { id = "offsetY", label = "Offset Y", min = -32, max = 32, step = 0.5 },
}

local sliderNameIndex = 0

------------------------------------------------------------------------------------
-- VERSION HELPER FUNCTION
------------------------------------------------------------------------------------
local function GetAddonMetadataValue(addonName, field)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(addonName, field)
    end

    if GetAddOnMetadata then
        return GetAddOnMetadata(addonName, field)
    end

    return nil
end

local function GetAddonDisplayTitle(addonName)
    return GetAddonMetadataValue(addonName, "Title") or addonName or "CursorGlow"
end

local function GetAddonVersion(addonName)
    return GetAddonMetadataValue(addonName, "Version") or "Unknown"
end

------------------------------------------------------------------------------------
-- SHARED TEXT STYLING
------------------------------------------------------------------------------------
local function ApplyFont(fontString, template, sizeOverride, flagsOverride, color, shadow)
    if not fontString then
        return
    end

    local fontObject = type(template) == "string" and _G[template] or template
    if fontObject then
        fontString:SetFontObject(fontObject)
    end

    if sizeOverride then
        local fontPath, _, fontFlags = fontString:GetFont()
        if fontPath then
            fontString:SetFont(fontPath, sizeOverride, flagsOverride or fontFlags)
        end
    end

    if color then
        fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
    end

    if shadow then
        fontString:SetShadowOffset(1, -1)
        fontString:SetShadowColor(0, 0, 0, shadow)
    else
        fontString:SetShadowOffset(0, 0)
        fontString:SetShadowColor(0, 0, 0, 0)
    end
end

local function CreateText(parent, template, text, style)
    local fontString = parent:CreateFontString(nil, "ARTWORK", template)
    fontString:SetJustifyH("LEFT")
    fontString:SetJustifyV("TOP")
    fontString:SetText(text or "")
    if style then
        ApplyFont(fontString, style.template or template, style.size, style.flags, style.color, style.shadow)
    else
        ApplyFont(fontString, template)
    end
    return fontString
end

local function StyleText(fontString, styleOrTemplate, color, shadow)
    if not fontString then
        return
    end

    if type(styleOrTemplate) == "table" and styleOrTemplate.template then
        ApplyFont(fontString, styleOrTemplate.template, styleOrTemplate.size, styleOrTemplate.flags, styleOrTemplate.color, styleOrTemplate.shadow)
    else
        ApplyFont(fontString, styleOrTemplate, nil, nil, color and { color[1], color[2], color[3], color[4] }, shadow)
    end
end

------------------------------------------------------------------------------------
-- FRAME SIZE / VISIBILITY STATE HELPERS
------------------------------------------------------------------------------------
local function ClampFrameSize(width, height)
    local clampedWidth = math.max(PANEL_MIN_WIDTH, math.floor((width or PANEL_MIN_WIDTH) + 0.5))
    local clampedHeight = math.max(PANEL_MIN_HEIGHT, math.floor((height or PANEL_MIN_HEIGHT) + 0.5))
    return clampedWidth, clampedHeight
end

local function SaveFrameSize(self, frame)
    if not self or not self.db or not self.db.profile or not frame then
        return
    end

    local width, height = ClampFrameSize(frame:GetWidth(), frame:GetHeight())
    self.db.profile.windowWidth = width
    self.db.profile.windowHeight = height
end

local function ApplyFrameSize(self, frame)
    if not self or not self.db or not self.db.profile or not frame then
        return
    end

    local width, height = ClampFrameSize(self.db.profile.windowWidth or 900, self.db.profile.windowHeight or 620)
    frame:SetSize(width, height)
end

local function EvaluateAndApplyCurrentState(self)
    if not self or not self.cursorGlow then
        return
    end

    self.currentVisible = nil
    local visible, state = self:EvaluateTrigger()
    self:ApplyVisibility(visible)

    if visible and state then
        self:ApplyState(state, true)
    end
end

local function GetAddonEnabled(self)
    return self.db and self.db.profile and self.db.profile.enabled
end

local function SetAddonEnabled(self, enabled)
    self.db.profile.enabled = enabled and true or false

    if not enabled then
        self.currentVisible = nil
        self:ApplyVisibility(false)
        return
    end

    EvaluateAndApplyCurrentState(self)
end

local function GetTestModeEnabled(self)
    return self.db and self.db.profile and self.db.profile.testMode
end

local function SetTestModeEnabled(self, enabled)
    self.db.profile.testMode = enabled and true or false

    if enabled then
        self:ApplyVisibility(true)
        self:ApplyState("DEFAULT", true)
        return
    end

    self.currentStateName = nil
    EvaluateAndApplyCurrentState(self)
end

------------------------------------------------------------------------------------
-- BASIC ROW / DIVIDER HELPERS
------------------------------------------------------------------------------------
local function CreateSeparator(parent, topAnchor)
    local line = parent:CreateTexture(nil, "BORDER")
    line:SetColorTexture(0.90, 0.78, 0.48, 0.16)
    line:SetPoint("TOPLEFT", topAnchor, "BOTTOMLEFT", 0, -12)
    line:SetPoint("TOPRIGHT", topAnchor, "BOTTOMRIGHT", 0, -12)
    line:SetHeight(1)
    return line
end

local function CreateCheckboxRow(parent, title, description)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(58)

    row.check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    row.check:SetPoint("TOPLEFT", 0, 0)

    row.label = CreateText(row, "GameFontNormal", title, FONT_STYLES.sectionTitle)
    row.label:SetPoint("TOPLEFT", row.check, "TOPRIGHT", 10, -3)
    row.label:SetPoint("RIGHT", row, "RIGHT", 0, 0)

    row.description = CreateText(row, "GameFontHighlightSmall", description, FONT_STYLES.body)
    row.description:SetPoint("TOPLEFT", row.label, "BOTTOMLEFT", 0, -5)
    row.description:SetPoint("RIGHT", row, "RIGHT", 0, 0)

    return row
end

------------------------------------------------------------------------------------
-- PANEL CHROME HELPERS
------------------------------------------------------------------------------------
local function CreateSimplePanel(parent)
    local panel = CreateFrame("Frame", nil, parent, BACKDROP_TEMPLATE)
    if panel.SetBackdrop then
        panel:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        panel:SetBackdropBorderColor(PANEL_BORDER[1], PANEL_BORDER[2], PANEL_BORDER[3], PANEL_BORDER[4])
    end

    panel.bg = panel:CreateTexture(nil, "BACKGROUND")
    panel.bg:SetAllPoints()
    panel.bg:SetTexture("Interface\\Buttons\\WHITE8x8")
    panel.bg:SetVertexColor(0, 0, 0, 0)
    panel.bg:Hide()

    panel.topShade = panel:CreateTexture(nil, "BORDER")
    panel.topShade:SetPoint("TOPLEFT", 1, -1)
    panel.topShade:SetPoint("TOPRIGHT", -1, -1)
    panel.topShade:SetHeight(54)
    panel.topShade:SetTexture("Interface\\Buttons\\WHITE8x8")
    panel.topShade:Hide()

    panel.bottomShade = panel:CreateTexture(nil, "ARTWORK")
    panel.bottomShade:SetPoint("BOTTOMLEFT", 1, 1)
    panel.bottomShade:SetPoint("BOTTOMRIGHT", -1, 1)
    panel.bottomShade:SetHeight(62)
    panel.bottomShade:SetTexture("Interface\\Buttons\\WHITE8x8")
    panel.bottomShade:Hide()

    panel.innerLine = panel:CreateTexture(nil, "OVERLAY")
    panel.innerLine:SetPoint("TOPLEFT", 1, -1)
    panel.innerLine:SetPoint("TOPRIGHT", -1, -1)
    panel.innerLine:SetHeight(1)
    panel.innerLine:SetColorTexture(1, 0.88, 0.60, 0.03)

    return panel
end

------------------------------------------------------------------------------------
-- SELECTED / UNSELECTED VISUAL STATE HELPERS
------------------------------------------------------------------------------------
local function CreateSelectableButtonChrome(button, accentWidth)
    if button.SetBackdrop then
        button:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        button:SetBackdropBorderColor(0, 0, 0, 0)
    end

    button.fill = button:CreateTexture(nil, "BACKGROUND")
    button.fill:SetPoint("TOPLEFT", 1, -1)
    button.fill:SetPoint("BOTTOMRIGHT", -1, 1)
    button.fill:SetTexture("Interface\\Buttons\\WHITE8x8")
    button.fill:SetVertexColor(SUBTLE_IDLE_FILL[1], SUBTLE_IDLE_FILL[2], SUBTLE_IDLE_FILL[3], SUBTLE_IDLE_FILL[4])

    button.hoverFill = button:CreateTexture(nil, "BORDER")
    button.hoverFill:SetPoint("TOPLEFT", 1, -1)
    button.hoverFill:SetPoint("BOTTOMRIGHT", -1, 1)
    button.hoverFill:SetTexture("Interface\\Buttons\\WHITE8x8")
    button.hoverFill:SetVertexColor(SUBTLE_HOVER_FILL[1], SUBTLE_HOVER_FILL[2], SUBTLE_HOVER_FILL[3], SUBTLE_HOVER_FILL[4])
    button.hoverFill:SetAlpha(0)

    button.accent = button:CreateTexture(nil, "ARTWORK")
    button.accent:SetPoint("TOPLEFT", 1, -1)
    button.accent:SetPoint("BOTTOMLEFT", 1, 1)
    button.accent:SetWidth(accentWidth or 3)
    button.accent:SetColorTexture(1, 0.83, 0.24, 1)
    button.accent:SetAlpha(0)
end

local function ApplySelectableButtonVisuals(button, selected, palette, normalTextStyle, hoverTextStyle, selectedTextStyle)
    if not button then
        return
    end

    button.selected = selected and true or false
    button.visualPalette = palette

    if button.fill then
        local fillColor = button.selected and palette.selectedFill or palette.normalFill
        button.fill:SetColorTexture(fillColor[1], fillColor[2], fillColor[3], fillColor[4] or 1)
    end

    if button.hoverFill then
        button.hoverFill:SetAlpha(0)
    end

    if button.accent then
        button.accent:SetAlpha((button.selected and palette.showSelectedAccent) and 1 or 0)
    end

    if button.SetBackdropBorderColor then
        button:SetBackdropBorderColor(0, 0, 0, 0)
    end

    StyleText(button.text, button.selected and selectedTextStyle or normalTextStyle)

    button:SetScript("OnEnter", function(selfButton)
        local currentPalette = selfButton.visualPalette or palette
        if selfButton.fill and not selfButton.selected then
            local fillColor = currentPalette.hoverFill or currentPalette.normalFill
            selfButton.fill:SetColorTexture(fillColor[1], fillColor[2], fillColor[3], fillColor[4] or 1)
        end

        if selfButton.hoverFill and not selfButton.selected and currentPalette.useHoverOverlay then
            selfButton.hoverFill:SetAlpha(1)
        end

        StyleText(selfButton.text, selfButton.selected and selectedTextStyle or hoverTextStyle)
    end)

    button:SetScript("OnLeave", function(selfButton)
        ApplySelectableButtonVisuals(
            selfButton,
            selfButton.selected,
            selfButton.visualPalette or palette,
            normalTextStyle,
            hoverTextStyle,
            selectedTextStyle
        )
    end)
end

------------------------------------------------------------------------------------
-- LEFT NAV ITEM STYLING
------------------------------------------------------------------------------------
local function CreateNavButton(parent, title)
    local button = CreateFrame("Button", nil, parent, BACKDROP_TEMPLATE)
    button:SetHeight(36)
    CreateSelectableButtonChrome(button, 3)

    button.text = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    button.text:SetPoint("LEFT", 14, 0)
    button.text:SetPoint("RIGHT", -12, 0)
    button.text:SetJustifyH("LEFT")
    button.text:SetJustifyV("MIDDLE")
    button.text:SetText(title)
    StyleText(button.text, FONT_STYLES.nav)

    button.SetSelected = function(selfButton, selected)
        ApplySelectableButtonVisuals(
            selfButton,
            selected,
            {
                normalFill = { 0, 0, 0, 0 },
                hoverFill = { 0, 0, 0, 0 },
                selectedFill = { 0, 0, 0, 0 },
                showSelectedAccent = false,
            },
            FONT_STYLES.nav,
            FONT_STYLES.navSelected,
            FONT_STYLES.navSelected
        )
    end

    button:SetSelected(false)

    return button
end

------------------------------------------------------------------------------------
-- CURSOR LIST ITEM STYLING
------------------------------------------------------------------------------------
local function CreateCursorStateButton(parent, title)
    local button = CreateFrame("Button", nil, parent, BACKDROP_TEMPLATE)
    button:SetHeight(22)
    CreateSelectableButtonChrome(button, 2)

    button.text = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    button.text:SetPoint("LEFT", 9, 0)
    button.text:SetPoint("RIGHT", -8, 0)
    button.text:SetJustifyH("LEFT")
    button.text:SetText(title)
    StyleText(button.text, FONT_STYLES.list)

    button.SetSelected = function(selfButton, selected)
        ApplySelectableButtonVisuals(
            selfButton,
            selected,
            {
                normalFill = { 0, 0, 0, 0 },
                hoverFill = { 0, 0, 0, 0 },
                selectedFill = { 0, 0, 0, 0 },
                showSelectedAccent = false,
            },
            FONT_STYLES.list,
            FONT_STYLES.listHover,
            FONT_STYLES.listSelected
        )
    end

    button:SetSelected(false)

    return button
end

------------------------------------------------------------------------------------
-- CURSOR STATE LABEL / VALUE HELPERS
------------------------------------------------------------------------------------
local function FormatCursorStateLabel(stateKey)
    if CURSOR_STATE_LABELS[stateKey] then
        return CURSOR_STATE_LABELS[stateKey]
    end

    local words = { strsplit("_", stateKey or "") }
    for index, word in ipairs(words) do
        words[index] = word:sub(1, 1) .. word:sub(2):lower()
    end

    return table.concat(words, " ")
end

local function GetCursorStateEntries()
    local entries = {}
    local seen = {}
    local states = ns.States or {}

    for _, stateKey in ipairs(CURSOR_STATE_ORDER) do
        if states[stateKey] then
            entries[#entries + 1] = {
                key = stateKey,
                label = FormatCursorStateLabel(stateKey),
            }
            seen[stateKey] = true
        end
    end

    for stateKey in pairs(states) do
        if not seen[stateKey] then
            entries[#entries + 1] = {
                key = stateKey,
                label = FormatCursorStateLabel(stateKey),
            }
        end
    end

    return entries
end

local function GetCursorStateConfig(stateKey)
    return CURSOR_STATE_CONFIG[stateKey]
end

local function GetCursorStateDefaultValue(self, stateKey, controlId)
    local config = GetCursorStateConfig(stateKey)
    if not config then
        return 0
    end

    local profileDefaults = self and self.db and self.db.defaults and self.db.defaults.profile
    local profileKey = config[controlId .. "Key"]
    if profileDefaults and profileDefaults[profileKey] ~= nil then
        return profileDefaults[profileKey]
    end

    local state = ns.States and ns.States[stateKey]
    if state then
        if controlId == "width" then
            return state.sizeX or 0
        elseif controlId == "height" then
            return state.sizeY or 0
        elseif controlId == "offsetX" then
            return state.offsetX or 0
        elseif controlId == "offsetY" then
            return state.offsetY or 0
        end
    end

    return 0
end

local function GetCursorStateValue(self, stateKey, controlId)
    local config = GetCursorStateConfig(stateKey)
    if not config or not self or not self.db or not self.db.profile then
        return 0
    end

    local profileKey = config[controlId .. "Key"]
    local value = self.db.profile[profileKey]
    if value == nil then
        value = GetCursorStateDefaultValue(self, stateKey, controlId)
    end

    return value
end

local function SetCursorStateValue(self, stateKey, controlId, value)
    local config = GetCursorStateConfig(stateKey)
    if not config or not self or not self.db or not self.db.profile then
        return
    end

    self.db.profile[config[controlId .. "Key"]] = value

    if self.RefreshActiveState then
        self:RefreshActiveState()
    end
end

local function ResetCursorStateToDefaults(self, stateKey)
    local config = GetCursorStateConfig(stateKey)
    if not config or not self or not self.db or not self.db.profile then
        return
    end

    for _, control in ipairs(CURSOR_SLIDER_DEFS) do
        local profileKey = config[control.id .. "Key"]
        self.db.profile[profileKey] = GetCursorStateDefaultValue(self, stateKey, control.id)
    end

    if self.RefreshActiveState then
        self:RefreshActiveState()
    end
end

local function FormatNumericValue(value)
    if math.abs(value - math.floor(value + 0.5)) < 0.001 then
        return tostring(math.floor(value + 0.5))
    end

    return string.format("%.1f", value)
end

------------------------------------------------------------------------------------
-- SLIDER VISUAL CONSTRUCTION
------------------------------------------------------------------------------------
local function CreateValueSlider(parent, labelText, minValue, maxValue, step)
    sliderNameIndex = sliderNameIndex + 1

    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(60)

    row.label = CreateText(row, "GameFontNormal", labelText, FONT_STYLES.sectionTitle)
    row.label:SetPoint("TOPLEFT", 0, 0)

    row.valueFrame = CreateFrame("Button", nil, row)
    row.valueFrame:SetPoint("TOPRIGHT", 2, 2)
    row.valueFrame:SetSize(56, 20)
    
    row.valueText = CreateText(row.valueFrame, "GameFontHighlight", "", FONT_STYLES.value)
    row.valueText:SetAllPoints()
    row.valueText:SetJustifyH("RIGHT")
    row.valueText:SetJustifyV("MIDDLE")
    
    row.valueEdit = CreateFrame("EditBox", nil, row.valueFrame, "InputBoxTemplate")
    row.valueEdit:SetPoint("TOPLEFT", -2, 2)
    row.valueEdit:SetPoint("BOTTOMRIGHT", 2, -2)
    row.valueEdit:SetAutoFocus(false)
    row.valueEdit:SetNumeric(false)
    row.valueEdit:SetJustifyH("RIGHT")
    row.valueEdit:SetJustifyV("MIDDLE")
    row.valueEdit:SetTextInsets(0, 0, 0, 0)
    row.valueEdit:SetMaxLetters(8)
    row.valueEdit:Hide()
    
    row.valueEdit:SetFontObject(GameFontHighlight)
    row.valueEdit:SetTextColor(GOLD_TEXT[1], GOLD_TEXT[2], GOLD_TEXT[3])
    row.valueEdit:SetShadowOffset(1, -1)
    row.valueEdit:SetShadowColor(0, 0, 0, 0.75)
    
    if row.valueEdit.Left then row.valueEdit.Left:Hide() end
    if row.valueEdit.Middle then row.valueEdit.Middle:Hide() end
    if row.valueEdit.Right then row.valueEdit.Right:Hide() end
    if row.valueEdit.LeftMiddle then row.valueEdit.LeftMiddle:Hide() end
    if row.valueEdit.RightMiddle then row.valueEdit.RightMiddle:Hide() end
    if row.valueEdit.MiddleMiddle then row.valueEdit.MiddleMiddle:Hide() end
    if row.valueEdit.TopLeft then row.valueEdit.TopLeft:Hide() end
    if row.valueEdit.TopRight then row.valueEdit.TopRight:Hide() end
    if row.valueEdit.TopMiddle then row.valueEdit.TopMiddle:Hide() end
    if row.valueEdit.BottomLeft then row.valueEdit.BottomLeft:Hide() end
    if row.valueEdit.BottomRight then row.valueEdit.BottomRight:Hide() end
    if row.valueEdit.BottomMiddle then row.valueEdit.BottomMiddle:Hide() end

    -- Toggle edit mode
    local function ShowEdit(self)
        self.valueText:Hide()
        self.valueEdit:Show()
        self.valueEdit:SetText(self.valueText:GetText())
        self.valueEdit:HighlightText()
        self.valueEdit:SetFocus()
    end

    local function HideEdit(self, apply)
        if apply then
            local text = self.valueEdit:GetText()
            local num = tonumber(text)

            if num then
                local minVal, maxVal = self.slider:GetMinMaxValues()
                num = math.max(minVal, math.min(maxVal, num))

                self.slider:SetValue(num)
            end
        end

        self.valueEdit:Hide()
        self.valueText:Show()
    end

    row.valueFrame:EnableMouse(true)
    row.valueFrame:SetScript("OnMouseDown", function()
        ShowEdit(row)
    end)

    row.valueEdit:SetScript("OnEnterPressed", function()
        HideEdit(row, true)
    end)

    row.valueEdit:SetScript("OnEscapePressed", function()
        HideEdit(row, false)
    end)

    row.valueEdit:SetScript("OnEditFocusLost", function()
        HideEdit(row, true)
    end)

    row.valueFrame:SetScript("OnEnter", function(self)
        row.valueText:SetAlpha(1)
    end)

    row.valueFrame:SetScript("OnLeave", function(self)
        row.valueText:SetAlpha(0.85)
    end)

    row.valueText:SetAlpha(0.85)

    row.slider = CreateFrame("Slider", "CursorGlowValueSlider" .. sliderNameIndex, row)
    row.slider:SetOrientation("HORIZONTAL")
    row.slider:SetPoint("TOPLEFT", row.label, "BOTTOMLEFT", 0, -11)
    row.slider:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, -24)
    row.slider:SetHeight(20)
    row.slider:SetMinMaxValues(minValue, maxValue)
    row.slider:SetValueStep(step)
    if row.slider.SetObeyStepOnDrag then
        row.slider:SetObeyStepOnDrag(true)
    end
    row.slider:EnableMouse(true)
    row.slider:SetThumbTexture("Interface\\Buttons\\WHITE8x8")

    row.slider.trackShadow = row.slider:CreateTexture(nil, "BACKGROUND")
    row.slider.trackShadow:SetPoint("LEFT", row.slider, "LEFT", 3, -1)
    row.slider.trackShadow:SetPoint("RIGHT", row.slider, "RIGHT", -3, -1)
    row.slider.trackShadow:SetHeight(8)
    row.slider.trackShadow:SetTexture("Interface\\Buttons\\WHITE8x8")
    row.slider.trackShadow:SetVertexColor(0, 0, 0, 0.30)

    row.slider.trackLeft = row.slider:CreateTexture(nil, "ARTWORK")
    row.slider.trackLeft:SetPoint("LEFT", row.slider, "LEFT", 0, 0)
    if row.slider.trackLeft.SetAtlas then
        row.slider.trackLeft:SetAtlas("Minimal_SliderBar_Left", true)
    else
        row.slider.trackLeft:SetTexture("Interface\\Buttons\\WHITE8x8")
        row.slider.trackLeft:SetSize(8, 8)
        row.slider.trackLeft:SetVertexColor(0.65, 0.65, 0.65, 1)
    end

    row.slider.trackRight = row.slider:CreateTexture(nil, "ARTWORK")
    row.slider.trackRight:SetPoint("RIGHT", row.slider, "RIGHT", 0, 0)
    if row.slider.trackRight.SetAtlas then
        row.slider.trackRight:SetAtlas("Minimal_SliderBar_Right", true)
    else
        row.slider.trackRight:SetTexture("Interface\\Buttons\\WHITE8x8")
        row.slider.trackRight:SetSize(8, 8)
        row.slider.trackRight:SetVertexColor(0.65, 0.65, 0.65, 1)
    end

    row.slider.trackMiddle = row.slider:CreateTexture(nil, "ARTWORK")
    row.slider.trackMiddle:SetPoint("LEFT", row.slider.trackLeft, "RIGHT", 0, 0)
    row.slider.trackMiddle:SetPoint("RIGHT", row.slider.trackRight, "LEFT", 0, 0)
    row.slider.trackMiddle:SetPoint("TOP", row.slider.trackLeft, "TOP", 0, 0)
    row.slider.trackMiddle:SetPoint("BOTTOM", row.slider.trackLeft, "BOTTOM", 0, 0)
    if row.slider.trackMiddle.SetAtlas then
        row.slider.trackMiddle:SetAtlas("_Minimal_SliderBar_Middle", false)
    else
        row.slider.trackMiddle:SetTexture("Interface\\Buttons\\WHITE8x8")
        row.slider.trackMiddle:SetVertexColor(0.65, 0.65, 0.65, 1)
    end

    local thumb = row.slider.GetThumbTexture and row.slider:GetThumbTexture()
    if thumb then
        if thumb.SetAtlas then
            thumb:SetAtlas("Minimal_SliderBar_Button", true)
        else
            thumb:SetTexture("Interface\\Buttons\\WHITE8x8")
            thumb:SetVertexColor(0.95, 0.78, 0.22, 1)
        end
        thumb:SetDrawLayer("OVERLAY", 1)
    end

    if thumb then
        row.slider.thumbGlow = row.slider:CreateTexture(nil, "ARTWORK", nil, 0)
        row.slider.thumbGlow:SetPoint("CENTER", thumb, "CENTER", 0, -1)
        row.slider.thumbGlow:SetSize(30, 30)

        if row.slider.thumbGlow.SetAtlas then
            row.slider.thumbGlow:SetAtlas("DK-Rune-Glow", false)
            row.slider.thumbGlow:SetVertexColor(GOLD_TEXT[1], GOLD_TEXT[2], GOLD_TEXT[3], 0.9)
        else
            row.slider.thumbGlow:SetTexture("Interface\\Buttons\\WHITE8x8")
            row.slider.thumbGlow:SetVertexColor(1.0, 0.82, 0.25, 0.20)
        end

        row.slider.thumbGlow:SetBlendMode("ADD")
        row.slider.thumbGlow:SetAlpha(0)
        row.slider.thumbGlow:Show()

        row.slider.thumbGlow.fadeIn = row.slider.thumbGlow:CreateAnimationGroup()
        local fadeIn = row.slider.thumbGlow.fadeIn:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.25)
        fadeIn:SetOrder(1)

        row.slider.thumbGlow.fadeOut = row.slider.thumbGlow:CreateAnimationGroup()
        local fadeOut = row.slider.thumbGlow.fadeOut:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.25)
        fadeOut:SetOrder(1)

        row.slider.thumbGlow.isVisible = false
    end

    row.slider:SetScript("OnUpdate", function(self)
        if not self.thumbGlow then
            return
        end

        local thumbTex = self:GetThumbTexture()
        if not thumbTex or not thumbTex:IsShown() then
            if self.thumbGlow.isVisible or self.thumbGlow:GetAlpha() > 0 then
                if self.thumbGlow.fadeIn:IsPlaying() then
                    self.thumbGlow.fadeIn:Stop()
                end
                if not self.thumbGlow.fadeOut:IsPlaying() then
                    self.thumbGlow.fadeOut:Play()
                end
                self.thumbGlow.isVisible = false
            end
            return
        end

        local mx, my = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        mx, my = mx / scale, my / scale

        local left = thumbTex:GetLeft()
        local right = thumbTex:GetRight()
        local top = thumbTex:GetTop()
        local bottom = thumbTex:GetBottom()

        if not (left and right and top and bottom) then
            return
        end

        local hoveringThumb = mx >= left and mx <= right and my >= bottom and my <= top

        if hoveringThumb then
            if not self.thumbGlow.isVisible then
                if self.thumbGlow.fadeOut:IsPlaying() then
                    self.thumbGlow.fadeOut:Stop()
                end
                self.thumbGlow.fadeIn:Stop()
                self.thumbGlow.fadeIn:Play()
                self.thumbGlow.isVisible = true
            end
        else
            if self.thumbGlow.isVisible then
                if self.thumbGlow.fadeIn:IsPlaying() then
                    self.thumbGlow.fadeIn:Stop()
                end
                self.thumbGlow.fadeOut:Stop()
                self.thumbGlow.fadeOut:Play()
                self.thumbGlow.isVisible = false
            end
        end
    end)

    row.slider.thumbGlow.fadeIn:SetScript("OnFinished", function()
        row.slider.thumbGlow:SetAlpha(1)
    end)

    row.slider.thumbGlow.fadeOut:SetScript("OnFinished", function()
        row.slider.thumbGlow:SetAlpha(0)
    end)

    function row:SetDisplayValue(value)
        self.valueText:SetText(FormatNumericValue(value))
    end

    return row
end

------------------------------------------------------------------------------------
-- PAGE LAYOUT
------------------------------------------------------------------------------------
local function CreatePage(parent, pageData)
    local page = CreateFrame("Frame", nil, parent)
    page:SetAllPoints()
    page:Hide()

    page.header = CreateFrame("Frame", nil, page)
    page.header:SetPoint("TOPLEFT", PAGE_INSET_X, PAGE_HEADER_TOP)
    page.header:SetPoint("TOPRIGHT", -PAGE_INSET_X, PAGE_HEADER_TOP)
    page.header:SetHeight(pageData.subtitle and PAGE_HEADER_HEIGHT or 28)

    page.title = CreateText(page.header, "GameFontNormalLarge", pageData.title, FONT_STYLES.pageTitle)
    page.title:SetPoint("TOPLEFT", 0, 0)
    page.title:SetPoint("TOPRIGHT", 0, 0)
    if pageData.subtitle then
        page.subtitle = CreateText(page.header, "GameFontHighlight", pageData.subtitle, FONT_STYLES.pageSubtitle)
        page.subtitle:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -6)
        page.subtitle:SetPoint("TOPRIGHT", page.title, "BOTTOMRIGHT", 0, -6)
    end

    page.body = CreateFrame("Frame", nil, page)
    page.body:SetPoint("TOPLEFT", page.header, "BOTTOMLEFT", 0, -18)
    page.body:SetPoint("TOPRIGHT", page.header, "BOTTOMRIGHT", 0, -18)
    page.body:SetPoint("BOTTOMLEFT", PAGE_INSET_X, 0)
    page.body:SetPoint("BOTTOMRIGHT", -PAGE_INSET_X, 0)

    return page
end

------------------------------------------------------------------------------------
-- GENERAL PAGE BUILD
------------------------------------------------------------------------------------
local function BuildGeneralPage(self, page)
    local intro = CreateText(page.body, "GameFontHighlight", "General settings for CursorGlow", FONT_STYLES.body)
    intro:SetPoint("TOPLEFT", 0, 0)
    intro:SetPoint("RIGHT", page.body, "RIGHT", 0, 0)

    page.enableRow = CreateCheckboxRow(page.body, "Enable", "Master toggle")
    page.enableRow:SetPoint("TOPLEFT", intro, "BOTTOMLEFT", 0, -18)
    page.enableRow:SetPoint("RIGHT", page.body, "RIGHT", 0, 0)
    page.enableRow.check:SetScript("OnClick", function(button)
        SetAddonEnabled(self, button:GetChecked())
        page:RefreshControls()
    end)

    page.testModeRow = CreateCheckboxRow(page.body, "Test Mode", "Keeps the default gauntlet glow shown on click for troubleshooting and alignment")
    page.testModeRow:SetPoint("TOPLEFT", page.enableRow, "BOTTOMLEFT", 0, -10)
    page.testModeRow:SetPoint("RIGHT", page.body, "RIGHT", 0, 0)
    page.testModeRow.check:SetScript("OnClick", function(button)
        SetTestModeEnabled(self, button:GetChecked())
        page:RefreshControls()
    end)

    page.note = CreateText(page.body, "GameFontHighlightSmall", "Additional controls will be added later as needed", FONT_STYLES.muted)
    page.note:SetPoint("TOPLEFT", page.testModeRow, "BOTTOMLEFT", 4, -14)
    page.note:SetPoint("RIGHT", page.body, "RIGHT", 0, 0)

    page.RefreshControls = function(currentPage)
        currentPage.enableRow.check:SetChecked(GetAddonEnabled(self))
        currentPage.testModeRow.check:SetChecked(GetTestModeEnabled(self))
    end
end

------------------------------------------------------------------------------------
-- REUSABLE INFO PANEL BUILD
------------------------------------------------------------------------------------
local function CreateSectionPanel(parent, title, bodyText)
    local panel = CreateSimplePanel(parent)
    panel:SetHeight(126)

    panel.title = CreateText(panel, "GameFontNormal", title, FONT_STYLES.sectionTitle)
    panel.title:SetPoint("TOPLEFT", 16, -14)
    panel.title:SetPoint("TOPRIGHT", -16, -14)

    panel.separator = CreateSeparator(panel, panel.title)

    panel.bodyText = CreateText(panel, "GameFontHighlightSmall", bodyText, FONT_STYLES.body)
    panel.bodyText:SetPoint("TOPLEFT", panel.separator, "BOTTOMLEFT", 0, -14)
    panel.bodyText:SetPoint("TOPRIGHT", -16, -38)
    panel.bodyText:SetJustifyV("TOP")

    return panel
end
------------------------------------------------------------------------------------
-- APPEARANCE PAGE BUILD
------------------------------------------------------------------------------------
local function BuildAppearancePage(page)
    page.intro = CreateText(page.body, "GameFontHighlight", " ", FONT_STYLES.body)
    page.intro:SetPoint("TOPLEFT", 0, 0)
    page.intro:SetPoint("TOPRIGHT", 0, 0)

    page.alphaSection = CreateSectionPanel(page.body, "Glow Alpha", "Placeholder -  to be added later")
    page.alphaSection:SetPoint("TOPLEFT", page.intro, "BOTTOMLEFT", 0, -18)
    page.alphaSection:SetPoint("TOPRIGHT", page.body, "TOPRIGHT", 0, -58)

    page.recolorSection = CreateSectionPanel(page.body, "Recoloring", "Placeholder -  to be added later")
    page.recolorSection:SetPoint("TOPLEFT", page.alphaSection, "BOTTOMLEFT", 0, -14)
    page.recolorSection:SetPoint("TOPRIGHT", page.body, "TOPRIGHT", 0, -190)

    page.previewSection = CreateSectionPanel(page.body, "Preview Behavior", "Placeholder -  to be added later")
    page.previewSection:SetPoint("TOPLEFT", page.recolorSection, "BOTTOMLEFT", 0, -14)
    page.previewSection:SetPoint("TOPRIGHT", page.body, "TOPRIGHT", 0, -322)

    page.RefreshControls = function()
    end
end

------------------------------------------------------------------------------------
-- CURSOR EDITOR STATE REFRESH
------------------------------------------------------------------------------------
local function RefreshCursorEditor(page)
    if not page or not page.selectedStateKey then
        return
    end

    local entry = page.stateLookup[page.selectedStateKey]
    if not entry then
        return
    end

    for _, control in ipairs(page.editorControls or {}) do
        local value = GetCursorStateValue(page.owner, page.selectedStateKey, control.controlId)
        control.isUpdating = true
        control.slider:SetValue(value)
        control:SetDisplayValue(value)
        control.isUpdating = false
    end
end

local function SelectCursorState(page, stateKey)
    if not page or not page.stateButtons or not page.stateLookup[stateKey] then
        return
    end

    page.selectedStateKey = stateKey

    for key, button in pairs(page.stateButtons) do
        button:SetSelected(key == stateKey)
    end

    local entry = page.stateLookup[stateKey]
    RefreshCursorEditor(page)
end

------------------------------------------------------------------------------------
-- CURSORS PAGE BUILD
------------------------------------------------------------------------------------
local function BuildCursorsPage(self, page)
    page.owner = self
    page.stateButtons = {}
    page.stateLookup = {}
    page.stateEntries = GetCursorStateEntries()

    page.leftPanel = CreateSimplePanel(page.body)
    page.leftPanel:SetPoint("TOPLEFT", 0, 0)
    page.leftPanel:SetPoint("BOTTOMLEFT", 0, 0)
    page.leftPanel:SetWidth(CURSORS_LIST_WIDTH)
    page.leftPanel.bg:Show()
    page.leftPanel.bg:SetVertexColor(0, 0, 0, 0.22)

    page.rightPanel = CreateSimplePanel(page.body)
    page.rightPanel:SetPoint("TOPLEFT", page.leftPanel, "TOPRIGHT", 16, 0)
    page.rightPanel:SetPoint("BOTTOMRIGHT", 0, 0)
    if page.rightPanel.SetBackdropBorderColor then
        page.rightPanel:SetBackdropBorderColor(0, 0, 0, 0)
    end
    if page.rightPanel.innerLine then
        page.rightPanel.innerLine:Hide()
    end

    page.leftTitle = CreateText(page.leftPanel, "GameFontNormal", "Cursor Types", FONT_STYLES.sectionTitle)
    page.leftTitle:SetPoint("TOPLEFT", 14, -14)
    page.leftTitle:SetPoint("TOPRIGHT", -14, -14)

    page.leftSeparator = CreateSeparator(page.leftPanel, page.leftTitle)

    page.listScroll = CreateFrame("ScrollFrame", nil, page.leftPanel, "UIPanelScrollFrameTemplate")
    page.listScroll:SetPoint("TOPLEFT", page.leftSeparator, "BOTTOMLEFT", 0, -12)
    page.listScroll:SetPoint("BOTTOMRIGHT", page.leftPanel, "BOTTOMRIGHT", -28, 12)

    page.listContent = CreateFrame("Frame", nil, page.listScroll)
    page.listContent:SetPoint("TOPLEFT", 0, 0)
    page.listContent:SetWidth(CURSORS_LIST_WIDTH - 40)
    page.listScroll:SetScrollChild(page.listContent)

    page.editorControls = {}

    local previousControl
    for _, controlDef in ipairs(CURSOR_SLIDER_DEFS) do
        local control = CreateValueSlider(page.rightPanel, controlDef.label, controlDef.min, controlDef.max, controlDef.step)
        if previousControl then
            control:SetPoint("TOPLEFT", previousControl, "BOTTOMLEFT", 0, -20)
            control:SetPoint("TOPRIGHT", previousControl, "BOTTOMRIGHT", 0, -20)
        else
            control:SetPoint("TOPLEFT", page.rightPanel, "TOPLEFT", 36, -34)
            control:SetPoint("TOPRIGHT", page.rightPanel, "TOPRIGHT", -26, -10)
        end

        control.controlId = controlDef.id
        local controlStep = controlDef.step or 1
        local currentControl = control
        control.slider:SetScript("OnValueChanged", function(_, value)
            if currentControl.isUpdating or not page.selectedStateKey then
                return
            end

            local roundedValue = math.floor((value / controlStep) + 0.5) * controlStep
            currentControl:SetDisplayValue(roundedValue)
            SetCursorStateValue(self, page.selectedStateKey, currentControl.controlId, roundedValue)
        end)

        page.editorControls[#page.editorControls + 1] = control
        previousControl = control
    end

    page.resetButton = CreateFrame("Button", nil, page.rightPanel, "UIPanelButtonTemplate")
    page.resetButton:SetSize(140, 24)
    page.resetButton:SetText("Reset to Defaults")
    page.resetButton:SetPoint("TOPLEFT", previousControl, "BOTTOMLEFT", 2, -22)
    page.resetButton:SetScript("OnClick", function()
        if not page.selectedStateKey then
            return
        end

        ResetCursorStateToDefaults(self, page.selectedStateKey)
        RefreshCursorEditor(page)
    end)

    local previousButton
    for _, entry in ipairs(page.stateEntries) do
        local button = CreateCursorStateButton(page.listContent, entry.label)
        button:SetWidth(CURSORS_LIST_WIDTH - 48)

        if previousButton then
            button:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, -6)
        else
            button:SetPoint("TOPLEFT", 0, 0)
        end

        button:SetScript("OnClick", function()
            SelectCursorState(page, entry.key)
        end)

        page.stateButtons[entry.key] = button
        page.stateLookup[entry.key] = entry
        previousButton = button
    end

    if previousButton then
        page.listContent:SetHeight((#page.stateEntries * 22) + ((#page.stateEntries - 1) * 6))
    else
        page.listContent:SetHeight(1)
    end

    page.RefreshControls = function(currentPage)
        if not currentPage.selectedStateKey and currentPage.stateEntries[1] then
            currentPage.selectedStateKey = currentPage.stateEntries[1].key
        end

        if currentPage.selectedStateKey then
            SelectCursorState(currentPage, currentPage.selectedStateKey)
        end
    end
end

------------------------------------------------------------------------------------
-- ABOUT PAGE BUILD
------------------------------------------------------------------------------------
local function BuildAboutPage(page)
    local version = GetAddonVersion(ADDON_NAME)
    local addonTitle = GetAddonDisplayTitle(ADDON_NAME)

    page.summary = CreateSimplePanel(page.body)
    page.summary:SetPoint("TOPLEFT", 0, 0)
    page.summary:SetPoint("TOPRIGHT", 0, 0)
    page.summary:SetHeight(112)

    local labelX = 16
    local valueX = 152
    local rowTop = -14
    local rowGap = -10

    page.addonLabel = CreateText(page.summary, "GameFontNormal", "Addon Name", FONT_STYLES.sectionTitle)
    page.addonLabel:SetPoint("TOPLEFT", labelX, rowTop)

    page.addonValue = CreateText(page.summary, "GameFontHighlight", addonTitle, FONT_STYLES.body)
    page.addonValue:SetPoint("TOPLEFT", valueX, rowTop)
    page.addonValue:SetPoint("RIGHT", page.summary, "RIGHT", -16, 0)

    page.versionLabel = CreateText(page.summary, "GameFontNormal", "Version", FONT_STYLES.sectionTitle)
    page.versionLabel:SetPoint("TOPLEFT", page.addonLabel, "BOTTOMLEFT", 0, rowGap)

    page.versionValue = CreateText(page.summary, "GameFontHighlight", version, FONT_STYLES.body)
    page.versionValue:SetPoint("TOPLEFT", valueX, -38)
    page.versionValue:SetPoint("RIGHT", page.summary, "RIGHT", -16, 0)

    page.commandsLabel = CreateText(page.summary, "GameFontNormal", "Commands", FONT_STYLES.sectionTitle)
    page.commandsLabel:SetPoint("TOPLEFT", page.versionLabel, "BOTTOMLEFT", 0, rowGap)

    page.commandsValue = CreateText(page.summary, "GameFontHighlight", "/cg or /cursorglow", FONT_STYLES.body)
    page.commandsValue:SetPoint("TOPLEFT", valueX, -62)
    page.commandsValue:SetPoint("RIGHT", page.summary, "RIGHT", -16, 0)

    page.help = CreateSectionPanel(page.body, "Notes", "Placeholder -  to be added later")
    page.help:SetPoint("TOPLEFT", page.summary, "BOTTOMLEFT", 0, -12)
    page.help:SetPoint("TOPRIGHT", page.body, "TOPRIGHT", 0, -124)

    page.RefreshControls = function(currentPage)
        currentPage.addonValue:SetText(GetAddonDisplayTitle(ADDON_NAME))
        currentPage.versionValue:SetText(GetAddonVersion(ADDON_NAME))
    end
end

------------------------------------------------------------------------------------
-- PAGE SWITCHING
------------------------------------------------------------------------------------
local function SelectPage(self, pageKey)
    local frame = self.configFrame
    if not frame then
        return
    end

    for key, page in pairs(frame.pages) do
        local isSelected = key == pageKey
        page:SetShown(isSelected)
        if isSelected and page.RefreshControls then
            page:RefreshControls()
        end
    end

    for key, button in pairs(frame.navButtons) do
        button:SetSelected(key == pageKey)
    end

    frame.currentPage = pageKey
end

------------------------------------------------------------------------------------
-- RESIZE / MINIMUM SIZE HANDLING
------------------------------------------------------------------------------------
local function CreateResizeGrip(frame, onStop)
    local grip = CreateFrame("Button", nil, frame)
    grip:SetSize(16, 16)
    grip:SetPoint("BOTTOMRIGHT", WINDOW_RESIZE_OFFSET_X, WINDOW_RESIZE_OFFSET_Y)

    grip.texture = grip:CreateTexture(nil, "ARTWORK")
    grip.texture:SetAllPoints()
    grip.texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

    grip:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then
            return
        end

        frame:StartSizing("BOTTOMRIGHT")
    end)

    grip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        if onStop then
            onStop()
        end
    end)

    return grip
end

------------------------------------------------------------------------------------
-- WINDOW CREATION
------------------------------------------------------------------------------------
local function CreateConfigFrame(self)
    if self.configFrame then
        return self.configFrame
    end

    local frame = CreateFrame("Frame", "CursorGlowConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    ApplyFrameSize(self, frame)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:Hide()

    if frame.SetMinResize then
        frame:SetMinResize(PANEL_MIN_WIDTH, PANEL_MIN_HEIGHT)
    end
    if frame.SetResizeBounds then
        frame:SetResizeBounds(PANEL_MIN_WIDTH, PANEL_MIN_HEIGHT)
    end

    ------------------------------------------------------------------------------------
    -- BLIZZARD FRAME CHROME RESTORATION
    ------------------------------------------------------------------------------------
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(panel)
        panel:StopMovingOrSizing()
        SaveFrameSize(self, panel)
    end)

    if frame.Bg then
        frame.Bg:Hide()
        frame.Bg:SetAlpha(0)
    end
    if frame.TopTileStreaks then
        frame.TopTileStreaks:Show()
        frame.TopTileStreaks:SetAlpha(1)
    end
    if frame.Inset and frame.Inset.Bg then
        frame.Inset.Bg:Hide()
        frame.Inset.Bg:SetAlpha(0)
    end
    if frame.Inset and frame.Inset.NineSlice then
        frame.Inset.NineSlice:Show()
    end
    if frame.NineSlice then
        frame.NineSlice:Show()
    end
    if frame.TitleBg then
        frame.TitleBg:Show()
    end
    if frame.TitleText then
        frame.TitleText:Show()
        frame.TitleText:SetText("CursorGlow")
        frame.TitleText:ClearAllPoints()
        frame.TitleText:SetPoint("TOP", frame, "TOP", 0, -6)
    end

    ------------------------------------------------------------------------------------
    -- CUSTOM BACKGROUND HOST / ATLAS BACKGROUND
    ------------------------------------------------------------------------------------
    frame.surfaceHost = CreateFrame("Frame", nil, frame)
    frame.surfaceHost:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -22)
    frame.surfaceHost:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, 3)

    ------------------------------------------------------------------------------------
    -- PRIMARY WINDOW BACKGROUND
    ------------------------------------------------------------------------------------

    local surfaceParent = frame.surfaceHost
    frame.surfaceBase = surfaceParent:CreateTexture(nil, "BACKGROUND", nil, 0)
    frame.surfaceBase:SetAllPoints(surfaceParent)
    frame.surfaceBase:SetTexture("Interface\\Buttons\\WHITE8x8")
    frame.surfaceBase:SetVertexColor(0, 0, 0, 0)

    frame.surfaceAtlas = surfaceParent:CreateTexture(nil, "BACKGROUND", nil, 1)
    frame.surfaceAtlas:SetAllPoints(surfaceParent)
    -- Force atlas ABOVE Blizzard background layers
    frame.surfaceAtlas:SetDrawLayer("ARTWORK", 0)

    if frame.surfaceAtlas.SetAtlas then
        frame.surfaceAtlas:SetAtlas("auctionhouse-background-index", false)
        frame.surfaceAtlas:SetTexCoord(0, 1, 0, 1)
        frame.surfaceAtlas:SetVertexColor(1, 1, 1, 1)
    else
        frame.surfaceAtlas:SetTexture("Interface\\Buttons\\WHITE8x8")
        frame.surfaceAtlas:SetVertexColor(0.12, 0.12, 0.13, 1)
    end

    frame.surfaceOverlay = surfaceParent:CreateTexture(nil, "BORDER")
    frame.surfaceOverlay:SetAllPoints(surfaceParent)
    frame.surfaceOverlay:SetTexture("Interface\\Buttons\\WHITE8x8")
    frame.surfaceOverlay:Hide()
    
    frame.surfaceTopFade = surfaceParent:CreateTexture(nil, "ARTWORK")
    frame.surfaceTopFade:SetPoint("TOPLEFT", surfaceParent, "TOPLEFT", 0, 0)
    frame.surfaceTopFade:SetPoint("TOPRIGHT", surfaceParent, "TOPRIGHT", 0, 0)
    frame.surfaceTopFade:SetHeight(88)
    frame.surfaceTopFade:SetTexture("Interface\\Buttons\\WHITE8x8")
    frame.surfaceTopFade:Hide()
    
    frame.surfaceBottomFade = surfaceParent:CreateTexture(nil, "ARTWORK")
    frame.surfaceBottomFade:SetPoint("BOTTOMLEFT", surfaceParent, "BOTTOMLEFT", 0, 0)
    frame.surfaceBottomFade:SetPoint("BOTTOMRIGHT", surfaceParent, "BOTTOMRIGHT", 0, 0)
    frame.surfaceBottomFade:SetHeight(90)
    frame.surfaceBottomFade:SetTexture("Interface\\Buttons\\WHITE8x8")
    frame.surfaceBottomFade:Hide()

    frame:SetScript("OnShow", function(panel)
        ApplyFrameSize(self, panel)
        SelectPage(self, panel.currentPage or PAGES[1].key)
    end)

    frame:SetScript("OnHide", function(panel)
        SaveFrameSize(self, panel)
    end)

    frame:SetScript("OnSizeChanged", function(panel, width, height)
        local clampedWidth, clampedHeight = ClampFrameSize(width, height)
        if not panel.enforcingSize and (math.abs(width - clampedWidth) > 0.5 or math.abs(height - clampedHeight) > 0.5) then
            panel.enforcingSize = true
            panel:SetSize(clampedWidth, clampedHeight)
            panel.enforcingSize = false
            return
        end
    end)

    ------------------------------------------------------------------------------------
    -- LEFT NAV
    ------------------------------------------------------------------------------------
    frame.navFrame = CreateFrame("Frame", nil, frame.Inset or frame)
    frame.navFrame:SetPoint("TOPLEFT", frame.Inset or frame, "TOPLEFT", 12, -24)
    frame.navFrame:SetPoint("BOTTOMLEFT", frame.Inset or frame, "BOTTOMLEFT", 12, 12)
    frame.navFrame:SetWidth(NAV_WIDTH)
    frame.navSeparator = frame.navFrame:CreateTexture(nil, "BORDER")
    frame.navSeparator:SetColorTexture(1, 0.82, 0, 0.10)
    frame.navSeparator:SetPoint("TOPLEFT", 0, -2)
    frame.navSeparator:SetPoint("TOPRIGHT", 0, -2)
    frame.navSeparator:SetHeight(1)

    ------------------------------------------------------------------------------------
    -- PAGE LAYOUT
    ------------------------------------------------------------------------------------
    local dividerParent = frame.Inset or frame
    
    frame.contentDivider = frame.surfaceHost:CreateTexture(nil, "OVERLAY", nil, 1)
    frame.contentDivider:SetWidth(1)
    frame.contentDivider:SetColorTexture(1.0, 0.84, 0.38, 0.06)
    frame.contentDivider:SetPoint("TOPLEFT", frame.navFrame, "TOPRIGHT", 12, -2)
    frame.contentDivider:SetPoint("BOTTOMLEFT", frame.navFrame, "BOTTOMRIGHT", 12, 2)

    frame.content = CreateFrame("Frame", nil, frame.Inset or frame)
    frame.content:SetPoint("TOPLEFT", frame.navFrame, "TOPRIGHT", 24, 0)
    frame.content:SetPoint("BOTTOMRIGHT", frame.Inset or frame, "BOTTOMRIGHT", -12, 12)

    frame.navButtons = {}
    frame.pages = {}

    local previousButton
    for _, pageData in ipairs(PAGES) do
        local button = CreateNavButton(frame.navFrame, pageData.title)
        button:SetWidth(NAV_WIDTH)

        if previousButton then
            button:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, -8)
        else
            button:SetPoint("TOPLEFT", frame.navFrame, "TOPLEFT", 0, -NAV_TOP_PADDING)
        end

        button:SetScript("OnClick", function()
            SelectPage(self, pageData.key)
        end)

        frame.navButtons[pageData.key] = button
        previousButton = button

        local page = CreatePage(frame.content, pageData)
        if pageData.key == "general" then
            BuildGeneralPage(self, page)
        elseif pageData.key == "cursors" then
            BuildCursorsPage(self, page)
        elseif pageData.key == "appearance" then
            BuildAppearancePage(page)
        elseif pageData.key == "about" then
            BuildAboutPage(page)
        end

        frame.pages[pageData.key] = page
    end

    frame.resizeGrip = CreateResizeGrip(frame, function()
        SaveFrameSize(self, frame)
    end)
    ------------------------------------------------------------------------------------
    -- RESIZE GRIP LAYERING
    ------------------------------------------------------------------------------------
    frame.resizeGrip:SetFrameStrata(frame:GetFrameStrata())
    frame.resizeGrip:SetFrameLevel(frame:GetFrameLevel() + WINDOW_RESIZE_FRAME_LEVEL_OFFSET)

    self.configFrame = frame
    SelectPage(self, PAGES[1].key)

    return frame
end

function CursorGlow:SetupOptions()
    self.optionsInitialized = true
end

function CursorGlow:OpenConfig()
    local frame = CreateConfigFrame(self)
    frame:Show()
    if frame.Raise then
        frame:Raise()
    end
    SelectPage(self, frame.currentPage or PAGES[1].key)
end
