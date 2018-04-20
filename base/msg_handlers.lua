-- Message handlers base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- These functions are not called by the engine directly,
-- but they are used by objects and so you should be careful
-- about overriding them.
							 
function self_destruct(id, data)
	dsb_delete(id)
end

function clean_up_target_exvars(id, data)
	dsb_clean_up_target_exvars(id)
end 

-- A helper function for determining the "reverse" of a message
-- Override this function if you want to expand upon it
function reverse_msg(cmsg)
	local rmsg = nil
	if (cmsg == M_ACTIVATE) then rmsg = M_DEACTIVATE end
	if (cmsg == M_DEACTIVATE) then rmsg = M_ACTIVATE end
	if (cmsg == M_TOGGLE) then rmsg = M_TOGGLE end
	if (cmsg == M_NEXTTICK) then rmsg = M_ALT_NEXTTICK end
	if (cmsg == M_ALT_NEXTTICK) then rmsg = M_NEXTTICK end
	
	return rmsg                                        
end

-- A helper function for objects that have
-- gotten triggered
function got_triggered(id, what)
	local destroyed = false
	
	if (not exvar[id]) then
	    return false
	end
	
	local ret_val = false
	
   	if (exvar[id].target) then
   		local opby = 0
		local d_opby = nil
 		
		if (what) then
   			opby = what
		end
		
		if (exvar[id].data) then
			d_opby = opby
			opby = exvar[id].data
		end
		
   		messages_to_targets(id, opby, exvar[id].target, 
			exvar[id].msg, exvar[id].delay, false, d_opby)
		if (not exvar[id]) then return end
			        	
		if (exvar[id].disable_self) then
		    exvar[id].disabled = true
		end
		
		if (what and exvar[id].destroy) then
		    dsb_delete(what)
		    destroyed = true
		end
		
		ret_val = true
	end
	
	if (exvar[id].func) then
		local cfunc = string_function_handler(id, exvar[id].func)
		if (cfunc) then
			cfunc(id, what, exvar[id].func_data)
		end
		if (not exvar[id]) then return end

		if (exvar[id].disable_self) then
		    exvar[id].disabled = true
		end
			
		if (not destroyed and what and exvar[id].destroy) then
		    dsb_delete(what)
		    destroyed = true
		end
		
		ret_val = true
	end

	return ret_val
end

-- Send the reverse of messages
function got_untriggered(id, what)
	if (not exvar[id]) then
	    return false
	end

   	if (exvar[id].target) then
   		local delay = 0
   		local opby = 0
		local d_opby = nil

   		if (what) then
   			opby = what
   		end
		
		if (exvar[id].data) then
			d_opby = opby
			opby = exvar[id].data
		end

   		if (exvar[id].delay) then
   			delay = exvar[id].delay
   		end

	   	if (exvar[id].target) then
	   		messages_to_targets(id, opby, exvar[id].target,
				exvar[id].msg, exvar[id].delay, true, d_opby)
			return true
		end
	end
	
	return false
end

-- Door functions
-- You don't really need to mess with this stuff if you
-- just want to open and close doors. Send them messages
-- as you would expect and these functions will handle it all
-- without having to do anything special.
function door_open(id, data)
	local door_arch = dsb_find_arch(id) 
	
	if (dsb_get_gfxflag(id, GF_BASHED)) then
	    return nil
	end
	
	local oldstate = nil
	if (exvar[id]) then
		oldstate = exvar[id].door_state
	end
	
	if (not oldstate and dsb_get_gfxflag(id, GF_INACTIVE)) then
	    return nil
	end
	
	if (door_arch.open_sound) then
		local_sound(door_arch.open_sound)
	end

    use_exvar(id)
	exvar[id].door_state = 1

	if (not oldstate) then
    	dsb_msg(1, id, M_NEXTTICK, 0)
    	if (dsb_get_crop(id) == 0) then
    		dsb_set_crop(id, 0)
    	end
	end
end

function door_close(id, data)
	local door_arch = dsb_find_arch(id) 
	
	if (dsb_get_gfxflag(id, GF_BASHED)) then
	    return nil
	end
	
	local oldstate = nil
	if (exvar[id]) then
		oldstate = exvar[id].door_state
	end
	
	if (not oldstate and not dsb_get_gfxflag(id, GF_INACTIVE)) then
	    return nil
	end
	
	if (door_arch.close_sound) then
		local_sound(door_arch.close_sound)
	end

	use_exvar(id)
	exvar[id].door_state = 2

	if (not oldstate) then
    	dsb_msg(1, id, M_NEXTTICK, 0)
    	if (dsb_get_crop(id) == 0) then
    		dsb_set_crop(id, dsb_get_cropmax(id))
    	end
	end
end

function door_toggle(id, data)
	local door_arch = dsb_find_arch(id)

	use_exvar(id)
	local oldstate = exvar[id].door_state

	if (oldstate) then
		local motion = 0
		
		if (oldstate == 1) then
		    exvar[id].door_state = 2
		    motion = -1 
		else
		    exvar[id].door_state = 1
		    motion = 1
		end
		
		if (door_arch.smooth) then
			dsb_set_crmotion(id, motion)
		end
		
	else
		if (dsb_get_gfxflag(id, GF_INACTIVE)) then
		    door_close(id, data)
		else
		    door_open(id, data)
		end
	end
end

