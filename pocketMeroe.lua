------------------------------------------------------------------------------------------------------------------------
--[[
License: GPLv3
pocketMeroe was made by meroe for <Serenity> - Mankrik.

Author's note: Licensing is complicated. I used the Details!: Framework library (LGPLv3) for this addon.
It can be found here: https://www.curseforge.com/wow/addons/libdframework and was made by Terciob,
Details!: Framework is *also* complicated, so I used Terciob's WorldQuestTracker addon as a reference.
WQT can be found here: https://www.curseforge.com/wow/addons/world-quest-tracker
TODO: I also used code from Method Raid Tools. MRT uses LibDeflate which is GPLv3.

Please DO NOT ask questions about pocketMeroe in the Details! discord, they would be very confused.
The Details! discord server will NOT answer questions or offer support
Thank you to Terciob, <Method>, and others for their contributions to the WoW community!

]]
------------------------------------------------------------------------------------------------------------------------
local version = "v0.0.4"
local config = {};
local helpers = {};
local PocketMeroeFrame = CreateFrame("Frame");

-- (Details!: Framework) get the framework table
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
		-- "focus", "focus2", "primary", "secondary", "sheep", "banish", "shackle", "fear",
		-- "rt8", "rt7", "rt6", "rt5", "rt4", "rt3", "rt2", "rt1"
	},
};
------ Mob Info --------------------------------------------------------------------------------------------------------
local npcData = {};
do
	--- Stockades Test ---
	npcData['1706'] = {
		markerType = {"councilB"},
		instance = {"test"},
		untauntable = true,
	};
	npcData['1707'] = {
		markerType = {"councilA"},
		instance = {"test"},
	};
	npcData['1708'] = {
		markerType = {"councilA"},
		instance = {"test"},
	};
	npcData['3501'] = {
		name = "Horde Guard (Test)",
		markerType = {"rt1"},
		instance = {"test"},
		untauntable = true,
	};

	--- Zul'Gurub      ---
	---- Trash         ---
	npcData['14750'] = {
		name = "Gurubashi Bat Rider",
		markerType = {"focus"},
		instance = {"zg"},
	};
	npcData['14883'] = {
		name = "Voodoo Slave",
		markerType = {"focus"},
		instance = {"zg"},
	};
	npcData['11830'] = {
		name = "Hakkari Priest",
		markerType = {"focus"},
		instance = {"zg"},
	};
	npcData['11353'] = {
		name = "Gurubashi Blood Drinker",
		markerType = {"sheep"},
		instance = {"zg"},
	};
	--- Molten Core    ---
	----  Trash       ----
	npcData['11671'] = {
		name = "Core Hound",
		markerType = {"banish"},
		instance = {"mc"},
	};
	npcData['12076'] = {
		name = "Lava Elemental",
		markerType = {"banish"},
		instance = {"mc"},
	};
	npcData['12100'] = {
		name = "Lava Reaver",
		markerType = {"banish"},
		instance = {"mc"},
	};
	npcData['11659'] = {
		name = "Molten Destroyer",
		markerType = {"focus"},
		instance = {"mc"},
	};
	---- Bosses       ----
	npcData['12118'] = {
		name = "*Lucifron",
		markerType = {"rt4"},
		instance = {"mc"},
	};
	npcData['12119'] = {
		name = "*Lucifron **Flamewaker Protector",
		markerType = {"focus"},
		instance = {"mc"},
	};
	npcData['11982'] = {
		name = "*Magmadar",
		markerType = {"rt8"},
		instance = {"mc"},
	};
	npcData['12099'] = {
		name = "*Garr **Firesworn",
		markerType = {"primary", "secondary"},
		instance = {"mc"},
	};
	npcData['12056'] = {
		name = "*Baron Geddon",
		markerType = {"rt8"},
		instance = {"mc"},
	};
	npcData['12264'] = {
		name = "*Shazzrah",
		markerType = {"rt8"},
		instance = {"mc"},
	};
	npcData['11988'] = {
		name = "*Golemagg",
		markerType = {"rt8"},
		instance = {"mc"},
	};
	npcData['11672'] = {
		name = "*Golemagg **Core Rager",
		markerType = {"shackle"},
		instance = {"mc"},
	};
	npcData['11662'] = {
		name = "*Sulfuron Harbinger **Flamewaker Priest",
		markerType = {"secondary"},
		instance = {"mc"},
	};
	npcData['11663'] = {
		name = "*Majordomo Executus) **Flamewaker Healer",
		markerType = {"secondary"},
		instance = {"mc"},
	};
	npcData['11664'] = {
		name = "*Majordomo Executus & *Gehennas **Flamewaker Elite",
		markerType = {"primary"},
		instance = {"mc"},
	};

	--- Blackwing Lair ---
	---- Trash        ----
	npcData['12468'] = {
		name = "Death Talon Hatcher",
		markerType = {"primary", "secondary"},
		instance = {"bwl"},
	};
	npcData['12458'] = {
		name = "Blackwing Taskmaster",
		markerType = {"rt2"},
		instance = {"bwl"},
	};
	npcData['12459'] = {
		name = "Blackwing Warlock",
		markerType = {"primary", "secondary"},
		instance = {"bwl"},
	};
	npcData['12457'] = {
		name = "Blackwing Spellbinder",
		markerType = {"secondary"},
		instance = {"bwl"},
	};
	---- Vael Pack     ---
	npcData['12467'] = {
		name = "Death Talon Captain",
		markerType = {"rt1"},
		instance = {"bwl"},
	};
	npcData['12463'] = {
		name = "Death Talon Flamescale",
		markerType = {"focus"},
		instance = {"bwl"},
	};
	npcData['12464'] = {
		name = "Death Talon Seether",
		markerType = {"banish"},
		instance = {"bwl"},
	};
	npcData['12465'] = {
		name = "Death Talon Wyrmkin",
		markerType = {"shackle"},
		instance = {"bwl"},
	};
	--12460
	---- Bosses        ---
	npcData['12420'] = {
		name = "(Razorgore) Blackwing Mage",
		markerType = {"primary"},
		instance = {"bwl"},
	};


	--- AQ20           ---
	---- Trash         ---
	---- Bosses        ---
	npcData['15514'] = {
		name = "(Buru) Buru Egg",
		markerType = {"primary", "secondary"},
		instance = {"aq20"},
	};
	npcData['15391'] = {
		name = "(General Rajaxx) Captian Qeez",
		markerType = {"secondary"},
		instance = {"aq20"},
	};
	npcData['15392'] = {
		name = "(General Rajaxx) Captian Tuubid",
		markerType = {"secondary"},
		instance = {"aq20"},
	};
	npcData['15389'] = {
		name = "(General Rajaxx) Captian Drenn",
		markerType = {"secondary"},
		instance = {"aq20"},
	};
	npcData['15390'] = {
		name = "(General Rajaxx) Captian Xurrem",
		markerType = {"secondary"},
		instance = {"aq20"},
	};
	npcData['15386'] = {
		name = "(General Rajaxx) Major Yeggeth",
		markerType = {"secondary"},
		instance = {"aq20"},
	};
	npcData['15388'] = {
		name = "(General Rajaxx) Major Pakkon",
		markerType = {"secondary"},
		instance = {"aq20"},
	};
	npcData['15385'] = {
		name = "(General Rajaxx) Colonel Zerran",
		markerType = {"secondary"},
		instance = {"aq20"},
	};
	npcData['15341'] = {
		name = "(General Rajaxx) General Rajaxx",
		markerType = {"rt8"},
		instance = {"aq20"},
	};

	--- AQ40           ---
	---- Trash        ----
	npcData['15264'] = {
		name = "Anubisath Sentinel",
		markerType = {"primary"},
		instance = {"aq40"},
	};
	--- Naxxramas      ---
	---- Trash        ----
	npcData['15981'] = {
		name = "Naxxramas Acolyte",
		markerType = {"sheep", "primary"},
		instance = {"naxx"},
	};
	npcData['16452'] = {
		name = "Necro Knight Guardian",
		markerType = {"primary","secondary"},
		instance = {"naxx"},
	};
	npcData['16017'] = {
		name = "Patchwork Golem",
		markerType = {"secondary"},
		instance = {"naxx"},
	};
	npcData['16021'] = {
		name = "Living Monstrosity",
		markerType = {"focus"},
		instance = {"naxx"},
	};
	npcData['16020'] = {
		name = "Mad Scientist",
		markerType = {"primary", "secondary"},
		instance = {"naxx"},
	};
	npcData['16447'] = {
		name = "Plagued Ghoul",
		markerType = {"primary", "secondary"},
		instance = {"naxx"},
	};
