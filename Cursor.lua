local ADDON_NAME, ns = ...
local GG = ns.GauntletGlow

local GetCursorPosition = GetCursorPosition
local UIParent = UIParent
local min = math.min
local max = math.max

local function SetTextureDesaturation(texture, enabled)
    if not texture then
        return
    end

    if texture.SetDesaturated then
        texture:SetDesaturated(enabled and true or false)
    elseif texture.SetDesaturation then
        texture:SetDesaturation(enabled and 1 or 0)
    end
end

function GG:RefreshGlowAppearance()
    local glow = self.gauntletGlow
    local tex = glow and glow.texture
    local profile = self.db and self.db.profile
    if not tex or not profile then
        return
    end

    local colorR, colorG, colorB = 1, 1, 1
    local desaturate = false
    if profile.useCustomColor then
        colorR = profile.colorR or 1
        colorG = profile.colorG or 1
        colorB = profile.colorB or 1
        desaturate = profile.desaturateTexture and true or false
    end

    local brightness = profile.useBrightness and (profile.brightness or 1) or 1
    local alpha = profile.useGlobalAlpha and (profile.globalAlpha or 1) or 1

    colorR = min(1, max(0, colorR * brightness))
    colorG = min(1, max(0, colorG * brightness))
    colorB = min(1, max(0, colorB * brightness))
    alpha = min(1, max(0, alpha))

    tex:SetVertexColor(colorR, colorG, colorB)
    tex:SetAlpha(alpha)
    SetTextureDesaturation(tex, desaturate)
end

function GG:CreateGauntletGlow()
    local f = CreateFrame("Frame", "GauntletGlowFrame", UIParent)
    f:SetFrameStrata("TOOLTIP")

    local tex = f:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()
    tex:SetBlendMode("ADD")

    f.texture = tex
    f:Hide()

    self.gauntletGlow = f
    self:RefreshGlowAppearance()
end

function GG:ApplyState(stateName, force)
    if not force and self.currentStateName == stateName then return end
    self.currentStateName = stateName

    local state = self.States[stateName]
    if not state then return end

    self.gauntletGlow.texture:SetTexture(state.texture)
    self:RefreshGlowAppearance()

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

    elseif stateName == "STABLEMASTER" then
        sizeX = self.db.profile.stableMasterSizeX or sizeX
        sizeY = self.db.profile.stableMasterSizeY or sizeY
        offsetX = self.db.profile.stableMasterOffsetX or offsetX
        offsetY = self.db.profile.stableMasterOffsetY or offsetY

    elseif stateName == "MAILBOX" then
        sizeX = self.db.profile.mailboxSizeX or sizeX
        sizeY = self.db.profile.mailboxSizeY or sizeY
        offsetX = self.db.profile.mailboxOffsetX or offsetX
        offsetY = self.db.profile.mailboxOffsetY or offsetY

    elseif stateName == "BANKER" then
        sizeX = self.db.profile.bankerSizeX or sizeX
        sizeY = self.db.profile.bankerSizeY or sizeY
        offsetX = self.db.profile.bankerOffsetX or offsetX
        offsetY = self.db.profile.bankerOffsetY or offsetY

    elseif stateName == "SKINNABLE" then
        sizeX = self.db.profile.skinnableSizeX or sizeX
        sizeY = self.db.profile.skinnableSizeY or sizeY
        offsetX = self.db.profile.skinnableOffsetX or offsetX
        offsetY = self.db.profile.skinnableOffsetY or offsetY

    elseif stateName == "VENDOR" then
        sizeX = self.db.profile.vendorSizeX or sizeX
        sizeY = self.db.profile.vendorSizeY or sizeY
        offsetX = self.db.profile.vendorOffsetX or offsetX
        offsetY = self.db.profile.vendorOffsetY or offsetY

    elseif stateName == "REPAIR_VENDOR" then
        sizeX = self.db.profile.repairVendorSizeX or sizeX
        sizeY = self.db.profile.repairVendorSizeY or sizeY
        offsetX = self.db.profile.repairVendorOffsetX or offsetX
        offsetY = self.db.profile.repairVendorOffsetY or offsetY

    elseif stateName == "SELL_ITEM" then
        sizeX = self.db.profile.sellItemSizeX or sizeX
        sizeY = self.db.profile.sellItemSizeY or sizeY
        offsetX = self.db.profile.sellItemOffsetX or offsetX
        offsetY = self.db.profile.sellItemOffsetY or offsetY

    else
        sizeX = self.db.profile.sizeX or sizeX
        sizeY = self.db.profile.sizeY or sizeY
        offsetX = self.db.profile.offsetX or offsetX
        offsetY = self.db.profile.offsetY or offsetY
    end

    self.gauntletGlow:SetSize(sizeX, sizeY)
    self.currentOffsetX = offsetX
    self.currentOffsetY = offsetY
end

function GG:RefreshActiveState()
    if not self.currentStateName then return end
    self:ApplyState(self.currentStateName, true)
end

function GG:StartCursorMovement()
    if self.movementFrame then return end

    local f = CreateFrame("Frame")

    f:SetScript("OnUpdate", function()
        self:UpdateCursorPosition()
    end)

    self.movementFrame = f
end

function GG:UpdateCursorPosition()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()

    x = x / scale
    y = y / scale

    local offsetX = self.currentOffsetX or 0
    local offsetY = self.currentOffsetY or 0

    self.gauntletGlow:ClearAllPoints()
    self.gauntletGlow:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x + offsetX, y + offsetY)
end
