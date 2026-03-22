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
local GetProfessions = GetProfessions
local GetProfessionInfo = GetProfessionInfo

local Tooltip = ns.Tooltip
local Data = ns.Data

local function HasTooltipKeywords(dataKey, lines, category)
    local keywordData = Data and Data[dataKey]
    local categoryData = keywordData and keywordData[category]
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

local function HasTooltipRole(lines, category)
    return HasTooltipKeywords("TOOLTIP_ROLE_KEYWORDS", lines, category)
end

local function HasWorldTooltipKeyword(lines, category)
    return HasTooltipKeywords("TOOLTIP_WORLD_KEYWORDS", lines, category)
end

local function IsFlightMasterName(name)
    if not name or not Data then
        return false
    end

    local flightMasters = Data["FLIGHTMASTERS"] or Data["FLIGHTMASTER"]
    return flightMasters and flightMasters[name] or false
end

local function NormalizeBagID(bag)
    if bag == -1 then
        return 0
    end

    return bag
end

-- #################################################
-- Profession Checks
-- #################################################

local function PlayerHasSkinning()
    local prof1, prof2 = GetProfessions()

    local function IsSkinning(index)
        if not index then return false end
        local name = GetProfessionInfo(index)
        return name == "Skinning"
    end

    return IsSkinning(prof1) or IsSkinning(prof2)
end

local function MerchantIsOpen()
    return MerchantFrame and MerchantFrame:IsShown()
end

local function GetHoveredFrame()
    if type(GetMouseFoci) ~= "function" then
        return nil
    end

    local foci = GetMouseFoci()
    if not foci then
        return nil
    end

    if type(foci) == "table" then
        return foci[1]
    end

    return foci
end

local function GetBagAndSlotFromDefaultButton(button)
    if not button then
        return nil
    end

    local name = button.GetName and button:GetName()
    local slot = button.GetID and button:GetID()

    if not name or not slot then
        return nil
    end

    local bag = name:match("^ContainerFrame(%d+)Item%d+$")
    if not bag then
        return nil
    end

    bag = tonumber(bag)
    if not bag then
        return nil
    end

    bag = bag - 1

    return bag, slot
end

local function GetBagAndSlotFromElvUIButton(button)
    if not button then
        return nil
    end

    local parent = button.GetParent and button:GetParent() or nil
    local bag = parent and parent.GetID and parent:GetID() or nil
    local slot = button.GetID and button:GetID() or nil

    if bag == nil or slot == nil then
        return nil
    end

    return bag, slot
end

local function GetBagAndSlotFromButton(button)
    local bag, slot = GetBagAndSlotFromElvUIButton(button)
    if bag ~= nil and slot ~= nil then
        return bag, slot
    end

    bag, slot = GetBagAndSlotFromDefaultButton(button)
    if bag ~= nil and slot ~= nil then
        return bag, slot
    end

    return nil
end

local function GetBlizzardOrElvUIBagItemFrame(frame)
    while frame do
        local name = frame.GetName and frame:GetName()

        if name then
            if name:match("^ContainerFrame%d+Item%d+$") then
                return frame
            end

            if name:match("^ElvUI_ContainerFrameBag%-?%d+Slot%d+$") then
                return frame
            end
        end

        frame = frame.GetParent and frame:GetParent() or nil
    end

    return nil
end

local function BagSlotHasItem(bag, slot)
    if type(GetContainerItemLink) == "function" then
        return GetContainerItemLink(bag, slot) ~= nil
    end

    if type(C_Container) == "table" and type(C_Container.GetContainerItemInfo) == "function" then
        local info = C_Container.GetContainerItemInfo(bag, slot)
        return info ~= nil
    end

    return false
end

local function GetHoveredBagItem()
    if not MerchantIsOpen() then
        return nil
    end

    local hoveredFrame = GetHoveredFrame()
    if not hoveredFrame then
        return nil
    end

    local button = GetBlizzardOrElvUIBagItemFrame(hoveredFrame)
    if not button then
        return nil
    end

    local bag, slot = GetBagAndSlotFromButton(button)
    if bag == nil or slot == nil then
        return nil
    end

    bag = NormalizeBagID(bag)

    if not BagSlotHasItem(bag, slot) then
        return nil
    end

    return bag, slot
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

    if HasTooltipRole(lines, "SKINNABLE") and PlayerHasSkinning() then
        table.insert(candidates, "SKINNABLE")
    end

    if HasTooltipRole(lines, "REPAIR_VENDOR") then
        table.insert(candidates, "REPAIR_VENDOR")
    end

    if HasTooltipRole(lines, "VENDOR") then
        table.insert(candidates, "VENDOR")
    end
end

local function AddWorldTooltipCandidates(candidates, lines)
    if HasWorldTooltipKeyword(lines, "HERBALISM") then
        table.insert(candidates, "HERBALISM")
    end

    if HasWorldTooltipKeyword(lines, "MINING") then
        table.insert(candidates, "MINING")
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

    AddWorldTooltipCandidates(candidates, lines)
    AddTooltipRoleCandidates(candidates, lines, name)

    if GetHoveredBagItem() then
        table.insert(candidates, "SELL_ITEM")
    end

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
