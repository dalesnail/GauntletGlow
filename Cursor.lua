local ADDON_NAME, ns = ...
local GG = ns.GauntletGlow

local GetCursorPosition = GetCursorPosition
local GetTime = GetTime
local UIParent = UIParent
local min = math.min
local max = math.max
local abs = math.abs
local cos = math.cos
local exp = math.exp
local pi = math.pi

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

local function Clamp(value, lower, upper)
    return min(upper, max(lower, value or 0))
end

local function MixColor(fromR, fromG, fromB, toR, toG, toB, amount)
    return fromR + ((toR - fromR) * amount),
        fromG + ((toG - fromG) * amount),
        fromB + ((toB - fromB) * amount)
end

local function GetBreathingPulse(speed)
    local clampedSpeed = Clamp(speed or 1, 0.45, 1.35)
    local wave = 0.5 - (0.5 * cos(GetTime() * (clampedSpeed * pi * 2)))

    return wave * wave * (3 - (2 * wave))
end

local function SmoothValue(currentValue, targetValue, speed, elapsed)
    if currentValue == nil then
        return targetValue
    end

    if elapsed <= 0 then
        return currentValue
    end

    if abs(targetValue - currentValue) < 0.0005 then
        return targetValue
    end

    local smoothing = 1 - exp(-max(speed or 0, 0.01) * elapsed)
    return currentValue + ((targetValue - currentValue) * smoothing)
end

local function GetTransitionResponseSpeed(transitionSpeed)
    local speed = Clamp(transitionSpeed or 4, 1, 12)
    return 0.9 + (speed * 0.6)
end

local function EnsureEffectAnimationState(self)
    if self.glowEffectState then
        return self.glowEffectState
    end

    local neutral = (ns.PlayerStateEffects and ns.PlayerStateEffects.neutral) or {}
    self.glowEffectState = {
        current = {
            colorR = neutral.colorR or 1,
            colorG = neutral.colorG or 1,
            colorB = neutral.colorB or 1,
            tintStrength = neutral.tintStrength or 0,
            brightness = neutral.brightness or 1,
            alpha = neutral.alpha or 1,
            desaturate = neutral.desaturate and true or false,
            pulseSpeed = neutral.pulseSpeed or 1.5,
            pulseStrength = neutral.pulseStrength or 0,
        },
        target = {
            colorR = neutral.colorR or 1,
            colorG = neutral.colorG or 1,
            colorB = neutral.colorB or 1,
            tintStrength = neutral.tintStrength or 0,
            brightness = neutral.brightness or 1,
            alpha = neutral.alpha or 1,
            desaturate = neutral.desaturate and true or false,
            pulseSpeed = neutral.pulseSpeed or 1.5,
            pulseStrength = neutral.pulseStrength or 0,
            transitionSpeed = neutral.transitionSpeed or 4,
        },
    }

    return self.glowEffectState
end

local function GetBaseAppearance(self)
    local profile = self.db and self.db.profile
    if not profile then
        return 1, 1, 1, 1, false
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

    colorR = Clamp(colorR * brightness, 0, 1)
    colorG = Clamp(colorG * brightness, 0, 1)
    colorB = Clamp(colorB * brightness, 0, 1)
    alpha = Clamp(alpha, 0, 1)

    return colorR, colorG, colorB, alpha, desaturate
end

local function GetNeutralEffectValues()
    local neutral = (ns.PlayerStateEffects and ns.PlayerStateEffects.neutral) or {}
    return {
        colorR = neutral.colorR or 1,
        colorG = neutral.colorG or 1,
        colorB = neutral.colorB or 1,
        tintStrength = neutral.tintStrength or 0,
        brightness = neutral.brightness or 1,
        alpha = neutral.alpha or 1,
        desaturate = neutral.desaturate and true or false,
        pulseSpeed = neutral.pulseSpeed or 1.5,
        pulseStrength = neutral.pulseStrength or 0,
        transitionSpeed = neutral.transitionSpeed or 4,
    }
end

