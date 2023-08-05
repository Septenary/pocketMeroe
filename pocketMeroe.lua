local _, pocketMeroe = ...; -- Namespace
pocketMeroe.Config = {};
local Config = pocketMeroe.Config;
aura_env = {};

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
        raidMarkers = {
            focus = {
                false, 
                false, 
                false, 
                false, 
                false, 
                false, 
                true, 
                true,
            },
            focus2 = {
                false, 
                true, 
                false, 
                true, 
                false, 
                false, 
                false, 
                false,
            },
            primary = {
                false, 
                true, 
                false, 
                true, 
                false, 
                true, 
                false, 
                true,  
            },
            secondary = {
                true, 
                false, 
                true, 
                false, 
                true, 
                false, 
                true,  
                false, 
            },
            sheep = {
                false, 
                false, 
                false, 
                false, 
                true, 
                true, 
                false, 
                false,        
            },
            banish = {
                false, 
                false, 
                false, 
                false, 
                true, 
                true, 
                false, 
                false,      
            },
            shackle = {
                false, 
                false, 
                true, 
                true, 
                false, 
                false, 
                false, 
                false,      
            },
            fear = {
                false, 
                false, 
                false, 
                false, 
                true, 
                true, 
                false, 
                false,
            },
        },
        raidMarkersCustom = {
            
        },
    },
};


local npcData = {};

-- Stockades Test
npcData['1706'] = {
    markerType = {"sheep"},
    abilities = { 1769, 676 },
    extra = {
        { icon = 136071, text = "Sheep", description = "These disarm and kick." }
    }
};
npcData['1707'] = {
    markerType = {"focus"},
    abilities = { 29306 },
    extra = {
        { icon = 38768, text = "Defias Captive (Rogues)", description = "Found in the Stockade" }
    }
};
npcData['1708'] = {
    markerType = {"focus"},
    abilities = { 1423 },
    extra = {
        { icon = 132349, text = "Defias Inmate (Warriors)", description = "Found in the Stockade" }
    }
};

-- ZG          --
-- -- Trash    --
npcData['14750'] = {
    name = "Gurubashi Bat Rider",
    markerType = {"focus"},
    abilities = { 19641 },
};
npcData['11830'] = {
    name = "Hakkari Priest",
    markerType = {"focus"},
    abilities = { 12039 },
    extra = {
        { icon = 132349, text = "AoE Fear", description = "Does an 8 second AoE Fear" }
    }
};
npcData['11353'] = {
    name = "Gurubashi Blood Drinker",
    markerType = {"sheep"},
    abilities = { 16608 },
};
-- Molten Core --
-- -- Trash    --
npcData['12076'] = {
    name = "Lava Elemental",
    markerType = {"banish"},
    abilities = { 19641 },
};
npcData['12100'] = {
    name = "Lava Reaver",
    markerType = {"banish"},
    abilities = { 20571 },
};
npcData['11659'] = {
    name = "Molten Destroyer",
    markerType = {"focus"},
    abilities = { 19129 },
};
-- -- Bosses   --
npcData['12119'] = {
    name = "(Lucifron) Flamewaker Protector",
    markerType = {"focus"},
    abilities = { 12721 },
};
npcData['12099'] = {
    name = "(Garr) Firesworn",
    markerType = {"primary", "secondary"},
    abilities = { 20483 },
    extra = {
        { icon = 135830, text = "Explodes on Death", description = "30yd Range" }
    }
};
npcData['11672'] = {
    name = "(Golemagg) Core Rager",
    markerType = {"shackle"},
    abilities = { 22570 },
};
npcData['11662'] = {
    name = "(Sulfuron Harbinger) Flamewaker Priest",
    markerType = {"secondary"},
    abilities = { 19775 },
};
npcData['11663'] = {
    name = "(Majordomo Executus) Flamewaker Healer",
    markerType = {"secondary"},
    abilities = { 20420, 21077 },
};
npcData['11664'] = {
    name = "(Majordomo Executus / Gehennas) Flamewaker Elite",
    markerType = {"primary"},
    abilities = {},
};

