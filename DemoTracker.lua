-------------------------------------------------------------------------------
-- Demon Tracker for Demonology Warlocks
-------------------------------------------------------------------------------


---------------
-- VARIABLES --
---------------

local demoTrackerPlayerGUID
local demoTrackerRegisteredForCombatEvent = false

-- counters for each demon type
local wildImpCount = 0
local dreadstalkerCount = 0
local grimoireCount = 0
local doomguardInfernalCount = 0
local darkglareCount = 0
-- array to hold each demon
local demoTrackerDemonArray = {}
-- keeps track of when demons should expire
local demoTrackerExpirationArray = {}
-- keeps track of which demons have Demonic Empowerment buff
local demoTrackerDemonicEmpowermentArray  = {}




-----------
-- FRAME --
-----------

-- create the primary frame
local demoTrackerFrame = CreateFrame("Frame", "demoTrackerFrame", UIParent)
demoTrackerFrame:SetBackdrop({
	bgFile = "Interface\\dialogframe\\ui-dialogbox-background-dark",
	edgeFile = "Interface\\tooltips\\UI-tooltip-Border",
	tile = false,
	tileSize = 32,
	edgeSize = 8,
	insets = {
		left = 1,
		right = 1,
		top = 1,
		bottom = 1,
	},
})
demoTrackerFrame:SetWidth(64)
demoTrackerFrame:SetHeight(128)
demoTrackerFrame:SetPoint("CENTER")
demoTrackerFrame:SetAlpha(0.7)

-- FRAME MOVEMENT
demoTrackerFrame:EnableMouse(true)
--demoTrackerFrame:EnableKeyboard(true)
demoTrackerFrame:SetMovable(true)
demoTrackerFrame:RegisterForDrag("RightButton")
demoTrackerFrame:SetUserPlaced(true)
--demoTrackerFrame:SetScript("OnKeyDown", function(self, key) if key == "SHIFT" then self:SetMovable(true) end end)
--demoTrackerFrame:SetScript("OnKeyUp", function(self, key) if key == "SHIFT" then self:SetMovable(false) end end)
demoTrackerFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
demoTrackerFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

-- DEMON COUNTERS
-- Wild Imps
local wildImpCounter = demoTrackerFrame:CreateFontString("wildImpCounter")
local wildImpTexture = demoTrackerFrame:CreateTexture("wildImpTexture")
local wildImpEmpower = demoTrackerFrame:CreateTexture("wildImpEmpower")
local wildImpTimer = demoTrackerFrame:CreateFontString("wildImpTimer")
-- Dreadstalkers
local dreadstalkerCounter = demoTrackerFrame:CreateFontString("dreadstalkerCounter")
local dreadstalkerTexture = demoTrackerFrame:CreateTexture("dreadstalkerTexture")
local dreadstalkerEmpower = demoTrackerFrame:CreateTexture("dreadstalkerEmpower")
local dreadstalkerTimer = demoTrackerFrame:CreateFontString("dreadstalkerTimer")
-- Grimoire
local grimoireCounter = demoTrackerFrame:CreateFontString("grimoireCounter")
local grimoireTexture = demoTrackerFrame:CreateTexture("grimoireTexture")
local grimoireEmpower = demoTrackerFrame:CreateTexture("grimoireEmpower")
local grimoireTimer = demoTrackerFrame:CreateFontString("grimoireTimer")
-- Doomguard and Infernal
local doomguardInfernalCounter = demoTrackerFrame:CreateFontString("doomguardInfernalCounter")
local doomguardInfernalTexture = demoTrackerFrame:CreateTexture("doomguardInfernalTexture")
local doomguardInfernalEmpower = demoTrackerFrame:CreateTexture("doomguardInfernalEmpower")
local doomguardInfernalTimer = demoTrackerFrame:CreateFontString("doomguardInfernalTimer")
-- Darkglare
local darkglareCounter = demoTrackerFrame:CreateFontString("darkglareCounter")
local darkglareTexture = demoTrackerFrame:CreateTexture("darkglareTexture")
local darkglareEmpower = demoTrackerFrame:CreateTexture("darkglareEmpower")
local darkglareTimer = demoTrackerFrame:CreateFontString("darkglareTimer")

   
   
   
   
   
----------------------
-- HELPER FUNCTIONS --
----------------------

