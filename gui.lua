local DF = _G["DetailsFramework"]

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

gui.autoMarkState = gui.autoMarkState or {}


local SetSetting = function(...)
	gui.OptionsOnClick(nil, nil, ...)
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


local function GetCursorPos(frame)
	local x_f,y_f = GetCursorPosition()
	local s = frame:GetEffectiveScale()
	x_f, y_f = x_f/s, y_f/s
	local x,y = frame:GetLeft(),frame:GetTop()
	x = x_f-x
	y = (y_f-y)*(-1)
	return x,y
end

local pm_data_names,pm_data_names_state = {},{}
function UpdateData()
	wipe(pm_data_names)
	wipe(pm_data_names_state)
	if type(gui.markMax) ~= "number" or gui.markMax < 100 then
		gui.markMax = 100
	end
	if type(gui.markMax) == "number" and gui.markMax > 1000 then
		gui.markMax = 1000
	end
	local lastNonZeroIndex = 0
	for i=1,gui.markMax do
		--local name = gui.autoMarkNames[i]
		local name = PocketMeroe.db.profile.markersCustom[1706][5] -- must be string!
		if name and name ~= "" then
			if name:find("^%-") then
				name = name:gsub("^%-","")
			end
			pm_data_names[ (name):lower() ] = true
			pm_data_names_state[ (name):lower() ] = gui.autoMarkState[i] or "87654321"
			lastNonZeroIndex = i
		end
	end
	if lastNonZeroIndex < 100 then
		lastNonZeroIndex = 100
	end
	gui.markMax = ceil(lastNonZeroIndex / 50) * 50
end

local function Tab2LineUpdate(self)
	local num = self._i
	--self.edit:SetText(gui.autoMarkNames[num] or "")
	--self.marks.state = gui.autoMarkState[num] or "87654321"
	
	for i=1,#self.marks.list do
		local mark = self.marks.state:sub(i,i)
		if mark ~= "" then
			self.marks.list[i]:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
			SetRaidTargetIconTexture(self.marks.list[i], tonumber(mark,19))
		else
			self.marks.list[i]:SetTexture()
		end
		if mark == self.marks.picked_mark then
			self.marks.list[i]:SetAlpha(.7)
		else
			self.marks.list[i]:SetAlpha(1)
		end
		self.marks.list[i]:SetShown(i <= 8 or self.isExpand)
	end
	if self.isExpand and not self.isExpanded then
		self.marks:SetWidth(20*17)
		self.edit:Size(470-20*8,20)
		self.isExpanded = true
	elseif not self.isExpand and self.isExpanded then
		self.marks:SetWidth(20*9)
		self.edit:Size(470,20)
		self.isExpanded = false
	end
end

local function Tab2MarksOnUpdate(self)
	if not IsMouseButtonDown(1) then
		self:SetScript("OnUpdate",nil)
		self.picked = nil
		self.picked_mark = nil
		gui.autoMarkState[self:GetParent()._i] = self.state
		self:GetParent():Update()
		UpdateData()
		return
	end
	local currCursor = 1
	for i=1,self.state_len do
		local x,y = GetCursorPos(self.list[i])
		if x < 0 then
			break
		end
		currCursor = i
	end
	local newState = self.saved_state:gsub(self.saved_state:sub(self.picked,self.picked),""):sub(1,currCursor-1) .. self.saved_state:sub(self.picked,self.picked) .. self.saved_state:gsub(self.saved_state:sub(self.picked,self.picked),""):sub(currCursor,-1)
	if newState ~= self.state then
		self.state = newState
		self:GetParent():Update()
	end
end
local function Tab2MarksOnMouseDown(self,button)
	self.picked_mark = nil
	if button == "LeftButton" then
		--print("LMB")
		local x,y = GetCursorPos(self.list.refresh)
		if x >= 0 and x <= 19 then
			self.state = self:GetParent().isExpand and "876543219ABCDEFG" or "87654321"
			gui.autoMarkState[self:GetParent()._i] = self.state
			self:GetParent():Update()
			UpdateData()
			return
		end
	
		self.picked = nil
		for i=1,#self.list do
			if self.list[i]:IsShown() then
				local x,y = GetCursorPos(self.list[i])
				if x >= 0 and x <= 19 then
					self.picked = i
					self.saved_state = self.state
					self.state_len = self.state:len()
					if self.state_len < i then
						return
					end
					break
				end
			end
		end
		if self.picked then
			self.picked_mark = self.saved_state:sub(self.picked,self.picked)
			self:SetScript("OnUpdate",Tab2MarksOnUpdate)
			self:GetParent():Update()
		end
	elseif button == "RightButton" then
		--print("RMB")
		local x,y = GetCursorPos(self.list.refresh)
		if x >= 0 and x <= 19 then
			--self:GetParent().isExpand = not self:GetParent().isExpand
			self:GetParent():Update()
			return
		end

		for i=1,#self.list do
			if self.list[i]:IsShown() then
				local x,y = GetCursorPos(self.list[i])
				if x >= 0 and x <= 19 then
					local newState = self.state:sub(1,i-1)..self.state:sub(i+1,-1)
					self.state = newState
					gui.autoMarkState[self:GetParent()._i] = newState
					self:GetParent():Update()
					UpdateData()
					break
				end
			end
		end			
	end
