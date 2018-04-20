-- Triggers base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- These functions are not called by the engine directly,
-- but they are used by objects and so you should be careful
-- about overriding them.

-- General wall button handler
function wallitem_click(self, id, what)
	local rv = false
	
	if (not exvar[id]) then
	    return false
	end
	
	local relobj = nil
	local relnum = nil
	local no_rel = nil
	if (not exvar[id].disabled and exvar[id].opby_empty_hand_only) then
		no_rel = true
	end
	if (exvar[id].release == true) then
		relobj, relnum = wallitem_release_object(self, id, what, no_rel)
		if (relobj and relnum == 0) then
			exvar[id].release = nil
		end
	end
	
	if (exvar[id].disabled) then
	    return false
	end

	if (is_opby(id, what, 1)) then
    	if (exvar[id].target or exvar[id].func) then
			click_sound(self, id)

			if (self.click_to) then
		   		dsb_qswap(id, self.click_to)
			end
		end
		
		if (exvar[id].count) then
			exvar[id].count = exvar[id].count - 1
			if (exvar[id].count == 0) then
				exvar[id].count = nil
			else
				if (exvar[id].destroy) then
					dsb_delete(what)
					what = nil
				end
			end
		end
		
		if (not exvar[id].count) then
			got_triggered(id, what)
		end
		
		rv = true
	end
	
	if (no_rel and relobj) then
		dsb_push_mouse(relobj)
	end
		
	return rv
end

-- Something that contains objects (like a sconce etc.)
function wallitem_take_object(self, id, what)
	use_exvar(id)
	if (not exvar[id].take_release_only) then
		wallitem_click(self, id, what)
	end
	if (what) then
		local arch = dsb_find_arch(what)
		if (not self.take_class or arch.class == self.take_class) then
			dsb_move(dsb_pop_mouse(), IN_OBJ, id, VARIABLE, 0)
			if (self.convert_take_object) then
			    dsb_qswap(id, self.convert_take_object)
			end
			if (exvar[id].take_release_only) then
				wallitem_click(self, id, what)
			end
			exvar[id].release = true
		end
	end
end

function wallitem_release_object(self, id, what, no_rel)
	if (not what) then
		local inside_id, max = dsb_fetch(IN_OBJ, id, VARIABLE, 0)
		if (inside_id) then
			if (not no_rel) then
				dsb_push_mouse(inside_id[max])
			end
			if (self.convert_release_object) then
				dsb_qswap(id, self.convert_release_object)
			elseif (self.release_object) then
				dsb_write(debug_color, "ERROR! ARCH.RELEASE_OBJECT IS DEPRECATED.")
		    	self.convert_release_object = self.release_object
		    	dsb_qswap(id, self.convert_release_object)
			end
			return inside_id[max], (max - 1)
		end
	end
	
	return false
end

-- A fountain got clicked
function fountain_click(self, id, what)
	if (not wallitem_click(self, id, what)) then
	    if (not what) then
	        local drinker = dsb_ppos_char(dsb_get_leader())
			dsb_set_water(drinker, dsb_get_water(drinker) + 2000)
	        dsb_sound(snd.gulp)
	    else
	        fountain_click_object(self, id, what)
		end
	end
end

function show_floortext(self, id, what)
	if (not what and exvar[id] and exvar[id].text) then
		if (exvar[id].disabled) then return end
		
		local lines, num_lines
		if (type(exvar[id].text) == "table") then
			lines = exvar[id].text
			num_lines = #(exvar[id].text)
		else
			lines, num_lines = dsb_linesplit(exvar[id].text, "/")
		end
		
		local color
		if (exvar[id].color) then color = exvar[id].color
		else color = {255,255,255} end
		
		for i=1,num_lines do
			dsb_write(color, lines[i])
		end
		
		if (exvar[id].disable_self) then
			exvar[id].disabled = true
		end
	end 	
end

function fountain_click_object(arch, id, what)
	local click_arch = dsb_find_arch(what)
	
	if (click_arch.class) then
	    if (arch.fill_class[click_arch.class]) then
			dsb_swap(what, arch.fill_class[click_arch.class])
		end
	end
	
end

