----------------------------------------------------------------------------------------------------
-- Client Lua Script for RaidCore Addon on WildStar Game.
--
-- Copyright (C) 2015 RaidCore
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Description:
--   Fake boss, to test few basic feature in RaidCore.
--
--   This last should be declared only in alpha version or with git database.
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
--@alpha@
local mod = core:NewEncounter("HousingTest", 36, 0, 60)
--@end-alpha@
if not mod then return end

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob("ANY", { "T-12 Raid Holo-Target", "Holographic Chompacabra", "Holographic Shootbot", "Holographic Moodie" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["T-12 Raid Holo-Target"] = "T-12 Raid Holo-Target",
    ["Holographic Chompacabra"] = "Holographic Chompacabra",
    ["Holographic Shootbot"] = "Holographic Shootbot",
    ["Holographic Moodie"] = "Holographic Moodie",
})

mod:RegisterDefaultTimerBarConfigs({
    ["UNIT"] = { sColor = "red", bEmphasize = false },
    ["INFINITE"] = { sColor = "FF008080", bEmphasize = true },
    ["INFINITE2"] = { bEmphasize = true },
    ["LONG"] = { sColor = "FF80FF20" },
})

local GetUnitById = GameLib.GetUnitById
local GetPlayerUnit = GameLib.GetPlayerUnit

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local function InfiniteTimer2()
    mod:AddTimerBar("INFINITE2", "Loop Timer outside", 10, nil, InfiniteTimer2)
end

local nTarget

----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
--    mod:AddTimerBar("INFINITE", "Timer in class", 12, false, mod.InfiniteTimer, mod)
--    mod:AddTimerBar("INFINITE2", "Timer outside", 12, nil, InfiniteTimer2)
    mod:AddTimerBar("LONG", "Long long timer...", 1000)
    nTarget = nil
end

function mod:InfiniteTimer()
    mod:AddTimerBar("INFINITE", "Loop Timer in class", 10, false, mod.InfiniteTimer, mod)
end

function mod:OnUnitCreated(nId, unit, sName)
    if sName == self.L["T-12 Raid Holo-Target"] then
        nTarget = nId
        core:MarkUnit(unit, 1, "A")
    end
    if sName == self.L["Holographic Chompacabra"] or sName == self.L["Holographic Shootbot"] or sName == self.L["Holographic Moodie"] then
        nTarget = nId
        core:MarkUnit(unit, 1, "A")
    end
end

function mod:OnEnteredCombat(nId, tUnit, sName, bInCombat)
    if bInCombat then
        if sName == self.L["T-12 Raid Holo-Target"] then
            nTarget = nId
            core:WatchUnit(tUnit)
            core:AddUnit(tUnit)
            core:MarkUnit(tUnit, 51)
        end
        if sName == self.L["Holographic Chompacabra"] or sName == self.L["Holographic Shootbot"] or sName == self.L["Holographic Moodie"] then
            nTarget = nId
            core:WatchUnit(tUnit)
            core:AddUnit(tUnit)
            core:MarkUnit(tUnit, 51)
        end
    end
end

function mod:OnDebuffAdd(nId, nSpellId, nStack, fTimeRemaining)
    local tId = GetPlayerUnit():GetId()
    if nId == tId then
        Print(GameLib.GetSpell(nSpellId):GetName() .. "=" .. nSpellId)
    end
end

function mod:OnDebuffRemove(nId, nSpellId)
end

function mod:OnBuffAdd(nId, nSpellId, nStack, fTimeRemaining)
    local tId = GetPlayerUnit():GetId()
    if nId == tId then
        Print(GameLib.GetSpell(nSpellId):GetName() .. "=" .. nSpellId)
    end
end

function mod:OnBuffRemove(nId, nSpellId)
end


function mod:OnCastStart(nId, sCastName, nCastEndTime, sName)
--    if sCastName == self.L["Phaser Combo"] then
--        mod:AddTimerBar("UNIT", "End of Combo Phaser", 3)
--    end
end

function mod:OnCastEnd(nId, sCastName, bInterrupted, nCastEndTime, sName)
--    if sCastName == self.L["Phaser Combo"] then
--        mod:AddMsg("LONG", sCastName, 5, "Alert")
--        mod:AddTimerBar("UNIT", "Next Combo Phaser", 15)
--    end
end

