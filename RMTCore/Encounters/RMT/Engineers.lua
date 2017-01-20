----------------------------------------------------------------------------------------------------
-- Engineers encounter script
--
-- Copyright (C) 2016 Joshua Shaffer
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Engineers", 104, 548, 552)
local Log = Apollo.GetPackage("Log-1.0").tPackage
if not mod then return end

mod:RegisterTrigMob("ANY", { "Head Engineer Orvulgh", "Chief Engineer Wilbargh" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["Fusion Core"] = "Fusion Core",
	["Cooling Turbine"] = "Cooling Turbine",
    ["Spark Plug"] = "Spark Plug",
    ["Lubricant Nozzle"] = "Lubricant Nozzle",
    ["Head Engineer Orvulgh"] = "Head Engineer Orvulgh",
    ["Chief Engineer Wilbargh"] = "Chief Engineer Wilbargh",
    ["Air Current"] = "Air Current", --Tornado units?
    -- Datachron messages.
    -- Cast.
    -- Bar and messages.
    ["%s pillar at N%!"] = "%s pillar at 85%!"
})

mod:RegisterDefaultSetting("PillarWarningSound")

mod:RegisterDefaultTimerBarConfigs({
    ["DISCHARGE"] = { sColor = "xkcdSunYellow" },
    ["LIQUIDATE"] = { sColor = "xkcdCyan" },
    ["INFINITE"] = { sColor = "xkcdRed" },
    ["ORBTARGETSELF"] = { sColor = "FFFF0070", bEmphasize = true },
    ["SHOCKSELF"] = { sColor = "FFFF0070", bEmphasize = true },
    ["ORBS"] = { sColor = "FFFF7020" },
})

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local DEBUFF__ELECTROSHOCK_VULNERABILITY = 83798 --2nd shock -> death
local DEBUFF__OIL_SLICK = 84072 --Sliding platform debuff
local DEBUFF__ATOMIC_ATTRACTION = 84053 
local thisTimer = 0
local orbs = 0
local gunId = 0
local pillarAlert = 0

----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local bWave1Spawned
local hasVuln = 0

local ptype = 0
local shocks = 0

local tPillars
local tVents

------------
-- Raw event handlers
---------
Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreatedRaw", mod)


----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
    --mod:AddTimerBar("ORBSPAWN", "Orb Spawn", 45, nil) 
    --30s to orb after airlock phase

    hasVuln = 0
    orbs = 0
    --These don't fire combat start (or combat logs in general?) so we have to do this the hard way with UnitCreated
    if tPillars then
        local nFusionCoreId = tPillars[self.L["Fusion Core"]].id
        local tFusionCoreUnit = GameLib.GetUnitById(nFusionCoreId)
        if tFusionCoreUnit then
            core:AddUnit(tFusionCoreUnit)
            core:WatchUnit(tFusionCoreUnit)
            core:CreateWorldMarker(nFusionCoreId .. "HEALTH", "29", Vector3.New(311, -200, -956))
        else
            Log:Add("ERROR", "Combat started but no Lubricant Fusion Core")
            mod:AddMsg("ERROR", "Missing pillars!", 10, "Alarm")
        end
        
        
        local nCollingTurbineId = tPillars[self.L["Cooling Turbine"]].id
        local tCoolingTurbineUnit = GameLib.GetUnitById(nCollingTurbineId)
        if tCoolingTurbineUnit then
            core:AddUnit(tCoolingTurbineUnit)
            core:WatchUnit(tCoolingTurbineUnit)
            core:CreateWorldMarker(nCollingTurbineId .. "HEALTH", "29", Vector3.New(311, -200, -831))
        else
            Log:Add("ERROR", "Combat started but no Cooling Turbine")
            mod:AddMsg("ERROR", "Missing pillars!", 10, "Alarm")
        end
        
        local nSparkPlugId = tPillars[self.L["Spark Plug"]].id
        local tSparkPlugUnit = GameLib.GetUnitById(nSparkPlugId)
        if tSparkPlugUnit then
            core:AddUnit(tSparkPlugUnit)
            core:WatchUnit(tSparkPlugUnit)
            core:CreateWorldMarker(nSparkPlugId .. "HEALTH", "29", Vector3.New(437, -200, -831))
        else
            Log:Add("ERROR", "Combat started but no Spark Plug")
            mod:AddMsg("ERROR", "Missing pillars!", 10, "Alarm")
        end
        
        local nLubricantNozzleId = tPillars[self.L["Lubricant Nozzle"]].id
        local tLubricantNozzleUnit = GameLib.GetUnitById(nLubricantNozzleId)
        if tLubricantNozzleUnit then
            core:AddUnit(tLubricantNozzleUnit)
            core:WatchUnit(tLubricantNozzleUnit)
            core:CreateWorldMarker(nLubricantNozzleId .. "HEALTH", "29", Vector3.New(437, -200, -956))
        else
            Log:Add("ERROR", "Combat started but no Lubricant Nozzle")
            mod:AddMsg("ERROR", "Missing pillars!", 10, "Alarm")
        end
    end
    if tVents then
        for vId, e in pairs(tVents) do
            local tFireVent = GameLib.GetUnitById(tVents[vId].id)
            core:WatchUnit(tFireVent)
        end
    end
    thisTimer = 15
    mod:AddTimerBar("INFINITE", thisTimer .. " seconds", 15, false, mod.InfiniteTimer, mod)
