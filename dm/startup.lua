-- CSBwin to DSB Conversion script version 1.3
--
-- This mess of code is designed to take an only-slightly-reformatted
-- CSBwin ASCII dump and attempt to convert it into something that DSB
-- actually knows what to do with. Execute this code by loading the
-- dungeon into ESB, then re-save it in native DSB format. After that,
-- you can replace this file with startup2.lua.
--
-- Do not try to load a Lua dump directly into DSB! The format of the
-- dungeon is sufficiently weird that it will introduce all sorts of
-- insidious and subtle bugs. ESB is needed to ensure the dungeon is
-- saved in a format that DSB can tolerate.
--

CONVERTING_FROM = "DM"

CSB2DSB = {
	["SQUARE DRAIN"] = "squaredrain",
	["SQUARE PAD"] = "pad",
	["POISON PUDDLE"] = "floorslime",
	["ROUND GRID"] = "rounddrain",
	["HEXAGONAL PAD"] = "pad_small",
	["FIRE POT"] = "firepit",
	["GREY MARK"] = "floorcrack",
	["TINY PAD"] = "pad_tiny",
	["WATER PUDDLE"] = "puddle",
	
	["Garbled Text"] = "wallwriting",
	["Square Alcove"] = "alcove",
	["VI Altar"] = "alcove_vi",
	["Ornate Alcove"] = "alcove2",
	["Hook"] = "hook",
	["Block Lock"] = "keyhole_plain",
	["Iron Ring"] = "ring_plain",
	["Small Switch"] = "smallswitch",
	["Dent 1"] = "dent",
	["Dent 2"] = "dent2",
	["Wood Ring"] = "ring_wood",
	["Crack"] = "crack",
	["Slime Outlet"] = "slimedrain",
	["Point"] = "peg",
	["Tiny Switch"] = "tinyswitch",
	["Green Button(Out)"] = "button_green",
	["Blue Button(Out)"] = "button_blue",
	["Coin Slot"] = "coinslot",
	["Double Lock"] = "keyhole_double",
	["Square Lock"] = "keyhole_square",
	["Winged Lock"] = "keyhole_winged",
	["Onyx Lock"] = "keyhole_onyx",
	["Stone Lock"] = "keyhole_solid",
	["Cross Lock"] = "keyhole_cross",
	["Jeweled Lock"] = "keyhole_topaz",
	["Skeleton Lock"] = "keyhole_skeleton",
	["Gold Lock"] = "keyhole_gold",
	["Turquoise Lock"] = "keyhole_turquoise",
	["Emerald Lock"] = "keyhole_emerald",
	["Ruby Lock"] = "keyhole_ruby",
	["RA Lock"] = "keyhole_ra",
	["Master Lock"] = "keyhole_master",
	["Gem Hole"] = "gemhole",
	["Slime"] = "wallslime",
	["Grate"] = "wallgrate",
	["Fountain"] = "fountain_medusa",
	["Manacles"] = "manacles",
	["Demon Face"] = "gorface",
	["Dragon Claws"] = "scratches",
	["Poison Holes"] = "holes_poison",
	["Fireball Holes"] = "holes_fireball",
	["Dagger Holes"] = "holes_dagger",
	["Picture Frame"] = "mirror",
	["Lever(Up)"] = "lever_up",
	["Lever(Down)"] = "lever_down",
	["Torch Holder(Empty)"] = "sconce_empty",
	["Torch Holder(Full)"] = "sconce_full",
	["Red Button(Out)"] = "button_redcross",
	["Eye Switch"] = "eye",
	["Big Switch(Out)"] = "brickswitch",
	["Crack Switch(Out)"] = "crackswitch",
	["Green Buton(In)"] = "button_green_pushed",
	["Blue Button(In)"] = "button_blue_pushed",
	["Red Button(In)"] = "button_redcross_pushed",
	["Big Switch(In)"] = "brickswitch_pushed",
	["Crack Switch(In)"] = "crackswitch_pushed",
	["Amalgam"] = "amalgam",
	["Powered Amalgam"] = "amalgam_gembare",
	["Burnt Amalgam"] = "amalgam_empty",
	["Evil Outside"] = "outside",
	
	["Scorpion"] = "scorpion",
	["Slime_Devil"] = "slimedevil",
	["Giggler"] = "giggler",
	["Flying_Eye"] = "gazer",
	["Hellhound"] = "hellhound",
	["Ruster"] = "ruster",
	["Screamer"] = "screamer",
	["Rock_Pile"] = "rockpile",
	["Rive"] = "rive",
	["Stone_Golem"] = "golem",
	["Mummy"] = "mummy",
	["Black_Flame"] = "blackflame",
	["Skeleton"] = "skeleton",
	["Couatl"] = "couatl",
	["Vexirk"] = "vexirk2",
	["Worm"] = "worm2b",
	["Ant_Man"] = "antman",
	["Muncher"] = "muncher",
	["Deth_Knight"] = "knight_deth",
	["Zytaz"] = "zytaz",
	["Water_Elemental"] = "waterelem",
	["Oitu"] = "oitu2",
	["Demon"] = "demon2",
	["Lord_Chaos"] = "lordchaos",
	["Dragon"] = "dragon",
	["Lord_Order"] = "lordorder",
	["Grey_Lord"] = "greylord",
	
	["Eye of Time"] = "eye_of_time",
	["Stormring"] = "stormring",
	["Torch"] = "torch",
	["Flamitt"] = "flamitt",
	["Staff of Claws"] = "staff_claws",
	["Bolt Blade"] = "boltblade",
	["Storm"] = "storm",
	["Fury"] = "fury",
	["Ra Blade"] = "rablade",
	["The Firestaff"] = "firestaff",
	["Dagger"] = "dagger",
	["Falchion"] = "falchion",
	["Sword"] = "sword",
	["Rapier"] = "rapier",
	["Sabre"] = "sabre",
	["Biter"] = "biter",
	["Axe"] = "axe",
	["Samurai Sword"] = "sword_samurai",
	["Delta"] = "delta",
	["Side Splitter"] = "side_splitter",
	["Diamond Edge"] = "diamond_edge",
	["Vorpal Blade"] = "vorpal",
	["Inquisitor"] = "inquisitor",
	["Dragon Fang"] = "dragon_fang",
	["Hardcleave"] = "hardcleave",
	["Executioner"] = "executioner",
	["Mace"] = "mace",
	["Mace of Order"] = "mace_order",
	["Morningstar"] = "morningstar",
	["Club"] = "club",
	["Stone Club"] = "club_stone",
	["Bow"] = "bow",
	["Claw Bow"] = "bow_claw",
	["Crossbow"] = "crossbow",
	["Arrow"] = "arrow",
	["Slayer"] = "slayer",
	["Sling"] = "sling",
	["Rock"] = "rock",
	["Poison Dart"] = "dart_csb",
	["Throwing Star"] = "throwing_star",
	["Stick"] = "stick",
	["Staff"] = "staff",
	["Wand"] = "wand",
	["Teowand"] = "teowand",
	["Yew Staff"] = "staff_yew",
	["Staff of Manar"] = "staff_manar",
	["Staff of Irra"] = "staff_irra",
	["Snake Staff"] = "staff_snake",
	["Cross of Neta"] = "staff_neta",
	["Conduit"] = "staff_conduit",
	["Serpent Staff"] = "staff_serpent",
	["Dragon Spit"] = "dragon_spit",
	["Sceptre of Lyf"] = "lyf",
	["Horn of Fear"] = "horn_of_fear",
	["Speedbow"] = "speedbow",
	["The Firestaff+"] = "firestaff_gem",

	["Compass"] = "compass_n",
	["Waterskin"] = "waterskin",
	["Jewel Symal"] = "jewelsymal",
	["Illumulet"] = "illumulet",
	["Ashes"] = "ashes",
	["Bones(Party)"] = "bones",
	["Copper Coin"] = "coin_copper",
	["Sar Coin"] = "coin_sar",
	["Silver Coin"] = "coin_silver",
	["Gold Coin"] = "coin_gold",
	["Gor Coin"] = "coin_gor",
	["Iron Key"] = "key_iron",
	["Key of B"] = "key_b",
	["Solid Key"] = "key_solid",
	["Square Key"] = "key_square",
	["Tourquoise Key"] = "key_tourquoise",
	["Cross Key"] = "key_cross",
	["Onyx Key"] = "key_onyx",
	["Skeleton Key"] = "key_skeleton",
	["Gold Key"] = "key_gold",
	["Winged Key"] = "key_winged",
	["Topaz Key"] = "key_topaz",
	["Sapphire Key"] = "key_sapphire",
	["Emerald Key"] = "key_emerald",
	["Ruby Key"] = "key_ruby",
	["Ra Key"] = "key_ra",
	["Master Key"] = "key_master",
	["Boulder"] = "boulder",
	["Blue Gem"] = "gem_blue",
	["Orange Gem"] = "gem_orange",
	["Green Gem"] = "gem_green",
	["Apple"] = "apple",
	["Corn"] = "corn",
	["Bread"] = "bread",
	["Cheese"] = "cheese",
	["Screamer Slice"] = "s_slice",
	["Worm Round"] = "worm_round",
	["Drumstick"] = "drumstick",
	["Shank"] = "shank",
	["Dragon Steak"] = "d_steak",
	["Gem of Ages"] = "gem_of_ages",
	["Ekkhard Cross"] = "ekkhard_cross",
	["Moonstone"] = "moonstone",
	["The Hellion"] = "hellion",
	["Pendant Feral"] = "pendant_feral",
	["Magic Box(Blue)"] = "magicbox_blue",
	["Magic Box(Green)"] = "magicbox_green",
	["Mirror of Dawn"] = "mirror_of_dawn",
	["Rope"] = "rope",
	["Rabbit's Foot"] = "rabbits_foot",
	["Corbamite"] = "corbum",
	["Corbum"] = "corbum",
	["Choker"] = "choker",
	["Lock Picks"] = "lockpicks",
	["Magnifier"] = "magnifier",
	["Zokathra Spell"] = "zokathra",
	["Bones"] = "bones",
	
	["Cape"] = "cape",
	["Cloak of Night"] = "cloak_night",
	["Tattered Pants"] = "tattered_pants",
	["Sandals"] = "sandals",
	["Leather Boots"] = "boots_leather",
	["Robe(Body)"] = "robe_top",
	["Tattered Shirt"] = "tattered_shirt",
	["Robe"] = "robe_bottom",
	["Fine Robe(top)"] = "robe_fine_top",
	["Fine Robe(bottom)"] = "robe_fine_bottom",
	["Kirtle"] = "kirtle",
	["Silk Shirt"] = "silk_shirt",
	["Tabard"] = "tabard",
	["Gunna"] = "gunna",
	["Elven Doublet"] = "elven_doublet",
	["Elven Huke"] = "elven_huke",
	["Elven Boots"] = "boots_elven",
	["Leather Jerkin"] = "leather_jerkin",
	["Leather Pants"] = "leather_pants",
	["Suede Boots"] = "boots_suede",
	["Blue Pants"] = "blue_pants",
	["Tunic"] = "tunic",
	["Ghi"] = "ghi",
	["Ghi Trousers"] = "ghi_trousers",
	["Calista"] = "calista",
	["Crown of Nerra"] = "crown_nerra",
	["Bezerker Helm"] = "berzerker_helm_csb",
	["Helmet"] = "helmet",
	["Basinet"] = "basinet",
	["Buckler"] = "shield_buckler",
	["Neta Shield"] = "shield_neta",
	["Hide Shield"] = "shield_hide",
	["Crystal Shield"] = "shield_crystal",
	["Wooden Shield"] = "shield_wood",
	["Small Shield"] = "shield_small",
	["Mail Aketon"] = "mail_aketon",
	["Leg Mail"] = "leg_mail",
	["Mithral Aketon"] = "mithral_aketon",
	["Mithral Mail"] = "mithral_mail",
	["Casque 'n Coif"] = "casquencoif",
	["Hosen"] = "hosen",
	["Armet"] = "armet",
	["Torso Plate"] = "torsoplate",
	["Leg Plate"] = "legplate",
	["Foot Plate"] = "footplate",
	["Large Shield"] = "shield_large",
	["Sar Shield"] = "shield_sar",
	["Helm of Lyte"] = "helm_lyte",
	["Helm of Ra"] = "helm_ra",
	["Plate of Lyte"] = "torsoplate_lyte",
	["Plate of Ra"] = "torsoplate_ra",
	["Poleyn of Lyte"] = "legplate_lyte",
	["Poleyn of Ra"] = "legplate_ra",
	["Greave of Lyte"] = "footplate_lyte",
	["Greave of Ra"] = "footplate_ra",
	["Shield of Lyte"] = "shield_lyte",
	["Shield of Ra"] = "shield_ra",
	["Helm of Darc"] = "helm_darc",
	["Dragon Helm"] = "helm_dragon",
	["Plate of Darc"] = "torsoplate_darc",
	["Dragon Plate"] = "torsoplate_dragon",
	["Poleyn of Darc"] = "legplate_darc",
	["Dragon Poleyn"] = "legplate_dragon",
	["Greave of Darc"] = "footplate_darc",
	["Dragon Greave"] = "footplate_dragon",
	["Shield of Darc"] = "shield_darc",
	["Dragon Shield"] = "shield_dragon",
	["Dexhelm"] = "dexhelm",
	["Flamebain"] = "flamebain",
	["Powertowers"] = "powertowers",
	["Boots of Speed"] = "boots_speed",
	["Halter"] = "halter",
	
	["Mon Potion(Stamina)"] = "flask_mon",
	["Mon Potion Green(Stamina)"] = "flask_mon",
	["Um Potion"] = "flask",
	["Des Potion"] = "flask",
	["Ven Potion(Poison)"] = "venbomb",
	["Sar Potion"] = "flask_sar",
	["Zo Potion"] = "flask_zo",
	["Ros Potion(Dexterity)"] = "flask_ros",
	["Ku potion(Strength)"] = "flask_ku",
	["Dane Potion(Wisdom)"] = "flask_dane",
	["Neta Potion(Vitality"] = "flask_neta",
	["Bro Potion"] = "flask_bro",
	["Antivenin(Cure Poison)"] = "flask_bro",
	["Ma Potion"] = "flask_mon",
	["Mon Potion Blue(Stamina)"] = "flask_mon",
	["Ya Potion(Magic Shield)"] = "flask_ya",
	["Ee Potion(Mana)"] = "flask_ee",
	["Vi Potion(Health)"] = "flask_vi",
	["Water Flask"] = "flask_water_yucky",
	["Kath Bomb"] = "fulbomb",
	["Pew Bomb"] = "fulbomb",
	["Ra Bomb"] = "fulbomb",
	["Ful Bomb"] = "fulbomb",
	["Empty Flask"] = "flask",
	
	-- Deco merged with the basic door types
	-- Certain door+deco combinations don't exist in DSB
	["Door Square Grid"] = "_swindow",
	["Door Metal Bars"] = "_metalbars",
	["Door Jewels"] = "_ornate",
	["Door Wood Ven"] = "_strong",
	["Door Arched Grid"] = "_cwindow",
	["Door Block Lock"] = "_metallock",
	["Door Corner Metal"] = "_bottomlock",
	["Door Ebony"] = "door_black",
	["Door Red Triangle Lock"] = "_redlock",
	["Door Trianngle Lock"] =  "_redlock", -- I have no idea what this one is
	["Door Blue Force Field"] = "door_ra_magic",
	["Door Damaged Metal"] = "door_metal_damaged"
}

