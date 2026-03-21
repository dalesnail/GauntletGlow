-- ############################################################
-- CORE: Addon Initialization
-- ############################################################

local ADDON_NAME, ns = ...

local CursorGlow = LibStub("AceAddon-3.0"):NewAddon(
    ADDON_NAME,
    "AceEvent-3.0",
    "AceTimer-3.0",
    "AceConsole-3.0"
)

ns.CursorGlow = CursorGlow

local LOOT_EXPIRATION = 240
local CLEANUP_INTERVAL = 30

function CursorGlow:OnInitialize()
    _G.CursorGlowNS = ns

    self.db = LibStub("AceDB-3.0"):New("CursorGlowDB", {
        profile = {

            enabled = true,
            testMode = false,

            -- DEFAULT
            offsetX = 15,
            offsetY = -13.5,
            sizeX = 68,
            sizeY = 65,

            -- ATTACK
            swordSizeX = 70,
            swordSizeY = 70,
            swordOffsetX = 16,
            swordOffsetY = -16,

            -- LOOT
            lootOffsetX = 13,
            lootOffsetY = -13,
            lootSizeX = 64,
            lootSizeY = 64,

            -- AUTO LOOT
            autoLootOffsetX = 15,
            autoLootOffsetY = -15,
            autoLootSizeX = 68,
            autoLootSizeY = 68,

            -- HERBALISM
            herbSizeX = 70,
            herbSizeY = 70,
            herbOffsetX = 16,
            herbOffsetY = -16,

            -- MINING
            miningSizeX = 65,
            miningSizeY = 70,
            miningOffsetX = 13.5,
            miningOffsetY = -16,

            -- FLIGHTMASTER
            flightMasterSizeX = 70,
            flightMasterSizeY = 70,
            flightMasterOffsetX = 16,
            flightMasterOffsetY = -16,

            -- BATTLEMASTER
            battlemasterSizeX = 69,
            battlemasterSizeY = 70,
            battlemasterOffsetX = 16,
            battlemasterOffsetY = -16,

            -- TRAINER
            trainerSizeX = 70,
            trainerSizeY = 69,
            trainerOffsetX = 16,
            trainerOffsetY = -16,

            -- DIRECTIONS GUARD
            directionsGuardSizeX = 69,
            directionsGuardSizeY = 68,
            directionsGuardOffsetX = 16,
            directionsGuardOffsetY = -16,

            -- INNKEEPER
            innkeeperSizeX = 66,
            innkeeperSizeY = 66,
            innkeeperOffsetX = 16,
            innkeeperOffsetY = -16,
        }
    })

    self.lootedUnits = {}
    self.lastMouseoverGUID = nil
    self.States = ns.States
end

function CursorGlow:OnEnable()
    self:CreateCursorGlow()
    self:StartCursorMovement()
    self:StartTriggerLoop()
    self:SetupOptions()

    self:RegisterChatCommand("cg", "OpenConfig")
    self:RegisterChatCommand("cursorglow", "OpenConfig")

    self:RegisterEvent("LOOT_OPENED")

    self.cleanupTimer = self:ScheduleRepeatingTimer("CleanupLootedUnits", CLEANUP_INTERVAL)
end

function CursorGlow:LOOT_OPENED()
    if self.lastMouseoverGUID then
        self.lootedUnits[self.lastMouseoverGUID] = GetTime()
    end
end

function CursorGlow:CleanupLootedUnits()
    local now = GetTime()

    for guid, timestamp in pairs(self.lootedUnits) do
        if now - timestamp > LOOT_EXPIRATION then
            self.lootedUnits[guid] = nil
        end
    end
end

function CursorGlow:OnDisable()
    if self.cleanupTimer then
        self:CancelTimer(self.cleanupTimer)
        self.cleanupTimer = nil
    end
end