-- Blackwing Lair --
-- -- Trash       --
npcData['12468'] = {
    name = "Death Talon Hatcher",
    markerType = {"primary, secondary"},
    abilities = {},
    extra = {
        { icon = 135830, text = "High Priority!", description = "Rogues cannot do suppression room without these cleared." }
    }
};
npcData['12458'] = {
    name = "Blackwing Taskmaster",
    markerType = {"secondary"},
    abilities = { 17289, 22458},
};
npcData['12459'] = {
    name = "Blackwing Warlock",
    markerType = {"primary, secondary"},
    abilities = { 22336, 19717, 22372},
};
npcData['12457'] = {
    name = "Blackwing Spellbinder",
    markerType = {"secondary"},
    abilities = { 22275, 22274},
};
-- -- Vael Pack    --
npcData['12467'] = {
    name = "Death Talon Captain",
    markerType = {"rt4"},
    abilities = { 22440, 22436},
};
npcData['12463'] = {
    name = "Death Talon Flamescale",
    markerType = {"focus"},
    abilities = { 29228},
};
npcData['12464'] = {
    name = "Death Talon Seether",
    markerType = {"rt7, rt6, rt5"},
    abilities = { 23341, 21340},
};
npcData['12465'] = {
    name = "Death Talon Wyrmkin",
    markerType = {"shackle, rt2, rt1"},
    abilities = { 13021, 11988},
};

-- -- Bosses      --
npcData['12420'] = {
    name = "(Razorgore) Blackwing Mage",
    markerType = {"primary, secondary"},
    abilities = { 22271, 17290},
};


--   AQ20    --
-- -- Trash  --
-- -- Bosses --
npcData['15514'] = {
    name = "(Buru) Buru Egg",
    markerType = {"primary, secondary"},
    abilities = { 19593 },
};
npcData['15391'] = {
    name = "(General Rajaxx) Captian Qeez",
    markerType = {"secondary"},
    abilities = { 19134 },
    extra = {
        { icon = 132154, text = "AOE fear", description = "Captain Qeez has a low-range  Intimidating Shout AOE fear. Ranged DPS and healers should stay away from Qeez while melee need to be careful about the fear." }
    }
};
npcData['15392'] = {
    name = "(General Rajaxx) Captian Tuubid",
    markerType = {"secondary"},
    abilities = { 25471 },
    extra = {
        { icon = 132212, text = "Attack Order", description = "Captain Tuubid has  Attack Order, a focus attack ability that sends all mobs in the wave to attack the marked target. CCs are really important in this wave, and must be kept up at all costs while Tuubid is alive." }
    }
};
npcData['15389'] = {
    name = "(General Rajaxx) Captian Drenn",
    markerType = {"secondary"},
    abilities = { 27530 },
    extra = {
        { icon = 136018, text = "Hurricane", description = "One of the more particularly challenging waves, Captain Drenn has a  Hurricane that he casts in the area around him. This can be especially dangerous if Andorov is caught in the Hurricane - If this happens, the tanks need to get threat from Drenn and move him away from the Hurricanes so Andorov follows him and gets moved safely out of the AOE." }
    }
};
npcData['15390'] = {
    name = "(General Rajaxx) Captian Xurrem",
    markerType = {"secondary"},
    abilities = { 25425 },
    extra = {
        { icon = 136105, text = "Shockwave", description = "Captain Xurrem has an AOE  Shockwave ability that deals significant damage around him. Melee need to be especially careful with this wave, and it might be a good idea to move the melee to kill the trash mobs in the wave while the ranged DPS take care of Xurrem." }
    }
};
npcData['15386'] = {
    name = "(General Rajaxx) Major Yeggeth",
    markerType = {"primary"},
    abilities = { 23415 },
    extra = {
        { icon = 135964, text = "Improved Blessing of Protection", description = "Major Yeggeth has an  Improved Blessing of Protection that he casts on himself, leaving him immune to Physical damage for 5 seconds. Ranged DPS needs to be careful with threat in this wave, as tanks have no way of generating threat during this. As the duration isn't very long, melee can just wait it out before attacking Yeggeth again." }
    }
};
npcData['15388'] = {
    name = "(General Rajaxx) Major Pakkon",
    markerType = {"primary"},
    abilities = { 25322 },
    extra = {
        { icon = 132111, text = "Sweeping Slam", description = "Major Pakkon has a  Sweeping Slam ability that deals significant damage and knocks back enemies in front of him. However, this is easily dealt with - Tank Pakkon against a wall to minimize the knockback, while melee stands behind him to avoid it completely." }
    }
};
npcData['15385'] = {
    name = "(General Rajaxx) Colonel Zerran",
    markerType = {"primary"},
    abilities = { 136101 },
    extra = {
        { icon = 136101, text = "Enlarge", description = "Colonel Zerran has an  Enlarge that he can cast on both himself and the adds on his wave that increase Physical damage done. This enlarge is dispensable by offensive magic dispells and simply needs to be dispelled as it happens." }
    }
};
npcData['15341'] = {
    name = "(General Rajaxx) General Rajaxx",
    markerType = {"rt8"},
    abilities = { 25599 },
    extra = {
        { icon = 136105, text = "Thundercrash", description = "Rajaxx's most dangerous ability is  Thundercrash, a zone-wide AOE knockback that he uses very often. This knockback deals half of the raid's current health (minimum of 100 damage) in damage and wipes all aggro from everyone when it happens." }
    }
};