end
------------------------------------------------------------------------------------------------------------------------

--[[ 
	TODO: cooltip clears
 ]]
 ------ Init ------------------------------------------------------------------------------------------------------------
function PocketMeroeFrame_OnLoad()
	local function HandleSlashCommands(str)
		PocketMeroe_MenuToggle();
	end
	--local function EasterEggKish(str)
	--[[ 
		TODO: Somethin funny lmao 
	]]
	--end
	SLASH_Meroe1 = "/meroe";
	SLASH_Meroe2 = "/MEROE";

	--SLASH_Kishibe1 = "/kishibe"
	SlashCmdList["Meroe"] = HandleSlashCommands;
	--SlashCmdList.Kishibe = EasterEggKish;		
	if (PocketMeroe.db:GetCurrentProfile() ~= "Default") then
		PocketMeroe.db:SetProfile("Default")
	end
	PocketMeroe.db.RegisterCallback(PocketMeroe, "OnProfileChanged", "RefreshConfig")
	
	_G["MarkingModifier"] = PocketMeroe.db.profile.marking_modifier
	_G["ClearModifier"] = PocketMeroe.db.profile.clear_modifier

	ChatFrame1:AddMessage(" pocketMeroe by meroe - <Serenity> is loaded ");
	ChatFrame1:AddMessage(" Remember kids, 'meroe' rhymes with '░░░░░' ");

	PocketMeroeFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
	PocketMeroeFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	PocketMeroeFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	PocketMeroeFrame:SetScript("OnEvent", PocketMeroeFrame_OnEvent);

	PocketMeroe_InitTooltips()
	PocketMeroe_InitMarking()
	--pocketMeroe.db.RegisterCallback (pocketMeroe, "OnDatabaseShutdown", "CleanUpJustBeforeGoodbye")
end

function PocketMeroeFrame_OnEvent(_,event)
	--if (name ~= "pocketMeroe") then return end

	if (event == "MODIFIER_STATE_CHANGED") then
		if helpers.markersModifierChanged then
			helpers.markersModifierChanged(f)
		end
	end

	-- Hook tooltip
	if not helpers.tooltipHooked then
		helpers.tooltipHooked = true
		GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
				if helpers.tooltipExtend then
					helpers.tooltipExtend(tooltip, f)
				end
		end)
	end
	-- Extend tooltip
	if (event == "MODIFIER_STATE_CHANGED") then
		if (UnitExists("mouseover")) then
			GameTooltip:SetUnit("mouseover")
		end
	end
