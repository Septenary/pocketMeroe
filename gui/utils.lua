-- utils.lua
local utils = {}

function utils.tableRemoveAt(t, index)
    local new = {}
    for i, v in ipairs(t) do
        if i ~= index then table.insert(new, v) end
    end
    return new
end

function utils.tableInsertAt(t, val, index)
    local new = {}
    for i = 1, #t + 1 do
        if i == index then
            table.insert(new, val)
        elseif i < index then
            table.insert(new, t[i])
        else
            table.insert(new, t[i - 1])
        end
    end
    return new
end

function utils.GetModifierName(modTable)
    for _, key in ipairs({ "none", "alt", "ctrl", "shift" }) do
        if modTable[key] then return key end
    end
    return "none"
end

function utils.BuildModifierOptions(var, callback)
    local result = {}
    for _, modifier in ipairs({ "none", "alt", "ctrl", "shift" }) do
        table.insert(result, {
            label = modifier:gsub("^%l", string.upper),
            value = modifier,
            onclick = function() callback(var, modifier) end,
        })
    end
    return result
end

function utils.CreateRaidMarks(frame, showAll)
    local marks = {}
    for i = 1, (showAll and 16 or 8) do
        local tex = frame:CreateTexture(nil, "ARTWORK")
        tex:SetPoint("LEFT", (i - 1) * 20, 0)
        tex:SetSize(18, 18)
        tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
        SetRaidTargetIconTexture(tex, i)
        tex:SetShown(i <= 8 or showAll)
        marks[i] = tex
    end
    return marks
end

function utils.SetTabContainerBackdrop(container)
    container:SetTabFramesBackdrop({
        edgeFile = [[Interface\Buttons\WHITE8X8]],
        edgeSize = 1,
        bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
        tile = true,
        tileSize = 64,
    },
    DetailsFramework:GetDefaultBackdropColor(), {0, 0, 0, 1})
end

PocketMeroe.utils = utils
