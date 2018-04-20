-- Editor configuration file  
-- This is where information on how to draw various objects
-- in the editor is found. You can customize this and make
-- the display more to your liking, or add information to
-- draw your custom dungeons better.

-- If you want to make something that can be more easily
-- redistributed, ESB will automatically attempt to parse
-- an optional file named editor/custom.lua, as well.


-- Flags
EEF_NOLIMBOSAVE  = 1
EEF_FLOORLOCK = 2
EEF_ALCOVE = 4
EEF_PITS = 8
EEF_DOORFRAME = 16

function esb_typecheck(arch, arch_name, check_name)
	if (arch_name == check_name) then
	    return true
	elseif (arch and arch.esb_name) then
		if (arch.esb_name == check_name) then
		    return true
		end
	end
	return false
end

-- This gives a bitmap number and a draw order for every
-- arch that might be found in a dungeon
function editor_drawnumber(arch_name, dir, inactive, tile)
	local arch = obj[arch_name]
	
	if (arch.esb_drawinfo) then
		if (type(arch.esb_drawinfo) == "function") then
			return (arch:esb_drawinfo(dir, inactive, tile))
		elseif (type(arch.esb_drawinfo) == "table") then
			return arch.esb_drawinfo[1], arch.esb_drawinfo[2], arch.esb_drawinfo[3], arch.esb_drawinfo[4]
		end
		return arch.esb_drawinfo, 20
	end

	if (esb_typecheck(arch, arch_name, "stairsdown")) then
		return 2, 0
	elseif (esb_typecheck(arch, arch_name, "stairsup")) then
		return 3, 0
	elseif (esb_typecheck(arch, arch_name, "ipit")) then
		if (inactive) then return 61, 0
		else return 60, 0 end
	elseif (arch.class == "PIT") then
		if (inactive) then return 5, 0
		else return 4, 0 end
	elseif (arch.class == "PIT_FAKE") then
		if (inactive) then return 69, 0
		else return 68, 0 end
	elseif (esb_typecheck(arch, arch_name, "ceiling_pit")) then
		return 46, 0
	elseif (esb_typecheck(arch, arch_name, "bluehaze")) then
		if (inactive) then return 7, 10
		else return 6, 10 end
	elseif (esb_typecheck(arch, arch_name, "firepit")) then
		return 8, 0		
	elseif (esb_typecheck(arch, arch_name, "rounddrain")) then
		return 9, 0
	elseif (esb_typecheck(arch, arch_name, "squaredrain")) then
		return 10, 0
	elseif (esb_typecheck(arch, arch_name, "floorslime")) then
		return 11, 0
	elseif (esb_typecheck(arch, arch_name, "puddle")) then
		return 12, 0
	elseif (esb_typecheck(arch, arch_name, "floorcrack")) then
		return 23, 0
	elseif (esb_typecheck(arch, arch_name, "monster_generator")) then
		return 25, 20
	elseif (esb_typecheck(arch, arch_name, "function_caller")) then
		return 45, 7
	elseif (esb_typecheck(arch, arch_name, "ambient_sound")) then
		return 47, 20
	elseif (esb_typecheck(arch, arch_name, "counter")) then
		return 57, 20
	elseif (esb_typecheck(arch, arch_name, "x_counter")) then
		return 57, 20
	elseif (esb_typecheck(arch, arch_name, "monster_blocker")) then
		if (inactive) then return 63, 10
		else return 62, 10 end
	elseif (esb_typecheck(arch, arch_name, "floordamager")) then
		if (inactive) then return 65, 2
		else return 64, 2 end		
	elseif (esb_typecheck(arch, arch_name, "movablewall")) then
		if (inactive) then return 15, 2
		else return 14, 1 end		
	elseif (esb_typecheck(arch, arch_name, "fakewall")) then
		return 59, 1
 	elseif (esb_typecheck(arch, arch_name, "invisiblewall")) then
		return 74, 0
	elseif (esb_typecheck(arch, arch_name, "floortext")) then
		return 66, 1
	elseif (esb_typecheck(arch, arch_name, "msg_sender")) then
		return 67, 1
	elseif (esb_typecheck(arch, arch_name, "x_relay")) then
		return 67, 1
	elseif (esb_typecheck(arch, arch_name, "qswapper")) then
		return 70, 0
	elseif (esb_typecheck(arch, arch_name, "sequencer")) then
		return 71, 2
	elseif (esb_typecheck(arch, arch_name, "item_action")) then
		return 72, 2
	elseif (esb_typecheck(arch, arch_name, "probability")) then
		return 73, 2
	elseif (esb_typecheck(arch, arch_name, "trigger_controller")) then
		return 73, 2
	elseif (arch.class == "DOORFRAME") then
		return 16, 6
	elseif (arch.class == "DOORBUTTON") then
		return 17, 8		
	elseif (arch.class == "TRIGGER") then
		if (inactive) then return 56, 25
		else return 24, 25 end
	elseif (arch.class == "TELEPORTER") then
		if (inactive) then return 58, 20
		else return 26, 20 end
		
	elseif (arch.type == "DOOR") then

		if (arch.class == "PORTCULLIS") then
			return 19, 10
		elseif (arch.class == "METAL") then
			return 20, 10
		elseif (arch.class == "BLACK") then
			return 21, 10
		elseif (arch.class == "RA") then
			return 22, 10
		else
			return 18, 10
		end
		
	elseif (arch.type == "WALLITEM") then
		if (arch.class ~= "DECO") then
			if (arch.class == "ALCOVE") then
				return (52+dir), 5
			else
				return (32+dir), 3
			end
		else
			return (48+dir), 4
		end
		
	elseif (arch.type == "THING") then
		if (tile) then return (36+dir), 150
		else return (28+dir), 150 end
			
	elseif (arch.type == "MONSTER") then
		return (40+dir), 150
	elseif (arch.type == "FLOORFLAT") then
		return 13, 1
	elseif (arch.type == "FLOORUPRIGHT") then
		return 27, 3
	end
	
	return nil, nil
