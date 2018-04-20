--- monstercapture.lua ---
-- This is an importable archetype of a "monster_capturer" which grabs
-- a monster and allows you to release that monster later. It is a rather
-- complicated object, but it serves as a good (if somewhat advanced)
-- tutorial on the creation of new objects with dynamic attack methods.
--
-- For a better documented example of importable archetypes themselves,
-- see moneybox.lua. The documentation in this file is concerned only with
-- demonstrating how to set up the new attack methods for monster capturing.

-- Methods are specified as a function that returns the available
-- methods. This allows them to change dynamically.
function monster_capture_methods(id, who)
	if (exvar[id] and exvar[id].captured) then
		return { { "RELEASE", 0, CLASS_PRIEST, method_release_monster } }
	else
		return { { "CAPTURE", 0, CLASS_PRIEST, method_capture_monster } }
	end 
end

-- Define the actual attack methods. lookup_method_info and method_finish
-- are utility functions provided by the base code in order to do most of
-- the simple tasks of grabbing the proper attack method information table
-- and then making use of it to give the right amount of xp, decrease
-- stamina, etc.
function method_capture_monster(name, ppos, who, what)
	local m = lookup_method_info(name, what)
	if (not m) then return end
	
	local captured = false
	
	-- Figure out where the "front" square is
	local lev, x, y, dir = dsb_party_coords()
	local dx, dy = dsb_forward(dir)
	-- And see what's in it, in all sections.
	for d=0,4 do
		local monsters = dsb_fetch(lev, x + dx, y + dy, d)
		if (monsters) then
			for midx in pairs(monsters) do
				local mon = monsters[midx]
				local m_arch = dsb_find_arch(mon)
				if (m_arch.type == "MONSTER") then
					-- Move the monster into the capturer and mark it a success
					dsb_move(mon, IN_OBJ, what, d, 0)
					captured = true
					
					-- Spawn a zap cloud, bigger if it's in the middle.
					local zcloud = dsb_spawn("zap", lev, x + dx, y + dy, d)
					if (d == CENTER) then
						dsb_set_charge(zcloud, 40)
					else
						dsb_set_charge(zcloud, 20)
					end
				end
			end
		end
	end
	
	-- If we succeeded, give xp and make a noise... otherwise, just
	-- set us idle for a little bit.
	if (captured) then
		use_exvar(what)
		exvar[what].captured = true
		method_finish(m, ppos, who)
		dsb_sound(snd.zap)
	else
		failed_attack_idle(m, ppos)
	end
		
end

function method_release_monster(name, ppos, who, what)
	local m = lookup_method_info(name, what)
	if (not m) then return end
	
	local released = false
	local first_mon
	local first_mon_arch
	
	-- Figure out the the first monster
	for d=0,4 do
		local inmon = dsb_fetch(IN_OBJ, what, d, 0)
		if (inmon) then
			first_mon = inmon
			first_mon_arch = dsb_find_arch(inmon)
		end
	end
	
	if (first_mon) then
		-- Figure out where the "front" square is
		local lev, x, y, dir = dsb_party_coords()
		local dx, dy = dsb_forward(dir)
		-- And see if our monster can go there
		if (canigo(first_mon_arch, first_mon, lev, x + dx, y + dy, false)) then
			-- Let them all out
			released = true
			for d=0,4 do
				local inmon = dsb_fetch(IN_OBJ, what, d, 0)
				if (inmon) then
					dsb_move(inmon, lev, x + dx, y + dy, d)
										
					-- Make the monster flash a moment
					dsb_set_tint(inmon, {255, 255, 255})
					dsb_msg(2, inmon, M_TINT, 0)
				end
			end	
		else
			dsb_write(system_color, "CANNOT RELEASE MONSTER THERE.")
		end
	end			
	
	-- If we succeeded, give xp and make a noise... otherwise, just
	-- set us idle for a little bit.
	if (released) then
		exvar[what].captured = nil
		method_finish(m, ppos, who)
		dsb_sound(snd.zap)
	else
		failed_attack_idle(m, ppos)
	end
end


obj[ROOT_NAME] = {
	name = "CAPTURER",
	type="THING",
	mass=33,
	class="STAFF",
	icon=gfx.icons[64],
	dungeon=gfx.staff_conduit,
	
	-- Store the table-returning method function as this arch's attack methods
	methods = monster_capture_methods,
	
	-- Store some extended information used by the functions that actually
	-- invoke the methods. This is all in the same form as base/methods.lua.
	method_info = {
		CAPTURE = {
	    	xp_class = CLASS_PRIEST,
			xp_sub = SKILL_FEAR,
			xp_get = 10,
			idleness = 10,
			stamina_used = 10
		},
		
		RELEASE = {
	    	xp_class = CLASS_PRIEST,
			xp_sub = SKILL_FEAR,
			xp_get = 5,
			idleness = 5,
			stamina_used = 5
		}
	},
	
	fit_sheath=true		
}