end

function mod:OnUnitCreatedRaw(tUnit)
    tPillars = tPillars or {}
    tVents = tVents or {}
    if tUnit then        
        local sName = tUnit:GetName()
        if sName == self.L["Fusion Core"] or
            sName == self.L["Cooling Turbine"] or
            sName == self.L["Spark Plug"] or
            sName == self.L["Lubricant Nozzle"] then
                tPillars[sName] = {id = tUnit:GetId()}
        elseif sName == "Fire Vent" then
           local tId = tUnit:GetId()
           tVents[tId] = { id = tId }
        end
    end
end

function mod:OnHealthChanged(nId, nPercent, sName)
    if sName == self.L["Fusion Core"] or
        sName == self.L["Cooling Turbine"] or
        sName == self.L["Spark Plug"] or
        sName == self.L["Lubricant Nozzle"] then
            local tUnit = GameLib.GetUnitById(nId)
--            core:DropMark(nId)
--            core:MarkUnit(tUnit, nil, nPercent)
            core:UpdateWorldMarker(nId .. "HEALTH", nPercent)
            core:RemovePolygon(nId)
            if nPercent >= 85 and not tPillars[sName].warning then
                local player = GameLib.GetPlayerUnit()
                tPillars[sName].warning = true
                mod:AddMsg("PILLARWARN", self.L["%s pillar at N%!"]:format(sName), 5, mod:GetSetting("PillarWarningSound") and "Destruction")
                core:AddLineBetweenUnits(nId, player:GetId(), nId, 5, "red")
            elseif nPercent <= 80 and nPercent > 30 then
                tPillars[sName].warning = false
                core:RemoveLineBetweenUnits(nId)
                core:AddPolygon(nId, nId, 12, 0, 7, "xkcdGreen", 20)
            elseif nPercent <= 30 and nPercent > 20 then
                core:AddPolygon(nId, nId, 12, 0, 7, "xkcdSunYellow", 20)
                if mod:GetDistanceBetweenUnits(tPlayerUnit, tUnit) < 40 then
                    pillarAlert = 0
                end
            elseif nPercent <= 20 then
                core:AddPolygon(nId, nId, 12, 0, 7, "xkcdRed", 20)
                if mod:GetDistanceBetweenUnits(tPlayerUnit, tUnit) < 40 then
                    mod:AddMsg("PILLARHEALTH", "CORE AT " + nPercent + "%", 2, pillarAlert == 0 and "Inferno")
                    pillarAlert = 1
                end
            end

    end
end

function mod:InfiniteTimer()
    thisTimer = thisTimer + 15
    mod:AddTimerBar("INFINITE", thisTimer .. " seconds", 15, false, mod.InfiniteTimer, mod)
end