-- Functions to check state of the warlock in question

local function isDemonology()
   local class, className = UnitClass("player")
   if className == "WARLOCK" and GetSpecialization() == 2 then
      return true
   else
      return false
   end
end

local function hasGrimoireOfService()
   _, _, _, GrimoireOfServiceSelected, _, _, _, _, _ = GetTalentInfo(6, 2, 1, false, nil)
   return GrimoireOfServiceSelected
end

local function hasGrimoireOfSupremacy()
   _, _, _, GrimoireOfSupremacySelected, _, _, _, _, _ = GetTalentInfo(6, 1, 1, false, nil)
   return GrimoireOfSupremacySelected
end

local function hasSummonDarkglare()
   _, _, _, SummonDarkglareSelected, _, _, _, _, _ = GetTalentInfo(7, 1, 1, false, nil)
   return SummonDarkglareSelected
end



-- functions to update the frame

local function setDemoTrackerFont()
   local trackerPosition = -2
   
	-- Wild Imps
	wildImpCounter:SetFont("Fonts\\FRIZQT__.TTF", 32, "OUTLINE")
	wildImpCounter:SetTextColor(1, 0, 1, 1)
	wildImpCounter:SetText(wildImpCount)
	wildImpCounter:SetJustifyH("CENTER")
	wildImpCounter:SetJustifyV("CENTER")
	wildImpCounter:SetPoint("TOP", demoTrackerFrame, -16, trackerPosition)
   trackerPosition = trackerPosition - 32
	
	-- Dreadstalkers
	dreadstalkerCounter:SetFont("Fonts\\FRIZQT__.TTF", 32, "OUTLINE")
	dreadstalkerCounter:SetTextColor(1, 0, 1, 1)
	dreadstalkerCounter:SetText(dreadstalkerCount)
	dreadstalkerCounter:SetJustifyH("CENTER")
	dreadstalkerCounter:SetJustifyV("CENTER")
	dreadstalkerCounter:SetPoint("TOP", demoTrackerFrame, -16, trackerPosition)
   trackerPosition = trackerPosition - 32
	
	-- Grimoire
   if hasGrimoireOfService() then
	grimoireCounter:SetFont("Fonts\\FRIZQT__.TTF", 32, "OUTLINE")
	grimoireCounter:SetTextColor(1, 0, 1, 1)
	grimoireCounter:SetText(grimoireCount)
	grimoireCounter:SetJustifyH("CENTER")
	grimoireCounter:SetJustifyV("CENTER")
	grimoireCounter:SetPoint("TOP", demoTrackerFrame, -16, trackerPosition)
   trackerPosition = trackerPosition - 32
   end
	
	-- Doomguard and Infernal
   if not hasGrimoireOfSupremacy() then
   doomguardInfernalCounter:SetFont("Fonts\\FRIZQT__.TTF", 32, "OUTLINE")
   doomguardInfernalCounter:SetTextColor(1, 0, 1, 1)
   doomguardInfernalCounter:SetText(doomguardInfernalCount)
   doomguardInfernalCounter:SetJustifyH("CENTER")
   doomguardInfernalCounter:SetJustifyV("CENTER")
   doomguardInfernalCounter:SetPoint("TOP", demoTrackerFrame, -16, trackerPosition)
   trackerPosition = trackerPosition - 32
   end
	
	-- Darkglare
   if hasSummonDarkglare() then
	darkglareCounter:SetFont("Fonts\\FRIZQT__.TTF", 32, "OUTLINE")
	darkglareCounter:SetTextColor(1, 0, 1, 1)
	darkglareCounter:SetText(darkglareCount)
	darkglareCounter:SetJustifyH("CENTER")
	darkglareCounter:SetJustifyV("CENTER")
	darkglareCounter:SetPoint("TOP", demoTrackerFrame, -16, trackerPosition)
   trackerPosition = trackerPosition - 32
   end
   
   return trackerPosition + 2