end

PocketMeroeFrame:RegisterEvent("ADDON_LOADED");
PocketMeroeFrame:SetScript("OnEvent", PocketMeroeFrame_OnLoad);
_G["PocketMeroe"] = DF:CreateAddOn ("PocketMeroe", "PocketMeroeDB", default_config)
_G["PocketMeroeHelpers"] = helpers

function PocketMeroe_LoadDF()
	if (not DF) then
		print ("|cFFFFAA00pocketMeroe: Details!: Framework not found, if you just installed or updated pocketMeroe, please restart your client.|r")
		return
	end
	-- (Details!: Framework) create the addon object
end
------ Database Loads in here ------------------------------------------------------------------------------------------
function PocketMeroe:RefreshConfig()
	--
end

------------------------------------------------------------------------------------------------------------------------
------ Bits and pieces for UI ------------------------------------------------------------------------------------------
local PocketMeroe_OptionsOnClick = function(_, _, option, value, value2, mouseButton)
	-- helpers.markersCustom = { 
	--     "focus", "focus2", "primary", "secondary", "sheep", "banish", "shackle", "fear",
	--     "rt8", "rt7", "rt6", "rt5", "rt4", "rt3", "rt2", "rt1"
	-- }
	if option == "use_mouseover" then
		PocketMeroe.db.profile.use_mouseover = not PocketMeroe.db.profile.use_mouseover
		return
	end
	if option == "require_leader" then
		PocketMeroe.db.profile.require_leader = not PocketMeroe.db.profile.require_leader
		return
	end
	for i, mark in pairs(PocketMeroe.db.profile.raidMarkers) do
		if option == i then
			--print(option, value)
			mark[value] = not mark[value]
			return
		end
	end
end

local PocketMeroe_SetSetting = function(...)
	PocketMeroe_OptionsOnClick(nil, nil, ...)
end

local PocketMeroe_SetModifier = function(_, var, value, key)
	PocketMeroe.db.profile [var].none = false
	PocketMeroe.db.profile [var].alt = false
	PocketMeroe.db.profile [var].ctrl = false
	PocketMeroe.db.profile [var].shift = false

	PocketMeroe.db.profile [var] [key] = value
end

function PocketMeroe_MenuToggle()
	local menu = meroeOptions or PocketMeroe_CreateMenu();
	if (menu) then
		menu:SetShown(not menu:IsShown());
	end
end

local BuildModifierOptions = function(var)
	local result = {
		{
			label = "None",
			value = "none",
			onclick = function()
				PocketMeroe_SetModifier(nil, var, true, "none")
			end,
		},
		{
			label = "Alt",
			value = "alt",
			onclick = function()
				PocketMeroe_SetModifier(nil, var, true, "alt")
			end,
		},
		{
			label = "Ctrl",
			value = "ctrl",
			onclick = function()
				PocketMeroe_SetModifier(nil, var, true, "ctrl")
			end,
		},
		{
			label = "Shift",
			value = "shift",
			onclick = function()
				PocketMeroe_SetModifier(nil, var, true, "shift")
			end,
		},
	}
	return result
end

local BuildRaidOptions = function(var)
	local result = {
		{
			label = "All",
			value = "none",
			onclick = function()
				PocketMeroe.markingScroll:UpdateList(nil, var, true, "none")
			end,
		},
		{
			label = "Zul'Gurub",
			value = "zg",
			onclick = function()
				PocketMeroe.markingScroll:UpdateList(nil, var, true, "zg")
			end,
		},
		{
			label = "Ruins of Ahn'Qiraj",
			value = "aq20",
			onclick = function()
				PocketMeroe.markingScroll:UpdateList(nil, var, true, "aq20")
			end,
		},
		{
			label = "Molten Core",
			value = "mc",
			onclick = function()
				PocketMeroe.markingScroll:UpdateList(nil, var, true, "mc")
			end,
		},
		{
			label = "Blackwing Lair",
			value = "bwl",
			onclick = function()
				PocketMeroe.markingScroll:UpdateList(nil, var, true, "bwl")
			end,
		},
		{
			label = "Temple of Ahn'Qiraj",
			value = "aq40",
			onclick = function()
				PocketMeroe.markingScroll:UpdateList(nil, var, true, "aq40")
			end,
		},
		{
			label = "Naxxramas",
			value = "naxx",
			onclick = function()
				PocketMeroe.markingScroll:UpdateList(nil, var, true, "naxx")
			end,
		},
	}
	return result
end