-- CSBuild's name conversion doesn't handle everything
if (CONVERTING_FROM == "DM") then
	CSB2DSB["Poison Dart"] = "dart"
	CSB2DSB["Bezerker Helm"] = "berzerker_helm"
	CSB2DSB["Dragon Spit"] = "dragon_spit_x" -- You get the nonfunctional one in real DM!
	
	CSB2DSB["Fountain"] = "fountain_lion"
	
	-- I think these are just oversights in CSBuild
	CSB2DSB["Dragon Fang"] = "inquisitor"
	CSB2DSB["Executioner"] = "hardcleave"
	CSB2DSB["Tattered Pants"] = "barbarian_hide"
	
	-- Use DM monsters, not CSB
	CSB2DSB["Slime_Devil"] = "swampslime"
	CSB2DSB["Flying_Eye"] = "wizardeye"
	CSB2DSB["Hellhound"] = "rat"
	CSB2DSB["Rive"] = "ghost"
	CSB2DSB["Vexirk"] = "vexirk"
	CSB2DSB["Worm"] = "worm"
	CSB2DSB["Ant_Man"] = "trolin"
	CSB2DSB["Muncher"] = "wasp"
	CSB2DSB["Deth_Knight"] = "knight_armour"
	CSB2DSB["Zytaz"] = "materializer"
	CSB2DSB["Oitu"] = "oitu"
	CSB2DSB["Demon"] = "demon"
