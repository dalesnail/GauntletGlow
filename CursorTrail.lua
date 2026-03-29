local ADDON_NAME, ns = ...

local CursorTrail = ns.CursorTrail or {}
ns.CursorTrail = CursorTrail

local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local GetTime = GetTime
local UIParent = UIParent
local max = math.max
local ceil = math.ceil
local sqrt = math.sqrt

local ATLAS_NAME = "bags-glow-flash"
local DEFAULT_FRAME_STRATA = "TOOLTIP"
local DEFAULT_POOL_SIZE = 16
local MAX_POOL_SIZE = 300
local MAX_EMISSIONS_PER_UPDATE = 40
local REFERENCE_SPACING = 12
local MIN_EFFECTIVE_SPACING = 1.5
local MAX_EFFECTIVE_SPACING = 5
local SPACING_SIZE_RATIO = 0.06
local HITCH_RESET_THRESHOLD = 0.25
local DEFAULT_TRAIL_LENGTH = 72
local LONG_TRAIL_SPACING_REDUCTION = 0.16

local function GetAddon()
    return ns.GauntletGlow
end

local function Clamp(value, lower, upper)
    if value == nil then
        return lower
    end

    if value < lower then
        return lower
    end

    if value > upper then
        return upper
    end

    return value
end

local function GetDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return sqrt((dx * dx) + (dy * dy))
end

