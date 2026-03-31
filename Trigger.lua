local ADDON_NAME, ns = ...
local GG = ns.GauntletGlow

-- ############################################################
-- LOCALS
-- ############################################################

local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitCanAttack = UnitCanAttack
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsTapDenied = UnitIsTapDenied
local CanLootUnit = CanLootUnit
local UnitGUID = UnitGUID
local UnitClass = UnitClass
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitAffectingCombat = UnitAffectingCombat
local IsMouseButtonDown = IsMouseButtonDown
local GetCVar = GetCVar
local IsModifiedClick = IsModifiedClick
local GetTime = GetTime
local GetProfessions = GetProfessions
local GetProfessionInfo = GetProfessionInfo
local GetNumSpellTabs = GetNumSpellTabs
local GetSpellBookItemName = GetSpellBookItemName
local GetSpellTabInfo = GetSpellTabInfo
local IsSpellKnown = IsSpellKnown
local IsMounted = IsMounted
local IsResting = IsResting
local CanMerchantRepair = CanMerchantRepair
local InRepairMode = InRepairMode
local strtrim = strtrim
local strsplit = strsplit
local tonumber = tonumber
local ipairs = ipairs
local type = type
local math = math
local table = table

local Tooltip = ns.Tooltip
local QuestieIntegration = ns.QuestieIntegration

local FIND_HERBS_SPELL_ID = 2383
local FIND_MINERALS_SPELL_ID = 2580
local BOOKTYPE_SPELL = BOOKTYPE_SPELL

-- ############################################################
-- GLiB Helpers
-- ############################################################

local function GetGLiB()
    return _G.GLiB
end

local function HasTooltipNpcTag(lines, tag)
    local glib = GetGLiB()
    if not glib or type(glib.TooltipNpcHasTag) ~= "function" then
        return false
    end

    return glib:TooltipNpcHasTag(lines, tag)
end

local function HasTooltipWorldTag(lines, tag)
    local glib = GetGLiB()
    if not glib or type(glib.TooltipWorldHasTag) ~= "function" then
        return false
    end

    return glib:TooltipWorldHasTag(lines, tag)
end

local function TooltipDisplaysUnit()
    if not GameTooltip or type(GameTooltip.GetUnit) ~= "function" then
        return false
    end

    local _, unit = GameTooltip:GetUnit()
    return unit ~= nil
end

local function GetNpcIdFromGUID(guid)
    if not guid then
        return nil
    end

    local unitType, _, _, _, _, npcId = strsplit("-", guid)
    if unitType ~= "Creature" and unitType ~= "Vehicle" then
        return nil
    end

    return tonumber(npcId)
end

local function GetMouseoverNpcId()
    if not UnitExists("mouseover") then
        return nil
    end

    return GetNpcIdFromGUID(UnitGUID("mouseover"))
end

local function GetGLiBNpcTypeById(npcId)
    local glib = GetGLiB()
    if not glib or type(glib.NpcTypeById) ~= "function" or not npcId then
        return nil
    end

    return glib:NpcTypeById(npcId)
end

local function GetGLiBObjType(name)
    local glib = GetGLiB()
    if not glib or type(glib.ObjType) ~= "function" then
        return nil
    end

    if not name or name == "" then
        return nil
    end

    return glib:ObjType(name)
end

local function GetLearnedNpcCache()
    if not GG or type(GG.NormalizeLearnedNpcCache) ~= "function" then
        return nil
    end

    return GG:NormalizeLearnedNpcCache()
end

local function IsLearnedNpcTag(npcId, tag)
    if type(npcId) ~= "number" or type(tag) ~= "string" or tag == "" then
        return false
    end

    local cache = GetLearnedNpcCache()
    local bucket = cache and cache[tag]
    return bucket and bucket[npcId] == true or false
end

local function IsShippedNpcTag(npcId, tag)
    local glib = GetGLiB()
    if not glib or type(glib.HasNpcTagById) ~= "function" then
        return false
    end

    return glib:HasNpcTagById(npcId, tag)
end

