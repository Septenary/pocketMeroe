------ Auto-Marking ----------------------------------------------------------------------------------------------------
-- thank you https://wago.io/p/Forsaken for good auto-marking code
------------------------------------------------------------------------------------------------------------------------
local marks = {}
local DF = _G["DetailsFramework"]
-- markerBias makes a specific mob a higher priority to mark.


function marks.InitTooltips ()
	if not PocketMeroeDB then
		print("PocketMeroe.marks.InitTooltips: Database not loaded! Stopping!")
		return
	end
	local npcData = PocketMeroe.db.profile.markersCustom

	function marks.tooltipExtend(tooltip)
		local unitName, unitId = GameTooltip:GetUnit()
		if unitId and UnitExists(unitId) then
			local guid = UnitGUID(unitId)
            if not guid then return end
			local type, _, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid)
			local npcInfo = PocketMeroe.db.profile.markersCustom[tonumber(npc_id)]
			if (npcInfo ~= nil) then
				--print(npcInfo)
--[[ 				if (npcInfo.untauntable) then
					local ttIcon = "|T136122:0|t"
					--GameTooltip:AddLine(ttIcon.." |cFFC41E3A! Untauntable !|r "..ttIcon)
				end ]]
				-- tooltip:Show();
				if (GameTooltip:GetWidth() > 700) then
					GameTooltip:SetWidth(700)
				end
				if marks.markersEnabled() then
					if marks.clearModifierIsPressed then
						marks.markersRemoveUnit(unitId)
						return
					end
					local markerType, markerBias = marks.markersGetTypeForNpc(npc_id, unitName)
					if (markerType ~= nil) then
						--print("Trying to mark ", npc_id)
						marks.markersSetUnit(unitId, markerType, markerBias)
					end
				end
			end
			-- lets enable global unmarking just for fun :)
			if marks.markersEnabled() then
				--print("NPC with ID", npc_id, "not found in markersCustom")
				if marks.clearModifierIsPressed then
					marks.markersRemoveUnit(unitId)
					return
				end
			end
		end
	end
end

function marks.SpamNpcData ()
	for id in pairs(PocketMeroe.db.profile.markersCustom) do
		local raidIcons, priority, zone, sortCategory, name = unpack(PocketMeroe.db.profile.markersCustom[id])
		-- lets not invest in debug code too greatly
		local debugIcons = ""
		for _, marker in ipairs(raidIcons) do
			debugIcons = debugIcons .. "{rt" .. marker .. "}"
		end
		-- print("NPC Details: ", id)
		-- print("  Name:",       name)
		-- print("  Zone:",       zone, sortCategory)
		-- print("  Priority:",   priority)
		-- print("  Raid Icons:", debugIcons)
	end
end
--[[
	TODO: Broadcast some of this to party/raid members.
]]

