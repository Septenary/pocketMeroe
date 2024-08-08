local DF = _G ["DetailsFramework"]

local gui = {}
gui.scrollBox = {}

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

local scrollConfig = {
	scroll_width = 510,
	scroll_height = 174,
	scroll_line_height = 18,
	scroll_lines = 9,
	backdrop_color = {.4, .4, .4, .2},
	backdrop_color_highlight = {.4, .4, .4, .6},
}


gui.SetSetting = function(...)
	gui.OptionsOnClick(nil, nil, ...)
end

gui.CreateScrollBox = function(self)
	local scrollBox = DF:CreateScrollBox(self, "$parent.Scrolling", self.markListRefresh, {}, scrollConfig.scroll_width, scrollConfig.scroll_height, scrollConfig.scroll_lines, scrollConfig.scroll_line_height, gui.CreateScrollBoxLine, true)
	DF:ReskinSlider (scrollBox)

    for i = 1, scrollConfig.scroll_lines do
		local line = scrollBox:CreateLine(self, i)
        line:SetPoint("TOP", 0, -35 - (i - 1) * scrollConfig.scroll_line_height)
        line:SetPoint("LEFT", 5, 0)
        line:SetPoint("RIGHT", -25, 0)
        line:SetHeight(scrollConfig.scroll_line_height)
        line._i = i
    end

	function scrollBox:UpdateList(_, _, option, value, value2, mouseButton)
		local data = {}
		local npcData = PocketMeroe.db.profile.markersCustom
		for id, _ in pairs (npcData) do
			local raidIcons, priority, zone, sortCategory, name = unpack(npcData[id])
			-- if id and npcData[id] then print(id .. " " .. tostring(npcData[id][3])) end
			-- i really sure hope the same mob IDs dont appear in multiple instances.
			-- i think we're lucky enough that raid instances only contain monsters unique to that instance
			if (zone == value or value =="none" or not value) then
				if not name then name = id end
				table.insert(data, {name, zone})
			end
		end
		scrollBox:SetData(data)
		scrollBox:Refresh()
	end
	scrollBox:UpdateList()
	scrollBox.OnSelect = function(selectedIconId, lineIndex)
		print("Icon " .. selectedIconId .. " selected for line " .. lineIndex)
	end
	gui.scrollBox = scrollBox
    return scrollBox
end

gui.SetModifier = function(_, var, value, key)
	if Config[var] then
		Config [var].none = false
		Config [var].alt = false
		Config [var].ctrl = false
		Config [var].shift = false
		Config [var] [key] = value
	end
end

local BuildRaidOptions = function(var)
    local raids = {
        { label = "All",       value = "none" },
        { label = "Zul'Gurub", value = "ZG" },
        { label = "Ruins of Ahn'Qiraj", value = "AQ20" },
        { label = "Molten Core", value = "MC" },
        { label = "Blackwing Lair", value = "BWL" },
        { label = "Temple of Ahn'Qiraj", value = "AQ40" },
        { label = "Naxxramas", value = "NAXX" },
    }

    local result = {}

    for _, raid in ipairs(raids) do
        table.insert(result, {
            label = raid.label,
            value = raid.value,
            onclick = function()
                gui.scrollBox:UpdateList(nil, var, true, raid.value)
            end,
        })
    end

    return result
end

local BuildModifierOptions = function(var)
    local modifiers = {"none", "alt", "ctrl", "shift"}
    local result = {}

    for _, modifier in ipairs(modifiers) do
        table.insert(result, {
            label = modifier:gsub("^%l", string.upper),  -- Capitalize the first letter
            value = modifier,
            onclick = function()
                gui.SetModifier(nil, var, true, modifier)
            end,
        })
    end

    return result
end

gui.OptionsOnClick = function(_, _, option, value, value2, mouseButton)
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

