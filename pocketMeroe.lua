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


npcData['1706'] = {
    markerType = {"sheep"},
    abilities = { 10, 35076 },
    extra = {
        { icon = 38768, text = "sheep", description = "Description of Extra" }
    }
};
npcData['1707'] = {
    markerType = {"primary"},
    abilities = { 10, 35076 },
    extra = {
        { icon = 38768, text = "Defias Captive", description = "Found in the Stockade" }
    }
};
npcData['1708'] = {
    markerType = {"focus"},
    abilities = { 10, 35076 },
    extra = {
        { icon = 38768, text = "Extra Info", description = "Description of Extra" }
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


function pocketMeroe:stockades ()
    -- local markingModifier = pocketMeroe.db.profile.marking_modifier
    -- local clearModifier = pocketMeroe.db.profile.clear_modifier
    --if (pocketMeroe.db.profile.require_leader and not UnitIsGroupLeader("player")) then return end 
    -- doesn't do marking if not player lead and "not lead" is toggled in custom options

    ---------------------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------------------

    --     if not pocketMeroe.db.profile.use_mouseover then

    --     if (markingModifier.alt and IsAltKeyDown()) then
    --         return true
    --     elseif (markingModifier.ctrl and IsControlKeyDown()) then
    --         return true
    --     elseif (markingModifier.shift and IsShiftKeyDown()) then
    --         return true
    --     end
    --     return false
    -- end
    -- .markersModifierChanged = function(aura)
    --     if (markingModifier and pocketMeroe.db.profile.use_mouseover) then
    return
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