local function GetTargetEffectValues(self, effectKey)
    local values = GetNeutralEffectValues()
    local previewActive = self.IsPlayerStateEffectPreviewActive and self:IsPlayerStateEffectPreviewActive(effectKey)
    if not effectKey or (not previewActive and not self:IsPlayerStateEffectEnabled(effectKey)) then
        return values
    end

    values.colorR = self:GetPlayerStateEffectValue(effectKey, "colorR") or values.colorR
    values.colorG = self:GetPlayerStateEffectValue(effectKey, "colorG") or values.colorG
    values.colorB = self:GetPlayerStateEffectValue(effectKey, "colorB") or values.colorB
    values.tintStrength = self:GetPlayerStateEffectValue(effectKey, "tintStrength") or values.tintStrength
    values.brightness = self:GetPlayerStateEffectValue(effectKey, "brightness") or values.brightness
    values.alpha = self:GetPlayerStateEffectValue(effectKey, "alpha") or values.alpha
    values.desaturate = self:GetPlayerStateEffectValue(effectKey, "desaturate") and true or false
    values.transitionSpeed = self:GetPlayerStateEffectValue(effectKey, "transitionSpeed") or values.transitionSpeed

    local pulseEnabled = self:GetPlayerStateEffectValue(effectKey, "pulseEnabled")
    if pulseEnabled then
        values.pulseSpeed = self:GetPlayerStateEffectValue(effectKey, "pulseSpeed") or values.pulseSpeed
        values.pulseStrength = self:GetPlayerStateEffectValue(effectKey, "pulseStrength") or values.pulseStrength
    else
        values.pulseStrength = 0
    end

    return values
end

local function GetEffectComposite(self)
    local baseR, baseG, baseB, baseAlpha, baseDesaturate = GetBaseAppearance(self)
    local effectState = EnsureEffectAnimationState(self).current
    local tintStrength = Clamp(effectState.tintStrength or 0, 0, 1)
    local brightness = Clamp(effectState.brightness or 1, 0.5, 2.0)
    local effectAlpha = Clamp(effectState.alpha or 1, 0.05, 1)
    local pulseStrength = Clamp(effectState.pulseStrength or 0, 0, 1)
    local pulseBoost = 0

    if pulseStrength > 0 then
        pulseBoost = GetBreathingPulse(effectState.pulseSpeed) * pulseStrength * 0.8
    end

    local finalR, finalG, finalB = MixColor(
        baseR,
        baseG,
        baseB,
        effectState.colorR or 1,
        effectState.colorG or 1,
        effectState.colorB or 1,
        tintStrength
    )

    local intensity = Clamp(brightness + pulseBoost, 0.35, 2.2)
    local baseIntensity = Clamp(intensity, 0, 1)
    local overlayAlpha = Clamp((intensity - 1) * 0.95, 0, 1)
    local overlayScale = 0.92 + (overlayAlpha * 0.22) + (pulseBoost * 0.12)
    local finalAlpha = Clamp(baseAlpha * effectAlpha, 0, 1)

    return {
        colorR = finalR,
        colorG = finalG,
        colorB = finalB,
        baseIntensity = baseIntensity,
        overlayAlpha = overlayAlpha * finalAlpha,
        overlayScale = overlayScale,
        alpha = finalAlpha,
        desaturate = baseDesaturate or (effectState.desaturate and true or false),
    }
end

function GG:RefreshPlayerStateEffectTarget()
    local effectState = EnsureEffectAnimationState(self)
    local targetValues = GetTargetEffectValues(self, self.currentPlayerStateEffectKey)

    effectState.target.colorR = targetValues.colorR
    effectState.target.colorG = targetValues.colorG
    effectState.target.colorB = targetValues.colorB
    effectState.target.tintStrength = targetValues.tintStrength
    effectState.target.brightness = targetValues.brightness
    effectState.target.alpha = targetValues.alpha
    effectState.target.desaturate = targetValues.desaturate and true or false
    effectState.target.pulseSpeed = targetValues.pulseSpeed
    effectState.target.pulseStrength = targetValues.pulseStrength
    effectState.target.transitionSpeed = targetValues.transitionSpeed

    self:RefreshGlowAppearance()
end

function GG:RefreshGlowAppearance()
    local glow = self.gauntletGlow
    local tex = glow and glow.texture
    local effectTex = glow and glow.effectTexture
    if not tex then
        return
    end

    local composite = GetEffectComposite(self)

    tex:SetVertexColor(
        Clamp(composite.colorR * composite.baseIntensity, 0, 1),
        Clamp(composite.colorG * composite.baseIntensity, 0, 1),
        Clamp(composite.colorB * composite.baseIntensity, 0, 1)
    )
    tex:SetAlpha(composite.alpha)
    SetTextureDesaturation(tex, composite.desaturate)

    if effectTex then
        if composite.overlayAlpha > 0.001 then
            effectTex:SetVertexColor(
                Clamp(composite.colorR * composite.overlayScale, 0, 1),
                Clamp(composite.colorG * composite.overlayScale, 0, 1),
                Clamp(composite.colorB * composite.overlayScale, 0, 1)
            )
            effectTex:SetAlpha(composite.overlayAlpha)
            effectTex:Show()
        else
            effectTex:SetAlpha(0)
            effectTex:Hide()
        end

        SetTextureDesaturation(effectTex, composite.desaturate)
    end
