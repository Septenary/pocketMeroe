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
local version = "v0.0.6"
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
		markersCustom = { -- [mobID] = {user-defined marks},priority,instanceShortcode,monster type, unitName
		[1706]  = {{1, 2, 3, 4, 5, 6, 7, 8},9,"none", "Boss", "AA"},
		[1707]  = {{1, 2, 3, 4, 5, 6, 7, 8},9,"none", "Boss", "AA"},
		[1708]  = {{1, 2, 3, 4, 5, 6, 7, 8},9,"none", "Boss", "AA"},
		[3501]  = {{1, 2, 3, 4, 5, 6, 7, 8},9,"none", "Boss", "AA"},
		[14750] = {{},1,"ZG", "Trash", "Gurubashi Bat Rider"},
		[14883] = {{},1,"ZG", "Trash", "Voodoo Slave"},
		[11830] = {{},1,"ZG", "Trash", "Hakkari Priest"},
		[11353] = {{},1,"ZG", "Trash", "Gurubashi Blood Drinker"},
		[11671] = {{},1,"MC", "Trash", "Core Hound"},
		[12076] = {{},1,"MC", "Trash", "Lava Elemental"},
		[12100] = {{},1,"MC", "Trash", "Lava Reaver"},
		[11659] = {{1, 2, 3, 4, 5, 6, 7, 8},1,"MC", "Trash", "Molten Destroyer"},
		[12118] = {{5},1,"MC", "Boss", "Lucifron"},
		[12119] = {{8,7},1,"MC", "Ads", "Flamewaker Protector"},
		[11982] = {{},1,"MC", "Boss", "Magmadar"},
		[12099] = {{},1,"MC", "Boss", "Garr"},
		[12056] = {{},1,"MC", "Trash", "Firesworn"},
		[12264] = {{},1,"MC", "Boss", "Baron Geddon"},
		[11988] = {{},1,"MC", "Boss", "Shazzrah"},
		[11672] = {{},1,"MC", "Trash", "Core Rager"},
		[11662] = {{},1,"MC", "Trash", "Flamewaker Priest"},
		[11663] = {{},1,"MC", "Trash", "Flamewaker Healer"},
		[12468] = {{1, 2, 3, 4, 5, 6, 7, 8},2,"BWL", "Trash", "Death Talon Hatcher"},
		[12458] = {{1, 2, 3},1,"BWL", "Trash", "Blackwing Taskmaster"},
		[12459] = {{},1,"BWL", "Trash", "Blackwing Warlock"},
		[12457] = {{},1,"BWL", "Trash", "Blackwing Spellbinder"},
		[12467] = {{1},1,"BWL", "Trash", "Death Talon Captain"},
		[12463] = {{8, 7},1,"BWL", "Trash", "Death Talon Flamescale"},
		[12464] = {{6, 5},1,"BWL", "Trash", "Death Talon Seether"},
		[12465] = {{4, 3},1,"BWL", "Trash", "Death Talon Wyrmkin"},
		[12420] = {{1, 2, 3, 4, 5, 6, 7, 8},1,"BWL", "Ads", "Blackwing Mage"},
		[15391] = {{1, 2, 3, 4, 5, 6, 7, 8},1,"AQ20", "Ads", "Buru Egg"},
		[15392] = {{1},1,"AQ20", "Ads", "Captian Qeez"},
		[15389] = {{2},1,"AQ20", "Ads", "Captian Tuubid"},
		[15390] = {{3},1,"AQ20", "Ads", "Captian Drenn"},
		[15386] = {{4},1,"AQ20", "Ads", "Captian Xurrem"},
		[15388] = {{5},1,"AQ20", "Ads", "Major Yeggeth"},
		[15385] = {{6},1,"AQ20", "Ads", "Major Pakkon"},
		[15341] = {{7},1,"AQ20", "Ads", "Colonel Zerran"},
		[15514] = {{8},1,"AQ20", "Boss", "General Rajaxx"},
		[15264] = {{4,3,2,1},1,"AQ40", "Trash", "Anubisath Sentinel"},
		[15981] = {{4,3,2,1},1,"NAXX", "Trash", "Naxxramas Acolyte"},
		[16452] = {{4,3,2,1},1,"NAXX", "Trash", "Necro Knight Guardian"},  --holy shit these mobs hit hard!
		[16017] = {{4,3,2,1},1,"NAXX", "Trash", "Patchwork Golem"}, --these cleave! omg! chain cleave! 360!
		[16021] = {{4,3,2,1},1,"NAXX", "Trash", "Living Monstrosity"},
		[16020] = {{4,3,2,1},1,"NAXX", "Trash", "Mad Scientist"},
		[16447] = {{8,7,6,5},3,"NAXX", "Trash", "Plagued Ghoul"},
		}
		-- "focus", "focus2", "primary", "secondary", "sheep", "banish", "shackle", "fear",
		-- "rt8", "rt7", "rt6", "rt5", "rt4", "rt3", "rt2", "rt1"
	},
};

PocketMeroe = DF:CreateAddOn("main", "PocketMeroeDB", default_config)


local PocketMeroe_OnEvent = function(_,event, ...)
	--ChatFrame1:AddMessage	(" main by meroe - <Serenity> is doing something ");
	if PocketMeroe.marks then
		if (event == "MODIFIER_STATE_CHANGED") then
			if PocketMeroe.marks.markersModifierChanged then
				PocketMeroe.marks.markersModifierChanged()
			end
		end

		-- Hook tooltip
		if not PocketMeroe.marks.tooltipHooked then
			PocketMeroe.marks.tooltipHooked = true
			GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
					if PocketMeroe.marks.tooltipExtend then
						PocketMeroe.marks.tooltipExtend(tooltip)
					end
			end)
		end
		-- Extend tooltip
		if (event == "MODIFIER_STATE_CHANGED") then
			if (UnitExists("mouseover")) then
				GameTooltip:SetUnit("mouseover")
			end
		end
	else
		ChatFrame1:AddMessage("PocketMeroe.main: PocketMeroe.marks is not responding.")
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
			PocketMeroe.marks.InitTooltips()
			PocketMeroe.marks.InitMarking()
		else
			ChatFrame1:AddMessage("PocketMeroe.main: PocketMeroe.marks is not initialized.")
		end
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