local function GetOffset(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    local distance = sqrt((dx * dx) + (dy * dy))
    return dx, dy, distance
end

local function GetEffectiveSpacing(settings)
    local baseSpacing = Clamp(settings and settings.spacing or REFERENCE_SPACING, 6, 18)
    local size = Clamp(settings and settings.size or 34, 16, 72)
    local spacingScale = baseSpacing / REFERENCE_SPACING
    local sizeDrivenSpacing = size * SPACING_SIZE_RATIO
    local trailLength = Clamp(settings and settings.trailLength or DEFAULT_TRAIL_LENGTH, 12, MAX_POOL_SIZE)
    local longTrailFactor = Clamp((trailLength - DEFAULT_TRAIL_LENGTH) / (MAX_POOL_SIZE - DEFAULT_TRAIL_LENGTH), 0, 1)
    local spacingReduction = 1 - (LONG_TRAIL_SPACING_REDUCTION * longTrailFactor)

    return Clamp(sizeDrivenSpacing * spacingScale * spacingReduction, MIN_EFFECTIVE_SPACING, MAX_EFFECTIVE_SPACING)
end

local function GetMovementThreshold(settings)
    return Clamp(GetEffectiveSpacing(settings) * 0.20, 0.2, 1.0)
end

local function GetTrailLengthBudget(settings)
    return Clamp(settings and settings.trailLength or DEFAULT_TRAIL_LENGTH, 12, MAX_POOL_SIZE)
end

local function HideSegment(segment)
    if not segment then
        return
    end

    segment:Hide()
    segment:SetAlpha(0)
end

local function ResetSegment(segment)
    if not segment then
        return
    end

    segment.birthTime = nil
    segment.lifetime = nil
    segment.startAlpha = nil
    segment.startSize = nil
    segment.colorR = nil
    segment.colorG = nil
    segment.colorB = nil
    HideSegment(segment)
end

local function PrepareSegmentTexture(texture)
    texture:SetDrawLayer("OVERLAY")
    texture:SetBlendMode("ADD")
    texture:SetAlpha(0)
    texture:Hide()

    if texture.SetAtlas then
        texture:SetAtlas(ATLAS_NAME, true)
    end
end

local function GetRankFactors(rank, capacity)
    if not capacity or capacity <= 1 then
        return 1, 1, 1
    end

    local pos = 1 - ((rank - 1) / (capacity - 1))
    pos = Clamp(pos, 0, 1)
    local alphaPos = 0.16 + (0.84 * (pos * pos))
    local sizePos = 0.36 + (0.64 * (pos ^ 0.38))
    return pos, alphaPos, sizePos
end

local function GetVisualState(startAlpha, startSize, lifetime, age, rank, capacity)
    local safeLifetime = max(lifetime or 0.01, 0.01)
    local progress = Clamp(age / safeLifetime, 0, 1)
    local timeFade = 1 - progress
    local _, alphaPos, sizePos = GetRankFactors(rank or 1, capacity or 1)
    local alphaTimeFactor = timeFade * timeFade
    local sizeTimeFactor = 0.28 + (0.72 * sqrt(timeFade))
    local alpha = (startAlpha or 1) * alphaTimeFactor * alphaPos
    local size = (startSize or 32) * sizeTimeFactor * sizePos

    return alpha, size
end

local function ApplySegmentVisuals(segment, age, rank, capacity)
    local alpha, size = GetVisualState(segment.startAlpha, segment.startSize, segment.lifetime, age, rank, capacity)

    segment:SetSize(size, size)
    segment:SetVertexColor(segment.colorR or 1, segment.colorG or 1, segment.colorB or 1)
    segment:SetAlpha(alpha)
end

function CursorTrail:CreateRenderer()
    if self.frame then
        return
    end

    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetAllPoints(UIParent)
    frame:SetFrameStrata(DEFAULT_FRAME_STRATA)
    frame:Hide()

    self.frame = frame
    self.activeSegments = {}
    self.inactiveSegments = {}
    self.totalSegments = 0
    self.headSegment = self.frame:CreateTexture(nil, "OVERLAY")
    PrepareSegmentTexture(self.headSegment)

    for _ = 1, DEFAULT_POOL_SIZE do
        self:CreateSegment()
    end
end

function CursorTrail:CreateSegment()
    if not self.frame or self.totalSegments >= MAX_POOL_SIZE then
        return nil
    end

    local segment = self.frame:CreateTexture(nil, "OVERLAY")
    PrepareSegmentTexture(segment)

    self.totalSegments = self.totalSegments + 1
    self.inactiveSegments[#self.inactiveSegments + 1] = segment

    return segment
end

function CursorTrail:PopInactiveSegment()
    local inactiveSegments = self.inactiveSegments
    if not inactiveSegments then
        return nil
    end

    local index = #inactiveSegments
    if index <= 0 then
        return nil
    end

    local segment = inactiveSegments[index]
    inactiveSegments[index] = nil
    return segment
end

function CursorTrail:AcquireSegment()
    local segment = self:PopInactiveSegment()
    if segment then
        return segment
    end

    segment = self:CreateSegment()
    if segment then
        return self:PopInactiveSegment()
    end

    if #self.activeSegments > 0 then
        segment = table.remove(self.activeSegments, 1)
        ResetSegment(segment)
        return segment
    end

    return nil
end

function CursorTrail:ReleaseSegment(index)
    local segment = table.remove(self.activeSegments, index)
    if not segment then
        return
    end

    ResetSegment(segment)
    self.inactiveSegments[#self.inactiveSegments + 1] = segment
end

function CursorTrail:ClearSegments()
    if not self.activeSegments then
        return
    end

    for index = #self.activeSegments, 1, -1 do
        self:ReleaseSegment(index)
    end
end

function CursorTrail:ResetTracking()
    self.lastCursorX = nil
    self.lastCursorY = nil
    self.lastEmitX = nil
    self.lastEmitY = nil
    self.currentCursorX = nil
    self.currentCursorY = nil
    self.lastUpdateTime = nil
end

function CursorTrail:Disable()
    self.enabled = false
    self.settings = nil

    if self.frame then
        self.frame:SetScript("OnUpdate", nil)
        self.frame:Hide()
    end

    self:ResetTracking()
    self:ClearSegments()
    HideSegment(self.headSegment)
end

function CursorTrail:Shutdown()
    self:Disable()
end

function CursorTrail:ApplySettings()
    local addon = GetAddon()
    local settings = addon and addon.GetCursorTrailSettings and addon:GetCursorTrailSettings() or nil
    self.settings = settings

    if not settings then
        return nil
    end

    settings.effectiveSpacing = GetEffectiveSpacing(settings)
    settings.movementThreshold = GetMovementThreshold(settings)
    settings.trailLengthBudget = GetTrailLengthBudget(settings)
    settings.rankCapacity = settings.trailLengthBudget

    for _, segment in ipairs(self.activeSegments or {}) do
        segment.startAlpha = settings.alpha
        segment.startSize = settings.size
        segment.lifetime = settings.lifetime
        segment.colorR = settings.colorR
        segment.colorG = settings.colorG
        segment.colorB = settings.colorB
    end

    if self.headSegment then
        self.headSegment.startAlpha = settings.alpha
        self.headSegment.startSize = settings.size
        self.headSegment.lifetime = settings.lifetime
        self.headSegment.colorR = settings.colorR
        self.headSegment.colorG = settings.colorG
        self.headSegment.colorB = settings.colorB
    end

    return settings
end

function CursorTrail:EnforceSegmentBudget()
    local maxVisibleSegments = (self.settings and self.settings.trailLengthBudget) or MAX_POOL_SIZE

    while #self.activeSegments > maxVisibleSegments do
        self:ReleaseSegment(1)
    end
end

function CursorTrail:EmitSegment(x, y, now)
    local settings = self.settings
    if not settings then
        return
    end

    local segment = self:AcquireSegment()
    if not segment then
        return
    end

    segment:ClearAllPoints()
    segment:SetPoint("CENTER", self.frame, "BOTTOMLEFT", x, y)
    segment.birthTime = now
    segment.lifetime = settings.lifetime
    segment.startAlpha = settings.alpha
    segment.startSize = settings.size
    segment.colorR = settings.colorR
    segment.colorG = settings.colorG
    segment.colorB = settings.colorB

    ApplySegmentVisuals(segment, 0)
    segment:Show()

    self.activeSegments[#self.activeSegments + 1] = segment
    self:EnforceSegmentBudget()
end

function CursorTrail:UpdateSegments(now)
    if not self.activeSegments then
        return
    end

    for index = #self.activeSegments, 1, -1 do
        local segment = self.activeSegments[index]
        local age = now - (segment.birthTime or now)

        if age >= (segment.lifetime or 0) then
            self:ReleaseSegment(index)
        end
    end

    local visibleCount = #self.activeSegments
    local rankCapacity = (self.settings and self.settings.rankCapacity) or MAX_POOL_SIZE

    for index = visibleCount, 1, -1 do
        local segment = self.activeSegments[index]
        local age = now - (segment.birthTime or now)
        local rank = (visibleCount - index) + 2

        ApplySegmentVisuals(segment, age, rank, rankCapacity)
    end

    self:UpdateHeadSegment(now, visibleCount, rankCapacity)
end

function CursorTrail:UpdateHeadSegment(now, visibleCount, rankCapacity)
    local headSegment = self.headSegment
    local settings = self.settings
    if not headSegment or not settings or not self.currentCursorX or not self.currentCursorY then
        HideSegment(headSegment)
        return
    end

    local lastEmitTime = self.lastEmitTime or now
    local idle = now - lastEmitTime
    local headAge = Clamp(idle, 0, settings.lifetime or 0)
    local alpha, size = GetVisualState(settings.alpha, settings.size, settings.lifetime, headAge, 1, rankCapacity)

    if alpha <= 0.01 or size <= 0.01 or visibleCount <= 0 then
        HideSegment(headSegment)
        return
    end

    headSegment:ClearAllPoints()
    headSegment:SetPoint("CENTER", self.frame, "BOTTOMLEFT", self.currentCursorX, self.currentCursorY)
    headSegment:SetSize(size, size)
    headSegment:SetVertexColor(settings.colorR, settings.colorG, settings.colorB)
    headSegment:SetAlpha(alpha)
    headSegment:Show()
end

function CursorTrail:EmitAlongPath(x, y, now)
    local settings = self.settings
    if not settings then
        return
    end

    if not self.lastEmitX or not self.lastEmitY then
        self.lastEmitX = x
        self.lastEmitY = y
        return
    end

    local spacing = settings.effectiveSpacing or settings.spacing
    local dx, dy, distance = GetOffset(self.lastEmitX, self.lastEmitY, x, y)
    if distance < (settings.movementThreshold or 0) then
        return
    end

    local steps = ceil(distance / max(spacing, 0.001))
    if steps <= 0 then
        return
    end

    steps = math.min(steps, MAX_EMISSIONS_PER_UPDATE)

    for index = 1, steps do
        local t = index / steps
        local sampleX = self.lastEmitX + (dx * t)
        local sampleY = self.lastEmitY + (dy * t)
        self:EmitSegment(sampleX, sampleY, now)
    end

    self.lastEmitX = x
    self.lastEmitY = y
    self.lastEmitTime = now
end

function CursorTrail:UpdateCursor(now)
    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    if not scale or scale == 0 then
        return
    end

    cursorX = cursorX / scale
    cursorY = cursorY / scale
    self.currentCursorX = cursorX
    self.currentCursorY = cursorY

    if not self.lastCursorX or not self.lastCursorY then
        self.lastCursorX = cursorX
        self.lastCursorY = cursorY
        self.lastEmitX = cursorX
        self.lastEmitY = cursorY
        self.lastEmitTime = now
        return
    end

    local movementThreshold = (self.settings and self.settings.movementThreshold) or 2
    if GetDistance(self.lastCursorX, self.lastCursorY, cursorX, cursorY) >= movementThreshold then
        self:EmitAlongPath(cursorX, cursorY, now)
    end

    self.lastCursorX = cursorX
    self.lastCursorY = cursorY
end

function CursorTrail:OnUpdate(_, _)
    local now = GetTime()
    if self.lastUpdateTime and (now - self.lastUpdateTime) > HITCH_RESET_THRESHOLD then
        self:ResetTracking()
        self:ClearSegments()
    end

    self.lastUpdateTime = now
    self:UpdateCursor(now)
    self:UpdateSegments(now)
end

function CursorTrail:Enable()
    self:CreateRenderer()

    local settings = self:ApplySettings()
    if not settings then
        return
    end

    self.enabled = true
    self.frame:Show()
    self.frame:SetScript("OnUpdate", function(frame, elapsed)
        self:OnUpdate(frame, elapsed)
    end)
end

function CursorTrail:Refresh()
    local addon = GetAddon()
    local settings = addon and addon.GetCursorTrailSettings and addon:GetCursorTrailSettings() or nil
    if not settings or not settings.enabled then
        self:Disable()
        return
    end

    self:CreateRenderer()
    self:ApplySettings()
    self:EnforceSegmentBudget()

    if not self.enabled then
        self:Enable()
        return
    end

    self.frame:Show()
end
