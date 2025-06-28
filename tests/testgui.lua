-- Dummy DetailsFramework mock for standalone testing
function CreateFrame(frameType, globalName, parent, template)
    local frame = {}

    -- Common frame methods used in your code:
    frame.SetPoint = function(...) end
    frame.GetSize = function() return 560, 330 end
    frame.SetSize = function(...) end
    frame.Show = function(...) end
    frame.Hide = function(...) end
    frame.SetFrameLevel = function(...) end
    frame.GetFrameLevel = function() return 1 end
    frame.ClearAllPoints = function(...) end
    frame.SetHeight = function(self, height) self.height = height end
    frame.SetWidth = function(self, width) self.width = width end
    frame.SetAlpha = function(...) end

    frame.CreateTexture = function(_, layer)
        local texture = {}
        texture.SetPoint = function(...) end
        texture.SetColorTexture = function(...) end
        texture.SetVertexColor = function(...) end
        texture.SetAlpha = function(...) end
        texture.SetAllPoints = function(...) end
        texture.SetTexCoord = function(...) end
        texture.SetShown = function(...) end
        return texture
    end

    frame.CreateFontString = function(...)
        local fs = {}
        fs.SetPoint = function(...) end
        fs.SetText = function(...) end
        fs.SetAlpha = function(...) end
        fs.SetJustifyH = function(...) end
        fs.SetWordWrap = function(...) end
        fs.GetStringWidth = function() return 100 end
        return fs
    end

    frame.EnableMouse = function(...) end
    frame.SetScript = function(...) end

    return frame
end

_G["DetailsFramework"] = {
    -- Creates a simple panel frame mock
    CreateSimplePanel = function(parent, width, height, title, globalName)
        local frame = {
            SetPoint = function() end,
            GetSize = function() return width, height end,
            SetSize = function() end,
            Show = function() end,
            Hide = function() end,
            SetFrameLevel = function() end,
            GetFrameLevel = function() return 1 end,
            CreateTexture = function() 
                return {
                    SetPoint = function() end,
                    SetColorTexture = function() end,
                    SetVertexColor = function() end,
                    SetAlpha = function() end,
                }
            end,
            SetBackdrop = function() end,
        }
        return frame
    end,

    -- Return a dummy template table
    GetTemplate = function(_, _) return {} end,

    -- Table utilities
    table = {
        copy = function(t) 
            local c = {} 
            for k,v in pairs(t) do c[k]=v end
            return c 
        end
    },

    -- Create a tab container mock with frames and buttons
    CreateTabContainer = function(parent, name, globalName, tabList, optionsTable, hookList)
        local container = {
            SetPoint = function() end,
            SetSize = function() end,
            Show = function() end,
            SetTabFramesBackdrop = function() end,
            AllFrames = {},
            AllButtons = {},
        }
    
        -- Create 2 dummy frames corresponding to your tabs
        for i = 1, 2 do
            local frame = {
                titleText = {
                    fontsize = 14,
                    SetFontSize = function(self, size) self.fontsize = size end,
                },
                GetHeight = function() return 300 end,
                GetWidth = function() return 500 end,
                SetPoint = function() end,
                SetSize = function() end,
                SetAlpha = function() end,
            }
            container.AllFrames[i] = frame
    
            local button = {
                widget = {},  -- placeholder for widget frame
                GetWidth = function() return 100 end,
                GetHeight = function() return 20 end,
                GetName = function() return "TabButton" .. i end,
                leftSelectionIndicator = nil,
                selectedUnderlineGlow = {
                    Hide = function() end,
                },
            }
            container.AllButtons[i] = button
        end
    
        return container
    end,

    -- No-op backdrop applying
    ApplyStandardBackdrop = function(frame) end,

    -- Label mock
    CreateLabel = function(parent, text)
        local label = {
            SetPoint = function() end,
            SetAlpha = function() end,
            textcolor = "",
            SetText = function(self, newText) self.text = newText end,
            text = text or "",
        }
        return label
    end,

    -- Texture mock
    CreateTexture = function(parent, params, layer, width, height, drawLayer, vertexColor, name)
        local texture = {
            SetAllPoints = function() end,
            SetPoint = function() end,
            SetColorTexture = function() end,
            SetVertexColor = function() end,
            SetAlpha = function() end,
            SetTexCoord = function() end,
            SetSize = function() end,
            SetShown = function() end,
        }
        return texture
    end,

    -- BuildMenu mock returns a dummy menu frame
    BuildMenu = function(parent, optionsTable, x, y, height, arg1, textTemplate, dropdownTemplate, switchTemplate, arg2, sliderTemplate, buttonTemplate, callback)
        local menu = {
            SetPoint = function() end,
            SetSize = function() end,
            Show = function() end,
            Hide = function() end,
            Refresh = function() end,
            SetData = function() end,
            IsShown = function() return true end,
        }
        return menu
    end,

    -- Grid scroll box mock
    CreateGridScrollBox = function(parent, globalName, refreshFunc, data, createColumnFunc, options)
        local scrollBox = {
            GetFrames = function() return {} end,
            SetData = function() end,
            Refresh = function() end,
            SetPoint = function() end,
            IsShown = function() return true end,
            Show = function() end,
            Hide = function() end,
        }
        return scrollBox
    end,

    -- Reskin slider no-op
    ReskinSlider = function(slider) end,

    -- Font helpers (dummy)
    GetFontSize = function(fontString) return 12 end,
    SetFontSize = function(fontString, size) end,

    -- String helpers
    strings = {
        tabletostring = function(tbl)
            if type(tbl) ~= "table" then return tostring(tbl) end
            local s = "{ "
            for _, v in ipairs(tbl) do
                s = s .. tostring(v) .. ", "
            end
            return s .. "}"
        end
    },
}
_G["DetailsFramework"].GetDefaultBackdropColor = function()
    return 0, 0, 0, 0.5  -- RGBA: black with 50% opacity, or whatever your code expects
