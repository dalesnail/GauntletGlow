local ADDON_NAME, ns = ...
local CursorGlow = ns.CursorGlow

local GetCursorPosition = GetCursorPosition
local UIParent = UIParent

function CursorGlow:CreateCursorGlow()
    local f = CreateFrame("Frame", "CursorGlowFrame", UIParent)
    f:SetFrameStrata("TOOLTIP")

    local tex = f:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()
    tex:SetBlendMode("ADD")

    f.texture = tex
    f:Hide()

    self.cursorGlow = f
end

function CursorGlow:ApplyState(stateName, force)
    if not force and self.currentStateName == stateName then return end
    self.currentStateName = stateName

    local state = self.States[stateName]
    if not state then return end

    self.cursorGlow.texture:SetTexture(state.texture)

    local sizeX = state.sizeX
    local sizeY = state.sizeY
    local offsetX = state.offsetX
    local offsetY = state.offsetY

    if stateName == "ATTACK" then
        sizeX = self.db.profile.swordSizeX or sizeX
        sizeY = self.db.profile.swordSizeY or sizeY
        offsetX = self.db.profile.swordOffsetX or offsetX
        offsetY = self.db.profile.swordOffsetY or offsetY

    elseif stateName == "LOOT" then
        sizeX = self.db.profile.lootSizeX or sizeX
        sizeY = self.db.profile.lootSizeY or sizeY
        offsetX = self.db.profile.lootOffsetX or offsetX
        offsetY = self.db.profile.lootOffsetY or offsetY

    elseif stateName == "AUTOLOOT" then
        sizeX = self.db.profile.autoLootSizeX or sizeX
        sizeY = self.db.profile.autoLootSizeY or sizeY
        offsetX = self.db.profile.autoLootOffsetX or offsetX
        offsetY = self.db.profile.autoLootOffsetY or offsetY

    elseif stateName == "HERBALISM" then
        sizeX = self.db.profile.herbSizeX or sizeX
        sizeY = self.db.profile.herbSizeY or sizeY
        offsetX = self.db.profile.herbOffsetX or offsetX
        offsetY = self.db.profile.herbOffsetY or offsetY

    elseif stateName == "MINING" then
        sizeX = self.db.profile.miningSizeX or sizeX
        sizeY = self.db.profile.miningSizeY or sizeY
        offsetX = self.db.profile.miningOffsetX or offsetX
        offsetY = self.db.profile.miningOffsetY or offsetY

    elseif stateName == "FLIGHTMASTER" then
        sizeX = self.db.profile.flightMasterSizeX or sizeX
        sizeY = self.db.profile.flightMasterSizeY or sizeY
        offsetX = self.db.profile.flightMasterOffsetX or offsetX
        offsetY = self.db.profile.flightMasterOffsetY or offsetY

    elseif stateName == "BATTLEMASTER" then
        sizeX = self.db.profile.battlemasterSizeX or sizeX
        sizeY = self.db.profile.battlemasterSizeY or sizeY
        offsetX = self.db.profile.battlemasterOffsetX or offsetX
        offsetY = self.db.profile.battlemasterOffsetY or offsetY

    elseif stateName == "TRAINER" then
        sizeX = self.db.profile.trainerSizeX or sizeX
        sizeY = self.db.profile.trainerSizeY or sizeY
        offsetX = self.db.profile.trainerOffsetX or offsetX
        offsetY = self.db.profile.trainerOffsetY or offsetY

    elseif stateName == "DIRECTIONS_GUARD" then
        sizeX = self.db.profile.directionsGuardSizeX or sizeX
        sizeY = self.db.profile.directionsGuardSizeY or sizeY
        offsetX = self.db.profile.directionsGuardOffsetX or offsetX
        offsetY = self.db.profile.directionsGuardOffsetY or offsetY

    elseif stateName == "INNKEEPER" then
        sizeX = self.db.profile.innkeeperSizeX or sizeX
        sizeY = self.db.profile.innkeeperSizeY or sizeY
        offsetX = self.db.profile.innkeeperOffsetX or offsetX
        offsetY = self.db.profile.innkeeperOffsetY or offsetY

    else
        sizeX = self.db.profile.sizeX or sizeX
        sizeY = self.db.profile.sizeY or sizeY
        offsetX = self.db.profile.offsetX or offsetX
        offsetY = self.db.profile.offsetY or offsetY
    end

    self.cursorGlow:SetSize(sizeX, sizeY)
    self.currentOffsetX = offsetX
    self.currentOffsetY = offsetY
end

function CursorGlow:RefreshActiveState()
    if not self.currentStateName then return end
    self:ApplyState(self.currentStateName, true)
end

function CursorGlow:StartCursorMovement()
    if self.movementFrame then return end

    local f = CreateFrame("Frame")

    f:SetScript("OnUpdate", function()
        self:UpdateCursorPosition()
    end)

    self.movementFrame = f
end

function CursorGlow:UpdateCursorPosition()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()

    x = x / scale
    y = y / scale

    local offsetX = self.currentOffsetX or 0
    local offsetY = self.currentOffsetY or 0

    self.cursorGlow:ClearAllPoints()
    self.cursorGlow:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x + offsetX, y + offsetY)
end
