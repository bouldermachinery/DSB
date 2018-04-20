--- dm2table.lua ---
-- This is an importable archetype that attempts to create tables
-- like DM2 had. Unlike the DM2 implementation, objects are contained
-- "inside" of the table objects, leaving the floor drop zones unaffected.
-- This means things can be both on and underneath the table.
-- 
-- For a better documented example of importable archetypes themselves,
-- see moneybox.lua. The documentation in this file is concerned only with
-- demonstrating how to make a DM2-style table.

-- Load the needed bitmaps and position them
gfx[ROOT_NAME] = dsb_get_bitmap("DM2TABLE_FRONT")
gfx[ROOT_NAME].y_off = 16
gfx[ROOT_NAME .. "_alt"] = dsb_get_bitmap("DM2TABLE_FRONT_ALT")
gfx[ROOT_NAME .. "_alt"].y_off = 16
gfx[ROOT_NAME .. "_zone"] = dsb_get_bitmap("DM2TABLE_ZONE")
gfx[ROOT_NAME .. "_zone"].y_off = -74

-- Automatically create the supporting structures when the table spawns
function create_alt_table_and_zones(arch, id, lev, x, y, t)
	local alt_id = dsb_spawn(arch.alt_version, lev, x, y, CENTER)
	dsb_msg_chain(id, alt_id)
	for d=0,3 do
		local zone_id = dsb_spawn(arch.drop_zone, lev, x, y, d)
		dsb_msg_chain(id, zone_id)
		if (arch.auto_place_on_top) then
			dsb_msg(1, zone_id, M_NEXTTICK, 0)
		end
	end
end

-- Define a function to make the table drop zones respond properly to being
-- clicked. The actual take and release functions are part of the base
-- code, we just need to invoke them properly.
function table_zone_click(self, id, what, x, y)
 	if (what) then
 		wallitem_take_object(self, id, what)
 	else
 		wallitem_release_object(self, id, what)
 	end	
end

-- This function takes anything on the tile and places it on the table
function place_items_on_table(id, data)
	local lev, x, y, d = dsb_get_coords(id)
	local obj = dsb_fetch(lev, x, y, d)
	for i in pairs(obj) do
		local obj_arch = dsb_find_arch(obj[i])
		if (obj_arch.type == "THING") then
			dsb_move(obj[i], IN_OBJ, id, VARIABLE, 0)
		end
	end	
end

-- If what is nil then the party is trying to move into the table.
-- Otherwise, it's some sort of inst, so let objects fly over the table.
-- Make sure "no_monsters = true" is set in the table's arch or this code
-- would also let monsters move into it.
function table_collision(arch, id, what)
	if (not what) then
		return true
	end
	
	return false
end

-- The basic table
obj[ROOT_NAME] = {
	type="FLOORUPRIGHT",
	class="TABLE",
	front=gfx[ROOT_NAME],
	col=table_collision,
	viewangle = { true, false, true, false },
	no_monsters = true,
	alt_version = ROOT_NAME .. "_alt",
	drop_zone = ROOT_NAME .. "_zone",
	on_spawn = create_alt_table_and_zones,
	auto_place_on_top = true -- If this is false, items spawn underneath	
}

-- The alternate angle table.
-- It is automatically spawned when the initial table is spawned
obj[obj[ROOT_NAME].alt_version] = clone_arch(obj[ROOT_NAME], {
	front=gfx[ROOT_NAME .. "_alt"],
	viewangle = { false, true, false, true },
	on_spawn = false
} )

-- The table's drop zones.
-- They are automatically spawned when the initial table is spawned
obj[obj[ROOT_NAME].drop_zone] = {
	type="FLOORUPRIGHT",
	class="TABLE",
	front=gfx[ROOT_NAME .. "_zone"],
	clickable=true,
	on_click=table_zone_click,
	draw_contents=true,
	msg_handler = {
		[M_NEXTTICK] = place_items_on_table
	}
}