end

local function setDemoTrackerArtwork()
   local trackerPosition = 0
   
	-- Wild Imps
	wildImpTexture:SetTexture(GetSpellTexture("Summon Imp"))
	wildImpTexture:SetWidth(32)
	wildImpTexture:SetHeight(32)
	wildImpTexture:SetPoint("TOP", demoTrackerFrame, 16, trackerPosition)
   trackerPosition = trackerPosition - 32

	-- Dreadstalkers
	dreadstalkerTexture:SetTexture(GetSpellTexture("Call Dreadstalkers"))
	dreadstalkerTexture:SetWidth(32)
	dreadstalkerTexture:SetHeight(32)
	dreadstalkerTexture:SetPoint("TOP", demoTrackerFrame, 16, trackerPosition)
   trackerPosition = trackerPosition - 32

	-- Grimoire
   if hasGrimoireOfService() then
	grimoireTexture:SetTexture(GetSpellTexture("Command Demon"))
	grimoireTexture:SetWidth(32)
	grimoireTexture:SetHeight(32)
	grimoireTexture:SetPoint("TOP", demoTrackerFrame, 16, trackerPosition)
   trackerPosition = trackerPosition - 32
   end

	-- Doomguard and Infernal
   if not hasGrimoireOfSupremacy() then
   doomguardInfernalTexture:SetTexture(GetSpellTexture("Summon Doomguard"))
   doomguardInfernalTexture:SetWidth(32)
   doomguardInfernalTexture:SetHeight(32)
   doomguardInfernalTexture:SetPoint("TOP", demoTrackerFrame, 16, trackerPosition)
   trackerPosition = trackerPosition - 32
   end

	-- Darkglare
   if hasSummonDarkglare() then
	darkglareTexture:SetTexture(GetSpellTexture("Summon Darkglare"))
	darkglareTexture:SetWidth(32)
	darkglareTexture:SetHeight(32)
	darkglareTexture:SetPoint("TOP", demoTrackerFrame, 16, trackerPosition)
   trackerPosition = trackerPosition - 32
   end
   
   return trackerPosition
end

local function setDemoTrackerDemonicEmpowerment() -- TEST THIS --
   local trackerPosition = -16
   
   wildImpEmpower:SetTexture(GetSpellTexture("Demonic Empowerment"))
   wildImpEmpower:SetWidth(16)
   wildImpEmpower:SetHeight(16)
   wildImpEmpower:SetPoint("Top", demoTrackerFrame, 40, trackerPosition)
   trackerPosition = trackerPosition - 32
   
   dreadstalkerEmpower:SetTexture(GetSpellTexture("Demonic Empowerment"))
   dreadstalkerEmpower:SetWidth(16)
   dreadstalkerEmpower:SetHeight(16)
   dreadstalkerEmpower:SetPoint("Top", demoTrackerFrame, 40, trackerPosition)
   trackerPosition = trackerPosition - 32
   
   if hasGrimoireOfService() then
   grimoireEmpower:SetTexture(GetSpellTexture("Demonic Empowerment"))
   grimoireEmpower:SetWidth(16)
   grimoireEmpower:SetHeight(16)
   grimoireEmpower:SetPoint("Top", demoTrackerFrame, 40, trackerPosition)
   trackerPosition = trackerPosition - 32
   end
   
   if not hasGrimoireOfSupremacy() then
   doomguardInfernalEmpower:SetTexture(GetSpellTexture("Demonic Empowerment"))
   doomguardInfernalEmpower:SetWidth(16)
   doomguardInfernalEmpower:SetHeight(16)
   doomguardInfernalEmpower:SetPoint("Top", demoTrackerFrame, 40, trackerPosition)
   trackerPosition = trackerPosition - 32
   end
   
   if hasSummonDarkglare() then
   darkglareEmpower:SetTexture(GetSpellTexture("Demonic Empowerment"))
   darkglareEmpower:SetWidth(16)
   darkglareEmpower:SetHeight(16)
   darkglareEmpower:SetPoint("Top", demoTrackerFrame, 40, trackerPosition)
   trackerPosition = trackerPosition - 32
   end
   
   return trackerPosition