-- Revive bones that are in the altar
function use_vi_altar(arch, id, what)

	wallitem_click(arch, id, what)
	if (not what) then return end
	
	local rev_arch = dsb_find_arch(what)
	local revive_class = "BONES"
	if (arch.revive_class) then revive_class = arch.revive_class end
	if (rev_arch.class == revive_class) then
	    if (exvar[what] and exvar[what].owner) then
			dsb_sound(snd.zap)
			exvar[what].in_altar = true
			dsb_msg(4, id, M_NEXTTICK, what)
		end
	end
end

function revive_character(id, data)
	local lev, xc, yc = dsb_get_coords(id)
	local char = exvar[data].owner
	
	local cloudid = dsb_spawn("explosion", lev, xc, yc, CENTER)
	dsb_set_charge(cloudid, 64)
	
	dsb_sound(snd.explosion)
	
	local mh = dsb_get_maxbar(char, HEALTH)
	mh = mh - (mh/64 + 1)
	if (mh < 250) then mh = 250 end
	dsb_set_maxbar(char, HEALTH, mh)
	dsb_set_bar(char, HEALTH, mh/2)
	
	-- I couldn't find any code in CSBwin that messes with
	-- stamina and mana, but then again, I don't think I ever
	-- came out of a vi altar in very good shape, either.
	-- Here is my attempt to tweak things.
	local ms = dsb_get_maxbar(char, STAMINA)
	dsb_set_bar(char, STAMINA, dsb_rand(ms/2, (ms*3)/4))	
	local mm = dsb_get_maxbar(char, MANA)
	dsb_set_bar(char, MANA, dsb_rand(0, mm/2))
	
	dsb_msg(0, data, M_DESTROY, 0)
end

-- General door button
function doorbutton_push(self, id, what)
	use_exvar(id)
	if (exvar[id].disabled) then
	    return false
	end
	click_sound(self, id)
	got_triggered(id)
end

-- The system of actuators included here is
-- an attempt at emulating most of what DM can
-- do. However, the base system of events and
-- messages is much more flexible, and you can
-- design all sorts of different trigger systems
-- if you so choose.
function floor_trigger(self, id, what, force)

	if (not exvar[id]) then
	    return false
	elseif ((not exvar[id].target) and (not exvar[id].func)) then
	    return false
	end
	
	if (exvar[id].disabled) then
	    return false
	end

	if (force or is_opby(id, what, 0)) then
		if (not exvar[id].tc) then
			exvar[id].tc = 0
		end
		local tc = exvar[id].tc
		if (not exvar[id].no_tc) then
			if (tc == 0 and what and exvar[id].destroy) then
				-- In DSB 0.67 this code would not add to the tc
				-- when the opby went away. This turned out to
				-- do the wrong thing.
				exvar[id].tc = tc + 1
			else
				exvar[id].tc = tc + 1
			end
		end
		
		if (tc == 0) then
			if (exvar[id].count) then
				exvar[id].count = exvar[id].count - 1
				if (exvar[id].count == 0) then
					exvar[id].count = nil
				end
			end
			
			local no_action = false
			if (not exvar[id].count) then
				if (exvar[id].off_trigger) then
					no_action = true
				else
					got_triggered(id, what)
				end
			end
			
			if (exvar[id].const_weight and exvar[id].disable_self) then
				if (exvar[id].disabled) then
					exvar[id].disabled = nil
					exvar[id].disable_count = 1
				end
			end
			
			make_trigger_sound(self, id, no_action)
		end
	else
		if (exvar[id].wrong_direction_untrigger) then
			if (exvar[id].opby_party and exvar[id].opby_party_face) then
				if (not what) then
					got_untriggered(id, what)
					make_trigger_sound(self, id, false)
					return
				end
			end
		end
		
		-- We stepped on the trigger and didn't carry what we were supposed to.
		-- Since it's constant weight, we'll send a reverse message.
		if (exvar[id].opby_party_carry and exvar[id].const_weight) then
			got_untriggered(id, what)
			make_trigger_sound(self, id, false)
			return
		end
		
	end
end

function floor_trigger_off(self, id, what, force)
	tdir_floor_trigger_off(self, id, what, nil, force)
end

