-- gui/GUI_Core.lua
local DF    = _G.DetailsFramework
local utils = PocketMeroe.utils

-- forward declares
local OptionsPanel, GeneralTab, AutomarksTab

--- The top‐level GUI controller
local Gui = {}
Gui.__index = Gui

function Gui:new()
    return setmetatable({}, self)
end

function Gui:ToggleOptionsMenu()
    if not self.panel then
        self.panel = OptionsPanel:new()
    end
    self.panel:Toggle()
end

PocketMeroe.gui = Gui:new()


-----------------------------------------------------------------------------
-- OptionsPanel: creates the main window and tabs
-----------------------------------------------------------------------------
OptionsPanel = {}
OptionsPanel.__index = OptionsPanel

function OptionsPanel:new()
    local o = setmetatable({}, self)
    o.frame = DF:CreateSimplePanel(UIParent, 700, 500, "PocketMeroe Config", "PocketMeroeOptions")
    o.frame:SetPoint("CENTER")
    table.insert(UISpecialFrames, o.frame:GetName())

    -- Build tabs
    o:_buildTabs()
    o.frame:Hide()
    return o
end

function OptionsPanel:Toggle()
    self.frame:SetShown(not self.frame:IsShown())
end

function OptionsPanel:_buildTabs()
    local tabDefs = {
        {
            name    = ".general",      -- frame‐name suffix (must be unique)
            text    = "General",       -- label shown on the tab
            onclick = function() self:SelectTab(1) end,
        },
        {
            name    = ".automarks",
            text    = "Automarks",
            onclick = function() self:SelectTab(2) end,
        },
    }
    local tabOpts = { width = 680, height = 460 }

    local tc = DF:CreateTabContainer(
        self.frame,                     -- parent
        "PocketMeroe",                  -- name prefix
        "pmeroe.tc",                    -- global name
        tabDefs,                        -- tab definitions (now with .name)
        tabOpts                         -- size options
    )
    tc:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -30)
    utils.SetTabContainerBackdrop(tc)
    self.tabContainer = tc

    -- instantiate your tab objects...
    self.tabs = {
        GeneralTab:new(tc.AllFrames[1]),
        AutomarksTab:new(tc.AllFrames[2]),
    }

    self:SelectTab(1)
end

function OptionsPanel:SelectTab(index)
    for i, frame in ipairs(self.tabContainer.AllFrames) do
        frame:SetShown(i == index)
    end
    local tabObj = self.tabs[index]
    if not tabObj.__built then
        tabObj:BuildUI()
        tabObj.__built = true
    end
end
-----------------------------------------------------------------------------
-- GeneralTab: builds the “General” options menu
-----------------------------------------------------------------------------
GeneralTab = {}
GeneralTab.__index = GeneralTab

function GeneralTab:new(frame)
    return setmetatable({ frame = frame }, self)
end

function GeneralTab:BuildUI()
    local f = self.frame
    local cfg = PocketMeroe.db.profile

    local options = {
        always_boxfirst = true,

        { type = "label",
          get  = function() return "Functionality" end,
          text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE"),
        },

        { type = "toggle",
          name = "Mouseover",
          desc = "Allow marking by mousing over mobs.",
          get = function() return cfg.use_mouseover end,
          set = function() cfg.use_mouseover = not cfg.use_mouseover end,
        },

        { type = "toggle",
          name = "Require Leader",
          desc = "Must be leader to mark mobs.",
          get = function() return cfg.require_leader end,
          set = function() cfg.require_leader = not cfg.require_leader end,
        },

        { type = "select",
          name  = "Marking Modifier",
          desc  = "Key required to apply marks.",
          get   = function() return utils.GetModifierName(cfg.marking_modifier) end,
          values= function() return utils.BuildModifierOptions("marking_modifier", function(v,k) cfg.marking_modifier = { [k]=true } end) end,
        },

        { type = "select",
          name   = "Clear Modifier",
          desc   = "Key required to clear marks.",
          get    = function() return utils.GetModifierName(cfg.clear_modifier) end,
          values = function() return utils.BuildModifierOptions("clear_modifier", function(v,k) cfg.clear_modifier = { [k]=true } end) end,
        },

      { type = "blank" },
    }

    DF:BuildMenu(f, options, 10, -100, f:GetHeight(), false,
        DF:GetTemplate("font",     "OPTIONS_FONT_TEMPLATE"),
        DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"),
        DF:GetTemplate("switch",   "OPTIONS_CHECKBOX_TEMPLATE"),
        true,
        DF:GetTemplate("slider",   "OPTIONS_SLIDER_TEMPLATE"),
        DF:GetTemplate("button",   "OPTIONS_BUTTON_TEMPLATE"),
        function() end  -- profile callback stub
    )