end

local function setDemoTrackerTimers()
   local trackerPosition = 0
   
   -- Wild Imps
	wildImpTimer:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
	wildImpTimer:SetTextColor(1, 1, 0, 1)
	wildImpTimer:SetText(0)
	wildImpTimer:SetJustifyH("CENTER")
	wildImpTimer:SetJustifyV("CENTER")
	wildImpTimer:SetPoint("TOP", demoTrackerFrame, 40, trackerPosition)
   trackerPosition = trackerPosition - 32
	
	-- Dreadstalkers
	dreadstalkerTimer:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
	dreadstalkerTimer:SetTextColor(1, 1, 0, 1)
	dreadstalkerTimer:SetText(0)
	dreadstalkerTimer:SetJustifyH("CENTER")
	dreadstalkerTimer:SetJustifyV("CENTER")
	dreadstalkerTimer:SetPoint("TOP", demoTrackerFrame, 40, trackerPosition)
   trackerPosition = trackerPosition - 32
	
	-- Grimoire
   if hasGrimoireOfService() then
	grimoireTimer:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
	grimoireTimer:SetTextColor(1, 1, 0, 1)
	grimoireTimer:SetText(0)
	grimoireTimer:SetJustifyH("CENTER")
	grimoireTimer:SetJustifyV("CENTER")
	grimoireTimer:SetPoint("TOP", demoTrackerFrame, 40, trackerPosition)
   trackerPosition = trackerPosition - 32
   end
   
   -- Doomguard and Infernal
   if not hasGrimoireOfSupremacy() then
   doomguardInfernalTimer:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
   doomguardInfernalTimer:SetTextColor(1, 1, 0, 1)
   doomguardInfernalTimer:SetText(0)
   doomguardInfernalTimer:SetJustifyH("CENTER")
   doomguardInfernalTimer:SetJustifyV("CENTER")
   doomguardInfernalTimer:SetPoint("TOP", demoTrackerFrame, 40, trackerPosition)
   trackerPosition = trackerPosition - 32
   end
	
	-- Darkglare
   if hasSummonDarkglare() then
	darkglareTimer:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
	darkglareTimer:SetTextColor(1, 1, 0, 1)
	darkglareTimer:SetText(0)
	darkglareTimer:SetJustifyH("CENTER")
	darkglareTimer:SetJustifyV("CENTER")
	darkglareTimer:SetPoint("TOP", demoTrackerFrame, 40, trackerPosition)
   trackerPosition = trackerPosition - 32
   end
   
   return trackerPosition
end


local function setGrimoireArtwork(demoSpellname)
   if demoSpellname == "Imp" then
      grimoireTexture:SetTexture(GetSpellTexture("Grimoire: Imp"))
   elseif demoSpellname == "Voidwalker" then
      grimoireTexture:SetTexture(GetSpellTexture("Grimoire: Voidwalker"))
   elseif demoSpellname == "Succubus" then
      grimoireTexture:SetTexture(GetSpellTexture("Grimoire: Succubus"))
   elseif demoSpellname == "Felhunter" then
      grimoireTexture:SetTexture(GetSpellTexture("Grimoire: Felhunter"))
   elseif demoSpellname == "Felguard" then
      grimoireTexture:SetTexture(GetSpellTexture("Grimoire: Felguard"))
   else
      grimoireTexture:SetTexture(GetSpellTexture("Command Demon"))
   end
end

local function setDoomguardInfernalArtwork(demoSpellname)
   if demoSpellname == "Doomguard" then
      doomguardInfernalTexture:SetTexture(GetSpellTexture("Summon Doomguard"))
   elseif demoSpellname == "Infernal" then
      doomguardInfernalTexture:SetTexture(GetSpellTexture("Summon Infernal"))
   else
      doomguardInfernalTexture:SetTexture(GetSpellTexture("Summon Doomguard"))
   end