function tdir_floor_trigger_off(self, id, what, t_tdir, force)
	if (not exvar[id]) then
	    return false
	elseif (not exvar[id].target and not exvar[id].func) then
	    return false
	end
	
	if (exvar[id].disabled) then
	    return false
	elseif (exvar[id].no_tc) then
		return nil
	end
	
	if (force or is_opby(id, what, 0, t_tdir)) then
		local tc = exvar[id].tc
		
		if (tc == nil) then
			dsb_write(debug_color, "ERROR! UNTRIGGERED NIL FOR " .. id)
			return
		end
		
		if (tc == 0) then
			dsb_write(debug_color, "ERROR! UNTRIGGER ON ZERO FOR " .. id)
			return
		end
		
		if (tc == 1) then
			if (exvar[id].const_weight) then
				got_untriggered(id, what)
				make_trigger_sound(self, id, false)			
				exvar[id].tc = nil
				
				if (exvar[id].disable_self and exvar[id].disable_count) then
					exvar[id].disabled = true
					exvar[id].disable_count = nil
				end
				
			else
				if (exvar[id].off_trigger) then
					got_triggered(id, what)
					make_trigger_sound(self, id, false)
				end
				exvar[id].tc = nil
			end
		else
			exvar[id].tc = tc - 1
		end
	else
		-- Off_trigger and wrong_direction_untrigger means send an untrigger
		-- when we step off facing the wrong direction
		if (exvar[id].off_trigger and exvar[id].wrong_direction_untrigger) then
			if (exvar[id].opby_party and exvar[id].opby_party_face) then
				if (not what) then
					got_untriggered(id, what)
					make_trigger_sound(self, id, false)
					return
				end
			end			
		end
	end
end

function turn_trigger(self, id, dir)
	if (not exvar[id]) then
		return nil
	end
	
	if (exvar[id].disabled) then
	    return false
	end
	
	local op_pos = nil
	if (exvar[id].opby_party_face) then
	    op_pos = exvar[id].opby_party_face
	else
	    local _, _, _, mypos = dsb_get_coords(id)
		op_pos = mypos
		if (op_pos >= CENTER) then
			return nil
		end
	end

	if (op_pos == dir) then
		floor_trigger(self, id, nil)
	end
end

function turn_trigger_off(self, id, old_dir)
	if (not exvar[id]) then
		return nil
	end
	
	if (exvar[id].disabled) then
	    return false
	end

    local op_pos = nil
	if (exvar[id].opby_party_face) then
	    op_pos = exvar[id].opby_party_face
	else
	    local _, _, _, mypos = dsb_get_coords(id)
		op_pos = mypos
		if (op_pos >= CENTER) then
			return nil
		end
	end

	if (op_pos == old_dir) then
		tdir_floor_trigger_off(self, id, nil, old_dir)
	end
end

function trigger_pickup(self, id, what)
	if (exvar[id] and not exvar[id].disabled) then
		if (what and exvar[id].opby_party_carry) then
		    local opc = exvar[id].opby_party_carry
		    if (opc == true) then opc = exvar[id].opby end
		    local obj_arch = dsb_find_arch(what)
			if (obj[opc] == obj_arch) then
				if (exvar[id].except_when_carried) then
					floor_trigger_off(self, id, what, true)
				else
					floor_trigger(self, id, what, true)
				end
			end
		end
	end
end

function trigger_drop(self, id, what)
	if (exvar[id] and not exvar[id].disabled) then
		if (what and exvar[id].opby_party_carry) then
		    local opc = exvar[id].opby_party_carry
		    if (opc == true) then opc = exvar[id].opby end
		    local obj_arch = dsb_find_arch(what)
			if (obj[opc] == obj_arch) then
				if (exvar[id].except_when_carried) then
					floor_trigger(self, id, what, true)
				else
					floor_trigger_off(self, id, what, true)
				end
			end
		end
	end
end

function check_opby_party_carry(id)
	local optable = exvar[id].opby_party_carry
	if (optable == true) then optable = exvar[id].opby end
	
	if (type(optable) == "table") then
		for i in pairs(optable) do
			local opby = optable[i]
			local res = dsb_party_scanfor(opby)
			if (res == true) then return true end
		end
	else
		if (dsb_party_scanfor(optable)) then
			return true
		else
			return false
		end
	end