-- TODO: cooltip clears
-- TODO: leaving or entering an instance fucks the configuation panel



-- (details framework) get the framework table
local DF = _G ["DetailsFramework"]
-- if (not DF) then
-- 	print ("|cFFFFAA00pocketMeroe: framework not found, if you just installed or updated the addon, please restart your client.|r")
-- 	return
-- end  

function pocketMeroe:OnInit(event, name)
    if (name ~= "pocketMeroe") then return end --forgot why
    local function HandleSlashCommands(str)
            Config.Toggle();
    end
    --local function EasterEggKish(str)
    -- TODO: Somethin funny lmao
    --end
    SLASH_Meroe1 = "/meroe";
    --SLASH_Kishibe1 = "/kishibe"
    SlashCmdList.Meroe = HandleSlashCommands;
    --SlashCmdList.Kishibe = EasterEggKish;
	if (pocketMeroe.db:GetCurrentProfile() ~= "Default") then
		pocketMeroe.db:SetProfile("Default")
	end
    pocketMeroe.db.RegisterCallback(pocketMeroe, "OnProfileChanged", "RefreshConfig")
    local markevents = CreateFrame("frame");

    markevents:RegisterEvent("MODIFIER_STATE_CHANGED")
    markevents:RegisterEvent("PLAYER_TARGET_CHANGED")
    markevents:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    
    markevents:SetScript("OnEvent", pocketMeroe.eventsHandle);
    pocketMeroe:initTooltips()
    pocketMeroe:initMarks()
    --pocketMeroe.db.RegisterCallback (pocketMeroe, "OnDatabaseShutdown", "CleanUpJustBeforeGoodbye")
end
---------------------------------------------------------------------------------------------------
-- (details framework doesnt init automagically, we must do it ourselves?)
local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", pocketMeroe.OnInit);
-- (details framework) create the addon object
pocketMeroe = DF:CreateAddOn ("pocketMeroe", "pocketMeroeDB", default_config)
------ Database Loads in here ---------------------------------------------------------------------
function pocketMeroe:RefreshConfig()
    --
end

local options_on_click = function(_, _, option, value, value2, mouseButton)
    -- helpers.markersCustom = { 
    --     "focus", "focus2", "primary", "secondary", "sheep", "banish", "shackle", "fear",
    --     "rt8", "rt7", "rt6", "rt5", "rt4", "rt3", "rt2", "rt1"
    -- }
    if option == "use_mouseover" then
        pocketMeroe.db.profile.use_mouseover = not pocketMeroe.db.profile.use_mouseover
        return
    end
    if option == "require_leader" then
        pocketMeroe.db.profile.require_leader = not pocketMeroe.db.profile.require_leader
        return
    end
    for i, mark in pairs(pocketMeroe.db.profile.raidMarkers) do
        if option == i then
            --print(option, value)
            mark[value] = not mark[value]
            return
        end
    end
end

pocketMeroe.SetSetting = function(...)
    options_on_click(nil, nil, ...)
end

