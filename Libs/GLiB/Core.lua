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
local ipairs = ipairs
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

    for _, line in ipairs(lines) do
        if type(line) == "string" and line ~= "" then
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