end

function make_trigger_sound(self, id, no_action)
	if (not no_action and not exvar[id].silent) then
		if (exvar[id].sound) then
			local_sound(id, exvar[id].sound, true)
		elseif (not self.default_silent) then
			if (self.default_sound) then
				local_sound(id, self.default_sound, true)
			elseif (self.class == "TRIGGER") then
				local_sound(id, snd.click)
			end
		end
	end	
end

-- A helper function to determine when a trigger
-- should be considered "operated"
function is_opby(id, what, itemtype, tdir)
	local wallitem = false
	if (itemtype == 1) then wallitem = true end
	local teleporter = false
	if (itemtype == 2) then teleporter = true end

	if (not(exvar[id])) then return(false) end
	
	if (exvar[id].opby_func) then
		local ofunc = dsb_lookup_global(exvar[id].opby_func)
		local rv = ofunc(id, what, wallitem, teleporter)
		if (rv == false) then return false end
		if (rv == true) then return true end
	end

	if (what) then
        local thing_arch = dsb_find_arch(what)
        local flying
        
		-- No longer check opby_party_carry at
		-- all. set_and_carry is now deprecated,
		-- instead, opby and opby_party_carry are
		-- two totally different fields.
        
		if (thing_arch.type == "THING") then
        	flying = dsb_get_flystate(what)
        elseif (thing_arch.type == "MONSTER") then
        	flying = thing_arch.hover
        else
        	flying = false
        end
        
		local air_ok = false
        if (teleporter or exvar[id].air) then
        	air_ok = true
        end
        if (exvar[id].not_in_air) then
        	air_ok = false
        end
        
		if (flying) then
			if (not air_ok and not exvar[id].air_only) then
				return false
			end
			
			if (teleporter) then
				if (dsb_get_gameflag(GAME_NO_LAUNCH_TELEPORT)) then
					if (dsb_get_gfxflag(what, GF_LAUNCHED)) then
						return false
					end
				end
			end
			
		else
			if (exvar[id].air_only) then
				return false
			end
		end
		
		if (exvar[id].blacklist) then
			local bl = exvar[id].blacklist
			for bli=1,#bl do
				if (what == exvar[id].blacklist[bli]) then
					return false
				end
			end
		end
		
		if (exvar[id].opby_thing == true) then
			if (thing_arch.type == "THING") then
				if (not exvar[id].opby_except_class or
					thing_arch.class ~= exvar[id].opby_except_class)
				then
					return true
				end
			end
		end

		if (exvar[id].opby_monster == true) then
			if (thing_arch.type == "MONSTER") then
				if (not exvar[id].opby_except_class or
					thing_arch.class ~= exvar[id].opby_except_class)
				then
					return true
				end
			end
		end
		
		if (type(exvar[id].opby) == "table") then
			for i in pairs(exvar[id].opby) do
				local opby = exvar[id].opby[i]
				if (thing_arch == obj[opby]) then
					return true
				end
			end
		else
			if (thing_arch == obj[exvar[id].opby]) then
				return true
			end
			
			if (exvar[id].opby_suffix) then
				local altv = "_x"
				if (type(exvar[id].opby_suffix) == "string") then altv = exvar[id].opby_suffix end 
				local depleted = exvar[id].opby .. altv
				if (obj[depleted] and obj[depleted] == thing_arch) then
					return true
				end
			end
		end
		
		if (thing_arch.class == exvar[id].opby_class) then
			return true
		end
		
		if (what == exvar[id].opby_id) then
		    return true
		end
		
		if (wallitem) then
		    if (exvar[id].opby_empty_hand_only) then
		        return false
			end
			
			if (exvar[id].opby) then
				return false
			elseif (exvar[id].opby_id) then
				return false
			else
				return true
			end
		end

	else
		if (exvar[id].opby_party == true) then
			if (not exvar[id].opby_party_face) then
  				return true
			end

			if (tdir) then
				if (tdir == exvar[id].opby_party_face) then
					return true
				end
			else
				local _, _, _, pface = dsb_party_coords()
				if (pface == exvar[id].opby_party_face) then
					return true
				end
			end
		end

		if (exvar[id].opby_party_carry) then
			local opc = check_opby_party_carry(id)
			if (exvar[id].except_when_carried) then
				return not opc
			end
			return opc
		end

		if (exvar[id].opby or
			exvar[id].opby_class or
			exvar[id].opby_id) then
			return false
		end
		
		if (wallitem) then
			if (exvar[id].opby_thing) then
				return false
			end
		    if (exvar[id].target or exvar[id].func) then
		    	return true
			end
		end
	end

	return false
