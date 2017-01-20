----------------------------------------------------------------------------------------------------
-- Robomination encounter script
--
-- Copyright (C) 2016 Joshua Shaffer
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Robomination", {104, 104}, {0, 548}, {548, 551})
if not mod then return end

mod:RegisterTrigMob("ANY", { "Robomination" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["Robomination"] = "Robomination",
	["Cannon Arm"] = "Cannon Arm",
	["Flailing Arm"] = "Flailing Arm",
    ["Scanning Eye"] = "Scanning Eye",
    ["Trash Compactor"] = "Trash Compactor", --What are these? live 5.5 seconds
    -- Datachron messages.
    ["Robomination Tries to crush %s"] = "Robomination Tries to crush",
    ["The Robomination sinks down into the trash"] = "The Robomination sinks down into the trash",
    ["The Robomination erupts back into the fight!"] = "The Robomination erupts back into the fight!",
    ["The Robomination tries to incinerate %s"] = "The Robomination tries to incinerate",
    -- Cast.
	["Noxious Belch"] = "Noxious Belch",
    ["Incineration Laser"] = "Incineration Laser",
    ["Cannon Fire"] = "Cannon Fire",
    -- Bar and messages.
    ["SMASH"] = "SMASH",
	["SMASH ON YOU"] = "SMASH ON YOU",
    ["SMASH NEAR YOU"] = "SMASH NEAR YOU",
    ["SMASH ON %s!"] = "SMASH ON %s!",
    ["Midphase soon!"] = "Midphase soon!",
})

mod:RegisterDefaultSetting("LinesFlailingArms", false)
mod:RegisterDefaultSetting("LinesCannonArms")
mod:RegisterDefaultSetting("LinesScanningEye")
mod:RegisterDefaultSetting("MarkSmashTarget")
mod:RegisterDefaultSetting("MarkIncineratedPlayer")
mod:RegisterDefaultSetting("SmashWarningSound")
mod:RegisterDefaultSetting("BelchWarningSound")
mod:RegisterDefaultSetting("MidphaseWarningSound")
mod:RegisterDefaultSetting("IncinerationWarningSound")
mod:RegisterDefaultSetting("CannonArmInterruptSound", false)

mod:RegisterDefaultTimerBarConfigs({
    ["ARMS"] = { sColor = "red" },
    ["BELCH"] = { sColor = "FF00CC00" },
    ["SKYFALL"] = { sColor = "FF808080" },
    ["INCINERATION"] = { sColor = "FFFF0020", bEmphasize = true },
    ["MIDPHASE"] = { sColor = "black" },
})

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local DEBUFF__ATOMIC_SPEAR = 70161 --Tank debuff of some sort?
local DEBUFF__THE_SKY_IS_FALLING = 75126 --Smash target
local DEBUFF__INCINERATION_LASER = 75496 --Laser target, rooted till someone else steps into the beam
local DEBUFF__MELTED_ARMOR = 83814 --Has stacks, 65% extra damage from laser per stack
local DEBUFF__TRACTOR_BEAM = 75623 --Yoink!
local DEBUFF__DISCHARGE = 84304 --Something the eye casts during mid phase maybe?
local NewVector3 = Vector3.New
local CARDINAL_MARKERS = {
    ["north"] = { x = -5, y = -203, z = -1394 },
    ["south"] = { x = -5, y = -203, z = -1279 },
    ["east"] = { x = 55, y = -203, z = -1337 },
    ["west"] = { x = -62, y = -203, z = -1337 },
}
local STATIC_LINES = {
    { NewVector3(-30, -203, -1338), NewVector3(35, -203, -1338), "xkcdAmber" },
    { NewVector3(-30, -203, -1336), NewVector3(35, -203, -1336), "xkcdGreen" },
--    { NewVector3(-5, -203, -1259), NewVector3(-5, -203, -1414) },
}

local cbnumber = 0
local ptype = 0
local roboId

----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local bMidPhase1Warning, bMidPhase2Warning

local bInMidPhase

