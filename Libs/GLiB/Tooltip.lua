local GLiB = _G.GLiB
if not GLiB then
    return
end

local P = GLiB._p
if not P then
    return
end

P.tooltipNpcTags = {
    skinnable = {
        exact = {
            ["Skinnable"] = true,
        },
        contains = {},
    },

    repair_vendor = {
        exact = {
            ["General Goods and Repairs"] = true,
            ["General Goods and Repair"] = true,
            ["General Goods & Repairs"] = true,
            ["General Goods & Repair"] = true,

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

            ["Blacksmithing Supplies"] = true,
            ["Blacksmithing Supplier"] = true,
            ["Blade Merchant"] = true,
            ["Blade Trader"] = true,
            ["Shield Merchant"] = true,
            ["Armorsmith"] = true,
            ["Armorer & Shieldsmith"] = true,
            ["Armorer and Shieldcrafter"] = true,
            ["Metalsmith"] = true,
            ["Shield Crafter"] = true,
            ["Cloth & Leather Merchant"] = true,
            ["Leather & Mail Armor Merchant"] = true,
            ["Guns Merchant"] = true,
        },
        contains = {},
    },

    vendor = {
        exact = {
            ["General Goods"] = true,
            ["General Goods Vendor"] = true,
            ["General Supplies"] = true,
            ["General & Trade Supplies"] = true,
            ["General Trade Supplier"] = true,
            ["General Trade Goods Vendor"] = true,

            ["Trade Supplies"] = true,
            ["Trade Supplier"] = true,
            ["Trade Goods"] = true,

            ["Food & Drink"] = true,
            ["Food and Drink"] = true,
            ["Food & Drink Vendor"] = true,
            ["Food & Drink Merchant"] = true,
            ["Food Vendor"] = true,
            ["Bread Vendor"] = true,
            ["Fruit Vendor"] = true,
            ["Drink Vendor"] = true,
            ["Fish Vendor"] = true,
            ["Fishing Supplies"] = true,
            ["Fishing Supplier"] = true,

            ["Tailoring Supplies"] = true,
            ["Tailoring Supplies & Specialty Goods"] = true,
            ["Blacksmithing Supplies"] = true,
            ["Blacksmithing Supplier"] = true,
            ["Leatherworking Supplies"] = true,
            ["Alchemy Supplies"] = true,
            ["Alchemy Supplies & Reagents"] = true,
            ["Engineering Supplies"] = true,
            ["Engineering Supplier"] = true,
            ["Enchanting Supplies"] = true,
            ["Cooking Supplies"] = true,
            ["Herbalism Supplies"] = true,
            ["Mining Supplies"] = true,
            ["Mining Supplier"] = true,
            ["Jewelcrafting Supplies"] = true,

            ["Reagents"] = true,
            ["Reagent Vendor"] = true,
            ["Reagents Vendor"] = true,
            ["Arcane Goods"] = true,
            ["Arcane Goods Vendor"] = true,
            ["Poison Supplies"] = true,
            ["Poison Supplier"] = true,
            ["Poison Vendor"] = true,
            ["Bag Vendor"] = true,
        },
        contains = {},
    },
}

P.tooltipWorldTags = {
    herbalism = {
        exact = {
            ["Requires Herbalism"] = true,
            ["Herbalism"] = true,
            ["[+] Herbalism"] = true,
            ["[++] Herbalism"] = true,
            ["[+++] Herbalism"] = true,
            ["[-] Herbalism"] = true,
        },
        contains = {},
    },

    mining = {
        exact = {
            ["Requires Mining"] = true,
            ["Mining"] = true,
            ["Mining Required"] = true,
            ["[+] Mining"] = true,
            ["[++] Mining"] = true,
            ["[+++] Mining"] = true,
            ["[-] Mining"] = true,
        },
        contains = {},
    },
}