pocketMeroe.SetModifier = function(_, var, value, key)
    pocketMeroe.db.profile [var].none = false
    pocketMeroe.db.profile [var].alt = false
    pocketMeroe.db.profile [var].ctrl = false
    pocketMeroe.db.profile [var].shift = false

    pocketMeroe.db.profile [var] [key] = value

end

function Config:Toggle()
    local menu = optionsFrame or Config:CreateMenu();
    menu:SetShown(not menu:IsShown());
end

local BuildModifierOptions = function(var)
    local result = {
        {
            label = "None",
            value = "none",
            onclick = function()
                pocketMeroe.SetModifier(nil, var, true, "none")
            end,
        },
        {
            label = "Alt",
            value = "alt",
            onclick = function()
                pocketMeroe.SetModifier(nil, var, true, "alt")
            end,
        },
        {
            label = "Ctrl",
            value = "ctrl",
            onclick = function()
                pocketMeroe.SetModifier(nil, var, true, "ctrl")
            end,
        },
        {
            label = "Shift",
            value = "shift",
            onclick = function()
                pocketMeroe.SetModifier(nil, var, true, "shift")
            end,
        },
    }
    return result
end



-- Settings
function Config:CreateMenu()
    -- toggle configuration menu
    if (pocketMeroeOptionsPanel) then
        pocketMeroeOptionsPanel:Show()
        return
    end
    -- create options frame
    optionsFrame = DF:CreateSimplePanel (UIParent, 560, 300, "pocketMeroe Config", "pocketMeroeOptionsPanel")
    optionsFrame:SetFrameStrata("HIGH")
	DF:ApplyStandardBackdrop(optionsFrame)
    optionsFrame:ClearAllPoints()
	PixelUtil.SetPoint(optionsFrame, "center", UIParent, "center", 2, 2, 1, 1)

    --create the footer below the options frame
    local statusBar = CreateFrame("frame", "$parentStatusBar", optionsFrame, "BackdropTemplate")
    statusBar:SetPoint("bottomleft", optionsFrame, "bottomleft")
    statusBar:SetPoint("bottomright", optionsFrame, "bottomright")
    statusBar:SetHeight(20)
    statusBar:SetAlpha(0.9)
    statusBar:SetFrameLevel(optionsFrame:GetFrameLevel()+2)
    DF:ApplyStandardBackdrop(statusBar)
    DF:BuildStatusbarAuthorInfo(statusBar, " For <Muted>, ", "Meroe")
    
    local bottomGradient = DF:CreateTexture(optionsFrame, {gradient = "vertical", fromColor = {0, 0, 0, 0.3}, toColor = "transparent"}, 1, 100, "artwork", {0, 1, 0, 1}, "bottomGradient")
	bottomGradient:SetPoint("bottom-top", statusBar)


    local frameOptions = {
		y_offset = 4,
		button_width = 108,
		button_height = 23,
		button_x = 190,
		button_y = -8,
		button_text_size = 10,
		right_click_y = 5,
		rightbutton_always_close = true,
		close_text_alpha = 0.4,
		container_width_offset = 30,
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
    local tabContainer = DF:CreateTabContainer(optionsFrame, "pocketMeroe", "pmOptions",
	{
		{name = "generalSettings",	text = "General"},
		{name = "marksConfig",		text = "Enabled Marks"},
		{name = "markingConfig",	text = "Assigned Marks"},
	},  
	frameOptions, hookList)

    tabContainer:SetPoint("topleft", optionsFrame, "topleft", 5, 0)
    tabContainer:Show()
    tabContainer:SetSize(optionsFrame:GetSize())

    --this function runs when any setting is changed
	local profileCallback = function()

	end
    
	--make the tab button's text be aligned to left and fit the button's area
	for index, frame in ipairs(tabContainer.AllFrames) do
		--DF:ApplyStandardBackdrop(frame)
		local frameBackgroundTexture = frame:CreateTexture(nil, "artwork")
		frameBackgroundTexture:SetPoint("topleft", frame, "topleft", -4, -64)
		frameBackgroundTexture:SetPoint("bottomright", frame, "bottomright", -4, 20)
		frameBackgroundTexture:SetColorTexture (0.2317647, 0.2317647, 0.2317647)
		frameBackgroundTexture:SetVertexColor (0.27, 0.27, 0.27)
		frameBackgroundTexture:SetAlpha (0.3)

		frame.titleText.fontsize = 12

		local tabButton = tabContainer.AllButtons[index]

		local leftSelectionIndicator = tabButton:CreateTexture(nil, "overlay")

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
		fontString:SetWidth(maxTextLength)
		fontString:SetHeight(tabButton:GetHeight()+20)
		fontString:SetWordWrap(true)
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
    local markingConfigFrame = tabContainer.AllFrames[3]

    -- templates
    local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
    local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
    local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
    local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
    local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")



    --- do loop for General settings
    do --do-do-do-do-do baby shark
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
                    return pocketMeroe.db.profile.use_mouseover
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("use_mouseover", pocketMeroe.db.profile.use_mouseover)
                end,
                name = "Mouseover",
                desc = "Allow marking by mousing over mobs.",
            },
            {
                type = "toggle",
                get = function()
                    return pocketMeroe.db.profile.require_leader
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("require_leader", pocketMeroe.db.profile.require_leader)
                end,
                name = "Require Leader",
                desc = "If toggled then you must be the leader to mark mobs.",
            },
            {
                type = "select",
                get = function() 
                    local markingModifier = pocketMeroe.db.profile.marking_modifier
                    return markingModifier.none and "none" or markingModifier.alt and "alt" or markingModifier.ctrl and "ctrl" or markingModifier.shift and "shift"
                end,
                values = function () return BuildModifierOptions("marking_modifier") end,
                name = "Marking Modifier",
                desc = "Require this modifier key to be held down for mouseover marking to work. ",
                
            },
            {
                type = "select",
                get = function() 
                    local clearModifier = pocketMeroe.db.profile.clear_modifier
                    return clearModifier.none and "none" or clearModifier.alt and "alt" or clearModifier.ctrl and "ctrl" or clearModifier.shift and "shift"
                end,
                values = function () return BuildModifierOptions("clear_modifier") end,
                name = "Clear Modifier",
                desc = "Require this modifier key to be held down to clear existing marks. ",
                
            },
            {type = "blank"},
        }
        DF:BuildMenu(generalSettingsFrame, optionsTable, 10, -70, tabFrameHeight, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, profileCallback)

    end

    --- do loop for Marks setings
    do --do-do-do-do-do baby shark
        local markers = pocketMeroe.db.profile.raidMarkers
        local checkboxHelper = function ()

        end
        local optionsTable = {
            always_boxfirst = false,
            {
                type = "label",
                get = function() return "   Focus" end,
                text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")
            },
            {
                type = "toggle",
                get = function()
                    return markers.focus[8]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("focus", 8)
                end,
                name = "    ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.focus[7]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("focus", 7)
                end,
                name = "    ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.focus[6]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("focus", 6)
                end,
                name = "    ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.focus[5]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("focus", 5)
                end,
                name = "    ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.focus[4]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("focus", 4)
                end,
                name = "    ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.focus[3]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("focus", 3)
                end,
                name = "    ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.focus[2]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("focus", 2)
                end,
                name = "    ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.focus[1]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("focus", 1)
                end,
                name = "    ",
            },
            {type = "blank"},
            {
                type = "label",
                get = function() return "Sheep" end,
                text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")
            },
            {
                type = "toggle",
                get = function()
                    return markers.sheep[8]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("sheep", 8)
                end,
                name = " ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.sheep[7]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("sheep", 7)
                end,
                name = " ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.sheep[6]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("sheep", 6)
                end,
                name = " ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.sheep[5]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("sheep", 5)
                end,
                name = " ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.sheep[4]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("sheep", 4)
                end,
                name = " ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.sheep[3]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("sheep", 3)
                end,
                name = " ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.sheep[2]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("sheep", 2)
                end,
                name = " ",
            },
            {
                type = "toggle",
                get = function()
                    return markers.sheep[1]
                end,
                set = function(self, fixedparam, value)
                    pocketMeroe.SetSetting("sheep", 1)
                end,
                name = " ",
            },
        }
        
        
        
        --local listBox = DF:CreateSimpleListBox("pocketMeroeOptionsPanel", "pocketMeroeListBox", "Marking","",npcData)
        
        
        --optionsTable.always_boxfirst = true
        DF:BuildMenu(marksConfigFrame, optionsTable, 10, -70, tabFrameHeight, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, profileCallback)
         
        local skull = marksConfigFrame:CreateTexture(nil, "overlay")
        skull:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcon_8]])
        skull:SetPoint("right", pmOptionsmarksConfigWidget2, "left", -4, 0)
        skull:SetWidth(20);skull:SetHeight(20)

        local cross = marksConfigFrame:CreateTexture(nil, "overlay")
        cross:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcon_7]])
        cross:SetPoint("right", pmOptionsmarksConfigWidget3, "left", -4, 0)
        cross:SetWidth(20);cross:SetHeight(20)

        local square = marksConfigFrame:CreateTexture(nil, "overlay")
        square:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcon_6]])
        square:SetPoint("right", pmOptionsmarksConfigWidget4, "left", -4, 0)
        square:SetWidth(20);square:SetHeight(20)

        local moon = marksConfigFrame:CreateTexture(nil, "overlay")
        moon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcon_5]])
        moon:SetPoint("right", pmOptionsmarksConfigWidget5, "left", -4, 0)
        moon:SetWidth(20);moon:SetHeight(20)

        local triangle = marksConfigFrame:CreateTexture(nil, "overlay")
        triangle:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcon_4]])
        triangle:SetPoint("right", pmOptionsmarksConfigWidget6, "left", -4, 0)
        triangle:SetWidth(20);triangle:SetHeight(20)

        local diamond = marksConfigFrame:CreateTexture(nil, "overlay")
        diamond:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcon_3]])
        diamond:SetPoint("right", pmOptionsmarksConfigWidget7, "left", -4, 0)
        diamond:SetWidth(20);diamond:SetHeight(20)

        local circle = marksConfigFrame:CreateTexture(nil, "overlay")
        circle:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcon_2]])
        circle:SetPoint("right", pmOptionsmarksConfigWidget8, "left", -4, 0)
        circle:SetWidth(20);circle:SetHeight(20)

        local star = marksConfigFrame:CreateTexture(nil, "overlay")
        star:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcon_1]])
        star:SetPoint("right", pmOptionsmarksConfigWidget9, "left", -4, 0)
        star:SetWidth(20);star:SetHeight(20)
    end

    optionsFrame:Hide();
    return optionsFrame;
