local ADDON_NAME, ns = ...
local strlower = strlower
local strsplit = strsplit
local strtrim = strtrim
local GetTime = GetTime
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local bit_band = bit and bit.band or bit32 and bit32.band

ns.CursorStateDefaults = ns.CursorStateDefaults or {
    DEFAULT = {
        sizeX = 68,
        sizeY = 65,
        offsetX = 15,
        offsetY = -13.5,
    },
    ATTACK = {
        sizeX = 70,
        sizeY = 70,
        offsetX = 16,
        offsetY = -16,
    },
    LOOT = {
        sizeX = 64,
        sizeY = 64,
        offsetX = 13,
        offsetY = -13,
    },
    AUTOLOOT = {
        sizeX = 68,
        sizeY = 68,
        offsetX = 15,
        offsetY = -15,
    },
    HERBALISM = {
        sizeX = 70,
        sizeY = 70,
        offsetX = 16,
        offsetY = -16,
    },
    MINING = {
        sizeX = 65,
        sizeY = 70,
        offsetX = 13.5,
        offsetY = -16,
    },
    FLIGHTMASTER = {
        sizeX = 70,
        sizeY = 70,
        offsetX = 16,
        offsetY = -16,
    },
    BATTLEMASTER = {
        sizeX = 69,
        sizeY = 70,
        offsetX = 16,
        offsetY = -16,
    },
    TRAINER = {
        sizeX = 69,
        sizeY = 70,
        offsetX = 16,
        offsetY = -15.5,
    },
    SPEAK = {
        sizeX = 67,
        sizeY = 64,
        offsetX = 14.5,
        offsetY = -13,
    },
    DIRECTIONS_GUARD = {
        sizeX = 68,
        sizeY = 69,
        offsetX = 15.5,
        offsetY = -15,
    },
    INNKEEPER = {
        sizeX = 66,
        sizeY = 66,
        offsetX = 14,
        offsetY = -14,
    },
    STABLEMASTER = {
        sizeX = 69,
        sizeY = 69,
        offsetX = 15.5,
        offsetY = -15.5,
    },
    MAILBOX = {
        sizeX = 70,
        sizeY = 65,
        offsetX = 16,
        offsetY = -13.5,
    },
    QUEST_AVAILABLE = {
        sizeX = 59,
        sizeY = 68,
        offsetX = 10.5,
        offsetY = -15,
    },
    QUEST_TURN_IN = {
        sizeX = 62,
        sizeY = 67,
        offsetX = 12,
        offsetY = -14.5,
    },
    COGWHEEL = {
        sizeX = 64,
        sizeY = 64,
        offsetX = 14,
        offsetY = -14,
    },
    FINANCE = {
        sizeX = 64,
        sizeY = 64,
        offsetX = 13,
        offsetY = -13,
    },
    SKINNABLE = {
        sizeX = 69,
        sizeY = 66,
        offsetX = 16,
        offsetY = -16,
    },
    VENDOR = {
        sizeX = 64,
        sizeY = 64,
        offsetX = 13,
        offsetY = -13,
    },
    SELL_ITEM = {
        sizeX = 64,
        sizeY = 64,
        offsetX = 13,
        offsetY = -13,
    },
    REPAIR_VENDOR = {
        sizeX = 67,
        sizeY = 68,
        offsetX = 14.5,
        offsetY = -15,
    },
    REPAIR_HOVER = {
        sizeX = 69,
        sizeY = 69,
        offsetX = 15.5,
        offsetY = -15.5,
    },
}

ns.CursorTrailDefaults = ns.CursorTrailDefaults or {
    enabled = false,
    size = 34,
    alpha = 0.60,
    lifetime = 0.42,
    trailLength = 72,
    spacing = 12,
    color = {
        r = 0.32,
        g = 0.86,
        b = 1.00,
    },
}

