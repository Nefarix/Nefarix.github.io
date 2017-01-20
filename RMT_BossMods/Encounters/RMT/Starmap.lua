require "Window"
require "Apollo"

local Mod = {}
local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Encounter = "TFPStarmap"

local Locales = {
	["enUS"] = {
	-- Units
	["unit.boss"] = "Alpha Cassus",
	["unit.aldinari"] = "Aldinari",
	["unit.cassus"] = "Cassus",
	["unit.vulpes_nix"] = "Vulpes Nix",
	["unit.rogue_asteroid"] = "Rogue Asteroid",
	["unit.aldinari_debris"] = "Close Debris Asteroid",
	["unit.cassus_debris"] = "Middle Debris Asteroid",
	["unit.vulpes_debris"] = "Far Debris Asteroid",
	["unit.debris_field"] = "Debris Field",
	["unit.world_ender"] = "World Ender",
	["unit.pulsar"] = "Pulsar",
	["unit.cosmic_debris"] = "Cosmic Debris",
	["unit.black_hole"] = "Black Hole",
	["unit.asteroid_lane_a"] = "Asteroid Lane A",
	["unit.asteroid_lane_b"] = "Asteroid Lane B",
	["unit.asteroid_lane_c"] = "Asteroid Lane C",
	["unit.asteroid_lane_d"] = "Asteroid Lane D",
	-- Casts
	["cast.solar_flare"] = "Solar Flare",
	["cast.midphase"] = "Catastrophic Solar Event",
	-- Timer
	["timer.danger_asteroids"] = "Super duper important Asteroids!",
	-- Alert
	["alert.world_ender"] = "World Ender spawned!",
	["alert.pulsar"] = "Pulsar spawned!",
	["alert.solar_winds"] = "Reset your stacks",
	["alert.midphase"] = "Midphase soon, reset stacks",
	-- Labels
	["label.world_ender"] = "World ender spawn points",
	["label.aldinari_sun"] = "Aldinari to Sun",
	["label.cassus_sun"] = "Cassus to Sun",
	["label.vulpes_nix_sun"] = "Vulpes Nix to Sun",
	["label.planet_orbit_aldinari"] = "Planet orbit Aldinari",
	["label.planet_orbit_cassus"] = "Planet orbit Cassus",
	["label.planet_orbit_vulpes_nix"] = "Planet orbit Vulpes Nix",
	["label.world_ender_player"] = "World Ender to player",
	["label.world_ender_direction"] = "World Ender direction",
	["label.rogue_asteroid_player"] = "Rogue Asteroid to player",
	["label.rogue_asteroid_direction"] = "Rogue Asteroid direction",
	["label.cardinal"] = "Cardinal directions",
	["label.solar_winds"] = "Solar Winds warning at 7 stacks",
	["label.sun_stack_cast"] = "Every other Solar Flare (Tanks/Collectors)",
	["label.irradiated_armor"] = "Sound when someone get Irradiated Armor stack (Tanks/Collectors)",
	["label.midphase"] = "Midphase warning",
	["label.solar_winds_timer"] = "Solar Wind debuff timer",
	["label.world_ender1"] = "Ender 1",
	["label.world_ender2"] = "Ender 2",
	["label.world_ender3"] = "Ender 3",
	["label.world_ender4"] = "Ender 4",
	["label.world_ender5"] = "Ender 5",
	["label.world_ender6"] = "Ender 6",
	["label.asteroids_important"] = "Important Fast Asteroids",
	["label.asteroids"] = "Asteroids",
	["label.asteroid_assignment_a"] = "Asteroid Assignment A",
	["label.asteroid_assignment_b"] = "Asteroid Assignment B",
	["label.asteroid_assignment_c"] = "Asteroid Assignment C",
	["label.asteroid_assignment_d"] = "Asteroid Assignment D",
	["label.cassus_debris_assignment"] = "Middle Debris Field Assignment",
	["label.vulpes_debris_assignment"] = "Far Debris Field Assignment",
	["label.aldinari_debris_assignment"] = "Close Debris Field Assignment",
	["label.asteroids1"] = "Asteroid Pattern A",
	["label.asteroids2"] = "Asteroid Pattern B",
	["label.asteroids0"] = "Asteroid Pattern C",
	["label.cassus_debris"] = "Middle Debris Field Asteroid",
	["label.vulpes_debris"] = "Far Debris Field Asteroid",
	["label.aldinari_debris"] = "Close Debris Field Asteroid",
	["label.asteroid_lane_d"] = "Asteroid Lane D",
	
},
	["deDE"] = {},
	["frFR"] = {},
}