function door_tick(id, data)
	local door_arch = dsb_find_arch(id)
	local doorlev = dsb_get_crop(id)
	local cropmax = dsb_get_cropmax(id)
	local movedir = exvar[id].door_state
	local finished = false
	
	dsb_clear_gfxflag(id, GF_INACTIVE)

	-- opening
	if (movedir == 1) then
		if (not door_arch.smooth) then
	    	doorlev = doorlev + 8
	    end
	    
	    if (doorlev >= cropmax) then
	        exvar[id].door_state = nil
	        dsb_set_crop(id, 0)
	        dsb_set_crmotion(id, 0)
	        dsb_set_gfxflag(id, GF_INACTIVE)
	        finished = true
		else
			if (door_arch.smooth) then
				dsb_set_crmotion(id, 1)
			else
		    	dsb_set_crop(id, doorlev)
		    end
		    
		    dsb_msg(1, id, M_NEXTTICK, 0)
	    end
	end

	-- closing
	if (movedir == 2) then
		if (not door_arch.smooth) then
	    	doorlev = doorlev - 8
	    end
	    
	    if (doorlev <= 0) then
	        exvar[id].door_state = nil
	        dsb_set_crop(id, 0)
	        dsb_set_crmotion(id, 0)
	        finished = true
		else
			if (door_arch.smooth) then
				dsb_set_crmotion(id, -1)
			else
				dsb_set_crop(id, doorlev)
          	end

		    local lev, x, y = dsb_get_coords(id)
            local p_at = dsb_party_at(lev, x, y)

		    if (p_at) then
		        local ppos_count
		        for ppos_count=0,3 do
		        	local who = dsb_ppos_char(ppos_count, p_at)
		        	if (valid_and_alive(who)) then
						h_door_hits_char(ppos_count, who)
					end
				end

			    if (door_arch.thud_sound) then
					dsb_3dsound(door_arch.thud_sound, lev, x, y)
			    else dsb_3dsound(snd.thud, lev, x, y) end
			    
		        dsb_msg(1, id, M_TEMPORARY_REVERSE, 0)
		        dsb_set_crop(id, math.floor(cropmax * 0.75))
		        if (door_arch.smooth) then
		        	dsb_set_crmotion(id, 1)
		        end
		    else
		        local hit_something = false
				local direction, i
				for direction=0, 4 do
		        	hit_objects = dsb_fetch(lev, x, y, direction)
		        	if (hit_objects) then
			        	for i in pairs(hit_objects) do
			        	    local v = hit_objects[i]
							local hit_arch = dsb_find_arch(v)
							local hheight = hit_arch.hit_height

							if (not hheight or door_arch.renderer_hack) then
							    hheight = 16
							end
							
							if (hit_arch.type == "MONSTER" and hit_arch.hit_height) then								
								local door_hit_height = math.floor(hheight/32.0 * cropmax)
								
								if (doorlev <= door_hit_height) then							
							   		hit_something = true
							    	h_door_hits_monster(v, hit_arch, id)		
									dsb_set_crop(id, door_hit_height)
								end
							end
			        	end
					end
				end

				if (hit_something) then
				    dsb_msg(1, id, M_TEMPORARY_REVERSE, 0)
				    if (door_arch.smooth) then
				    	dsb_set_crmotion(id, 1)
				    end
				    
				    if (door_arch.thud_sound) then 
						dsb_3dsound(door_arch.thud_sound, lev, x, y)
				    else dsb_3dsound(snd.thud, lev, x, y) end
				    
				else
		    		dsb_msg(1, id, M_NEXTTICK, 0)
				end

			end

	    end
	end
	
	if (not door_arch.smooth or not finished) then
		if (not door_arch.silent) then
			if (not door_arch.silent_move) then
				if (door_arch.move_sound) then
					local_sound(id, door_arch.move_sound)
				else
					local_sound(id, snd.doorclank)
				end
			end
		end
	end

end

function door_whacked_something(id, data)
	local doorlev = dsb_get_crop(id)
	local movedir = exvar[id].door_state
	local door_arch = dsb_find_arch(id)

	if (not door_arch.silent) then
		if (not door_arch.silent_move) then
			if (door_arch.move_sound) then
				local_sound(id, door_arch.move_sound)
			else
				local_sound(id, snd.doorclank)
			end
		end
		
		if (door_arch.reverse_sound) then
			local_sound(id, door_arch.reverse_sound)
		end
	end
	
	if (door_arch.smooth) then
		if (exvar[id].door_state == 2) then
			dsb_set_crmotion(id, -1)
		end
	else
		doorlev = doorlev + 8
		dsb_set_crop(id, doorlev)
	end
	
	dsb_clear_gfxflag(id, GF_INACTIVE)
	dsb_msg(1, id, M_NEXTTICK, 0)
end

function door_gotbashed(id, data)
	local door_arch = dsb_find_arch(id)
	
	if (dsb_get_gfxflag(id, GF_BASHED)) then
		return
	end
	
	if (data <= 1) then
		if (door_arch.bash_sound) then
			local_sound(id, door_arch.bash_sound)
		else
	    	local_sound(id, snd.thud)
	    end
	end
	
	if (data > 0) then
	    -- Make sure the door is down when it gets bashed
	    dsb_clear_gfxflag(id, GF_INACTIVE)
	    dsb_set_crop(id, 0)
	    dsb_set_crmotion(id, 0)
	    
		dsb_set_gfxflag(id, GF_BASHED)
	end
end

function door_collide(self, id, what)
	if (dsb_get_gfxflag(id, GF_BASHED)) then
	    return false
	else
	    if (what) then
			local what_arch = dsb_find_arch(what)
			if (what_arch.nonmat) then return false end
			if (self.bars and what_arch.go_thru_bars) then
				return false
			end
		end
		
		-- Let the party squeeze through a door that is
		-- just starting to close
		if (not what) then
			if (dsb_get_crop(id) >= math.floor(0.75 * dsb_get_cropmax(id))) then
				return false
			end
		end
		
		return true
	end

end