end

-- Depending on what is being spawned, ESB will try to help out by
-- creating some exvars that you'll probably want to use, and do other
-- manipulations of the objects in the dungeon.
function editor_spawn(arch_name, level, x, y, dir)
	local arch = obj[arch_name]

	if (arch.type == "DOOR" or arch.class == "DOORBUTTON" and
		esb_bitflag(EDITOR_FLAGS, EEF_DOORFRAME))
	then
		local df = search_for_class(level, x, y, CENTER, "DOORFRAME")
		if (not df) then
			dsb_spawn("doorframe", level, x, y, CENTER)
		end
	end

	-- Actually spawn the requested object
	local id = dsb_spawn(arch_name, level, x, y, dir)
	
	-- Make sure movable wall objects are actually on walls
	if (esb_typecheck(arch, arch_name, "movablewall")) then
		dsb_set_cell(level, x, y, true)
	end
	
	-- And that invisible walls are also actually walls
	if (esb_typecheck(arch, arch_name, "invisiblewall")) then
		dsb_set_cell(level, x, y, true)
	end
	
	-- And sure fake wall objects are actually not walls
	if (esb_typecheck(arch, arch_name, "fakewall")) then
		dsb_set_cell(level, x, y, false)
	end
	
	-- Potions need this exvar or they show up as "FIX ME" in DSB
	if (arch.class == "POTION" or arch.class == "BOMB") then
		exvar[id] = { power = 1 }
	end
	
	-- Automatically link a doorbutton to a door on its tile
	if (arch.class == "DOORBUTTON") then
		local mydoor = search_for_type(level, x, y, CENTER, "DOOR")
		if (mydoor) then
			exvar[id] = { target = mydoor }
		end
	end	
	
	-- If there's a "full" sconce, put a torch in it
	if (esb_typecheck(arch, arch_name, "sconce_full")) then
		dsb_spawn("torch", IN_OBJ, id, 0, 0)
		exvar[id] = { release = true }
	end
	
	-- Warn about a pit on the bottom level of the dungeon
	if (arch.class == "PIT") then
		if (esb_bitflag(EDITOR_FLAGS, EEF_PITS) and level == ESB_LAST_LEVEL) then
			esb_information("Pit is on bottom level!")
		end
	end 
	
	-- Things don't go "in" drop zones
	if (esb_bitflag(EDITOR_FLAGS, EEF_ALCOVE) and level == IN_OBJ) then
		local conarch = dsb_find_arch(x)
		if (conarch.drop_zone) then
			local nl, nx, ny, nd = dsb_get_coords(x)
			if (nl >= 0) then
				esb_information("Instance " .. id .. " of type " ..
					arch_name .. " was automatically\n" .. "moved outside of this drop_zone.")
				dsb_move(id, nl, nx, ny, nd)
			end
		end
	end	
	-- And drop zones must be below all things that they contain
	if (esb_bitflag(EDITOR_FLAGS, EEF_ALCOVE) and arch.drop_zone) then
		local thing = 1
		local thinglist = { }
		local thingn = 0
		while (thing) do
			thing = search_for_type(level, x, y, dir, "THING")
			-- pull it out of order...
			if (thing) then
				dsb_move(thing, LIMBO, 0, 0, 0)
				thingn = thingn + 1
				thinglist[thingn] = thing 
			end
		end
		if (thingn > 0) then
			-- ... and drop it back in at the end
			for count=1,thingn do
				dsb_move(thinglist[count], level, x, y, dir)
			end
		end
	end
	
	-- Mostly nonsense parameters but it at least shows how the arch works
	if (esb_typecheck(arch, arch_name, "monster_generator")) then
		exvar[id] = { generates = "mummy", min = 1, max = 4, regen = 5000 }
	end
	
	if (esb_typecheck(arch, arch_name, "qswapper")) then
		exvar[id] = { arch = "apple" }
	end
	
	if (esb_typecheck(arch, arch_name, "shooter")) then
		exvar[id] = { power = 60 }
	end
	
	if (esb_typecheck(arch, arch_name, "counter")) then
		exvar[id] = { count = 2 }
	end
	
	if (esb_typecheck(arch, arch_name, "floordamager")) then
		exvar[id] = { dmg_type = 0, dmg_amt = 1 }
	end
	
	-- Set up some default opbys for keyhole types
	if (arch.class == "KEYHOLE") then
		local opby_item
		if (esb_typecheck(arch, arch_name, "coinslot")) then
			opby_item = "coin_gor"
		elseif (esb_typecheck(arch, arch_name, "gemhole")) then
			opby_item = "gem_green"
		else
			local splitchar = string.find(arch_name, "_")
			local kt = nil
			if (splitchar) then
				kt = "key_" .. string.sub(arch_name, splitchar+1)
			end
			if (kt and obj[kt]) then opby_item = kt
			else opby_item = "key_iron" end				
		end
		exvar[id] = { opby = opby_item, destroy = true, disable_self = true }
	end
	
	if (arch.class == "WRITING" or arch.class == "SCROLL") then
		exvar[id] = { text = "EDIT ME" }
	end
	
	-- So custom code doesn't have to duplicate all this.
	if (user_spawn) then
		user_spawn(arch_name, id, level, x, y, dir)
	end
	
	-- This is necessary! Otherwise the editor won't know the id of the
	-- spawned inst and everything grinds to a horrible halt.
	return id