------ Menu ------------------------------------------------------------------------------------------------------------
function PocketMeroe_CreateMenu()
	-- toggle configuration menu
	if (meroeOptions) then
		meroeOptions:Show()
		return
	end

	-- templates
	local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
	local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
	local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
	local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
	local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")
	local options_button_template_selected = DF.table.copy({}, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
	
	--options
	local selectedTabIndicatorDefaultColor = {.4, .4, .4}
	local selectedTabIndicatorColor = {1, 1, 0}

	local startX = 160

	--build the options window
	local optionsFrame = DF:CreateSimplePanel (UIParent, 560, 330, "pocketMeroe Config", "meroeOptions")
	--local meroeOptions = DF:NewPanel(UIParent, _, "meroeOptions", _, 897, 592)

	optionsFrame.Frame = optionsFrame
	optionsFrame.__name = "Options"
	optionsFrame.real_name = "POCKETMEROE_OPTIONS"
	optionsFrame.__icon = [[Interface\Scenarios\ScenarioIcon-Interact]]

	--create the footer below the options frame
	local statusBar = CreateFrame("frame", "$parentStatusBar", optionsFrame, "BackdropTemplate")
	local authorInfo = DF:CreateLabel(statusBar, "|cFFFFFFFFmeroe|r |cFFFFFFFF<Serenity>|r - Mankrik")
	statusBar:ClearAllPoints()
	statusBar:SetPoint("BOTTOMLEFT", optionsFrame, "BOTTOMLEFT")
	statusBar:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT")
	statusBar:SetHeight(20)
	statusBar:SetAlpha(0.9)
	statusBar:SetFrameLevel(optionsFrame:GetFrameLevel()+2)
	authorInfo.textcolor = "silver"
	authorInfo:ClearAllPoints()
	authorInfo:SetPoint("left", statusBar, "left", 6, 0)
	authorInfo:SetAlpha(.6)
	statusBar.authorInfo = authorInfo
	DF:ApplyStandardBackdrop(statusBar)

	local bottomGradient = DF:CreateTexture(optionsFrame, {gradient = "vertical", fromColor = {0, 0, 0, 0.3}, toColor = "transparent"}, 1, 100, "artwork", {0, 1, 0, 1}, "bottomGradient")
	bottomGradient:SetAllPoints(optionsFrame, 1)
	bottomGradient:SetPoint("bottom-top", statusBar)

--[[ 	--divisor shown above the tab options area
	local frameBackgroundTextureTopLine = optionsFrame:CreateTexture("$parentHeaderDivisorTopLine", "artwork")
	local divisorYPosition = -60
	frameBackgroundTextureTopLine:SetPoint("topleft", optionsFrame, "topleft", startX-9, divisorYPosition)
	frameBackgroundTextureTopLine:SetPoint("topright", optionsFrame, "topright", -1, divisorYPosition)
	frameBackgroundTextureTopLine:SetHeight(1)
	frameBackgroundTextureTopLine:SetColorTexture(0.1215, 0.1176, 0.1294)

	local frameBackgroundTextureLeftLine = optionsFrame:CreateTexture("$parentHeaderDivisorLeftLine", "artwork")
	local divisorYPosition = -60
	frameBackgroundTextureLeftLine:SetPoint("topleft", frameBackgroundTextureTopLine, "topleft", 0, 0)
	frameBackgroundTextureLeftLine:SetPoint("bottomleft", optionsFrame, "bottomleft", startX-9, 1)
	frameBackgroundTextureLeftLine:SetHeight(1)
	frameBackgroundTextureLeftLine:SetColorTexture(0.1215, 0.1176, 0.1294)
 ]]
	local tabList = {
		{name = ".settings",	text = "General"},
		{name = ".markers",		text = "Enabled Marks"},
	}
	local optionsTable = {
		y_offset = 0,
		button_width = 100,
		button_height = 23,
		button_x = 220,
		button_y = 0,
		button_text_size = 11,
		right_click_y = 5,
		rightbutton_always_close = true,
		close_text_alpha = 0,
		container_width_offset = 0
	}
	local hookList = {
		OnSelectIndex = function(tabContainer, tabButton)
			if (not tabButton.leftSelectionIndicator) then
				return
			end

			for i = 1, #tabContainer.AllFrames do
				local thisTabButton = tabContainer.AllButtons[i]
				thisTabButton.leftSelectionIndicator:SetColorTexture(unpack(selectedTabIndicatorDefaultColor))
			end
		tabButton.leftSelectionIndicator:SetColorTexture(unpack(selectedTabIndicatorColor))
		tabButton.selectedUnderlineGlow:Hide()
		end,
	}

	local tabContainer = DF:CreateTabContainer(optionsFrame, "pocketMeroe", "meroe", tabList, optionsTable, hookList)
												
	tabContainer:SetPoint("center", optionsFrame, "center", 0, 0)
	tabContainer:SetSize(optionsFrame:GetSize())
	tabContainer:Show()


	local backdropTable = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true}
	local backdropColor = {DF:GetDefaultBackdropColor()}
	local backdropBorderColor = {0, 0, 0, 1}
	tabContainer:SetTabFramesBackdrop(backdropTable, backdropColor, backdropBorderColor)

	--this function runs when any setting is changed
	local profileCallback = function()

	end

	--make the tab button's text be aligned to left and fit the button's area
	for index, frame in ipairs(tabContainer.AllFrames) do
		frame.titleText.fontsize = 18
		local tabButton = tabContainer.AllButtons[index]
		local leftSelectionIndicator = tabButton:CreateTexture(nil, "overlay")

		--DF:ApplyStandardBackdrop(frame)
		local frameBackgroundTexture = frame:CreateTexture(nil, "artwork")
		frameBackgroundTexture:SetPoint("topleft", frame, "topleft", 4, -110)
		frameBackgroundTexture:SetPoint("bottomright", frame, "bottomright", -4, 20)
		frameBackgroundTexture:SetColorTexture (0.2317647, 0.2317647, 0.2317647)
		frameBackgroundTexture:SetVertexColor (0.27, 0.27, 0.27)
		frameBackgroundTexture:SetAlpha (0.3)

		if (index == 1) then
			leftSelectionIndicator:SetColorTexture(1, 1, 0)
		else
			leftSelectionIndicator:SetColorTexture(.4, .4, .4)
		end
		leftSelectionIndicator:SetPoint("left", tabButton.widget, "left", 2, 0)
		leftSelectionIndicator:SetSize(4, tabButton:GetHeight()-4)
		tabButton.leftSelectionIndicator = leftSelectionIndicator

		local maxTextLength = tabButton:GetWidth() - 7

		local fontString = _G[tabButton:GetName() .. "_Text"]
		fontString:ClearAllPoints()
		fontString:SetPoint("left", leftSelectionIndicator, "right", 2, 0)
		fontString:SetJustifyH("left")
		fontString:SetWordWrap(true)
		fontString:SetWidth(maxTextLength)
		fontString:SetHeight(tabButton:GetHeight()+20)
		fontString:SetText(fontString:GetText())

		local stringWidth = fontString:GetStringWidth()

		--print(stringWidth, maxTextLength, fontString:GetText())

		if (stringWidth > maxTextLength) then
			local fontSize = DF:GetFontSize(fontString)
			DF:SetFontSize(fontString, fontSize-0.5)
		end
	end

	-- get each tab's frame and create a local variable to cache it
	local generalSettingsFrame = tabContainer.AllFrames[1]
	local marksConfigFrame = tabContainer.AllFrames[2]
	local tabFrameHeight = generalSettingsFrame:GetHeight()
	--- General settings
	do
		local optionsTable = {
			always_boxfirst = true,
			{
				type = "label",
				get = function() return "Functionality" end,
				text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")
			},
			{
				type = "toggle",
				get = function()
					return PocketMeroe.db.profile.use_mouseover
				end,
				set = function(self, fixedparam, value)
					PocketMeroe_SetSetting("use_mouseover", PocketMeroe.db.profile.use_mouseover)
				end,
				name = "Mouseover",
				desc = "Allow marking by mousing over mobs.",
			},
			{
				type = "toggle",
				get = function()
					return PocketMeroe.db.profile.require_leader
				end,
				set = function(self, fixedparam, value)
					PocketMeroe_SetSetting("require_leader", PocketMeroe.db.profile.require_leader)
				end,
				name = "Require Leader",
				desc = "If toggled then you must be the leader to mark mobs.",
			},
			{
				type = "select",
				get = function()
					return MarkingModifier.none and "none" or MarkingModifier.alt and "alt" or MarkingModifier.ctrl and "ctrl" or MarkingModifier.shift and "shift"
				end,
				values = function () return BuildModifierOptions("marking_modifier") end,
				name = "Marking Modifier",
				desc = "Require this modifier key to be held down for mouseover marking to work. ",
			},
			{
				type = "select",
				get = function() 
					return ClearModifier.none and "none" or ClearModifier.alt and "alt" or ClearModifier.ctrl and "ctrl" or ClearModifier.shift and "shift"
				end,
				values = function () return BuildModifierOptions("clear_modifier") end,
				name = "Clear Modifier",
				desc = "Require this modifier key to be held down to clear existing marks. ",
			},
			{type = "blank"},
		}
		DF:BuildMenu(generalSettingsFrame, optionsTable, 10, -100, tabFrameHeight, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, profileCallback)

	end

	--- Marking setings
	do
		-- local markers = PocketMeroe.db.profile.raidMarkers

		local optionsTable = {
			always_boxfirst = false,
			{
				type = "select",
				get = function() 
					return "none" or "zg" or "aq20" or "mc" or "bwl"
				end,
				values = function () return BuildRaidOptions() end,
				name = "Raid:",
				--desc = "",

			},
		}
		--optionsTable.always_boxfirst = true

		local config = {
			scroll_width = 510,
			scroll_height = 174,
			scroll_line_height = 18,
			scroll_lines = 9,
			backdrop_color = {.4, .4, .4, .2},
			backdrop_color_highlight = {.4, .4, .4, .6},
		}
		local backdrop_color = {.8, .8, .8, 0.2}
		local backdrop_color_on_enter = {.8, .8, .8, 0.4}

		DF:BuildMenu(marksConfigFrame, optionsTable, 10, -100, tabFrameHeight, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, profileCallback)
		local line_onenter = function (self)
			self:SetBackdropColor (unpack (backdrop_color_on_enter))
		end
		
		local line_onleave = function (self)
			self:SetBackdropColor (unpack (backdrop_color))
		end

		if (not pocketMeroeScrollPanel) then
			local markListRefresh = function(self, data, offset, totalLines)
				for i = 1, totalLines do
					local index = i + offset
					local data = data[index]
					
					if (data) then
						local line = self:GetLine(i)
						line:SetBackdropColor (unpack (backdrop_color))
						line:SetScript ("OnEnter", line_onenter)
						line:SetScript ("OnLeave", line_onleave)
						if (line) then
							local name, markerType = unpack(data)
							--print(index, name, markerType)
							line.name:SetText(name)
							line.markerType:SetText(markerType)
						end
					end
				end
			end

			--who needs a brain and knowledge of lua scopes anyways xd probably just pass this to the dropdown onclick that uses it ...
			PocketMeroe.markingScroll = DF:CreateScrollBox (marksConfigFrame, "$parentmarkingScroll", markListRefresh, {}, config.scroll_width, config.scroll_height, config.scroll_lines, config.scroll_line_height)
			local markingScroll = PocketMeroe.markingScroll
			DF:ReskinSlider (markingScroll)
			markingScroll:SetPoint("TOPLEFT", marksConfigFrame, "TOPLEFT", 5, -140)

			--create the scroll widgets
			-- local createLine = function(self, index)
			-- 	local line = CreateFrame ("button", "$parentLine" .. index, self, "BackdropTemplate")
			-- 	line:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -((index-1)*(config.scroll_line_height+1)) - 1)
			-- 	line:SetSize(config.scroll_width - 2, config.scroll_line_height)

			-- 	line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			-- 	line:SetBackdropColor(unpack (config.backdrop_color))

			-- 	local name = line:CreateFontString ("$parentName", "OVERLAY", "GameFontNormal")
			-- 	local markerType = line:CreateFontString ("$parentName", "OVERLAY", "GameFontNormal")

			-- 	DF:SetFontSize (name, 10)
			-- 	DF:SetFontSize (markerType, 10)

			-- 	name:SetPoint("LEFT", line, "LEFT", 4, 0)
			-- 	markerType:SetPoint("RIGHT", line, "RIGHT", -4, 0)

			-- 	line.name = name
			-- 	line.markerType = markerType
			-- 	return line
			-- end

			-- --create the scroll widgets
			-- for i = 1, config.scroll_lines do
			-- 	markingScroll:CreateLine (createLine, i)
			-- end

			-- --this build a list of units and send it to the scroll
			-- function markingScroll:UpdateList(_, _, option, value, value2, mouseButton)
			-- 	local data = {}
			-- 	for id, _ in pairs (npcData) do
			-- 		-- i really sure hope the same mob IDs dont appear in multiple instances.
			-- 		if (npcData[id].instance[1] == value or value =="none" or not value) then
			-- 			local name = npcData[id].name or id
			-- 			local markerType = npcData[id].markerType[1]
			-- 			for i=2, #npcData[id].markerType do
			-- 				markerType = markerType .. ", " .. tostring((npcData[id].markerType[i]))
			-- 			end
			-- 			tinsert (data, {name, markerType})
			-- 		end
			-- 	end
			-- 	markingScroll:SetData (data)
			-- 	markingScroll:Refresh()
			-- end
			-- markingScroll:UpdateList()
			-- markingScroll:Show()
		end
	end