end

function GG:CreateGauntletGlow()
    local f = CreateFrame("Frame", "GauntletGlowFrame", UIParent)
    f:SetFrameStrata("TOOLTIP")

    local tex = f:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()
    tex:SetBlendMode("ADD")

    local effectTex = f:CreateTexture(nil, "OVERLAY", nil, 1)
    effectTex:SetAllPoints()
    effectTex:SetBlendMode("ADD")
    effectTex:SetAlpha(0)
    effectTex:Hide()

    f.texture = tex
    f.effectTexture = effectTex
    f:Hide()

    self.gauntletGlow = f
    EnsureEffectAnimationState(self)
    self:RefreshGlowAppearance()
end

function GG:ApplyState(stateName, force)
    if not force and self.currentStateName == stateName then return end
    self.currentStateName = stateName

    local state = self.States[stateName]
    if not state then return end

    self.gauntletGlow.texture:SetTexture(state.texture)
    if self.gauntletGlow.effectTexture then
        self.gauntletGlow.effectTexture:SetTexture(state.texture)
    end
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

    elseif stateName == "SPEAK" then
        sizeX = self.db.profile.speakSizeX or sizeX
        sizeY = self.db.profile.speakSizeY or sizeY
        offsetX = self.db.profile.speakOffsetX or offsetX
        offsetY = self.db.profile.speakOffsetY or offsetY

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

    elseif stateName == "QUEST_AVAILABLE" then
        sizeX = self.db.profile.questAvailableSizeX or sizeX
        sizeY = self.db.profile.questAvailableSizeY or sizeY
        offsetX = self.db.profile.questAvailableOffsetX or offsetX
        offsetY = self.db.profile.questAvailableOffsetY or offsetY

    elseif stateName == "QUEST_INCOMPLETE" then
        sizeX = self.db.profile.questIncompleteSizeX or sizeX
        sizeY = self.db.profile.questIncompleteSizeY or sizeY
        offsetX = self.db.profile.questIncompleteOffsetX or offsetX
        offsetY = self.db.profile.questIncompleteOffsetY or offsetY

    elseif stateName == "QUEST_TURN_IN" then
        sizeX = self.db.profile.questTurnInSizeX or sizeX
        sizeY = self.db.profile.questTurnInSizeY or sizeY
        offsetX = self.db.profile.questTurnInOffsetX or offsetX
        offsetY = self.db.profile.questTurnInOffsetY or offsetY

    elseif stateName == "FINANCE" then
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

    elseif stateName == "REPAIR_HOVER" then
        sizeX = self.db.profile.repairHoverSizeX or sizeX
        sizeY = self.db.profile.repairHoverSizeY or sizeY
        offsetX = self.db.profile.repairHoverOffsetX or offsetX
        offsetY = self.db.profile.repairHoverOffsetY or offsetY

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

    f:SetScript("OnUpdate", function(_, elapsed)
        self:UpdateCursorPosition()
        self:UpdateGlowEffectAnimation(elapsed or 0)
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

function GG:UpdateGlowEffectAnimation(elapsed)
    local effectState = EnsureEffectAnimationState(self)
    local current = effectState.current
    local target = effectState.target
    local transitionSpeed = GetTransitionResponseSpeed(target.transitionSpeed)

    current.colorR = SmoothValue(current.colorR, target.colorR, transitionSpeed, elapsed)
    current.colorG = SmoothValue(current.colorG, target.colorG, transitionSpeed, elapsed)
    current.colorB = SmoothValue(current.colorB, target.colorB, transitionSpeed, elapsed)
    current.tintStrength = SmoothValue(current.tintStrength, target.tintStrength, transitionSpeed, elapsed)
    current.brightness = SmoothValue(current.brightness, target.brightness, transitionSpeed, elapsed)
    current.alpha = SmoothValue(current.alpha, target.alpha, transitionSpeed, elapsed)
    current.desaturate = target.desaturate and true or false
    current.pulseSpeed = SmoothValue(current.pulseSpeed, target.pulseSpeed, transitionSpeed, elapsed)
    current.pulseStrength = SmoothValue(current.pulseStrength, target.pulseStrength, transitionSpeed, elapsed)

    self:RefreshGlowAppearance()
end
