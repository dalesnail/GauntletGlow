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