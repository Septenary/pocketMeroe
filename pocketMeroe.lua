------------------------------------------------------------------------------------------------------------------------
--[[
License: GPLv3
main was made by meroe for <Serenity> - Mankrik.

Details!: Framework library (LGPLv3)
https://www.curseforge.com/wow/addons/libdframework Terciob,

Method Raid Tools
https://www.curseforge.com/wow/addons/method-raid-tools,
]]
------------------------------------------------------------------------------------------------------------------------
local _, PocketMeroe = ...
local version = "v0.0.10"
local config = {};

local main = {}
local mainFrame = CreateFrame("frame");

-- Details!: Framework
local DF = _G ["DetailsFramework"]

-- Ace3BasedConfigTable
local default_config = {
	profile = {
		use_mouseover = true,
		require_leader = true,
		global_unmarking = false,
		marking_modifier = {
			none = false,
			alt = false,
			ctrl = false,
			shift = true,
		},
		clear_modifier = {
			none = false,
			alt = true,
			ctrl = false,
			shift = false,
		},
		markersCustom = PocketMeroeData
		-- "focus", "focus2", "primary", "secondary", "sheep", "banish", "shackle", "fear",
		-- "rt8", "rt7", "rt6", "rt5", "rt4", "rt3", "rt2", "rt1"
	},
};


PocketMeroe = DF:CreateAddOn("main", "PocketMeroeDB", default_config)


local PocketMeroe_OnEvent = function(_, event, ...)
    local marks = PocketMeroe.marks
    if not marks then
        ChatFrame1:AddMessage("PocketMeroe.main: PocketMeroe.marks is not responding.")
        return
    end

    if event == "MODIFIER_STATE_CHANGED" then
        if marks.markersModifierChanged then
            marks.markersModifierChanged()
        end

        if UnitExists("mouseover") then
            GameTooltip:SetUnit("mouseover")
        end
    end

    -- Hook tooltip only once
    if not marks.tooltipHooked then
        marks.tooltipHooked = true

        local function OnTooltipSetUnit(tooltip)
            if marks.tooltipExtend then
                marks:tooltipExtend(tooltip)
            end
        end

        if TooltipDataProcessor then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
        else
            GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
        end
    end
end