function Mod:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.instance = "Redmoon Terror"
	self.displayName = "TFP Starmap"
	self.tTrigger = {
		sType = "ANY",
		tNames = {"unit.boss"},
		tZones = {
			[1] = {
				continentId = 104,
				parentZoneId = 548,
				mapId = 556,
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
				color = "ffff8900",
				position = 1,
			},
			aldinari = {
				enable = true,
				label = "unit.aldinari",
				color = "ff800080",
				position = 2,
			},
			cassus = {
				enable = true,
				label = "unit.cassus",
				color = "ff00bfff",
				position = 3,
			},
			vulpes_nix = {
				enable = true,
				label = "unit.vulpes_nix",
				color = "ffff8c00",
				position = 4,
			},
			world_ender = {
				enable = true,
				label = "unit.world_ender",
				color = "ffff0000",
				position = 5,
			},
			rogue_asteroid = {
				enable = false,
				label = "unit.rogue_asteroid",
				color = "ffff1493",
				position = 6,
			},
			pulsar = {
				enable = true,
				label = "unit.pulsar",
				position = 7,
			},
			black_hole = {
				enable = true,
				label = "unit.black_hole",
				position = 8,
			},
		},
		timers = {
			world_ender = {
				enable = true,
				position = 1,
				color = "ffff0000",
				label = "unit.world_ender",
			},
			rogue_asteroid = {
				enable = true,
				position = 2,
				color = "ffff1493",
				label = "unit.rogue_asteroid",
			},
			aldinari_debris = {
				enable = true,
				position = 3,
				color = "ff800080",
				label = "unit.aldinari_debris",
			},
			cassus_debris = {
				enable = true,
				position = 4,
				color = "ff00bfff",
				label = "unit.cassus_debris",
			},
			vulpes_debris = {
				enable = true,
				position = 5,
				color = "ffff8c00",
				label = "unit.vulpes_debris",
			},
		},
		alerts = {
			world_ender = {
				enable = true,
				position = 1,
				color = "ffff0000",
				label = "unit.world_ender",
			},
			pulsar = {
				enable = true,
				position = 2,
				color = "ffff0000",
				label = "unit.pulsar",
			},
			solar_winds = {
				enable = true,
				position = 3,
				color = "ffff0000",
				label = "label.solar_winds",
			},
			midphase = {
				enable = true,
				position = 4,
				color = "ffff0000",
				label = "label.midphase",
			},
		},
		sounds = {
			world_ender = {
				enable = true,
				position = 1,
				file = "beware",
				label = "unit.world_ender",
			},
			pulsar = {
				enable = true,
				position = 2,
				file = "alert",
				label = "unit.pulsar",
			},
			solar_winds = {
				enable = true,
				position = 3,
				file = "run-away",
				label = "label.solar_winds",
			},
			irradiated_armor = {
				enable = false,
				position = 4,
				file = "info",
				label = "label.irradiated_armor",
			},
			midphase = {
				enable = true,
				position = 5,
				file = "long",
				label = "label.midphase",
			},
		},
		lines = {
			aldinari_sun = {
				enable = false,
				thickness = 6,
				color = "ff800080",
				label = "label.aldinari_sun",
				position = 1,
			},
			cassus_sun = {
				enable = false,
				thickness = 6,
				color = "ff00bfff",
				label = "label.cassus_sun",
				position = 2,
			},
			vulpes_nix_sun = {
				enable = false,
				thickness = 6,
				color = "ffff8c00",
				label = "label.vulpes_nix_sun",
				position = 3,
			},
			planet_orbit_aldinari = {
				enable = false,
				thickness = 4,
				color = "ff800080",
				label = "label.planet_orbit_aldinari",
				position = 4,
			},
			planet_orbit_cassus = {
				enable = false,
				thickness = 4,
				color = "ff00bfff",
				label = "label.planet_orbit_cassus",
				position = 5,
			},
			planet_orbit_vulpes_nix = {
				enable = false,
				thickness = 4,
				color = "ffff8c00",
				label = "label.planet_orbit_vulpes_nix",
				position = 6,
			},
			world_ender_player = {
				enable = true,
				thickness = 6,
				color = "ffff0000",
				label = "label.world_ender_player",
				position = 7,
			},
			world_ender_direction = {
				enable = true,
				thickness = 4,
				color = "ffffffff",
				label = "label.world_ender_direction",
				position = 8,
			},
			rogue_asteroid_player = {
				enable = false,
				thickness = 6,
				color = "ffff1493",
				label = "label.rogue_asteroid_player",
				position = 9,
			},
			rogue_asteroid_direction = {
				enable = false,
				thickness = 4,
				color = "ffffffff",
				label = "label.rogue_asteroid_direction",
				position = 10,
			},
			sun_stack_cast = {
				enable = false,
				thickness = 8,
				color = "ffff0000",
				label = "label.sun_stack_cast",
				position = 11,
			},
			cosmic_debris = {
				enable = false,
				thickness = 5,
				color = "ffff8c00",
				label = "unit.cosmic_debris",
				position = 12,
			},
			debris_field = {
				enable = false,
				thickness = 5,
				color = "ffff0000",
				label = "unit.debris_field",
				position = 13,
			},
			asteroid_lane_a = {
				enable = true,
				thickness = 4,
				color = "ffff0000",
				label = "label.asteroid_lane_a",
				position = 14,
			},
			asteroid_lane_b = {
				enable = true,
				thickness = 4,
				color = "ffff0000",
				label = "label.asteroid_lane_b",
				position = 15,
			},
			asteroid_lane_c = {
				enable = true,
				thickness = 4,
				color = "ffff0000",
				label = "label.asteroid_lane_c",
				position = 16,
			},
			asteroid_lane_d = {
				enable = true,
				thickness = 4,
				color = "ffff0000",
				label = "label.asteroid_lane_d",
				position = 17,
			},
		},
		icons = {
			debris_field = {
				enable = true,
				sprite = "LUIBM_monster",
				size = 80,
				color = "ffff0000",
				label = "unit.debris_field",
			},
		},
		texts = {
			world_ender = {
				enable = true,
				color = "ffff4500",
				timer = false,
				label = "label.world_ender",				
				position = 1,
			},
			cardinal = {
				enable = true,
				color = "ffff4500",
				timer = false,
				label = "label.cardinal",
				position = 2,
			},
			asteroid_numbers = {
				enable = true,
				color = "ffff1493",
				timer = false,
				label = "unit.rogue_asteroid",
				position = 3,
			},
			solar_winds = {
				enable = true,
				color = "ffffffff",
				timer = true,
				label = "label.solar_winds_timer",
				position = 4,
			},
			--this is where you add text line customization
			asteroid_assignment_a = {
				enable = true,
				color = "ffffffff",
				timer = false,
				label = "label.asteroid_assignment_a",
				position = 5,
			},
			asteroid_assignment_b = {
				enable = true,
				color = "ffffffff",
				timer = false,
				label = "label.asteroid_assignment_b",
				position = 6,
			},
			asteroid_assignment_c = {
				enable = true,
				color = "ffffffff",
				timer = false,
				label = "label.asteroid_assignment_c",
				position = 7,
			},
			asteroid_assignment_d = {
				enable = true,
				color = "ffffffff",
				timer = false,
				label = "label.asteroid_assignment_d",
				position = 8,
			},
			cassus_debris_assignment = {
				enable = true,
				color = "ffffffff",
				timer = false,
				label = "label.cassus_debris_assignment",
				position = 9,
			},
			vulpes_debris_assignment = {
				enable = true,
				color = "ffffffff",
				timer = false,
				label = "label.vulpes_debris_assignment",
				position = 10,
			},
			aldinari_debris_assignment = {
				enable = true,
				color = "ffffffff",
				timer = false,
				label = "label.aldinari_debris_assignment",
				position = 11,
			},
		},
	}
	return o