end


local function updateDemoTrackerFrame()

   if isDemonology() then
      demoTrackerFrame:Show()
      demoTrackerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
      demoTrackerRegisteredForCombatEvent = true
      
	   local height = setDemoTrackerFont()
      local dtPoint, dtRelTo, dtRPoint, dtXOff, dtYOff = demoTrackerFrame:GetPoint(1)
      setDemoTrackerArtwork()
      setDemoTrackerDemonicEmpowerment()
      setDemoTrackerTimers()
      --demoTrackerFrame:SetHeight(height)
      
      wildImpEmpower:Hide()
      dreadstalkerEmpower:Hide()
      grimoireEmpower:Hide()
      doomguardInfernalEmpower:Hide()
      darkglareEmpower:Hide()
      
      wildImpTimer:Hide()
      dreadstalkerTimer:Hide()
      grimoireTimer:Hide()
      doomguardInfernalTimer:Hide()
      darkglareTimer:Hide()
      
      if hasSummonDarkglare() then
         darkglareCounter:Show()
         darkglareTexture:Show()
      else
         darkglareCounter:Hide()
         darkglareTexture:Hide()
      end

      if hasGrimoireOfService() then
         grimoireCounter:Show()
         grimoireTexture:Show()
      else
         grimoireCounter:Hide()
         grimoireTexture:Hide()
      end
      
      if hasGrimoireOfSupremacy() then
         doomguardInfernalCounter:Hide()
         doomguardInfernalTexture:Hide()
      else
         doomguardInfernalCounter:Show()
         doomguardInfernalTexture:Show()
      end
         
	else  
      demoTrackerFrame:Hide()
      if demoTrackerRegisteredForCombatEvent == true then
         demoTrackerFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
      end
   end
   
end
   
   
   
   
   
------------
-- EVENTS --
------------

function demoTrackerFrame:PLAYER_ENTERING_WORLD(self, event, ...)
	demoTrackerPlayerGUID = UnitGUID("player")
   
	updateDemoTrackerFrame()
   --demoTrackerFrame:Hide()
   
   -- events to watch to see if they switched to a demo spec
	demoTrackerFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
	demoTrackerFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	demoTrackerFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
   
   demoTrackerFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
   demoTrackerFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
   demoTrackerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
   demoTrackerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	
	demoTrackerFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end


function demoTrackerFrame:CHARACTER_POINTS_CHANGED(self, event, ...)
   updateDemoTrackerFrame()
end

function demoTrackerFrame:PLAYER_TALENT_UPDATE(self, event, ...)
   updateDemoTrackerFrame()
end

function demoTrackerFrame:ACTIVE_TALENT_GROUP_CHANGED(self, event, ...)
   updateDemoTrackerFrame()
end

function demoTrackerFrame:PLAYER_ENTER_COMBAT(self, event, ...)
  --demoTrackerFrame:Show()
end

function demoTrackerFrame:PLAYER_LEAVE_COMBAT(self, event, ...)
   --demoTrackerFrame:Hide()
end

function demoTrackerFrame:PLAYER_REGEN_DISABLED(self, event, ...)
   --demoTrackerFrame:Show()
end

function demoTrackerFrame:PLAYER_REGEN_ENABLED(self, event, ...)
   --demoTrackerFrame:Hide()
end