end

function pocketMeroe:initTooltips ()
    _G["pocketMeroeHelpers"] = _G["pocketMeroeHelpers"] or {}
    local helpers = _G["pocketMeroeHelpers"]
    helpers.tooltipExtend = function(tooltip, aura)
        local unitName, unitId = GameTooltip:GetUnit()
        if UnitExists(unitId) then
            local guid = UnitGUID(unitId)
            local type, _, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid)
            local npcInfo = npcData[npc_id]
            if (npcInfo ~= nil) then
                for i, abilityId in ipairs(npcInfo.abilities) do
                    local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(abilityId)
                    if (name ~= nil) then
                        -- Icon + Name
                        local ttIcon = ""
                        local ttName = name
                        local texture = GetSpellTexture(abilityId)
                        if (texture ~= nil) then
                            ttIcon = "|T"..texture..":0|t"
                        end
                        GameTooltip:AddLine(ttIcon..ttName)
                        -- Description
                        local ttDescription = GetSpellDescription(abilityId)
                        if (spellDesc ~= nil) and (spellDesc[abilityId] ~= nil) then
                            ttDescription = spellDesc[abilityId]
                        end
                        if (ttDescription ~= nil) and IsControlKeyDown() then
                            GameTooltip:AddLine(ttDescription, 0.8, 0.8, 0.8, true)
                        end
                    end
                end
                if (npcInfo.extra ~= nil) then
                    for i, extraInfo in ipairs(npcInfo.extra) do
                        local ttIcon = "";
                        local ttName = extraInfo.text;
                        if (extraInfo.icon ~= nil) then
                            local texture = GetSpellTexture(extraInfo.icon)
                            if (texture ~= nil) then
                                ttIcon = "|T"..texture..":0|t"
                            end
                        end
                        GameTooltip:AddLine(ttIcon..ttName)
                        if (extraInfo.description ~= nil) and IsControlKeyDown() then
                            GameTooltip:AddLine(extraInfo.description, 0.8, 0.8, 0.8, true)
                        end
                    end
                end
                if not IsControlKeyDown() then
                    GameTooltip:AddLine("(Ctrl for details)", 0.8, 0.8, 0.8)
                end
                -- tooltip:Show();
                if (GameTooltip:GetWidth() > 700) then
                    GameTooltip:SetWidth(700)
                end
                if helpers.markersEnabled(aura) then
                    local markerType, markerBias = helpers.markersGetTypeForNpc(aura, npc_id, unitName)
                    if (markerType ~= nil) then
                        helpers.markersSetUnit(aura, unitId, markerType, markerBias)
                    end
                end
            end                    
        end
    end
