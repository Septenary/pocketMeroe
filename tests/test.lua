-- test.lua

-- MOCK WoW global environment and APIs

PocketMeroe = {
    db = {
      profile = {
        use_mouseover = true,
        require_leader = false,
        marking_modifier = { alt = true, ctrl = false, shift = false },
        clear_modifier   = { alt = false, ctrl = false, shift = true },
        markersCustom = {
            [1706]  = {{8,7,6,5,4,3,2,1},9,"none", "Boss", "AA"},
            [16021] = {{8,1},1,"NAXX", "Trash", "Living Monstrosity"},
            [16020] = {{7,6,5,4,3,2},1,"NAXX", "Trash", "Mad Scientist"},
            [16447] = {{8,7,6,5},3,"NAXX", "Trash", "Plagued Ghoul"},
        }
      }
    }
  }
  
  local keyState = { alt = false, ctrl = false, shift = false }
  
  function UnitIsGroupLeader(unit)
    return unit == "player" and true
  end
  
  function IsAltKeyDown() return keyState.alt end
  function IsControlKeyDown() return keyState.ctrl end
  function IsShiftKeyDown() return keyState.shift end
  
  local raidTargets = {}
  
  function GetRaidTargetIndex(unitId)
    return raidTargets[unitId] or 0
  end
  
  function SetRaidTarget(unitId, index)
    raidTargets[unitId] = index
    print(string.format("SetRaidTarget called: unit=%s index=%d", unitId, index))
  end
  
  function UnitExists(unit) return true end -- simplify, all exist in test
  function UnitGUID(unit) return unit end -- we'll fake guid as unit for simplicity
  function UnitName(unit) return "UnitName"..unit end
  
  local GameTooltip = {}
  
  function GameTooltip:GetUnit()
    return "UnitName", self.unit or "mouseover"
  end
  
  function GameTooltip:SetWidth(w)
    -- No-op or print for debug
    -- print("[GameTooltip] SetWidth called with", w)
  end
  
  function GameTooltip:GetWidth()
    return 800
  end
  
  function GameTooltip:SetUnit(unit)
    -- No-op or print
    -- print("[GameTooltip] SetUnit called for", unit)
  end
  
  function strsplit(sep, str)
    local fields = {}
    for field in string.gmatch(str, "([^"..sep.."]+)") do
      table.insert(fields, field)
    end
    return table.unpack(fields)
  end
  
  local Marks = {}
  
  function Marks:markersEnabled()
    local config = PocketMeroe.db.profile
    local mark = config.marking_modifier
    local clear = config.clear_modifier
  
    if not config.use_mouseover then return false end
    if not mark then return false end
    if config.require_leader and not UnitIsGroupLeader("player") then return false end
  
    if (IsAltKeyDown() and (clear.alt or mark.alt))
      or (IsControlKeyDown() and (clear.ctrl or mark.ctrl))
      or (IsShiftKeyDown() and (clear.shift or mark.shift)) then
      return true
    end
    return false
  end
  
  function Marks:markersRemoveUnit(unitId)
    raidTargets[unitId] = 0
    print("markersRemoveUnit: Cleared marker for", unitId)
  end
  
  function Marks:markersGetTypeForNpc(npcId, npcName)
    local cfg = PocketMeroe.db.profile.markersCustom
    npcId = tonumber(npcId)
    if npcId and cfg[npcId] then
      return cfg[npcId][1], 0.0
    end
    return nil, 0.0
  end
  
  function Marks:markersSetUnit(unitId, markerType, markerBias)
    local markerCurrent = GetRaidTargetIndex(unitId)
    local markerIndex = nil
  
    if type(markerType) == "table" then
      markerIndex = markerType[1]
    else
      markerIndex = markerType
    end
  
    if markerIndex ~= nil and markerIndex ~= markerCurrent then
      self:markersRemoveUnit(unitId)
      SetRaidTarget(unitId, markerIndex)
    else
      print(string.format("No change needed for %s (current marker %d)", unitId, markerCurrent))
    end
  end
  
  function Marks:tooltipExtend(tooltip)
    local unitName, unitId = tooltip:GetUnit()
    if not unitId or not UnitExists(unitId) then return end
  
    local guid = UnitGUID(unitId)
    if not guid then return end
  
    -- Simulate WoW GUID structure for testing:
    -- format: "Creature-0-0-0-0-npc_id-uniqueid"
    -- Here unitId is npc_id for test convenience
    local npc_id = tonumber(unitId)
    if not npc_id then return end
  
    local npcInfo = PocketMeroe.db.profile.markersCustom[npc_id]
    if not npcInfo then return end
  
    tooltip:SetWidth(math.min(tooltip:GetWidth(), 700))
  
    if not self:markersEnabled() then
      print("Markers not enabled for", npc_id)
      return
    end
  
    if self.clearModifierIsPressed then
      self:markersRemoveUnit(unitId)
      return
    end
  
    local markerType, markerBias = self:markersGetTypeForNpc(npc_id, unitName)
    if markerType then
      print("Setting marker for NPC ID", npc_id)
      self:markersSetUnit(unitId, markerType, markerBias)
    else
      print("No marker type found for NPC ID", npc_id)
    end
  end
  
  PocketMeroe.marks = Marks
  
  local function testAllMobs()
    print("=== Test all mobs from markersCustom ===")
  
    Marks.clearModifierIsPressed = false
    keyState.alt = true -- simulate modifier pressed to enable marking
  
    local tooltip = GameTooltip
  
    for npcId, _ in pairs(PocketMeroe.db.profile.markersCustom) do
      print("\nTesting NPC ID:", npcId)
      tooltip.unit = tostring(npcId) -- set current unit id for tooltip mock
      Marks:tooltipExtend(tooltip)
    end
  end
  
  testAllMobs()
