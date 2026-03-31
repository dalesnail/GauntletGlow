local ADDON_NAME, ns = ...

local QuestieIntegration = ns.QuestieIntegration or {}
ns.QuestieIntegration = QuestieIntegration

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitCanAttack = UnitCanAttack
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local IsInInstance = IsInInstance
local IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
local C_QuestLog = C_QuestLog
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestLogTitle = GetQuestLogTitle
local pcall = pcall
local pairs = pairs
local ipairs = ipairs
local next = next
local rawget = rawget
local strlower = strlower
local strsplit = strsplit
local strtrim = strtrim
local tonumber = tonumber
local type = type

local questieState = {
    ready = false,
    readyCallbackRegistered = false,
    tooltipModule = nil,
    questDbModule = nil,
    l10nModule = nil,
    playerModule = nil,
    activeFinisherNpcIds = {},
    activeFinisherNpcIdsDirty = true,
}

local NPC_FINISHER_ENTITY_TYPES = {
    creature = true,
    monster = true,
    npc = true,
    unit = true,
}

local function ResetQuestieState()
    questieState.ready = false
    questieState.readyCallbackRegistered = false
    questieState.tooltipModule = nil
    questieState.questDbModule = nil
    questieState.l10nModule = nil
    questieState.playerModule = nil
    questieState.activeFinisherNpcIds = {}
    questieState.activeFinisherNpcIdsDirty = true
end

local function IsQuestieLoaded()
    return type(IsAddOnLoaded) == "function" and IsAddOnLoaded("Questie") and true or false
end

local questieEventFrame = CreateFrame("Frame")
questieEventFrame:RegisterEvent("ADDON_LOADED")
questieEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
questieEventFrame:RegisterEvent("QUEST_ACCEPTED")
questieEventFrame:RegisterEvent("QUEST_LOG_UPDATE")
questieEventFrame:RegisterEvent("QUEST_REMOVED")
questieEventFrame:SetScript("OnEvent", function(_, eventName, ...)
    if eventName == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "Questie" then
            ResetQuestieState()
        end

        return
    end

    questieState.activeFinisherNpcIdsDirty = true
end)

local function RefreshQuestieReadyState()
    -- Gate all Questie reads on the documented public readiness API.
    if not IsQuestieLoaded() then
        ResetQuestieState()
        return false
    end

    local questie = _G.Questie
    local api = questie and questie.API

    if type(api) == "table" and api.isReady == true then
        questieState.ready = true
        return true
    end

    questieState.ready = false

    if type(api) == "table" and (not questieState.readyCallbackRegistered) and type(api.RegisterOnReady) == "function" then
        local ok = pcall(api.RegisterOnReady, function()
            questieState.ready = true
            questieState.tooltipModule = nil
            questieState.questDbModule = nil
            questieState.l10nModule = nil
            questieState.playerModule = nil
            questieState.activeFinisherNpcIdsDirty = true
        end)

        if ok then
            questieState.readyCallbackRegistered = true
        end
    end

    return false
end

local function GetTooltipModule()
    -- Questie does not currently expose a public NPC quest-state lookup, so we
    -- isolate the internal tooltip-module fallback here after readiness is confirmed.
    if type(questieState.tooltipModule) == "table" then
        return questieState.tooltipModule
    end

    local loader = _G.QuestieLoader
    if type(loader) ~= "table" then
        return nil
    end

    local modules = rawget(loader, "_modules")
    local module = type(modules) == "table" and modules.QuestieTooltips or nil
    if type(module) == "table" then
        questieState.tooltipModule = module
        return module
    end

    if type(loader.ImportModule) ~= "function" then
        return nil
    end

    local ok, loadedModule = pcall(function()
        return loader:ImportModule("QuestieTooltips")
    end)

    if ok and type(loadedModule) == "table" then
        questieState.tooltipModule = loadedModule
        return loadedModule
    end

    return nil
end