ns.PlayerStateEffects = ns.PlayerStateEffects or {
    order = {
        "LOW_HEALTH",
        "COMBAT",
        "MOUNTED",
        "RESTING",
    },
    labels = {
        COMBAT = "Combat",
        LOW_HEALTH = "Low Health",
        MOUNTED = "Mounted",
        RESTING = "Resting",
    },
    priority = {
        LOW_HEALTH = 40,
        COMBAT = 30,
        MOUNTED = 20,
        RESTING = 10,
    },
    lowHealthThreshold = 0.35,
    neutral = {
        colorR = 1,
        colorG = 1,
        colorB = 1,
        tintStrength = 0,
        brightness = 1,
        alpha = 1,
        desaturate = false,
        pulseEnabled = false,
        pulseSpeed = 1.5,
        pulseStrength = 0,
        transitionSpeed = 4,
    },
    defaults = {
        COMBAT = {
            enabled = false,
            colorR = 1.0,
            colorG = 0.28,
            colorB = 0.16,
            tintStrength = 0.55,
            brightness = 1.18,
            alpha = 1,
            desaturate = true,
            pulseEnabled = false,
            pulseSpeed = 1.10,
            pulseStrength = 0.16,
            transitionSpeed = 5.00,
        },
        LOW_HEALTH = {
            enabled = false,
            colorR = 1.0,
            colorG = 0.10,
            colorB = 0.10,
            tintStrength = 0.72,
            brightness = 1.24,
            alpha = 1,
            desaturate = true,
            pulseEnabled = true,
            pulseSpeed = 0.95,
            pulseStrength = 0.52,
            transitionSpeed = 7.00,
        },
        MOUNTED = {
            enabled = false,
            colorR = 1.0,
            colorG = 0.84,
            colorB = 0.54,
            tintStrength = 0.32,
            brightness = 1.14,
            alpha = 1,
            desaturate = true,
            pulseEnabled = false,
            pulseSpeed = 0.85,
            pulseStrength = 0.10,
            transitionSpeed = 4.00,
        },
        RESTING = {
            enabled = false,
            colorR = 0.68,
            colorG = 0.82,
            colorB = 0.96,
            tintStrength = 0.30,
            brightness = 1.00,
            alpha = 1,
            desaturate = false,
            pulseEnabled = false,
            pulseSpeed = 0.75,
            pulseStrength = 0.08,
            transitionSpeed = 3.50,
        },
    },
}

ns.QuestieObjectiveEffectDefaults = ns.QuestieObjectiveEffectDefaults or {
    enabled = false,
    colorR = 1.0,
    colorG = 0.82,
    colorB = 0.20,
    tintStrength = 0.65,
    brightness = 1.08,
    alpha = 1,
    desaturate = true,
    pulseEnabled = false,
    pulseSpeed = 1.00,
    pulseStrength = 0,
    transitionSpeed = 5.00,
}

ns.CursorStateDefaults.QUEST_INCOMPLETE = ns.CursorStateDefaults.QUEST_INCOMPLETE or ns.CursorStateDefaults.QUEST_AVAILABLE

