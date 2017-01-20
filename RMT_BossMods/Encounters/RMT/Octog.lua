require "Window"
require "Apollo"

local Mod = {}
local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Encounter = "TFPOctog"

local DEBUFF__NOXIOUS_INK = 85533 -- DoT for standing in circles
local DEBUFF__SQUINGLING_SMASHER = 86804 -- +5% DPS/heals, -10% incoming heals; per stack
local DEBUFF__CHAOS_TETHER = 85583 -- kills you if you leave orb area
local DEBUFF__CHAOS_ORB = 85582 -- 10% more damage taken per stack
local DEBUFF__REND = 85443 -- main tank stacking debuff, 2.5% less mitigation per stack
local DEBUFF__AFFLICTED = 85411 -- main tank stacking debuff, 2.5% less mitigation per stack
local DEBUFF__SPACE_FIRE = 87159 -- 12k dot from flame, lasts 45 seconds
local BUFF__CHAOS_ORB = 86876 -- Countdown to something, probably the orb wipe
local BUFF__CHAOS_AMPLIFIER = 86876 -- Bosun Buff that increases orb count?
local BUFF__FLAMETHROWER = 87059 -- Flamethrower countdown buff -- DOESN'T EXIST ANYMORE, used to be 15s countdown to flame cast
local BUFF__ASTRAL_SHIELD = 85643 -- Shard phase shield, 20 stacks
local BUFF__ASTRAL_SHARD = 85611 --Buff shards get right before they die, probably meaningless

local ROCKET_HEIGHT = 20
local ROOM_FLOOR_Y = 378

local circles = { c = { } }

local squirglings = { }

local tBossCheckTimer

local Locales = {
    ["enUS"] = {
        ["unit.boss"] = "Star-Eater the Voracious",
        ["unit.squirgling"] = "Squirgling",
        ["unit.orb"] = "Chaos Orb",
        ["unit.pool"] = "Noxious Ink Pool",
        ["unit.shard"] = "Astral Shard",
        ["cast.hookshot"] = "Hookshot",
        ["cast.summon"] = "Summon Squirglings",
        ["cast.flamethrower"] = "Flamethrower",
        ["cast.supernova"] = "Supernova",
        ["label.late_squirgling"] = "Squirgling about to burst",
    },
    ["deDE"] = {
    },
    ["frFR"] = {
    },
}

function Mod:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.instance = "Redmoon Terror"
    self.displayName = "TFP Octog"
    self.tTrigger = {
        sType = "ANY",
        tNames = {"unit.boss"},
        tZones = {
            [1] = {
                continentId = 104,
                parentZoneId = 0,
                mapId = 548,
            },
        },
    }
    self.run = false
    self.runtime = {}
    self.config = {
        enable = true,
        units = {
            boss = {
                enable = true,
                label = "unit.boss",
                position = 1,
            },
        },
        icons = {
            late_squirgling = {
                enable = true,
                position = 1,
                sprite = "LUIBM_crosshair",
                size = 80,
                color = "ffff0000",
                label = "label.late_squirgling",
            },
        },
        texts = {
            compass = {
                enable = true,
                font = "Subtitle",
                color = "ffffffff",
                label = "texts.compass",
            },
        },
        lines = {
            circle_telegraph = {
                enable = true,
                thickness = 7,
                color = "ffff0000",
                label = "label.circle_telegraph",
            },
            squirgling = {
                enable = true,
                priority = 1,
                thickness = 8,
                color = "afff0000",
                label = "unit.squirgling",
            },        },
        timers = {
            supernova = {
                enable = true,
                position = 1,
                color = "ade91dfb",
                label = "cast.supernova",
            },
            hookshot = {
                enable = true,
                position = 2,
                color = "afb0ff2f",
                label = "cast.hookshot",
            },
            flamethrower = {
                enable = true,
                position = 3,
                color = "afff0000",
                label = "cast.flamethrower",
            },
            orbs = {
                enable = false,
                position = 4,
                color = "afff00ff",
                label = "unit.orb",
            },
        }
    }
    return o
end

function Mod:Init(parent)
    Apollo.LinkAddon(parent, self)

    self.core = parent
    self.L = parent:GetLocale(Encounter,Locales)
end

function Mod:OnBossCheckTimer()
--    ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug, "timer")
    for nId, attr in pairs(circles.c) do
--      ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug, "Upd: " .. nId .. ": " .. circles.c[nId].s)
      if circles.c[nId].s ~= nil and circles.c[nId].s < 54 then 
        local ns = circles.c[nId].s + 1
        circles.c[nId].s = ns
        if ns % 7 == 0 then
            local newsize = 5 + ((ns / 7) * 2)
            LUI_BossMods:RemovePolygon(nId)
--            ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug, "Upd2: " .. nId .. ": " .. newsize)
            LUI_BossMods:DrawPolygon(nId, circles.c[nId].u, self.config.lines.circle_telegraph, math.floor(newsize), 0, 20)
