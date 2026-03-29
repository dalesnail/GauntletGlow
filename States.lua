local ADDON_NAME, ns = ...
local GG = ns.GauntletGlow

local cursorStateDefaults = ns.CursorStateDefaults or {}
local mediaRegistry = assert(ns.MediaRegistry, "GauntletGlow media registry is not loaded")

local function CreateState(stateKey)
    local defaults = cursorStateDefaults[stateKey] or cursorStateDefaults.DEFAULT or {}
    local texture = assert(mediaRegistry:GetTexturePath(stateKey), "GauntletGlow missing media texture for state " .. tostring(stateKey))

    return {
        mediaKey = mediaRegistry:GetGroupKeyForState(stateKey),
        texture = texture,
        sizeX = defaults.sizeX,
        sizeY = defaults.sizeY,
        offsetX = defaults.offsetX,
        offsetY = defaults.offsetY,
    }
end

ns.States = {

    DEFAULT = CreateState("DEFAULT"),

    ATTACK = CreateState("ATTACK"),

    LOOT = CreateState("LOOT"),

    AUTOLOOT = CreateState("AUTOLOOT"),

    HERBALISM = CreateState("HERBALISM"),

    MINING = CreateState("MINING"),

    FLIGHTMASTER = CreateState("FLIGHTMASTER"),

    BATTLEMASTER = CreateState("BATTLEMASTER"),

    TRAINER = CreateState("TRAINER"),

    SPEAK = CreateState("SPEAK"),

    DIRECTIONS_GUARD = CreateState("DIRECTIONS_GUARD"),

    INNKEEPER = CreateState("INNKEEPER"),

    STABLEMASTER = CreateState("STABLEMASTER"),

    MAILBOX = CreateState("MAILBOX"),

    QUEST_AVAILABLE = CreateState("QUEST_AVAILABLE"),

    QUEST_INCOMPLETE = CreateState("QUEST_INCOMPLETE"),

    QUEST_TURN_IN = CreateState("QUEST_TURN_IN"),

    FINANCE = CreateState("FINANCE"),

    SKINNABLE = CreateState("SKINNABLE"),

    VENDOR = CreateState("VENDOR"),

    SELL_ITEM = CreateState("SELL_ITEM"),

    REPAIR_VENDOR = CreateState("REPAIR_VENDOR"),

    REPAIR_HOVER = CreateState("REPAIR_HOVER"),
}

-- ############################################################
-- PRIORITY SYSTEM
-- ############################################################

ns.StatePriority = {
    REPAIR_HOVER = 101,
    SELL_ITEM = 100,
    HERBALISM = 95,
    MINING = 95,
    QUEST_TURN_IN = 91,
    QUEST_AVAILABLE = 90.5,
    QUEST_INCOMPLETE = 90.25,
    FLIGHTMASTER = 90,
    BATTLEMASTER = 88,
    REPAIR_VENDOR = 87.5,
    VENDOR = 87,
    TRAINER = 86.75,
    SPEAK = 86.5,
    DIRECTIONS_GUARD = 86,
    INNKEEPER = 84,
    STABLEMASTER = 83,
    MAILBOX = 82,
    FINANCE = 81.75,
    AUTOLOOT = 85,
    LOOT = 80,
    SKINNABLE = 79,
    ATTACK = 70,
    DEFAULT = 0,
}
