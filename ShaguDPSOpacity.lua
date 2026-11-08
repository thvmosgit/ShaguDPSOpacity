-- ShaguDPS Opacity - OEVG edition
--
-- Adds an "OOC Opacity" row to ShaguDPS's settings window (under "Window"): out of combat
-- all ShaguDPS windows are shown at that opacity, in combat at full opacity. 10% - 100% in
-- steps of 10%; 100% = off. While the mouse is over a window it is fully opaque.
--
-- The value is kept in ShaguDPS's own config table (config.ooc_alpha), which ShaguDPS saves
-- as ShaguDPS_Config together with its other settings. ShaguDPS's files stay untouched.

local ShaguDPS = ShaguDPS
if not ShaguDPS or not ShaguDPS.config or not ShaguDPS.settings or not ShaguDPS.window then return end

local config = ShaguDPS.config
local settings = ShaguDPS.settings
local window = ShaguDPS.window

local MIN_ALPHA, MAX_ALPHA, STEP = 0, 1, 0.1

local function oocAlpha()
	local a = tonumber(config.ooc_alpha) or 1
	if a < MIN_ALPHA then a = MIN_ALPHA end
	if a > MAX_ALPHA then a = MAX_ALPHA end
	return a
end

local inCombat = false

-- In combat, or with the mouse over a window: fully opaque.
local function applyAlpha()
	local ooc = inCombat and 1 or oocAlpha()
	for i = 1, 10 do
		local w = window[i]
		if w and w.SetAlpha then
			local a = (ooc < 1 and MouseIsOver(w)) and 1 or ooc
			if math.abs(w:GetAlpha() - a) > 0.001 then w:SetAlpha(a) end
		end
	end
end

-- Default; ShaguDPS copies the saved value over it at PLAYER_ENTERING_WORLD.
config.ooc_alpha = config.ooc_alpha or 1

-- Windows created later (the "+" button) or re-laid out get the current alpha too.
local origRefresh = window.Refresh
window.Refresh = function(force, report)
	origRefresh(force, report)
	applyAlpha()
end

-- Settings row: ShaguDPS's own number selector (< value >), with its change function
-- replaced so it steps by 10% and shows a percentage.
-- OEVG builds its settings controls on the first opening.
-- Run its existing OnShow first, then add the opacity row.
local opacityRowAdded = false

local function AddOpacityRow()
	if opacityRowAdded then return end
	if not settings.CreateConfig then return end

	settings:CreateConfig("OOC Opacity", "ooc_alpha", "number")

	-- Find the selector by its config key rather than assuming
	-- GetChildren() returns newly created controls last.
	local input
	local children = { settings:GetChildren() }

	for _, child in pairs(children) do
		if child.entry == "ooc_alpha" and child.caption then
			input = child
			break
		end
	end

	if not input then return end
	opacityRowAdded = true

	input.change = function(self, mod)
		local a = oocAlpha()

		if mod then
			a = math.floor((a + mod * STEP) * 10 + 0.5) / 10
			if a < MIN_ALPHA then a = MIN_ALPHA end
			if a > MAX_ALPHA then a = MAX_ALPHA end
		end

		config.ooc_alpha = a
		self.caption:SetText(math.floor(a * 100 + 0.5) .. "%")

		-- Classic theme uses enabled/disabled stock buttons;
		-- Flat theme uses alpha to indicate the limits.
		if ShaguDPS.classic then
			if a <= MIN_ALPHA then
				self.left:Disable()
			else
				self.left:Enable()
			end

			if a >= MAX_ALPHA then
				self.right:Disable()
			else
				self.right:Enable()
			end
		else
			self.left:SetAlpha(a <= MIN_ALPHA and 0.25 or 1)
			self.right:SetAlpha(a >= MAX_ALPHA and 0.25 or 1)
		end

		applyAlpha()
	end

	-- make room for the extra row
	settings:SetHeight(settings:GetHeight() + 20)

	-- CreateConfig shows the selector before we replace change(),
	-- so update its initial caption explicitly.
	input:change()
end

local originalOnShow = settings:GetScript("OnShow")

settings:SetScript("OnShow", function()
	if originalOnShow then originalOnShow() end
	AddOpacityRow()
end)

-- Also handle installation after settings have already been built.
if settings.built then
	AddOpacityRow()
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function()
	if event == "PLAYER_REGEN_DISABLED" then
		inCombat = true
	elseif event == "PLAYER_REGEN_ENABLED" then
		inCombat = false
	else
		inCombat = UnitAffectingCombat("player") and true or false
	end
	applyAlpha()
end)

-- Mouseover check, 10 times a second (only does anything while windows are faded).
local nextTick = 0
events:SetScript("OnUpdate", function()
	local now = GetTime()
	if now < nextTick then return end
	nextTick = now + 0.1
	if not inCombat and oocAlpha() < 1 then applyAlpha() end
end)
