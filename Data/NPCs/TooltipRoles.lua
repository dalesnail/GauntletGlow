local ADDON_NAME, ns = ...

ns.Data = ns.Data or {}

ns.Data["TOOLTIP_ROLE_KEYWORDS"] = {
    FLIGHTMASTER = {
        exact = {
            ["Flight Master"] = true,
            ["Gryphon Master"] = true,
            ["Hippogryph Master"] = true,
            ["Darnassus Flight Master"] = true,
            ["Wind Rider Master"] = true,
            ["Bat Handler"] = true,
            ["Dragonhawk Master"] = true,
            ["Spectral Gryphon Master"] = true,
        },
    },

    BATTLEMASTER = {
        contains = {
            "Battlemaster",
        },
    },

    TRAINER = {
        contains = {
            "Trainer",
        },
        exact = {
            ["Master Mage"] = true,
        },
    },

    DIRECTIONS_GUARD = {
        contains = {
            "Guard",
            "Guardian",
            "Peacekeeper",
            "Deathguard",
        },
    },

    INNKEEPER = {
        exact = {
            ["Innkeeper"] = true,
        },
    },
}