end

local SOLAR_WINDS = 87536
local IRRADIATED_ARMOR = 84305

local ROOM_CENTER = Vector3.New(-76.71, -95.79, 357.12)

local ENDER_SPAWN = {
	["W1"] = Vector3.New(-159.57, -95.93, 346.34), -- Aldinari
	--["W2"] = Vector3.New(-149.60, -96.06, 315.52), -- Cassus
	["W3"] = Vector3.New(-145.28, -96.22, 317), -- Vulpes Nix (New)
	["W4"] = Vector3.New(2.25, -96.22, 340.37), -- Aldinari (New)
	--["W5"] = Vector3.New(-19.37, -95.79, 414.22), -- Aldinari
}

local CARDINAL = {
	["N"] = Vector3.New(-76.75, -96.21, 309.26),
	["S"] = Vector3.New(-76.55, -96.21, 405.18),
	["E"] = Vector3.New(-30.00, -96.22, 357.03),
	["W"] = Vector3.New(-124.81, -96.21, 356.96),
}

local ASTEROID_LANE_A = {
	["A1"] = Vector3.New( -83.32, -96.22, 287.38),
	["A2"] = Vector3.New(-139.95, -96.22, 385.47),
	["A3"] = Vector3.New( -68.68, -96.22, 426.62),
		
	["AA"] = Vector3.New( -83.63, -96.22, 284.40),
	["AB"] = Vector3.New(-142.69, -96.22, 386.69),
	["AC"] = Vector3.New( -68.37, -96.22, 429.60),	
}