end

_G["DetailsFramework"].GetDefaultBorderColor = function()
    return 0, 0, 0, 1  -- RGBA: black fully opaque
end

-- Create dummy PocketMeroe global with expected nested tables and functions
PocketMeroe = PocketMeroe or {}
PocketMeroe.db = PocketMeroe.db or {}
PocketMeroe.db.profile = PocketMeroe.db.profile or {
    use_mouseover = true,
    require_leader = false,
    clear_modifier = { none = true, alt = false, ctrl = false, shift = false },
    marking_modifier = { none = true, alt = false, ctrl = false, shift = false },
    raidMarkers = {
        [1] = { someFlag = true },
        [2] = { someFlag = false },
    },
    markersCustom = {
        [12345] = { {8,7,6,5,4,3,2,1}, 1, "MC", "Boss", "Some Boss" },
        [67890] = { {1,2,3,4,5,6,7,8}, 2, "ZG", "Trash", "Some Mob" },
    },
}

-- Provide dummy ProfileGet/Set functions used in your gui.lua
function PocketMeroe.ProfileGet(id, key)
    local profile = PocketMeroe.db.profile
    if key == "customMarks" then
        local data = profile.markersCustom[id]
        if data then return data[1] end
    end
    return nil
end

function PocketMeroe.ProfileSet(id, key, value)
    local profile = PocketMeroe.db.profile
    if not profile.markersCustom[id] then
        profile.markersCustom[id] = { {}, 1, "none", "", "" }
    end
    if key == "customMarks" then
        profile.markersCustom[id][1] = value
    end
end

-- Define these globals expected by your gui.lua
Config = PocketMeroe.db.profile
ClearModifier = Config.clear_modifier
MarkingModifier = Config.marking_modifier

-- Load your GUI code
dofile("./gui.lua")
PocketMeroeDB = PocketMeroeDB or PocketMeroe.db.profile

-- Now you can safely call ShowMenu()
PocketMeroe.gui.ShowMenu()