--[[ 	
	TODO: add other 6 tabs
	TODO: add bossmods tab which controls features for boss enocunters
		TODO: add boss encounter things
			TODO: create frames for these and tie them into event handlers
			 
	TODO: add externals timers for usage during raid
		TODO: assignment list on the background for trash/sheeps
		TODO: tanks cooldowns used w options of including more people
		TODO: calculate estimative to boss kill timer
		TODO: distance to target somewhere in the screen, maybe on nameplate

	TODO: add raid role organizer/selector
]]

--[[ 	local scenario = CreateFrame("frame", "pocketMeroeScenario", UIParent, "BackdropTemplate")
	local scenarioDesc = DF:CreateLabel(scenario, "For |cFFFFFFFF<Serenity>|r - Mankrik, by |cFFFFFFFFmeroe|r")
	scenarioDesc:ClearAllPoints()
	scenarioDesc:SetPoint("BOTTOMLEFT", optionsFrame, "BOTTOMLEFT")
	scenarioDesc:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT")
	scenarioDesc:SetHeight(20)
	scenarioDesc:SetAlpha(0.9)
	scenario:Show()
 ]]

 	optionsFrame:Hide();
	return optionsFrame;
end
------ Auto-Marking ----------------------------------------------------------------------------------------------------
-- Huge credit to https://wago.io/p/Forsaken for most of the auto-marking code.
-- The WeakAura I modified can be found here: https://wago.io/q1YbxB5Pz
-- Even with my tweaks, full credit goes to Forsaken for their beautiful WeakAura.
------------------------------------------------------------------------------------------------------------------------
function PocketMeroe_InitTooltips ()
	helpers.tooltipExtend = function(tooltip, f)
		local unitName, unitId = GameTooltip:GetUnit()
		if UnitExists(unitId) then
			local guid = UnitGUID(unitId)
			local type, _, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid)
			local npcInfo = npcData[npc_id]
			if (npcInfo ~= nil) then
				if (npcInfo.untauntable) then
					local ttIcon = "|T136122:0|t"
					GameTooltip:AddLine(ttIcon.." |cFFC41E3A! Untauntable !|r "..ttIcon)
				end
				-- tooltip:Show();
				if (GameTooltip:GetWidth() > 700) then
					GameTooltip:SetWidth(700)
				end
				if helpers.markersEnabled(f) then
					if helpers.clearModifierIsPressed then
						helpers.markersRemoveUnit(f, unitId)
						return
					end
					local markerType, markerBias = helpers.markersGetTypeForNpc(f, npc_id, unitName)
					if (markerType ~= nil) then
						helpers.markersSetUnit(f, unitId, markerType, markerBias)
					end
				end
			end
		end
	end