end
-- local function Tab2MarksListOnEnter(self)
-- 	self:GetParent().Background:Show()
-- end
-- local function Tab2MarksListOnLeave(self)
-- 	self:GetParent().Background:Hide()
-- end


local BuildMarksBar = function(parent)
	for i=1,9 do
		local marks = CreateFrame("Frame",nil,parent)
		marks:EnableMouse(true)
		marks.Background = marks:CreateTexture(nil,"BACKGROUND")
		marks.Background:SetColorTexture(0,0,0,.3)
		marks.Background:SetPoint("CENTER")
		marks.Background:SetPoint("CENTER")
		marks:SetPoint("RIGHT",-5,0)
		marks:SetSize(20*9,20)
		marks.list = {}
		for i=1,16 do
			marks.list[i] = marks:CreateTexture(nil,"ARTWORK")
			marks.list[i]:SetPoint("LEFT",(i-1)*20,0)
			marks.list[i]:SetSize(18,18)
			marks.list[i]:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
			SetRaidTargetIconTexture(marks.list[i], i)
			marks.list[i]:SetShown(i <= 8)
		end
		marks.list.refresh = marks:CreateTexture(nil,"ARTWORK")
		marks.list.refresh:SetPoint("RIGHT",0,0)
		marks.list.refresh:SetSize(18,18)
		marks.list.refresh:SetTexture([[Interface\AddOns\MRT\media\DiesalGUIcons16x256x128]])
		marks.list.refresh:SetTexCoord(0.125,0.1875,0.5,0.625)
		marks.list.refresh:SetVertexColor(1,1,1,0.7)	
	
		marks:SetScript("OnMouseDown",Tab2MarksOnMouseDown)
		
		marks.state = gui.autoMarkState[i] or "87654321"
		
		parent.marks = marks
		
		parent.Update = Tab2LineUpdate
		parent:Update()
		
		-- marks:SetScript("OnEnter",Tab2MarksListOnEnter)
		-- marks:SetScript("OnLeave",Tab2MarksListOnLeave)
	end
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

	local bottomGradient = DF:CreateTexture(optionsFrame,
		{ gradient = "vertical", fromColor = { 0, 0, 0, 0.3 }, toColor = "transparent" }, 1, 100, "artwork", { 0, 1, 0, 1 },
		"bottomGradient")
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
	---  [meroe.general]  ---
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
	DF:BuildMenu(general, generalOptionsTable, 10, -100, tabFrameHeight, false, options_text_template,
		options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template,
		profileCallback)

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

				DetailsFramework:ApplyStandardBackdrop(fs)

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

				DetailsFramework:ApplyStandardBackdrop(optionButton)
				optionButton:SetSize(100, 20)

				line._i = lineIndex
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
		local data = {
			-- {text = "1"}, {text = "2"}, {text = "3"}, {text = "4"}, {text = "5"}, {text = "6"}, {text = "7"}, {text = "8"}, {text = "9"}, {text = "10"},
			-- {text = "11"}, {text = "12"}, {text = "13"}, {text = "14"}, {text = "15"}, {text = "16"}, {text = "17"}, {text = "18"}, {text = "19"}, {text = "20"},
			-- {text = "21"}, {text = "22"}, {text = "23"}, {text = "24"}, {text = "25"}, {text = "26"}, {text = "27"}, {text = "28"}, {text = "29"}, {text = "30"},
			-- {text = "31"}, {text = "32"}, {text = "33"}, {text = "34"}, {text = "35"}, {text = "36"}, {text = "37"}, {text = "38"}, {text = "39"}, {text = "40"},
			-- {text = "41"}, {text = "42"}, {text = "43"}, {text = "44"}, {text = "45"}, {text = "46"}, {text = "47"}, {text = "48"}, {text = "49"}, {text = "50"},
			-- {text = "51"}, {text = "52"}, {text = "53"}, {text = "54"}, {text = "55"}, {text = "56"}, {text = "57"}, {text = "58"}, {text = "59"}, {text = "60"},
			-- {text = "61"}, {text = "62"}, {text = "63"}, {text = "64"}, {text = "65"}, {text = "66"}, {text = "67"}, {text = "68"}, {text = "69"}, {text = "70"},
			-- {text = "71"}, {text = "72"}, {text = "73"}, {text = "74"}, {text = "75"}, {text = "76"}, {text = "77"}, {text = "78"}, {text = "79"}, {text = "80"},
			-- {text = "81"}, {text = "82"}, {text = "83"}, {text = "84"}, {text = "85"}, {text = "86"}, {text = "87"}, {text = "88"}, {text = "89"}, {text = "90"},
			-- {text = "91"}, {text = "92"}, {text = "93"}, {text = "94"}, {text = "95"}, {text = "96"}, {text = "97"}, {text = "98"}, {text = "99"}, {text = "100"},
		}

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
					automarks.scroll:UpdateList(nil, var, true, raid.value)
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
			values = function () return BuildRaidOptions(Config.var, automarks.scroll) end,
			name = "Raid:",
			--desc = "",
		},
	}

	automarks.scroll:UpdateList()
	DF:BuildMenu(automarks, automarksOptionsTable, 10, -100, tabFrameHeight, false, options_text_template,
		options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template,
		profileCallback)

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