local CURSOR_STATE_PROFILE_KEYS = {
    DEFAULT = {
        sizeX = "sizeX",
        sizeY = "sizeY",
        offsetX = "offsetX",
        offsetY = "offsetY",
    },
    ATTACK = {
        sizeX = "swordSizeX",
        sizeY = "swordSizeY",
        offsetX = "swordOffsetX",
        offsetY = "swordOffsetY",
    },
    LOOT = {
        sizeX = "lootSizeX",
        sizeY = "lootSizeY",
        offsetX = "lootOffsetX",
        offsetY = "lootOffsetY",
    },
    AUTOLOOT = {
        sizeX = "autoLootSizeX",
        sizeY = "autoLootSizeY",
        offsetX = "autoLootOffsetX",
        offsetY = "autoLootOffsetY",
    },
    HERBALISM = {
        sizeX = "herbSizeX",
        sizeY = "herbSizeY",
        offsetX = "herbOffsetX",
        offsetY = "herbOffsetY",
    },
    MINING = {
        sizeX = "miningSizeX",
        sizeY = "miningSizeY",
        offsetX = "miningOffsetX",
        offsetY = "miningOffsetY",
    },
    FLIGHTMASTER = {
        sizeX = "flightMasterSizeX",
        sizeY = "flightMasterSizeY",
        offsetX = "flightMasterOffsetX",
        offsetY = "flightMasterOffsetY",
    },
    BATTLEMASTER = {
        sizeX = "battlemasterSizeX",
        sizeY = "battlemasterSizeY",
        offsetX = "battlemasterOffsetX",
        offsetY = "battlemasterOffsetY",
    },
    TRAINER = {
        sizeX = "trainerSizeX",
        sizeY = "trainerSizeY",
        offsetX = "trainerOffsetX",
        offsetY = "trainerOffsetY",
    },
    SPEAK = {
        sizeX = "speakSizeX",
        sizeY = "speakSizeY",
        offsetX = "speakOffsetX",
        offsetY = "speakOffsetY",
    },
    DIRECTIONS_GUARD = {
        sizeX = "directionsGuardSizeX",
        sizeY = "directionsGuardSizeY",
        offsetX = "directionsGuardOffsetX",
        offsetY = "directionsGuardOffsetY",
    },
    INNKEEPER = {
        sizeX = "innkeeperSizeX",
        sizeY = "innkeeperSizeY",
        offsetX = "innkeeperOffsetX",
        offsetY = "innkeeperOffsetY",
    },
    STABLEMASTER = {
        sizeX = "stableMasterSizeX",
        sizeY = "stableMasterSizeY",
        offsetX = "stableMasterOffsetX",
        offsetY = "stableMasterOffsetY",
    },
    MAILBOX = {
        sizeX = "mailboxSizeX",
        sizeY = "mailboxSizeY",
        offsetX = "mailboxOffsetX",
        offsetY = "mailboxOffsetY",
    },
    QUEST_AVAILABLE = {
        sizeX = "questAvailableSizeX",
        sizeY = "questAvailableSizeY",
        offsetX = "questAvailableOffsetX",
        offsetY = "questAvailableOffsetY",
    },
    QUEST_TURN_IN = {
        sizeX = "questTurnInSizeX",
        sizeY = "questTurnInSizeY",
        offsetX = "questTurnInOffsetX",
        offsetY = "questTurnInOffsetY",
    },
    COGWHEEL = {
        sizeX = "cogwheelSizeX",
        sizeY = "cogwheelSizeY",
        offsetX = "cogwheelOffsetX",
        offsetY = "cogwheelOffsetY",
    },
    FINANCE = {
        sizeX = "bankerSizeX",
        sizeY = "bankerSizeY",
        offsetX = "bankerOffsetX",
        offsetY = "bankerOffsetY",
    },
    SKINNABLE = {
        sizeX = "skinnableSizeX",
        sizeY = "skinnableSizeY",
        offsetX = "skinnableOffsetX",
        offsetY = "skinnableOffsetY",
    },
    VENDOR = {
        sizeX = "vendorSizeX",
        sizeY = "vendorSizeY",
        offsetX = "vendorOffsetX",
        offsetY = "vendorOffsetY",
    },
    SELL_ITEM = {
        sizeX = "sellItemSizeX",
        sizeY = "sellItemSizeY",
        offsetX = "sellItemOffsetX",
        offsetY = "sellItemOffsetY",
    },
    REPAIR_VENDOR = {
        sizeX = "repairVendorSizeX",
        sizeY = "repairVendorSizeY",
        offsetX = "repairVendorOffsetX",
        offsetY = "repairVendorOffsetY",
    },
    REPAIR_HOVER = {
        sizeX = "repairHoverSizeX",
        sizeY = "repairHoverSizeY",
        offsetX = "repairHoverOffsetX",
        offsetY = "repairHoverOffsetY",
    },
}

CURSOR_STATE_PROFILE_KEYS.QUEST_INCOMPLETE = CURSOR_STATE_PROFILE_KEYS.QUEST_INCOMPLETE or CURSOR_STATE_PROFILE_KEYS.QUEST_AVAILABLE

