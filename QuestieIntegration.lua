local ADDON_NAME, ns = ...

local QuestieIntegration = ns.QuestieIntegration or {}
ns.QuestieIntegration = QuestieIntegration

local CreateFrame = CreateFrame
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
local C_QuestLog = C_QuestLog
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestLogTitle = GetQuestLogTitle
local pcall = pcall
local pairs = pairs
local ipairs = ipairs
local rawget = rawget
local strlower = strlower
local strsplit = strsplit
local tonumber = tonumber
local type = type

local questieState = {
    ready = false,
    readyCallbackRegistered = false,
    tooltipModule = nil,
    questDbModule = nil,
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

local function ResolveTooltipState(tooltipEntries)
    local hasQuestAvailable = false

    for _, tooltip in pairs(tooltipEntries) do
        if type(tooltip) == "table" and type(tooltip.questId) == "number" then
            if tooltip.type == "Finisher" then
                return "QUEST_TURN_IN"
            end

            if tooltip.type == "NPC" then
                hasQuestAvailable = true
            end
        end
    end

    if hasQuestAvailable then
        return "QUEST_AVAILABLE"
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

function QuestieIntegration.GetMouseoverNpcQuestState()
    if not RefreshQuestieReadyState() then
        return nil
    end

    local npcId = GetMouseoverNpcId()
    if not npcId then
        return nil
    end

    local tooltipModule = GetTooltipModule()
    local lookupByKey = tooltipModule and type(tooltipModule.lookupByKey) == "table" and tooltipModule.lookupByKey or nil
    local tooltipEntries = lookupByKey and lookupByKey["m_" .. npcId]

    if type(tooltipEntries) == "table" then
        local resolvedState = ResolveTooltipState(tooltipEntries)
        if resolvedState then
            return resolvedState
        end
    end

    if IsActiveQuestFinisherNpc(npcId) then
        return "QUEST_INCOMPLETE"
    end

    return nil
end
