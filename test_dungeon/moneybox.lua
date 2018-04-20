--- moneybox.lua ---
-- This is an example how to create an importable archetype,
-- that any DSB dungeon can then load via dsb_import_arch(file, root_name).
-- All you have to distribute is this single Lua file, and any
-- bitmaps that the new object needs.
--
-- The names used by the data structures created here should be
-- dynamically generated, using the ROOT_NAME variable that
-- will be defined by the engine when this file is parsed.
-- This helps to prevent name collisions if the dungeon designer
-- wants to use several similarly named items.

-- Load any graphics that your custom object will need.
-- Temporary bitmaps should be declared local so the garbage collector
-- will be able to take care of them.
--
gfx[ROOT_NAME] = dsb_get_bitmap("MONEYBOX")
gfx[ROOT_NAME .. "_icon"] = dsb_get_bitmap("MONEYBOX_ICON")
gfx[ROOT_NAME .. "_alticon"] = dsb_get_bitmap("MONEYBOX_ALTICON")
gfx[ROOT_NAME .. "_inside"] = dsb_get_bitmap("MONEYBOX_INSIDE")

--
-- Now define any functions that your custom object will need.
--
function moneybox_click(id, zone, mouseobj)
	local self = dsb_find_arch(id)
	local targarch = obj[self.zone_obj[zone+1]]
	
	local mousearch = nil
	if (mouseobj) then
		mousearch = dsb_find_arch(mouseobj)
	end
	if (mousearch and mousearch ~= targarch) then return false end
	
	if (mouseobj) then
		dsb_move(dsb_pop_mouse(), IN_OBJ, id, VARIABLE, 0)
	else
		local iobj
		for iobj in dsb_in_obj(id) do
			local iarch = dsb_find_arch(iobj)
			if (iarch == targarch) then
				dsb_push_mouse(iobj)
				return true
			end
		end
	end 
end

function moneybox_subrenderer(self, id)
	local zcs = {
		{x = 34, y = 4},
		{x = 94, y = 4},
		{x =154, y = 4},
		{x = 34, y =74},
		{x = 94, y =74},
		{x =154, y =74}
	}
	
	local ninside = { 0, 0, 0, 0, 0, 0 }

	local sr = dsb_subrenderer_target()
	
	use_exvar(id)
	if (not exvar[id].draw_seed) then
		exvar[id].draw_seed = dsb_rand(8, 1023)
	end
	local ds = exvar[id].draw_seed
	
	dsb_bitmap_clear(sr, base_background)
	dsb_bitmap_draw(self.inside_gfx, sr, 30, 0, false)
	
	local iobj
	for iobj in dsb_in_obj(id) do
		local iarch = dsb_find_arch(iobj)
		local i
		if (iarch.class == "COIN" or iarch.class == "GEM") then
			for i=1,6 do
				if (obj[self.zone_obj[i]] == iarch) then
					ninside[i] = ninside[i] + 1
				end
			end
		end
	end
	
	local i
	for i=1,6 do
		local x = zcs[i].x
		local y = zcs[i].y
		
		dsb_msgzone(sr, id, i-1, zcs[i].x, zcs[i].y, 58, 68, M_NEXTTICK)
		while (ninside[i] > 0) do
			local tx = (ds + 8 * ninside[i]) % 26
			local ty = (ds/2 + 16 * ninside[i]) % 36
			dsb_bitmap_draw(obj[self.zone_obj[i]].icon, sr, x + tx, y + ty, false)
			ninside[i] = ninside[i] - 1
		end
	end
end

--
-- Finally, declare the new arch into the object table, using the
-- dynamic name assigned by the dungeon designer.
--
obj[ROOT_NAME] = {
	name="MONEY BOX",
	type="THING",
	class="CONTAINER",
	mass=11,
	
	dungeon=gfx[ROOT_NAME],
	icon=gfx[ROOT_NAME .. "_icon"],
	alt_icon=gfx[ROOT_NAME .. "_alticon"],
	inside_gfx=gfx[ROOT_NAME .. "_inside"],
	
	msg_handler = {
		[M_NEXTTICK] = moneybox_click
	},
	
	zone_obj = {
		"gem_blue",
		"gem_orange",
		"gem_green",
		"coin_gold",
		"coin_silver",
		"coin_copper"
	},
	
	subrenderer = moneybox_subrenderer,
	
	to_r_hand = alticon,
	from_r_hand = normicon,
	max_throw_power=30
}

