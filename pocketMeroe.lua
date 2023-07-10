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

pocketMeroe.SetModifier = function(_, _, value, key)
    pocketMeroe.db.profile.marking_modifier.none = false
    pocketMeroe.db.profile.marking_modifier.alt = false
    pocketMeroe.db.profile.marking_modifier.ctrl = false
    pocketMeroe.db.profile.marking_modifier.shift = false

    pocketMeroe.db.profile.marking_modifier [key] = true

end


function Config:Toggle()
    local menu = generalSettingsFrame or Config:CreateMenu();
    menu:SetShown(not menu:IsShown());
end




local BuildMarkingModifierOptions = function()
    local result = {
        {
            label = "Alt",
            value = "alt",
            onclick = function()
                pocketMeroe.SetModifier(nil, nil, true, "alt")
            end,
        },
        {
            label = "Shift",
            value = "shift",
            onclick = function()
                pocketMeroe.SetModifier(nil, nil, true, "shift")
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
                    return markingModifier.alt and "alt" or markingModifier.shift and "shift"
                end,
                values = function () return BuildMarkingModifierOptions() end,
                name = "Marking Modifier",
                desc = "Require this modifier key to be held down for mouseover marking to work. ",
                
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




    --UIConfig.optModifier = DF:CreateSimpleListBox (UIConfig, optModifier, "Mouseover Modifier", "None", {"None", "Alt", "Ctrl", "Shift"})
    --local optLeader = DF:CreateOptionsButton(menu, nil, "pocketMeroeOptLeader")
    --optLeader:SetPoint("bottomleft", UIConfig, "bottomleft")



    generalSettingsFrame:Hide();
    return generalSettingsFrame;
end