end

arch_names = {
	monsters = { },
	weapons = { },
	potions = { },
	clothing = { },
	misc = { },
	floor_deco = { },
	wall_deco = { },

	basic_doors = { "door_portcullis", "door_wood", "door_metal", "door_ra" },
	deco_doors = { },

}

DB_DOOR = 0
DB_TELE = 1
DB_TEXT = 2
DB_ACT  = 3
DB_MON  = 4
DB_WEAP = 5
DB_CLOT = 6
DB_SCRO = 7
DB_POT  = 8
DB_CHES = 9
DB_MISC = 10
DB_EXP	= 11
EMPTY = 65534

forward = -1
right = -2
back = -3
left = -4
north = NORTH
south = SOUTH
east = EAST
west = WEST

dd = { 
	db = { 
		[DB_DOOR] = { },
		[DB_TELE] = { },
		[DB_TEXT] = { },
		[DB_ACT]  = { },
		[DB_MON]  = { },
		[DB_WEAP] = { },
		[DB_CLOT] = { },
		[DB_SCRO] = { },
		[DB_POT]  = { },
		[DB_CHES] = { },
		[DB_MISC] = { },
		[DB_EXP]  = { }
	},
	it = { },
	text = { },
	offsets =  { },
	width = { },
	height = { },
	doors = { },
	deco_info = { },
	timer65targets = { },
	got_graphic = { }
}

