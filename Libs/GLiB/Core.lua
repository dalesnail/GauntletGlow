local ADDON_NAME = ...
local GLiB = _G.GLiB or {}

_G.GLiB = GLiB

GLiB.name = "GLiB"
GLiB.addon = ADDON_NAME
GLiB.version = "0.1.0"

local P = GLiB._p or {}
GLiB._p = P

local strtrim = strtrim
local lower = string.lower
local strfind = string.find
local gsub = string.gsub
local ipairs = ipairs
local pairs = pairs
local type = type

local function norm(value)
    if type(value) ~= "string" then
        return nil
    end

    value = strtrim(value)
    if value == "" then
        return nil
    end

    return lower(value)
end

P.norm = norm

local function tooltipNorm(value)
    if type(value) ~= "string" then
        return nil
    end

    value = gsub(value, "|c%x%x%x%x%x%x%x%x", "")
    value = gsub(value, "|r", "")
    value = gsub(value, "|T.-|t", " ")
    value = gsub(value, "%s+", " ")

    return norm(value)
end

local function GetNormalizedTooltipCategory(categoryData)
    if not categoryData then
        return nil
    end

    local normalized = rawget(categoryData, "__normalized")
    if normalized then
        return normalized
    end

    normalized = {
        exact = {},
        contains = {},
    }

    if type(categoryData.exact) == "table" then
        for keyword in pairs(categoryData.exact) do
            local normalizedKeyword = tooltipNorm(keyword)
            if normalizedKeyword then
                normalized.exact[normalizedKeyword] = true
            end
        end
    end

    if type(categoryData.contains) == "table" then
        for _, keyword in ipairs(categoryData.contains) do
            local normalizedKeyword = tooltipNorm(keyword)
            if normalizedKeyword then
                normalized.contains[#normalized.contains + 1] = normalizedKeyword
            end
        end
    end

    categoryData.__normalized = normalized
    return normalized
end

function GLiB:Ver()
    return self.version
end

function GLiB:Ready()
    return true
end

--[[ Objects ]]

function GLiB:Obj(name)
    local keyMap = P.objNameToKey
    local dataMap = P.objData
    if not keyMap or not dataMap then
        return nil
    end

    local n = norm(name)
    if not n then
        return nil
    end

    local key = keyMap[n]
    if not key then
        return nil
    end

    return dataMap[key]
end

function GLiB:ObjType(name)
    local info = self:Obj(name)
    return info and info.type or nil
end

function GLiB:HasObjTag(name, tag)
    if type(tag) ~= "string" or tag == "" then
        return false
    end

    local info = self:Obj(name)
    if not info or not info.tags then
        return false
    end

    return info.tags[tag] == true
end

--[[ NPCs ]]

function GLiB:NpcById(npcId)
    if type(npcId) ~= "number" then
        return nil
    end

    local dataMap = P.npcData
    if not dataMap then
        return nil
    end

    return dataMap[npcId]
end

function GLiB:NpcTypeById(npcId)
    local info = self:NpcById(npcId)
    return info and info.type or nil
end

function GLiB:HasNpcTagById(npcId, tag)
    if type(tag) ~= "string" or tag == "" then
        return false
    end

    local info = self:NpcById(npcId)
    if not info or not info.tags then
        return false
    end

    return info.tags[tag] == true
end

--[[ Tooltip fallback data ]]--
local function tooltipLinesMatch(lines, categoryData)
    if type(lines) ~= "table" or not categoryData then
        return false
    end

    local normalizedCategory = GetNormalizedTooltipCategory(categoryData)
    if not normalizedCategory then
        return false
    end

    for _, line in ipairs(lines) do
        local normalizedLine = tooltipNorm(line)
        if normalizedLine then
            if normalizedCategory.exact and normalizedCategory.exact[normalizedLine] then
                return true
            end

            if normalizedCategory.contains then
                for _, keyword in ipairs(normalizedCategory.contains) do
                    if strfind(normalizedLine, keyword, 1, true) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function GLiB:TooltipNpcHasTag(lines, tag)
    if type(tag) ~= "string" or tag == "" then
        return false
    end

    local dataMap = P.tooltipNpcTags
    if not dataMap then
        return false
    end

    return tooltipLinesMatch(lines, dataMap[tag])
end

function GLiB:TooltipWorldHasTag(lines, tag)
    if type(tag) ~= "string" or tag == "" then
        return false
    end

    local dataMap = P.tooltipWorldTags
    if not dataMap then
        return false
    end

    return tooltipLinesMatch(lines, dataMap[tag])
end
