------ Auto-Marking ----------------------------------------------------------------------------------------------------
-- thank you https://wago.io/p/Forsaken for good auto-marking code
------------------------------------------------------------------------------------------------------------------------
---@class Marks
local Marks = {}
Marks.__index = Marks

--Initilization
function Marks:new()
	local o = {
		markersUsed = {},
		markersUsedPriority = {},
		markersUsedByGUID = {},
		markersUsedReset = GetTime() + 2,
		markersModifierIsPressed = false,
		clearModifierIsPressed = false,
		tooltipHooked = false,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Marks:InitMarkingSettings()
	local config = PocketMeroe.db.profile
	local ClearModifier = config.clear_modifier
	local MarkingModifier = config.marking_modifier
	
	if not PocketMeroeDB then
		print("PocketMeroe.marks.InitMarking: Database not loaded! Stopping!")
		return
	end
end

function Marks:tooltipExtend(tooltip)
	if not tooltip then return end
	local unitName, unitId = tooltip:GetUnit()
	if not unitId or not UnitExists(unitId) then return end

	local guid = UnitGUID(unitId)
	if not guid then return end

	local _, _, _, _, _, npc_id = strsplit("-", guid)
	npc_id = tonumber(npc_id)
	if not npc_id then return end

	local npcInfo = PocketMeroe.db.profile.markersCustom[npc_id]
	if not npcInfo then return end

	tooltip:SetWidth(math.min(tooltip:GetWidth(), 700))

	if not self:AreMarkersEnabled() then return end

	if self.clearModifierIsPressed then
		self:RemoveMarkersFromUnit(unitId)
		return
	end

	local markerType, markerBias = self:GetMarkerTypeForNpc(npc_id, unitName)
	if markerType then
		self:SetMarkerForUnit(unitId, markerType, markerBias)
	end
end

function Marks:InitTooltipHooks()
	if not PocketMeroeDB then
		print("PocketMeroe.marks.new: Database not loaded! Stopping!")
		return
	end

	if not Marks.tooltipHooked then
		Marks.tooltipHooked = true

		if TooltipDataProcessor then
			TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltipData)
				if not GameTooltip then return end
				Marks:tooltipExtend(GameTooltip)
			end)
		else
			GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
				Marks:tooltipExtend(tooltip)
			end)
		end
	end
end


-- Marker activation checks
function Marks:AreMarkersEnabled()
	local config = PocketMeroe.db.profile

	if not config.use_mouseover then return false end
	if not MarkingModifier then return false end
	if config.require_leader and not UnitIsGroupLeader("player") then return false end
	if (IsAltKeyDown() and (ClearModifier.alt or MarkingModifier.alt))
		or (IsControlKeyDown() and (ClearModifier.ctrl or MarkingModifier.ctrl))
		or (IsShiftKeyDown() and (ClearModifier.shift or MarkingModifier.shift)) then
		return true
	end
	return false
end

function Marks:isClearModifierPressed()
	local config = PocketMeroe.db.profile
	local clear = config.clear_modifier
	if not config.use_mouseover then return false end

	return (ClearModifier.alt and IsAltKeyDown())
	    or (ClearModifier.ctrl and IsControlKeyDown())
	    or (ClearModifier.shift and IsShiftKeyDown())
end

--Modifier key state
function Marks:OnMarkersModifierPressed()
	if self.markersModifierIsPressed then return end
	self.markersModifierIsPressed = true
	self:ClearUsedMarkers()
	self.markersUsedReset = GetTime() + 10
end

function Marks:OnMarkersModifierReleased()
	if not self.markersModifierIsPressed then return end
	self.markersModifierIsPressed = false
	self.markersUsedReset = GetTime()
end

--Marker Usage
function Marks:AddMarkerUsed(unitId, index, priority)
	index = index or GetRaidTargetIndex(unitId)
	if not index then return end

	if not priority then
		local markerType = self:GetMarkerTypeForUnit(unitId)
		priority = self.markersUsedPriority[index] or self:GetMarkerPriority(markerType)
	end

	for guid, i in pairs(self.markersUsedByGUID) do
		if i == index then
			self.markersUsedByGUID[guid] = nil
		end
	end

	if index then
		local guid = UnitGUID(unitId)
		self.markersUsed[index] = true
		self.markersUsedPriority[index] = priority
		if guid then
			self.markersUsedByGUID[guid] = index
		end
	end
end

function Marks:ClearUsedMarkers()
	for i = 1, 8 do
		self.markersUsed[i] = false
		self.markersUsedPriority[i] = nil
	end
	wipe(self.markersUsedByGUID)
end

function Marks:GetUsedMarkers()
	if self.markersUsedReset < GetTime() then
		self:ClearUsedMarkers()
	end
	self.markersUsedReset = math.max(self.markersUsedReset, GetTime() + 2)

	self:AddMarkerUsed("target")
	for i = 1, 40 do
		self:AddMarkerUsed("nameplate" .. i)
	end
	return self.markersUsed
end