end

-- Performs helpful functions when an instance is activated
function editor_inst_activate(id, arch_name)
	if (esb_typecheck(arch, arch_name, "movablewall")) then
		local lev, x, y = dsb_get_coords(id)
		dsb_set_cell(lev, x, y, true)
	end
end

-- Performs helpful functions when an instance is deactivated
function editor_inst_deactivate(id, arch_name)
	if (esb_typecheck(arch, arch_name, "movablewall")) then
		local lev, x, y = dsb_get_coords(id)
		dsb_set_cell(lev, x, y, false)
	end
end

function editor_check_taketargets(arch_name)
	local arch = obj[arch_name]
	local noclick_wallitem_class = {
	    WRITING = true,
	    SHOOTER = true,
	    MECHANICS = true
	}
	    
	if (arch.class == "CHAMPION_HOLDER") then
	    return 1
	elseif (arch.type == "WALLITEM" and not noclick_wallitem_class[arch.class]) then
		return 2
	elseif (arch.class == "STAIRS" or arch.class == "TRIGGER") then
		return 2
	elseif (arch.class == "DOORBUTTON") then
	    return 1
	elseif (arch.esb_take_opby_targets) then
		return 2
	elseif (arch.esb_take_targets) then
		return 1
	elseif (arch.esb_targ_draw_color) then
		return 1
	end
	return false 
end

-- Determines the color to draw a msg line
function editor_msg_draw_color(msg)
	if (ed_draw_color[msg]) then
		return ed_draw_color[msg]
	elseif (msg < 100000) then
		return { 192, 32, 192 }
	else
		return { 192, 192, 192 }
	end
end
ed_draw_color = {
	[M_ACTIVATE] = { 220, 64, 64 },
	[M_DEACTIVATE] = { 32, 192, 32 },
	[M_TOGGLE] = { 220, 120, 32 },
	[M_NEXTTICK] = { 150, 150, 48 },
	[M_RESET] = { 192, 220, 32 },
	[M_CLEANUP] = { 64, 255, 192 },
	[M_EXPIRE] = { 120, 64, 32 },
	[M_DESTROY] = { 78, 78, 78 }
} 

important_exvars = {
	"count", "delay", "msg", "target", "data", "func", "func_data", "arch",
	"m_a", "m_d", "m_t", "m_n", "generates", "min", "max", "lev", "x", "y",
	"opby", "opby_class", "opby_id", "opby_party", "opby_party_face", "opby_thing",
	"opby_monster", "opby_empty_hand_only", "opby_party_carry", "except_when_carried",
	"destroy", "disable_self", "const_weight",
	"text", "shoots", "power", "sound", "regen", "double", "bit_i", "bit_t"
}