convert = {
	dungeon = function(ptable)
		dd.dungeon_data = ptable
		
		local gameflags = GAME_ONE_WALLITEM + GAME_NO_LAUNCH_TELEPORT
		if (not ptable.DMRules) then
			gameflags = gameflags + GAME_CSB_REINCARNATION
		end
		dsb_set_gameflag(gameflags)
	end,
	
	level = function(ptable)
	
		dd.offsets[ptable.level] = ptable.offset
		dd.width[ptable.level] = ptable.size[1]
		dd.height[ptable.level] = ptable.size[2]
		
		dd.deco_info[ptable.level] = {
			rand_floor = ptable.numRanFloor,
			rand_wall = ptable.numRanWall,
		}
		
		dd.doors[ptable.level] = { ptable.doors[1]+1, ptable.doors[2]+1 }
		
		local total_x = ptable.size[1] + ptable.offset[1]
		local total_y = ptable.size[2] + ptable.offset[2]
		local light = 0
		if (ptable.expMult == 0) then light = 100 end
		dsb_text2map(ptable.level, total_x, total_y, light, ptable.expMult, nil)
		dsb_level_wallset(ptable.level, wallset.default)
		-- Start inactive, like DM
		dsb_level_flags(ptable.level, 2)
		
		for yy=0,total_y-1 do
			for xx=0,total_x-1 do
				if (xx < ptable.offset[1] or yy < ptable.offset[2]) then
					dsb_set_cell(ptable.level, xx, yy, true)
				end
			end
		end
		
	end,
	
	monsterName = function(ptable)
		arch_names.monsters[ptable.monsterIndex + 1] = CSB2DSB[ptable.monsterName]
	end,
	
	floorDecorationName = function(ptable)
		arch_names.floor_deco[ptable.floorDecorationIndex + 1] = CSB2DSB[ptable.floorDecorationName]
	end,
	
	wallDecorationName = function(ptable)
		arch_names.wall_deco[ptable.wallDecorationIndex + 1] = CSB2DSB[ptable.wallDecorationName]
	end,
	
	doorDecorationName = function(ptable)
		arch_names.deco_doors[ptable.doorDecorationIndex + 1] = CSB2DSB[ptable.doorDecorationName]
	end,
	
	weaponName = function(ptable)
		arch_names.weapons[ptable.weaponIndex + 1] = CSB2DSB[ptable.weaponName]
		if (not CSB2DSB[ptable.weaponName]) then
			esb_information("No Weapon table entry for " .. ptable.weaponName)
		end
	end,
	
	potionName = function(ptable)
		arch_names.potions[ptable.potionIndex + 1] = CSB2DSB[ptable.potionName]
		if (not CSB2DSB[ptable.potionName]) then
			esb_information("No Potion table entry for " .. ptable.potionName)
		end
	end,
	
	clothingName = function(ptable)
		arch_names.clothing[ptable.clothingIndex + 1] = CSB2DSB[ptable.clothingName]
		if (not CSB2DSB[ptable.clothingName]) then
			esb_information("No Clothing table entry for " .. ptable.clothingName)
		end
	end,
	
	miscObjectName = function(ptable)
		arch_names.misc[ptable.miscObjectIndex + 1] = CSB2DSB[ptable.miscObjectName]
		if (not CSB2DSB[ptable.miscObjectName]) then
			esb_information("No Misc Object table entry for " .. ptable.miscObjectName)
		end
	end,
	
	monsterlist = function(ptable)
	end,
	
	wallDecorationList = function(ptable)
		dd.deco_info[ptable.level].walls = ptable.list
	end,
	
	floorDecorationList = function(ptable)
		dd.deco_info[ptable.level].floors = ptable.list
	end,
	
	doorDecorationList = function(ptable)
		dd.deco_info[ptable.level].doors = ptable.list
	end,
	
	DSAlist = function(ptable)
	end,
	
	Timer = function(ptable)
		if (ptable.func == 65) then
			dd.timer65targets[ptable.x+(ptable.y*100)+(ptable.level*10000)] = ptable
		end
	end,
	
	door = function(ptable)
		dd.db[DB_DOOR][ptable.index] = { door = true, link = ptable.link, pt = ptable }
	end,
	
	teleporter = function(ptable)
		dd.db[DB_TELE][ptable.index] = { arch = "teleporter", link = ptable.link, pt = ptable  }
	end,
	
	text = function(ptable)
		dd.db[DB_TEXT][ptable.index] = { text = true, link = ptable.link, show = ptable.show, textindex = ptable.textIndex }  
	end,
	
	actuator = {
		Portrait = function(ptable)
			dd.db[DB_ACT][ptable.index] = { arch = "mirror", link = ptable.link, pt = ptable }
		end,
		
		PressurePad = function(ptable)
			dd.db[DB_ACT][ptable.index] = { arch = "trigger",
				graphic = ptable.graphic, link = ptable.link, pt = ptable }
		end,
		
		Pushbutton = function(ptable)
			dd.db[DB_ACT][ptable.index] = { direct = true, pushbutton = true,
				graphic = ptable.graphic, link = ptable.link, pt = ptable}
		end,
		
		MonsterGenerator = function(ptable)
			dd.db[DB_ACT][ptable.index] = { arch = "monster_generator",
				graphic = ptable.graphic, link = ptable.link, pt = ptable }
		end,
		
		Andor = function(ptable)
			dd.db[DB_ACT][ptable.index] = { arch = "trigger_controller",
				graphic = ptable.graphic, link = ptable.link, pt = ptable }
		end,
		
		Disabled = function(ptable)
			dd.db[DB_ACT][ptable.index] = { direct = true, disabled = true,
				graphic = ptable.graphic, link = ptable.link, monster_generator = ptable.MonsterGenerator }
		end,
		
		Counter = function(ptable)
			dd.db[DB_ACT][ptable.index] = { arch = "counter",
				graphic = ptable.graphic, link = ptable.link, pt = ptable }
		end,
		
		Launcher = function(ptable)
			dd.db[DB_ACT][ptable.index] = { arch = "shooter",
				graphic = ptable.graphic, link = ptable.link, pt = ptable }
		end,
		
		Objectholder = function(ptable)
			dd.db[DB_ACT][ptable.index] = { direct = true, objectholder = true,
				graphic = ptable.graphic, link = ptable.link, pt = ptable}
		end,
		
		Swapobject = function(ptable)
			dd.db[DB_ACT][ptable.index] = { arch = "qswapper", swapobject = true,
				graphic = ptable.graphic, link = ptable.link, pt = ptable }
		end,
		
		Endgame = function(ptable)
			dd.db[DB_ACT][ptable.index] = { arch = "function_caller", endgame = true, link = ptable.link, pt = ptable }	
		end
	},
	
	monster = function(ptable)
		dd.db[DB_MON][ptable.index] = { arch = arch_names.monsters[ptable.type + 1], link = ptable.link, 
			contents = ptable.possessions, pt = ptable }
	end,
	
	weapon = function(ptable)
		dd.db[DB_WEAP][ptable.index] = { arch = arch_names.weapons[ptable.type + 1], link = ptable.link, cursed = ptable.cursed }
	end,
	
	clothing = function(ptable)
		dd.db[DB_CLOT][ptable.index] = { arch = arch_names.clothing[ptable.type + 1], link = ptable.link, cursed = ptable.cursed  }
	end,
	
	scroll = function(ptable)
		dd.db[DB_SCRO][ptable.index] = { arch = "scroll", link = ptable.link, text_indirect_index = ptable.textIndex }
	end,
	
	potion = function(ptable)
		dd.db[DB_POT][ptable.index] = { arch = arch_names.potions[ptable.type + 1], link = ptable.link, strength = ptable.strength }
	end,
	
	chest = function(ptable)
		dd.db[DB_CHES][ptable.index] = { arch = "chest", link = ptable.link, contents = ptable.contents }
	end,
	
	misc = function(ptable)
		local arch_name = arch_names.misc[ptable.type + 1]
		if (arch_name == "waterskin") then
			if (ptable.value == 1) then arch_name = "waterskin_1"
			elseif (ptable.value == 2) then arch_name = "waterskin_2"
			elseif (ptable.value == 3) then arch_name = "waterskin_full"
			end
		end
		dd.db[DB_MISC][ptable.index] = { arch = arch_name, link = ptable.link, cursed = ptable.cursed  }
	end,
	
	IndirectTable = function(ptable)
		dd.it[ptable.index] = { db = ptable.dbType, v = ptable.dbIndex, pos = ptable.pos }
	end,
	
	rawtext = function(ptable)
		dd.text[ptable.index] = dsb_textconvert_dmstring(ptable.text)
	end,
	
	cell = function(ptable)

		-- values without offsets
		local map_x = ptable.location[2]
		local map_y = ptable.location[3]
		-- and the normal ones
		local lev = ptable.location[1]
		local x = map_x + dd.offsets[lev][1]
		local y = map_y + dd.offsets[lev][2]
		
		if (ptable.roomType == "STONE") then
			dsb_set_cell(lev, x, y, true)
			
			-- Random decorations
			local deco = { false, false, false, false }
			if (ptable.flags.northDec) then deco[1] = true end
			if (ptable.flags.eastDec) then deco[2] = true end
			if (ptable.flags.southDec) then deco[3] = true end
			if (ptable.flags.westDec) then deco[4] = true end
			for decdir=1,4 do
				if (deco[decdir]) then
					local num_deco = dd.deco_info[lev].rand_wall
					local use_deco = convert.random_deco(lev, map_x, (map_y+1)*decdir, num_deco, 30)
					if (use_deco) then
						local deco_num = dd.deco_info[lev].walls[use_deco + 1]
						if (deco_num > -1) then
							local deco_arch = arch_names.wall_deco[deco_num + 1]
							local rd = dsb_spawn(deco_arch, lev, x, y, decdir-1)
							exvar[rd] = { RANDOM_DECO = true }
						end
					end
				end
			end
		else
			if (ptable.flags.Dec) then
				local num_deco = dd.deco_info[lev].rand_floor
				local use_deco = convert.random_deco(lev, map_x, map_y, num_deco, 30)
				if (use_deco) then
					local deco_num = dd.deco_info[lev].floors[use_deco + 1]
					if (deco_num > -1) then
						local deco_arch = arch_names.floor_deco[deco_num + 1]
						local rd = dsb_spawn(deco_arch, lev, x, y, CENTER)
						exvar[rd] = { RANDOM_DECO = true }
					end
				end
			end		
		end
		
		if (ptable.roomType == "PIT") then
			local pit_type = "pit"
			
			if (ptable.flags.obscure) then
				pit_type = "ipit"
			elseif (ptable.flags.falsePit) then
				pit_type = "fakepit"
			end
			
			local pid = dsb_spawn(pit_type, lev, x, y, CENTER)
			if (not ptable.flags.open) then
				dsb_disable(pid)
			end
			exvar[pid] = { TARGETABLE = true }
		elseif (ptable.roomType == "FALSEWALL") then
			local wall_type = "movablewall"
			if (ptable.flags.open) then wall_type = "fakewall" end
			local wid = dsb_spawn(wall_type, lev, x, y, CENTER)
			if (ptable.flags.invisible) then
				dsb_disable(wid)
			end			
			if (wall_type == "movablewall") then
				exvar[wid] = { TARGETABLE = true }
				if (not ptable.flags.invisible) then
					dsb_set_cell(lev, x, y, true)
				end
			end
		elseif (ptable.roomType == "DOOR") then
			local dfid = dsb_spawn("doorframe", lev, x, y, CENTER)
		elseif (ptable.roomType == "STAIRS") then
			local stair_type = "stairsdown"
			if (ptable.flags.up) then stair_type = "stairsup" end
			local sid = dsb_spawn(stair_type, lev, x, y, CENTER)
		end
		
		local itemlist = ptable.contents
		convert.spawn_itemlist(ptable, ptable.contents, lev, x, y, false)
	
	end,
	
	finish = function(ptable)
		local lev = dd.dungeon_data.partyLocation[1]
		local x = dd.dungeon_data.partyLocation[2] + dd.offsets[lev][1]
		local y = dd.dungeon_data.partyLocation[3] + dd.offsets[lev][2]
		dsb_party_place(lev, x, y, dd.dungeon_data.partyLocation[4])
		
		-- Reconcile the targeted squares with DSB's targeting system
		for x in pairs(exvar) do
			if (exvar[x].TARGET_SQUARE) then
				local targlist = { }
				local targ_num = 1
				local tlev = exvar[x].TARGET_SQUARE[1]
				local tx = exvar[x].TARGET_SQUARE[2]
				local ty = exvar[x].TARGET_SQUARE[3]
				local tpos = exvar[x].TARGET_POS
				
				-- DSB mechanics tend to live at the center of cells, so do that
				local atloc = dsb_fetch(tlev, tx, ty, CENTER)
				if (atloc) then
					for ix in pairs(atloc) do
						local id = atloc[ix]
						if (exvar[id] and exvar[id].TARGETABLE) then
							targlist[targ_num] = id
							targ_num = targ_num + 1
							
							local t_arch = dsb_find_arch(id)
							-- Position is important, it sends the bit number
							if (t_arch == obj.trigger_controller) then
								exvar[x].data = tpos + 1
							end
							
						end
					end
				end
				
				-- Look for shooters and whatever
				local atloc = dsb_fetch(tlev, tx, ty, tpos)
				if (atloc) then
					for ix in pairs(atloc) do
						local id = atloc[ix]
						if (exvar[id] and exvar[id].TARGETABLE_OFFCENTER) then
							targlist[targ_num] = id
							targ_num = targ_num + 1							
						end
					end
				end
				
				if (targ_num > 2) then
					exvar[x].target = targlist
				elseif (targ_num == 2) then
					exvar[x].target = targlist[1]
				end
				
			end
		end
		
		-- Place objects at holders inside of them
		-- and fix initial teleporters
		for x in pairs(exvar) do
			if (exvar[x].OBJECT_HOLDER) then
				local lev, xc, yc, pos = dsb_get_coords(x)
				local objs = dsb_fetch(lev, xc, yc, pos)
				if (objs) then
					for c_id in pairs(objs) do
						local inst = objs[c_id]
						if (inst ~= x) then
							local arch = dsb_find_arch(inst)
							if (arch.type == "THING") then
								dsb_move(inst, IN_OBJ, x, -1, 0)
								exvar[x].release = true
							elseif (arch.type == "WALLITEM") then
								if (arch.convert_take_object or arch.convert_release_object) then
									use_exvar(inst)
									exvar[inst].GET_RID_OF_ME = true
									exvar[x].func = nil
								end
							end
						end
					end
				end
				
				-- If there is a torch inside, it's a full sconce
				objs = dsb_fetch(IN_OBJ, x, -1, 0)
				if (objs) then
					local arch = dsb_find_arch(objs[1])
					if (arch.class == "TORCH") then
						dsb_qswap(x, "sconce_full")
					end
				end
			end
			
			if (exvar[x].TELEPORTER or exvar[x].OBJECT_TRIGGER) then
				if (not dsb_get_gfxflag(x, GF_INACTIVE)) then
					local t_blacklist = { }
					local bl_len = 1
					local lev, xc, yc, pdir = dsb_get_coords(x)
					for p=0,4 do
						if (pdir == CENTER or pdir == p) then
							local objs = dsb_fetch(lev, xc, yc, p)
							if (objs) then
								for c_id in pairs(objs) do
									local inst = objs[c_id]
									local arch = dsb_find_arch(inst)
									local blacklisted = false
									
									if (exvar[x].opby_thing and arch.type == "THING") then
										blacklisted = true
									elseif (exvar[x].opby_monster and arch.type == "MONSTER") then
										-- Floating monsters don't trigger things so they
										-- don't need to be blacklisted!
										if (not arch.hover) then
											blacklisted = true
										end
									end
									
									if (blacklisted) then
										t_blacklist[bl_len] = inst
										bl_len = bl_len + 1
									end
								end
							end
						end
					end
					if (bl_len > 1) then
						exvar[x].blacklist = t_blacklist
						-- This only works if the blacklist doesn't stick around
						if (exvar[x].OBJECT_TRIGGER) then
							exvar[x].tc = (bl_len - 1)
						end
					end
				end
			end
						
			if (exvar[x].LOCAL_ACTION) then
				local lev, xc, yc, pos = dsb_get_coords(x)
				local objs = dsb_fetch(lev, xc, yc, pos)
				if (objs) then
					for c_id in pairs(objs) do
						local inst = objs[c_id]
						local arch = dsb_find_arch(inst)
						if (inst ~= x and arch.type == "WALLITEM") then
							exvar[x].msg = exvar[inst].msg
							exvar[x].target = exvar[inst].target
							exvar[x].data = exvar[inst].data
							exvar[x].opby_empty_hand_only = true
							exvar[x].disable_self = true
							
							exvar[inst].msg = nil
							exvar[inst].target = nil
							exvar[inst].data = nil
						end
					end
				end
			end
			
			if (exvar[x].FLOOR_TEXT) then
				if (dsb_get_gfxflag(x, GF_INACTIVE)) then
					local lev, xc, yc, pos = dsb_get_coords(x)
					local mymirror
					for d=0,3 do
						local dx, dy = dsb_forward(d)
						mymirror = search_for_class(lev, xc+dx, yc+dy, (d+2)%4, "CHAMPION_HOLDER")
						if (mymirror) then break end
					end
					if (mymirror) then
						local char_id = convert.text_to_character(exvar[x].text)
						use_exvar(mymirror)
						exvar[mymirror].champion = char_id
						exvar[x].GET_RID_OF_ME = true
					end
					
					if (mymirror) then				
						-- Remove duplicate mirrors and copy their messages
						lev, xc, yc, pos = dsb_get_coords(mymirror)
						local mirror_loc = dsb_fetch(lev, xc, yc, pos)
						for i in pairs(mirror_loc) do
							if (mirror_loc[i] ~= mymirror) then
								local mirror_inst = mirror_loc[i]
								local mirror_arch = dsb_find_arch(mirror_inst)
								if (mirror_arch.class == "CHAMPION_HOLDER") then
									if (exvar[mirror_inst]) then
										for z in pairs(exvar[mirror_inst]) do
											exvar[mymirror][z] = exvar[mirror_inst][z]
										end
									end
									exvar[mirror_inst].GET_RID_OF_ME = true
								end
							end
						end
					end
				end
				
				if (not exvar[x].GET_RID_OF_ME) then
					exvar[x].text = convert.fix_floortext_slashes(exvar[x].text)
				end
				
			end
			
			if (exvar[x].RANDOM_DECO) then
				local lev, xc, yc, pos = dsb_get_coords(x)
				local numthings = 0
				local thinghere = dsb_fetch(lev, xc, yc, pos)
				if (thinghere) then
					for th in pairs(thinghere) do
						local th_arch = dsb_find_arch(thinghere[th])
						if (thinghere[th] == x or
							(th_arch.type == "WALLITEM" or th_arch.class == "MECHANICS")) 
						then
							numthings = numthings + 1
						end
					end
				end
				if (numthings > 1) then
					exvar[x].GET_RID_OF_ME = true
				end
			end
			
			-- This is sort of a hack
			if (exvar[x].REVEAL_LOCAL) then
				local lev, xc, yc, pos = dsb_get_coords(x)
				local thinghere = dsb_fetch(lev, xc, yc, exvar[x].ORIG_POS)
				for th=1,#thinghere do
					local id = thinghere[th]
					if (id ~= x) then
						local th_arch = dsb_find_arch(id)
						if (th_arch.type == "WALLITEM") then
							dsb_disable(id)
							exvar[x].target = id
							exvar[x].msg = M_ACTIVATE
							break
						end
					end
				end
			end
			
			-- And this is definitely a hack
			if (exvar[x].AMALGAM) then
				local lev, xc, yc, _ = dsb_get_coords(x)
				local pos = exvar[x].ORIG_POS
				
				local swapper = x
				local amal = search_for_arch(lev, xc, yc, pos, "amalgam")
				local amal_pow = search_for_arch(lev, xc, yc, pos, "amalgam_gembare")
				local firestaff = search_for_arch(lev, xc, yc, pos, "firestaff_gem")
				
				if (amal and amal_pow and firestaff) then
					dsb_disable(amal_pow)
					exvar[amal] = { opby = "zokathra", destroy = true, disable_self = true, silent = true,
						msg = { M_ACTIVATE, M_DEACTIVATE }, target = { amal_pow, amal } }
					exvar[amal_pow] = { opby = "firestaff", disable_self = true,
						msg = { M_ACTIVATE, M_DEACTIVATE }, target = { swapper, amal_pow } }
					exvar[swapper] = { arch = "firestaff_gem", target_opby = true, full_swap = true }
					dsb_delete(firestaff)
				end
				
			end
			
			if (exvar[x].msg and not exvar[x].target) then
				exvar[x].msg = nil
			end
		end
		
		for x in pairs(exvar) do	
			exvar[x].ORIG_POS = nil
			exvar[x].TARGETABLE = nil
			exvar[x].TARGETABLE_OFFCENTER = nil
			exvar[x].TARGET_SQUARE = nil
			exvar[x].TARGET_POS = nil
			exvar[x].OBJECT_HOLDER = nil
			exvar[x].TELEPORTER = nil
			exvar[x].SHOOTER = nil
			exvar[x].LOCAL_ACTION = nil
			exvar[x].OBJECT_TRIGGER = nil
			exvar[x].ORIGINAL_INDEX = nil
			exvar[x].GRAPHIC_ARCH = nil
			exvar[x].FLOOR_TEXT = nil
			exvar[x].RANDOM_DECO = nil
			exvar[x].REVEAL_LOCAL = nil
			exvar[x].AMALGAM = nil
			if (exvar[x].GET_RID_OF_ME) then
				dsb_delete(x)
			end
		end
		
		-- Fix champion inventories
		dungeon_translate(true)
		
	end,
	
	do_indirection = function(idt_id)
		local idt_tbl = dd.it[idt_id]
		return dd.db[idt_tbl.db][idt_tbl.v], idt_tbl.pos, { db = idt_tbl.db, key = idt_tbl.v }
	end,
	
	spawn_itemlist = function(ptable, itemlist, lev, x, y, upos)
		while (itemlist and (itemlist ~= EMPTY)) do
			local here, pos, i_info = convert.do_indirection(itemlist)
			local zone_pos = nil
			
			if (lev >= 0) then
				map_x = x - dd.offsets[lev][1]
				map_y = y - dd.offsets[lev][2]
			else 
				map_x = x
				map_y = y
			end
						
			if (here ~= nil) then
				if (here.disabled and ptable.roomType ~= "STONE") then
					-- Re-init it as a monster generator if a timer is going to make it such
					if (dd.timer65targets[map_x+(map_y*100)+(lev*10000)]) then
						convert.actuator.MonsterGenerator(here.monster_generator)
						here, pos, i_info = convert.do_indirection(itemlist)
					end
				end
	
				-- Must be an actuator, determine its graphic now
				local graphic_arch = nil
				if (here.graphic and here.graphic > 0) then
					if (ptable.roomType == "STONE") then
						local deco_num = dd.deco_info[lev].walls[here.graphic]
						graphic_arch = arch_names.wall_deco[deco_num + 1]
					else
						local deco_num = dd.deco_info[lev].floors[here.graphic]
						graphic_arch = arch_names.floor_deco[deco_num + 1]
					end
				end
				-- Some actuators just are their graphics, no fancy stuff
				if (here.direct == true) then
					-- Alcoves work differently in DSB
					if (obj[graphic_arch].drop_zone) then
						zone_pos = pos
						here.arch = "trigger"
						here.converted_alcove = true
					else
						here.arch = graphic_arch
						graphic_arch = nil
					end
				end
				-- Failsafe
				if (not here.arch) then
					here.arch = "x_relay"
				end
				
				-- Spawn the graphic
				local gid = nil
				if (graphic_arch) then
					local gpos = pos
					local garch = obj[graphic_arch]
					if (garch.type == "FLOORFLAT") then
						gpos = CENTER
					end
					
					if (not dd.got_graphic[gpos+(map_x*5)+(map_y*500)+(lev*50000)]) then
						gid = dsb_spawn(graphic_arch, lev, x, y, gpos)
						dd.got_graphic[gpos+(map_x*5)+(map_y*500)+(lev*50000)] = gid
					end
				end
				
				local hide = false
				local make_targetable = false
				local make_offcenter_targetable = false
				local door_info = nil			
				-- Figure out what my door is
				if (ptable.roomType == "DOOR" and here.door == true) then
					local doortype_id = dd.doors[lev][here.pt.type + 1]
					local door_arch = arch_names.basic_doors[doortype_id]
					
					if (here.pt.ornat and here.pt.ornat > 0) then
						local deco_id = dd.deco_info[lev].doors[here.pt.ornat]
						local deco_name = arch_names.deco_doors[deco_id + 1]
						
						if (obj[deco_name]) then
							door_arch = deco_name
						elseif (obj[door_arch .. deco_name]) then
							door_arch = door_arch .. deco_name
						else
							esb_information("Unsupported door deco " .. door_arch .. deco_name)
						end
					end					
					here.arch = door_arch
					make_targetable = true
					
					door_info = { }
					if (here.pt.openWithFireball) then
						door_info.fire_power = 20
					elseif (obj[door_arch].fire_power) then
						door_info.fire_power = 9999
					end
					if (here.pt.openWithAxe) then
						door_info.bash_power = 20
					elseif (obj[door_arch].bash_power) then
						door_info.bash_power = 9999
					end				
				end
				
				-- Convert text items
				local textindex = nil
				local floortext = nil
				if (here.text == true) then
					if (dsb_get_cell(lev, x, y)) then
						here.arch = "wallwriting"
						make_offcenter_targetable = true
					else
						here.arch = "floortext"
						floortext = true
					end
					if (not here.show) then
						hide = true
					end
					textindex = here.textindex
				elseif (here.arch == "scroll") then
					local ti = here.text_indirect_index
					local textnum = convert.do_indirection(ti)
					if (textnum.text) then
						textindex = textnum.textindex
					end
				end
				
				local curse_object = false
				if (here.cursed) then
					curse_object = true
				end
				
				local sarch = obj[here.arch]
				
				-- If we have a forced position, then use that
				local orig_pos = pos
				if (upos) then
					pos = upos
				else
					if (zone_pos) then
						pos = zone_pos
					elseif (sarch.type == "FLOORFLAT" or sarch.type == "DOOR") then
						pos = CENTER
					end
				end
								
				-- Here we spawn the object and then carry out various hacks
				-- for converting between CSB and DSB representations of objects
				local new_id, second_id 
				if (sarch.type == "MONSTER") then
					new_id = convert.spawn_monstergroup(here, sarch, lev, x, y)
				else
					new_id = dsb_spawn(here.arch, lev, x, y, pos)
				end
				
				if (sarch.type == "DOOR") then
					if (here.pt.switch) then
						local bid = dsb_spawn("doorbutton", lev, x, y, CENTER)
						exvar[bid] = { target = new_id }
					end
					if (not ptable.flags.closed) then
						hide = true
					end
					exvar[new_id] = door_info
				end
				
				if (ptable.roomType == "TELEPORTER" and here.arch == "teleporter") then
					if (ptable.flags.visible == true) then
						second_id = dsb_spawn("bluehaze", lev, x, y, CENTER)
						exvar[second_id] = { TARGETABLE = true }
					end
					if (ptable.flags.active == false) then
						hide = true
					end
					local tlev = here.pt.target[1]
					exvar[new_id] = { TELEPORTER = true,
						lev = tlev,
						x = here.pt.target[2] + dd.offsets[tlev][1],
						y = here.pt.target[3] + dd.offsets[tlev][2]
					}
					if (not here.pt.audible) then exvar[new_id].silent = true end
					if (here.pt.party) then exvar[new_id].opby_party = true end
					if (here.pt.monsters) then exvar[new_id].opby_monster = true end
					if (here.pt.objects) then exvar[new_id].opby_thing = true end
					
					make_targetable = true
					
					local face = here.pt.face
					if (face >= 0) then
						exvar[new_id].face = face
					elseif (face ~= -1) then
						exvar[new_id].spin = (face + 1) * -1
					end
				end
				
				if (i_info.db == DB_POT) then
					local base_power = here.strength
					if (not base_power or base_power < 1) then base_power = 0 end
					local disp_power = math.floor(base_power/40)
					if (disp_power < 1) then disp_power = 1 end
					
					exvar[new_id] = { power = disp_power, base_power = base_power }
					exvar[new_id].ORIGINAL_INDEX = i_info.key
				
				elseif (i_info.db == DB_ACT) then
					exvar[new_id] = convert.tbl_pt_to_exvars(here, lev, x, y)
					if (exvar[new_id]) then
						exvar[new_id].ORIG_POS = orig_pos
					end
				end
				
				-- Amalgam hack to make DM work right
				if (CONVERTING_FROM == "DM") then
					if (here.swapobject) then
						if (graphic_arch == "amalgam_gembare") then
							exvar[new_id].AMALGAM = true
						end
					end
				end
					
				if (curse_object) then
					use_exvar(new_id)
					exvar[new_id].shortdesc = "CURSED"
					exvar[new_id].cursed = true
				end
				
				if (make_targetable) then
					use_exvar(new_id)
					exvar[new_id].TARGETABLE = true
				elseif (make_offcenter_targetable) then
					use_exvar(new_id)
					exvar[new_id].TARGETABLE_OFFCENTER = true
				end
				
				if (textindex) then
					use_exvar(new_id)
					exvar[new_id].text = dd.text[textindex]
					if (floortext) then
						exvar[new_id].FLOOR_TEXT = true
					end
				end
				
				if (hide) then
					dsb_disable(new_id)
					if (second_id) then dsb_disable(second_id) end
				end
				
				if (graphic_arch) then
					use_exvar(new_id)
					exvar[new_id].GRAPHIC_ARCH = graphic_arch
				end
					
				if (here.contents and here.contents ~= EMPTY) then
					local insidelist = here.contents
					convert.spawn_itemlist(ptable, insidelist, IN_OBJ, new_id, -1, 0)
				end
				
				itemlist = here.link
			else
				itemlist = EMPTY
			end
		end	
	
	end,
	
	spawn_monstergroup = function(here, sarch, lev, x, y)
		local new_id
		local num = here.pt.numMonster
		for mn=1,num do
			local mpos = here.pt.positions[mn]
			if (here.pt.positions.center) then mpos = CENTER end
			new_id = dsb_spawn(here.arch, lev, x, y, mpos)
			mon_hp(new_id, here.pt.hitpoints[mn])
		end
		
		return new_id
	end,
	
	random_deco = function(lev, xx, yy, num_deco, prob)
		local random_seed = 13
		local hash1 = (2000 + xx*32 + yy) % 65536
		local hash2 = (3000 + lev*64 + dd.width[lev] + dd.height[lev]) % 65536
					
		-- copied out of CSBwin
		local hashval = (hash1 * 31417) / 2
		hashval = math.floor(hashval) % 32768
		hashval = hashval + (hash2 * 11)
		hashval = hashval + random_seed
		hashval = math.floor(hashval / 4) % 16384
		hashval = hashval % prob

		if (hashval < num_deco) then
			return hashval
		end			
		return nil
	end,
	
	tbl_pt_to_exvars = function(h, lev, x, y)
		local exv = { }
		local tarch = obj[h.arch]
		local ptable = h.pt
		
		local monster_generator = false
		local trigger = false
		
		if (not ptable) then return nil end
		
		exv.ORIGINAL_INDEX = ptable.index
		
		if (type(ptable.target) == "table") then
			exv.TARGET_SQUARE = { lev,
				ptable.target[1] + dd.offsets[lev][1],
				ptable.target[2] + dd.offsets[lev][2] 
			}
			exv.TARGET_POS = ptable.target[3]
		end
		
		if (h.endgame) then
			exv.m_a = "csb_win_game"
		end
		
		if (h.arch == "trigger") then
			trigger = true	
			if (ptable.sound == true) then
				exv.sound = "click"
			end
		elseif (h.arch == "counter") then
			exv.count = ptable.value
			exv.disable_self = true
		elseif (h.arch == "shooter") then
			local stype = ptable.type
			if (stype == 14 or stype == 15) then
				exv.shoot_square = true
			elseif (stype == 7 or stype == 9) then
				local mtype = ptable.missileType
				if (mtype >= 4 and mtype <= 7) then
					exv.shoots = "torch"
				elseif (mtype == 32) then
					exv.shoots = "dagger"
				elseif (mtype == 51) then
					exv.shoots = "arrow"
				elseif (mtype == 54) then
					exv.shoots = "rock"
				end
			else
				local mtype = ptable.missileType
				if (mtype == 0) then
					exv.shoots = "fireball"
				elseif (mtype == 1) then
					exv.shoots = "poison_slime"
				elseif (mtype == 2) then
					exv.shoots = "lightning" 
				elseif (mtype == 3) then
					exv.shoots = "desewspell"
				elseif (mtype == 4 or mtype == 5) then
					exv.shoots = "zospell"
				elseif (mtype == 6) then 
					exv.shoots = "poison_desven"
				elseif (mtype >= 7) then
					exv.shoots = "poison_ohven"
				end
			end
			if (stype == 9 or stype == 10 or stype == 15) then
				exv.double = true
			end
			exv.power = ptable.energy
			exv.SHOOTER = true
			exv.TARGETABLE_OFFCENTER = true
		end
		
		if (ptable.monsterType) then
			exv.generates = arch_names.monsters[ptable.monsterType + 1]
			
			local minmax = ptable.num
			if (minmax > 8) then
				minmax = minmax - 8
				exv.min = 1
				exv.max = minmax
			else
				exv.min = minmax
			end
			
			if (ptable.hpMult > 0) then
				exv.multiplier = ptable.hpMult
			end
			
			monster_generator = true
		end
		
		if (ptable.OO) then
			if (monster_generator) then
				exv.count = 1
			else
				exv.disable_self = true
			end
		end
		
		if (ptable.NC) then
			exv.off_trigger = true
		end
		
		-- The action of an object holder
		if (ptable.localaction) then
			-- Always rotate!
			exv.func = "csb_local_rotate"
			
			-- Localaction = 1 means release activates underlying trigger, or something?
			if (ptable.localaction == 1) then
				exv.LOCAL_ACTION = true
			end
			
			if (exv.action == 0) then
				exv.msg = M_ACTIVATE
			elseif (exv.action == 1) then
				exv.msg = M_DEACTIVATE
			else
				exv.msg = M_TOGGLE
			end
			exv.take_release_only = true
			exv.OBJECT_HOLDER = true
		end
		
		if (ptable.isLocal == true) then
			exv.REVEAL_LOCAL = true
		end
					
		local msg = ptable.msg
		if (msg == "Set") then
			exv.msg = M_ACTIVATE
		elseif (msg == "Clear") then
			exv.msg = M_DEACTIVATE
		elseif (msg == "Toggle") then
			exv.msg = M_TOGGLE
		elseif (msg == "Hold") then
			if (ptable.NC) then
				exv.off_trigger = nil
				exv.msg = M_DEACTIVATE
				exv.const_weight = true
			else
				exv.msg = M_ACTIVATE
				exv.const_weight = true
			end
		elseif (msg == "LocalAction") then
			exv.func = "csb_local_rotate"
		end
		
		-- Get bits used by and/or
		if (ptable.Initial and ptable.Final) then
			exv.bit_i = convert.val_to_bits(ptable.Initial)
			exv.bit_t = convert.val_to_bits(ptable.Final)
			-- Same idea
			if (exv.const_weight) then
				exv.send_reverse = true
				exv.const_weight = nil
			elseif (msg == "Toggle" and ptable.NC) then
				exv.send_reverse = true
				exv.send_reverse_only = true
				exv.off_trigger = nil
			end
		end
		
		-- Counter reverses
		if (h.arch == "counter") then
			if (not exv.const_weight) then
				exv.no_reverse = true
			end
			exv.const_weight = nil
		end
		
		local button_type = nil
		local object_opby = true
		if (h.pushbutton and ptable.type) then
			button_type = ptable.type
		end
		if (button_type == "SwitchAnything") then
			object_opby = false
		elseif (button_type == "SwitchHand") then
			object_opby = false
			exv.opby_empty_hand_only = true
		end
		
		if (tarch.class == "TRIGGER") then
			exv.OBJECT_TRIGGER = true
		end
		
		if (ptable.type == "AlcoveAnything") then
			object_opby = false
			if (h.converted_alcove) then
				exv.opby_thing = true
			end
		end
		
		if (ptable.object and object_opby) then
			if (ptable.value >= 0) then
				exv.opby = CSB2DSB[ptable.object]
				if (button_type == "LockRemove") then
					exv.destroy = true
				end
			end
		elseif (ptable.OpBy and ptable.OpBy.object) then
			exv.opby = CSB2DSB[ptable.OpBy.object]
		end
		
		if (exv.opby) then
			if (obj[exv.opby .. "_x"]) then
				exv.opby_suffix = "_x"
			elseif (obj[exv.opby .. "_cursed"]) then
				exv.opby_suffix = "_cursed"
			end
		end
		
		if (ptable.OpBy) then			
			if (ptable.OpBy.what == "PartyMovesOnOrOff") then
				exv.opby_party = true
			elseif (ptable.OpBy.what == "PartyMovesOrTurnsNorth") then
				exv.opby_party = true
				exv.opby_party_face = 0
				exv.wrong_direction_untrigger = true
			elseif (ptable.OpBy.what == "PartyMovesOrTurnsEast") then
				exv.opby_party = true
				exv.opby_party_face = 1
				exv.wrong_direction_untrigger = true
			elseif (ptable.OpBy.what == "PartyMovesOrTurnsSouth") then
				exv.opby_party = true
				exv.opby_party_face = 2
				exv.wrong_direction_untrigger = true
			elseif (ptable.OpBy.what == "PartyMovesOrTurnsWest") then
				exv.opby_party = true
				exv.opby_party_face = 3
				exv.wrong_direction_untrigger = true
			elseif (ptable.OpBy.what == "Object") then
				if (not exv.opby) then
					exv.opby_thing = true
				end
			elseif (ptable.OpBy.what == "Monster") then
				exv.opby_monster = true
			elseif (ptable.OpBy.what == "Party/Monster") then
				exv.opby_party = true
				exv.opby_monster = true
			elseif (ptable.OpBy.what == "anything") then
				exv.opby_party = true
				exv.opby_monster = true
				exv.opby_thing = true
			elseif (ptable.OpBy.what == "PartyPossesses") then
				exv.opby_party_carry = exv.opby
				exv.opby = nil
				if (ptable.NC) then
					if (msg ~= "Hold") then
						exv.except_when_carried = true
						exv.off_trigger = nil
					end
				end
			end
		end
		
		if (ptable.delay and ptable.delay > 0) then
			if (monster_generator) then 
				if (ptable.delay > 127) then
					exv.regen = (ptable.delay-126)*64
				else
					exv.regen = ptable.delay
				end
			else
				exv.delay = ptable.delay
			end
		end
			
		if (tarch.class ~= "TRIGGER") then
			exv.TARGETABLE = true
		end
		
		if (exv == { }) then
			return nil
		end
		return exv
	end,
	
	fix_floortext_slashes = function(str)
		local strtbl = dsb_linesplit(str, "/")
		local outputstr = ""
		for i=1,#strtbl,3 do
			if (strtbl[i+2]) then
				outputstr = outputstr .. strtbl[i] .. " " .. strtbl[i+1] .. " " .. strtbl[i+2]
			elseif (strtbl[i+1]) then
				outputstr = outputstr .. strtbl[i] .. " " .. strtbl[i+1]
			else
				outputstr = outputstr .. strtbl[i]
			end
			if (strtbl[i+3]) then
				outputstr = outputstr .. "/"
			end
		end
		return outputstr
	end,
	
	val_to_bits = function(val)
		local bits = { false, false, false, false }
		for c=4,1,-1 do
			local pow2 = math.pow(2,(c-1))
			if (val >= pow2) then
				val = val - pow2
				bits[c] = true
			end
		end	
		return bits
	end,
	
	text_to_character = function(str)
		local strtbl = dsb_linesplit(str, "/")
		local hsm = dsb_textconvert_numbers(strtbl[5], 3, 4) 
		local stat = dsb_textconvert_numbers(strtbl[6], 7, 2)
		for i=1,7 do
			stat[i] = stat[i]*10
		end
		
		local subxp = dsb_textconvert_numbers(strtbl[7], 16, 1)
		for i=1,16 do
			if (subxp[i] > 0) then
				subxp[i] = 125*(2 ^ subxp[i])
			end
		end
		local mainxp = { }
		for i=1,4 do
			local total = 0
			local offset = (4*i)-3
			for subn=0,3 do
				total = total + subxp[offset + subn]
			end
			mainxp[i] = total
		end
		
		local portname = "port_" .. string.gsub(string.lower(strtbl[1]), " ", "")
		local chid = dsb_add_champion(portname, strtbl[1], strtbl[2] .. strtbl[3],
			hsm[1]*10, hsm[2], hsm[3]*10, stat[1], stat[2], stat[3], stat[4], stat[5], stat[6], stat[7], 0, 0, 0, 0)
		
		for cl=0,3 do
			dsb_set_xp(chid, cl, 0, mainxp[cl+1])
			for s=1,4 do
				local offset = cl*4
				dsb_set_xp(chid, cl, s, subxp[offset+s])
			end
		end
			
		return chid
	end
}

if (CONVERTING_FROM == "CSB") then
	lua_manifest = { "csb.lua" }
else
	lua_manifest = { "dm.lua" }
end