-- Controls a wall shooter
function shooter_shoot(id, data)
	local blocked = dsb_get_gfxflag(id, GF_INACTIVE)
	if (blocked) then return end

	local shoot_me
	local shoot_me_too

	use_exvar(id)

	if (exvar[id].shoots) then
		shoot_me = dsb_spawn(exvar[id].shoots, LIMBO, 0, 0, 0)
		if (exvar[id].double) then
			shoot_me_too = dsb_spawn(exvar[id].shoots, LIMBO, 0, 0, 0)
		end	
	else
		local shoot_table
		
		if (exvar[id].shoot_square) then
		    local lev, x, y, d = dsb_get_coords(id)
		    if (lev < 0) then return end
			
			local shoot_count = 0
			shoot_table = { }
			
			for dp=0,3 do
				local fd = (d + dp) % 4
				local fetched_table = dsb_fetch(lev, x, y, fd)
				if (fetched_table) then
					for i=1,#fetched_table do
						local n_id = fetched_table[i]
						local n_arch = dsb_find_arch(n_id)
						if (n_arch.type == "THING") then
							shoot_count = shoot_count + 1
							shoot_table[shoot_count] = n_id
						end
					end
				end
			end
			
			if (shoot_count == 0) then
				shoot_table = nil
			end
			
		else
			shoot_table = dsb_fetch(IN_OBJ, id, -1, 0)
		end
		
		if (shoot_table) then
			shoot_me = shoot_table[1]
			if (exvar[id].double) then
				shoot_me_too = shoot_table[2]
			end
		end	
	end
	
	if (shoot_me) then
		local lev, xc, yc, dir = dsb_get_coords(id)
		local dx, dy = dsb_forward(dir)
		
		local start = dir
		local ostart = dir
		
		if (exvar[id].force_side == 1) then
		    start = (start + 1) % 4
		elseif (exvar[id].force_side == 0) then
		    ostart = (ostart + 1) % 4
		else
			if (not shoot_me_too and dsb_rand(0, 1) == 0) then
				start = (start + 1) % 4
			else
			    ostart = (start + 1) % 4
			end
				
		end
		
		start = dsb_tileshift(start, dir)
		ostart = dsb_tileshift(ostart, dir)
		
		local power = 1
		if (exvar[id].power) then power = exvar[id].power end
		local damage = power
		local delta = 0 -- Many puzzles in DM and CSB require shooters to have no delta
		if (exvar[id].damage) then damage = exvar[id].damage end
		if (exvar[id].delta) then delta = exvar[id].delta end
		
		dsb_shoot(shoot_me, lev, xc+dx, yc+dy, dir, start, power, damage, delta)
		if (shoot_me_too) then
			dsb_shoot(shoot_me_too, lev, xc+dx, yc+dy, dir, ostart, 
				power, damage, delta)
		end

		if (exvar[id].sound) then
		    local_sound(id, exvar[id].sound, true)
		end
		
		-- No regen doesn't mean "never reactivate," it means "never deactivate!"
		if (exvar[id].regen) then
			dsb_set_gfxflag(id, GF_INACTIVE)
			dsb_msg(exvar[id].regen, id, M_NEXTTICK, 0)
		end
	end
end

function cloud_shrink(id, data)
	local clsz = dsb_get_charge(id)
	
	use_exvar(id)
	local dd = exvar[id].delta
	if (not dd) then dd = 1 end
	clsz = clsz - dd
	
	if (clsz > 0) then
	    dsb_set_charge(id, clsz)
	    dsb_toggle_gfxflag(id, GF_FLIP)
		dsb_msg(1, id, M_NEXTTICK, 0)
	else
	    dsb_msg(0, id, M_DESTROY, 0)
	end
end

function poison_cloud_shrink(id, data)
	if (not exvar[id] or not exvar[id].apower) then
		dsb_msg(0, id, M_DESTROY, 0)
		return
	end		
	exvar[id].apower = exvar[id].apower - 5
	dsb_toggle_gfxflag(id, GF_FLIP)
	if (exvar[id].apower <= 0) then
		dsb_msg(0, id, M_DESTROY, 0)
	else		
		local p_range = (exvar[id].apower)/3
		if (p_range > 60) then
		    p_range = 64
		elseif (p_range < 10) then
			p_range = 10
		end
		dsb_set_charge(id, p_range)
		dsb_msg(2, id, M_ALT_NEXTTICK, 0)
	end
end

function explosion_created(self, id)
	dsb_msg(2, id, M_DESTROY, 0)
end

function cloud_created(self, id)
	dsb_msg(1, id, M_NEXTTICK, 0)	
end

function poison_cloud_created(self, id)
	dsb_msg(1, id, M_NEXTTICK, 0)
	dsb_msg(2, id, M_ALT_NEXTTICK, 0)
end

function light_fade_step(id, data)
	local base_light = (dsb_get_light("magic") - exvar[id].light)
	
	exvar[id].light = math.floor(exvar[id].light - data)
	
	if (exvar[id].light > 0) then	
		dsb_set_light("magic", base_light + exvar[id].light)
		dsb_msg(4, id, M_NEXTTICK, data)
	else
		dsb_set_light("magic", base_light)
		dsb_msg(0, id, M_DESTROY, 0)
	end
end

function shield_shutdown(id, data)
	local who = exvar[id].owner
	local s_level = dsb_get_condition(who, exvar[id].type)
	
	s_level = s_level - exvar[id].power
	if (s_level < 1) then s_level = 0 end
	
	dsb_set_condition(who, exvar[id].type, s_level)
	
	self_destruct(id, data)
end