local function IsKnownRepairNpc(npcId)
    return IsShippedNpcTag(npcId, "repair_vendor") or IsLearnedNpcTag(npcId, "repair_vendor")
end

local function IsKnownVendorNpc(npcId)
    if IsKnownRepairNpc(npcId) then
        return true
    end

    return IsShippedNpcTag(npcId, "vendor") or IsLearnedNpcTag(npcId, "vendor")
end

local function GetMerchantNpcId()
    local guid =
        UnitGUID("npc")
        or UnitGUID("mouseover")
        or UnitGUID("target")
        or (GG and GG.lastMouseoverGUID)

    return GetNpcIdFromGUID(guid)
end

local function LearnMerchantNpc()
    local npcId = GetMerchantNpcId()
    if not npcId then
        return
    end

    local cache = GetLearnedNpcCache()
    if not cache then
        return
    end

    local canRepair = type(CanMerchantRepair) == "function" and CanMerchantRepair() or false

    if canRepair then
        if not IsShippedNpcTag(npcId, "repair_vendor") then
            cache.repair_vendor[npcId] = true
        end

        cache.vendor[npcId] = nil
        return
    end

    if not IsShippedNpcTag(npcId, "vendor") and not IsShippedNpcTag(npcId, "repair_vendor") then
        cache.vendor[npcId] = true
    end
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

local function PlayerHasProfession(professionName)
    local prof1, prof2 = GetProfessions()

    local function HasProfession(index)
        if not index then
            return false
        end

        local name = GetProfessionInfo(index)
        return name == professionName
    end

    return HasProfession(prof1) or HasProfession(prof2)
end

local function PlayerKnowsSpell(spellID, spellName)
    if type(IsSpellKnown) == "function" and type(spellID) == "number" and IsSpellKnown(spellID) then
        return true
    end

    if type(GetNumSpellTabs) ~= "function" or type(GetSpellTabInfo) ~= "function" or type(GetSpellBookItemName) ~= "function" then
        return false
    end

    for tabIndex = 1, GetNumSpellTabs() do
        local _, _, offset, numSlots = GetSpellTabInfo(tabIndex)
        if offset and numSlots then
            for slotIndex = offset + 1, offset + numSlots do
                local name = GetSpellBookItemName(slotIndex, BOOKTYPE_SPELL)
                if name == spellName then
                    return true
                end
            end
        end
    end

    return false
end

local function PlayerHasSkinning()
    return PlayerHasProfession("Skinning")
end

local function PlayerHasHerbalism()
    return PlayerKnowsSpell(FIND_HERBS_SPELL_ID, "Find Herbs")
end

local function PlayerHasMining()
    return PlayerKnowsSpell(FIND_MINERALS_SPELL_ID, "Find Minerals")
end

local function MerchantIsOpen()
    return MerchantFrame and MerchantFrame:IsShown()
end

local function MerchantBuybackTabIsSelected()
    if not MerchantIsOpen() then
        return false
    end

    if MerchantFrame and MerchantFrame.selectedTab ~= nil then
        return MerchantFrame.selectedTab == 2
    end

    if type(PanelTemplates_GetSelectedTab) == "function" then
        return PanelTemplates_GetSelectedTab(MerchantFrame) == 2
    end

    return false
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
    if not MerchantIsOpen() or MerchantBuybackTabIsSelected() then
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

local function IsRepairModeActive()
    return MerchantIsOpen()
        and not MerchantBuybackTabIsSelected()
        and type(InRepairMode) == "function"
        and InRepairMode()
        and true or false
end

local function GetMerchantItemIndexFromFrame(frame)
    while frame do
        local name = frame.GetName and frame:GetName()

        if name then
            local index = name:match("^MerchantItem(%d+)ItemButton$")
            if index then
                return tonumber(index)
            end

            index = name:match("^MerchantItem(%d+)$")
            if index then
                return tonumber(index)
            end
        end

        frame = frame.GetParent and frame:GetParent() or nil
    end

    return nil
end

