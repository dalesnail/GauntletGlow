# CursorGlow Development Context

## ?? Last Updated

2026-03-21

---

# ?? Current Status

The addon is stable and functioning correctly with the following implemented systems:

### ? Core Features

* Cursor glow rendering system is working
* State-based visual system is functioning correctly
* Tooltip scanning supports ALL tooltip lines dynamically
* Trigger system correctly evaluates and resolves states using priority

### ? Working States

* DEFAULT
* ATTACK
* HERBALISM
* MINING
* LOOT
* AUTOLOOT
* FLIGHTMASTER
* BATTLEMASTER (implemented, partially tested)
* TRAINER (implemented)
* INNKEEPER (implemented)
* DIRECTIONS_GUARD (implemented but known to be noisy)

### ? Flight Master System

* Primary detection via tooltip role titles (line scanning)
* Optional fallback via name list (currently minimal)
* Fully working and validated

---

# ?? Current Development Direction

The addon is evolving into a **tooltip-driven NPC classification system**.

### Primary Detection Model

* Scan ALL tooltip lines via `Tooltip:GetLines()`
* Match against structured keyword data:

  * Exact matches
  * Substring matches

### Data Source

* `Data/NPCs/TooltipRoles.lua` ? primary keyword definitions
* `Data/NPCs/FlightMasters.lua` ? optional fallback name list

---

# ?? Next Target Features

### High Priority

* Mailbox detection
* Skinnable corpse detection
* Vendor detection
* Stable master detection

### Experimental / Advanced

* Detection based on cursor types:

  * SkinAlliance
  * SkinHorde

---

# ?? Known Issues / Constraints

* Tooltip data varies across NPC types and zones
* Some categories (e.g. guards) are inherently noisy
* WoW TBC Classic API differs from Retail:

  * Do NOT assume Retail-only API functions exist
* Tooltip events fire frequently ? performance matters

---

# ?? Architecture Rules (STRICT)

* Do NOT rewrite working systems unless absolutely necessary
* Preserve current file structure and responsibilities
* Extend systems incrementally and safely
* Avoid large refactors unless explicitly requested

---

# ?? File Responsibilities

* Core.lua ? addon initialization, state application
* Tooltip.lua ? tooltip scanning and data extraction
* Trigger.lua ? detection logic and candidate generation
* States.lua ? state definitions and priority system
* Options.lua ? configuration UI (Ace3)
* Data/NPCs/TooltipRoles.lua ? structured tooltip keyword data
* Data/NPCs/FlightMasters.lua ? optional fallback name data

---

# ?? State System

### Behavior

* Multiple states may be valid simultaneously
* Highest priority state is selected

### Current Priority (simplified)

1. HERBALISM
2. MINING
3. FLIGHTMASTER
4. AUTOLOOT
5. LOOT
6. ATTACK
7. DEFAULT

(New states follow similar structure and are integrated without breaking existing order)

---

# ?? Tooltip Role Detection System

### Structure

```lua
ns.Data["TOOLTIP_ROLE_KEYWORDS"] = {
    CATEGORY = {
        exact = { ... },
        contains = { ... }
    }
}
```

### Matching Rules

* `exact` ? full string match
* `contains` ? substring match

### Detection Flow

1. Get all tooltip lines
2. Iterate through lines
3. Match against keyword tables
4. Add matching state to candidates

---

# ?? Known Weak Category

### DIRECTIONS_GUARD

* Uses broad keyword matching (e.g. "Guard")
* Causes false positives on generic NPCs
* Currently accepted as "low precision / acceptable noise"

---

# ?? Debug / Performance Notes

* Tooltip scanning must remain lightweight
* Avoid redundant table creation where possible
* Prefer reuse of buffers (e.g. wipe tables)

---

# ?? Hard Rules for Code Generation

* Output FULL FILES or FULL FUNCTION BLOCKS only
* Do NOT output partial snippets
* Do NOT introduce new frameworks or abstractions
* Do NOT restructure modules
* Follow existing naming and structure exactly
* Preserve working behavior at all costs

---

# ?? Development Workflow (CRITICAL)

## ChatGPT (Planning + Debugging)

Use ChatGPT for:

* System design
* Debugging issues
* Data structure creation
* Writing static data files
* Breaking work into safe steps

## Codex (Execution)

Use Codex for:

* Implementing features
* Modifying files
* Wiring systems together

### Codex Rules

* Tasks must be SMALL and SCOPED
* Prefer single-feature or limited multi-file changes
* Always include guard rails:

  * “Do not refactor working systems”
  * “Preserve structure”
  * “Additive changes only”

---

# ?? Codex Usage Strategy

### Safe Tasks

* Adding new detection categories
* Updating Trigger.lua logic
* Extending Options.lua

### Medium Tasks

* Multi-file feature integration (with guard rails)

### Dangerous Tasks (AVOID)

* Full addon refactors
* Large data generation in one pass
* Architecture changes

---

# ?? Data Strategy

* Tooltip-based categories use shared structured file:

  * TooltipRoles.lua
* Fallback name-based detection uses separate files
* Keep fallback datasets minimal unless necessary

---

# ?? Future Expansion

Potential future systems:

* Improved vendor detection (if clean identifiers found)
* Cursor-type-based detection (SkinAlliance / SkinHorde)
* Performance optimization pass
* Debug overlay tools (DaleBug integration)

---

# ?? Guiding Principle

> Prefer **simple, reliable detection systems** over complex or fragile ones.

If a category cannot be detected cleanly via tooltip or simple logic,
it should be deferred rather than forced.