function marks.InitMarking ()
	if not PocketMeroeDB then
		print("PocketMeroe.marks.InitMarking: Database not loaded! Stopping!")
		return
	end
	local Config = PocketMeroe.db.profile
	local ClearModifier = Config.clear_modifier
	local MarkingModifier = Config.marking_modifier

	marks.markersUsed = marks.markersUsed or {}
	marks.markersUsedPriority = marks.markersUsedPriority or {}
	marks.markersUsedByGUID = marks.markersUsedByGUID or {}
	marks.markersUsedReset = GetTime() + 2
	marks.markersModifierIsPressed = false
	marks.clearModifierIsPressed = false

	-- PocketMeroeFrame_OnEvent
	-- MODIFIER_STATE_CHANGED -> markersModifierChanged()
	--   markersModifierPressed() OR markersModifierReleased() -- continue OR wait
	--     markersClearUsed()
	-- 
	-- MODIFIER_STATE_CHANGED, PLAYER_TARGET_CHANGED, UPDATE_MOUSEOVER_UNIT
	-- tooltipExtend() -- forced
	--   markersEnabled()
	--     markersRemoveUnit OR markersGetTypeForNpc -- break or continue
	--   markersGetTypeForNpc()
	--     -- more details below


	-- markerType

	-- check GUI options and keyboard state
	marks.markersEnabled = function()
		if not Config.use_mouseover then
			return false
		end
		if not MarkingModifier then
			return false
		end
		if (Config.require_leader and not UnitIsGroupLeader("player")) then
			-- doesn't do marking if not player lead and "not lead" is toggled in custom options
			return false
		end
		if (IsAltKeyDown() and (ClearModifier.alt or MarkingModifier.alt))
		or (IsControlKeyDown() and (ClearModifier.ctrl or MarkingModifier.ctrl))
		or (IsShiftKeyDown() and (ClearModifier.shift or MarkingModifier.shift)) then
			return true
		end
		return false
	end

	-- check specifics for Clearing or Marking
	marks.markersModifierChanged = function()
		if ClearModifier ~= nil and Config.use_mouseover then
			if (ClearModifier.alt and IsAltKeyDown())
			or (ClearModifier.ctrl and IsControlKeyDown())
			or (ClearModifier.shift and IsShiftKeyDown()) then
				marks.clearModifierIsPressed = true
			elseif (marks.markersModifierPressed) then
				marks.clearModifierIsPressed = false
			end
			return -- Blocks a unit from repeatedly being marked and unmarked quickly.
		end
		if MarkingModifier ~= nil and Config.use_mouseover then
			if (MarkingModifier.alt and IsAltKeyDown())
			or (MarkingModifier.ctrl and IsControlKeyDown())
			or (MarkingModifier.shift and IsShiftKeyDown()) then
				marks.clearModifierIsPressed = true
			end
			if marks.clearModifierIsPressed then
				marks.markersModifierReleased()
			end
		end
	end

	-- Pressed and Released introduce a delay for chain-marking mobs.
	marks.markersModifierPressed = function()
		if marks.markersModifierIsPressed then
			return -- Was already pressed before
		end
		marks.markersModifierIsPressed = true
		marks.markersClearUsed()
		marks.markersUsedReset = GetTime() + 10.0
	end
	marks.markersModifierReleased = function()
		if not marks.markersModifierIsPressed then
			return -- Was already released before
		end
		marks.markersModifierIsPressed = false
		marks.markersUsedReset = GetTime()
	end
	-- Add unit's marker to list of used markers        
	marks.markersAddToUsed = function(unitId, index, priority)
		if not index then
			index = GetRaidTargetIndex(unitId)
		end

		if not priority then
			local markerType = marks.markersGetTypeForUnit(unitId)
			priority = marks.markersUsedPriority[index] or marks.markersGetPriority(markerType)
		end
		for guid, i in pairs(marks.markersUsedByGUID) do
			if (i == index) then
				marks.markersUsedByGUID[guid] = nil
			end
		end
		if index then
			local guid = UnitGUID(unitId)
			marks.markersUsed[index] = true
			marks.markersUsedPriority[index] = priority
			if guid then
				marks.markersUsedByGUID[guid] = index
			end
	--[[ 			
		TODO: markersUsedByGUID would be shared as it updates to other players in the raid
	]]
			-- print(guid, "+", index)
		end
	end
	-- Get list of all currently used markers
	marks.markersClearUsed = function()
		for i = 1, 8 do
			marks.markersUsed[i] = false
			marks.markersUsedPriority[i] = nil
		end
		wipe(marks.markersUsedByGUID)
	end
	-- Get list of all currently used markers
	marks.markersGetUsed = function()
		-- Reset state
		if marks.markersUsedReset < GetTime() then
			marks.markersClearUsed()
		end
		marks.markersUsedReset = max(marks.markersUsedReset, GetTime() + 2.0)
		-- Don't use marks already used on the players target
		marks.markersAddToUsed("target")
		-- Don't use marks already used on party member or their targets
		-- for partyMember in WA_IterateGroupMembers(false, true) do
		--     marks.markersAddToUsed(aura, partyMember)
		--     marks.markersAddToUsed(aura, partyMember.."target")     
		-- end
		-- Don't use marks already used on boss1-4
		-- for i = 1, 4 do
		-- 	marks.markersAddToUsed("boss"..i)
		-- end
		-- Don't use marks already used on nameplates
		for i = 1, 40 do
			marks.markersAddToUsed("nameplate"..i)
		end
		return marks.markersUsed
	end
	-- Get free marker index for the given type
	marks.markersGetFreeIndex = function(markerType, priority, markerCurrent)
		if (type(markerType) == "table") then
			-- Get the highest priority marker from a list of marker types
			local markerIndex = nil
			local markerPriority = 0
			for _, t in ipairs(markerType) do
				local p = marks.markersGetPriority(t)
				if not markerIndex and (p > markerPriority) then
					markerIndex = marks.markersGetFreeIndex(t, priority, markerCurrent)
					if (markerIndex ~= nil) then
						markerPriority = p
					end
				end
			end
			return markerIndex
		end

		-- Pre-defined exact markers, "rt1-8"
		if markerType ~= nil then
			local i = tonumber(markerType)
			if markerCurrent and (i < markerCurrent) then
				return markerCurrent
			end
			--print("markerExact:", markerExact)
			--print("markersUsedPriority[", i, "]:", marks.markersUsedPriority[i])
			--print(i, "?", marks.markersUsed[i] or false, marks.markersUsedPriority[i] or 0, "vs", priority)
			if not marks.markersUsed[i] then
				return i
			end
			if (marks.markersUsedPriority[i] ~= nil) and (marks.markersUsedPriority[i] < priority) then
				return i
			end
			--return nil
		end
		
		-- Get the first available marker from the given type
		if not markerType or not Config.markersCustom[markerType] then
			return nil
		end

		for i = 1, 8 do
			if markerCurrent and (i < markerCurrent) then
				return markerCurrent
			end
			local s = tostring(i)
			--print("markerType:", markerType)
			--print("markersUsedPriority[", i, "]:", marks.markersUsedPriority[i])
			--print("mt", Config.markersCustom[markerType], "s", Config.markersCustom[markerType][s])
			if Config.markersCustom[markerType][i] then
				print(i, "?", marks.markersUsed[i] or false, marks.markersUsedPriority[i] or 0, "vs", priority)
				if not marks.markersUsed[i] then
					return i
				end
				if (marks.markersUsedPriority[i] ~= nil) and (marks.markersUsedPriority[i] < priority) then
					return i
				end
			end
		end
		return nil
	end

	-- Recursively search for an appropriate priority. allows for layering with marks
	marks.markersGetPriority = function(markerType)
		if type(markerType) == "table" then
			-- Get the maximum priority from a list of marker types
			local priority = -math.huge  -- Start with the lowest possible value
			for _, t in ipairs(markerType) do
				local tPriority = marks.markersGetPriority(t)
				priority = math.max(tPriority, priority)
			end
			return priority
		end
		
		-- Handle the case where markerType is not a table
		-- This should be adjusted based on how you want to handle non-table inputs
		return markerType  -- Assuming markerType is a numeric value indicating priority
	end

	-- gets some string of marks that should be used. 
	-- defaults to {8,7,6,5,4,3,2,1} if mob is in markersCustom
	marks.markersGetTypeForNpc = function(npcId, npcName)
		-- Overrides via custom options
		local markersCustom = Config.markersCustom
		npcId = tonumber(npcId)
		if npcId then
			for id, _ in pairs (markersCustom) do
				local raidIcons, priority, zone, sortCategory, name = unpack(markersCustom[id])
				if  (id == npcId) then
					local debugIcons = ""
					for _, marker in ipairs(raidIcons) do
						debugIcons = debugIcons .. "{rt" .. marker .. "}"
					end
					-- print("NPC Details: ", id)
					-- print("  Name:",       name)
					-- print("  Zone:",       zone, sortCategory)
					-- print("  Priority:",   priority)
					-- print("  Raid Icons:", debugIcons)
					return raidIcons, (markersCustom[npcId].markerBias or 0.0)
				--else
					--wipe(npcData[npcId].markerType)
				--end
			end
		end
		-- fill in default mob data
		print("NPC with ID", npcId, "not found in markersCustom")
		if markersCustom[npcId] and markersCustom[npcId][2] then
			if (markersCustom[npcId].markerType == {}) then
				markersCustom[npcId][1] = {8,7,6,5,4,3,2,1}
			end
			return markersCustom[npcId].markerType, (markersCustom[npcId].markerBias or 0.0)
		end
			return nil -- mob data never existed
		end
	end

	-- markersGetTypeForNpc for a Unit
	marks.markersGetTypeForUnit = function(unitId)
		if UnitExists(unitId) then
			local guid = UnitGUID(unitId);
			local name = UnitName(unitId);
			if guid and name then
				local type, _, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
				return marks.markersGetTypeForNpc(npc_id, name)
			end
		end
		return nil
	end

	-- clear mark from attributes
	marks.markersClearIndex = function(index)
		if index then
			marks.markersUsed[index] = false
			marks.markersUsedPriority[index] = nil
		end
	end

	-- clear mark on a Unit from attributes
	marks.markersClearUnit = function(unitId)
		local guid = UnitGUID(unitId)
		if guid and marks.markersUsedByGUID[guid] then
			--print(guid, "-", marks.markersUsedByGUID[guid])
			marks.markersClearIndex(marks.markersUsedByGUID[guid])
			marks.markersUsedByGUID[guid] = nil
		end
		local index = GetRaidTargetIndex(unitId)
		marks.markersClearIndex(index)
	end
	-- Set marker type for unit
	marks.markersSetUnit = function(unitId, markerType, markerBias)
		marks.markersGetUsed()
		--print(marks.markersGetPriority(markerType), " + ", (markerBias or 0.0))
		--print("Unit:", unitId)
		--print("Marker Type:", markerType, type(markerType))
		--print("Marker Bias:", markerBias)
		local priority = marks.markersGetPriority(markerType) + (markerBias or 0.0)
		local markerCurrent = GetRaidTargetIndex(unitId)
		local markerIndex = marks.markersGetFreeIndex(markerType, priority, markerCurrent)
		-- print("Priority:", priority)
		-- print("Current Marker Index:", markerCurrent)
		-- print("Marker Index:", markerIndex)
		if (markerIndex ~= nil) and (markerIndex ~= markerCurrent) then
			--print("Trying to put {rt",markerIndex,"} on rt{",markerCurrent,"}",unitId)
			marks.markersClearUnit(unitId)
			SetRaidTarget(unitId, markerIndex)
			marks.markersAddToUsed(unitId, markerIndex, priority)
		end
	end
	-- Remove raid marker for unit
	marks.markersRemoveUnit = function(unitId)
		marks.markersClearUnit(unitId)
		SetRaidTarget(unitId, 0)
	end


	-- markersSetUnit
	--   markersGetUsed() -> markersClearUsed() OR markersAddToUsed()
	--     markersGetTypeForUnit  -- set attributes
	--   markersGetPriority()     -- search priority, should always use table method
	--     markersGetPriority
	--   markersGetFreeIndex()    -- search mark to use, based on priority
	--     markersGetPriority -> markersGetFreeIndex
	--   markersClearUnit() OR succeed + markersAddToUsed()
end

PocketMeroe.marks = marks
