-----------------------------------------------------------------------------------------------
-- Client Lua Script for RMT_BossMods
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- RMT_BossMods Module Definition
-----------------------------------------------------------------------------------------------
local RMT_BossMods = {} 
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function RMT_BossMods:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function RMT_BossMods:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		 "LUI_BossMods",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 
-----------------------------------------------------------------------------------------------
-- RMT_BossMods OnLoad
-----------------------------------------------------------------------------------------------
function RMT_BossMods:OnLoad()
	local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
--	LUI_BossMods.xmlDoc:RegisterCallback("OnDocLoaded", LUI_BossMods)
    LUI_BossMods:LoadWindows()
    LUI_BossMods:LoadModules()
    LUI_BossMods:LoadSettings()

    if LUI_BossMods.tPreloadUnits then
        LUI_BossMods:CreateUnitsFromPreload()
    end

    LUI_BossMods:OnCharacterCreated()

end

-----------------------------------------------------------------------------------------------
-- RMT_BossMods OnDocLoaded
-----------------------------------------------------------------------------------------------
function RMT_BossMods:OnDocLoaded()
	local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
	-- No init needed

end

-----------------------------------------------------------------------------------------------
-- RMT_BossMods Instance
-----------------------------------------------------------------------------------------------
local RMT_BossModsInst = RMT_BossMods:new()
RMT_BossModsInst:Init()
