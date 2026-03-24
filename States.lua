local ADDON_NAME, ns = ...
local GG = ns.GauntletGlow

local cursorStateDefaults = ns.CursorStateDefaults or {}

local function CreateState(texture, stateKey)
    local defaults = cursorStateDefaults[stateKey] or cursorStateDefaults.DEFAULT or {}

    return {
        texture = texture,
        sizeX = defaults.sizeX,
        sizeY = defaults.sizeY,
        offsetX = defaults.offsetX,
        offsetY = defaults.offsetY,
    }
end

ns.States = {

    DEFAULT = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\cursor_glow_default.png", "DEFAULT"),

    ATTACK = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\sword_glow_default.png", "ATTACK"),

    LOOT = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\loot_glow.png", "LOOT"),

    AUTOLOOT = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\autoloot_glow.png", "AUTOLOOT"),

    HERBALISM = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\herb_glow.png", "HERBALISM"),

    MINING = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\mining_glow.png", "MINING"),

    FLIGHTMASTER = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\flight_glow.png", "FLIGHTMASTER"),

    BATTLEMASTER = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\battlemaster_glow.png", "BATTLEMASTER"),

    TRAINER = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\trainer_glow.png", "TRAINER"),

    SPEAK = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\speak_glow.png", "SPEAK"),

    DIRECTIONS_GUARD = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\directions_glow.png", "DIRECTIONS_GUARD"),

    INNKEEPER = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\innkeeper_glow.png", "INNKEEPER"),

    STABLEMASTER = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\stablemaster_glow.png", "STABLEMASTER"),

    MAILBOX = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\mail_glow.png", "MAILBOX"),

    FINANCE = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\loot_glow.png", "FINANCE"),

    SKINNABLE = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\skinnable_glow.png", "SKINNABLE"),

    VENDOR = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\loot_glow.png", "VENDOR"),

    SELL_ITEM = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\loot_glow.png", "SELL_ITEM"),

    REPAIR_VENDOR = CreateState("Interface\\AddOns\\GauntletGlow\\Media\\repair_glow.png", "REPAIR_VENDOR"),
}

-- ############################################################
-- PRIORITY SYSTEM
-- ############################################################

ns.StatePriority = {
    SELL_ITEM = 100,
    HERBALISM = 95,
    MINING = 95,
    FLIGHTMASTER = 90,
    BATTLEMASTER = 88,
    TRAINER = 87,
    SPEAK = 86.5,
    DIRECTIONS_GUARD = 86,
    INNKEEPER = 84,
    STABLEMASTER = 83,
    MAILBOX = 82,
    FINANCE = 81.75,
    VENDOR = 81,
    REPAIR_VENDOR = 81.5,
    AUTOLOOT = 85,
    LOOT = 80,
    SKINNABLE = 79,
    ATTACK = 70,
    DEFAULT = 0,
}
