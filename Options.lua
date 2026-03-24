local ADDON_NAME, ns = ...
local GG = ns.GauntletGlow

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
    { key = "general", title = "General", subtitle = "Core addon controls and basic troubleshooting options", compactHeader = true },
    { key = "cursors", title = "Cursors", subtitle = "Tweak cursors size and position" },
    { key = "appearance", title = "Appearance", subtitle = "Global appearance controls for every cursor state" },
    { key = "effects", title = "Effects", subtitle = "Player-state effects layer over the active cursor glow" },
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
    "SPEAK",
    "DIRECTIONS_GUARD",
    "INNKEEPER",
    "STABLEMASTER",
    "MAILBOX",
    "FINANCE",
    "SKINNABLE",
    "VENDOR",
    "SELL_ITEM",
    "REPAIR_VENDOR",
}

local CURSOR_STATE_LABELS = {
    AUTOLOOT = "Auto Loot",
    FLIGHTMASTER = "Flight Master",
    STABLEMASTER = "Stable Master",
    FINANCE = "Finance",
    SPEAK = "Speak",
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
    SPEAK = {
        widthKey = "speakSizeX",
        heightKey = "speakSizeY",
        offsetXKey = "speakOffsetX",
        offsetYKey = "speakOffsetY",
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
    FINANCE = {
        widthKey = "bankerSizeX",
        heightKey = "bankerSizeY",
        offsetXKey = "bankerOffsetX",
        offsetYKey = "bankerOffsetY",
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

local CURSOR_DEFAULT_FIELDS = {
    width = "sizeX",
    height = "sizeY",
    offsetX = "offsetX",
    offsetY = "offsetY",
}

local PLAYER_STATE_EFFECT_ORDER = (ns.PlayerStateEffects and ns.PlayerStateEffects.order) or {
    "COMBAT",
    "LOW_HEALTH",
    "MOUNTED",
    "RESTING",
}

local PLAYER_STATE_EFFECT_SLIDER_DEFS = {
    { id = "tintStrength", label = "Tint Strength", min = 0.0, max = 1.0, step = 0.05 },
    { id = "brightness", label = "Brightness", min = 0.50, max = 2.00, step = 0.05 },
    { id = "alpha", label = "Alpha", min = 0.05, max = 1.00, step = 0.05 },
    { id = "pulseSpeed", label = "Pulse Speed", min = 0.45, max = 1.35, step = 0.05 },
    { id = "pulseStrength", label = "Pulse Strength", min = 0.00, max = 1.00, step = 0.05 },
    { id = "transitionSpeed", label = "Transition Speed", min = 1.00, max = 12.00, step = 0.25 },
}

local sliderNameIndex = 0
local dropdownNameIndex = 0

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
    return GetAddonMetadataValue(addonName, "Title") or addonName or "GauntletGlow"
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
    if not self or not self.gauntletGlow then
        return
    end

    self.currentVisible = nil
    local visible, state = self:EvaluateTrigger()
    self:ApplyVisibility(visible)

    if visible and state then
        self:ApplyState(state, true)
    end

    if self.UpdatePlayerStateEffect then
        self:UpdatePlayerStateEffect()
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
        if self.UpdatePlayerStateEffect then
            self:UpdatePlayerStateEffect()
        end
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

    table.sort(entries, function(left, right)
        local leftLabel = strlower(left.label or "")
        local rightLabel = strlower(right.label or "")

        if leftLabel == rightLabel then
            return (left.key or "") < (right.key or "")
        end

        return leftLabel < rightLabel
    end)

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

    local defaultField = CURSOR_DEFAULT_FIELDS[controlId]
    if not defaultField then
        return 0
    end

    local stateDefaults = ns.CursorStateDefaults and (ns.CursorStateDefaults[stateKey] or ns.CursorStateDefaults.DEFAULT)
    if stateDefaults and stateDefaults[defaultField] ~= nil then
        return stateDefaults[defaultField]
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

    if math.abs((value * 10) - math.floor((value * 10) + 0.5)) < 0.001 then
        return string.format("%.1f", value)
    end

    if math.abs((value * 100) - math.floor((value * 100) + 0.5)) < 0.001 then
        return string.format("%.2f", value)
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
    row.valueFrame:SetSize(64, 20)
    
    row.valueText = CreateText(row.valueFrame, "GameFontHighlight", "", FONT_STYLES.value)
    row.valueText:ClearAllPoints()
    row.valueText:SetPoint("RIGHT", row.valueFrame, "RIGHT", -6, 0)
    row.valueText:SetJustifyH("RIGHT")
    row.valueText:SetJustifyV("MIDDLE")
    
    row.valueEdit = CreateFrame("EditBox", nil, row.valueFrame, "InputBoxTemplate")
    row.valueEdit:SetPoint("TOPLEFT", 0, 0)
    row.valueEdit:SetPoint("BOTTOMRIGHT", -6, 0)
    row.valueEdit:SetAutoFocus(false)
    row.valueEdit:SetNumeric(false)
    row.valueEdit:SetJustifyH("RIGHT")
    row.valueEdit:SetJustifyV("MIDDLE")
    row.valueEdit:SetTextInsets(0, 0, 0, 0)
    row.valueEdit:SetMaxLetters(8)
    row.valueEdit:Hide()
    
    local valueFontPath, valueFontSize, valueFontFlags = row.valueText:GetFont()
    if valueFontPath then
        row.valueEdit:SetFont(valueFontPath, valueFontSize, valueFontFlags)
    end
    
    row.valueEdit:SetTextColor(GOLD_TEXT[1], GOLD_TEXT[2], GOLD_TEXT[3])
    row.valueEdit:SetShadowOffset(1, -1)
    row.valueEdit:SetShadowColor(0, 0, 0, 0.75)
    
    for _, regionName in ipairs({
        "Left", "Middle", "Right",
        "LeftMiddle", "MiddleMiddle", "RightMiddle",
        "TopLeft", "TopMiddle", "TopRight",
        "BottomLeft", "BottomMiddle", "BottomRight",
    }) do
        local region = row.valueEdit[regionName]
        if region then
            region:Hide()
        end
    end

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

    row.slider = CreateFrame("Slider", "GauntletGlowValueSlider" .. sliderNameIndex, row)
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

    local headerHeight = pageData.subtitle and PAGE_HEADER_HEIGHT or 28
    local subtitleOffset = -6
    local bodyOffset = -18

    if pageData.compactHeader and pageData.subtitle then
        headerHeight = PAGE_HEADER_HEIGHT - 4
        subtitleOffset = -4
        bodyOffset = -14
    end

    page.header = CreateFrame("Frame", nil, page)
    page.header:SetPoint("TOPLEFT", PAGE_INSET_X, PAGE_HEADER_TOP)
    page.header:SetPoint("TOPRIGHT", -PAGE_INSET_X, PAGE_HEADER_TOP)
    page.header:SetHeight(headerHeight)

    page.title = CreateText(page.header, "GameFontNormalLarge", pageData.title, FONT_STYLES.pageTitle)
    page.title:SetPoint("TOPLEFT", 0, 0)
    page.title:SetPoint("TOPRIGHT", 0, 0)
    if pageData.subtitle then
        page.subtitle = CreateText(page.header, "GameFontHighlight", pageData.subtitle, FONT_STYLES.pageSubtitle)
        page.subtitle:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, subtitleOffset)
        page.subtitle:SetPoint("TOPRIGHT", page.title, "BOTTOMRIGHT", 0, subtitleOffset)
    end

    page.body = CreateFrame("Frame", nil, page)
    page.body:SetPoint("TOPLEFT", page.header, "BOTTOMLEFT", 0, bodyOffset)
    page.body:SetPoint("TOPRIGHT", page.header, "BOTTOMRIGHT", 0, bodyOffset)
    page.body:SetPoint("BOTTOMLEFT", PAGE_INSET_X, 0)
    page.body:SetPoint("BOTTOMRIGHT", -PAGE_INSET_X, 0)

    return page
end

------------------------------------------------------------------------------------
-- GENERAL PAGE BUILD
------------------------------------------------------------------------------------
local function BuildGeneralPage(self, page)
    page.enableRow = CreateCheckboxRow(page.body, "Enable", "Master toggle")
    page.enableRow:SetPoint("TOPLEFT", 0, 0)
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
    panel.bg:Show()
    panel.bg:SetVertexColor(0, 0, 0, 0.22)

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

local function GetAppearanceProfile(self)
    return self and self.db and self.db.profile or nil
end

local function RefreshAppearance(self)
    if self.RefreshGlowAppearance then
        self:RefreshGlowAppearance()
    end
end

local function GetAppearanceCustomColorEnabled(self)
    local profile = GetAppearanceProfile(self)
    return profile and profile.useCustomColor or false
end

local function SetAppearanceCustomColorEnabled(self, enabled)
    local profile = GetAppearanceProfile(self)
    if not profile then
        return
    end

    profile.useCustomColor = enabled and true or false

    RefreshAppearance(self)
end

local function GetAppearanceColor(self)
    local profile = GetAppearanceProfile(self)
    if not profile then
        return 1, 1, 1
    end

    return profile.colorR or 1, profile.colorG or 1, profile.colorB or 1
end

local function SetAppearanceColor(self, r, g, b)
    local profile = GetAppearanceProfile(self)
    if not profile then
        return
    end

    profile.colorR = r or 1
    profile.colorG = g or 1
    profile.colorB = b or 1

    RefreshAppearance(self)
end

local function GetAppearanceDesaturateEnabled(self)
    local profile = GetAppearanceProfile(self)
    return profile and profile.desaturateTexture or false
end

local function SetAppearanceDesaturateEnabled(self, enabled)
    local profile = GetAppearanceProfile(self)
    if not profile then
        return
    end

    profile.desaturateTexture = enabled and true or false

    RefreshAppearance(self)
end

local function GetAppearanceBrightnessEnabled(self)
    local profile = GetAppearanceProfile(self)
    return profile and profile.useBrightness or false
end

local function SetAppearanceBrightnessEnabled(self, enabled)
    local profile = GetAppearanceProfile(self)
    if not profile then
        return
    end

    profile.useBrightness = enabled and true or false

    RefreshAppearance(self)
end

local function GetAppearanceBrightness(self)
    local profile = GetAppearanceProfile(self)
    return profile and profile.brightness or 1
end

local function SetAppearanceBrightness(self, value)
    local profile = GetAppearanceProfile(self)
    if not profile then
        return
    end

    profile.brightness = value or 1

    RefreshAppearance(self)
end

local function GetAppearanceGlobalAlphaEnabled(self)
    local profile = GetAppearanceProfile(self)
    return profile and profile.useGlobalAlpha or false
end

local function SetAppearanceGlobalAlphaEnabled(self, enabled)
    local profile = GetAppearanceProfile(self)
    if not profile then
        return
    end

    profile.useGlobalAlpha = enabled and true or false

    RefreshAppearance(self)
end

local function GetAppearanceGlobalAlpha(self)
    local profile = GetAppearanceProfile(self)
    return profile and profile.globalAlpha or 1
end

local function SetAppearanceGlobalAlpha(self, value)
    local profile = GetAppearanceProfile(self)
    if not profile then
        return
    end

    profile.globalAlpha = value or 1

    RefreshAppearance(self)
end

local function CreateInlineCheckbox(parent, title)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(26)

    row.check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    row.check:SetPoint("LEFT", 0, 0)

    row.label = CreateText(row, "GameFontNormal", title, FONT_STYLES.sectionTitle)
    row.label:SetPoint("LEFT", row.check, "RIGHT", 6, -2)
    row.label:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.label:SetJustifyV("MIDDLE")

    return row
end

local function SetInlineCheckboxEnabled(row, enabled)
    if not row then
        return
    end

    if enabled then
        row.check:Enable()
    else
        row.check:Disable()
    end

    StyleText(row.label, enabled and FONT_STYLES.sectionTitle or FONT_STYLES.muted)
    row:SetAlpha(enabled and 1 or 0.6)
end

local function SetInlineCheckboxStableEnabled(row, enabled)
    if not row then
        return
    end

    if enabled then
        row.check:Enable()
    else
        row.check:Disable()
    end

    ApplyFont(
        row.label,
        FONT_STYLES.sectionTitle.template,
        FONT_STYLES.sectionTitle.size,
        FONT_STYLES.sectionTitle.flags,
        enabled and FONT_STYLES.sectionTitle.color or MUTED_TEXT,
        FONT_STYLES.sectionTitle.shadow
    )
    row:SetAlpha(enabled and 1 or 0.6)
end

local function SetValueSliderEnabled(row, enabled)
    if not row then
        return
    end

    if enabled then
        row.slider:Enable()
        row.slider:EnableMouse(true)
        row.valueFrame:EnableMouse(true)
        ApplyFont(row.label, FONT_STYLES.sectionTitle.template, FONT_STYLES.sectionTitle.size, FONT_STYLES.sectionTitle.flags, FONT_STYLES.sectionTitle.color, FONT_STYLES.sectionTitle.shadow)
        ApplyFont(row.valueText, FONT_STYLES.value.template, FONT_STYLES.value.size, FONT_STYLES.value.flags, FONT_STYLES.value.color, FONT_STYLES.value.shadow)
        row.valueFrame:SetAlpha(1)
        row.slider:SetAlpha(1)
        row:SetAlpha(1)
    else
        row.slider:Disable()
        row.slider:EnableMouse(false)
        row.valueFrame:EnableMouse(false)
        row.valueEdit:ClearFocus()
        row.valueEdit:Hide()
        row.valueText:Show()
        ApplyFont(row.label, FONT_STYLES.sectionTitle.template, FONT_STYLES.sectionTitle.size, FONT_STYLES.sectionTitle.flags, MUTED_TEXT, FONT_STYLES.sectionTitle.shadow)
        ApplyFont(row.valueText, FONT_STYLES.value.template, FONT_STYLES.value.size, FONT_STYLES.value.flags, MUTED_TEXT, FONT_STYLES.value.shadow)
        row.valueFrame:SetAlpha(0.75)
        row.slider:SetAlpha(0.45)
        row:SetAlpha(0.75)
    end
end

local function CreateColorSwatchButton(parent)
    local button = CreateFrame("Button", nil, parent, BACKDROP_TEMPLATE)
    button:SetSize(26, 26)

    if button.SetBackdrop then
        button:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
    end

    if button.SetBackdropColor then
        button:SetBackdropColor(0, 0, 0, 0.35)
    end

    button.swatch = button:CreateTexture(nil, "ARTWORK")
    button.swatch:SetPoint("TOPLEFT", 3, -3)
    button.swatch:SetPoint("BOTTOMRIGHT", -3, 3)
    button.swatch:SetTexture("Interface\\Buttons\\WHITE8x8")

    button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
    button.highlight:SetAllPoints()
    button.highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    button.highlight:SetVertexColor(1, 1, 1, 0.08)

    function button:SetSwatchColor(r, g, b)
        self.swatch:SetVertexColor(r or 1, g or 1, b or 1)
    end

    function button:SetEnabledState(enabled)
        if enabled then
            self:Enable()
            self:SetAlpha(1)
            if self.SetBackdropBorderColor then
                self:SetBackdropBorderColor(0.88, 0.75, 0.30, 0.80)
            end
        else
            self:Disable()
            self:SetAlpha(0.45)
            if self.SetBackdropBorderColor then
                self:SetBackdropBorderColor(0.44, 0.40, 0.32, 0.55)
            end
        end
    end

    button:SetEnabledState(true)

    return button
end

local function GetColorDataRGB(colorData)
    if type(colorData) == "table" then
        local r = colorData.r or colorData.red or colorData[1]
        local g = colorData.g or colorData.green or colorData[2]
        local b = colorData.b or colorData.blue or colorData[3]

        if r ~= nil and g ~= nil and b ~= nil then
            return r, g, b
        end
    end

    return nil
end

local function GetColorPickerRGB(colorData)
    local r, g, b = GetColorDataRGB(colorData)
    if r ~= nil and g ~= nil and b ~= nil then
        return r, g, b
    end

    if ColorPickerFrame and ColorPickerFrame.GetColorRGB then
        return ColorPickerFrame:GetColorRGB()
    end

    return nil
end

local function OpenAppearanceColorPicker(self, onChanged)
    if not ColorPickerFrame then
        return
    end

    local initialR, initialG, initialB = GetAppearanceColor(self)

    local function ApplyPickerColor(colorData)
        local r, g, b = GetColorPickerRGB(colorData)
        if r == nil or g == nil or b == nil then
            return
        end

        SetAppearanceColor(self, r, g, b)

        if onChanged then
            onChanged()
        end
    end

    local function CancelPickerColor(previousValues)
        local r, g, b = GetColorDataRGB(previousValues)
        if r == nil or g == nil or b == nil then
            r, g, b = initialR, initialG, initialB
        end

        SetAppearanceColor(self, r, g, b)

        if onChanged then
            onChanged()
        end
    end

    if ColorPickerFrame.SetupColorPickerAndShow then
        local info = {}
        info.r = initialR
        info.g = initialG
        info.b = initialB
        info.hasOpacity = false
        info.swatchFunc = function(...)
            ApplyPickerColor(select(1, ...))
        end
        info.cancelFunc = function(previousValues)
            CancelPickerColor(previousValues)
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
        return
    end

    ColorPickerFrame.func = function(...)
        ApplyPickerColor(select(1, ...))
    end
    ColorPickerFrame.opacityFunc = nil
    ColorPickerFrame.cancelFunc = function(previousValues)
        CancelPickerColor(previousValues)
    end
    ColorPickerFrame.hasOpacity = false
    ColorPickerFrame.opacity = 1
    ColorPickerFrame.previousValues = { r = initialR, g = initialG, b = initialB }
    ColorPickerFrame:SetColorRGB(initialR, initialG, initialB)
    ColorPickerFrame:Hide()
    ColorPickerFrame:Show()
end

local function GetPlayerStateEffectData()
    return ns.PlayerStateEffects or {}
end

local function GetPlayerStateEffectLabel(effectKey)
    local effectData = GetPlayerStateEffectData()
    local labels = effectData.labels or {}
    return labels[effectKey] or FormatCursorStateLabel(effectKey)
end

local function GetPlayerStateEffectProfile(self, effectKey)
    if not self or not self.db or not self.db.profile then
        return nil
    end

    if self.GetPlayerStateEffectProfile then
        local existingProfile = self:GetPlayerStateEffectProfile(effectKey)
        if existingProfile then
            return existingProfile
        end
    end

    self.db.profile.effects = self.db.profile.effects or {}
    self.db.profile.effects.playerStates = self.db.profile.effects.playerStates or {}
    self.db.profile.effects.playerStates[effectKey] = self.db.profile.effects.playerStates[effectKey] or {}

    return self.db.profile.effects.playerStates[effectKey]
end

local function GetPlayerStateEffectDefault(effectKey, valueKey)
    local effectData = GetPlayerStateEffectData()
    local defaults = effectData.defaults and effectData.defaults[effectKey]
    if defaults and defaults[valueKey] ~= nil then
        return defaults[valueKey]
    end

    local neutral = effectData.neutral or {}
    return neutral[valueKey]
end

local function GetPlayerStateEffectValue(self, effectKey, valueKey)
    if self and self.GetPlayerStateEffectValue then
        local value = self:GetPlayerStateEffectValue(effectKey, valueKey)
        if value ~= nil then
            return value
        end
    end

    return GetPlayerStateEffectDefault(effectKey, valueKey)
end

local function RefreshPlayerStateEffects(self)
    if self.UpdatePlayerStateEffect then
        self:UpdatePlayerStateEffect()
    end

    if self.RefreshPlayerStateEffectTarget then
        self:RefreshPlayerStateEffectTarget()
    elseif self.RefreshGlowAppearance then
        self:RefreshGlowAppearance()
    end
end

local function SetPlayerStateEffectValue(self, effectKey, valueKey, value)
    local effectProfile = GetPlayerStateEffectProfile(self, effectKey)
    if not effectProfile then
        return
    end

    effectProfile[valueKey] = value
    if valueKey == "alpha" then
        effectProfile.alphaEnabled = nil
    end
    RefreshPlayerStateEffects(self)
end

local function SetPlayerStateEffectColor(self, effectKey, r, g, b)
    local effectProfile = GetPlayerStateEffectProfile(self, effectKey)
    if not effectProfile then
        return
    end

    effectProfile.colorR = r or 1
    effectProfile.colorG = g or 1
    effectProfile.colorB = b or 1
    RefreshPlayerStateEffects(self)
end

local function ResetPlayerStateEffectToDefaults(self, effectKey)
    local effectProfile = GetPlayerStateEffectProfile(self, effectKey)
    if not effectProfile then
        return
    end

    local effectData = GetPlayerStateEffectData()
    local defaults = effectData.defaults and effectData.defaults[effectKey]
    if not defaults then
        return
    end

    for key, value in pairs(defaults) do
        effectProfile[key] = value
    end

    effectProfile.alphaEnabled = nil

    RefreshPlayerStateEffects(self)
end

local function OpenPlayerStateEffectColorPicker(self, effectKey, onChanged)
    if not ColorPickerFrame then
        return
    end

    local initialR = GetPlayerStateEffectValue(self, effectKey, "colorR") or 1
    local initialG = GetPlayerStateEffectValue(self, effectKey, "colorG") or 1
    local initialB = GetPlayerStateEffectValue(self, effectKey, "colorB") or 1

    local function ApplyPickerColor(colorData)
        local r, g, b = GetColorPickerRGB(colorData)
        if r == nil or g == nil or b == nil then
            return
        end

        SetPlayerStateEffectColor(self, effectKey, r, g, b)

        if onChanged then
            onChanged()
        end
    end

    local function CancelPickerColor(previousValues)
        local r, g, b = GetColorDataRGB(previousValues)
        if r == nil or g == nil or b == nil then
            r, g, b = initialR, initialG, initialB
        end

        SetPlayerStateEffectColor(self, effectKey, r, g, b)

        if onChanged then
            onChanged()
        end
    end

    if ColorPickerFrame.SetupColorPickerAndShow then
        local info = {}
        info.r = initialR
        info.g = initialG
        info.b = initialB
        info.hasOpacity = false
        info.swatchFunc = function(...)
            ApplyPickerColor(select(1, ...))
        end
        info.cancelFunc = function(previousValues)
            CancelPickerColor(previousValues)
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
        return
    end

    ColorPickerFrame.func = function(...)
        ApplyPickerColor(select(1, ...))
    end
    ColorPickerFrame.opacityFunc = nil
    ColorPickerFrame.cancelFunc = function(previousValues)
        CancelPickerColor(previousValues)
    end
    ColorPickerFrame.hasOpacity = false
    ColorPickerFrame.opacity = 1
    ColorPickerFrame.previousValues = { r = initialR, g = initialG, b = initialB }
    ColorPickerFrame:SetColorRGB(initialR, initialG, initialB)
    ColorPickerFrame:Hide()
    ColorPickerFrame:Show()
end

local function CreateCompactDropdown(parent, width)
    dropdownNameIndex = dropdownNameIndex + 1

    local dropdown = CreateFrame("Frame", "GauntletGlowDropdown" .. dropdownNameIndex, parent, "UIDropDownMenuTemplate")
    dropdown:SetWidth(width or 180)

    if UIDropDownMenu_SetWidth then
        UIDropDownMenu_SetWidth(dropdown, width or 180)
    end

    if UIDropDownMenu_SetText then
        UIDropDownMenu_SetText(dropdown, "")
    end

    return dropdown
end

------------------------------------------------------------------------------------
-- APPEARANCE PAGE BUILD
------------------------------------------------------------------------------------
local function BuildAppearancePage(self, page)
    local function RoundAppearanceValue(value, step)
        local roundedValue = math.floor((value / step) + 0.5) * step
        return tonumber(string.format("%.2f", roundedValue))
    end

    local sectionGap = 12
    local introGap = 18
    local sectionBottomPadding = 12
    local toggleRegionWidth = 170

    local function UpdateAppearanceScrollLayout()
        if not page.scrollFrame or not page.scrollContent then
            return
        end

        local contentWidth = math.max(page.scrollFrame:GetWidth(), 1)
        local viewportHeight = math.max(page.scrollFrame:GetHeight(), 1)
        page.scrollContent:SetWidth(contentWidth)

        local totalHeight = page.recolorSection:GetHeight()
            + sectionGap
            + page.brightnessSection:GetHeight()
            + sectionGap
            + page.alphaSection:GetHeight()
            + sectionBottomPadding

        page.scrollContent:SetHeight(math.max(viewportHeight, totalHeight))
    end

    page.scrollFrame = CreateFrame("ScrollFrame", nil, page.body, "UIPanelScrollFrameTemplate")
    page.scrollFrame:SetPoint("TOPLEFT", page.body, "TOPLEFT", 0, 0)
    page.scrollFrame:SetPoint("BOTTOMRIGHT", page.body, "BOTTOMRIGHT", -28, 0)

    page.scrollContent = CreateFrame("Frame", nil, page.scrollFrame)
    page.scrollContent:SetPoint("TOPLEFT", 0, 0)
    page.scrollContent:SetSize(1, 1)
    page.scrollFrame:SetScrollChild(page.scrollContent)
    page.scrollFrame:SetScript("OnSizeChanged", UpdateAppearanceScrollLayout)
    page:SetScript("OnShow", UpdateAppearanceScrollLayout)

    page.recolorSection = CreateSectionPanel(page.scrollContent, "Color", "")
    page.recolorSection:SetPoint("TOPLEFT", page.scrollContent, "TOPLEFT", 0, 0)
    page.recolorSection:SetPoint("TOPRIGHT", page.scrollContent, "TOPRIGHT", 0, 0)
    page.recolorSection:SetHeight(126)
    page.recolorSection.bodyText:SetText("")
    page.recolorSection.bodyText:Hide()

    page.recolorControls = CreateFrame("Frame", nil, page.recolorSection)
    page.recolorControls:SetPoint("TOPLEFT", page.recolorSection.separator, "BOTTOMLEFT", 0, -12)
    page.recolorControls:SetPoint("TOPRIGHT", page.recolorSection.separator, "BOTTOMRIGHT", 0, -12)
    page.recolorControls:SetHeight(28)

    page.customColorToggle = CreateInlineCheckbox(page.recolorControls, "Custom Color")
    page.customColorToggle:SetPoint("TOPLEFT", 0, 0)
    page.customColorToggle:SetWidth(180)
    page.customColorToggle.check:SetScript("OnClick", function(button)
        SetAppearanceCustomColorEnabled(self, button:GetChecked())
        page:RefreshControls()
    end)

    page.colorSwatch = CreateColorSwatchButton(page.recolorControls)
    page.colorSwatch:SetPoint("LEFT", page.customColorToggle, "RIGHT", 8, 0)
    page.colorSwatch:SetScript("OnClick", function()
        OpenAppearanceColorPicker(self, function()
            page:RefreshControls()
        end)
    end)

    page.desaturateToggle = CreateInlineCheckbox(page.recolorControls, "Desaturate")
    page.desaturateToggle:SetPoint("TOPRIGHT", 0, 0)
    page.desaturateToggle:SetWidth(150)
    page.desaturateToggle.check:SetScript("OnClick", function(button)
        SetAppearanceDesaturateEnabled(self, button:GetChecked())
        page:RefreshControls()
    end)

    page.resetColorButton = CreateFrame("Button", nil, page.recolorSection, "UIPanelButtonTemplate")
    page.resetColorButton:SetSize(100, 22)
    page.resetColorButton:SetText("Reset Color")
    page.resetColorButton:SetPoint("TOPLEFT", page.recolorControls, "BOTTOMLEFT", 2, -10)
    page.resetColorButton:SetScript("OnClick", function()
        SetAppearanceColor(self, 1, 1, 1)
        page:RefreshControls()
    end)

    page.brightnessSection = CreateSectionPanel(page.scrollContent, "Brightness", "")
    page.brightnessSection:SetPoint("TOPLEFT", page.recolorSection, "BOTTOMLEFT", 0, -sectionGap)
    page.brightnessSection:SetPoint("TOPRIGHT", page.recolorSection, "BOTTOMRIGHT", 0, -12)
    page.brightnessSection:SetHeight(160)
    page.brightnessSection.bodyText:SetText("")
    page.brightnessSection.bodyText:Hide()

    page.brightnessToggleRegion = CreateFrame("Frame", nil, page.brightnessSection)
    page.brightnessToggleRegion:SetPoint("TOPLEFT", page.brightnessSection.separator, "BOTTOMLEFT", 0, -12)
    page.brightnessToggleRegion:SetSize(toggleRegionWidth, 26)

    page.brightnessToggle = CreateInlineCheckbox(page.brightnessToggleRegion, "Enable")
    page.brightnessToggle:SetAllPoints()
    page.brightnessToggle.check:SetScript("OnClick", function(button)
        SetAppearanceBrightnessEnabled(self, button:GetChecked())
        page:RefreshControls()
    end)

    page.brightnessSlider = CreateValueSlider(page.brightnessSection, "Brightness", 0.25, 2.0, 0.05)
    page.brightnessSlider:SetPoint("TOPLEFT", page.brightnessSection.separator, "BOTTOMLEFT", 0, -46)
    page.brightnessSlider:SetPoint("TOPRIGHT", page.brightnessSection.separator, "BOTTOMRIGHT", 0, -46)
    page.brightnessSlider.slider:SetScript("OnValueChanged", function(_, value)
        if page.brightnessSlider.isUpdating then
            return
        end

        local roundedValue = RoundAppearanceValue(value, 0.05)
        page.brightnessSlider:SetDisplayValue(roundedValue)
        SetAppearanceBrightness(self, roundedValue)
    end)

    page.alphaSection = CreateSectionPanel(page.scrollContent, "Alpha", "")
    page.alphaSection:SetPoint("TOPLEFT", page.brightnessSection, "BOTTOMLEFT", 0, -sectionGap)
    page.alphaSection:SetPoint("TOPRIGHT", page.brightnessSection, "BOTTOMRIGHT", 0, -12)
    page.alphaSection:SetHeight(160)
    page.alphaSection.bodyText:SetText("")
    page.alphaSection.bodyText:Hide()

    page.alphaToggleRegion = CreateFrame("Frame", nil, page.alphaSection)
    page.alphaToggleRegion:SetPoint("TOPLEFT", page.alphaSection.separator, "BOTTOMLEFT", 0, -12)
    page.alphaToggleRegion:SetSize(toggleRegionWidth, 26)

    page.alphaToggle = CreateInlineCheckbox(page.alphaToggleRegion, "Enable")
    page.alphaToggle:SetAllPoints()
    page.alphaToggle.check:SetScript("OnClick", function(button)
        SetAppearanceGlobalAlphaEnabled(self, button:GetChecked())
        page:RefreshControls()
    end)

    page.alphaSlider = CreateValueSlider(page.alphaSection, "Alpha", 0.05, 1.0, 0.05)
    page.alphaSlider:SetPoint("TOPLEFT", page.alphaSection.separator, "BOTTOMLEFT", 0, -46)
    page.alphaSlider:SetPoint("TOPRIGHT", page.alphaSection.separator, "BOTTOMRIGHT", 0, -46)
    page.alphaSlider.slider:SetScript("OnValueChanged", function(_, value)
        if page.alphaSlider.isUpdating then
            return
        end

        local roundedValue = RoundAppearanceValue(value, 0.05)
        page.alphaSlider:SetDisplayValue(roundedValue)
        SetAppearanceGlobalAlpha(self, roundedValue)
    end)

    page.RefreshControls = function(currentPage)
        local useCustomColor = GetAppearanceCustomColorEnabled(self)
        local colorR, colorG, colorB = GetAppearanceColor(self)
        local useBrightness = GetAppearanceBrightnessEnabled(self)
        local brightness = RoundAppearanceValue(GetAppearanceBrightness(self), 0.05)
        local useGlobalAlpha = GetAppearanceGlobalAlphaEnabled(self)
        local globalAlpha = RoundAppearanceValue(GetAppearanceGlobalAlpha(self), 0.05)

        currentPage.customColorToggle.check:SetChecked(useCustomColor)
        currentPage.colorSwatch:SetSwatchColor(colorR, colorG, colorB)
        currentPage.colorSwatch:SetEnabledState(useCustomColor)

        currentPage.desaturateToggle.check:SetChecked(GetAppearanceDesaturateEnabled(self))
        SetInlineCheckboxEnabled(currentPage.desaturateToggle, useCustomColor)

        currentPage.brightnessToggle.check:SetChecked(useBrightness)
        currentPage.brightnessSlider.isUpdating = true
        currentPage.brightnessSlider.slider:SetValue(brightness)
        currentPage.brightnessSlider:SetDisplayValue(brightness)
        currentPage.brightnessSlider.isUpdating = false
        SetInlineCheckboxStableEnabled(currentPage.brightnessToggle, true)
        SetValueSliderEnabled(currentPage.brightnessSlider, useBrightness)

        currentPage.alphaToggle.check:SetChecked(useGlobalAlpha)
        currentPage.alphaSlider.isUpdating = true
        currentPage.alphaSlider.slider:SetValue(globalAlpha)
        currentPage.alphaSlider:SetDisplayValue(globalAlpha)
        currentPage.alphaSlider.isUpdating = false
        SetInlineCheckboxStableEnabled(currentPage.alphaToggle, true)
        SetValueSliderEnabled(currentPage.alphaSlider, useGlobalAlpha)
        UpdateAppearanceScrollLayout()
    end
end

local function BuildEffectsPage(self, page)
    local function RoundEffectValue(value, step)
        local roundedValue = math.floor((value / step) + 0.5) * step
        return tonumber(string.format("%.2f", roundedValue))
    end

    local sectionBottomPadding = 12
    local controlGap = 18
    local effectSliderDefsById = {}

    for _, sliderDef in ipairs(PLAYER_STATE_EFFECT_SLIDER_DEFS) do
        effectSliderDefsById[sliderDef.id] = sliderDef
    end

    local function UpdateEffectsScrollLayout()
        if not page.scrollFrame or not page.scrollContent then
            return
        end

        local contentWidth = math.max(page.scrollFrame:GetWidth(), 1)
        local viewportHeight = math.max(page.scrollFrame:GetHeight(), 1)
        page.scrollContent:SetWidth(contentWidth)

        if page.playerStateSection and page.resetButton then
            local sectionTop = page.playerStateSection:GetTop()
            local resetButtonBottom = page.resetButton:GetBottom()
            if sectionTop and resetButtonBottom then
                page.playerStateSection:SetHeight(math.max(1, math.floor((sectionTop - resetButtonBottom) + sectionBottomPadding + 0.5)))
            end
        end

        local totalHeight = page.playerStateSection:GetHeight()
            + sectionBottomPadding

        page.scrollContent:SetHeight(math.max(viewportHeight, totalHeight))
    end

    local function SetSelectedEffect(effectKey)
        if not effectKey then
            effectKey = PLAYER_STATE_EFFECT_ORDER[1]
        end

        page.selectedEffectKey = effectKey

        if UIDropDownMenu_SetSelectedValue then
            UIDropDownMenu_SetSelectedValue(page.stateDropdown, effectKey)
        end

        if UIDropDownMenu_SetText then
            UIDropDownMenu_SetText(page.stateDropdown, GetPlayerStateEffectLabel(effectKey))
        end
    end

    local function CreateEffectSlider(controlKey)
        local sliderDef = effectSliderDefsById[controlKey]
        local slider = CreateValueSlider(page.playerStateSection, sliderDef.label, sliderDef.min, sliderDef.max, sliderDef.step)
        slider.slider:SetScript("OnValueChanged", function(_, value)
            if slider.isUpdating or not page.selectedEffectKey then
                return
            end

            local clampedValue = math.max(sliderDef.min, math.min(sliderDef.max, value))
            local roundedValue = RoundEffectValue(clampedValue, sliderDef.step)
            slider:SetDisplayValue(roundedValue)
            SetPlayerStateEffectValue(self, page.selectedEffectKey, controlKey, roundedValue)
        end)

        page[controlKey .. "Slider"] = slider
        return slider
    end

    local function RefreshEffectSlider(currentPage, effectKey, controlKey)
        local sliderDef = effectSliderDefsById[controlKey]
        local control = currentPage[controlKey .. "Slider"]
        if not sliderDef or not control then
            return
        end

        local currentValue = GetPlayerStateEffectValue(self, effectKey, controlKey) or sliderDef.min
        local roundedValue = RoundEffectValue(math.max(sliderDef.min, math.min(sliderDef.max, currentValue)), sliderDef.step)
        control.isUpdating = true
        control.slider:SetValue(roundedValue)
        control:SetDisplayValue(roundedValue)
        control.isUpdating = false
    end

    local function SetButtonEnabled(button, enabled)
        if not button then
            return
        end

        if enabled then
            button:Enable()
            button:SetAlpha(1)
        else
            button:Disable()
            button:SetAlpha(0.55)
        end
    end

    local function SetEffectLabelEnabled(label, enabled)
        ApplyFont(
            label,
            FONT_STYLES.sectionTitle.template,
            FONT_STYLES.sectionTitle.size,
            FONT_STYLES.sectionTitle.flags,
            enabled and FONT_STYLES.sectionTitle.color or MUTED_TEXT,
            FONT_STYLES.sectionTitle.shadow
        )
        label:SetAlpha(enabled and 1 or 0.8)
    end

    page.scrollFrame = CreateFrame("ScrollFrame", nil, page.body, "UIPanelScrollFrameTemplate")
    page.scrollFrame:SetPoint("TOPLEFT", page.body, "TOPLEFT", 0, 0)
    page.scrollFrame:SetPoint("BOTTOMRIGHT", page.body, "BOTTOMRIGHT", -28, 0)

    page.scrollContent = CreateFrame("Frame", nil, page.scrollFrame)
    page.scrollContent:SetPoint("TOPLEFT", 0, 0)
    page.scrollContent:SetSize(1, 1)
    page.scrollFrame:SetScrollChild(page.scrollContent)
    page.scrollFrame:SetScript("OnSizeChanged", UpdateEffectsScrollLayout)
    page:SetScript("OnShow", UpdateEffectsScrollLayout)

    page.playerStateSection = CreateSectionPanel(page.scrollContent, "Player State Effects", "")
    page.playerStateSection:SetPoint("TOPLEFT", page.scrollContent, "TOPLEFT", 0, 0)
    page.playerStateSection:SetPoint("TOPRIGHT", page.scrollContent, "TOPRIGHT", 0, 0)
    page.playerStateSection:SetHeight(1)
    page.playerStateSection.bodyText:SetText("")
    page.playerStateSection.bodyText:Hide()

    page.topRow = CreateFrame("Frame", nil, page.playerStateSection)
    page.topRow:SetPoint("TOPLEFT", page.playerStateSection.separator, "BOTTOMLEFT", 0, -10)
    page.topRow:SetPoint("TOPRIGHT", page.playerStateSection.separator, "BOTTOMRIGHT", 0, -10)
    page.topRow:SetHeight(28)

    page.stateLabel = CreateText(page.topRow, "GameFontNormal", "Player State", FONT_STYLES.sectionTitle)
    page.stateLabel:SetPoint("LEFT", page.topRow, "LEFT", 0, -1)
    page.stateLabel:SetWidth(90)
    page.stateLabel:SetJustifyV("MIDDLE")

    page.stateDropdown = CreateCompactDropdown(page.topRow, 180)
    page.stateDropdown:SetPoint("LEFT", page.stateLabel, "RIGHT", -2, 1)

    if UIDropDownMenu_Initialize then
        UIDropDownMenu_Initialize(page.stateDropdown, function(_, level)
            if level ~= 1 then
                return
            end

            for _, effectKey in ipairs(PLAYER_STATE_EFFECT_ORDER) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = GetPlayerStateEffectLabel(effectKey)
                info.value = effectKey
                info.checked = page.selectedEffectKey == effectKey
                info.func = function(button)
                    SetSelectedEffect(button.value)
                    page:RefreshControls()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
    end

    page.colorSwatch = CreateColorSwatchButton(page.topRow)
    page.colorSwatch:SetPoint("RIGHT", page.topRow, "RIGHT", 0, 0)
    page.colorSwatch:SetScript("OnClick", function()
        if not page.selectedEffectKey or not GetPlayerStateEffectValue(self, page.selectedEffectKey, "enabled") then
            return
        end

        OpenPlayerStateEffectColorPicker(self, page.selectedEffectKey, function()
            page:RefreshControls()
        end)
    end)

    page.colorLabel = CreateText(page.topRow, "GameFontNormal", "Color", FONT_STYLES.sectionTitle)
    page.colorLabel:SetPoint("RIGHT", page.colorSwatch, "LEFT", -10, -1)
    page.colorLabel:SetJustifyV("MIDDLE")

    page.previewToggle = CreateInlineCheckbox(page.topRow, "Test")
    page.previewToggle:SetPoint("RIGHT", page.colorLabel, "LEFT", -24, 0)
    page.previewToggle:SetWidth(76)
    page.previewToggle.check:SetScript("OnClick", function(button)
        if not page.selectedEffectKey or not self.SetPlayerStateEffectPreview then
            return
        end

        self:SetPlayerStateEffectPreview(page.selectedEffectKey, button:GetChecked() and true or false)
        page:RefreshControls()
    end)

    page.toggleRow = CreateFrame("Frame", nil, page.playerStateSection)
    page.toggleRow:SetPoint("TOPLEFT", page.topRow, "BOTTOMLEFT", 0, -12)
    page.toggleRow:SetPoint("TOPRIGHT", page.topRow, "BOTTOMRIGHT", 0, -12)
    page.toggleRow:SetHeight(28)

    page.enableToggle = CreateInlineCheckbox(page.toggleRow, "Enable")
    page.enableToggle:SetPoint("LEFT", page.toggleRow, "LEFT", 0, 0)
    page.enableToggle:SetWidth(96)
    page.enableToggle.check:SetScript("OnClick", function(button)
        if not page.selectedEffectKey then
            return
        end

        SetPlayerStateEffectValue(self, page.selectedEffectKey, "enabled", button:GetChecked() and true or false)
        if not button:GetChecked() and self.IsPlayerStateEffectPreviewActive
            and self:IsPlayerStateEffectPreviewActive(page.selectedEffectKey)
            and self.SetPlayerStateEffectPreview then
            self:SetPlayerStateEffectPreview(page.selectedEffectKey, false)
        end
        page:RefreshControls()
    end)

    page.pulseToggle = CreateInlineCheckbox(page.toggleRow, "Pulse")
    page.pulseToggle:SetPoint("LEFT", page.enableToggle, "RIGHT", 18, 0)
    page.pulseToggle:SetWidth(88)
    page.pulseToggle.check:SetScript("OnClick", function(button)
        if not page.selectedEffectKey then
            return
        end

        SetPlayerStateEffectValue(self, page.selectedEffectKey, "pulseEnabled", button:GetChecked() and true or false)
        page:RefreshControls()
    end)

    page.desaturateToggle = CreateInlineCheckbox(page.toggleRow, "Desaturate")
    page.desaturateToggle:SetPoint("LEFT", page.pulseToggle, "RIGHT", 18, 0)
    page.desaturateToggle:SetWidth(120)
    page.desaturateToggle.check:SetScript("OnClick", function(button)
        if not page.selectedEffectKey then
            return
        end

        SetPlayerStateEffectValue(self, page.selectedEffectKey, "desaturate", button:GetChecked() and true or false)
        page:RefreshControls()
    end)

    page.primarySliderRow = CreateFrame("Frame", nil, page.playerStateSection)
    page.primarySliderRow:SetPoint("TOPLEFT", page.toggleRow, "BOTTOMLEFT", 0, -14)
    page.primarySliderRow:SetPoint("TOPRIGHT", page.toggleRow, "BOTTOMRIGHT", 0, -14)
    page.primarySliderRow:SetHeight(60)

    page.tintStrengthSlider = CreateEffectSlider("tintStrength")
    page.tintStrengthSlider:SetPoint("TOPLEFT", page.primarySliderRow, "TOPLEFT", 0, 0)
    page.tintStrengthSlider:SetWidth(170)

    page.brightnessSlider = CreateEffectSlider("brightness")
    page.brightnessSlider:SetPoint("TOPLEFT", page.tintStrengthSlider, "TOPRIGHT", controlGap, 0)
    page.brightnessSlider:SetWidth(170)

    page.alphaSlider = CreateEffectSlider("alpha")
    page.alphaSlider:SetPoint("TOPLEFT", page.brightnessSlider, "TOPRIGHT", controlGap, 0)
    page.alphaSlider:SetPoint("TOPRIGHT", page.primarySliderRow, "TOPRIGHT", 0, 0)

    page.secondarySliderRow = CreateFrame("Frame", nil, page.playerStateSection)
    page.secondarySliderRow:SetPoint("TOPLEFT", page.primarySliderRow, "BOTTOMLEFT", 0, -12)
    page.secondarySliderRow:SetPoint("TOPRIGHT", page.primarySliderRow, "BOTTOMRIGHT", 0, -12)
    page.secondarySliderRow:SetHeight(60)

    page.pulseSpeedSlider = CreateEffectSlider("pulseSpeed")
    page.pulseSpeedSlider:SetPoint("TOPLEFT", page.secondarySliderRow, "TOPLEFT", 0, 0)
    page.pulseSpeedSlider:SetWidth(170)

    page.pulseStrengthSlider = CreateEffectSlider("pulseStrength")
    page.pulseStrengthSlider:SetPoint("TOPLEFT", page.pulseSpeedSlider, "TOPRIGHT", controlGap, 0)
    page.pulseStrengthSlider:SetWidth(170)

    page.transitionSpeedSlider = CreateEffectSlider("transitionSpeed")
    page.transitionSpeedSlider:SetPoint("TOPLEFT", page.pulseStrengthSlider, "TOPRIGHT", controlGap, 0)
    page.transitionSpeedSlider:SetPoint("TOPRIGHT", page.secondarySliderRow, "TOPRIGHT", 0, 0)

    page.resetButton = CreateFrame("Button", nil, page.playerStateSection, "UIPanelButtonTemplate")
    page.resetButton:SetSize(120, 24)
    page.resetButton:SetText("Reset to Default")
    page.resetButton:SetPoint("TOPLEFT", page.secondarySliderRow, "BOTTOMLEFT", 2, -18)
    page.resetButton:SetScript("OnClick", function()
        if not page.selectedEffectKey then
            return
        end

        ResetPlayerStateEffectToDefaults(self, page.selectedEffectKey)
        page:RefreshControls()
    end)

    page.RefreshControls = function(currentPage)
        if not currentPage.selectedEffectKey then
            currentPage.selectedEffectKey = PLAYER_STATE_EFFECT_ORDER[1]
        end

        SetSelectedEffect(currentPage.selectedEffectKey)

        local effectKey = currentPage.selectedEffectKey
        local enabled = GetPlayerStateEffectValue(self, effectKey, "enabled") and true or false
        local pulseEnabled = enabled and (GetPlayerStateEffectValue(self, effectKey, "pulseEnabled") and true or false) or false
        local colorR = GetPlayerStateEffectValue(self, effectKey, "colorR") or 1
        local colorG = GetPlayerStateEffectValue(self, effectKey, "colorG") or 1
        local colorB = GetPlayerStateEffectValue(self, effectKey, "colorB") or 1
        local previewActive = (self.GetPlayerStateEffectPreviewKey and self:GetPlayerStateEffectPreviewKey() == effectKey) and true or false

        currentPage.enableToggle.check:SetChecked(enabled)
        SetInlineCheckboxStableEnabled(currentPage.enableToggle, true)

        currentPage.colorSwatch:SetSwatchColor(colorR, colorG, colorB)
        currentPage.colorSwatch:SetEnabledState(enabled)
        SetEffectLabelEnabled(currentPage.colorLabel, enabled)
        StyleText(currentPage.stateLabel, FONT_STYLES.sectionTitle)

        for _, sliderData in ipairs(PLAYER_STATE_EFFECT_SLIDER_DEFS) do
            RefreshEffectSlider(currentPage, effectKey, sliderData.id)
        end

        currentPage.pulseToggle.check:SetChecked(GetPlayerStateEffectValue(self, effectKey, "pulseEnabled") and true or false)
        currentPage.desaturateToggle.check:SetChecked(GetPlayerStateEffectValue(self, effectKey, "desaturate") and true or false)
        currentPage.previewToggle.check:SetChecked(previewActive)
        SetInlineCheckboxStableEnabled(currentPage.pulseToggle, enabled)
        SetInlineCheckboxStableEnabled(currentPage.desaturateToggle, enabled)
        SetInlineCheckboxStableEnabled(currentPage.previewToggle, enabled)
        SetValueSliderEnabled(currentPage.tintStrengthSlider, enabled)
        SetValueSliderEnabled(currentPage.brightnessSlider, enabled)
        SetValueSliderEnabled(currentPage.alphaSlider, enabled)
        SetValueSliderEnabled(currentPage.pulseSpeedSlider, pulseEnabled)
        SetValueSliderEnabled(currentPage.pulseStrengthSlider, pulseEnabled)
        SetValueSliderEnabled(currentPage.transitionSpeedSlider, enabled)
        SetButtonEnabled(currentPage.resetButton, enabled)

        UpdateEffectsScrollLayout()
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
    page.summary.bg:Show()
    page.summary.bg:SetVertexColor(0, 0, 0, 0.22)

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

    page.commandsValue = CreateText(page.summary, "GameFontHighlight", "/gg or /gauntletglow", FONT_STYLES.body)
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

    local frame = CreateFrame("Frame", "GauntletGlowConfigFrame", UIParent, "BasicFrameTemplateWithInset")
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
        frame.TitleText:SetText("GauntletGlow")
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
            BuildAppearancePage(self, page)
        elseif pageData.key == "effects" then
            BuildEffectsPage(self, page)
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

function GG:SetupOptions()
    self.optionsInitialized = true
end

function GG:OpenConfig()
    local frame = CreateConfigFrame(self)
    frame:Show()
    if frame.Raise then
        frame:Raise()
    end
    SelectPage(self, frame.currentPage or PAGES[1].key)
end
