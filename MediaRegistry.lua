local ADDON_NAME, ns = ...

local MEDIA_ROOT = "Interface\\AddOns\\GauntletGlow\\Media\\"

local registry = {
    root = MEDIA_ROOT,
    order = {
        "gauntlet",
        "attack",
        "loot_vendor",
        "autoloot",
        "herbalism",
        "mining",
        "flight",
        "battlemaster",
        "trainer",
        "speak",
        "directions",
        "innkeeper",
        "stable_master",
        "mail",
        "quest_available",
        "quest_turn_in",
        "skinning",
        "repair_anvil",
        "repair_hammer",
        "cogwheel",
        "engineer",
        "inspect",
        "move",
        "quest_repeatable",
        "skinhorde",
        "talk",
    },
    groups = {
        gauntlet = {
            file = "cursor_glow_default.png",
            optionLabel = "Gauntlet",
            states = { "DEFAULT" },
            primaryState = "DEFAULT",
            sharedDefaultsState = "DEFAULT",
            active = true,
        },
        attack = {
            file = "sword_glow_default.png",
            optionLabel = "Attack",
            states = { "ATTACK" },
            primaryState = "ATTACK",
            sharedDefaultsState = "ATTACK",
            active = true,
        },
        loot_vendor = {
            file = "loot_glow.png",
            optionLabel = "Loot / Vendor",
            states = { "LOOT", "FINANCE", "VENDOR", "SELL_ITEM" },
            primaryState = "LOOT",
            sharedDefaultsState = "LOOT",
            active = true,
        },
        autoloot = {
            file = "autoloot_glow.png",
            optionLabel = "Autoloot",
            states = { "AUTOLOOT" },
            primaryState = "AUTOLOOT",
            sharedDefaultsState = "AUTOLOOT",
            active = true,
        },
        herbalism = {
            file = "herb_glow.png",
            optionLabel = "Herbalism",
            states = { "HERBALISM" },
            primaryState = "HERBALISM",
            sharedDefaultsState = "HERBALISM",
            active = true,
        },
        mining = {
            file = "mining_glow.png",
            optionLabel = "Mining",
            states = { "MINING" },
            primaryState = "MINING",
            sharedDefaultsState = "MINING",
            active = true,
        },
        flight = {
            file = "flight_glow.png",
            optionLabel = "Flight",
            states = { "FLIGHTMASTER" },
            primaryState = "FLIGHTMASTER",
            sharedDefaultsState = "FLIGHTMASTER",
            active = true,
        },
        battlemaster = {
            file = "battlemaster_glow.png",
            optionLabel = "Battlemaster",
            states = { "BATTLEMASTER" },
            primaryState = "BATTLEMASTER",
            sharedDefaultsState = "BATTLEMASTER",
            active = true,
        },
        trainer = {
            file = "trainer_glow.png",
            optionLabel = "Trainer",
            states = { "TRAINER" },
            primaryState = "TRAINER",
            sharedDefaultsState = "TRAINER",
            active = true,
        },
        speak = {
            file = "speak_glow.png",
            optionLabel = "Speak",
            states = { "SPEAK" },
            primaryState = "SPEAK",
            sharedDefaultsState = "SPEAK",
            active = true,
        },
        directions = {
            file = "directions_glow.png",
            optionLabel = "Directions",
            states = { "DIRECTIONS_GUARD" },
            primaryState = "DIRECTIONS_GUARD",
            sharedDefaultsState = "DIRECTIONS_GUARD",
            active = true,
        },
        innkeeper = {
            file = "innkeeper_glow.png",
            optionLabel = "Innkeeper",
            states = { "INNKEEPER" },
            primaryState = "INNKEEPER",
            sharedDefaultsState = "INNKEEPER",
            active = true,
        },
        stable_master = {
            file = "stablemaster_glow.png",
            optionLabel = "Stable Master",
            states = { "STABLEMASTER" },
            primaryState = "STABLEMASTER",
            sharedDefaultsState = "STABLEMASTER",
            active = true,
        },
        mail = {
            file = "mail_glow.png",
            optionLabel = "Mail",
            states = { "MAILBOX" },
            primaryState = "MAILBOX",
            sharedDefaultsState = "MAILBOX",
            active = true,
        },
        quest_available = {
            file = "quest_A.png",
            optionLabel = "Quest Available",
            states = { "QUEST_AVAILABLE", "QUEST_INCOMPLETE" },
            primaryState = "QUEST_AVAILABLE",
            sharedDefaultsState = "QUEST_AVAILABLE",
            active = true,
        },
        quest_turn_in = {
            file = "quest_C.png",
            optionLabel = "Quest Turn-In",
            states = { "QUEST_TURN_IN" },
            primaryState = "QUEST_TURN_IN",
            sharedDefaultsState = "QUEST_TURN_IN",
            active = true,
        },
        skinning = {
            file = "skinnable_glow.png",
            optionLabel = "Skinning",
            states = { "SKINNABLE" },
            primaryState = "SKINNABLE",
            sharedDefaultsState = "SKINNABLE",
            active = true,
        },
        repair_anvil = {
            file = "repair_glow.png",
            optionLabel = "Repair Anvil",
            states = { "REPAIR_VENDOR" },
            primaryState = "REPAIR_VENDOR",
            sharedDefaultsState = "REPAIR_VENDOR",
            active = true,
        },
        repair_hammer = {
            file = "repair_hover.png",
            optionLabel = "Repair Hammer",
            states = { "REPAIR_HOVER" },
            primaryState = "REPAIR_HOVER",
            sharedDefaultsState = "REPAIR_HOVER",
            active = true,
        },
        cogwheel = {
            file = "cogwheel_glow.png",
            optionLabel = "Cogwheel",
            states = { "COGWHEEL" },
            primaryState = "COGWHEEL",
            sharedDefaultsState = "COGWHEEL",
            active = true,
        },
        engineer = {
            file = "engineer.png",
            optionLabel = "Engineer",
            states = {},
            active = false,
        },
        inspect = {
            file = "inspect.png",
            optionLabel = "Inspect",
            states = {},
            active = false,
        },
        move = {
            file = "move.png",
            optionLabel = "Move",
            states = {},
            active = false,
        },
        quest_repeatable = {
            file = "quest_repeatable.png",
            optionLabel = "Quest Repeatable",
            states = {},
            active = false,
        },
        skinhorde = {
            file = "skinhorde.png",
            optionLabel = "Skinhorde",
            states = {},
            active = false,
        },
        talk = {
            file = "talk_glow.png",
            optionLabel = "Talk",
            states = {},
            active = false,
        },
    },
}

registry.stateToGroup = {}

for _, groupKey in ipairs(registry.order) do
    local group = registry.groups[groupKey]
    if group then
        group.key = groupKey
        group.path = MEDIA_ROOT .. group.file
        group.states = group.states or {}

        for _, stateKey in ipairs(group.states) do
            registry.stateToGroup[stateKey] = groupKey
        end
    end
end

function registry:GetGroup(groupKey)
    return self.groups[groupKey]
end

function registry:GetGroupKeyForState(stateKey)
    return self.stateToGroup[stateKey]
end

function registry:GetGroupForState(stateKey)
    local groupKey = self:GetGroupKeyForState(stateKey)
    return groupKey and self.groups[groupKey] or nil
end

function registry:GetTexturePath(key)
    local group = self.groups[key] or self:GetGroupForState(key)
    return group and group.path or nil
end

ns.MediaRegistry = registry

if ns.GauntletGlow then
    ns.GauntletGlow.MediaRegistry = registry
end