local PocketMeroe_OnLoad = function (_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "pocketMeroe" then
		ChatFrame1:AddMessage	(" pocketMeroe by meroe - <Serenity> is loaded ");
		ChatFrame1:AddMessage	(" Remember kids, 'meroe' rhymes with '░░░░░' ");
		if PocketMeroeDB then
			if (PocketMeroe.db:GetCurrentProfile() ~= "Default") then
				PocketMeroe.db:SetProfile("Default")
			end
			PocketMeroe.db.RegisterCallback(main, "OnProfileChanged", "RefreshConfig")
		else
			ChatFrame1:AddMessage("PocketMeroe.main: PocketMeroeDB is not initialized.")
		end

        -- Setup slash commands
        local function HandleSlashCommands(str)
			if PocketMeroe and PocketMeroe.gui then
            	PocketMeroe.gui:MenuToggle()
			else
				ChatFrame1:AddMessage("PocketMeroe.main: PocketMeroe.gui is not initialized.")
			end
        end

		SlashCmdList["Meroe"] = HandleSlashCommands;
		SLASH_Meroe1 = "/meroe";
		SLASH_Meroe2 = "/MEROE";
		--SLASH_Kishibe1 = "/kishibe"
		--SlashCmdList.Kishibe = EasterEggKish;	

        -- Other initialization code
		local eventframe = CreateFrame("frame");
        eventframe:RegisterEvent("MODIFIER_STATE_CHANGED")
        eventframe:RegisterEvent("PLAYER_TARGET_CHANGED")
        eventframe:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
        eventframe:SetScript("OnEvent", PocketMeroe_OnEvent)
		if PocketMeroe and PocketMeroe.marks then
			PocketMeroe.marks.InitTooltipHooks()
			PocketMeroe.marks.InitMarkingSettings()
		else
			ChatFrame1:AddMessage("PocketMeroe.main: PocketMeroe.marks is not initialized.")
		end
	end
end
--[mobID] = {user-defined marks},priority,instanceShortcode,monster type, unitName

PocketMeroe.ResetProfileToDefaults = function()
	-- Deep copy defaults into profile
	PocketMeroe.db.profile = DF.table.copy({}, default_config.profile)

	-- Optionally refresh UI
	if meroe and meroe:IsShown() then
		meroe:Hide()
		gui.ShowMenu()
	end
end


PocketMeroe.ProfileSet = function(id, var, arg)
	if not PocketMeroeDB then
		error("PocketMeroe.lua: Database not loaded!", 2)
	end

	id = tonumber(id)
	if not id or id <= 0 then
		error("PocketMeroe.lua: mobID expects a valid mobID!", 2)
	end

	if arg == nil then
		error("PocketMeroe.lua: ProfileSet expects an argument!", 2)
	end

	-- Ensure markersCustom is initialized and pre-sized with 5 entries
	local markers = PocketMeroe.db.profile.markersCustom
	if not markers then
		markers = {}
		PocketMeroe.db.profile.markersCustom = markers
	end

	if type(markers[id]) ~= "table" then
		markers[id] = {}
	end

	for i = 1, 5 do
		if markers[id][i] == nil then
			markers[id][i] = (i == 1) and {} or nil
		end
	end

	local functionMapping = {
		customMarks = function(arg)
			if type(arg) ~= "table" then
				error("PocketMeroe.lua: ProfileSet(\"customMarks\") expects a table!", 2)
			end
			markers[id][1] = arg
		end,

		priority = function(arg)
			markers[id][2] = tonumber(arg)
		end,

		instanceShortcode = function(arg)
			markers[id][3] = tostring(arg)
		end,

		monsterType = function(arg)
			markers[id][4] = tostring(arg)
		end,

		unitName = function(arg)
			markers[id][5] = tostring(arg)
		end,
	}

	local func = functionMapping[var]
	if func then
		func(arg)
	else
		error("PocketMeroe.lua: ProfileSet(\"" .. tostring(var) .. "\") is not a recognized key", 2)
	end
end


PocketMeroe.ProfileGet = function (id, var)
	if not PocketMeroeDB then
		print("PocketMeroe.lua: Database not loaded! Stopping!")
		return
	end

	id = tonumber(id)
    if not id or id <= 0 then
        error("PocketMeroe.lua: mobID expects a mobID!")
        return
    end


    -- Ensure markersCustom is properly initialized
    if not PocketMeroe.db.profile.markersCustom then
        PocketMeroe.db.profile.markersCustom = {}
		print("PocketMeroe.lua: Database dumped!")
    end
    if not PocketMeroe.db.profile.markersCustom[id] then
		print("PocketMeroe.lua: Database error!")
        PocketMeroe.db.profile.markersCustom[id] = { {}, 0, "", "", "" } -- reasonable defaults
    end


	local functionMapping = {
		customMarks = function()
			return PocketMeroe.db.profile.markersCustom[id][1]
		end,
		priority = function()
			return PocketMeroe.db.profile.markersCustom[id][2]
		end,
		instanceShortcode = function()
			return PocketMeroe.db.profile.markersCustom[id][3]
		end,
		monsterType = function ()
			return PocketMeroe.db.profile.markersCustom[id][4]
		end,
		unitName = function ()
			return PocketMeroe.db.profile.markersCustom[id][5]
		end,
	}

	local func = functionMapping[var]
    if func then
        return func()
    else
		print("PocketMeroe.lua: ProfileGet("..tostring(var)..") not found!")
    end

end

PocketMeroe.ProfileClear = function (id, var) -- right now it just nukes your profile to corruption. it should be per unit
	if not PocketMeroeDB then
		print("PocketMeroe.lua: Database not loaded! Stopping!")
		return
	end

	id = tonumber(id)
    if not id or id <= 0 then
        error("PocketMeroe.lua: mobID expects a mobID!")
        return
    end


    -- Reset markers custom to my defaults
    PocketMeroe.db.profile.markersCustom = PocketMeroeData

    if not PocketMeroe.db.profile.markersCustom[id] then
		print("PocketMeroe.lua: Database error!")
        PocketMeroe.db.profile.markersCustom[id] = { {}, 0, "", "", "" } -- reasonable defaults
    end

end

function main.OnInit()
end

function main:RefreshConfig()
	--
end

mainFrame:RegisterEvent("ADDON_LOADED");
mainFrame:SetScript("OnEvent", PocketMeroe_OnLoad);

PocketMeroe.main = main
_G["PocketMeroe"] = PocketMeroe