function generate_monster(id, data)
	local blocked = dsb_get_gfxflag(id, GF_INACTIVE)
	if (blocked) then return end 	
	
	local lev, xc, yc = dsb_get_coords(id)
	
	local d
	for d=0,4 do
		local full = search_for_type(lev, xc, yc, d, "MONSTER")
		if (full) then return end
	end
	
	if (not exvar[id] or not exvar[id].generates) then
		return
	end
	local mon_arch = obj[exvar[id].generates]
	if (not mon_arch) then
		return
	end
	
	if (exvar[id].count) then
		if (exvar[id].count <= 0) then
			dsb_set_gfxflag(id, GF_INACTIVE)
			return
		end
	end
	
	local monsters
	if (mon_arch.size == 4) then
		monsters = 1
	else
		if (exvar[id].min) then
			if (exvar[id].max and exvar[id].max > exvar[id].min) then
				monsters = dsb_rand(exvar[id].min, exvar[id].max)
			else
				monsters = exvar[id].min
			end
		else
			if (exvar[id].num_permitted) then
				local pslot = dsb_rand(1, 4)
				local failures = 0
				while (not exvar[id].num_permitted[pslot]) do
					pslot = (pslot + 1)
					if (pslot > 4) then pslot = 1 end
					failures = failures + 1
					if (failures == 4) then break end
				end
				monsters = pslot			
			else
				monsters = 1
			end
		end
	end
	
	if (mon_arch.size == 2 and monsters > 2) then
		monsters = 2
	elseif (monsters > 4) then
		monsters = 4
	elseif (monsters <= 0) then
		return
	end
	
	-- Generate facing the party. Randomize if we can't.
	local fd = nil
	local p_lev, p_x, p_y = dsb_party_coords()
	if (lev == p_lev) then
		fd = linedirfrom(xc, yc, p_x, p_y)
	end
	if (not fd) then
		fd = dsb_rand(0, 3)
	end
	
	if (monsters == 1) then
		local mon = dsb_spawn(exvar[id].generates, lev, xc, yc, CENTER)
		dsb_set_facedir(mon, fd)
		if (exvar[id].hp and exvar[id].hp >= 0) then
			dsb_set_maxhp(mon, exvar[id].hp)
			dsb_set_hp(mon, exvar[id].hp)
		end
	else
		local tp		
		if (mon_arch.size == 2) then tp = 0
		else tp = dsb_rand(0, 3) end
		
		for y=1,monsters do
			local mon
			if (mon_arch.size == 2) then
				sys_actual_level = lev
				mon = dsb_spawn(exvar[id].generates, LIMBO, 0, 0, 0)
				dsb_set_facedir(mon, fd)
				dsb_move(mon, lev, xc, yc, fd + tp)
			else
				mon = dsb_spawn(exvar[id].generates, lev, xc, yc, tp)
				dsb_set_facedir(mon, fd)
			end
			
			local sethp = nil
			if (exvar[id].hp and exvar[id].hp >= 0) then
				sethp = exvar[id].hp
			elseif (exvar[id].multiplier and exvar[id].multiplier > 0) then
				local base_hp = mon_arch.hp
				sethp = calc_monster_initial_hp(base_hp, lev, exvar[id].multiplier)
			end
			if (sethp) then
				dsb_set_maxhp(mon, sethp)
				dsb_set_hp(mon, sethp)
			end
			
			tp = (tp + 1) % 4		 
		end
	end
	
	if (exvar[id].sound) then
		local_sound(id, exvar[id].sound, true)
	end
	
	if (exvar[id].count) then
		if (not exvar[id].base_count) then
			counter_storebase(id)
		end		
		exvar[id].count = exvar[id].count - 1
	end
	
	-- No regen doesn't mean "never reactivate," it means "never deactivate!"
	if (exvar[id].regen) then
		dsb_set_gfxflag(id, GF_INACTIVE)
		dsb_msg(exvar[id].regen, id, M_NEXTTICK, 0)	
	end
end

function wall_appears(id, data)
	dsb_enable(id)
	local lev, xc, yc = dsb_get_coords(id)
	dsb_set_cell(lev, xc, yc, 1)
end

function wall_disappears(id, data)
	dsb_disable(id)
	local lev, xc, yc = dsb_get_coords(id)
	dsb_set_cell(lev, xc, yc, 0)
end

function wall_toggled(id, data)
	local lev, xc, yc = dsb_get_coords(id)
	if (dsb_get_cell(lev, xc, yc)) then
		wall_disappears(id, data)
	else
		wall_appears(id, data)
	end
end

function wall_destroyed(id, data)
	wall_disappears(id, data)
	self_destruct(id, data)
end

function func_caller(type, id, data, sender)
	local fname = exvar[id]["m_" .. type]
	local cfunc = string_function_handler(id, fname)
	if (cfunc) then
		local lev, xc, yc, tile = dsb_get_coords(id)
		cfunc(id, lev, xc, yc, tile, data, sender)
	end
end

function string_function_handler(id, string)
	local cfunc = dsb_lookup_global(string)
	if (cfunc) then
	    return cfunc
	end
	local exec_cfunc = loadstring(string)
	exec_cfunc()
	return nil
end

function turn_on_sender(id, data)
	dsb_enable(id)	
	use_exvar(id)
	local cc = exvar[id].current_code
	if (not cc) then cc = 0 end
	exvar[id].current_code = cc + 1
	
	if (exvar[id].data) then
		exvar[id].initial_data = exvar[id].data
	elseif (not exvar[id].no_param_copy) then
		exvar[id].initial_data = data
	end
	dsb_msg(0, id, M_NEXTTICK, exvar[id].current_code, id)

	if (exvar[id].sound and snd[exvar[id].sound]) then
	    dsb_sound(snd[exvar[id].sound])
	end
end

function turn_off_sender(id, data)
	dsb_disable(id)
	use_exvar(id)
	exvar[id].initial_data = nil
end

function toggle_sender(id, data)
	if (dsb_get_gfxflag(id, GF_INACTIVE)) then
		turn_on_sender(id, data)
	else
		turn_off_sender(id, data)
	end
end

