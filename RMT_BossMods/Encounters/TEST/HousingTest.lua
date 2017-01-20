require "Window"
require "Apollo"

local Mod = {}
local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Encounter = "HousingTest"

local tBossCheckTimer

local circles = {}

local Locales = {
    ["enUS"] = {
        ["unit.holo"] = "T-12 Raid Holo-Target", 
        ["unit.chomp"] = "Holographic Chompacabra", 
        ["unit.shoot"] = "Holographic Shootbot", 
        ["unit.moodie"] = "Holographic Moodie",
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
    self.displayName = "Octog"
    self.tTrigger = {
        sType = "ANY",
        tNames = {"unit.holo", "unit.chomp", "unit.shoot", "unit.moodie"},
        tZones = {
            [1] = {
                continentId = 36,
                parentZoneId = 0,
                mapId = 60,
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
                label = "unit.holo",
                position = 1,
            },
        },
        lines = {
            circle_telegraph = {
                enable = true,
                thickness = 7,
                color = "ffff0000",
                label = "label.circle_telegraph",
            },
        },
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
    for nId, attr in pairs(circles) do
--      ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug, "Upd: " .. nId .. ": " .. s)
      if circles[nId].s ~= nil and circles[nId].s < 40 then 
        local ns = circles[nId].s + 1
        circles[nId].s = ns
        if ns % 7 == 0 then
            local newsize = 5 + ((ns / 7) * 2)
--            self.core:RemovePolygon(nId)
            LUI_BossMods:RemovePolygon(nId)
            ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug, "Upd2: " .. nId .. ": " .. newsize)
--            self.core:RemovePolygon(nId)
            LUI_BossMods:DrawPolygon(nId, circles[nId].tUnit, self.config.lines.circle_telegraph, math.floor(newsize), 0, 20)
            ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug, "Upd3: " .. nId .. ": " .. newsize)
        end
      end
    end
end

function Mod:OnUnitCreated(nId, tUnit, sName, bInCombat)
    if not self.run == true then
        return
    end

    if sName == self.L["unit.holo"] and bInCombat then
        self.core:AddUnit(nId,sName,tUnit,self.config.units.holo)
        tBossCheckTimer = ApolloTimer.Create(1, true, "OnBossCheckTimer", Mod)
        circles[nId] = { tUnit = tUnit, s = 0 }
        ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug, "Added: " ..  nId .. ": " .. 0)
    end
end

function Mod:OnUnitDestroyed(nId, tUnit, sName)
    if sName == self.L["unit.pool"] then
        self.core:RemovePolygon(nId)
        circles[nId] = nil
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
        circles = {} 
    end

end

local ModInst = Mod:new()
LUI_BossMods.modules[Encounter] = ModInst