local function MerchantItemIsPurchasable(index)
    if type(index) ~= "number" then
        return false
    end

    if type(GetMerchantItemInfo) == "function" then
        local _, _, price, _, _, isUsable, extendedCost = GetMerchantItemInfo(index)
        if price == nil and isUsable == nil and extendedCost == nil then
            return false
        end

        if price and price > 0 then
            return true
        end

        if extendedCost then
            return true
        end
    end

    if type(C_MerchantFrame) == "table" and type(C_MerchantFrame.GetItemInfo) == "function" then
        local info = C_MerchantFrame.GetItemInfo(index)
        if info and (info.price and info.price > 0 or info.hasExtendedCost) then
            return true
        end
    end

    return false
end

local function GetHoveredMerchantItemIndex()
    if not MerchantIsOpen() or MerchantBuybackTabIsSelected() then
        return nil
    end

    local hoveredFrame = GetHoveredFrame()
    if not hoveredFrame then
        return nil
    end

    local index = GetMerchantItemIndexFromFrame(hoveredFrame)
    if not index then
        return nil
    end

    if not MerchantItemIsPurchasable(index) then
        return nil
    end

    return index
end

local function CanLootMouseoverCorpse()
    local guid = UnitGUID("mouseover")
    if not guid or not CanLootUnit then
        return false
    end

    local hasLoot, canLoot = CanLootUnit(guid)
    return hasLoot and canLoot
end

local function IsRecentEligibleMouseoverCorpse()
    local guid = UnitGUID("mouseover")
    if not guid or not GG or type(GG.IsRecentCorpseGUID) ~= "function" then
        return false
    end

    return GG:IsRecentCorpseGUID(guid)
end

local function IsMouseoverCorpse()
    return UnitExists("mouseover") and UnitIsDeadOrGhost("mouseover")
end

local function HasProfessionCorpseTooltip(lines)
    return HasTooltipWorldTag(lines, "herbalism")
        or HasTooltipWorldTag(lines, "mining")
        or HasTooltipNpcTag(lines, "skinnable")
end

local function IsPostLootGatherable(lines)
    if not lines or not IsMouseoverCorpse() then
        return false
    end

    if not HasProfessionCorpseTooltip(lines) then
        return false
    end

    if CanLootMouseoverCorpse() then
        return false
    end

    return true
end

local function IsCorpseProfessionWorldTag(lines, tag)
    return IsPostLootGatherable(lines) and HasTooltipWorldTag(lines, tag)
end

local function IsHerbalismCorpse(lines)
    return IsCorpseProfessionWorldTag(lines, "herbalism") and PlayerHasHerbalism()
end

local function IsMiningCorpse(lines)
    return IsCorpseProfessionWorldTag(lines, "mining") and PlayerHasMining()
end

local function GetCorpseProfessionState(lines)
    if IsHerbalismCorpse(lines) then
        return "HERBALISM"
    end

    if IsMiningCorpse(lines) then
        return "MINING"
    end

    return nil
end

local function AddTooltipRoleCandidates(candidates, lines, name)
    local glib = GetGLiB()
    local npcId = GetMouseoverNpcId()
    local hasLiveNpc = npcId ~= nil

    local npcType = GetGLiBNpcTypeById(npcId)
    local objectType = nil

    if not npcType and name then
        objectType = GetGLiBObjType(name)
    end

    local glibType = npcType or objectType
    local glibInfo = npcId and glib and type(glib.NpcById) == "function" and glib:NpcById(npcId) or nil

    local knownRepair = npcId and IsKnownRepairNpc(npcId) or false
    local knownVendor = npcId and IsKnownVendorNpc(npcId) or false

    if knownRepair then
        table.insert(candidates, "REPAIR_VENDOR")
    elseif knownVendor then
        table.insert(candidates, "VENDOR")
    end

    if glibType == "flightmaster" then
        table.insert(candidates, "FLIGHTMASTER")
    end

    if glibType == "battlemaster" then
        table.insert(candidates, "BATTLEMASTER")
    end

    if glibType == "trainer" then
        if glibInfo and glibInfo.subtype == "class" then
            local _, playerClass = UnitClass("player")

            if glibInfo.class == playerClass then
                table.insert(candidates, "TRAINER")
            else
                table.insert(candidates, "SPEAK")
            end
        else
            table.insert(candidates, "TRAINER")
        end
    end

    if glibType == "directions_guard" then
        table.insert(candidates, "DIRECTIONS_GUARD")
    end

    if glibType == "innkeeper" then
        table.insert(candidates, "INNKEEPER")
    end

    if glibType == "stablemaster" then
        table.insert(candidates, "STABLEMASTER")
    end

    if glibType == "mailbox" then
        table.insert(candidates, "MAILBOX")
    end

    if glibType == "finance" then
        table.insert(candidates, "FINANCE")
    end

    if HasTooltipNpcTag(lines, "skinnable") and PlayerHasSkinning() then
        table.insert(candidates, "SKINNABLE")
    end

    if hasLiveNpc and not knownRepair and HasTooltipNpcTag(lines, "repair_vendor") then
        table.insert(candidates, "REPAIR_VENDOR")
    end

    if hasLiveNpc and not knownVendor and not knownRepair and HasTooltipNpcTag(lines, "vendor") then
        table.insert(candidates, "VENDOR")
    end