local function CopyTable(source)
    local copy = {}

    for key, value in pairs(source or {}) do
        if type(value) == "table" then
            copy[key] = CopyTable(value)
        else
            copy[key] = value
        end
    end

    return copy
end

local function CreateProfileDefaults()
    local profileDefaults = {
        enabled = true,
        testMode = false,
        useCustomColor = false,
        colorR = 1,
        colorG = 1,
        colorB = 1,
        desaturateTexture = false,
        useBrightness = false,
        brightness = 1,
        useGlobalAlpha = false,
        globalAlpha = 1,
        blendMode = "GLOW",
        effects = {
            playerStates = {},
            questieHighlight = CopyTable(ns.QuestieObjectiveEffectDefaults),
        },
        cursorTrail = CopyTable(ns.CursorTrailDefaults),
    }

    for stateKey, profileKeys in pairs(CURSOR_STATE_PROFILE_KEYS) do
        local stateDefaults = ns.CursorStateDefaults[stateKey]
        if stateDefaults then
            profileDefaults[profileKeys.sizeX] = stateDefaults.sizeX
            profileDefaults[profileKeys.sizeY] = stateDefaults.sizeY
            profileDefaults[profileKeys.offsetX] = stateDefaults.offsetX
            profileDefaults[profileKeys.offsetY] = stateDefaults.offsetY
        end
    end

    for effectKey, effectDefaults in pairs((ns.PlayerStateEffects and ns.PlayerStateEffects.defaults) or {}) do
        profileDefaults.effects.playerStates[effectKey] = CopyTable(effectDefaults)
    end

    return profileDefaults
end

GG = LibStub("AceAddon-3.0"):NewAddon(
    ADDON_NAME,
    "AceEvent-3.0",
    "AceTimer-3.0",
    "AceConsole-3.0"
)

ns.GauntletGlow = GG

local LOOT_EXPIRATION = 480
local RECENT_CORPSE_EXPIRATION = 30
local CLEANUP_INTERVAL = 30

local GROUP_COMBATLOG_FLAGS = COMBATLOG_OBJECT_AFFILIATION_MINE
    + COMBATLOG_OBJECT_AFFILIATION_PARTY
    + COMBATLOG_OBJECT_AFFILIATION_RAID
    + COMBATLOG_OBJECT_REACTION_FRIENDLY
local GROUP_CONTROL_FLAGS = COMBATLOG_OBJECT_CONTROL_PLAYER + COMBATLOG_OBJECT_CONTROL_NPC
local NPC_COMBATLOG_FLAGS = COMBATLOG_OBJECT_TYPE_NPC
local ELIGIBLE_CORPSE_EVENTS = {
    DAMAGE_SHIELD = true,
    DAMAGE_SPLIT = true,
    RANGE_DAMAGE = true,
    SPELL_BUILDING_DAMAGE = true,
    SPELL_DAMAGE = true,
    SPELL_PERIODIC_DAMAGE = true,
    SWING_DAMAGE = true,
}

local function HasCombatLogFlag(flags, mask)
    return flags and mask and bit_band and bit_band(flags, mask) ~= 0 or false
end

local function IsGroupCombatUnit(flags)
    return HasCombatLogFlag(flags, GROUP_COMBATLOG_FLAGS) and HasCombatLogFlag(flags, GROUP_CONTROL_FLAGS)
end

local function IsNpcCombatUnit(flags)
    return HasCombatLogFlag(flags, NPC_COMBATLOG_FLAGS)
end

local function MigratePlayerStateEffectProfile(effectKey, effectProfile)
    if not effectProfile then
        return
    end

    if effectProfile.alphaEnabled ~= nil then
        if effectProfile.alphaEnabled then
            if effectProfile.alpha == nil then
                local defaults = GG:GetPlayerStateEffectDefaults(effectKey)
                effectProfile.alpha = (defaults and defaults.alpha) or 1
            end
        else
            effectProfile.alpha = 1
        end

        effectProfile.alphaEnabled = nil
    end