----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
        for i, Vectors in next, STATIC_LINES do
            core:AddLineBetweenUnits("StaticLine" .. i, Vectors[1], Vectors[2], 3, Vectors[3] )
        end
    -- Remove previous markers
    core:DropWorldMarker("NORTH")
    core:DropWorldMarker("SOUTH")
    core:DropWorldMarker("EAST")
    core:DropWorldMarker("WEST")

    -- Set markers
    core:SetWorldMarker("NORTH", "N", CARDINAL_MARKERS["north"])
    core:SetWorldMarker("SOUTH", "S", CARDINAL_MARKERS["south"])
    core:SetWorldMarker("EAST", "E", CARDINAL_MARKERS["east"])
    core:SetWorldMarker("WEST", "W", CARDINAL_MARKERS["west"])


    mUnit = GameLib.GetPlayerUnit()
    classId = mUnit:GetClassId()
    if (mUnit:GetAssaultPower() > mUnit:GetSupportPower()) then
        ptype = 0
    elseif (classId == GameLib.CodeEnumClass.Esper or classId == GameLib.CodeEnumClass.Medic or classId == GameLib.CodeEnumClass.Spellslinger) then
        ptype = 1
    else
        ptype = 2
    end

    bMidPhase1Warning = false
    bMidPhase2Warning = false
    bInMidPhase = false
    mod:AddTimerBar("ARMS", "Next arms", 45, nil)
    mod:AddTimerBar("BELCH", "Next noxious belch", 15, nil)
--    mod:AddTimerBar("SKYFALL", "Next sky is falling", 4, nil)
end

function mod:OnHealthChanged(nId, nPercent, sName)
    if sName == self.L["Robomination"] then
        if nPercent >= 75 and nPercent <= 77 and not bMidPhase1Warning then
            bMidPhase1Warning = true
            mod:AddMsg("MIDPHASEWARNING", self.L["Midphase soon!"], 5, mod:GetSetting("MidphaseWarningSound") and "Algalon")
        elseif nPercent >= 50 and nPercent <= 57 and not bMidPhase2Warning then
            bMidPhase2Warning = true
            mod:AddMsg("MIDPHASEWARNING", self.L["Midphase soon!"], 5, mod:GetSetting("MidphaseWarningSound") and "Algalon")
        end
    end
end

function mod:OnDebuffAdd(nId, nSpellId, nStack, fTimeRemaining)
--    Print(GameLib.GetSpell(nSpellId):GetName() .. "=" .. nSpellId)
    local tUnit = GameLib.GetUnitById(nId)
    local player = GameLib.GetPlayerUnit()

    if DEBUFF__THE_SKY_IS_FALLING == nSpellId then
        mod:AddTimerBar("SKYFALL", "Next sky is falling", 17, nil)
        core:AddPolygon(nId, nId, 6.7, 0, 7, "xkcdBloodOrange", 20)
--	core:AddPixie(nId, 2, tUnit, nil, "xkcdBloodOrange", 15, 15, 0)
        if tUnit == player then
            mod:AddMsg("SMASH", "SMASH ON YOU!", 5, mod:GetSetting("SmashWarningSound") and "RunAway")
        elseif mod:GetDistanceBetweenUnits(player, tUnit) < 10 then
            mod:AddMsg("SMASH", self.L["SMASH NEAR YOU"]:format(sName), 5, mod:GetSetting("SmashWarningSound") and "Info")
        else
            local sName = tUnit:GetName()
            mod:AddMsg("SMASH", self.L["SMASH ON %s!"]:format(sName), 5, mod:GetSetting("SmashWarningSound") and "Info")
        end
        if mod:GetSetting("MarkSmashTarget") then
            core:AddPicture(nId, nId, "Crosshair", 40, nil, nil, nil, "red")
        end
    elseif DEBUFF__INCINERATION_LASER == nSpellId then
        if mod:GetSetting("MarkIncineratedPlayer") then
            core:AddPicture("LASER" .. nId, nId, "Crosshair", 40, nil, nil, nil, "xkcdWhite")
        end
    end
end

function mod:OnDebuffRemove(nId, nSpellId)
    if DEBUFF__THE_SKY_IS_FALLING == nSpellId then
--	core:DropPixie(nId)
	core:RemovePolygon(nId)
        core:RemovePicture(nId)
    elseif DEBUFF__INCINERATION_LASER == nSpellId then
        core:RemovePicture("LASER" .. nId)
    end
end