end

local function AddWorldTooltipCandidates(candidates, lines)
    if not IsMouseoverCorpse() and HasTooltipWorldTag(lines, "herbalism") then
        table.insert(candidates, "HERBALISM")
    end

    if not IsMouseoverCorpse() and HasTooltipWorldTag(lines, "mining") then
        table.insert(candidates, "MINING")
    end
end

local function GetLowHealthThreshold()
    local threshold = (ns.PlayerStateEffects and ns.PlayerStateEffects.lowHealthThreshold) or 0.35
    return math.max(0, math.min(1, threshold))
end

local function IsPlayerLowHealth()
    local maxHealth = UnitHealthMax and UnitHealthMax("player")
    if not maxHealth or maxHealth <= 0 then
        return false
    end

    local currentHealth = UnitHealth and UnitHealth("player")
    if not currentHealth then
        return false
    end

    return (currentHealth / maxHealth) <= GetLowHealthThreshold()
end

local function IsPlayerCombatState()
    return UnitAffectingCombat and UnitAffectingCombat("player") and true or false
end

local function IsPlayerMountedState()
    return IsMounted and IsMounted() and true or false
end

local function IsPlayerRestingState()
    return IsResting and IsResting() and true or false
end

local function GetPlayerStateEffectPriority(effectKey)
    local effectData = ns.PlayerStateEffects
    local priorityMap = effectData and effectData.priority
    return priorityMap and priorityMap[effectKey] or 0
end

local PLAYER_STATE_EFFECT_CHECKS = {
    LOW_HEALTH = IsPlayerLowHealth,
    COMBAT = IsPlayerCombatState,
    MOUNTED = IsPlayerMountedState,
    RESTING = IsPlayerRestingState,
}

-- ############################################################
-- TRIGGER LOOP
-- ############################################################