local function GetQuestDbModule()
    if type(questieState.questDbModule) == "table" then
        return questieState.questDbModule
    end

    local questDb = _G.QuestieDB
    if type(questDb) == "table" then
        questieState.questDbModule = questDb
        return questDb
    end

    local loader = _G.QuestieLoader
    if type(loader) ~= "table" then
        return nil
    end

    local modules = rawget(loader, "_modules")
    local module = type(modules) == "table" and modules.QuestieDB or nil
    if type(module) == "table" then
        questieState.questDbModule = module
        return module
    end

    if type(loader.ImportModule) ~= "function" then
        return nil
    end

    local ok, loadedModule = pcall(function()
        return loader:ImportModule("QuestieDB")
    end)

    if ok and type(loadedModule) == "table" then
        questieState.questDbModule = loadedModule
        return loadedModule
    end

    return nil
end

local function GetL10nModule()
    if type(questieState.l10nModule) == "table" then
        return questieState.l10nModule
    end

    local loader = _G.QuestieLoader
    if type(loader) ~= "table" then
        return nil
    end

    local modules = rawget(loader, "_modules")
    local module = type(modules) == "table" and modules.l10n or nil
    if type(module) == "table" then
        questieState.l10nModule = module
        return module
    end

    if type(loader.ImportModule) ~= "function" then
        return nil
    end

    local ok, loadedModule = pcall(function()
        return loader:ImportModule("l10n")
    end)

    if ok and type(loadedModule) == "table" then
        questieState.l10nModule = loadedModule
        return loadedModule
    end

    return nil
end

local function GetPlayerModule()
    if type(questieState.playerModule) == "table" then
        return questieState.playerModule
    end

    local loader = _G.QuestieLoader
    if type(loader) ~= "table" then
        return nil
    end

    local modules = rawget(loader, "_modules")
    local module = type(modules) == "table" and modules.QuestiePlayer or nil
    if type(module) == "table" then
        questieState.playerModule = module
        return module
    end

    if type(loader.ImportModule) ~= "function" then
        return nil
    end

    local ok, loadedModule = pcall(function()
        return loader:ImportModule("QuestiePlayer")
    end)

    if ok and type(loadedModule) == "table" then
        questieState.playerModule = loadedModule
        return loadedModule
    end

    return nil
end

local function GetMouseoverNpcId()
    if not UnitExists("mouseover") then
        return nil
    end

    local guid = UnitGUID("mouseover")
    if not guid then
        return nil
    end

    local unitType, _, _, _, _, npcId = strsplit("-", guid)
    if unitType ~= "Creature" and unitType ~= "Vehicle" then
        return nil
    end

    return tonumber(npcId)
end

local function GetTooltipLine(index)
    if not index or index < 1 then
        return nil
    end

    local text = _G["GameTooltipTextLeft" .. index]
    if not text then
        return nil
    end

    local value = text:GetText()
    if type(value) ~= "string" then
        return nil
    end

    value = strtrim(value)
    if value == "" then
        return nil
    end

    return value
end

local function GetMouseoverNpcTooltipEntries()
    local npcId = GetMouseoverNpcId()
    if not npcId then
        return nil, nil, nil
    end

    local guid = UnitGUID("mouseover")
    local tooltipModule = GetTooltipModule()
    local lookupByKey = tooltipModule and type(tooltipModule.lookupByKey) == "table" and tooltipModule.lookupByKey or nil
    local tooltipEntries = lookupByKey and lookupByKey["m_" .. npcId]

    return npcId, guid, tooltipEntries
end

local function GetCurrentZoneId()
    local playerModule = GetPlayerModule()
    if type(playerModule) ~= "table" or type(playerModule.GetCurrentZoneId) ~= "function" then
        return nil
    end

    local ok, zoneId = pcall(function()
        return playerModule:GetCurrentZoneId()
    end)

    if ok and type(zoneId) == "number" then
        return zoneId
    end

    return nil
end

local function GetPublicObjectiveIconHint(guid)
    local questie = _G.Questie
    local api = questie and questie.API
    local getter = api and api.GetQuestObjectiveIconForUnit

    if type(guid) ~= "string" or type(getter) ~= "function" then
        return false, false
    end

    local ok, icon = pcall(function()
        return api:GetQuestObjectiveIconForUnit(guid)
    end)
    if not ok then
        return false, false
    end

    return type(icon) == "string" and icon ~= "", true