function demoTrackerFrame:COMBAT_LOG_EVENT_UNFILTERED(self, event, ...)

   local Timestamp = GetTime()
   local combatEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, _, spellName = ...
   
   -- a demon was summoned
   if combatEvent == "SPELL_SUMMON" and sourceGUID == demoTrackerPlayerGUID then
      if destName == "Wild Imp" then
         demoTrackerDemonArray[destGUID] = "Wild Imp"
         demoTrackerExpirationArray[destGUID] = Timestamp
         wildImpCount = wildImpCount + 1
         wildImpEmpower:Hide()
         wildImpTimer:Show()
      elseif destName == "Dreadstalker" then
         demoTrackerDemonArray[destGUID] = "Dreadstalker"
         demoTrackerExpirationArray[destGUID] = Timestamp
         dreadstalkerCount = dreadstalkerCount + 1
         dreadstalkerEmpower:Hide()
         dreadstalkerTimer:Show()
      elseif destName == "Felguard" or destName == "Felhunter" or destName == "Succubus" or destName == "Voidwalker" or destName == "Imp" then
         demoTrackerDemonArray[destGUID] = "Grimoire of Service"
         demoTrackerExpirationArray[destGUID] = Timestamp
         grimoireCount = grimoireCount + 1
         grimoireEmpower:Hide()
         grimoireTimer:Show()
         setGrimoireArtwork(destName)
      elseif destName == "Doomguard" and not hasGrimoireOfSupremacy() then
         demoTrackerDemonArray[destGUID] = "Doomguard"
         demoTrackerExpirationArray[destGUID] = Timestamp
         doomguardInfernalCount = doomguardInfernalCount + 1
         doomguardInfernalEmpower:Hide()
         doomguardInfernalTimer:Show()
         setDoomguardInfernalArtwork(destName)
      elseif destName == "Infernal" and not hasGrimoireOfSupremacy() then
         demoTrackerDemonArray[destGUID] = "Infernal"
         demoTrackerExpirationArray[destGUID] = Timestamp
         doomguardInfernalCount = doomguardInfernalCount + 1
         doomguardInfernalEmpower:Hide()
         doomguardInfernalTimer:Show()
         setDoomguardInfernalArtwork(destName)
      elseif destName == "Darkglare" then
         demoTrackerDemonArray[destGUID] = "Darkglare"
         demoTrackerExpirationArray[destGUID] = Timestamp
         darkglareCount = darkglareCount + 1
         darkglareEmpower:Hide()
         darkglareTimer:Show()
      end
   end
   
   
   -- a demon died
   if combatEvent == "UNIT_DIED" or combatEvent == "PARTY_KILL" or combatEvent == "SPELL_INSTAKILL" then
      for i, value in pairs(demoTrackerDemonArray) do
         if destGUID == i then
            if value == "Wild Imp" then
               print("Wild Imp died")
               wildImpCount = wildImpCount - 1
               if wildImpCount == 0 then
                  wildImpEmpower:Hide()
                  wildImpTimer:Hide()
               end 
            elseif value == "Dreadstalker" then
               print("Dreadstalker died")
               dreadstalkerCount = dreadstalkerCount - 1
               if dreadstalkerCount == 0 then
                  dreadstalkerEmpower:Hide()
                  dreadstalkerTimer:Hide()
               end
            elseif value == "Grimoire of Service" then
               print("Grimoire of Service died") 
               grimoireCount = grimoireCount - 1
               if grimoireCount == 0 then
                  grimoireEmpower:Hide()
                  grimoireTimer:Hide()
               end
            elseif value == "Doomguard" then
               print("Doomguard died")
               doomguardInfernalCount = doomguardInfernalCount - 1
               if doomguardInfernalCount == 0 then
                  doomguardInfernalEmpower:Hide()
                  doomguardInfernalTimer:Hide()
               end
            elseif value == "Infernal" then
               print("Infernal died")
               doomguardInfernalCount = doomguardInfernalCount - 1
               if doomguardInfernalCount == 0 then
                  doomguardInfernalEmpower:Hide()
                  doomguardInfernalTimer:Hide()
               end
            elseif value == "Darkglare" then
               print("Darkglare died")
               darkglareCount = darkglareCount - 1
               if darkglareCount == 0 then
                  darkglareEmpower:Hide()
                  darkglareTimer:Hide()
               end
            end
            demoTrackerDemonArray[i] = nil
            demoTrackerExpirationArray[i] = nil
            demoTrackerDemonicEmpowermentArray[i] = nil
         end
      end
   end
   
   
   --Demonic Empowerment was cast
   if combatEvent == "SPELL_CAST_SUCCESS" and sourceGUID == demoTrackerPlayerGUID and spellName == "Demonic Empowerment" then
      
      for i, value in pairs(demoTrackerDemonArray) do
         demoTrackerDemonicEmpowermentArray[i] = Timestamp
      end
      
      if wildImpCount > 0 then
         wildImpEmpower:Show()
      end
      if dreadstalkerCount > 0 then
         dreadstalkerEmpower:Show()
      end
      if grimoireCount > 0 then
         grimoireEmpower:Show()
      end
      if doomguardInfernalCount > 0 then
         doomguardInfernalEmpower:Show()
      end
      if darkglareCount > 0 then
         darkglareEmpower:Show()
      end
      
   end
   
   
   -- update counters
   wildImpCounter:SetText(wildImpCount)
   dreadstalkerCounter:SetText(dreadstalkerCount)
   if hasGrimoireOfService() then
      grimoireCounter:SetText(grimoireCount)
   end
   if not hasGrimoireOfSupremacy() then
      doomguardInfernalCounter:SetText(doomguardInfernalCount)
   end
   if hasSummonDarkglare() then
      darkglareCounter:SetText(darkglareCount)
   end
   