--            ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug, "Upd3: " .. nId .. ": " .. newsize)
        end
      end
    end

    for nId, attr in pairs(squirglings) do
      if squirglings[nId].s ~= nil and squirglings[nId].s < 20 then 
          local ns = squirglings[nId].s + 1
          squirglings[nId].s = ns
      elseif squirglings[nId].s ~= nil then
          squirglings[nId].s = nil
          LUI_BossMods:DrawIcon("Icon_Squirgling"..tostring(nId), squirglings[nId].unit, self.config.icons.late_squirgling, true, nil, 10)
          LUI_BossMods:DrawLineBetween(nId, squirglings[nId].unit, nil, self.config.lines.squirgling)
      end
    end
end

function Mod:OnUnitCreated(nId, tUnit, sName, bInCombat)
    if not self.run == true then
        return
    end

    if sName == self.L["unit.boss"] and bInCombat then
        circles = { c = {} }
        squirglings = { }
        self.core:AddUnit(nId,sName,tUnit,self.config.units.boss)
        tBossCheckTimer = ApolloTimer.Create(1, true, "OnBossCheckTimer", Mod)

--  North: -5,840,378
--  East:  -63,903,378
--  South: -5,962,378
--  West:  53,903,378

        self.core:DrawText("mark.north", Vector3.New(-5,378,840), self.config.texts.compass, "N")
        self.core:DrawText("mark.east", Vector3.New(-63,378,903), self.config.texts.compass, "W")
        self.core:DrawText("mark.south", Vector3.New(-5,378,962), self.config.texts.compass, "S")
        self.core:DrawText("mark.west", Vector3.New(53,378,903), self.config.texts.compass, "E")

    elseif sName == self.L["unit.squirgling"] then
        squirglings[nId] = { unit = tUnit, s = 0 }
    elseif sName == self.L["unit.pool"] then
        circles.c[nId] = { u = tUnit, s = -1 }
        LUI_BossMods:DrawPolygon(nId, tUnit, self.config.lines.circle_telegraph, 5, 0, 20)
    end
end

function Mod:OnCastStart(nId, sCastName, tCast, sName)
    local tUnit = GameLib.GetUnitById(nId)

    if sName == self.L["unit.boss"] and bInCombat then
        if self.L["cast.hookshot"] == sCastName then
--            self.core:ShowAlert("HOOKSHOTWARN", self.L["Hookshot!"], 5, mod:GetSetting("HookshotWarningSound") and "Beware")
            self.core:AddTimer("cast.hookshot", "Next Hookshot", 30, self.config.timers.hookshot)
--            if mod:GetSetting("ShowHookshotCircles") then
--                tHookshotRedrawTimer = ApolloTimer.Create(.1, true, "RedrawHookshotCircles", self)
--                tHookshotCircleTimer = ApolloTimer.Create(5, true, "RemoveHookshotCircles", self)
--            end
        elseif self.L["cast.supernova"] == sCastName then
            self.core:AddTimer("cast.supernova", self.L["cast.supernova"], 25, self.config.timers.supernova)
            self.core:RemoveTimer("cast.orbs")
            self.core:RemoveTimer("cast.hookshot")
            self.core:RemoveTimer("cast.flamethrower")
--        elseif self.L["cast.summon"] == sCastName then
--            iSquirgCount = 0
        elseif self.L["cast.flamethrower"] == sCastName then
            self.core:AddTimer("cast.flamethrower", "Next Flamethrower", 45, self.config.timers.flamethrower)
        end
    end
end


function Mod:OnCastEnd(nId, sCastName, tCast, sName)
    if self.L["unit.boss"] == sName then
        if self.L["cast.supernova"] == sCastName then
            self.core:RemoveTimer("cast.supernova")
            
            tShardIds = {}
            if tShardTimer then
                tShardTimer:Stop()
                tShardTimer = nil
            end
            
--            local timeToNextOrbs = iNextOrbs - GameLib.GetGameTime()
--            if timeToNextOrbs < 10 then
--                mod:AddTimer("ORBS", "Next Orbs", 10, mod:GetSetting("OrbCountdown"))
--            else
--                mod:AddTimer("ORBS", "Next Orbs", timeToNextOrbs, mod:GetSetting("OrbCountdown"))
--            end
        elseif self.L["Hookshot"] == sCastName then
--            if tHookshotRedrawTimer then
--                tHookshotRedrawTimer:Stop()
--                tHookshotRedrawTimer = nil
--            end
        end
    end
end

function Mod:OnUnitDestroyed(nId, tUnit, sName)
    if sName == self.L["unit.pool"] then
        self.core:RemovePolygon(nId)
        circles.c[nId] = nil
    elseif sName == self.L["unit.squirgling"] then
--        self.core:RemoveIcon("Icon_Squirgling"..tostring(nId))
        self.core:RemoveIcon("Icon_Squirgling"..tostring(nId))
        self.core:RemoveLineBetween(nId)
        squirglings[nId] = nil
    end
end

function Mod:IsRunning()
    return self.run
end

function Mod:IsEnabled()
    return self.config.enable
end

function Mod:OnEnable()
    self.run = true
end

function Mod:OnDisable()
    self.run = false
    if tBossCheckTimer then
        tBossCheckTimer:Stop()
        tBossCheckTimer = nil
        circles = { c = {} }
        squirglings = { }
--        iSquirgCount = 0
    end
end

local ModInst = Mod:new()
LUI_BossMods.modules[Encounter] = ModInst
