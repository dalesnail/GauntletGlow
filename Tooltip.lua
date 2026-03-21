-- ############################################################
-- TOOLTIP MODULE
-- ############################################################

local ADDON_NAME, ns = ...

local Tooltip = {}

local GameTooltip = GameTooltip

-- ##################################################
-- INTERNAL HELPERS
-- ############################################################

local function GetTooltipLine(index)
    local text = _G["GameTooltipTextLeft" .. index]

    if text then
        local val = text:GetText()
        if val and val ~= "" then
            return strtrim(val)
        end
    end
end

-- ############################################################
-- GET TOOLTIP NAME
-- ############################################################

function Tooltip:GetName()
    return GetTooltipLine(1)
end

-- ############################################################
-- GET ADDITIONAL TOOLTIP LINES
-- ############################################################

function Tooltip:GetLine2()
    return GetTooltipLine(2)
end

function Tooltip:GetLine3()
    return GetTooltipLine(3)
end

-- ############################################################
-- EXPORT
-- ############################################################

ns.Tooltip = Tooltip
#####

ns.Tooltip = Tooltip