function do_message_send(id, data)
	if (not dsb_get_gfxflag(id, GF_INACTIVE)) then 
		if (exvar[id] and exvar[id].msg) then
			if (data == exvar[id].current_code) then
				messages_to_targets(id, exvar[id].initial_data, exvar[id].target,
					exvar[id].msg, exvar[id].delay)

				if (exvar[id].repeat_rate and exvar[id].repeat_rate > 0) then
					dsb_msg(exvar[id].repeat_rate, id, M_NEXTTICK,
						exvar[id].current_code)
				end
			end
		end
	end
end

function party_conditions_met(id)

	if (exvar[id].block_dirs) then
		local lev, x, y, dir = dsb_party_coords()
		if (exvar[id].block_dirs[dir + 1]) then
			return false
		end
	end

	if (not exvar[id].party_contains) then
	    return true
	end
	
	if (exvar[id].party_contains == -1) then
		for ppos=0,3 do
		    if (dsb_ppos_char(ppos)) then
		        return false
			end
		end
		return true
	end
	
	if (exvar[id].party_contains == 0) then
	    local req_members = 1
	    local members = 0
	    if (exvar[id].party_members) then
			req_members = exvar[id].party_members
		end
		for ppos=0,3 do
		    if (dsb_ppos_char(ppos)) then
				members = members + 1
			end
		end
		if (members >= req_members) then
		    return true
		else
		    return false
		end
	end
	
	for ppos=0,3 do
		local char_id = dsb_ppos_char(ppos)
		if (char_id == exvar[id].party_contains) then
		    return true
		end
	end
	
	return false
end

function bit_tweak_check(id, operation, bitn)
	if (not exvar[id] or not exvar[id].bit_i or not exvar[id].bit_t) then
		return false, true
	end
	
	if (not exvar[id].bit_c) then
		exvar[id].bit_c = { exvar[id].bit_i[1], exvar[id].bit_i[2], exvar[id].bit_i[3], exvar[id].bit_i[4] }
	end
	
	if (operation ~= nil) then
		local sval = false
		if (operation == true or (operation == "toggle" and exvar[id].bit_c[bitn] == false)) then
			sval = true
		end
		exvar[id].bit_c[bitn] = sval
	end
	
	--[[ For debugging:
	local bp = function(txt, val) if (exvar[id]["bit_" .. txt][val]) then return "1" else return "0" end end 
	_dsb_write(debug_color, "TC " .. id .. " BITS " .. bp("c",1) .. bp("c",2) .. bp("c",3) .. bp("c",4) .. " VS "  .. bp("t",1) .. bp("t",2) .. bp("t",3) .. bp("t",4))
	--]]
	
	for bn=1,4 do
		if (exvar[id].bit_c[bn] ~= exvar[id].bit_t[bn]) then
			return true, false
		end
	end

	return true, true
end

function trigger_controller_sender(id, data, orig, deac, bit_operation)
	if (not exvar[id] or exvar[id].disabled) then
		return
	end
	
	if (not exvar[id].probability or
		dsb_rand(0, 99) < exvar[id].probability)
	then
		local bitnum = 1
		if (data >=2 and data <=4) then bitnum = data end
		
		-- bits_match is true if we are not using bits
		local have_bits, bits_match = bit_tweak_check(id, bit_operation, bitnum)
		local msg_rev = false
		if (exvar[id].send_reverse) then
			if (have_bits and not bits_match) then
				msg_rev = true
			elseif (deac and not have_bits) then
				msg_rev = true
			end
		end
		
		local possible_disable = false
		local reverse_only_match = false
		
		if (not msg_rev and exvar[id].send_reverse_only) then
			if (bits_match) then
				possible_disable = true
				reverse_only_match = true
			end
			msg_rev = nil
			bits_match = nil
		end
		
		if (bits_match or msg_rev) then
			local from = orig
			if (not exvar[id].originator_preserve) then from = id end
			if (party_conditions_met(id)) then
				messages_to_targets(from, exvar[id].data, exvar[id].target,
					exvar[id].msg, exvar[id].delay, msg_rev)
					
				possible_disable = true
			end
		end
		
		if (possible_disable and exvar[id].disable_self) then
			if (not have_bits or bits_match or reverse_only_match) then
				exvar[id].disabled = true
			end
		end
		
	end
end

function send_under_conditions(id, data, orig)
	trigger_controller_sender(id, data, orig, false, true)
end

function send_under_conditions_toggle(id, data, orig)
	trigger_controller_sender(id, data, orig, false, "toggle")
end

function possibly_reverse_under_conditions(id, data, orig)
	trigger_controller_sender(id, data, orig, true, false)
end

function reset_sequence(id, data)
	if (not exvar[id]) then return end
	exvar[id].seq = 1
end

function next_in_sequence(id, data)
	if (not exvar[id]) then return end
	if (not exvar[id].msg or not exvar[id].target) then return end
	
	if (type(exvar[id].target) ~= "table") then
		exvar[id].target = { exvar[id].target }
	end
	
	local number = 1
	if (exvar[id].seq) then
		number = exvar[id].seq
	end
	
	target = exvar[id].target[number]
	local msg = exvar[id].msg
	if (type(msg) == "table") then
		msg = exvar[id].msg[number]
	end
	local delay = 0
	if (exvar[id].delay) then
		delay = exvar[id].delay
		if (type(delay) == "table") then
			delay = exvar[id].delay[number]
		end
	end
	local data = 0
	if (exvar[id].data) then
		data = exvar[id].data
		if (type(data) == "table") then
			data = exvar[id].data[number]
		end
	end
	
	if (exvar[id].seq_q_r_msg) then
		dsb_msg(exvar[id].seq_q_r_delay,
			exvar[id].seq_q_r_target,
			exvar[id].seq_q_r_msg,
			exvar[id].seq_q_r_data, id)
	end
	
	dsb_msg(delay, target, msg, data, id)
	
	if (exvar[id].send_reverse) then
		exvar[id].seq_q_r_msg = reverse_msg(msg)
		exvar[id].seq_q_r_target = target
		exvar[id].seq_q_r_delay = delay
		exvar[id].seq_q_r_data = data
	end 
	
	number = number + 1
	if (not exvar[id].target[number]) then
		exvar[id].seq = 1
	else
		exvar[id].seq = number
	end
	
