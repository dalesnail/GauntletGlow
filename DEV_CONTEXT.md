# CursorGlow Development Context

## ?? Current Status

* Cursor glow system is functional and stable
* Supported states:

  * Default
  * Attack
  * Herbing
  * Mining
  * Loot
  * Auto Loot
* Tooltip-based detection is working for gathering nodes
* Loot detection is working, including:

  * Proper corpse detection
  * Differentiation between lootable and non-lootable units
* Tooltip module has been **removed from active use**

---

## ?? Current Goals

1. Implement flight master detection using tooltip parsing
2. Expand detection system to support additional NPC types
3. Maintain stability of trigger system before adding complexity

---

## ?? Current Focus

* Implementing flight master detection via data files
* Stabilizing trigger logic using ordered evaluation (no priority system)
* Ensuring all states reliably trigger without conflicts
* Expanding detection coverage (NPCs, objects, etc.)

---

## ?? File Responsibilities

* Core.lua ? Main addon logic and orchestration
* Cursor.lua ? Cursor glow rendering and visuals
* Trigger.lua ? Detection logic and trigger evaluation (PRIMARY FOCUS)
* States.lua ? State definitions (no active priority system)
* Options.lua ? In-game configuration (Ace3 framework)
* Data/ ? Contains lookup tables for detection (Herbalism, Mining, NPCs, etc.)

---

## ?? Known Issues / Constraints

* Tooltip data is inconsistent depending on NPC/object type
* Tooltip fade behavior is controlled by Blizzard and **cannot be reliably overridden**
* Attempting to override tooltip anchoring or fade behavior causes:

  * Flickering
  * Tooltip desync
  * Broken detection
  * Stuck cursor glow states
* Tooltip parsing is limited primarily to line 1 (name)
* Some API functions available in Retail WoW are NOT available in TBC Classic

  * Do NOT assume Retail API availability

---

## ?? Architecture Rules (STRICT)

* Do NOT rewrite working systems unless absolutely required
* Preserve current file structure and module boundaries
* Implement new features incrementally and safely
* Avoid large refactors unless explicitly requested
* Prefer simple, stable solutions over complex systems

---

## ?? State System (Current Implementation)

* Uses **ordered evaluation (NOT priority-based)**
* First valid condition wins

### Current Evaluation Order

1. Herbalism
2. Mining
3. Flight Master (in progress)
4. Attack
5. Auto Loot
6. Loot
7. Default

### Notes

* Priority system was attempted but removed due to instability and debugging complexity
* May be reintroduced later once system is fully stable

---

## ?? Debug Notes

* Tooltip events can fire multiple times per frame
* Avoid relying on tooltip lifecycle for logic timing
* Use GameTooltipTextLeft1:GetText() for stable name retrieval
* Always ensure DEFAULT state is returned as fallback
* When debugging:

  * Print detected tooltip name
  * Print selected state
  * Verify trigger loop is running

---

## ?? Hard Rules for Code Generation

* Output FULL FILES or FULL FUNCTION BLOCKS only
* Do NOT output partial snippets
* Do NOT introduce new frameworks or dependencies
* Do NOT restructure modules
* Follow existing naming and file organization

---

## ?? Development Guidelines

* Prefer extending existing systems over replacing them
* Keep logic modular and contained within assigned files
* Validate each step in-game before continuing
* Maintain compatibility with WoW TBC Classic API only
* Avoid overengineering early systems (stability first)

---

## ?? Tooltip System Decision (IMPORTANT)

* Tooltip module has been removed due to engine limitations
* Fade behavior cannot be reliably overridden without side effects
* Hybrid anchoring (cursor + fixed) proved unstable
* Recommendation:

  ? Users should use mouse-anchored tooltips for best experience

* Future tooltip work should be approached cautiously and modularly

---

## ?? Future Considerations (Not Active Work)

* Reintroduce priority system (data-driven) once system is stable
* Expand NPC detection (vendors, trainers, quest givers, etc.)
* Improve gathering node coverage
* Multi-tooltip debugging tools (DaleBug integration)
* Performance optimization passes