function mod:OnCastStart(nId, sCastName, nCastEndTime, sName)
--    Print(sName .. " casting: " .. sCastName)
    local tUnit = GameLib.GetUnitById(nId)
    local player = GameLib.GetPlayerUnit()

    if self.L["Robomination"] == sName then
        if self.L["Noxious Belch"] == sCastName then
            mod:AddMsg("BELCH", "Noxious Belch", 5, mod:GetSetting("BelchWarningSound") and "Beware")
            mod:AddTimerBar("BELCH", "Next noxious belch", 30, nil)
            
            --self:AddPolygon("PLAYER_BELCH", GameLib.GetPlayerUnit():GetPosition(), 8, 0, 3, "xkcdBrightPurple", 16)
        end
    elseif self.L["Cannon Arm"] == sName and mod:GetDistanceBetweenUnits(player, tUnit) < 25 then
        if self.L["Cannon Fire"] == sCastName then
            cbnumber = cbnumber + 1
            if (cbnumber > 3) then 
                cbnumber = 1
            end
            mod:AddMsg("CANNONBLAST", "Interrupt " .. cbnumber .. "!", 2, "Alert")
        end
    end
end

function mod:OnDatachron(sMessage)
    if sMessage == self.L["The Robomination sinks down into the trash"] then
        bInMidPhase = true
        mod:AddMsg("MIDPHASE", "Get to center!", 5, "Info")
        mod:RemoveTimerBar("ARMS")
        mod:RemoveTimerBar("BELCH")
        mod:RemoveTimerBar("SKYFALL")
        mod:RemoveTimerBar("INCINERATION")
        mod:AddTimerBar("MIDPHASE", "Midphase", 999)
--	core:RemovePolygon(nId)
    elseif sMessage == self.L["The Robomination erupts back into the fight!"] then
--        core:AddPolygon(nId, nId, 20, 0, 7, "white", 20)
        bInMidPhase = false
        mod:RemoveTimerBar("MIDPHASE")
        mod:AddTimerBar("ARMS", "Next arms", 45, nil)
        mod:AddTimerBar("BELCH", "Next noxious belch", 15, nil)
--        mod:AddTimerBar("SKYFALL", "Next sky is falling", 4, nil)
        mod:AddTimerBar("INCINERATION", "Next incineration laser", 18, nil)
    elseif sMessage:find(self.L["The Robomination tries to incinerate %s"]) then
        mod:AddMsg("INCINERATION", "Incineration!", 5, mod:GetSetting("IncinerationWarningSound") and "Inferno")
        mod:AddTimerBar("INCINERATION", "Next incineration laser", 40, nil)
    end
end

function mod:OnUnitCreated(nId, unit, sName)
    local player = GameLib.GetPlayerUnit()
    
    if sName == self.L["Robomination"] then
        core:AddUnit(unit)
        core:WatchUnit(unit)

        core:AddPolygon(nId, nId, 20, 0, 7, "white", 20)
        roboId = nId


        mUnit = GameLib.GetPlayerUnit()
        classId = mUnit:GetClassId()
        if (mUnit:GetAssaultPower() > mUnit:GetSupportPower()) then
            btank = 0
        elseif (classId == GameLib.CodeEnumClass.Esper or classId == GameLib.CodeEnumClass.Medic or classId == GameLib.CodeEnumClass.Spellslinger) then
            ptype = 1
        else
            ptype = 2
        end

    elseif sName == self.L["Cannon Arm"] then
        cbnumber = 0
        core:AddUnit(unit)
        core:WatchUnit(unit)
        if ptype < 2 then
            core:AddLineBetweenUnits(nId, player:GetId(), nId, 5, "blue")
        end
        if not bInMidPhase then
            mod:AddTimerBar("ARMS", "Next arms", 45, nil)
        end
    elseif sName == self.L["Flailing Arm"] then
        core:AddUnit(unit)
        core:WatchUnit(unit)
        if ptype == 2 then
            core:AddLineBetweenUnits(nId, player:GetId(), nId, 5, "blue")
        end
    elseif sName == self.L["Scanning Eye"] then
        cbnumber = 0
        core:AddUnit(unit)
        core:WatchUnit(unit)
        if mode:GetSetting("LinesScanningEye") then
            core:AddLineBetweenUnits(nId, player:GetId(), nId, 5, "green")
        end
    end
 
end

function mod:OnUnitDestroyed(nId, unit, sName)
    if sName == self.L["Scanning Eye"] then
        core:RemoveLineBetweenUnits(nId)
        mod:AddTimerBar("ARMS", "Next arms", 6, nil)
    elseif sName == self.L["Cannon Arm"] then
        core:RemoveLineBetweenUnits(nId)
    elseif sName == self.L["Flailing Arm"] then
        core:RemoveLineBetweenUnits(nId)
    elseif sName == self.L["Robomination"] then
	core:RemovePolygon(nId)
    end
end