end

function base_pitfall(self, id, what)
	if (what) then

		arch = dsb_find_arch(what)

		if (arch.type == "THING") then
			local fly = dsb_get_flystate(what)
			if (not fly) then
				local lev, xc, yc, face = dsb_get_coords(what)
				dsb_move(what, lev+1, xc, yc, face)
			end
		elseif (arch.type == "MONSTER") then
		    if (not arch.hover) then
				local lev, xc, yc, face = dsb_get_coords(what)
				local damage_amount, nlev, nxc, nyc, nface =
					h_monster_falls_down(lev, xc, yc, face)
				dsb_move(what, nlev, nxc, nyc, nface)
				dsb_set_hp(what, dsb_get_hp(what) - damage_amount)
			end
		end
	else	
		if (dsb_party_affecting() == dsb_party_viewing()) then
			local fallspeed = 2
			local lev, xc, yc, face = dsb_party_coords()
			local down_rope = false
			
			if (not g_total_pit_damage) then
			    if (gt_rope_use) then
			        gt_rope_use = nil
					down_rope = true
				else
		    		dsb_sound(snd.scream)
		    		g_total_pit_damage = 0
		    		fallspeed = 4
				end
		    end
		    
		    -- Set all bit flags but actuators
			local pit_lock = 65534
			
			local damage_amount, nlev, nxc, nyc, nface =
				h_party_falls_down(lev, xc, yc, face)
				
			dsb_lock_game(pit_lock)
	
			dsb_delay_func(fallspeed, function()
		        dsb_unlock_game(pit_lock)
	    		dsb_party_place(nlev, nxc, nyc, nface)
	    		if (not down_rope) then
	    			g_total_pit_damage = g_total_pit_damage + damage_amount
				end
			end)
			
		else
			local lev, xc, yc, face = dsb_party_coords()
			local damage_amount, nlev, nxc, nyc, nface =
				h_party_falls_down(lev, xc, yc, face)
			
			-- If nothing is specified, dsb_party_place will affect
			-- dsb_party_affecting, not necessarily the one viewing.
			dsb_party_place(nlev, nxc, nyc, nface)
			pit_damage(damage_amount)
		end
	end
end

function base_stairs(self, id, what)

	if (is_opby(id, what, 0)) then
		got_triggered(id, what)
	end

	if (what) then
	    local arch = dsb_find_arch(what)
	    
	    if (arch.type == "THING") then
			local fly = dsb_get_flystate(what)
			
			if (not fly) then
				local lev, xc, yc, landpos = dsb_get_coords(what)
				local back_out_dir = open_facing(lev, xc, yc, landpos)
				
				-- If the stairs go up, just bump into the stairs and drop
				if (self.stairs_dir < 0) then
					local dx, dy = dsb_forward(back_out_dir)
					dsb_move(what, lev, xc+dx, yc+dy, dsb_tileshift(landpos, back_out_dir))				
				else
					local levchg = self.stairs_dir
					if (exvar[id]) then
						if (exvar[id].x) then
							xc = exvar[id].x
							levchg = 0
						end	
						if (exvar[id].y) then
							yc = exvar[id].y
							levchg = 0
						end
						if (exvar[id].lev) then 
							lev = exvar[id].lev
							levchg = 0
						end
					end
			    
					local out_dir = open_facing(lev+levchg, xc, yc, landpos)
					local dx, dy = dsb_forward(out_dir)
					
					local flip_side = false
					if (back_out_dir == landpos) then
						flip_side = true
					end
					
					local newpos = dsb_tileshift(out_dir, out_dir)
					if (flip_side) then
						newpos = dsb_tileshift(newpos, ((out_dir+1)%4))
					end
					
					-- In actual DM, this check doesn't exist. If you throw something down
					-- the stairs, it lands at the bottom... if there is a wall down there,
					-- the item will be stuck in the wall. This is, in my opinion, a bug.
					-- The simplest fix is to just not let it go down the stairs.
					if (dsb_get_cell(lev+levchg, xc+dx, yc+dy)) then
						local bdx, bdy = dsb_forward(back_out_dir)
						dsb_move(what, lev, xc+bdx, yc+bdy, dsb_tileshift(landpos, back_out_dir))	
					else
						dsb_move(what, lev+levchg, xc+dx, yc+dy, newpos)		
					end
					
				end
			end
		end
	else
		use_stairs(self, id)
	end
