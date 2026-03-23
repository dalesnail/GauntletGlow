-- ############################################################
-- CORE: Addon Initialization
-- ############################################################

local ADDON_NAME, ns = ...
local GG = ns.GauntletGlow

GG = LibStub("AceAddon-3.0"):NewAddon(
    ADDON_NAME,
    "AceEvent-3.0",
    "AceTimer-3.0",
    "AceConsole-3.0"
)

ns.GauntletGlow = GG

local LOOT_EXPIRATION = 240
local CLEANUP_INTERVAL = 30

function GG:OnInitialize()
    _G.GauntletGlowNS = ns

    self.db = LibStub("AceDB-3.0"):New("GauntletGlowDB", {
        profile = {

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
            trainerSizeX = 69,
            trainerSizeY = 70,
            trainerOffsetX = 16,
            trainerOffsetY = -15.5,

            -- DIRECTIONS GUARD
            directionsGuardSizeX = 68,
            directionsGuardSizeY = 69,
            directionsGuardOffsetX = 15.5,
            directionsGuardOffsetY = -15,

            -- INNKEEPER
            innkeeperSizeX = 66,
            innkeeperSizeY = 66,
            innkeeperOffsetX = 14,
            innkeeperOffsetY = -14,

            -- STABLEMASTER
            stableMasterSizeX = 69,
            stableMasterSizeY = 69,
            stableMasterOffsetX = 15.5,
            stableMasterOffsetY = -15.5,

            -- MAILBOX
            mailboxSizeX = 70,
            mailboxSizeY = 65,
            mailboxOffsetX = 16,
            mailboxOffsetY = -13.5,

            -- BANKER
            bankerSizeX = 64,
            bankerSizeY = 64,
            bankerOffsetX = 13,
            bankerOffsetY = -13,

            -- SKINNABLE
            skinnableSizeX = 69,
            skinnableSizeY = 66,
            skinnableOffsetX = 16,
            skinnableOffsetY = -16,

            -- VENDOR
            vendorSizeX = 64,
            vendorSizeY = 64,
            vendorOffsetX = 13,
            vendorOffsetY = -13,

            -- REPAIR VENDOR
            repairVendorSizeX = 67,
            repairVendorSizeY = 68,
            repairVendorOffsetX = 14.5,
            repairVendorOffsetY = -15,

            -- SELL ITEM
            sellItemSizeX = 64,
            sellItemSizeY = 64,
            sellItemOffsetX = 13,
            sellItemOffsetY = -13,

        }
    })

    self.lootedUnits = {}
    self.lastMouseoverGUID = nil
    self.States = ns.States
end

function GG:OnEnable()
    self:CreateGauntletGlow()
    self:StartCursorMovement()
    self:StartTriggerLoop()
    self:SetupOptions()

    self:RegisterChatCommand("gg", "OpenConfig")
    self:RegisterChatCommand("gauntletglow", "OpenConfig")

    self:RegisterEvent("LOOT_OPENED")

    self.cleanupTimer = self:ScheduleRepeatingTimer("CleanupLootedUnits", CLEANUP_INTERVAL)
end

function GG:LOOT_OPENED()
    if self.lastMouseoverGUID then
        self.lootedUnits[self.lastMouseoverGUID] = GetTime()
    end
end

function GG:CleanupLootedUnits()
    local now = GetTime()

    for guid, timestamp in pairs(self.lootedUnits) do
        if now - timestamp > LOOT_EXPIRATION then
            self.lootedUnits[guid] = nil
        end
    end
end

function GG:OnDisable()
    if self.cleanupTimer then
        self:CancelTimer(self.cleanupTimer)
        self.cleanupTimer = nil
    end
end
