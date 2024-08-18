local DF = _G["DetailsFramework"]

local gui = {}
gui.scrollBox = {}

local config = {}

-- templates
local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")
local options_button_template_selected = DF.table.copy({}, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))

local raidIcons = {
	[1] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1", -- Star
	[2] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2", -- Circle
	[3] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3", -- Diamond
	[4] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4", -- Triangle
	[5] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5", -- Moon
	[6] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6", -- Square
	[7] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7", -- Cross
	[8] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8", -- Skull
}

--this function runs when any setting is changed
local profileCallback = function()

end

local SetModifier = function(_, var, value, key)
	if Config[var] then
		Config [var].none = false
		Config [var].alt = false
		Config [var].ctrl = false
		Config [var].shift = false
		Config [var] [key] = value
	end
end

local BuildModifierOptions = function(var)
    local modifiers = {"none", "alt", "ctrl", "shift"}
    local result = {}

    for _, modifier in ipairs(modifiers) do
        table.insert(result, {
            label = modifier:gsub("^%l", string.upper),  -- Capitalize the first letter
            value = modifier,
            onclick = function()
                SetModifier(nil, var, true, modifier)
            end,
        })
    end

    return result
end

local BuildMarksBar = function(parent)
	local marks = CreateFrame("Frame",nil,parent)
	marks:EnableMouse(true)
	marks.Background = marks:CreateTexture(nil,"BACKGROUND")
	marks.Background:SetColorTexture(0,0,0,.3)
	marks.Background:SetPoint("TOPLEFT")
	marks.Background:SetPoint("BOTTOMRIGHT")
	marks:SetPoint("CENTER",18,0)
	marks:SetSize(20*9,20)
	marks.list = {}
	for i=1,9 do
		marks.list[i] = marks:CreateTexture(nil,"OVERLAY")
		marks.list[i]:SetPoint("LEFT",(i-1)*20,0)
		marks.list[i]:SetSize(18,18)
		marks.list[i]:SetTexture(i <= 8 and "Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..i or [[Interface\AddOns\MRT\media\DiesalGUIcons16x256x128]])
		if i == 9 then
			marks.list[i]:SetTexCoord(0.125,0.1875,0.5,0.625)
			marks.list[i]:SetVertexColor(1,1,1,0.7)			
		end
	end
	return marks
end

local OptionsOnClick = function(_, _, option, value, value2, mouseButton)
	if option == "use_mouseover" then
		Config.use_mouseover = not Config.use_mouseover
		return
	end
	if option == "require_leader" then
		Config.require_leader = not Config.require_leader
		return
	end
	for i, mark in pairs(Config.raidMarkers) do
		if option == i then
			--print(option, value)
			mark[value] = not mark[value]
			return
		end
	end
end

local SetSetting = function(...)
	OptionsOnClick(nil, nil, ...)
end


local buildOptionsFrameTabs = function(parent, tabs)
	local tabList = {
		{name = ".general",	text = "General"},
		{name = ".automarks", text = "Automarks"},
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

	local selectedTabIndicatorDefaultColor = {.4, .4, .4}
	local selectedTabIndicatorColor = {1, 1, 0}

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

	local tabContainer = DF:CreateTabContainer(optionsFrame, "pocketMeroe", "$parent.tabContainer", tabList, optionsTable,
		hookList)
	tabContainer:SetPoint("center", optionsFrame, "center", 0, 0)
	tabContainer:SetSize(optionsFrame:GetSize())
	tabContainer:Show()

	local backdropTable = { edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile =
	[[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true }
	local backdropColor = { DF:GetDefaultBackdropColor() }
	local backdropBorderColor = {0, 0, 0, 1}
	tabContainer:SetTabFramesBackdrop(backdropTable, backdropColor, backdropBorderColor)
	return tabContainer
end

local buildStatusAuthorBar = function(parent)
	local statusBar = CreateFrame("frame", "$parent.Status", parent, "BackdropTemplate")
    statusBar:SetHeight(20)
    statusBar:SetAlpha(0.9)
    statusBar:SetFrameLevel(parent:GetFrameLevel()+2)
    statusBar:ClearAllPoints()
    statusBar:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT")
    statusBar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT")
	DF:ApplyStandardBackdrop(statusBar)

    local authorInfo = DF:CreateLabel(statusBar, "|cFFFFFFFFmeroe|r |cFFFFFFFF<Serenity>|r - Mankrik")
    authorInfo:SetPoint("left", statusBar, "left", 6, 0)
    authorInfo:SetAlpha(.6)
    authorInfo.textcolor = "silver"

	local bottomGradient = DF:CreateTexture(parent,
	{ gradient = "vertical", fromColor = { 0, 0, 0, 0.3 }, toColor = "transparent" }, 1, 100, "artwork", { 0, 1, 0, 1 },
	"bottomGradient")
	bottomGradient:SetAllPoints(parent, 1)
	bottomGradient:SetPoint("bottom-top", statusBar)


	return statusBar, authorInfo
end

local buildTab1Options = function(parentTab, tabFrameHeight)
	local generalOptionsTable = {
		always_boxfirst = true,
		{
			type = "label",
			get = function() return "Functionality" end,
			text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")
		},
		{
			type = "toggle",
			get = function()
				return Config.use_mouseover
			end,
			set = function(self, fixedparam, value)
				SetSetting("use_mouseover", Config.use_mouseover)
			end,
			name = "Mouseover",
			desc = "Allow marking by mousing over mobs.",
		},
		{
			type = "toggle",
			get = function()
				return Config.require_leader
			end,
			set = function(self, fixedparam, value)
				SetSetting("require_leader", Config.require_leader)
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
	DF:BuildMenu(general, config.generalOptionsTable, 10, -100, tabFrameHeight, false, options_text_template,
		options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template,
		profileCallback)

end

local buildTab2Options = function(parentTab, tabFrameHeight)
	local BuildRaidOptions = function(var, frame)
		local raids = {
			{ label = "All",                 value = "none" },
			{ label = "Zul'Gurub",           value = "ZG" },
			{ label = "Ruins of Ahn'Qiraj",  value = "AQ20" },
			{ label = "Molten Core",         value = "MC" },
			{ label = "Blackwing Lair",      value = "BWL" },
			{ label = "Temple of Ahn'Qiraj", value = "AQ40" },
			{ label = "Naxxramas",           value = "NAXX" },
		}

		local result = {}

		for _, raid in ipairs(raids) do
			table.insert(result, {
				label = raid.label,
				value = raid.value,
				onclick = function()
					parentTab.scroll:UpdateList(nil, var, true, raid.value)
				end,
			})
		end
		return result
	end

	local automarksOptionsTable = {
		always_boxfirst = false,
		{
			type = "select",
			get = function()
				return "none" or "ZG" or "AQ20" or "MC" or "BWL"
			end,
			values = function () return BuildRaidOptions(Config.var, parentTab.scroll) end,
			name = "Raid:",
			--desc = "",
		},
	}

	parentTab.scroll:UpdateList()
	DF:BuildMenu(parentTab, automarksOptionsTable, 10, -100, tabFrameHeight, false, options_text_template,
		options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template,
		profileCallback)
end

gui.ShowMenu = function()
	-- toggle scrollConfiguration menu

	if not PocketMeroeDB then
		print("PocketMeroe.gui: PocketMeroeDB not loaded! Stopping!")
		return
	end
	Config = PocketMeroe.db.profile
	ClearModifier = Config.clear_modifier
	MarkingModifier = Config.marking_modifier

	if (PocketMeroeOptions) then
		PocketMeroeOptions:Show()
		return
	end


	--build the options window
	local optionsFrame = DF:CreateSimplePanel ("UIParent", 560, 330, "pocketMeroe Config", "PocketMeroeOptions")

	buildStatusAuthorBar(optionsFrame)
	local tabContainer = buildOptionsFrameTabs(optionsFrame)	-- build the tabs

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
	local general = tabContainer.AllFrames[1]
	local automarks = tabContainer.AllFrames[2]
	local tabFrameHeight = general:GetHeight()

	---  [meroe.general]  ---
	buildTab1Options(general, tabFrameHeight)
	
	--- [meroe.automarks] ---
	function PocketMeroe.ShowMarkScroll()
		if automarks.scroll then
			automarks.scroll:Show()
			return
		end
--[[ 		local backdrop_color = {.8, .8, .8, 0.2}
		local backdrop_color_on_enter = {.8, .8, .8, 0.4}

		local line_onenter = function (self)
			self:SetBackdropColor (unpack (backdrop_color_on_enter))
		end

		local line_onleave = function (self)
			self:SetBackdropColor (unpack (backdrop_color))
		end ]]

		---(self:df_scrollbox, data:table, offset:number, numlines:number)
		local refreshGrid = function(frame, data)
			if not frame or not data then return end
			if not data.text then 
				frame:Hide()  -- Hide the frame if data.text is not provided
				return
			end

			frame.text:SetText(data.text)

			if frame:GetObjectType() == "button" then
				frame:SetScript("OnClick", function(self) print("clicked option " .. data.text) end)
			elseif
				frame:GetObjectType() == "frame" then
			end
			frame:Show()
		end

		-- TODO: 
		-- % over columnIndex
		-- raidIcons selector -> clicky -> {8,7,6,5,4,3,2,1}
		-- data columns & refresh with if (npcData[id].instance[1] == value [+checks])


		--declare a function to create a column within a scroll line
		--this function will receive the line, the line index within the scrollbox and the column index within the line
		local createColumnFrame = function(line, lineIndex, columnIndex)
			if columnIndex == 1 then
				local fs = CreateFrame("frame", "$parentOptionFrame" .. lineIndex .. columnIndex, line)
				fs:SetSize(100, 20)
				fs.text = fs:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				fs.text:SetPoint("left", fs, "left", 0, 0)
				fs.text:SetText("Option " .. lineIndex .. columnIndex)

				local highlightTexture = fs:CreateTexture(nil, "HIGHLIGHT")
				highlightTexture:SetAllPoints()
				highlightTexture:SetColorTexture(1, 1, 1, 0.2)

				DF:ApplyStandardBackdrop(fs)

				return fs
			end
			if columnIndex == 2 then
				local marksBar = BuildMarksBar(line)
			end
			if true then
				local optionButton = CreateFrame("button", "$parentOptionFrame" .. lineIndex .. columnIndex, line)
				optionButton:SetPoint("right", line, "right", 0, 0)
				optionButton.text = optionButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				optionButton.text:SetPoint("right", optionButton, "right", 0, 0)
				optionButton.text:SetText("Option " .. lineIndex .. columnIndex)

				local highlightTexture = optionButton:CreateTexture(nil, "HIGHLIGHT")
				highlightTexture:SetAllPoints()
				highlightTexture:SetColorTexture(1, 1, 1, 0.2)

				DF:ApplyStandardBackdrop(optionButton)
				optionButton:SetSize(100, 20)

				return optionButton
			end
		end

		local options = {
			width = 510,
			height = 190,
			--amount of horizontal lines
			line_amount = 9,
			--amount of columns per line
			columns_per_line = 3,
			--height of each line
			line_height = 20,
			auto_amount = false,
			no_scroll = false,
			no_backdrop = false,
		}
		local data = {}

		function PocketMeroe.gui.getData () 
			if not PocketMeroeDB then
				print("PocketMeroe.marks.InitTooltips: Database not loaded! Stopping!")
				return
			end
			local npcData = PocketMeroe.db.profile.markersCustom
			for id, value in pairs (npcData) do
				--[mobID] = customMarks, priority, instanceShortcode,monsterType,unitName
				local customMarks, priority, instanceShortcode,monsterType,unitName = unpack(value)
				table.insert(data, {text = tostring(unitName)})
				table.insert(data, {text = ""})
				table.insert(data, {text = tostring(instanceShortcode) .." ".. tostring(monsterType)})
			end
			return data
		end
		PocketMeroe.gui.data = PocketMeroe.gui.getData()
		automarks.scroll = 	DF:CreateGridScrollBox(automarks, "$parentScroll", refreshGrid, PocketMeroe.gui.data, createColumnFrame, options)
		DF:ReskinSlider(automarks.scroll)
		automarks.scroll:SetPoint("bottom", automarks, "bottom", -10, 25)

		function automarks.scroll:UpdateList(_, _, option, value, value2, mouseButton)
				if (not automarks.scroll:IsShown()) then
					return
				end

				-- local npcData = PocketMeroe.db.profile.markersCustom
				-- for id, _ in pairs (npcData) do
				-- 	local raidIcons, priority, zone, sortCategory, name = unpack(npcData[id])
				-- 	-- if id and npcData[id] then print(id .. " " .. tostring(npcData[id][3])) end
				-- 	-- i really sure hope the same mob IDs dont appear in multiple instances.
				-- 	-- i think we're lucky enough that raid instances only contain monsters unique to that instance
				-- 	if (zone == value or value =="none" or not value) then
				-- 		if not name then name = id end
				-- 		--table.insert(data, {name, zone})
				-- 	end
				-- end
				-- --automarks.scroll:SetData(data)
				automarks.scroll:Refresh()
		end
	end

	PocketMeroe.ShowMarkScroll()

	buildTab2Options(automarks, tabFrameHeight)

	---
	PocketMeroeOptions:Hide();
	return PocketMeroeOptions;
end

gui.MenuToggle = function ()
	local menu = PocketMeroeOptions or gui.ShowMenu();
	if (menu) then
		menu:SetShown(not menu:IsShown());
		--needs to visually reset after closing the options menu
--[[ 		if automarks.scroll then
			automarks.scroll:UpdateList(nil, config.profile.var, true, "none");
		end ]]
	end
end

PocketMeroe.gui = gui

--[[
		TODO: Add "BossMods" tab to control boss encounter features.
		TODO: Implement boss encounter functionalities.
		TODO: Create frames for these and integrate with event handlers.
		TODO: Replace Tems' WeakAuras and dominate the world *cackles maniacally*


		TODO: Integrate external timers for raid usage.
		TODO: Implement assignment list for trash and sheeps.
		TODO: Calculate estimated timer to monster dying.
		TODO: Display distance to target, possibly on nameplates or screen.

		TODO: Incorporate raid role optimizer using officer notes.
]]