end

local function IsHostileMouseoverUnit()
    return UnitExists("mouseover")
        and not UnitIsDeadOrGhost("mouseover")
        and UnitCanAttack("player", "mouseover")
        and true or false
end

local function IsActiveObjectObjectiveTooltip(tooltip)
    if type(tooltip) ~= "table" or type(tooltip.questId) ~= "number" or tooltip.name then
        return false
    end

    local objective = tooltip.objective
    if type(objective) ~= "table" or type(objective.Update) ~= "function" then
        return false
    end

    local ok = pcall(function()
        objective:Update()
    end)
    if not ok or objective.Completed then
        return false
    end

    local questie = _G.Questie
    if type(questie) ~= "table" then
        return false
    end

    local iconType = objective.Icon
    return iconType == questie.ICON_TYPE_OBJECT
        or iconType == questie.ICON_TYPE_INTERACT
end

local function IsIncompleteQuestNpcObjective(tooltip, shouldUsePublicHint, hasPublicObjectiveIcon)
    if type(tooltip) ~= "table" or type(tooltip.questId) ~= "number" then
        return false
    end

    local objective = tooltip.objective
    if type(objective) ~= "table" or type(objective.Update) ~= "function" then
        return false
    end

    local ok = pcall(function()
        objective:Update()
    end)
    if not ok or objective.Completed then
        return false
    end

    local questie = _G.Questie
    if type(questie) ~= "table" then
        return false
    end

    local iconType = objective.Icon
    if iconType == questie.ICON_TYPE_INCOMPLETE then
        return true
    end

    if shouldUsePublicHint and not hasPublicObjectiveIcon then
        return false
    end

    return iconType == questie.ICON_TYPE_TALK
        or iconType == questie.ICON_TYPE_INTERACT
end

local function IsHostileObjectiveEnemyTooltip(tooltip, shouldUsePublicHint, hasPublicObjectiveIcon)
    if type(tooltip) ~= "table" or type(tooltip.questId) ~= "number" then
        return false
    end

    if tooltip.type == "NPC" or tooltip.type == "Finisher" then
        return false
    end

    local objective = tooltip.objective
    if type(objective) ~= "table" or type(objective.Update) ~= "function" then
        return false
    end

    local ok = pcall(function()
        objective:Update()
    end)
    if not ok or objective.Completed then
        return false
    end

    local questie = _G.Questie
    if type(questie) ~= "table" then
        return false
    end

    local iconType = objective.Icon
    if iconType == questie.ICON_TYPE_TALK
        or iconType == questie.ICON_TYPE_INTERACT
        or iconType == questie.ICON_TYPE_INCOMPLETE then
        return false
    end

    if shouldUsePublicHint and not hasPublicObjectiveIcon then
        return false
    end

    return hasPublicObjectiveIcon
        or iconType ~= nil
end

local function ResolveTooltipState(tooltipEntries, shouldUsePublicHint, hasPublicObjectiveIcon)
    local hasQuestAvailable = false
    local hasQuestIncomplete = false

    for _, tooltip in pairs(tooltipEntries) do
        if type(tooltip) == "table" and type(tooltip.questId) == "number" then
            if tooltip.type == "Finisher" then
                return "QUEST_TURN_IN"
            end

            if tooltip.type == "NPC" then
                hasQuestAvailable = true
            end

            if not hasQuestAvailable and IsIncompleteQuestNpcObjective(tooltip, shouldUsePublicHint, hasPublicObjectiveIcon) then
                hasQuestIncomplete = true
            end
        end
    end

    if hasQuestAvailable then
        return "QUEST_AVAILABLE"
    end

    if hasQuestIncomplete then
        return "QUEST_INCOMPLETE"
    end

    return nil
end

local function NormalizeEntityType(value)
    if type(value) ~= "string" then
        return nil
    end

    return strlower(value)
end

local function AddNpcIdsFromValue(value, result)
    if type(value) == "number" then
        result[value] = true
        return
    end

    if type(value) ~= "table" then
        return
    end

    for _, entry in pairs(value) do
        if type(entry) == "number" then
            result[entry] = true
        end
    end
