local _, pocketMeroe = ...; -- Namespace
pocketMeroe.Config = {};
local Config = pocketMeroe.Config;

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
    },
}

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
    --SLASH_Kishibe1 = "kishibe"
    SlashCmdList.Meroe = HandleSlashCommands;
    --SlashCmdList.Kishibe = EasterEggKish;
	if (pocketMeroe.db:GetCurrentProfile() ~= "Default") then
		pocketMeroe.db:SetProfile("Default")
	end
    pocketMeroe.db.RegisterCallback(pocketMeroe, "OnProfileChanged", "RefreshConfig")
    pocketMeroe:initMarks()
    local markevents = CreateFrame("frame");
    markevents:RegisterEvent("PLAYER_REGEN_ENABLED")
    markevents:RegisterEvent("PLAYER_REGEN_DISABLED")
    markevents:RegisterEvent("UNIT_COMBAT")
    markevents:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    markevents:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    markevents:RegisterEvent("MODIFIER_STATE_CHANGED")
    markevents:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    markevents:RegisterEvent("READY_CHECK")
    markevents:SetScript("OnEvent", pocketMeroe.eventsMarks);
    --pocketMeroe.db.RegisterCallback (pocketMeroe, "OnDatabaseShutdown", "CleanUpJustBeforeGoodbye") --more info at https://www.youtube.com/watch?v=GXFnT4YJLQo
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
    if (option == "use_mouseover") then
        pocketMeroe.db.profile.use_mouseover = not pocketMeroe.db.profile.use_mouseover
    end
    if (option == "require_leader") then
        pocketMeroe.db.profile.require_leader = not pocketMeroe.db.profile.require_leader
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
    local menu = generalSettingsFrame or Config:CreateMenu();
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
local generalSettingsFrame;
function Config:CreateMenu()
    generalSettingsFrame = DF:CreateSimplePanel (UIParent, 500, 288, "pocketMeroe Config", "pocketMeroeOptionsPanel")
    generalSettingsFrame:SetFrameStrata("HIGH")
	DF:ApplyStandardBackdrop(generalSettingsFrame)
    generalSettingsFrame:ClearAllPoints()

    --- Content
    -- mouseover marking
    -- modifier
    -- require leader

    --- Templates
    local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
    local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
    local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
    local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
    local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")


    --this function runs when any setting is changed
	local profileCallback = function()

	end

    --- do loop for General Settings
    do --do-do-do-do-do baby shark
        local optionsTable = {
            --always_boxfirst = true,
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
            {
                type = "label",
                get = function() return "Enabled Marks" end,
                text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")
            },
            {type = "blank"},
            {
                type = "label",
                get = function() return "CC Types" end,
                text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")
            },

        }
        --optionsTable.always_boxfirst = true
        DF:BuildMenu(generalSettingsFrame, optionsTable, 10, -30, tabFrameHeight, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, profileCallback)

    end

    generalSettingsFrame:Hide();
    return generalSettingsFrame;
end