local ASTEROID_LANE_B = {
	["B1"] = Vector3.New( -12.05, -96.22, 328.53),
	["B2"] = Vector3.New(-122.84, -96.22, 304.98),	
	["B3"] = Vector3.New( -29.16, -96.22, 409.02),
	
	["BA"] = Vector3.New(  -9.31, -96.22, 327.31),
	["BB"] = Vector3.New(-124.85, -96.22, 302.75),
	["BC"] = Vector3.New( -27.15, -96.22, 411.25),
}

local ASTEROID_LANE_C = {
	["C1"] = Vector3.New( -41.00, -96.22, 296.38),
	["C2"] = Vector3.New(-144.47, -96.22, 342.45),
	["C3"] = Vector3.New(  -7.53, -96.22, 371.55),
	["C4"] = Vector3.New(-111.00, -96.22, 417.62),	
	
	["CA"] = Vector3.New( -39.50, -96.22, 293.78),
	["CB"] = Vector3.New(-147.40, -96.22, 341.82),
	["CC"] = Vector3.New(  -4.60, -96.22, 372.18),	
	["CD"] = Vector3.New(-112.50, -96.22, 420.22),
}

local ids = {}
local tEnderCount = 1
local tAsteroidWave = 1
local aMod = 1
local debrisCount = 1
local debrisWave = 1

function Mod:Init(parent)
	Apollo.LinkAddon(parent, self)

	self.core = parent
	self.L = parent:GetLocale(Encounter,Locales)
	ids = {}
end

function Mod:EnderTimer(eCount)
	-- Remove current asteroid lanes
	self.core:RemoveLineBetween("ASTEROID_LANE_1")
	self.core:RemoveLineBetween("ASTEROID_LANE_2")
	self.core:RemoveLineBetween("ASTEROID_LANE_3")
	self.core:RemoveLineBetween("ASTEROID_LANE_4")
	self.core:RemoveText("ASTEROID_ASSIGNMENT_1")
	self.core:RemoveText("ASTEROID_ASSIGNMENT_2")
	self.core:RemoveText("ASTEROID_ASSIGNMENT_3")
	self.core:RemoveText("ASTEROID_ASSIGNMENT_4")
	
	if eCount <= 6 then
		self.core:AddTimer("ENDER_SPAWN", self.L["label.world_ender"..eCount], 78, self.config.timers.world_ender, Mod.EnderTimer, eCount + 1)
	end
end