end

--[[
	TODO: Broadcast some of this to party/raid members.
]]
function PocketMeroe_InitMarking ()
	-- List of all currently used markers
	helpers.markersUsed = helpers.markersUsed or {}
	helpers.markersUsedPriority = helpers.markersUsedPriority or {}
	helpers.markersUsedByGUID = helpers.markersUsedByGUID or {}
	helpers.markersUsedReset = GetTime() + 2
	helpers.markersModifierIsPressed = false
	helpers.clearModifierIsPressed = false
	-- Group mappings for custom npcs
	helpers.markersCustom = { 
		"focus", "focus2", "primary", "secondary", "sheep", "banish", "shackle", "fear",
		"rt8", "rt7", "rt6", "rt5", "rt4", "rt3", "rt2", "rt1"
	}
	-- Check if marking (and unmarking) units is enabled
	helpers.markersEnabled = function(f)
		if not PocketMeroe.db.profile.use_mouseover then
			return false
		end
		if not MarkingModifier then
			return false
		end
		if (PocketMeroe.db.profile.require_leader and not UnitIsGroupLeader("player")) then
			-- doesn't do marking if not player lead and "not lead" is toggled in custom options
			return false
		end
		if (ClearModifier.alt and IsAltKeyDown()) then
			return true
		elseif (ClearModifier.ctrl and IsControlKeyDown()) then
			return true
		elseif (ClearModifier.shift and IsShiftKeyDown()) then
			return true
		end
		if (MarkingModifier.alt and IsAltKeyDown()) then
			return true
		elseif (MarkingModifier.ctrl and IsControlKeyDown()) then
			return true
		elseif (MarkingModifier.shift and IsShiftKeyDown()) then
			return true
		end
		return false
	end
	helpers.markersModifierChanged = function(f)
		if ClearModifier and PocketMeroe.db.profile.use_mouseover then
			if (ClearModifier.alt and IsAltKeyDown()) then
				helpers.clearModifierIsPressed = true
			elseif (ClearModifier.ctrl and IsControlKeyDown()) then
				helpers.clearModifierIsPressed = true
			elseif (ClearModifier.shift and IsShiftKeyDown()) then
				helpers.clearModifierIsPressed = true
			elseif (helpers.markersModifierPressed) then
				helpers.clearModifierIsPressed = false
			end
			return -- Blocks a unit from repeatedly being marked and unmarked quickly.
		end
		if MarkingModifier and PocketMeroe.db.profile.use_mouseover then
			if (MarkingModifier.alt and IsAltKeyDown()) then
				helpers.markersModifierPressed()
			elseif (MarkingModifier.ctrl and IsControlKeyDown()) then
				helpers.markersModifierPressed()
			elseif (MarkingModifier.shift and IsShiftKeyDown()) then
				helpers.markersModifierPressed()
			elseif (helpers.markersModifierPressed) then
				helpers.markersModifierReleased()
			end
		end

	end
	-- Pressed and Released introduce a delay for chain-marking mobs.
	helpers.markersModifierPressed = function(f)
		if helpers.markersModifierIsPressed then
			return -- Was already pressed before
		end
		helpers.markersModifierIsPressed = true
		helpers.markersClearUsed()
		helpers.markersUsedReset = GetTime() + 10.0
	end
	helpers.markersModifierReleased = function(f)
		if not helpers.markersModifierIsPressed then
			return -- Was already released before
		end
		helpers.markersModifierIsPressed = false
		helpers.markersUsedReset = GetTime()
	end
	-- Add unit's marker to list of used markers        
	helpers.markersAddToUsed = function(f, unitId, index, priority)
		if not index then
			index = GetRaidTargetIndex(unitId)
		end
		if not priority then
			local markerType = helpers.markersGetTypeForUnit(f, unitId)
			priority = helpers.markersUsedPriority[index] or helpers.markersGetPriority(markerType)
		end
		for guid, i in pairs(helpers.markersUsedByGUID) do
			if (i == index) then
				helpers.markersUsedByGUID[guid] = nil
			end
		end
		if index then
			local guid = UnitGUID(unitId)
			helpers.markersUsed[index] = true
			helpers.markersUsedPriority[index] = priority
			helpers.markersUsedByGUID[guid] = index
