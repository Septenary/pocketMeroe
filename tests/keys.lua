-- Mock WoW Global Environment

-- Simulate WoW-style environment
local PocketMeroe = {
	db = {
		profile = {
			use_mouseover = true,
			require_leader = true,
			marking_modifier = { alt = true, ctrl = false, shift = false },
			clear_modifier   = { alt = false, ctrl = false, shift = true },
		}
	}
}

-- Simulate key state (change these in your tests)
local keyState = {
	alt = false,
	ctrl = false,
	shift = false,
}

-- Simulate WoW API functions
function UnitIsGroupLeader(unit)
	return unit == "player" and true -- always assume we're leader for testing
end

function IsAltKeyDown()    return keyState.alt   end
function IsControlKeyDown() return keyState.ctrl  end
function IsShiftKeyDown()   return keyState.shift end

-- Marks table with your function
local Marks = {}

function Marks:markersEnabled()
	local config = PocketMeroe.db.profile
	local mark = config.marking_modifier
	local clear = config.clear_modifier

	if not config.use_mouseover then return false end
	if not mark then return false end
	if config.require_leader and not UnitIsGroupLeader("player") then return false end

	if (IsAltKeyDown() and (clear.alt or mark.alt))
		or (IsControlKeyDown() and (clear.ctrl or mark.ctrl))
		or (IsShiftKeyDown() and (clear.shift or mark.shift)) then
		return true
	end

	return false
end

-- Helper: test with specific keys pressed
local function testCase(description, alt, ctrl, shift)
	keyState.alt = alt
	keyState.ctrl = ctrl
	keyState.shift = shift

	local result = Marks:markersEnabled()
	print(description .. ": " .. tostring(result))
end

-- Run test cases
print("== PocketMeroe Test ==")
testCase("No keys", false, false, false)
testCase("Alt pressed", true, false, false)
testCase("Ctrl pressed", false, true, false)
testCase("Shift pressed", false, false, true)
testCase("Alt+Shift pressed", true, false, true)