function Mod:AsteroidsTimer(aCount)
	--if aCount == 7 or aCount == 13 then
	--	self.core:AddTimer("ASTEROIDS", self.L["label.asteroids_important"], 26, self.config.timers.rogue_asteroid, Mod.AsteroidsTimer, aCount + 1)
	--elseif aCount == 2 or aCount == 5 or aCount == 8 or aCount == 11 or aCount == 14 or aCount == 17 then
	--	self.core:AddTimer("ASTEROIDS", self.L["label.asteroids"], 52, self.config.timers.rogue_asteroid, Mod.AsteroidsTimer, aCount + 1)
	--else
	--	self.core:AddTimer("ASTEROIDS", self.L["label.asteroids"], 26, self.config.timers.rogue_asteroid, Mod.AsteroidsTimer, aCount + 1)
	--end
		
	-- Remove current asteroid lanes
	self.core:RemoveLineBetween("ASTEROID_LANE_1")
	self.core:RemoveLineBetween("ASTEROID_LANE_2")
	self.core:RemoveLineBetween("ASTEROID_LANE_3")
	self.core:RemoveLineBetween("ASTEROID_LANE_4")
	self.core:RemoveText("ASTEROID_ASSIGNMENT_1")
	self.core:RemoveText("ASTEROID_ASSIGNMENT_2")
	self.core:RemoveText("ASTEROID_ASSIGNMENT_3")
	self.core:RemoveText("ASTEROID_ASSIGNMENT_4")
	
	-- Determine which wave pattern it is
	aMod = aCount % 3
	
	if aMod == 1 then
		self.core:DrawLineBetween("ASTEROID_LANE_1", ASTEROID_LANE_A["A1"], ROOM_CENTER, self.config.lines.asteroid_lane_a)
		self.core:DrawLineBetween("ASTEROID_LANE_2", ASTEROID_LANE_A["A2"], ROOM_CENTER, self.config.lines.asteroid_lane_b)
		self.core:DrawLineBetween("ASTEROID_LANE_3", ASTEROID_LANE_A["A3"], ROOM_CENTER, self.config.lines.asteroid_lane_c)
		
		self.core:DrawText("ASTEROID_ASSIGNMENT_1", ASTEROID_LANE_A["AA"], self.config.texts.asteroid_assignment_a, "A")
		self.core:DrawText("ASTEROID_ASSIGNMENT_2", ASTEROID_LANE_A["AB"], self.config.texts.asteroid_assignment_b, "B")
		self.core:DrawText("ASTEROID_ASSIGNMENT_3", ASTEROID_LANE_A["AC"], self.config.texts.asteroid_assignment_c, "C")
	elseif aMod == 2 then
		self.core:DrawLineBetween("ASTEROID_LANE_1", ASTEROID_LANE_B["B1"], ROOM_CENTER, self.config.lines.asteroid_lane_a)
		self.core:DrawLineBetween("ASTEROID_LANE_2", ASTEROID_LANE_B["B2"], ROOM_CENTER, self.config.lines.asteroid_lane_b)
		self.core:DrawLineBetween("ASTEROID_LANE_3", ASTEROID_LANE_B["B3"], ROOM_CENTER, self.config.lines.asteroid_lane_c)
		
		self.core:DrawText("ASTEROID_ASSIGNMENT_1", ASTEROID_LANE_B["BA"], self.config.texts.asteroid_assignment_a, "A")
		self.core:DrawText("ASTEROID_ASSIGNMENT_2", ASTEROID_LANE_B["BB"], self.config.texts.asteroid_assignment_b, "B")
		self.core:DrawText("ASTEROID_ASSIGNMENT_3", ASTEROID_LANE_B["BC"], self.config.texts.asteroid_assignment_c, "C")
	else
		self.core:DrawLineBetween("ASTEROID_LANE_1", ASTEROID_LANE_C["C1"], ROOM_CENTER, self.config.lines.asteroid_lane_a)
		self.core:DrawLineBetween("ASTEROID_LANE_2", ASTEROID_LANE_C["C2"], ROOM_CENTER, self.config.lines.asteroid_lane_b)
		self.core:DrawLineBetween("ASTEROID_LANE_3", ASTEROID_LANE_C["C3"], ROOM_CENTER, self.config.lines.asteroid_lane_c)
		self.core:DrawLineBetween("ASTEROID_LANE_4", ASTEROID_LANE_C["C4"], ROOM_CENTER, self.config.lines.asteroid_lane_d)
		
		self.core:DrawText("ASTEROID_ASSIGNMENT_1", ASTEROID_LANE_C["CA"], self.config.texts.asteroid_assignment_a, "A")
		self.core:DrawText("ASTEROID_ASSIGNMENT_2", ASTEROID_LANE_C["CB"], self.config.texts.asteroid_assignment_b, "B")
		self.core:DrawText("ASTEROID_ASSIGNMENT_3", ASTEROID_LANE_C["CC"], self.config.texts.asteroid_assignment_c, "C")
		self.core:DrawText("ASTEROID_ASSIGNMENT_4", ASTEROID_LANE_C["CD"], self.config.texts.asteroid_assignment_d, "D")
	end
	
	-- Determine if it's the first or second wave in the cycle
	aMod = aCount % 2
	
	if aMod == 1 then
		-- First wave
		aMod = aCount % 3
		self.core:AddTimer("ASTEROIDS", self.L["label.asteroids"..aMod], 26, self.config.timers.rogue_asteroid, Mod.AsteroidsTimer, aCount + 1)
	else
		-- Second wave -> delay timer for World Ender spawn
		aMod = aCount % 3
		self.core:AddTimer("ASTEROIDS", self.L["label.asteroids"..aMod], 52, self.config.timers.rogue_asteroid, Mod.AsteroidsTimer, aCount + 1)
	end
end