end

function stairs_turn(self, id, dir)
	use_stairs(self, id)
end

function stairs_backup(self, id, dir)
	local lev, xc, yc, face = dsb_party_coords()
	if ((face+2)%4 == dir) then
		return (use_stairs(dsb_find_arch(id), id))
	else
		return false
	end
end

function use_stairs(stairs_arch, id)
	if (exvar[id] and exvar[id].temp_disabled) then
		return false
	end
	local def_lev, xc, yc, face = dsb_party_coords()
	local lev = (def_lev + stairs_arch.stairs_dir)
	
	-- Stairs can have arbitrary targets, just to be tricky ;)
	-- Now consistent with teleporters. If we have any targets
	-- specified, we only change levels if explicitly told to.
	if (exvar[id]) then
		if (exvar[id].x) then
			xc = exvar[id].x
			lev = def_lev
		end	
		if (exvar[id].y) then
			yc = exvar[id].y
			lev = def_lev
		end
		if (exvar[id].lev) then lev = exvar[id].lev end
		
		if (exvar[id].sound) then
			dsb_sound(snd[exvar[id].sound])
		end
	end
		
	local new_face = open_facing(lev, xc, yc, face)
	local targ_stairs = search_for_class(lev, xc, yc, CENTER, "STAIRS")
	if (targ_stairs) then
		use_exvar(targ_stairs)
		exvar[targ_stairs].temp_disabled = true
		dsb_delay_func(END_OF_FRAME, function()
			exvar[targ_stairs].temp_disabled = nil
		end)
	end
	dsb_party_place(lev, xc, yc, new_face)
	
	return true
end

function blocker_no_monsters(self, id, what)
	if (exvar[id] and what) then
		if (exvar[id].blocks) then
			if (obj[exvar[id].blocks] ~= dsb_find_arch(what)) then
				return false
			end
		end 
	end
	return true
end

function pit_no_monsters(self, id, what)
	if (what) then
	    local arch = dsb_find_arch(what)
	    if (arch.hover == true) then
	        return false
		else
		    return true
		end
	end
	return false
end

function fakepit_no_monsters(self, id, what)
	if (what) then
	    local arch = dsb_find_arch(what)
	    if (arch.hover or (not arch.sight)) then
	        return false
		else
		    if (arch.smart) then
		        local lev, x, y = dsb_get_coords(id)
		        local vis = dsb_visited(lev, x, y)
		        if (vis) then
		            return false
				end
			end
		    return true
		end
	end
	return false
end