end

function counter_check(id, data)
	if (exvar[id].count == 0) then
	    got_triggered(id, data)
	    if (exvar[id].sound and snd[exvar[id].sound]) then
	        dsb_sound(snd[exvar[id].sound])
		end
		if (exvar[id].disable_self) then
			exvar[id].disabled = true
		end
	else
		if (not exvar[id].no_reverse) then
	    	got_untriggered(id, data)
	    end
	end
end

function counter_up(id, data)
	use_exvar(id)
	if (exvar[id].disabled) then return end
	
	if (not exvar[id].count) then exvar[id].count = 0 end
	if (not exvar[id].base_count) then
		counter_storebase(id)
	end
	exvar[id].count = exvar[id].count + 1
	counter_check(id, data)
end

function counter_down(id, data)
	use_exvar(id)
	if (exvar[id].disabled) then return end
	
	if (not exvar[id].count) then exvar[id].count = 0 end
	if (not exvar[id].base_count) then
		counter_storebase(id)
	end
	exvar[id].count = exvar[id].count - 1
	counter_check(id, data)
end

function counter_toggle(id, data, sender)
	if (not exvar[id]) then return end
	
	if (exvar[id].disabled) then return end
	
	local sender_id = "I" .. tostring(sender)
	local inc = exvar[id][sender_id]
	if (inc) then
		counter_up(id, data)
		exvar[id][sender_id] = nil
	else
		counter_down(id, data)
		exvar[id][sender_id] = true
	end
end

function counter_storebase(id)
	exvar[id].base_count = exvar[id].count
end

function counter_reset(id, data)
	if (not exvar[id] or not exvar[id].base_count) then return end
	exvar[id].disabled = nil
	exvar[id].count = exvar[id].base_count
	counter_check(id, data)
end

function reset_target_list(id, data)
	use_exvar(id)
	exvar[id].disabled = nil
	if (data and data > 0) then
		exvar[id].target = data
	end
end

function amb_startsound(id)
	if (not exvar[id]) then return end
	if (exvar[id].sound and not exvar[id].sound_id) then
	    local lev, x, y = dsb_get_coords(id)
	    local loop = true
	    if (exvar[id].no_loop) then loop = false end
	    
		if (exvar[id].global) then
	    	exvar[id].sound_id = dsb_sound(snd[exvar[id].sound], loop)
	    else
			exvar[id].sound_id = dsb_3dsound(snd[exvar[id].sound], lev, x, y, loop)
		end
		
		if (loop == false) then
		    exvar[id].sound_id = nil
		end
	end
	
	if (exvar[id].music) then
	    if (dsb_music(QUERY) ~= exvar[id].music) then
		    local loop = true
		    if (exvar[id].no_loop) then loop = false end
			dsb_music(exvar[id].music, loop)
		end
	end
end

function amb_stopsound(id)
	if (exvar[id]) then
		if (exvar[id].sound_id) then
	    	dsb_stopsound(exvar[id].sound_id)
	    	exvar[id].sound_id = nil
		end
		
		if (exvar[id].music) then
		    local current_music = dsb_music(QUERY)
		    if (current_music and exvar[id].music == current_music) then
		        dsb_music(nil)
			end
		end
	end
	
end

function amb_togglesound(id)
	if (exvar[id]) then
	    if (exvar[id].sound_id) then
	        amb_stopsound(id)
		else
		    amb_startsound(id)
		end
	end
end

function amb_stopandestroy(id)
	amb_stopsound(id)  
	self_destruct(id)
end

function perform_qswap(id, data)
	if (exvar[id]) then
		local swap_func = dsb_qswap

		if (exvar[id].full_swap) then
		    swap_func = dsb_swap
		end
		
		if (exvar[id].target_opby) then
			if (data and data > 0) then
		    	exvar[id].target = data
			else
			    exvar[id].target = nil
				return
			end
		end
		
		if (exvar[id].arch and exvar[id].target) then
			if (type(exvar[id].target) == "table") then
				for i=1,100 do
					local targ = exvar[id].target[i]
					if (not targ) then break end
					if (dsb_valid_inst(targ)) then
						swap_func(targ, exvar[id].arch)
					end
				end
			else
				if (dsb_valid_inst(exvar[id].target)) then
					swap_func(exvar[id].target, exvar[id].arch)
				end
			end
		end
	end
end