end

local function CollectNpcIdsFromFinisherData(data, result)
    if type(data) ~= "table" then
        return
    end

    -- Questie's raw finishedBy payload stores NPC finisher ids in slot 1.
    AddNpcIdsFromValue(data[1], result)
    AddNpcIdsFromValue(data.NPC, result)
    AddNpcIdsFromValue(data.npc, result)

    local entityType = NormalizeEntityType(data.Type or data.type or data.entityType or data.entity_type or data[1])
    if entityType and NPC_FINISHER_ENTITY_TYPES[entityType] then
        AddNpcIdsFromValue(data.Id or data.id or data[2], result)
    end

    AddNpcIdsFromValue(data.npcId, result)
    AddNpcIdsFromValue(data.npcID, result)
    AddNpcIdsFromValue(data.NpcId, result)
    AddNpcIdsFromValue(data.NpcID, result)
    AddNpcIdsFromValue(data.npcIds, result)
    AddNpcIdsFromValue(data.npcIDs, result)
    AddNpcIdsFromValue(data.NpcIds, result)
    AddNpcIdsFromValue(data.NpcIDs, result)
    AddNpcIdsFromValue(data.npc, result)
    AddNpcIdsFromValue(data.npcs, result)
    AddNpcIdsFromValue(data.NPC, result)
    AddNpcIdsFromValue(data.NPCs, result)
    AddNpcIdsFromValue(data.monster, result)
    AddNpcIdsFromValue(data.monsters, result)
    AddNpcIdsFromValue(data.creature, result)
    AddNpcIdsFromValue(data.creatures, result)
    AddNpcIdsFromValue(data.unit, result)
    AddNpcIdsFromValue(data.units, result)

    for _, entry in pairs(data) do
        if type(entry) == "table" then
            local childType = NormalizeEntityType(entry.Type or entry.type or entry.entityType or entry.entity_type or entry[1])
            if childType and NPC_FINISHER_ENTITY_TYPES[childType] then
                AddNpcIdsFromValue(entry.Id or entry.id or entry[2], result)
            end
        end
    end
end

local function GetQuestFinisherNpcIds(questId)
    local finisherNpcIds = {}
    local questDb = GetQuestDbModule()
    if type(questDb) ~= "table" then
        return nil
    end

    if type(questDb.QueryQuestSingle) == "function" then
        local ok, finishedBy = pcall(questDb.QueryQuestSingle, questId, "finishedBy")
        if ok then
            CollectNpcIdsFromFinisherData(finishedBy, finisherNpcIds)
        end
    end

    if next(finisherNpcIds) == nil and type(questDb.GetQuest) == "function" then
        local ok, quest = pcall(questDb.GetQuest, questId)
        if ok and type(quest) == "table" then
            CollectNpcIdsFromFinisherData(quest.finishedBy, finisherNpcIds)
            CollectNpcIdsFromFinisherData(quest.Finisher, finisherNpcIds)
        end
    end

    if next(finisherNpcIds) == nil then
        return nil
    end

    return finisherNpcIds
end