end

function GG:OnInitialize()
    _G.GauntletGlowNS = ns

    self.db = LibStub("AceDB-3.0"):New("GauntletGlowDB", {
        profile = CreateProfileDefaults(),
        global = {
            learnedNpcTags = {
                vendor = {},
                repair_vendor = {},
            },
        },
    })

    self:MigratePlayerStateEffects()

    self.lootedUnits = {}
    self.recentCorpseGUIDs = {}
    self.lastMouseoverGUID = nil
    self.questieObjectiveHoverActive = false
    self.playerStateEffectPreviewEnabled = false
    self.playerStateEffectPreviewKey = nil
    self.States = ns.States
end

function GG:OnEnable()
    self:CreateGauntletGlow()
    self:StartCursorMovement()
    self:StartTriggerLoop()
    self:SetupOptions()
    self:RefreshCursorTrail()

    self:RegisterChatCommand("gg", "HandleChatCommand")
    self:RegisterChatCommand("gauntletglow", "HandleChatCommand")

    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("LOOT_OPENED")
    self:RegisterEvent("MERCHANT_SHOW")
    self:RegisterEvent("DISPLAY_SIZE_CHANGED", "HandleCursorEnvironmentChanged")
    self:RegisterEvent("UI_SCALE_CHANGED", "HandleCursorEnvironmentChanged")

    self.cleanupTimer = self:ScheduleRepeatingTimer("CleanupLootedUnits", CLEANUP_INTERVAL)
end

function GG:LOOT_OPENED()
    if self.lastMouseoverGUID then
        self.lootedUnits[self.lastMouseoverGUID] = GetTime()
    end
end

function GG:MarkRecentCorpseGUID(guid)
    if guid then
        self.recentCorpseGUIDs[guid] = GetTime()
    end
end

function GG:IsRecentCorpseGUID(guid)
    local timestamp = guid and self.recentCorpseGUIDs[guid]
    return timestamp and (GetTime() - timestamp) < RECENT_CORPSE_EXPIRATION or false
end

function GG:COMBAT_LOG_EVENT_UNFILTERED()
    if not CombatLogGetCurrentEventInfo then
        return
    end

    local _, eventType, _, sourceGUID, _, sourceFlags, _, destGUID, _, destFlags = CombatLogGetCurrentEventInfo()
    if not ELIGIBLE_CORPSE_EVENTS[eventType] then
        return
    end

    if IsGroupCombatUnit(sourceFlags) and IsNpcCombatUnit(destFlags) then
        self:MarkRecentCorpseGUID(destGUID)
    elseif IsNpcCombatUnit(sourceFlags) and IsGroupCombatUnit(destFlags) then
        self:MarkRecentCorpseGUID(sourceGUID)
    end
end

function GG:CleanupLootedUnits()
    local now = GetTime()

    for guid, timestamp in pairs(self.lootedUnits) do
        if now - timestamp > LOOT_EXPIRATION then
            self.lootedUnits[guid] = nil
        end
    end

    for guid, timestamp in pairs(self.recentCorpseGUIDs) do
        if now - timestamp > RECENT_CORPSE_EXPIRATION then
            self.recentCorpseGUIDs[guid] = nil
        end
    end
end

function GG:NormalizeLearnedNpcCache()
    local global = self.db and self.db.global
    if not global then
        return nil
    end

    global.learnedNpcTags = global.learnedNpcTags or {}
    global.learnedNpcTags.vendor = global.learnedNpcTags.vendor or {}
    global.learnedNpcTags.repair_vendor = global.learnedNpcTags.repair_vendor or {}

    return global.learnedNpcTags
end

function GG:OnDisable()
    if self.cleanupTimer then
        self:CancelTimer(self.cleanupTimer)
        self.cleanupTimer = nil
    end

    if ns.CursorTrail and ns.CursorTrail.Shutdown then
        ns.CursorTrail:Shutdown()
    end
