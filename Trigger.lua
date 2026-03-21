local ADDON_NAME, ns = ...
local CursorGlow = ns.CursorGlow

-- ############################################################
-- LOCALS
-- ############################################################

local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitCanAttack = UnitCanAttack
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsPlayer = UnitIsPlayer
local UnitIsFriend = UnitIsFriend
local UnitGUID = UnitGUID
local IsMouseButtonDown = IsMouseButtonDown
local GetCVar = GetCVar
local IsModifiedClick = IsModifiedClick
local GetTime = GetTime

local Tooltip = ns.Tooltip
local Data = ns.Data

local function HasTooltipRole(lines, category)
    local roleData = Data and Data["TOOLTIP_ROLE_KEYWORDS"]
    local categoryData = roleData and roleData[category]
    if not categoryData or not lines then
        return false
    end

    for _, line in ipairs(lines) do
        if categoryData.exact and categoryData.exact[line] then
            return true
        end

        if categoryData.contains then
            for _, keyword in ipairs(categoryData.contains) do
                if strfind(line, keyword, 1, true) then
                    return true
                end
            end
        end
    end

    return false
end

local function IsFlightMasterName(name)
    if not name or not Data then
        return false
    end

    local flightMasters = Data["FLIGHTMASTERS"] or Data["FLIGHTMASTER"]
    return flightMasters and flightMasters[name] or false
end

local function AddTooltipRoleCandidates(candidates, lines, name)
    if HasTooltipRole(lines, "FLIGHTMASTER") then
        table.insert(candidates, "FLIGHTMASTER")
    elseif IsFlightMasterName(name) then
        table.insert(candidates, "FLIGHTMASTER")
    end

    if HasTooltipRole(lines, "BATTLEMASTER") then
        table.insert(candidates, "BATTLEMASTER")
    end

    if HasTooltipRole(lines, "TRAINER") then
        table.insert(candidates, "TRAINER")
    end

    if HasTooltipRole(lines, "DIRECTIONS_GUARD") then
        table.insert(candidates, "DIRECTIONS_GUARD")
    end

    if HasTooltipRole(lines, "INNKEEPER") then
        table.insert(candidates, "INNKEEPER")
    end

    if HasTooltipRole(lines, "STABLEMASTER") then
        table.insert(candidates, "STABLEMASTER")
    end

    if HasTooltipRole(lines, "MAILBOX") then
        table.insert(candidates, "MAILBOX")
    end

    if HasTooltipRole(lines, "SKINNABLE") then
        table.insert(candidates, "SKINNABLE")
    end

    if HasTooltipRole(lines, "VENDOR") then
        table.insert(candidates, "VENDOR")
    end

    if HasTooltipRole(lines, "REPAIR_VENDOR") then
        table.insert(candidates, "REPAIR_VENDOR")
    end
end

-- ############################################################
-- TRIGGER LOOP
-- ############################################################

function CursorGlow:StartTriggerLoop()
    if self.triggerFrame then return end

    local f = CreateFrame("Frame")

    f:SetScript("OnUpdate", function()
        local visible, state = self:EvaluateTrigger()

        self:ApplyVisibility(visible)

        if visible and state then
            self:ApplyState(state)
        end
    end)

    self.triggerFrame = f
end

-- ############################################################
-- Resolver
-- ############################################################

function CursorGlow:ResolveState(candidates)
    local bestState = nil
    local bestPriority = -math.huge

    for _, state in ipairs(candidates) do
        local priority = ns.StatePriority[state] or 0

        if priority > bestPriority then
            bestPriority = priority
            bestState = state
        end
    end

    return bestState
end

-- ############################################################
-- TRIGGER LOGIC
-- ############################################################

function CursorGlow:EvaluateTrigger()
    if self.db.profile.testMode then
        return true, "DEFAULT"
    end

    if IsMouseButtonDown("RightButton")
        or IsMouseButtonDown("LeftButton") then
        return false
    end

    local candidates = {}

    local name = Tooltip and Tooltip:GetName()
    local lines = Tooltip and Tooltip:GetLines()

    if name then
        name = strtrim(name)
    end

    if name and Data then
        if Data["HERBALISM"] and Data["HERBALISM"][name] then
            table.insert(candidates, "HERBALISM")
        end

        if Data["MINING"] and Data["MINING"][name] then
            table.insert(candidates, "MINING")
        end
    end

    AddTooltipRoleCandidates(candidates, lines, name)

    if UnitExists("mouseover") and not UnitIsUnit("mouseover", "player") then
        local guid = UnitGUID("mouseover")

        if guid and UnitIsDeadOrGhost("mouseover") then
            self.lastMouseoverGUID = guid
        end

        if UnitIsDeadOrGhost("mouseover") then
            local timestamp = guid and self.lootedUnits[guid]

            if timestamp and (GetTime() - timestamp < 120) then
                table.insert(candidates, "DEFAULT")
            else
                if not UnitIsTapDenied("mouseover") then
                    local autoLoot = GetCVar("autoLootDefault") == "1"
                    local modifier = IsModifiedClick("AUTOLOOTTOGGLE")
                    local isAutoLoot = (autoLoot and not modifier) or (not autoLoot and modifier)

                    table.insert(candidates, isAutoLoot and "AUTOLOOT" or "LOOT")
                else
                    table.insert(candidates, "DEFAULT")
                end
            end
        end

        -- ATTACK (only if alive)
        if UnitExists("mouseover")
            and not UnitIsDeadOrGhost("mouseover")
            and UnitCanAttack("player", "mouseover") then
            
            table.insert(candidates, "ATTACK")
        end
    end

    local best = self:ResolveState(candidates)

    return true, best or "DEFAULT"
end

-- ############################################################
-- VISIBILITY
-- ############################################################

function CursorGlow:ApplyVisibility(state)
    if not self.db.profile.enabled then
        self.cursorGlow:Hide()
        return
    end

    if self.currentVisible == state then return end
    self.currentVisible = state

    if state then
        self.cursorGlow:Show()
    else
        self.cursorGlow:Hide()
    end
end