local function GetActiveQuestIds()
    local questIds = {}

    if type(C_QuestLog) == "table" and type(C_QuestLog.GetNumQuestLogEntries) == "function" and type(C_QuestLog.GetInfo) == "function" then
        local numEntries = C_QuestLog.GetNumQuestLogEntries() or 0
        for index = 1, numEntries do
            local info = C_QuestLog.GetInfo(index)
            local questId = info and info.questID or nil
            if questId and not info.isHeader then
                questIds[#questIds + 1] = questId
            end
        end

        return questIds
    end

    if type(GetNumQuestLogEntries) ~= "function" or type(GetQuestLogTitle) ~= "function" then
        return questIds
    end

    local numEntries = GetNumQuestLogEntries() or 0
    for index = 1, numEntries do
        local _, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(index)
        if questId and not isHeader then
            questIds[#questIds + 1] = questId
        end
    end

    return questIds
end

local function RebuildActiveFinisherNpcIds()
    local activeFinisherNpcIds = {}

    for _, questId in ipairs(GetActiveQuestIds()) do
        local finisherNpcIds = GetQuestFinisherNpcIds(questId)
        if finisherNpcIds then
            for npcId in pairs(finisherNpcIds) do
                activeFinisherNpcIds[npcId] = true
            end
        end
    end

    questieState.activeFinisherNpcIds = activeFinisherNpcIds
    questieState.activeFinisherNpcIdsDirty = false
end

local function IsActiveQuestFinisherNpc(npcId)
    if type(npcId) ~= "number" then
        return false
    end

    if questieState.activeFinisherNpcIdsDirty then
        RebuildActiveFinisherNpcIds()
    end

    return questieState.activeFinisherNpcIds[npcId] == true
end

local function IsObjectInCurrentZone(objectId, playerZone)
    if type(objectId) ~= "number" or (type(IsInInstance) == "function" and IsInInstance()) then
        return true
    end

    if playerZone == nil or playerZone == 0 then
        return true
    end

    local questDb = GetQuestDbModule()
    if type(questDb) ~= "table" or type(questDb.QueryObjectSingle) ~= "function" then
        return true
    end

    local ok, spawns = pcall(questDb.QueryObjectSingle, objectId, "spawns")
    if not ok or type(spawns) ~= "table" or next(spawns) == nil then
        return true
    end

    return spawns[playerZone] ~= nil
end

local function HasMouseoverActiveObjectObjective()
    if UnitExists("mouseover") or not GameTooltip or not GameTooltip:IsShown() then
        return false
    end

    local name = GetTooltipLine(1)
    if not name then
        return false
    end

    local l10nModule = GetL10nModule()
    local objectNameLookup = l10nModule and type(l10nModule.objectNameLookup) == "table" and l10nModule.objectNameLookup or nil
    local objectIds = objectNameLookup and objectNameLookup[name] or nil
    if type(objectIds) ~= "table" then
        return false
    end

    local tooltipModule = GetTooltipModule()
    local lookupByKey = tooltipModule and type(tooltipModule.lookupByKey) == "table" and tooltipModule.lookupByKey or nil
    if not lookupByKey then
        return false
    end

    local playerZone = GetCurrentZoneId()

    for _, objectId in pairs(objectIds) do
        if type(objectId) == "number" and IsObjectInCurrentZone(objectId, playerZone) then
            local tooltipEntries = lookupByKey["o_" .. objectId]
            if type(tooltipEntries) == "table" then
                for _, tooltip in pairs(tooltipEntries) do
                    if IsActiveObjectObjectiveTooltip(tooltip) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function QuestieIntegration.GetMouseoverNpcQuestState()
    if not RefreshQuestieReadyState() then
        return nil
    end

    local npcId, guid, tooltipEntries = GetMouseoverNpcTooltipEntries()
    if not npcId then
        return nil
    end

    local hasPublicObjectiveIcon, shouldUsePublicHint = GetPublicObjectiveIconHint(guid)

    if type(tooltipEntries) == "table" then
        local resolvedState = ResolveTooltipState(tooltipEntries, shouldUsePublicHint, hasPublicObjectiveIcon)
        if resolvedState then
            return resolvedState
        end
    end

    if IsActiveQuestFinisherNpc(npcId) then
        return "QUEST_INCOMPLETE"
    end

    return nil
end

function QuestieIntegration.IsMouseoverHostileObjectiveEnemy()
    if not RefreshQuestieReadyState() or not IsHostileMouseoverUnit() then
        return false
    end

    local _, guid, tooltipEntries = GetMouseoverNpcTooltipEntries()
    if type(tooltipEntries) ~= "table" then
        return false
    end

    local hasPublicObjectiveIcon, shouldUsePublicHint = GetPublicObjectiveIconHint(guid)

    for _, tooltip in pairs(tooltipEntries) do
        if IsHostileObjectiveEnemyTooltip(tooltip, shouldUsePublicHint, hasPublicObjectiveIcon) then
            return true
        end
    end

    return false
end

function QuestieIntegration.IsMouseoverActiveObjectObjective()
    if not RefreshQuestieReadyState() then
        return false
    end

    return HasMouseoverActiveObjectObjective()
end
