-- ############################################################
-- OPTIONS MODULE (FULL UPDATED)
-- ############################################################

local ADDON_NAME, ns = ...
local CursorGlow = ns.CursorGlow

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local function refresh(self)
    self:RefreshActiveState()
end

local function update(self)
    self:UpdateCursorPosition()
end

local function makeGroup(name, order, sizeX, sizeY, offsetX, offsetY, defaults)
    return {
        type = "group",
        name = name,
        order = order,
        args = {

            sizeY = {
                type = "range", name = "Height",
                order = 1,
                width = 1.25,
                min = 16, max = 300, step = 1,
                get = function() return sizeY() end,
                set = function(_, v) sizeY(v) refresh(CursorGlow) end,
            },

            sizeX = {
                type = "range", name = "Width",
                order = 2,
                width = 1.25,
                min = 16, max = 300, step = 1,
                get = function() return sizeX() end,
                set = function(_, v) sizeX(v) refresh(CursorGlow) end,
            },

            offsetX = {
                type = "range", name = "Offset X",
                order = 3,
                width = 1.25,
                min = -100, max = 100, step = 0.5,
                get = function() return offsetX() end,
                set = function(_, v) offsetX(v) update(CursorGlow) end,
            },

            offsetY = {
                type = "range", name = "Offset Y",
                order = 4,
                width = 1.25,
                min = -100, max = 100, step = 0.5,
                get = function() return offsetY() end,
                set = function(_, v) offsetY(v) update(CursorGlow) end,
            },

            reset = {
                type = "execute",
                name = "Reset",
                order = 5,
                width = "full",
                func = function()
                    defaults()
                    refresh(CursorGlow)
                    update(CursorGlow)
                end,
            },
        }
    }
end

local function BuildOptions(self)

    local p = function() return self.db.profile end

    return {
        type = "group",
        name = "CursorGlow",
        childGroups = "tab",
        args = {

            -- ##################################################
            -- GENERAL
            -- ##################################################

            general = {
                type = "group",
                name = "General",
                order = 0,
                args = {

                    testMode = {
                        type = "toggle",
                        name = "Test Mode",
                        width = "full",
                        order = 1,
                        get = function() return self.db.profile.testMode end,
                        set = function(_, val)
                            self.db.profile.testMode = val

                            if val then
                                self:ApplyVisibility(true)
                                self:ApplyState("DEFAULT", true)
                            else
                                self.currentStateName = nil
                                self.currentVisible = nil
                            end
                        end,
                    },
                },
            },

            -- ##################################################
            -- APPEARANCE (TABBED)
            -- ##################################################

            appearance = {
                type = "group",
                name = "Appearance",
                order = 1,
                childGroups = "tab",
                args = {

                    default = makeGroup("Default", 1,
                        function(v) if v then p().sizeX = v end return p().sizeX end,
                        function(v) if v then p().sizeY = v end return p().sizeY end,
                        function(v) if v then p().offsetX = v end return p().offsetX end,
                        function(v) if v then p().offsetY = v end return p().offsetY end,
                        function()
                            p().sizeX = 68
                            p().sizeY = 65
                            p().offsetX = 15
                            p().offsetY = -13.5
                        end
                    ),

                    attack = makeGroup("Attack", 2,
                        function(v) if v then p().swordSizeX = v end return p().swordSizeX end,
                        function(v) if v then p().swordSizeY = v end return p().swordSizeY end,
                        function(v) if v then p().swordOffsetX = v end return p().swordOffsetX end,
                        function(v) if v then p().swordOffsetY = v end return p().swordOffsetY end,
                        function()
                            p().swordSizeX = 70
                            p().swordSizeY = 70
                            p().swordOffsetX = 16
                            p().swordOffsetY = -16
                        end
                    ),

                    loot = makeGroup("Loot", 3,
                        function(v) if v then p().lootSizeX = v end return p().lootSizeX end,
                        function(v) if v then p().lootSizeY = v end return p().lootSizeY end,
                        function(v) if v then p().lootOffsetX = v end return p().lootOffsetX end,
                        function(v) if v then p().lootOffsetY = v end return p().lootOffsetY end,
                        function()
                            p().lootSizeX = 64
                            p().lootSizeY = 64
                            p().lootOffsetX = 13
                            p().lootOffsetY = -13
                        end
                    ),

                    autoloot = makeGroup("Auto Loot", 4,
                        function(v) if v then p().autoLootSizeX = v end return p().autoLootSizeX end,
                        function(v) if v then p().autoLootSizeY = v end return p().autoLootSizeY end,
                        function(v) if v then p().autoLootOffsetX = v end return p().autoLootOffsetX end,
                        function(v) if v then p().autoLootOffsetY = v end return p().autoLootOffsetY end,
                        function()
                            p().autoLootSizeX = 68
                            p().autoLootSizeY = 68
                            p().autoLootOffsetX = 15
                            p().autoLootOffsetY = -15
                        end
                    ),

                    herb = makeGroup("Herbalism", 5,
                        function(v) if v then p().herbSizeX = v end return p().herbSizeX end,
                        function(v) if v then p().herbSizeY = v end return p().herbSizeY end,
                        function(v) if v then p().herbOffsetX = v end return p().herbOffsetX end,
                        function(v) if v then p().herbOffsetY = v end return p().herbOffsetY end,
                        function()
                            p().herbSizeX = 70
                            p().herbSizeY = 70
                            p().herbOffsetX = 16
                            p().herbOffsetY = -16
                        end
                    ),

                    mining = makeGroup("Mining", 6,
                        function(v) if v then p().miningSizeX = v end return p().miningSizeX end,
                        function(v) if v then p().miningSizeY = v end return p().miningSizeY end,
                        function(v) if v then p().miningOffsetX = v end return p().miningOffsetX end,
                        function(v) if v then p().miningOffsetY = v end return p().miningOffsetY end,
                        function()
                            p().miningSizeX = 65
                            p().miningSizeY = 70
                            p().miningOffsetX = 13.5
                            p().miningOffsetY = -16
                        end
                    ),
                },
            },
        },
    }
end

function CursorGlow:SetupOptions()
    if self.optionsInitialized then return end
    AceConfig:RegisterOptionsTable("CursorGlow", BuildOptions(self))
    self.optionsInitialized = true
end

function CursorGlow:OpenConfig()
    AceConfigDialog:Open("CursorGlow")

    local frame = AceConfigDialog.OpenFrames["CursorGlow"]
    if not frame then return end

    local realFrame = frame.frame

    realFrame:SetWidth(self.db.profile.windowWidth or 1000)
    realFrame:SetHeight(self.db.profile.windowHeight or 600)

    realFrame:SetResizable(true)

    realFrame:SetScript("OnSizeChanged", function(_, w, h)
        self.db.profile.windowWidth = w
        self.db.profile.windowHeight = h
    end)
end