end

function GG:GetPlayerStateEffectDefaults(effectKey)
    local effectData = ns.PlayerStateEffects
    local defaults = effectData and effectData.defaults
    return defaults and defaults[effectKey] or nil
end

function GG:GetPlayerStateEffectProfile(effectKey)
    local profile = self.db and self.db.profile
    local effects = profile and profile.effects
    local playerStates = effects and effects.playerStates
    local effectProfile = playerStates and playerStates[effectKey] or nil

    if effectProfile then
        MigratePlayerStateEffectProfile(effectKey, effectProfile)
    end

    return effectProfile
end

function GG:GetPlayerStateEffectValue(effectKey, valueKey)
    local profile = self:GetPlayerStateEffectProfile(effectKey)
    if profile and profile[valueKey] ~= nil then
        return profile[valueKey]
    end

    local defaults = self:GetPlayerStateEffectDefaults(effectKey)
    if defaults and defaults[valueKey] ~= nil then
        return defaults[valueKey]
    end

    return nil
end

function GG:IsPlayerStateEffectEnabled(effectKey)
    local enabled = self:GetPlayerStateEffectValue(effectKey, "enabled")
    return enabled and true or false
end

function GG:MigratePlayerStateEffects()
    local profile = self.db and self.db.profile
    local effects = profile and profile.effects
    local playerStates = effects and effects.playerStates
    if not playerStates then
        return
    end

    for effectKey, effectProfile in pairs(playerStates) do
        MigratePlayerStateEffectProfile(effectKey, effectProfile)
    end
end

function GG:GetPlayerStateEffectPreviewKey()
    if self.playerStateEffectPreviewEnabled and self.playerStateEffectPreviewKey then
        if not self:IsPlayerStateEffectEnabled(self.playerStateEffectPreviewKey) then
            self.playerStateEffectPreviewEnabled = false
            self.playerStateEffectPreviewKey = nil
            return nil
        end

        return self.playerStateEffectPreviewKey
    end

    return nil
end

function GG:IsPlayerStateEffectPreviewActive(effectKey)
    return effectKey ~= nil and self:GetPlayerStateEffectPreviewKey() == effectKey
end

function GG:SetPlayerStateEffectPreview(effectKey, enabled)
    if enabled and effectKey and self:IsPlayerStateEffectEnabled(effectKey) then
        self.playerStateEffectPreviewEnabled = true
        self.playerStateEffectPreviewKey = effectKey
    else
        self.playerStateEffectPreviewEnabled = false
        self.playerStateEffectPreviewKey = nil
    end

    if self.UpdatePlayerStateEffect then
        self:UpdatePlayerStateEffect()
    elseif self.RefreshPlayerStateEffectTarget then
        self:RefreshPlayerStateEffectTarget()
    elseif self.RefreshGlowAppearance then
        self:RefreshGlowAppearance()
    end
end

function GG:GetCursorTrailProfile()
    local profile = self.db and self.db.profile
    if not profile then
        return nil
    end

    profile.cursorTrail = profile.cursorTrail or {}

    local cursorTrailProfile = profile.cursorTrail
    local defaults = ns.CursorTrailDefaults or {}

    if cursorTrailProfile.enabled == nil then
        cursorTrailProfile.enabled = defaults.enabled and true or false
    end

    if cursorTrailProfile.size == nil then
        cursorTrailProfile.size = defaults.size or 34
    end

    if cursorTrailProfile.alpha == nil then
        cursorTrailProfile.alpha = defaults.alpha or 0.6
    end

    if cursorTrailProfile.lifetime == nil then
        cursorTrailProfile.lifetime = defaults.lifetime or 0.42
    end

    if cursorTrailProfile.trailLength == nil then
        cursorTrailProfile.trailLength = defaults.trailLength or 72
    end

    if cursorTrailProfile.spacing == nil then
        cursorTrailProfile.spacing = defaults.spacing or 12
    end

    if type(cursorTrailProfile.color) ~= "table" then
        cursorTrailProfile.color = {}
    end

    local colorDefaults = defaults.color or {}
    if cursorTrailProfile.color.r == nil then
        cursorTrailProfile.color.r = colorDefaults.r or 1
    end
    if cursorTrailProfile.color.g == nil then
        cursorTrailProfile.color.g = colorDefaults.g or 1
    end
    if cursorTrailProfile.color.b == nil then
        cursorTrailProfile.color.b = colorDefaults.b or 1
    end

    return cursorTrailProfile