-- The function that controls teleporters and spinners
function base_teleporter(self, id, what)
	local lev, xc, yc, face
	local tface
	local tele_sound = nil
		
	if (not is_opby(id, what, 2)) then
		return false
	end
	
	if (what) then
	    lev, xc, yc, face = dsb_get_coords(what)
	    tface = face
	else
	    lev, xc, yc, face = dsb_party_coords()
	end
		
	if (exvar[id].x) then xc = exvar[id].x end	
	if (exvar[id].y) then yc = exvar[id].y end
	if (exvar[id].lev) then lev = exvar[id].lev end
	
	if (exvar[id].face) then
	    face = exvar[id].face
	    if (what) then
	        dsb_set_facedir(what, face)
		end
	end

	if (exvar[id].spin) then
		face = (face + exvar[id].spin) % 4
		if (what) then
		    dsb_set_facedir(what, (dsb_get_facedir(what) + exvar[id].spin) % 4)
		end
	end

	if (exvar[id].sound) then
	    tele_sound = snd[exvar[id].sound]
	end
	if (tele_sound == nil) then tele_sound = snd.buzz end
	
	if (what) then
	    local arch = dsb_find_arch(what)
	    
	    if (tface == CENTER) then
	    	face = CENTER
	    end
		
		local queued = false
		if (arch.type == "MONSTER") then
			local clev, cx, cy = dsb_get_coords(id)
			-- Only bother trying to queue if we're going to a different tile		
			if (clev ~= lev or cx ~= xc or cy ~= yc) then
				queued = teleport_needs_queue(what, lev, xc, yc, face)
			end
		end
		
		-- Only make noise once per tick
		if (not exvar[id].silent and not self.default_silent) then
			if (not exvar[id].temporary_silence) then
				dsb_3dsound(tele_sound, lev, xc, yc)
				exvar[id].temporary_silence = true
				dsb_msg(1, id, M_NEXTTICK, 0)
			end
		end

	    if (queued) then
			local controller = dsb_spawn("function_caller", LIMBO, 0, 0, 0)
			exvar[controller] = { m_a = "finish_queued_teleport", inst = what,
				lev = lev, x = xc, y = yc, tries = 0 }
			dsb_msg(2, controller, M_ACTIVATE, 0)

			if (face ~= CENTER) then
				use_exvar(what)
				exvar[what].teleport_tile_pos = face
			end
			dsb_move(what, LIMBO, 0, 0, 0)
		else			
			dsb_move(what, lev, xc, yc, face)
			if (arch.on_teleport) then
				arch:on_teleport(what, lev, xc, yc, face)
			end
		end

	    if (dsb_get_cell(lev, xc, yc)) then
	    	dsb_set_flystate(what, 0)
		end
	else
	    dsb_party_place(lev, xc, yc, face)
	    if (not exvar[id].silent and not self.default_silent) then
	    	if (dsb_party_viewing() == dsb_party_affecting()) then
	    		dsb_sound(tele_sound)
	    	else
	    		dsb_3dsound(tele_sound, lev, xc, yc)
	    	end
	    end
	end
end

function teleport_needs_queue(targ, lev, xc, yc, pos)
	local targ_arch = dsb_find_arch(targ)
	local myboss = dsb_ai_boss(targ, true)
	local blocking_group = false
	local same_type_blocks = true
	local position_open = false
	
	local levp, xcp, ycp = dsb_get_coords_prev(targ)
	local going_back = false
	if (levp == lev and ycp == yc and xcp == xc) then	
		going_back = true
	end
	
	for p=4,0,-1 do
		local occupied = search_for_type(lev, xc, yc, p, "MONSTER")
		if (occupied) then
			if (myboss == dsb_ai_boss(occupied, true)) then
				return false
			else
				blocking_group = true
				
				-- Something in the center always blocks
				if (p == CENTER) then
					return true
				end
				
				-- Only bother with this if we're going back where we came from
				if (going_back) then			
					if (pos and p == pos) then
						if (not occupied) then position_open = true end
					end
					local occ_arch = dsb_find_arch(occupied)
					if (occ_arch ~= targ_arch and 
						(not targ_arch.group_type or (occ_arch.group_type ~= targ_arch.group_type)))
					then
						same_type_blocks = false
						break
					end
				else
					return true
				end
			end
		end
	end

	if (blocking_group) then
		if (same_type_blocks and position_open) then
			return false
		end
	else
		return false
	end
	
	return true
end

function finish_queued_teleport(id)
	local targ = exvar[id].inst
	local lev = exvar[id].lev
	local xc = exvar[id].x
	local yc = exvar[id].y
	
	if (exvar[id].disabled) then return end
	
	-- Target is gone, give up!
	if (not dsb_valid_inst(targ)) then
		dsb_msg(1, id, M_DESTROY, 0)
		return
	end
	local tlev = dsb_get_coords(targ)
	if (tlev ~= LIMBO) then
		dsb_msg(1, id, M_DESTROY, 0)
		return
	end
	
	local occupied = nil
	if (exvar[id].tries < 1500) then
		occupied = teleport_needs_queue(targ, lev, xc, yc, nil)
		exvar[id].tries = exvar[id].tries + 1
	end
	
	if (occupied) then
		dsb_msg(2, id, M_ACTIVATE, 0)
	else	
		local pos = CENTER
		if (exvar[targ] and exvar[targ].teleport_tile_pos) then
			pos = exvar[targ].teleport_tile_pos
			exvar[targ].teleport_tile_pos = nil
		end
		
		dsb_move(targ, lev, xc, yc, pos)
		
		local action_time = dsb_ai(targ, AI_TIMER, QUERY)
		if (action_time < 3) then
			dsb_ai(targ, AI_TIMER, 3)
		end
		
		local arch = dsb_find_arch(targ)
		if (arch.on_teleport) then
			arch:on_teleport(targ, lev, xc, yc, pos)
		end
		
		dsb_msg(1, id, M_DESTROY, 0)
	end
