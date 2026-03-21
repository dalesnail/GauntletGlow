local ADDON_NAME, ns = ...

ns.States = {

    DEFAULT = {
        texture = "Interface\\AddOns\\CursorGlow\\Media\\cursor_glow_default.png",
        sizeX = 68,
        sizeY = 65,
        offsetX = 15,
        offsetY = -13.5,
    },

    ATTACK = {
        texture = "Interface\\AddOns\\CursorGlow\\Media\\sword_glow.png",
        sizeX = 70,
        sizeY = 70,
        offsetX = 16,
        offsetY = -16,
    },

    LOOT = {
        texture = "Interface\\AddOns\\CursorGlow\\Media\\loot_glow.png",
        sizeX = 64,
        sizeY = 64,
        offsetX = 13,
        offsetY = -13,
    },

    AUTOLOOT = {
        texture = "Interface\\AddOns\\CursorGlow\\Media\\autoloot_glow.png",
        sizeX = 68,
        sizeY = 68,
        offsetX = 15,
        offsetY = -15,
    },

    HERBALISM = {
        texture = "Interface\\AddOns\\CursorGlow\\Media\\herb_glow.png",
        sizeX = 70,
        sizeY = 70,
        offsetX = 16,
        offsetY = -16,
    },

    MINING = {
        texture = "Interface\\AddOns\\CursorGlow\\Media\\mining_glow.png",
        sizeX = 65,
        sizeY = 70,
        offsetX = 13.5,
        offsetY = -16,
    },

    FLIGHTMASTER = {
        texture = "Interface\\AddOns\\CursorGlow\\Media\\flight_glow.png",
        sizeX = 70,
        sizeY = 70,
        offsetX = 16,
        offsetY = -16,
    },
}

-- ############################################################
-- PRIORITY SYSTEM
-- ############################################################

ns.StatePriority = {
    HERBALISM = 100,
    MINING = 95,
    FLIGHTMASTER = 90,
    AUTOLOOT = 85,
    LOOT = 80,
    ATTACK = 60,
    DEFAULT = 0,
}