end

function GG:GetCursorTrailSettings()
    local profile = self:GetCursorTrailProfile()
    if not profile then
        return nil
    end

    local addonProfile = self.db and self.db.profile or nil
    local addonEnabled = addonProfile and addonProfile.enabled

    return {
        enabled = (addonEnabled ~= false) and (profile.enabled and true or false),
        colorR = profile.color.r or 1,
        colorG = profile.color.g or 1,
        colorB = profile.color.b or 1,
        size = profile.size or 34,
        alpha = profile.alpha or 0.6,
        lifetime = profile.lifetime or 0.42,
        trailLength = profile.trailLength or 72,
        spacing = profile.spacing or 12,
    }
end

function GG:GetQuestieObjectiveEffectDefaults()
    return ns.QuestieObjectiveEffectDefaults or nil
end

function GG:GetQuestieObjectiveEffectProfile()
    local profile = self.db and self.db.profile
    local effects = profile and profile.effects
    if not effects then
        return nil
    end

    if type(effects.questieHighlight) ~= "table" then
        effects.questieHighlight = CopyTable(self:GetQuestieObjectiveEffectDefaults() or {})
    end

    return effects.questieHighlight
end

function GG:GetQuestieObjectiveEffectValue(valueKey)
    local profile = self:GetQuestieObjectiveEffectProfile()
    if profile and profile[valueKey] ~= nil then
        return profile[valueKey]
    end

    local defaults = self:GetQuestieObjectiveEffectDefaults()
    if defaults and defaults[valueKey] ~= nil then
        return defaults[valueKey]
    end

    return nil
end

function GG:IsQuestieObjectiveEffectEnabled()
    local enabled = self:GetQuestieObjectiveEffectValue("enabled")
    return enabled and true or false
end

function GG:RefreshCursorTrail()
    if ns.CursorTrail and ns.CursorTrail.Refresh then
        ns.CursorTrail:Refresh()
    end
end

function GG:SetCursorTrailEnabled(enabled)
    local profile = self:GetCursorTrailProfile()
    if not profile then
        return
    end

    profile.enabled = enabled and true or false
    self:RefreshCursorTrail()
end

local function ParseTrailToggleCommand(input)
    if not input or input == "" then
        return nil
    end

    local command, rest = strsplit(" ", strlower(strtrim(input)), 2)
    if command ~= "trail" then
        return nil
    end

    local mode = rest and strtrim(rest) or ""
    if mode == "" then
        return "toggle"
    end

    if mode == "on" or mode == "off" or mode == "toggle" or mode == "status" then
        return mode
    end

    return "invalid"
end

function GG:HandleChatCommand(input)
    local trailCommand = ParseTrailToggleCommand(input)
    if trailCommand then
        if trailCommand == "invalid" then
            self:Print("Usage: /gg trail on|off|toggle|status")
            return
        end

        local trailProfile = self:GetCursorTrailProfile()
        local enabled = trailProfile and trailProfile.enabled and true or false

        if trailCommand == "toggle" then
            enabled = not enabled
            self:SetCursorTrailEnabled(enabled)
        elseif trailCommand == "on" then
            enabled = true
            self:SetCursorTrailEnabled(true)
        elseif trailCommand == "off" then
            enabled = false
            self:SetCursorTrailEnabled(false)
        end

        self:Print("Cursor trail " .. (enabled and "enabled." or "disabled."))
        return
    end

    self:OpenConfig()
end