--[[ 			
	TODO: markersUsedByGUID would be shared as it updates to other players in the raid
 ]]
 			-- print(guid, "+", index)
		end
	end
	-- Get list of all currently used markers
	helpers.markersClearUsed = function(f)
		for i = 1, 8 do
			helpers.markersUsed[i] = false
			helpers.markersUsedPriority[i] = nil
		end
		wipe(helpers.markersUsedByGUID)
	end
	-- Get list of all currently used markers
	helpers.markersGetUsed = function(f)
		-- Reset state
		if helpers.markersUsedReset < GetTime() then
			helpers.markersClearUsed()
		end
		helpers.markersUsedReset = max(helpers.markersUsedReset, GetTime() + 2.0)
		-- Don't use marks already used on the players target
		helpers.markersAddToUsed(f, "target")
		-- Don't use marks already used on party member or their targets
		-- for partyMember in WA_IterateGroupMembers(false, true) do
		--     helpers.markersAddToUsed(aura, partyMember)
		--     helpers.markersAddToUsed(aura, partyMember.."target")     
		-- end
		-- Don't use marks already used on boss1-4
		for i = 1, 4 do
			helpers.markersAddToUsed(f, "boss"..i)
		end
		-- Don't use marks already used on nameplates
		for i = 1, 40 do
			helpers.markersAddToUsed(f, "nameplate"..i)
		end
		return helpers.markersUsed
	end
	-- Get free marker index for the given type
	helpers.markersGetFreeIndex = function(f, markerType, priority, markerCurrent)
		if (type(markerType) == "table") then
			-- Get the highest priority marker from a list of marker types
			local markerIndex = nil
			local markerPriority = 0
			for _, t in ipairs(markerType) do
				local p = helpers.markersGetPriority(t)
				if not markerIndex or (p > markerPriority) then
					markerIndex = helpers.markersGetFreeIndex(f, t, priority, markerCurrent)
					if (markerIndex ~= nil) then
						markerPriority = p
					end
				end
			end
			return markerIndex
		end
		-- Pre-defined exact markers, "rt1-8"
		local markerExact = strmatch(markerType, "rt([0-9]+)")
		
		if markerExact ~= nil then
			local i = tonumber(markerExact)
			--print("markerExact:", markerExact)
			--print("markersUsedPriority[", i, "]:", helpers.markersUsedPriority[i])
			if not helpers.markersUsed[i] then
				return i
			end
			if (helpers.markersUsedPriority[i] ~= nil) and (helpers.markersUsedPriority[i] < priority) then
				return i
			end
			--return nil
		end
		-- Get the first available marker from the given type
		if not markerType or not PocketMeroe.db.profile.raidMarkers[markerType] then
			return nil
		end
		for i = 8, 1, -1 do
			if markerCurrent and (i <= markerCurrent) then
				return markerCurrent
			end
			local s = tostring(i)
			--print("markerType:", markerType)
			--print("markersUsedPriority[", i, "]:", helpers.markersUsedPriority[i])
			--print("mt", pocketMeroe.db.profile.raidMarkers[markerType], "s", pocketMeroe.db.profile.raidMarkers[markerType][s])
			if PocketMeroe.db.profile.raidMarkers[markerType][i] then
				--print(i, "?", helpers.markersUsed[i] or false, helpers.markersUsedPriority[i] or 0, "vs", priority)
				if not helpers.markersUsed[i] then
					return i
				end
				if (helpers.markersUsedPriority[i] ~= nil) and (helpers.markersUsedPriority[i] < priority) then
					return i
				end
			end
		end
		return nil
	end
	-- Set marker type for unit
	helpers.markersGetPriority = function(markerType)
		if (type(markerType) == "table") then
			-- Get the lowest priority from a list of marker types
			local priority = 20
			local priorityMax = 0
			for _, t in ipairs(markerType) do
				priority = min(helpers.markersGetPriority(t), priority)
				priorityMax = max(priorityMax, priority)
			end
			if (priorityMax > priority) then
				priority = priority + 0.01
			end
			return priority
		end
		-- Higher priority for exact markers
		if markerType and strmatch(markerType, "rt[0-9]+") then
			return 11
		end
		-- Get the priority for the given marker type
		if (markerType == "councilA") then
			return 12
		elseif (markerType == "councilB") then
			return 11
		elseif (markerType == "focus") then
			return 10
		elseif (markerType == "focus2") then
			return 9
		elseif (markerType == "primary") then
			return 8
		elseif (markerType == "secondary") then
			return 7
		elseif (markerType == "sheep") then
			return 6
		elseif (markerType == "banish") then
			return 5
		elseif (markerType == "shackle") then
			return 4
		elseif (markerType == "fear") then
			return 3
		else
			return 0
		end
	end
	-- Set marker type for unit
	helpers.markersGetTypeForUnit = function(f, unitId)
		if UnitExists(unitId) then
			local guid = UnitGUID(unitId);
			local name = UnitName(unitId);
			local type, _, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
			return helpers.markersGetTypeForNpc(f, npc_id, name)
		end
		return nil
	end
	-- Set marker type for npc id
	helpers.markersGetTypeForNpc = function(f, npcId, npcName)
		-- Overrides via custom options
		-- for _, npcCustom in ipairs(pocketMeroe.db.profile.raidMarkersCustom) do
		--     local customId = npcCustom.npcId
		--     local customName = npcCustom.npcName
		--     if (customId == "") and (customName == npcName) then
		--         customId = npcId
		--     end
		--     if (customId == npcId) then
		--         if not npcData[npcId] then
		--             npcData[npcId] = {
		--                 abilities = {}
		--             }
		--         end
		--         if not npcData[npcId].markerType then
		--             npcData[npcId].markerType = {}
		--         else
		--             wipe(npcData[npcId].markerType)
		--         end
		--         for i, b in ipairs(npcCustom.markers) do
		--             if b then
		--                 local customMarkerType = helpers.markersCustom[i]
		--                 tinsert(npcData[npcId].markerType, customMarkerType)
		--             end
		--         end
		--     end
		-- end
		-- Default npc data
		if npcData[npcId] and npcData[npcId].markerType then
			if (npcData[npcId].markerType == "default") then
				npcData[npcId].markerType = { "primary", "secondary" }
			end
			return npcData[npcId].markerType, (npcData[npcId].markerBias or 0.0)
		end
		return nil
	end
	-- markersSetUnit <- markersClearUnit <- markersClearIndex
	-- Set marker type for unit 
	helpers.markersClearIndex = function(index)
		if index then
			helpers.markersUsed[index] = false
			helpers.markersUsedPriority[index] = nil
		end
	end
	-- Set marker type for unit
	helpers.markersClearUnit = function(unitId)
		local guid = UnitGUID(unitId)
		if helpers.markersUsedByGUID[guid] then
			--print(guid, "-", helpers.markersUsedByGUID[guid])
			helpers.markersClearIndex(helpers.markersUsedByGUID[guid])
			helpers.markersUsedByGUID[guid] = nil
		end
		local index = GetRaidTargetIndex(unitId)
		helpers.markersClearIndex(index)
	end
	-- Set marker type for unit
	helpers.markersSetUnit = function(f, unitId, markerType, markerBias)
		helpers.markersGetUsed(f)
		local priority = helpers.markersGetPriority(markerType) + (markerBias or 0.0)
		local markerCurrent = GetRaidTargetIndex(unitId)
		local markerIndex = helpers.markersGetFreeIndex(f, markerType, priority, markerCurrent)
--[[ 		print("Unit:", unitId)
		print("Marker Type:", markerType)
		print("Priority:", priority)
		print("Current Marker Index:", markerCurrent)
		print("Free Marker Index:", markerIndex) ]]
		if (markerIndex ~= nil) and (markerIndex ~= markerCurrent) then
			--print("Setting marker for unit:", unitId)
			helpers.markersClearUnit(unitId)
			SetRaidTarget(unitId, markerIndex)
			helpers.markersAddToUsed(f, unitId, markerIndex, priority)
		end
	end
	-- Remove raid marker for unit
	helpers.markersRemoveUnit = function(f, unitId)
		helpers.markersClearUnit(unitId)
		SetRaidTarget(unitId, 0)
	end
end