function mod:addShockLines()
            local nId = gunId
            local tUnit = GameLib.GetUnitById(nId)
            core:RemoveSimpleLine("SHOCKLINE")
            core:AddSimpleLine("GUNLINE", nId, nil, 45, 0, 12, "red")
            local t = 0
            for i = 1, GroupLib.GetMemberCount() do
                local tMember = GroupLib.GetGroupMember(i)
                local tPlayer = GroupLib.GetUnitForGroupMember(i)
                if tPlayer and tPlayer:GetId() then
                    local nPlayerId = tPlayer:GetId()
                    local tPlayerUnit = GameLib.GetUnitById(nPlayerId)
                    if tMember and tPlayer and tPlayer:GetHealth() ~= 0 then
-- and mod:GetDistanceBetweenUnits(tPlayerUnit, tUnit) < 30 then
                        t = t + 1
                        local line = core:AddLineBetweenUnits("GUNLINE" .. t, nPlayerId, nId, 4, "xkcdOrange")
                        line:SetMaxLengthVisible(50)
                    end
                end
            end
end

function mod:OnCastStart(nId, sCastName, nCastEndTime, sName)
--    Print(sName .. " casting: " .. sCastName .. " with duration: " .. nCastEndTime)
    if self.L["Head Engineer Orvulgh"] == sName then
        if "Electroshock" == sCastName then
--            mod:AddMsg("DISCHARGE", "Electrostatic Discharge", 3, "Beware")
            mod:AddTimerBar("DISCHARGE", "Next Electrostatic Discharge", 17, false, mod.addShockLines, mod) 
            if hasVuln == 1 then
                mod:AddTimerBar("SHOCKSELF", "Next Vortex Dance", 16, nil) 
            end
            local tUnit = GameLib.GetUnitById(nId)
            core:RemoveSimpleLine("SHOCKLINE")
            core:AddSimpleLine("GUNLINE", nId, nil, 45, 0, 12, "red")
            local t = 0
            for i = 1, GroupLib.GetMemberCount() do
                local tMember = GroupLib.GetGroupMember(i)
                local tPlayer = GroupLib.GetUnitForGroupMember(i)
                if tPlayer and tPlayer:GetId() then
                    local nPlayerId = tPlayer:GetId()
                    local tPlayerUnit = GameLib.GetUnitById(nPlayerId)
                    if tMember and tPlayer and tPlayer:GetHealth() ~= 0 then
-- and mod:GetDistanceBetweenUnits(tPlayerUnit, tUnit) < 30 then
                        t = t + 1
                        local line = core:AddLineBetweenUnits("GUNLINE" .. t, nPlayerId, nId, 4, "xkcdOrange")
                        line:SetMaxLengthVisible(50)
                    end
                end
            end        elseif "Rocket Jump" == sCastName then
            mod:AddMsg("ROCKETJUMP", "Rocket Jump!", 3, "Beware")
        end
    elseif self.L["Chief Engineer Wilbargh"] == sName then
        if "Liquidate" == sCastName then
            mod:AddTimerBar("LIQUIDATE", "Next Liquidate", 24, nil) 
        end
    end
end

function mod:OnCastEnd(nId, sCastName, bInterrupted, nCastEndTime, sName)
    if self.L["Head Engineer Orvulgh"] == sName then
        if "Electroshock" == sCastName then
            core:RemoveSimpleLine("GUNLINE")
            core:AddSimpleLine("SHOCKLINE", nId, nil, 20, 0, 3, "xkcdGreen")
            for i = 1, 20 do
                core:RemoveLineBetweenUnits("GUNLINE" .. i)
            end
        end
   end
end

function mod:OnUnitCreated(nId, tUnit, sName)
    local player = GameLib.GetPlayerUnit()
    
    if sName == self.L["Head Engineer Orvulgh"] then
        shocks = 0
        local mUnit = GameLib.GetPlayerUnit()
        classId = mUnit:GetClassId()
        if (mUnit:GetAssaultPower() > mUnit:GetSupportPower()) then
            ptype = 0
        elseif (classId == GameLib.CodeEnumClass.Esper or classId == GameLib.CodeEnumClass.Medic or     classId == GameLib.CodeEnumClass.Spellslinger) then
            ptype = 1
        else
            ptype = 2
        end

        gunId = nId
        core:AddUnit(tUnit)
        core:WatchUnit(tUnit)
        core:AddSimpleLine("GUNLINE0", nId, nil, 20, 0, 3, "xkcdGreen")
