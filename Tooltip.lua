-- ############################################################
-- TOOLTIP MODULE
-- ############################################################

local ADDON_NAME, ns = ...

local Tooltip = {}

local GameTooltip = GameTooltip
local wipe = wipe

local tooltipLinesBuffer = {}

-- ############################################################
-- INTERNAL HELPERS
-- ############################################################

local function GetTooltipLine(index)
    if not index or index < 1 then
        return nil
    end

    local text = _G["GameTooltipTextLeft" .. index]
    if not text then
        return nil
    end

    local value = text:GetText()
    if not value or value == "" then
        return nil
    end

    value = strtrim(value)
    if value == "" then
        return nil
    end

    return value
end

local function CollectTooltipLines()
    wipe(tooltipLinesBuffer)

    local numLines = GameTooltip and GameTooltip:NumLines() or 0
    if numLines <= 0 then
        return tooltipLinesBuffer
    end

    for index = 1, numLines do
        local line = GetTooltipLine(index)
        if line then
            tooltipLinesBuffer[#tooltipLinesBuffer + 1] = line
        end
    end

    return tooltipLinesBuffer
end

-- ############################################################
-- PUBLIC API
-- ############################################################

function Tooltip:GetName()
    return GetTooltipLine(1)
end

function Tooltip:GetLine2()
    return GetTooltipLine(2)
end

function Tooltip:GetLine3()
    return GetTooltipLine(3)
end

function Tooltip:GetLines()
    return CollectTooltipLines()
end

-- ############################################################
-- EXPORT
-- ############################################################

ns.Tooltip = Tooltip