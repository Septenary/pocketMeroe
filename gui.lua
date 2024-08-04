local _, PocketMeroe = ...

local DF = _G ["DetailsFramework"]
local PocketMeroe = _G ["PocketMeroe"]
local ClearModifier = PocketMeroe.db.ClearModifier
local MarkingModifier = PocketMeroe.db.MarkingModifier

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
                PocketMeroe.markingScroll:UpdateList(nil, var, true, raid.value)
            end,
        })
    end

    return result
end


function PocketMeroe.ShowMenu()
	-- toggle configuration menu
	if (PocketMeroeMenu) then
		PocketMeroeMenu:Show()
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
	local optionsFrame = DF:CreateSimplePanel (UIParent, 560, 330, "pocketMeroe Config", "PocketMeroeMenu")
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
					PocketMeroe.SetSetting("use_mouseover", PocketMeroe.db.profile.use_mouseover)
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
					PocketMeroe.SetSetting("require_leader", PocketMeroe.db.profile.require_leader)
				end,
				name = "Require Leader",
				desc = "If toggled then you must be the leader to mark mobs.",
			},
			{
				type = "select",
				get = function()
					return MarkingModifier.none and "none" or MarkingModifier.alt and "alt" or MarkingModifier.ctrl and "ctrl" or MarkingModifier.shift and "shift"
				end,
				values = function () return PocketMeroe.BuildModifierOptions("marking_modifier") end,
				name = "Marking Modifier",
				desc = "Require this modifier key to be held down for mouseover marking to work. ",
			},
			{
				type = "select",
				get = function() 
					return ClearModifier.none and "none" or ClearModifier.alt and "alt" or ClearModifier.ctrl and "ctrl" or ClearModifier.shift and "shift"
				end,
				values = function () return PocketMeroe.BuildModifierOptions("clear_modifier") end,
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
					return "none" or "ZG" or "AQ20" or "MC" or "BWL"
				end,
				values = function () return BuildRaidOptions(PocketMeroe.db.profile.var) end,
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

		if (not PocketMeroeScrollPanel) then
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
							line.markerType:SetText(tostring(markerType))
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
			local createLine = function(self, index)
				local line = CreateFrame ("button", "$parentLine" .. index, self, "BackdropTemplate")
				line:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -((index-1)*(config.scroll_line_height+1)) - 1)
				line:SetSize(config.scroll_width - 2, config.scroll_line_height)

				line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
				line:SetBackdropColor(unpack (config.backdrop_color))

				local name = line:CreateFontString ("$parentName", "OVERLAY", "GameFontNormal")
				local markerType = line:CreateFontString ("$parentName", "OVERLAY", "GameFontNormal")

				DF:SetFontSize (name, 10)
				DF:SetFontSize (markerType, 10)

				name:SetPoint("LEFT", line, "LEFT", 4, 0)
				markerType:SetPoint("RIGHT", line, "RIGHT", -4, 0)

				

				line.name = name
				line.markerType = markerType
				return line
			end

			--create the scroll widgets
			for i = 1, config.scroll_lines do
				local line = markingScroll:CreateLine (createLine, i)
				line:SetPoint("TOP",0,-35-(i-1)*25)
				line:SetPoint("LEFT",5,0)
				line:SetPoint("RIGHT",-25,0)
				line:SetHeight(25)
				line._i = i

				local marks = CreateFrame("Frame",nil,line)
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
				line.marks = marks
			end

			--this build a list of units and send it to the scroll
			function markingScroll:UpdateList(_, _, option, value, value2, mouseButton)
				local data = {}
				local npcData = PocketMeroe.db.profile.markersCustom
				for id, _ in pairs (npcData) do
					-- if id and npcData[id] then print(id .. " " .. tostring(npcData[id][3])) end
					-- i really sure hope the same mob IDs dont appear in multiple instances.
					-- i think we're lucky enough that raid instances only contain monsters unique to that instance
					if (npcData[id][3] == value or value =="none" or not value) then
						local name = npcData[id][5] or id
						local markerType = ""
						if type(npcData[id][2])~="table" then markerType = "#".. npcData[id][2] else markerType = "#10" end
						tinsert (data, {name, markerType})
					end
				end
				markingScroll:SetData (data)
				markingScroll:Refresh()
			end
			markingScroll:UpdateList()
			markingScroll:Show()
		end
	end


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

--[[ 	
		local scenario = CreateFrame("frame", "PocketMeroeScenario", UIParent, "BackdropTemplate")
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