--        core:AddSimpleLine("GunAim", nId, nil, 20, 0, nil, "white")
--        core:AddPixie("GunAim", 2, tUnit, nil, "xkcdBloodAmber", 2, 20)
--        core:DrawLine(nId, tUnit, "xkcdBloodAmber", 2, 17)
    elseif sName == self.L["Chief Engineer Wilbargh"] then
        core:AddUnit(tUnit)
        core:WatchUnit(tUnit)
--        core:AddSimpleLine("CleaveA", nId, -1.5, 15, -50, 10, "white") --, 0, Vector3.New(2,0,-1.5)
--        core:AddSimpleLine("CleaveB", nId, -1.5, 15, 50, 10, "white")

    elseif sName == self.L["Air Current"] then --Track these moving?
        core:AddPixie(nId, 2, tUnit, nil, "Yellow", 5, 15, 0)
--    elseif sName == "Fire Vent" then
--        core:AddUnit(tUnit)
--        core:WatchUnit(tUnit)
     --These don't fire enter combat or created, but need to figure out how to track their HP
    -- elseif sName == self.L["Fusion Core"] then
        -- core:AddUnit(tUnit)
        -- core:WatchUnit(tUnit)
    -- elseif sName == self.L["Cooling Turbine"] then
        -- core:AddUnit(tUnit)
        -- core:WatchUnit(tUnit)
    -- elseif sName == self.L["Spark Plug"] then
        -- core:AddUnit(tUnit)
        -- core:WatchUnit(tUnit)
    -- elseif sName == self.L["Lubricant Nozzle"] then
        -- core:AddUnit(tUnit)
        -- core:WatchUnit(tUnit)
    end
end



function mod:OnUnitDestroyed(nId, tUnit, sName)
    --if sName == self.L["Air Current"] then
    --    core:RemovePixie("TORNADO" .. nId)
    --end
end


function mod:OnDebuffAdd(nId, nSpellId, nStack, fTimeRemaining)
--    Print(GameLib.GetSpell(nSpellId):GetName() .. "=" .. nSpellId)
    local tUnit = GameLib.GetUnitById(nId)
    local player = GameLib.GetPlayerUnit()

    if DEBUFF__ATOMIC_ATTRACTION == nSpellId then
        orbs = orbs + 1
        local orbString = "Orb on " .. tUnit:GetName()
        mod:AddTimerBar("ORBS", "Next Orb", 24, nil)
       
        if tUnit == player then
            mod:AddTimerBar("ORBTARGETSELF", orbString, 14, nil)
            mod:AddMsg("ORBTARGET", "ORB ON YOU!", 5, "RunAway")
        end
    elseif DEBUFF__ELECTROSHOCK_VULNERABILITY == nSpellId then
          core:MarkUnit(tUnit, nil, "SHOCK")
          if ptype == 1 and tUnit:GetHealth() ~= 0 then
              local nPlayerId = player:GetId()
              local line = core:AddLineBetweenUnits("DEBUFFHEAL" .. nId, nPlayerId, nId, 6, "blue")
              line:SetMaxLengthVisible(90)
          end

--        if tUnit == player then
--            hasVuln = 1
--            mod:AddTimerBar("SHOCKSELF", "Next Vortex Dance", 16, nil) 
--        end
    end
end

function mod:OnDebuffRemove(nId, nSpellId)
    if DEBUFF__ELECTROSHOCK_VULNERABILITY == nSpellId then
        hasVuln = 0
        core:DropMark(nId)
        mod:RemoveTimerBar("SHOCKSELF")
        if ptype == 1 then
            core:RemoveLineBetweenUnits("DEBUFFHEAL" .. nId)
        end
    end
end