-- Marker selection
function Marks:FindFreeMarkerIndex(markerType, priority, markerCurrent)
	local config = PocketMeroe.db.profile
	if not config.markersCustom then return false end

	if type(markerType) == "table" then
		local markerIndex, markerPriority = nil, 0
		for _, t in ipairs(markerType) do
			local p = self:GetMarkerPriority(t)
			if not markerIndex or p > markerPriority then
				local try = self:FindFreeMarkerIndex(t, priority, markerCurrent)
				if try then
					markerIndex, markerPriority = try, p
				end
			end
		end
		return markerIndex
	end

	local i = tonumber(markerType)
	if i then
		if markerCurrent and i < markerCurrent then return markerCurrent end
		if not self.markersUsed[i] then return i end
		if self.markersUsedPriority[i] and self.markersUsedPriority[i] < priority then return i end
	end

	if not config.markersCustom[markerType] then return nil end

	for i = 1, 8 do
		if markerCurrent and i < markerCurrent then return markerCurrent end
		if config.markersCustom[markerType][i] then
			if not self.markersUsed[i] or (self.markersUsedPriority[i] and self.markersUsedPriority[i] < priority) then
				return i
			end
		end
	end

	return nil
end

function Marks:GetMarkerPriority(markerType)
	if type(markerType) == "table" then
		local best = -math.huge
		for _, t in ipairs(markerType) do
			best = math.max(best, self:GetMarkerPriority(t))
		end
		return best
	end
	return markerType or 0
end

function Marks:GetMarkerTypeForNpc(npcId, npcName)
	local config = PocketMeroe.db.profile
	local markersCustom = config.markersCustom
	npcId = tonumber(npcId)
	if not npcId then return nil end

	for id, _ in pairs(markersCustom) do
		if id == npcId then
			local raidIcons = markersCustom[id][1]
			local bias = markersCustom[id].markerBias or 0.0
			return raidIcons, bias
		end
	end

	print("NPC with ID", npcId, "not found in markersCustom")
	return nil
end

function Marks:GetMarkerTypeForUnit(unitId)
	if UnitExists(unitId) then
		local guid = UnitGUID(unitId)
		local name = UnitName(unitId)
		if guid and name then
			local _, _, _, _, _, npc_id = strsplit("-", guid)
			return self:GetMarkerTypeForNpc(npc_id, name)
		end
	end
	return nil
end

-- Marker Clearing
function Marks:ClearMarkerIndex(index)
	if index then
		self.markersUsed[index] = false
		self.markersUsedPriority[index] = nil
	end
end

function Marks:ClearMarkersForUnit(unitId)
	local guid = UnitGUID(unitId)
	if guid and self.markersUsedByGUID[guid] then
		self:ClearMarkerIndex(self.markersUsedByGUID[guid])
		self.markersUsedByGUID[guid] = nil
	end
	local index = GetRaidTargetIndex(unitId)
	self:ClearMarkerIndex(index)
end

--Marker assignment and removal
function Marks:SetMarkerForUnit(unitId, markerType, markerBias)
	self:GetUsedMarkers()
	local priority = self:GetMarkerPriority(markerType) + (markerBias or 0.0)
	local markerCurrent = GetRaidTargetIndex(unitId)
	local markerIndex = self:FindFreeMarkerIndex(markerType, priority, markerCurrent)
	if markerIndex and markerIndex ~= markerCurrent then
		self:ClearMarkersForUnit(unitId)
		SetRaidTarget(unitId, markerIndex)
		self:AddMarkerUsed(unitId, markerIndex, priority)
	end
end

function Marks:RemoveMarkersFromUnit(unitId)
	self:ClearMarkersForUnit(unitId)
	SetRaidTarget(unitId, 0)
end

-- Debug
function Marks:DebugPrintNpcData()
	for id, data in pairs(PocketMeroe.db.profile.markersCustom) do
		local raidIcons = data[1]
		local debugIcons = ""
		for _, marker in ipairs(raidIcons) do
			debugIcons = debugIcons .. "{rt" .. marker .. "}"
		end
		-- print(id, debugIcons) -- enable for debugging
	end
end

function Marks:DebugPrintMarkerUsage()
    print("=== Marker Usage ===")
    for i = 1, 8 do
        local used = self.markersUsed[i]
        local priority = self.markersUsedPriority[i]
        local ownerGUID = nil
        for guid, idx in pairs(self.markersUsedByGUID) do
            if idx == i then
                ownerGUID = guid
                break
            end
        end
        if used then
            print(string.format("Marker %d: Used = true, Priority = %s, Owned by GUID = %s", i, tostring(priority), tostring(ownerGUID)))
        else
            print(string.format("Marker %d: Used = false", i))
        end
    end
end

function Marks:DebugCheckUnitMarker(unitId)
    if not UnitExists(unitId) then
        print("Unit", unitId, "does not exist.")
        return
    end

    local currentMarker = GetRaidTargetIndex(unitId)
    local guid = UnitGUID(unitId)
    local name = UnitName(unitId)
    local markerType, markerBias = self:markersGetTypeForUnit(unitId)
    local priority = self:markersGetPriority(markerType) + (markerBias or 0)

    print(string.format("Unit: %s (%s)", name or "unknown", unitId))
    print("GUID:", guid)
    print("Current Marker:", currentMarker)
    print("Calculated Marker Type:", markerType and table.concat(type(markerType)=="table" and markerType or {markerType}, ", ") or "none")
    print("Calculated Priority:", priority)
end

function Marks:DebugPrintModifierStates()
    print("Modifier keys state:")
    print("Alt:", IsAltKeyDown() and "DOWN" or "UP")
    print("Ctrl:", IsControlKeyDown() and "DOWN" or "UP")
    print("Shift:", IsShiftKeyDown() and "DOWN" or "UP")
    print("Clear Modifier Pressed:", tostring(self.clearModifierIsPressed))
    print("Markers Modifier Pressed:", tostring(self.markersModifierIsPressed))
end

local marks = Marks:new()
PocketMeroe.marks = marks