function Mod:AsteroidsBHTimer(aCount)
	aMod = aCount % 3
	self.core:AddTimer("ASTEROIDS", self.L["label.asteroids"..aMod], 12, self.config.timers.rogue_asteroid, Mod.AsteroidsBHTimer, aCount + 1)
end

function Mod:CassusDebrisTimer(aCount)
	self.core:AddTimer("CASSUS_DEBRIS", self.L["label.cassus_debris"], 26, self.config.timers.cassus_debris, Mod.CassusDebrisTimer, aCount + 1)
end

function Mod:AldinariDebrisTimer(aCount)
	self.core:AddTimer("ALDINARI_DEBRIS", self.L["label.aldinari_debris"], 26, self.config.timers.aldinari_debris, Mod.AldinariDebrisTimer, aCount + 1)
end

function Mod:VulpesDebrisTimer(aCount)
	self.core:AddTimer("VULPES_DEBRIS", self.L["label.vulpes_debris"], 26, self.config.timers.vulpes_debris, Mod.VulpesDebrisTimer, aCount + 1)
end

function Mod:OnUnitCreated(nId, tUnit, sName, bInCombat)
	if sName == self.L["unit.boss"] and bInCombat then
		if not ids[nId] then
			self.core:AddUnit(nId,sName,tUnit,self.config.units.boss)

			self.core:AddTimer("ENDER_SPAWN", self.L["label.world_ender1"], 52, self.config.timers.world_ender, Mod.EnderTimer, tEnderCount + 1)
			self.core:AddTimer("ASTEROIDS", self.L["label.asteroids"..aMod], 26, self.config.timers.rogue_asteroid, Mod.AsteroidsTimer, tAsteroidWave + 1)
			
			self.core:DrawText("ENDER_SPAWN1", ENDER_SPAWN["W1"], self.config.texts.world_ender, "W1")
			--self.core:DrawText("ENDER_SPAWN2", ENDER_SPAWN["W2"], self.config.texts.world_ender, "W2")
			self.core:DrawText("ENDER_SPAWN3", ENDER_SPAWN["W3"], self.config.texts.world_ender, "W3")
			self.core:DrawText("ENDER_SPAWN4", ENDER_SPAWN["W4"], self.config.texts.world_ender, "W4")
			--self.core:DrawText("ENDER_SPAWN5", ENDER_SPAWN["W5"], self.config.texts.world_ender, "W5")

			self.core:DrawText("CARDINAL_N", CARDINAL["N"], self.config.texts.cardinal, "N")
			self.core:DrawText("CARDINAL_S", CARDINAL["S"], self.config.texts.cardinal, "S")
			self.core:DrawText("CARDINAL_E", CARDINAL["E"], self.config.texts.cardinal, "E")
			self.core:DrawText("CARDINAL_W", CARDINAL["W"], self.config.texts.cardinal, "W")

			self.core:DrawPolygon("P1_I", tUnit, self.config.lines.planet_orbit_aldinari, 16, 0, 40)
			self.core:DrawPolygon("P1_O", tUnit, self.config.lines.planet_orbit_aldinari, 24, 0, 40)

			self.core:DrawPolygon("P2_I", tUnit, self.config.lines.planet_orbit_cassus, 35, 0, 50)
			self.core:DrawPolygon("P2_O", tUnit, self.config.lines.planet_orbit_cassus, 45, 0, 50)

			self.core:DrawPolygon("P3_I", tUnit, self.config.lines.planet_orbit_vulpes_nix, 53, 0, 60)
			self.core:DrawPolygon("P3_O", tUnit, self.config.lines.planet_orbit_vulpes_nix, 66, 0, 60)
			
			self.core:DrawLineBetween("ASTEROID_LANE_1", ASTEROID_LANE_A["A1"], ROOM_CENTER, self.config.lines.asteroid_lane_a)
			self.core:DrawLineBetween("ASTEROID_LANE_2", ASTEROID_LANE_A["A2"], ROOM_CENTER, self.config.lines.asteroid_lane_b)
			self.core:DrawLineBetween("ASTEROID_LANE_3", ASTEROID_LANE_A["A3"], ROOM_CENTER, self.config.lines.asteroid_lane_c)
		
			self.core:DrawText("ASTEROID_ASSIGNMENT_1", ASTEROID_LANE_A["AA"], self.config.texts.asteroid_assignment_a, "A")
			self.core:DrawText("ASTEROID_ASSIGNMENT_2", ASTEROID_LANE_A["AB"], self.config.texts.asteroid_assignment_b, "B")
			self.core:DrawText("ASTEROID_ASSIGNMENT_3", ASTEROID_LANE_A["AC"], self.config.texts.asteroid_assignment_c, "C")
			
			ids[nId] = true
		end

	elseif sName == self.L["unit.aldinari"] then
		self.core:AddUnit(nId,sName,tUnit,self.config.units.aldinari)
		self.core:DrawLineBetween("ALDINARI_SUN", nId, ROOM_CENTER, self.config.lines.aldinari_sun)
		self.aldinariId = nId

	elseif sName == self.L["unit.cassus"] then
		self.core:AddUnit(nId,sName,tUnit,self.config.units.cassus)
		self.core:DrawLineBetween("CASSUS_SUN", nId, ROOM_CENTER, self.config.lines.cassus_sun)

	elseif sName == self.L["unit.vulpes_nix"] then
		self.core:AddUnit(nId,sName,tUnit,self.config.units.vulpes_nix)
		self.core:DrawLineBetween("VULPES_NIX_SUN", nId, ROOM_CENTER, self.config.lines.vulpes_nix_sun)

	elseif sName == self.L["unit.rogue_asteroid"] then
		if not ids[nId] then
			self.nTotalAsteroidCount = self.nTotalAsteroidCount + 1
			self.core:AddUnit(nId,sName,tUnit,self.config.units.rogue_asteroid)
			
			self.core:DrawLineBetween(("ROGUE_ASTEROID_%d"):format(nId), nId, nil, self.config.lines.rogue_asteroid_player)
			self.core:DrawLine(nId, tUnit, self.config.lines.rogue_asteroid_direction, 20)
			self.core:DrawText(("ROUGE_ASTEROID_%d"):format(nId), nId, self.config.texts.asteroid_numbers, self.nTotalAsteroidCount, false, 0)
						
			ids[nId] = true
		end

	elseif sName == self.L["unit.world_ender"] then
		if not ids[nId] then
			self.core:AddUnit(nId,sName,tUnit,self.config.units.world_ender)
			self.core:PlaySound(self.config.sounds.world_ender)
			self.core:ShowAlert(sCastName, self.L["alert.world_ender"], self.config.alerts.world_ender)
			self.core:DrawLineBetween("WORLD_ENDER", nId, nil, self.config.lines.world_ender_player)
			self.core:DrawLine("WORLD_ENDER_DIR", nId, self.config.lines.world_ender_direction, 10)

			ids[nId] = true
		end

	elseif sName == self.L["unit.pulsar"] then
		self.core:AddUnit(nId,sName,tUnit,self.config.units.pulsar)
		self.core:PlaySound(self.config.sounds.pulsar)
		self.core:ShowAlert(sCastName, self.L["alert.pulsar"], self.config.alerts.pulsar)
		
	elseif sName == self.L["unit.debris_field"] then
		self.core:DrawIcon(("DEBRIS_FIELD_%d"):format(nId), nId, self.config.icons.debris_field, true, nil, nDuration)
		self.core:DrawLineBetween(("DEBRIS_FIELD_LINE_%d"):format(nId), nId, nil, self.config.lines.debris_field)
		
		if debrisCount == 1 then
			self.core:AddTimer("CASSUS_DEBRIS", self.L["label.cassus_debris"], 26, self.config.timers.cassus_debris, Mod.CassusDebrisTimer, debrisWave + 1)
		elseif debrisCount == 2 then
			self.core:AddTimer("VULPES_DEBRIS", self.L["label.vulpes_debris"], 26, self.config.timers.vulpesnix_debris, Mod.VulpesDebrisTimer, debrisWave + 1)
		else
			self.core:AddTimer("ALDINARI_DEBRIS", self.L["label.aldinari_debris"], 26, self.config.timers.aldinari_debris, Mod.AldinariDebrisTimer, debrisWave + 1)
		end
		
		debrisCount = debrisCount + 1
		
	elseif sName == self.L["unit.cosmic_debris"] then
		self.core:DrawLineBetween(("COSMIC_DEBRIS_%d"):format(nId), nId, nil, self.config.lines.cosmic_debris)
		
	elseif sName == self.L["unit.black_hole"] then
		self.core:AddUnit(nId,sName,tUnit,self.config.units.black_hole)
		
		self.core:RemoveTimer("ENDER_SPAWN")
		self.core:RemoveTimer("ASTEROIDS")
		
		aMod = tAsteroidWave % 3
		self.core:AddTimer("ASTEROIDS", self.L["label.asteroids"..aMod], 12, self.config.timers.rogue_asteroid, Mod.AsteroidsBHTimer, tAsteroidWave + 1)
		
	end