function GG:StartTriggerLoop()
    if self.triggerFrame then
        return
    end

    local f = CreateFrame("Frame")

    f:SetScript("OnUpdate", function()
        local visible, state = self:EvaluateTrigger()
        self:UpdatePlayerStateEffect()

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

function GG:ResolveState(candidates)
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

function GG:ResolvePlayerStateEffect()
    local effectData = ns.PlayerStateEffects
    local effectOrder = effectData and effectData.order
    if not effectOrder then
        return nil
    end

    local previewEffectKey = self.GetPlayerStateEffectPreviewKey and self:GetPlayerStateEffectPreviewKey()
    if previewEffectKey then
        return previewEffectKey
    end

    local bestEffect = nil
    local bestPriority = -math.huge

    for _, effectKey in ipairs(effectOrder) do
        local check = PLAYER_STATE_EFFECT_CHECKS[effectKey]
        if check and self:IsPlayerStateEffectEnabled(effectKey) and check() then
            local priority = GetPlayerStateEffectPriority(effectKey)
            if priority > bestPriority then
                bestPriority = priority
                bestEffect = effectKey
            end
        end
    end

    return bestEffect
end

function GG:SetPlayerStateEffect(effectKey)
    if self.currentPlayerStateEffectKey == effectKey then
        return
    end

    self.currentPlayerStateEffectKey = effectKey

    if self.RefreshPlayerStateEffectTarget then
        self:RefreshPlayerStateEffectTarget()
    end
end

function GG:SetQuestieObjectiveHoverActive(active)
    active = active and true or false
    if self.questieObjectiveHoverActive == active then
        return
    end

    self.questieObjectiveHoverActive = active

    if self.RefreshPlayerStateEffectTarget then
        self:RefreshPlayerStateEffectTarget()
    end
end

function GG:UpdatePlayerStateEffect()
    self:SetPlayerStateEffect(self:ResolvePlayerStateEffect())
end

-- ############################################################
-- TRIGGER LOGIC
-- ############################################################

function GG:EvaluateTrigger()
    if self.db.profile.testMode then
        self:SetQuestieObjectiveHoverActive(false)
        return true, "DEFAULT"
    end

    if IsMouseButtonDown("RightButton") or IsMouseButtonDown("LeftButton") then
        self:SetQuestieObjectiveHoverActive(false)
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

    local questieState = QuestieIntegration and QuestieIntegration.GetMouseoverNpcQuestState and QuestieIntegration.GetMouseoverNpcQuestState()
    if questieState then
        table.insert(candidates, questieState)
    end

    local questieObjectObjectiveActive = QuestieIntegration
        and QuestieIntegration.IsMouseoverActiveObjectObjective
        and QuestieIntegration.IsMouseoverActiveObjectObjective()
        or false
    if questieObjectObjectiveActive then
        table.insert(candidates, "COGWHEEL")
    end

    local questieObjectiveHoverActive = QuestieIntegration
        and QuestieIntegration.IsMouseoverHostileObjectiveEnemy
        and QuestieIntegration.IsMouseoverHostileObjectiveEnemy()
        or false
    self:SetQuestieObjectiveHoverActive(questieObjectiveHoverActive)

    if IsRepairModeActive() then
        table.insert(candidates, "REPAIR_HOVER")
    end

    if GetHoveredMerchantItemIndex() then
        table.insert(candidates, "LOOT")
    end

    if GetHoveredBagItem() then
        table.insert(candidates, "SELL_ITEM")
    end

    if UnitExists("mouseover") and not UnitIsUnit("mouseover", "player") then
        local guid = UnitGUID("mouseover")

        if guid then
            self.lastMouseoverGUID = guid
        end

        if UnitIsDeadOrGhost("mouseover") then
            local timestamp = guid and self.lootedUnits[guid]
            local wasRecentlyLooted = timestamp and (GetTime() - timestamp < 120)
            local corpseProfessionState = GetCorpseProfessionState(lines)
            local canLootCorpse = CanLootMouseoverCorpse()

            if canLootCorpse and not wasRecentlyLooted then
                local autoLoot = GetCVar("autoLootDefault") == "1"
                local modifier = IsModifiedClick("AUTOLOOTTOGGLE")
                local isAutoLoot = (autoLoot and not modifier) or (not autoLoot and modifier)

                table.insert(candidates, isAutoLoot and "AUTOLOOT" or "LOOT")
            elseif corpseProfessionState then
                table.insert(candidates, corpseProfessionState)
            else
                table.insert(candidates, "DEFAULT")
            end
        end

        if UnitExists("mouseover") and not UnitIsDeadOrGhost("mouseover") and UnitCanAttack("player", "mouseover") then
            table.insert(candidates, "ATTACK")
        end
    end

    local best = self:ResolveState(candidates)

    return true, best or "DEFAULT"
end

function GG:MERCHANT_SHOW()
    LearnMerchantNpc()
end

-- ############################################################
-- VISIBILITY
-- ############################################################

function GG:ApplyVisibility(state)
    if not self.db.profile.enabled then
        self.gauntletGlow:Hide()
        return
    end

    if self.currentVisible == state then
        return
    end

    self.currentVisible = state

    if state then
        self.gauntletGlow:Show()
    else
        self.gauntletGlow:Hide()
    end
end