end


-----------------------------------------------------------------------------
-- AutomarksTab: builds the “Automarks” scrollbox and dropdown
-----------------------------------------------------------------------------
AutomarksTab = {}
AutomarksTab.__index = AutomarksTab

function AutomarksTab:new(frame)
    return setmetatable({ frame = frame }, self)
end

function AutomarksTab:BuildUI()
    local f   = self.frame
    local cfg = PocketMeroe.db.profile

    ------------------------------------------------------------------------------------------------
    -- 1) Raid Selector (DF dropdown)
    ------------------------------------------------------------------------------------------------
    print("AutomarksTab:BuildUI() — creating dropdown")   -- 🔍
    local dd = DF:CreateDropdown(f,
        function(_, _, raidValue)
            print("Dropdown callback fired! raidValue =", raidValue)  -- 🔍
            cfg.selectedRaid = raidValue

            -- repopulate the scroll data source
            local newData = getData()
            print("getData returned", #newData, "entries")            -- 🔍
            self.scroll:SetData(newData)
            self.scroll:Refresh()
        end,
        130, 20
    )
    dd:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -40)
    dd:SetLabel("Raid:")
    dd:SetList({
        none = "All",
        ZG   = "Zul'Gurub",
        AQ20 = "Ruins of Ahn'Qiraj",
        MC   = "Molten Core",
        BWL  = "Blackwing Lair",
        AQ40 = "Temple of Ahn'Qiraj",
        NAXX = "Naxxramas",
    })
    dd:Select(cfg.selectedRaid or "none")

    ------------------------------------------------------------------------------------------------
    -- 2) NPC Scroll Grid
    ------------------------------------------------------------------------------------------------
    -- Prepare data source
    local data = {}
    local function getData()
        wipe(data)
        for id, entry in pairs(PocketMeroe.db.profile.markersCustom or {}) do
            local marks, prio, zone, mobType, name = unpack(entry)
            if (cfg.selectedRaid == "none") or (cfg.selectedRaid == zone) then
                tinsert(data, { text = name })
                tinsert(data, { text = tostring(id) })
                tinsert(data, { text = zone .. " " .. mobType })
            end
        end
        print("getData() assembled", #data, "cells for selectedRaid=", cfg.selectedRaid)  -- 🔍
        return data
    end

    -- Cell renderer
    local function refreshLine(lineFrame, cellData)
        if not cellData or not cellData.text then
            return lineFrame:Hide()
        end
        if not lineFrame.text then
            -- first time, attach a FontString for debugging
            lineFrame.text = lineFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lineFrame.text:SetPoint("LEFT", lineFrame, "LEFT", 2, 0)
        end
        lineFrame.text:SetText(cellData.text)
        lineFrame:Show()
    end

    -- Column factories
    local function createColumn(line, lineIndex, columnIndex)
        if columnIndex == 1 then
            local lbl = DF:CreateLabel(line, "", "GameFontNormal")
            lbl:SetPoint("LEFT", line, "LEFT", 2, 0)
            return lbl

        elseif columnIndex == 2 then
            local bar = Gui:CreateRaidIconBar(line)
            if not bar or not bar.list then
                print("ERROR: CreateRaidIconBar returned", bar)  -- 🔍
            end
            return bar

        else
            local btn = DF:CreateButton(line, function() print("Clicked action on line", lineIndex) end, 24, 24, "", 0, true)
            btn:SetPoint("RIGHT", line, "RIGHT", -2, 0)
            return btn
        end
    end

    -- Create scrollBox
    print("AutomarksTab: Building scroll box")  -- 🔍
    local initialData = getData()
    self.scroll = DF:CreateGridScrollBox(
        f,
        "$parentScroll",
        refreshLine,
        initialData,
        createColumn,
        {
            width            = 510,
            height           = 190,
            line_amount      = 9,
            columns_per_line = 3,
            line_height      = 20,
        }
    )
    if not self.scroll then
        print("ERROR: CreateGridScrollBox returned nil!")  -- 🔍
        return
    end

    self.scroll:SetPoint("BOTTOM", f, "BOTTOM", -10, 25)
    DF:ReskinSlider(self.scroll)

    -- expose UpdateList override if needed
    function self.scroll:UpdateList(_, _, _, raidValue)
        print("scroll:UpdateList called, raidValue=", raidValue)  -- 🔍
        self:SetData(getData())
        self:Refresh()
    end

    print("AutomarksTab:BuildUI() complete")  -- 🔍
end


function AutomarksTab:_CreateIconBar(line)
    return Gui:CreateRaidIconBar(line)
end

return Gui