end

function Mod:OnUnitDestroyed(nId, tUnit, sName)
	if sName == self.L["unit.world_ender"] then

	elseif sName == self.L["unit.rogue_asteroid"] then
		self.core:RemoveLineBetween(("ROGUE_ASTEROID_%d"):format(nId))
	elseif sName == self.L["unit.cosmic_debris"] then
		self.core:RemoveLineBetween(("COSMIC_DEBRIS_%d"):format(nId))
	end
end

function Mod:OnCastStart(nId, sCastName, tCast, sName)
	if sName == self.L["unit.boss"] then
		if sCastName == self.L["cast.solar_flare"] then
			self.nSunCast = self.nSunCast + 1
			if self.nSunCast == 1 then
				self.core:DrawLine("BOSS_STACK_CAST", nId, self.config.lines.sun_stack_cast, 25)
			end
		elseif sCastName == self.L["cast.midphase"] then
			self.nSunCast = 0
		end
	end
end

function Mod:OnCastEnd(nId, sCastName, tCast, sName)
	if sName == self.L["unit.boss"] then
		if sCastName == self.L["cast.solar_flare"] then
			if self.nSunCast == 1 then
				self.core:RemoveLineBetween("BOSS_STACK_CAST")
			elseif self.nSunCast == 2 then
				self.nSunCast = 0
			end
		end
	end
