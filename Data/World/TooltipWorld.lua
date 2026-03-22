local ADDON_NAME, ns = ...

ns.Data = ns.Data or {}

ns.Data["TOOLTIP_WORLD_KEYWORDS"] = {
    HERBALISM = {
        exact = {
            ["Requires Herbalism"] = true,
            ["Herbalism"] = true,
        },
        contains = {},
    },

    MINING = {
        exact = {
            ["Requires Mining"] = true,
            ["Mining"] = true,
            ["Mining Required"] = true,
        },
        contains = {},
    },
}