function perform_item_action(id, data, sender)
	local operand = nil
	local lev, xc, yc, pos = dsb_get_coords(id)
	local put_away = false
		
	use_exvar(id)
	local tm = exvar[id].target_mode
	if (tm == 1) then
		operand = data
	elseif (tm == 2) then
		operand = sender
	elseif (tm == 3) then
		local new_arch = exvar[id].target_arch
		if (not new_arch) then return end
		operand = dsb_spawn(FORCE_INSTANT, new_arch, lev, xc, yc, pos)
		if (not dsb_valid_inst(operand)) then
			return
		end
	elseif (tm == 4) then
		local optable = { }
		local opn = 1
		local search_arch = exvar[id].target_arch
		if (not search_arch) then return end
		for i in dsb_insts() do
			local iarch = dsb_find_arch(i)
			if (iarch == obj[search_arch]) then
				optable[opn] = i
				opn = opn + 1
			end 
		end
		if (not optable[1]) then return end
		operand = optable
	else
		operand = exvar[id].target
	end
	
	if (exvar[id].send_msg) then
		local target_obj = operand
		local opby_obj = data
		if (exvar[id].send_to_target) then
			target_obj = exvar[id].target
			opby_obj = operand
		end            
		if (not target_obj) then return end
		
		if (type(opby_obj) == "table") then
			for i in pairs(opby_obj) do	
				messages_to_targets(id, opby_obj[i], target_obj,
					exvar[id].send_msg, 0)
			end
		else
			messages_to_targets(id, opby_obj, target_obj,
				exvar[id].send_msg, 0)
		end
	end
	
	local do_move = false
	local mm = exvar[id].move_mode
	local dest_lev = lev
	local dest_x = xc
	local dest_y = yc
	local dest_f = pos
	local moving_obj = operand
	if (mm == 1) then
		if (exvar[id].move_lev) then dest_lev = exvar[id].move_lev end
		if (exvar[id].move_x) then dest_x = exvar[id].move_x end
		if (exvar[id].move_y) then dest_y = exvar[id].move_y end
		if (exvar[id].move_face) then dest_f = exvar[id].move_face end
		do_move = true	
	elseif (mm == 2) then
		local into_obj = exvar[id].target
		if (exvar[id].target_to_operand) then
			moving_obj = exvar[id].target
			into_obj = operand
		end
		if (not into_obj) then return end
		if (type(into_obj) == "table") then
			into_obj = into_obj[1]
		end		
		if (dsb_valid_inst(into_obj)) then
			local into_arch = dsb_find_arch(into_obj)
			local objs, num_objs = dsb_fetch(IN_OBJ, into_obj, VARIABLE, 0)
			if (not num_objs) then num_objs = 0 end 
			if (not into_arch.capacity or exvar[id].ignore_capacity or
				into_arch.capacity > num_objs)
			then			
				dest_lev = IN_OBJ
				dest_x = into_obj
				dest_y = VARIABLE
				dest_f = 0
				do_move = true
			end	
		else
			return
		end	
	elseif (mm == 3) then
		local at_obj = exvar[id].target
		if (exvar[id].target_to_operand) then
			moving_obj = exvar[id].target
			at_obj = operand
		end
		if (not at_obj) then return end
		if (type(at_obj) == "table") then
			at_obj = at_obj[1]
		end
		
		if (not dsb_valid_inst(at_obj)) then
			return
		end
		
		local alev, ax, ay, af = dsb_get_coords(at_obj)
		if (alev == MOUSE_HAND) then
			dest_lev, dest_x, dest_y = dsb_party_coords()
			local leader = dsb_get_leader()
			if (leader) then
				dest_f = dsb_ppos_tile(leader)
			else
				dest_f = dsb_rand(0, 3)
			end	
		elseif (alev == CHARACTER) then
			dest_lev, dest_x, dest_y = dsb_party_coords()
			local ppos = dsb_char_ppos(ax)
			if (ppos) then
				dest_f = dsb_ppos_tile(ppos)
			else
				dest_f = dsb_rand(0, 3)
			end	
		elseif (alev < 0) then
			return
		else			
			dest_lev = alev
			dest_x = ax
			dest_y = ay
			dest_f = af
			do_move = true	
		end	
	elseif (mm == 4) then
		local targ_char = exvar[id].inv_char
		local spot = 0
		put_away = exvar[id].inv_put_away
		
		if (targ_char == -1) then
			local leader = dsb_get_leader()
			if (leader) then
				targ_char = dsb_ppos_char(leader)
			end
		end
		
		if (not targ_char or targ_char <= 0) then return end
		
		if (not put_away) then
			if (type(moving_obj) == "table") then
				moving_obj = moving_obj[1]
			end			
			if (dsb_fetch(CHARACTER, targ_char, 0, 0)) then
				spot = 1
				if (dsb_fetch(CHARACTER, targ_char, 1, 0)) then
					return
				end
			end
		end
	
		dest_lev = CHARACTER
		dest_x = targ_char
		dest_y = spot
		dest_f = 0
		do_move = true

	elseif (mm == 5) then
		local mouse_obj = dsb_fetch(MOUSE_HAND, 0, 0, 0)
		if (mouse_obj) then return end
		if (type(moving_obj) == "table") then
			moving_obj = moving_obj[1]
		end
		dest_lev = MOUSE_HAND
		dest_x = 0
		dest_y = 0
		dest_f = 0
		do_move = true
	end
	
	gt_obj_data_table = { }
	if (do_move) then
		if (type(moving_obj) == "table") then
			for mov in pairs(moving_obj) do
				item_action_move(moving_obj[mov], dest_lev, dest_x, dest_y, dest_f, put_away)
			end
		else
			item_action_move(moving_obj, dest_lev, dest_x, dest_y, dest_f, put_away)
		end
	end	
end

function item_action_move(id, lev, x, y, f, put_away)

	-- Inventory moving object is already in place, do nothing
	if (put_away or lev == CHARACTER) then
		local clev, cx, cy = dsb_get_coords(id)
		while (clev == IN_OBJ) do
			clev, cx, cy = dsb_get_coords(cx)
		end
		if (clev == CHARACTER and x == cx) then
			if (put_away or cy == INV_L_HAND or cy == INV_R_HAND) then
				return
			end
		end
	end

	if (put_away) then
		put_object_away(x, id, gt_obj_data_table)
	else
		if (f == CENTER) then
			local id_arch = dsb_find_arch(id)
			if (id_arch.type == "THING") then
				f = dsb_rand(0, 3)
			end
		end
		if (dsb_valid_inst(id)) then 
			dsb_move(id, lev, x, y, f)
		end
	end
end

function re_enable(id, data)
	dsb_clear_gfxflag(id, GF_INACTIVE)
end

function object_enable(id)
	dsb_enable(id)
end

function object_disable(id)
	dsb_disable(id)
	if (exvar[id]) then
		exvar[id].tc = nil
	end