end

-- Trigger for a damager
function damage_something(self, id, what)
	if (not exvar[id]) then return end

	if (not what) then
	    for ppos_count=0,3 do
	        local damaged = false
	    	local who = dsb_ppos_char(ppos_count)
	    	if (valid_and_alive(who)) then
	    	    local dtype = exvar[id].dmg_type
	    	    if (dtype == nil) then dtype = HEALTH end
				do_damage(ppos_count, who,
					dtype, exvar[id].dmg_amt)
				damaged = true
			end
			if (damaged and not exvar[id].silent) then hurt_sound() end
		end
	else
	    local what_arch = dsb_find_arch(what)
	    if (what_arch.type == "MONSTER") then
			if (not exvar[id].dmg_type or
				exvar[id].dmg_type == HEALTH)
			then
				local hp = dsb_get_hp(what)
				hp = hp - exvar[id].dmg_amt
				dsb_set_hp(what, hp)
			end
		end
	end
end

function messages_to_targets(id, opby, target, msg, delay, m_reverse, default_opby)
	local i
	
	if (not opby) then opby = 0 end  		
	if (not delay) then delay = 0 end
	if (not msg) then
		local arch = dsb_find_arch(id)
		if (arch.default_msg) then msg = arch.default_msg end
	end
	if (not msg or not target) then return end
	if (not default_opby) then default_opby = 0 end

	if (type(target) == "table") then
		for i=1,100 do
			local targ = target[i]
			if (not targ) then break end
			local cmsg, cdelay, copby

			if (type(msg) == "table") then cmsg = msg[i]
			else cmsg = msg end
			
			if (type(delay) == "table") then cdelay = delay[i]
			else cdelay = delay end			

            if (type(opby) == "table") then copby = opby[i]
			else copby = opby end
			if (not copby and default_opby) then copby = default_opby end
			
			if (m_reverse) then
				local rmsg = reverse_msg(cmsg)
				if (rmsg) then
				    dsb_msg(cdelay, targ, rmsg, copby, id)
				end
			else
				dsb_msg(cdelay, targ, cmsg, copby, id)
			end
		end
	else
	    if (type(msg) == "table") then
			for i in pairs(msg) do
				local cmsg = msg[i]
				local cdelay, copby
				
				if (type(delay) == "table") then cdelay = delay[i]
				else cdelay = delay end

	            if (type(opby) == "table") then copby = opby[i]
				else copby = opby end
				if (not copby and default_opby) then copby = default_opby end

            	local rmsg = cmsg
				if (m_reverse) then rmsg = reverse_msg(cmsg) end
				if (rmsg) then
					dsb_msg(cdelay, target, cmsg, copby, id)
				end
			end
		else
			local rmsg = msg
			if (m_reverse) then rmsg = reverse_msg(msg) end
			if (rmsg) then
				local copby = opby
				if (not copby and default_opby) then copby = default_opby end
				dsb_msg(delay, target, rmsg, copby, id)
			end
		end
	end
end

-- Invoked by pits to create their ceiling pits
function create_linked_object(arch, id, lev, x, y, dir)
	if (arch.link_object) then
		local lo = dsb_spawn(arch.link_object,
			lev + arch.link_offset[1],
			x + arch.link_offset[2],
			y + arch.link_offset[3], dir)
		dsb_msg_chain(id, lo)
		-- This works for spawnbursted objects, but objects created
		-- afterwards will have to have their state updated by hand
		if (dsb_get_gfxflag(id, GF_INACTIVE)) then
			dsb_set_gfxflag(lo, GF_INACTIVE)
		end
	end
end