end



local function demoTrackerFrameOnUpdate(self, elapsed)

   local Timestamp = GetTime()
   
   -- a demon expired
   for i, value in pairs(demoTrackerDemonArray) do
      if value == "Wild Imp" then
         if (demoTrackerExpirationArray[i] + 12) < Timestamp then
            demoTrackerDemonArray[i] = nil
            demoTrackerExpirationArray[i] = nil
            demoTrackerDemonicEmpowermentArray[i] = nil
            wildImpCount = wildImpCount - 1
            if wildImpCount == 0 then
               wildImpEmpower:Hide()
               wildImpTimer:Hide()
            end
         end
      elseif value == "Dreadstalker" then
         if (demoTrackerExpirationArray[i] + 12) < Timestamp then
            demoTrackerDemonArray[i] = nil
            demoTrackerExpirationArray[i] = nil
            demoTrackerDemonicEmpowermentArray[i] = nil
            dreadstalkerCount = dreadstalkerCount - 1
            if dreadstalkerCount == 0 then
               dreadstalkerEmpower:Hide()
               dreadstalkerTimer:Hide()
            end
         end
      elseif value == "Grimoire of Service" then
         if (demoTrackerExpirationArray[i] + 25) < Timestamp then
            demoTrackerDemonArray[i] = nil
            demoTrackerExpirationArray[i] = nil
            demoTrackerDemonicEmpowermentArray[i] = nil
            grimoireCount = grimoireCount - 1
            setGrimoireArtwork("default")
            if grimoireCount == 0 then
               grimoireEmpower:Hide()
               grimoireTimer:Hide()
            end
         end
      elseif value == "Doomguard" and not hasGrimoireOfSupremacy() then
         if (demoTrackerExpirationArray[i] + 25) < Timestamp then
            demoTrackerDemonArray[i] = nil
            demoTrackerExpirationArray[i] = nil
            demoTrackerDemonicEmpowermentArray[i] = nil
            doomguardInfernalCount = doomguardInfernalCount - 1
            setDoomguardInfernalArtwork("default")
            if doomguardInfernalCount == 0 then
               doomguardInfernalEmpower:Hide()
               doomguardInfernalTimer:Hide()
            end
         end
      elseif value == "Infernal" and not hasGrimoireOfSupremacy() then
         if (demoTrackerExpirationArray[i] + 25) < Timestamp then
            demoTrackerDemonArray[i] = nil
            demoTrackerExpirationArray[i] = nil
            demoTrackerDemonicEmpowermentArray[i] = nil
            doomguardInfernalCount = doomguardInfernalCount - 1
            setDoomguardInfernalArtwork("default")
            if doomguardInfernalCount == 0 then
               doomguardInfernalEmpower:Hide()
               doomguardInfernalTimer:Hide()
            end
         end
      elseif value == "Darkglare" then
         if (demoTrackerExpirationArray[i] + 12) < Timestamp then
            demoTrackerDemonArray[i] = nil
            demoTrackerExpirationArray[i] = nil
            demoTrackerDemonicEmpowermentArray[i] = nil
            darkglareCount = darkglareCount - 1
            if darkglareCount == 0 then
               darkglareEmpower:Hide()
               darkglareTimer:Hide()
            end
         end
      end
   end
   
   
   --Demonic Empowerment expired
   for i, value in pairs(demoTrackerDemonicEmpowermentArray) do
      if (value + 12) < Timestamp then
         demoTrackerDemonicEmpowermentArray[i] = nil
         if demoTrackerDemonArray[i] == "Wild Imp" then
            wildImpEmpower:Hide()
         elseif demoTrackerDemonArray[i] == "Dreadstalker" then
            dreadstalkerEmpower:Hide()
         elseif demoTrackerDemonArray[i] == "Grimoire of Service" then
            grimoireEmpower:Hide()
         elseif demoTrackerDemonArray[i] == "Doomguard" then
            doomguardInfernalEmpower:Hide()
         elseif demoTrackerDemonArray[i] == "Infernal" then
            doomguardInfernalEmpower:Hide()
         elseif demoTrackerDemonArray[i] == "Darkglare" then
            darkglareEmpower:Hide()
         end
      end
   end
   
   
   -- update timers
   local wildImpOldest, dreadstalkerOldest, grimoireOldest = 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
   local doomguardInfernalOldest, darkglareOldest = 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
   for i, value in pairs(demoTrackerDemonArray) do
      if value == "Wild Imp" and demoTrackerExpirationArray[i] < wildImpOldest then
         wildImpOldest = demoTrackerExpirationArray[i]
      elseif value == "Dreadstalker" and demoTrackerExpirationArray[i] < dreadstalkerOldest then
         dreadstalkerOldest = demoTrackerExpirationArray[i]
      elseif value == "Grimoire of Service" and demoTrackerExpirationArray[i] < grimoireOldest then
         grimoireOldest = demoTrackerExpirationArray[i]
      elseif value == "Doomguard" and demoTrackerExpirationArray[i] < doomguardInfernalOldest then
         doomguardInfernalOldest = demoTrackerExpirationArray[i]
      elseif value == "Infernal" and demoTrackerExpirationArray[i] < doomguardInfernalOldest then
         doomguardInfernalOldest = demoTrackerExpirationArray[i]
      elseif value == "Darkglare" and demoTrackerExpirationArray[i] < darkglareOldest then
         darkglareOldest = demoTrackerExpirationArray[i]
      end
   end
   
   if wildImpCount > 0 then
      wildImpTimer:SetText(ceil(12 - Timestamp + wildImpOldest))
   end
   if dreadstalkerCount > 0 then
      dreadstalkerTimer:SetText(ceil(12 - Timestamp + dreadstalkerOldest))
   end
   if grimoireCount > 0 then
      grimoireTimer:SetText(ceil(25 - Timestamp + grimoireOldest))
   end
   if doomguardInfernalCount > 0 then
      doomguardInfernalTimer:SetText(ceil(25 - Timestamp + doomguardInfernalOldest))
   end
   if darkglareCount > 0 then
      darkglareTimer:SetText(ceil(12 - Timestamp + darkglareOldest))
   end
   
   
   -- update counters
   wildImpCounter:SetText(wildImpCount)
   dreadstalkerCounter:SetText(dreadstalkerCount)
   if hasGrimoireOfService() then
      grimoireCounter:SetText(grimoireCount)
   end
   if not hasGrimoireOfSupremacy() then
      doomguardInfernalCounter:SetText(doomguardInfernalCount)
   end
   if hasSummonDarkglare() then
      darkglareCounter:SetText(darkglareCount)
   end
   
end





----------------------
-- START THE ENGINE --
----------------------

demoTrackerFrame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)
demoTrackerFrame:SetScript("OnUpdate", demoTrackerFrameOnUpdate)
demoTrackerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")