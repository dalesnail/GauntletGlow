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
            "Patroller",
        },
    },

    INNKEEPER = {
        exact = {
            ["Innkeeper"] = true,
        },
    },

    STABLEMASTER = {
        exact = {
            ["Stable Master"] = true,
        },
        contains = {}
    },

    MAILBOX = {
        exact = {
            ["Mailbox"] = true,
        },
        contains = {}
    },

    SKINNABLE = {
        exact = {
            ["Skinnable"] = true,
        },
        contains = {}
    },

    REPAIR_VENDOR = {
        exact = {
            ["General Goods and Repairs"] = true,
            ["General Goods and Repair"] = true,

            ["Armorer"] = true,
            ["Apprentice Armorer"] = true,
            ["Armor Crafter"] = true,
            ["Armorer & Shieldcrafter"] = true,
            ["Cloth Armor and Accessories"] = true,
            ["Cloth Armor Merchant"] = true,
            ["Clothier"] = true,
            ["Cloth & Leather Armor Merchant"] = true,
            ["Heavy Armor Merchant"] = true,
            ["Leather Armor & Leatherworking Supplies"] = true,
            ["Leather Armor Merchant"] = true,
            ["Light Armor Merchant"] = true,
            ["Light Armor & Weapons Merchant"] = true,
            ["Mail Armor Merchant"] = true,
            ["Mail & Plate Merchant"] = true,
            ["Night Elf Armorer"] = true,
            ["Superior Armorer"] = true,
            ["Superior Armorsmith"] = true,
            ["Armor Merchant"] = true,
            ["Plate Armor Merchant"] = true,

            ["Axecrafter"] = true,
            ["Axe Merchant"] = true,
            ["Superior Axecrafter"] = true,

            ["Bow Merchant"] = true,
            ["Bow & Arrow Merchant"] = true,
            ["Bowyer"] = true,
            ["Bowyer & Fletching Goods"] = true,
            ["Fletcher"] = true,
            ["Superior Bowyer"] = true,

            ["Gun Merchant"] = true,
            ["Bowyer & Gunsmith"] = true,
            ["Guns and Ammo Merchant"] = true,
            ["Gunsmith"] = true,
            ["Gunsmith & Bowyer"] = true,
            ["Weaponsmith & Gunsmith"] = true,
            ["Bow & Gun Merchant"] = true,

            ["Macecrafter"] = true,
            ["Mace & Staff Merchant"] = true,
            ["Mace & Staves"] = true,
            ["Mace & Staves Vendor"] = true,
            ["Staff & Mace Merchant"] = true,
            ["Superior Macecrafter"] = true,

            ["Staff Merchant"] = true,
            ["Staves Merchant"] = true,

            ["Wand Merchant"] = true,
            ["Wand Vendor"] = true,

            ["Weapon Merchant"] = true,
            ["Apprentice Weaponsmith"] = true,
            ["Dwarven Weaponsmith"] = true,
            ["Master Weaponsmith"] = true,
            ["Superior Weaponsmith"] = true,
            ["Sword and Dagger Merchant"] = true,
            ["Thrown Weapons Merchant"] = true,
            ["Two Handed Weapon Merchant"] = true,
            ["Weapons Merchant"] = true,
            ["Weaponsmith"] = true,
            ["Weaponsmith & Armorcrafter"] = true,
            ["Weaponsmith & Armorer"] = true,
            ["Weapons Quartermaster"] = true,
            ["Weapon Vendor"] = true,

            ["Blunt Weapon Merchant"] = true,
        },
        contains = {}
    },

    VENDOR = {
        exact = {
            ["Merchant"] = true,
            ["Vendor"] = true,
            ["Supplies"] = true,

            ["General Goods"] = true,
            ["General Goods Merchant"] = true,
            ["General Goods Vendor"] = true,
            ["General Supplies"] = true,

            ["Trade Supplies"] = true,
            ["Trade Supplier"] = true,
            ["Trade Goods Supplies"] = true,
            ["General Trade Supplier"] = true,
            ["General Trade Goods Merchant"] = true,
            ["General Trade Goods Vendor"] = true,

            ["Armorer"] = true,
            ["Armor Merchant"] = true,
            ["Heavy Armor Merchant"] = true,
            ["Light Armor Merchant"] = true,
            ["Leather Armor Merchant"] = true,
            ["Cloth Armor Merchant"] = true,
            ["Mail Armor Merchant"] = true,
            ["Mail & Plate Merchant"] = true,

            ["Weapon Merchant"] = true,
            ["Weaponsmith & Gunsmith"] = true,

            ["Bow Merchant"] = true,
            ["Bow & Arrow Merchant"] = true,
            ["Bowyer"] = true,
            ["Superior Bowyer"] = true,
            ["Bowyer & Fletching Goods"] = true,
            ["Fletcher"] = true,

            ["Gun Merchant"] = true,
            ["Guns and Ammo Merchant"] = true,
            ["Gunsmith"] = true,
            ["Gunsmith & Bowyer"] = true,
            ["Bowyer & Gunsmith"] = true,
            ["Ammunition"] = true,
            ["Guns and Ammunition"] = true,
            ["Throwing Weapons & Ammunition"] = true,

            ["Macecrafter"] = true,
            ["Superior Macecrafter"] = true,
            ["Mace & Staff Merchant"] = true,
            ["Mace & Staves"] = true,
            ["Mace & Staves Vendor"] = true,
            ["Staff & Mace Merchant"] = true,

            ["Arcane Goods Vendor"] = true,
            ["Bag Vendor"] = true,
            ["Butcher"] = true,
            ["Meats"] = true,
            ["Darkmoon Faire Cards & Exotic Goods"] = true,

            ["Bait and Tackle Supplier"] = true,
            ["Fishing Supplies"] = true,
            ["Fishing Trainer & Supplies"] = true,
            ["Fish Merchant & Supplies"] = true,

            ["Herbalism Supplies"] = true,
            ["Herbalism & Alchemy Supplies"] = true,
            ["Reagents"] = true,
            ["Reagents and Herbs"] = true,
            ["Reagents & Poisons"] = true,
            ["Poisons & Reagents"] = true,
            ["Poison Supplies"] = true,
            ["Poison Vendor"] = true,

            ["Leather Armor & Leatherworking Supplies"] = true,
            ["Leatherworking & Tailoring Supplies"] = true,
            ["Specialist Leatherworking Supplies"] = true,

            ["Mining Supplies"] = true,

            ["Speciality Tailoring Supplies"] = true,
            ["Tailoring Supplies & Specialty Goods"] = true,

            ["General Provisioner"] = true,
            ["Provisioner"] = true,
            ["Camp Trader"] = true,
            ["Shady Dealer"] = true,
            ["Hermit & Trader"] = true,

            ["Mount Vendor"] = true,
            ["Mechanostrider Merchant"] = true,
            ["Horse Breeder"] = true,
            ["Ram Breeder"] = true,
            ["Raptor Handler"] = true,
            ["Saber Handler"] = true,
            ["Elekk Breeder"] = true,
            ["Gryphon Keeper"] = true,
            ["Hawkstrider Breeder"] = true,
            ["Kodo Mounts"] = true,
        },
        contains = {}
    },
}