end

function pocketMeroe:initMarks ()
    local markingModifier = pocketMeroe.db.profile.marking_modifier
    local clearModifier = pocketMeroe.db.profile.clear_modifier

    _G["pocketMeroeHelpers"] = _G["pocketMeroeHelpers"] or {}
    local helpers = _G["pocketMeroeHelpers"]
    -- List of all currently used markers
    helpers.markersUsed = helpers.markersUsed or {}
    helpers.markersUsedPriority = helpers.markersUsedPriority or {}
    helpers.markersUsedByGUID = helpers.markersUsedByGUID or {}
    helpers.markersUsedReset = GetTime() + 2
    helpers.markersModifierIsPressed = false
    -- Group mappings for custom npcs
    helpers.markersCustom = { 
        "focus", "focus2", "primary", "secondary", "sheep", "banish", "shackle", "fear",
        "rt8", "rt7", "rt6", "rt5", "rt4", "rt3", "rt2", "rt1"
    }
    -- Check if marking units is enabled
    helpers.markersEnabled = function(aura)
        if not pocketMeroe.db.profile.use_mouseover then
            return false
        end
        if not markingModifier then
            return false
        end
        if (pocketMeroe.db.profile.require_leader and not UnitIsGroupLeader("player")) then
            -- doesn't do marking if not player lead and "not lead" is toggled in custom options
            return false
        end
        if (markingModifier.alt and IsAltKeyDown()) then
            return true
        elseif (markingModifier.ctrl and IsControlKeyDown()) then
            return true
        elseif (markingModifier.shift and IsShiftKeyDown()) then
            return true
        end
        return false
    end
    helpers.markersModifierChanged = function(aura)
        if markingModifier and pocketMeroe.db.profile.use_mouseover then
            if (markingModifier.alt and IsAltKeyDown()) then
                helpers.markersModifierPressed()
            elseif (markingModifier.ctrl and IsControlKeyDown()) then
                helpers.markersModifierPressed()
            elseif (markingModifier.shift and IsShiftKeyDown()) then
                helpers.markersModifierPressed()
            elseif (helpers.markersModifierPressed) then
                helpers.markersModifierReleased()
            end
        end
    end
    helpers.markersModifierPressed = function(aura)
        if helpers.markersModifierIsPressed then
            -- Was already pressed before
            return
        end
        helpers.markersModifierIsPressed = true
        helpers.markersClearUsed()
        helpers.markersUsedReset = GetTime() + 10.0
    end
    helpers.markersModifierReleased = function(aura)
        if not helpers.markersModifierIsPressed then
            -- Was already released before
            return
        end
        helpers.markersModifierIsPressed = false
        helpers.markersUsedReset = GetTime()
    end
    -- Add unit's marker to list of used markers        
    helpers.markersAddToUsed = function(aura, unitId, index, priority)
        if not index then
            index = GetRaidTargetIndex(unitId)
        end
        if not priority then
            local markerType = helpers.markersGetTypeForUnit(aura, unitId)
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
            --print(guid, "+", index)
        end
    end
    -- Get list of all currently used markers
    helpers.markersClearUsed = function(aura)
        for i = 1, 8 do
            helpers.markersUsed[i] = false
            helpers.markersUsedPriority[i] = nil
        end
        wipe(helpers.markersUsedByGUID)
    end
    -- Get list of all currently used markers
    helpers.markersGetUsed = function(aura)
        -- Reset state
        if helpers.markersUsedReset < GetTime() then
            helpers.markersClearUsed()
        end
        helpers.markersUsedReset = max(helpers.markersUsedReset, GetTime() + 2.0)
        -- Don't use marks already used on the players target
        helpers.markersAddToUsed(aura, "target")
        -- Don't use marks already used on party member or their targets
        -- for partyMember in WA_IterateGroupMembers(false, true) do
        --     helpers.markersAddToUsed(aura, partyMember)
        --     helpers.markersAddToUsed(aura, partyMember.."target")     
        -- end
        -- Don't use marks already used on boss1-4
        for i = 1, 4 do
            helpers.markersAddToUsed(aura, "boss"..i)
        end
        -- Don't use marks already used on nameplates
        for i = 1, 40 do
            helpers.markersAddToUsed(aura, "nameplate"..i)
        end
        return helpers.markersUsed
    end
    -- Get free marker index for the given type
    helpers.markersGetFreeIndex = function(aura, markerType, priority, markerCurrent)
        if (type(markerType) == "table") then
            -- Get the highest priority marker from a list of marker types
            local markerIndex = nil
            local markerPriority = 0
            for _, t in ipairs(markerType) do
                local p = helpers.markersGetPriority(t)
                if not markerIndex or (p > markerPriority) then
                    markerIndex = helpers.markersGetFreeIndex(aura, t, priority, markerCurrent)
                    if (markerIndex ~= nil) then
                        markerPriority = p
                    end
                end
            end
            return markerIndex
        end
        -- Exact marker
        local markerExact = strmatch(markerType, "rt([0-9]+)")
        if markerExact then
            local i = tonumber(markerExact)
            if (helpers.markersUsedPriority[i] ~= nil) and (helpers.markersUsedPriority[i] < priority) then
                return i
            end
            return nil
        end
        -- Get the first available marker from the given type
        if not markerType or not pocketMeroe.db.profile.raidMarkers[markerType] then
            return nil
        end
        for i = 8, 1, -1 do
            if markerCurrent and (i <= markerCurrent) then
                return markerCurrent
            end
            --local s = tostring(i)
            --print("markerType: ", markerType, "i: ", i, "s: ", s)
            --print("mt", pocketMeroe.db.profile.raidMarkers[markerType], "s", pocketMeroe.db.profile.raidMarkers[markerType][s])
            if pocketMeroe.db.profile.raidMarkers[markerType][i] then
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
        if (markerType == "focus") then
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
    helpers.markersGetTypeForUnit = function(aura, unitId)
        if UnitExists(unitId) then
            local guid = UnitGUID(unitId);
            local name = UnitName(unitId);
            local type, _, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
            return helpers.markersGetTypeForNpc(aura, npc_id, name)
        end
        return nil
    end
    -- Set marker type for npc id
    helpers.markersGetTypeForNpc = function(aura, npcId, npcName)
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
    helpers.markersSetUnit = function(aura, unitId, markerType, markerBias)
        helpers.markersGetUsed(aura)
        local priority = helpers.markersGetPriority(markerType) + (markerBias or 0.0)
        local markerCurrent = GetRaidTargetIndex(unitId)
        local markerIndex = helpers.markersGetFreeIndex(aura, markerType, priority, markerCurrent)
        --print(priority, markerIndex, markerCurrent)
        if (markerIndex ~= nil) and (markerIndex ~= markerCurrent) then
            --print("WORKY")
            helpers.markersClearUnit(unitId)
            SetRaidTarget(unitId, markerIndex)
            helpers.markersAddToUsed(aura, unitId, markerIndex, priority)
        end
    end


end

function pocketMeroe:eventsHandle (event)
    _G["pocketMeroeHelpers"] = _G["pocketMeroeHelpers"] or {}
    local helpers = _G["pocketMeroeHelpers"]
    if (event == "MODIFIER_STATE_CHANGED") then
        if helpers.markersModifierChanged then
            helpers.markersModifierChanged(aura)
        end
    end
    
    -- Hook tooltip
    if not helpers.tooltipHooked then
        helpers.tooltipHooked = true
        GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
                if helpers.tooltipExtend then
                    helpers.tooltipExtend(tooltip, aura)
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