gui.CreateScrollBoxLine = function (scrollBox, index)
	local line = scrollBox:CreateLine()

	line:SetSize(scrollConfig.scroll_width - 2, scrollConfig.scroll_line_height)

	local marksContainer = CreateFrame("Frame", nil, line)
	marksContainer:SetSize(scrollConfig.scroll_width - 2, scrollConfig.scroll_line_height)
	marksContainer:SetPoint("CENTER")
	marksContainer:EnableMouse(true)

	local iconSize = 32
	local icons = {}
	for id, texture in pairs(raidIcons) do
		local button = CreateFrame("Button", nil, marksContainer)
		button:SetSize(iconSize, iconSize)
        button:SetPoint("LEFT", marksContainer, "LEFT", (id - 1) * (iconSize + 5), 0)

		button.icon = button:CreateTexture(nil, "BACKGROUND")
		button.icon:SetAllPoints()
		button.icon:SetTexture(texture)

		button:SetScript("OnClick", function()
			if self.onSelect then 
				self.onSelect(id, index)
			end
		end)

		icons[id] = button
	end

	line.icons = icons

	local defaultIconId = 1
	line:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
	})
	line:SetBackdropBorderColor(1, 1, 1, 0)

	return line
end

gui.updateIconSelector = function(line, selectedIconId)
	for id, button in pairs(line.icons) do
		if id == selectedIconId then
			button:SetBackdropBorderColor(1, 1, 1, 1)
		else
			button:SetBackdropBorderColor(1, 1, 1, 0)
		end
	end
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
	local optionsFrame = DF:CreateSimplePanel ("UIParent", 560, 330, "pocketMeroe Config", "PocketMeroeOptions")

    local statusBar = CreateFrame("frame", "$parent.Status", optionsFrame, "BackdropTemplate")
    statusBar:SetHeight(20)
    statusBar:SetAlpha(0.9)
    statusBar:SetFrameLevel(optionsFrame:GetFrameLevel()+2)
    statusBar:ClearAllPoints()
    statusBar:SetPoint("BOTTOMLEFT", optionsFrame, "BOTTOMLEFT")
    statusBar:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT")

    local authorInfo = DF:CreateLabel(statusBar, "|cFFFFFFFFmeroe|r |cFFFFFFFF<Serenity>|r - Mankrik")
    authorInfo:SetPoint("left", statusBar, "left", 6, 0)
    authorInfo:SetAlpha(.6)
    authorInfo.textcolor = "silver"

    statusBar.authorInfo = authorInfo
    DF:ApplyStandardBackdrop(statusBar)

    local bottomGradient = DF:CreateTexture(optionsFrame, {gradient = "vertical", fromColor = {0, 0, 0, 0.3}, toColor = "transparent"}, 1, 100, "artwork", {0, 1, 0, 1}, "bottomGradient")
    bottomGradient:SetAllPoints(optionsFrame, 1)
    bottomGradient:SetPoint("bottom-top", statusBar)

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

	local tabContainer = DF:CreateTabContainer(optionsFrame, "pocketMeroe", "$parent.tabContainer", tabList, optionsTable, hookList)
												
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
	local general = tabContainer.AllFrames[1]
	local automarks = tabContainer.AllFrames[2]
	local tabFrameHeight = general:GetHeight()
	--- meroe.general
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
					return Config.use_mouseover
				end,
				set = function(self, fixedparam, value)
					gui.SetSetting("use_mouseover", Config.use_mouseover)
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
					gui.SetSetting("require_leader", Config.require_leader)
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
		DF:BuildMenu(general, optionsTable, 10, -100, tabFrameHeight, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, profileCallback)

	end

	--- meroe.automarks
	do
		-- local markers = Config.raidMarkers

		local optionsTable = {
			always_boxfirst = false,
			{
				type = "select",
				get = function() 
					return "none" or "ZG" or "AQ20" or "MC" or "BWL"
				end,
				values = function () return BuildRaidOptions(Config.var) end,
				name = "Raid:",
				--desc = "",

			},
		}
		--optionsTable.always_boxfirst = true
		DF:BuildMenu(automarks, optionsTable, 10, -100, tabFrameHeight, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, profileCallback)
		gui.CreateScrollBox(automarks)
	
	end
    --_G["automarksScroll"] = setmetatable({}, {__index = ScrollBox })
    --automarksScroll:Create(automarks)
    --automarksScroll:Show()

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
	PocketMeroeOptions:Hide();
	return PocketMeroeOptions;
end

gui.MenuToggle = function ()
	local menu = PocketMeroeOptions or gui.ShowMenu();
	if (menu) then
		menu:SetShown(not menu:IsShown());
		--needs to visually reset after closing the options menu
--[[ 		if automarksScroll then
			automarksScroll:UpdateList(nil, config.profile.var, true, "none");
		end ]]
	end
end

PocketMeroe.gui = gui