end

function Mod:OnBuffAdded(nId, nSpellId, sName, tData, sUnitName, nStack, nDuration)
	if nSpellId == IRRADIATED_ARMOR then
		self.core:PlaySound(self.config.sounds.irradiated_armor)
	elseif nSpellId == SOLAR_WINDS and tData.tUnit:IsThePlayer() then
		self.core:DrawText(nId, self.aldinariId, self.config.texts.solar_winds, "", false, 0, 4)
	end
end

function Mod:OnBuffUpdated(nId, nSpellId, sName, tData, sUnitName, nStack, nDuration)
	if nSpellId == SOLAR_WINDS and nStack >= 7 and tData.tUnit:IsThePlayer() and self.aSolarWindWarned == false then
		self.core:PlaySound(self.config.sounds.solar_winds)
		self.core:ShowAlert("SOLAR_WINDS_ALRT", self.L["alert.solar_winds"], self.config.alerts.solar_winds)
		self.aSolarWindWarned = true
	elseif nSpellId == IRRADIATED_ARMOR and nStack >= 2 then
		self.core:PlaySound(self.config.sounds.irradiated_armor)
	elseif nSpellId == SOLAR_WINDS and tData.tUnit:IsThePlayer() then
		self.core:DrawText(nId, self.aldinariId, self.config.texts.solar_winds, "", false, 0, 4)
	end
end

function Mod:OnBuffRemoved(nId, nSpellId, sName, tData, sUnitName)
	if nSpellId == SOLAR_WINDS and tData.tUnit:IsThePlayer() then
		self.aSolarWindWarned = false
		self.core:RemoveText(nId)
	end
end

function Mod:OnHealthChanged(nId, nHealthPercent, sName, tUnit)
	if sName == self.L["unit.boss"] then
		if nHealthPercent <= 77 and self.nMidphaseWarnings == 0 then
			self.core:ShowAlert("Alert_Midphase", self.L["alert.midphase"], self.config.alerts.midphase)
			self.core:PlaySound(self.config.sounds.midphase)
			self.nMidphaseWarnings = 1
		elseif nHealthPercent <= 47 and self.nMidphaseWarnings == 1 then
			self.core:ShowAlert("Alert_Midphase", self.L["alert.midphase"], self.config.alerts.midphase)
			self.core:PlaySound(self.config.sounds.midphase)
			self.nMidphaseWarnings = 2
		elseif nHealthPercent <= 15 and self.nMidphaseWarnings == 2 then
			self.core:ShowAlert("Alert_Midphase", self.L["alert.midphase"], self.config.alerts.midphase)
			self.core:PlaySound(self.config.sounds.midphase)
			self.nMidphaseWarnings = 3
		end
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
	self.aSolarWindWarned = false
	self.nSunCast = 0
	self.nMidphaseWarnings = 0
	self.nTotalAsteroidCount = 0
end

function Mod:OnDisable()
	self.run = false
end

local ModInst = Mod:new()
LUI_BossMods.modules[Encounter] = ModInst