function pocketMeroe:initMarks()
    pocketMeroe.Marks = {}
    _G["env"] = pocketMeroe.Marks
    env.orderList = {
        ["defaultOrder"] = {8,7,6,5,4,3,2,1},
    }
    env.mobList = {
        -- Stockades Test
        ["1706"] = true and "banish", -- Defias Prisoner
        ["1707"] = true and "banish", -- Defias Captive
        -- BRD --
        ["8894"] = true and "polymorph", -- Anvilrage Medic
        ["8895"] = true and "kill", -- Anvilrage Officer
        ["8909"] = true and "kill", -- Fireguard
    }        
        --DO NOT TOUCH
    env.marks = {}
    env.assigned = {}


    env.getOrder = function(unitId, isNameplate) 
        local orderName
        if (isNameplate) then
            orderName = env.mobListNameplate[unitId]
        else        
            orderName = env.mobList[unitId]
        end
        return  env.orderList[orderName] or env.orderList["defaultOrder"]
    end

    --checks marks on players in party. DOES NOT empty the list of marked mobs or marks in use
    -- env.checkPremarkedPlayers = function ()
    --     for unit in WA_IterateGroupMembers() do
    --         if GetRaidTargetIndex(unit) then
    --             env.assigned[GetRaidTargetIndex(unit)] = true
    --             env.marks[unit] = GetRaidTargetIndex(unit)
    --         end
    --     end
    -- end


    --checks nameplates on screen and adds them to the tracked list if not already in it. DOES NOT empty the list of marked mobs or marks in use
    env.checkPremarkedMobs = function ()
        for i = 1,40 do
            local unit = "nameplate"..i
            if UnitExists(unit) and GetRaidTargetIndex(unit) and not UnitPlayerControlled(unit) then
                env.assigned[GetRaidTargetIndex(unit)] = true
                env.marks[UnitGUID(unit)] = GetRaidTargetIndex(unit) 
            end
        end
    end

    --checks if the unit should be marked
    env.isUnitValid = function (unit)
        if unit == "player" then return end
        local guid = UnitGUID(unit)
        if not guid then return end
        local unitid = select(6, strsplit("-", guid))
        
        return UnitExists(unit) and not GetRaidTargetIndex(unit) and env.mobList[unitid] and not UnitIsDead(unit)
    end

    --special case for nameplate marking, but same as the function above. Should merge them in the future
    env.isUnitValidNameplate = function (unit)
        if unit == "player" then return end
        local guid = UnitGUID(unit)
        if not guid then return end
        local unitid = select(6, strsplit("-", guid))
        
        return UnitExists(unit) and not GetRaidTargetIndex(unit) and not env.marks[guid] and env.mobListNameplate[unitid] and not UnitIsDead(unit)
    end

    --takes in a unit and the order to mark it with. function checks the marks in the order to find the first availible marker from that order
    env.markUnit = function (unit, order)
        local guid = UnitGUID(unit)
        for i=1, #order do
            if not env.assigned[order[i]] --and env.config.settingsGroup.enabledMarks[order[i]]
            then
                if env.marks[guid] then 
                    SetRaidTarget(unit, env.marks[guid])
                    return               
                end            
                env.marks[guid] = order[i]
                env.assigned[order[i]] = true
                SetRaidTarget(unit, order[i])
                return
            end
        end
    end
end

function pocketMeroe:eventsMarks (event, ...)
    local markingModifier = pocketMeroe.db.profile.marking_modifier
    local clearModifier = pocketMeroe.db.profile.clear_modifier

    if (pocketMeroe.db.profile.require_leader and not UnitIsGroupLeader("player")) then return end 
    -- doesn't do marking if not player lead and "not lead" is toggled in custom options

    ---------------------------------------------------------------------------------------
    if event == "PLAYER_REGEN_ENABLED" then
        env.marks = {}
        env.assigned = {}
        env.checkPremarkedMobs()
        --env.checkPremarkedPlayers()
    end
    if event == "PLAYER_REGEN_DISABLED" then
        env.checkPremarkedMobs()
        --env.checkPremarkedPlayers()
    end
    
    ---------------------------------------------------------------------------------------

    ---------------------------------------------------------------------------------------
    --mouseover functionality
    if (event == "UPDATE_MOUSEOVER_UNIT" or event == "MODIFIER_STATE_CHANGED") and pocketMeroe.db.profile.use_mouseover then
        
        if (clearModifier.alt and IsAltKeyDown()) or
            (clearModifier.ctrl and IsControlKeyDown()) or
            (clearModifier.shift and IsShiftKeyDown()) then

            SetRaidTarget("mouseover", 0)
        end
        
        if (markingModifier.alt and not IsAltKeyDown()) then return end
        if (markingModifier.ctrl and not IsControlKeyDown()) then return end
        if (markingModifier.shift and not IsShiftKeyDown()) then return end
        local guid = UnitGUID("mouseover")
        if not guid then return end
        local unitid = select(6, strsplit("-", guid))
        if not env.isUnitValid("mouseover") then return end
        --env.checkPremarkedPlayers()
        env.checkPremarkedMobs()
        env.markUnit("mouseover", env.getOrder(unitid))
    end
    
    ---------------------------------------------------------------------------------------
    --Frees up marks when mobs die
    if event == "COMBAT_LOG_EVENT_UNFILTERED" and (select(2,...) == "UNIT_DIED" or select(2,...) == "UNIT_DESTROYED") then
        local guid = select(8,...)     
        if guid and(env.marks[guid]) then
            local type = select(1, strsplit("-", guid)) 
            
            if string.lower(type)~="player" then
                env.assigned[env.marks[select(8,...)]] = false
                env.marks[select(8,...)] = nil
            end
        end    
    end
end

-- TODO: cooltip clears
-- TODO: leaving or entering an instance fucks the configuation panel