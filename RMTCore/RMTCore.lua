-----------------------------------------------------------------------------------------------
-- Client Lua Script for RMTCore
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- RMTCore Module Definition
-----------------------------------------------------------------------------------------------
local RMTCore = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function RMTCore:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function RMTCore:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		 "RaidCore",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- RMTCore OnLoad
-----------------------------------------------------------------------------------------------
function RMTCore:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("RMTCore.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

--	local myRC = Apollo.GetAddon("RaidCore")
--	myRC.xmlDoc = XmlDoc.CreateFromFile("RaidCore.xml")
--	myRC.xmlDoc:RegisterCallback("OnDocLoaded", myRC)

--        myRC:OnInitialize()
end

-----------------------------------------------------------------------------------------------
-- RMTCore OnDocLoaded
-----------------------------------------------------------------------------------------------
function RMTCore:OnDocLoaded()
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "RMTCoreForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

	
		-- if the xmlDoc is no longer needed, you should set it to nil
		self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- RMTCore Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-----------------------------------------------------------------------------------------------
-- RMTCoreForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function RMTCore:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function RMTCore:OnCancel()
	self.wndMain:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- RMTCore Instance
-----------------------------------------------------------------------------------------------
local RMTCoreInst = RMTCore:new()
RMTCoreInst:Init()
