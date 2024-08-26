local DF = _G["DetailsFramework"]

local gui = {}
gui.scrollBox = {}

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

local profileCallback = function()
	-- executes whenever profile settings are changed
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

	local tabContainer = DF:CreateTabContainer(parent, "pocketMeroe", "$parent.tc", tabList, optionsTable,
		hookList)
	tabContainer:SetPoint("center", parent, "center", 0, 0)
	tabContainer:SetSize(parent:GetSize())
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
	DF:BuildMenu(parentTab, generalOptionsTable, 10, -100, tabFrameHeight, false, options_text_template,
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

-- get cursor position relative to a frame
local function GetCursorPos(frame)
	local x_f,y_f = GetCursorPosition()
	local s = frame:GetEffectiveScale()
	x_f, y_f = x_f/s, y_f/s
	local x,y = frame:GetLeft(),frame:GetTop()
	x = x_f-x
	y = (y_f-y)*(-1)
	return x,y
end

local function Tab2LineUpdate(self)
	local num = self._i
	--self.edit:SetText(gui.autoMarkNames[num] or "")
	--self.marks.state = gui.autoMarkState[num] or {8, 7, 6, 5, 4, 3, 2, 1}
	if not self.id then self.marks.state = {8, 7, 6, 5, 4, 3, 2, 1} end
	--print ("Update ", self.id)
	self.marks.state = PocketMeroe.ProfileGet(self.id, "customMarks")
	if self.marks.state == {} then self.marks.state = {8, 7, 6, 5, 4, 3, 2, 1} end
	--print("State: ", self.marks.state)
	for i=1,#self.marks.list do
		local mark = self.marks.state[i]
		if mark and mark ~= "" then
			self.marks.list[i]:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
			SetRaidTargetIconTexture(self.marks.list[i], tonumber(mark,9))
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
		self.id = self:GetParent().id
		--print("id: ", self.id)
		self.state = PocketMeroe.ProfileGet(self.id, "customMarks")
		
		--gui.autoMarkState[self:GetParent():GetParent()._i] = self.state
		self:GetParent():Update()
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
	--local newState = self.saved_state:gsub(self.saved_state:sub(self.picked,self.picked),""):sub(1,currCursor-1) .. self.saved_state:sub(self.picked,self.picked) .. self.saved_state:gsub(self.saved_state:sub(self.picked,self.picked),""):sub(currCursor,-1)
	-- prolly did this wrong..
	local function removeElementAtIndex(t, i)
		local newTable = {}
		for index, value in ipairs(t) do
			if index ~= i then
				table.insert(newTable, value)
			end
		end
		return newTable
	end
	
	local function insertElementAtIndex(t, element, index)
		local newTable = {}
		for i = 1, index - 1 do
			table.insert(newTable, t[i])
		end
		table.insert(newTable, element)
		for i = index, #t do
			table.insert(newTable, t[i])
		end
		return newTable
	end
	
	-- Remove the picked element
	local tempState = removeElementAtIndex(self.saved_state, self.picked)
	-- Create newState by inserting the picked element at currCursor
	local newState = insertElementAtIndex(tempState, self.saved_state[self.picked], currCursor)
	
	-- for _, v in ipairs(newState) do
	-- 	print(v)
	-- end
	-- print (newState)

	if newState ~= self.state then
		self.state = newState
		self:GetParent():Update()
	end
end
local function Tab2MarksOnMouseDown(self,button)
	self.id = self:GetParent().id
	--print("Mousedown: ", self.id)
	self.state = PocketMeroe.ProfileGet(self.id, "customMarks")
	--print("mdState: ", self.state)

	self.picked_mark = nil
	if button == "LeftButton" then
		--print("LMB")
		local x,y = GetCursorPos(self.list.refresh)
		--print("x", x, "y", y)
		if x >= 0 and x <= 19 then
			--self.state = {8, 7, 6, 5, 4, 3, 2, 1}
			--gui.autoMarkState[self:GetParent()._i] = self.state
			self:GetParent():Update()
			return
		end
	
		self.picked = nil
		for i=1,#self.list do
			if self.list[i]:IsShown() then
				local x,y = GetCursorPos(self.list[i])
				--print("x", x, "y", y)
				if x >= 0 and x <= 19 then
					self.picked = i
					--print(self.picked)
					self.saved_state = self.state
					self.state_len = #self.state
					if self.state_len < i then
						return
					end
					break
				end
			end
		end
		if self.picked then
			self.picked_mark = self.saved_state[self.picked]
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
					--local newState = self.state:sub(1,i-1)..self.state:sub(i+1,-1)
					local function removeElementAtIndex(t, i)
						local newState = {}
						for index, value in ipairs(t) do
							if index ~= i then
								table.insert(newState, value)
							end
						end
						return newState
					end
					
					local newState = removeElementAtIndex(self.state, i)						
					-- Print the new state to verify
					-- for _, v in ipairs(newState) do
					-- 	print(v)
					-- end
					self.state = newState
					if self.id then
						--print("list: ", self.id)
						--PocketMeroe.ProfileSet(self.id, "customMarks", self.state)
					end
					--gui.autoMarkState[self:GetParent()._i] = newState
					self:GetParent():Update()
					break
				end
			end
		end			
	end
end

local BuildTab2MarksBar = function(parent)
	local line = CreateFrame("Frame",nil,parent)
	do
		line.id = parent._id
		line:SetPoint("LEFT",5,0)
		line:SetPoint("RIGHT",-130,0)
		line:SetHeight(25)
	end

	local marks = CreateFrame("Frame",nil,line)
	do
		marks:EnableMouse(true)
		marks.Background = marks:CreateTexture(nil,"BACKGROUND")
		marks.Background:SetColorTexture(0,0,0,.3)
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
		

		marks.state = {8, 7, 6, 5, 4, 3, 2, 1}
		--gui.autoMarkState[i] or {8, 7, 6, 5, 4, 3, 2, 1}
		
		line.marks = marks
		
		line.Update = Tab2LineUpdate
		line:Update()
	end
		--marks:SetScript("OnEnter",Tab2MarksListOnEnter)
		--marks:SetScript("OnLeave",Tab2MarksListOnLeave)
end
-- local function Tab2MarksListOnEnter(self)
-- 	self:GetParent().Background:Show()
-- end
-- local function Tab2MarksListOnLeave(self)
-- 	self:GetParent().Background:Hide()
-- end


function PocketMeroe.ShowMarkScroll(parentTab)
	if parentTab.scroll then
		parentTab.scroll:Show()
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
		local npcData = PocketMeroe.db.profile.markersCustom
		if not frame or not data then return end
		if not data.text then
			frame:Hide()  -- Hide the frame if data.text is not provided
			return
		end

		frame.text:SetText(data.text)

		--print(DF.ScrollBoxFunctions:GetData(frame))
		if frame:GetObjectType() == "button" then
			frame:SetScript("OnClick", function(self) print("clicked option " .. data.text) end)
		elseif
			frame:GetObjectType() == "frame" then
		end
		frame:Show()
	end

	-- TODO: 
	-- raidIcons selector -> clicky -> {8,7,6,5,4,3,2,1}
	-- data columns & refresh with if (npcData[id].instance[1] == value [+checks]) -- SEARCH? searchBox df_searchbox


	--declare a function to create a column within a scroll line
	--this function will receive the line, the line index within the scrollbox and the column index within the line


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
			table.insert(data, {text = tostring(id)})
			table.insert(data, {text = tostring(instanceShortcode) .." ".. tostring(monsterType)})
		end
		return data
	end

	local createColumnFrame = function(line, lineIndex, columnIndex)
		if line then
			line._i = lineIndex
		end
		if columnIndex == 1 then
			local fs = CreateFrame("frame", "$parentG" .. lineIndex .. columnIndex, line)
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
			local optionButton = CreateFrame("button", "$parentG" .. lineIndex .. columnIndex, line)
			optionButton:SetPoint("center", line, "center", 0, 0)
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
		if columnIndex == 3 then
			local optionButton = CreateFrame("button", "$parentG" .. lineIndex .. columnIndex, line)
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


	PocketMeroe.gui.data = PocketMeroe.gui.getData()
	parentTab.scroll = 	DF:CreateGridScrollBox(parentTab, "$parentScroll", refreshGrid, PocketMeroe.gui.data, createColumnFrame, options)
	DF:ReskinSlider(parentTab.scroll)
	parentTab.scroll:SetPoint("bottom", parentTab, "bottom", -10, 25)
	gui.automarks.scroll:Refresh()

	for i, line in ipairs(parentTab.scroll:GetFrames()) do
		line._id = line.optionFrames[2].text:GetText()
		print ("line_id", line._id)
		BuildTab2MarksBar(line)
	end

	function gui.automarks.scroll:UpdateList(_, _, option, value, value2, mouseButton)
			if (gui.automarks.scroll and (not gui.automarks.scroll:IsShown())) then
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
			gui.automarks.scroll:Refresh()
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

	if (meroe) then
		meroe:Show()
		return
	end


	--build the options window
	local optionsFrame = DF:CreateSimplePanel ("UIParent", 560, 330, "pocketMeroe Config", "meroe")

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
	
	-- immediately add this to "namespace"
	gui.general = general
	gui.automarks = automarks

	---  [meroe.general]  ---
	buildTab1Options(general, tabFrameHeight)
	
	
	--- [meroe.automarks] ---
	PocketMeroe.ShowMarkScroll(automarks)
	buildTab2Options(automarks, tabFrameHeight)

	---
	meroe:Hide();
	return meroe;
end

gui.MenuToggle = function ()
	local menu = meroe or gui.ShowMenu();
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