end

function object_toggle(id)
	dsb_toggle(id)
	if (exvar[id]) then
		if (dsb_get_gfxflag(id, GF_INACTIVE)) then
			exvar[id].tc = nil
		end
	end
end	

function trigger_reset(id)
	local disabled = dsb_get_gfxflag(id, GF_INACTIVE)
	use_exvar(id)
	
	if (not disabled) then object_disable(id) end
	
	exvar[id].disabled = nil
	
	-- For trigger controllers
	exvar[id].bit_c = nil
	-- For constant weight
	exvar[id].disable_count = nil
	
	if (not disabled) then object_enable(id) end
end

function object_expiration(id)
	local arch = dsb_find_arch(id)
	local stop_con = false
	if (arch.on_expire) then
		stop_con = arch:on_expire(id)
	end
	if (not stop_con) then
		do_convert(arch, id, "expire")
	end	
end

function make_noise_again(id)
	use_exvar(id)
	exvar[id].temporary_silence = nil
end

base_msg_handler = {
	[M_ACTIVATE] = "object_enable",
	[M_DEACTIVATE] = "object_disable",
	[M_TOGGLE] = "object_toggle",
	[M_CLEANUP] = "clean_up_target_exvars",
	[M_RESET] = "trigger_reset",
	[M_EXPIRE] = "object_expiration",
	[M_DESTROY] = "self_destruct"
}

teleporter_msg_handler = {
	[M_NEXTTICK] = "make_noise_again"
}

msg_sender_msg_handler = {
	[M_ACTIVATE] = "turn_on_sender",
	[M_DEACTIVATE] = "turn_off_sender",
	[M_TOGGLE] = "toggle_sender",
	[M_NEXTTICK] = "do_message_send"
}

probability_msg_handler = {
	[M_ACTIVATE] = "send_under_conditions",
	[M_DEACTIVATE] = "possibly_reverse_under_conditions",
	[M_TOGGLE] = "send_under_conditions_toggle",
}

sequencer_msg_handler = {
	[M_ACTIVATE] = "next_in_sequence",
	[M_RESET] = "reset_sequence"
}

qswapper_msg_handler = {
	[M_ACTIVATE] = "perform_qswap",
	[M_DEACTIVATE] = false,
	[M_TOGGLE] = "perform_qswap",
	[M_RESET] = "reset_target_list"
}

item_action_msg_handler = {
	[M_ACTIVATE] = "perform_item_action",
	[M_DEACTIVATE] = false,
	[M_TOGGLE] = "perform_item_action",
	[M_RESET] = "reset_target_list"
}

door_msg_handler = {
	[M_ACTIVATE] = "door_close",
	[M_DEACTIVATE] = "door_open",
	[M_TOGGLE] = "door_toggle",
	[M_NEXTTICK] = "door_tick",
	[M_TEMPORARY_REVERSE] = "door_whacked_something",
	[M_BASH] = "door_gotbashed"
}

vi_altar_msg_handler = {
	[M_NEXTTICK] = "revive_character"
}

shooter_msg_handler = {
	[M_ACTIVATE] = "shooter_shoot",
	[M_DEACTIVATE] = false,
	[M_TOGGLE] = "shooter_shoot",
	[M_NEXTTICK] = "re_enable"
}

movable_wall_msg_handler = {
	[M_ACTIVATE] = "wall_appears",
	[M_DEACTIVATE] = "wall_disappears",
	[M_TOGGLE] = "wall_toggled",
	[M_DESTROY] = "wall_destroyed"
}

cloud_msg_handler = {
	[M_NEXTTICK] = "cloud_shrink"
}

poison_cloud_msg_handler = {
	[M_NEXTTICK] = "poison_damage_inside",
	[M_ALT_NEXTTICK] = "poison_cloud_shrink"
}

torch_msg_handler = {
	[M_NEXTTICK] = "use_torch_charge"
}

light_msg_handler = {
	[M_NEXTTICK] = "light_fade_step"
}

shield_msg_handler = {
	[M_DESTROY] = "shield_shutdown"
}

generator_msg_handler = {
	[M_ACTIVATE] = "generate_monster",
	[M_DEACTIVATE] = false,
	[M_TOGGLE] = "generate_monster",
	[M_NEXTTICK] = "re_enable"
}

function_caller_msg_handler = {
	[M_ACTIVATE] = function(id, data, sender) func_caller("a", id, data, sender) end,
	[M_DEACTIVATE] = function(id, data, sender) func_caller("d", id, data, sender) end,
	[M_TOGGLE] = function(id, data, sender) func_caller("t", id, data, sender) end,
	[M_NEXTTICK] = function(id, data, sender) func_caller("n", id, data, sender) end,
	[M_RESET] = "reset_target_list"
}

ambient_sound_msg_handler = {
	[M_ACTIVATE] = "amb_startsound",
	[M_DEACTIVATE] = "amb_stopsound",
	[M_TOGGLE] = "amb_togglesound",
	[M_DESTROY] = "amb_stopanddestroy"
}

-- Native DSB counters have greater capabilities.
-- Keep the emulated counters separate in case they diverge somehow
counter_msg_handler = {
	[M_ACTIVATE] = "counter_down",
	[M_DEACTIVATE] = "counter_up",
	[M_TOGGLE] = "counter_toggle",
	[M_NEXTTICK] = "counter_storebase",
	[M_RESET] = "counter_reset"
}

x_relay_msg_handler = {
	[M_ACTIVATE] = got_triggered,
	[M_DEACTIVATE] = false,
	[M_TOGGLE] = got_triggered
}
x_counter_msg_handler = {
	[M_ACTIVATE] = counter_down,
	[M_DEACTIVATE] = counter_up,
	[M_TOGGLE] = counter_toggle
}
	
	