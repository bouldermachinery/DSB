-- System functions base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- If you want to override these functions, you should
-- do so in your own dungeon's startup.lua instead.

-- These are all called by the engine at various times
-- to allow for customizability of various events. you
-- NEED these functions or the game won't work!

-- Invoked when a monster is far from the party or on a different level.
function sys_ai_far(id)
	return (ai_monster_far(id))
end

-- Invoked when it's not a monster's turn, but it's looking around
function sys_ai_investigate(id, sight)
	return (ai_monster_investigate(id, sight))
end

-- Invoked when a monster is near a/the party and can attack or take action.
-- The function is passed whether it can see the given party, and which
-- party it is near (which is always 0 and can be ignored in a standard game)
function sys_ai_near(id, sight, targ_party)
	return (ai_monster(id, sight, targ_party))
end

-- This is the function called when an arch doesn't have a specific
-- on_impact to call. If on_impact returns true, this function will
-- not be called!
function sys_base_impact(id, hit_what, hit_ppos)
	standard_object_impact(id, hit_what, hit_ppos)
end

-- Calculate the maximum load someone can carry.
function sys_calc_maxload(who)
	local strength = dsb_get_stat(who, STAT_STR)/10
	local max_load = (strength + (10 - (strength/5)))
	max_load = attenuate_by_stamina(who, max_load)
	
	-- Before 0.58, injuries didn't impact your maximum load at all.
	-- This was a bug!
	local zones = inventory_info.injurable_zones
	local sub = nil
	for i=1,#zones do
		if (dsb_get_injury(who, zones[i])) then
			if (zones[i] == INV_FEET) then
				sub = 4
			elseif (not sub) then	
				sub = 8
			end
		end
	end
	if (sub) then
		max_load = max_load - math.floor(max_load/sub)
	end

	if (ch_exvar[who]) then
		if (ch_exvar[who].load_bonus) then
			local bonus_load = (max_load*ch_exvar[who].load_bonus)
			bonus_load = math.floor(bonus_load / 16)
			max_load = max_load + bonus_load
		end 
	end
	
	return (max_load * 10)
end

-- Calculates the sight range of a monster
function sys_calc_sight(id, total_light)
	local arch = dsb_find_arch(id)
	
	local range = arch.perception
	if (not range) then range = 1 end
	if (not arch.darkvision) then
		if (total_light > 84) then total_light = 84 end
		range = range - ((84-total_light) / 12)
	end
	
	if (arch.awareness) then
		local blind_range = arch.awareness
		if (blind_range > range) then
			return blind_range
		end
	end
	
	if (range < 1) then range = 1 end
	return range
end

-- Given a time interval, calculate what time interval is "short"
-- relative to that time interval. Used by the monster AI.
function sys_calc_shortinterval(interval)
	local shortinterval
	
	if (interval < 4) then shortinterval = 1
	elseif (interval < 10) then shortinterval = math.floor(interval / 2)
	else shortinterval = 5 end
	
	return shortinterval
end

-- Called when the view is changed to a new party
-- We just ensure that torches don't light the wrong person
function sys_change_view(new_party)
	set_torch_levels()
end

-- Invoked when a character dies.
function sys_character_die(ppos, who, mouse_drop)
	
	drop_all_items_and_magicshields(ppos, who, mouse_drop)

	local lev, xc, yc = dsb_party_coords()
	local tile_pos = dsb_ppos_tile(ppos)
	local bones_id = dsb_spawn("bones", lev, xc, yc, tile_pos)
	exvar[bones_id] = { owner = who }

end

-- This happens after a character is reincarnated. Nuke all
-- their skills and jumble their stats around.
function sys_character_reincarnated(ppos, who)

	for main=0,3 do
	    for sub=0,4 do
			dsb_set_xp(who, main, sub, 0)
			dsb_set_temp_xp(who, main, sub, 0)
		end
	end
	
	if (dsb_get_gameflag(GAME_CSB_REINCARNATION)) then
	    for v=HEALTH,MANA do
			local bar = dsb_get_bar(who, v)
			dsb_set_bar(who, v, bar/2)
			local maxbar = dsb_get_maxbar(who, v)
			dsb_set_maxbar(who, v, maxbar/2)
		end

		for v=STAT_STR,STAT_AFI do
		    local stat = dsb_get_stat(who, v)
		    stat = (stat * 14) / 16
		    if (stat < 300) then stat = 300 end
		    dsb_set_stat(who, v, stat)
			dsb_set_maxstat(who, v, stat)
		end
	end
	
	for n=1,12 do
	    local attr = dsb_rand(STAT_STR, STAT_AFI)
	    
	    local val = dsb_get_stat(who, attr)
	    local maxval = dsb_get_maxstat(who, attr)
	    
	    dsb_set_stat(who, attr, val + 10)
	    dsb_set_maxstat(who, attr, maxval + 10)
	end

	local whoname = dsb_get_charname(who)
	dsb_write(player_colors[ppos + 1], whoname .. msg_reincarnated)
end

-- This happens after a character is resurrected.
-- For DM, considerably simpler than reincarnation.
function sys_character_resurrected(ppos, who)
	local whoname = dsb_get_charname(who)
	dsb_write(player_colors[ppos + 1], whoname .. msg_resurrected)
end

-- When you click the "mouth" icon on the inventory with something
function sys_click_mouth(who, what)
	local arch = dsb_find_arch(what)
	local stop_con = false
	
	if (arch.on_consume or arch.convert_consume) then
		if (arch.on_consume) then
			stop_con = arch:on_consume(what, who)
		end
		
		if (not stop_con) then
			do_convert(arch, what, "consume")
		end
	end
end

-- Executed when the party enters a new level (via stairs, pit, or teleporter)
-- By default, nothing special-- the engine handles everything usual.
-- Note that this level may not be the one being viewed, if you're using
-- multiple parties. You'll want "sys_viewto_level" for that.
function sys_enter_level(level)
	return nil
end

-- Everyone's dead. Go "AAAAH!" and wait for a little bit.
function sys_everyone_dead(last_dead)
	dsb_sound(snd.scream)

	return 70 -- amount of time to pause before restart
end

-- Tell a flying object that should only be flying to expire if
-- it runs out of power. Otherwise do nothing, it'll just drop.
function sys_flyer_drop(id)
	local arch = dsb_find_arch(id)
	if (arch.flying_only) then
		dsb_msg(0, id, M_EXPIRE, 0)
	end 
end

-- This is used if you want to create some kind of "no magic zone"
-- Default DM of course has nothing like this, so it's just false.
function sys_forbid_magic(ppos, who)
	return false
end                                   

-- This is used if you want to create some kind of "holding zone"
-- Default DM of course has nothing like this, so it's just false.
function sys_forbid_move(lev, xc, yc)
	return false
end

-- This is used if you want to create some kind of "no save zone"
-- Default DM of course has nothing like this, so it's just false.
function sys_forbid_save()
	return false
end

-- This is used if you want to create some kind of "no sleep zone"
-- Default DM of course has nothing like this, so it's just false.
function sys_forbid_sleep()
	return false
end

-- This function is called when the game's main loop begins.
function sys_game_beginplay()
	gt_highlight = nil
	clear_spell_flash()
	return nil
end

-- This function is called when the game is saved.
function sys_game_save() 
	return nil
end

-- This function is called when the game is ready to begin.
-- In the default dungeon, it invokes a fullscreen renderer that shows
-- the front door animation.
--
-- sys_game_start's return value is interpreted as follows:
-- nil or 0         	enter
-- true or 1        	resume
-- anything else    	quit
--
-- See base/render.lua for the front_door function itself.
function sys_game_start(savegames)
	return (front_door(savegames))
end

-- This function is called when the game is reloaded, either from
-- the "The End" screen or from "Resume" at the front door.
function sys_game_load()
	return nil
end

-- This function is called when characters are exported (like CSB)
function sys_game_export()
	return nil
end

-- This function multiplies the monster's base HP times the xp
-- multiplier for the level and applies a random factor. This formula
-- is taken directly out of CSBwin. See util.lua.
function sys_init_monster_hp(base_hp, level)
	return (calc_monster_initial_hp(base_hp, level, nil))
end

-- Called when objects are moved around in the inventory.
-- It is passed the character index, the inventory slot number,
-- what is being picked up (if there's something there, otherwise nil)
-- what is being put down (if something in hand, otherwise nil)
-- whether the action is before or after the item is in place, and
-- whether it's being forced into that position (via a dsb_spawn/move)
-- If force is false, then a return of true lets the item go into
-- the slot, and a return value of false means that it won't.
-- This is the reverse of the old to_* and from_* functions. They
-- returned true if the object should be blocked. They keep their
-- current sense and are reversed by this function.
function sys_inventory(who, slot, pickup, putdown, when, force)
	local from_word
	if (when) then from_word = "after_from_"
	else from_word = "from_" end

	local to_word
	if (when) then to_word = "after_to_"
	else to_word = "to_" end
	
	local slotname = inventory_info[slot].name
	
	if (not when) then
	    local fit = false
	    
		if (force or not putdown) then
		    fit = true
		else
		    local arch = dsb_find_arch(putdown)
		    
		    if (slot <= INV_L_HAND) then 
		    	fit = true
				if (arch.fit_hands == false) then fit = false end
		    elseif (arch.no_fit_inventory) then fit = false
		    elseif (inventory_info[slot].take_all) then fit = true
		    else
		        fit = arch["fit_" .. slotname]
		        if (slot == INV_QUIVER and not fit) then
		            fit = arch.fit_sheath
				end
				if (type(fit) == "function") then
					fit = fit(arch, putdown, who)
				end
		    end
		end
		
		if (not fit) then return false end
	end
	
	if (pickup) then
	    local arch = dsb_find_arch(pickup)
		if (arch[from_word .. "anywhere"]) then
		    if (arch[from_word .. "anywhere"](arch, pickup, who) ~= nil) then
		        return false
			end
		end
		if (arch[from_word .. slotname]) then
		    if (arch[from_word .. slotname](arch, pickup, who) ~= nil) then
		        return false
			end
		end
		
		if (when) then
			handle_object_properties("from", arch, pickup, who, slotname)
		end
		
	end
	
	if (putdown) then
	    local arch = dsb_find_arch(putdown)
		if (arch[to_word .. "anywhere"]) then
			arch[to_word .. "anywhere"](arch, putdown, who)
		end
		if (arch[to_word .. slotname]) then
			arch[to_word .. slotname](arch, putdown, who)
		end
		
		if (when) then
			handle_object_properties("to", arch, putdown, who, slotname)
			
			-- Moving it around eliminates the object's "memory"
			if (exvar[putdown]) then
				exvar[putdown].last_owner = nil
			end
		end
		
	end
	
	return true
end

-- Called when the inventory is viewed. By default, nothing special.
function sys_inventory_enter(ppos, who)
	return
end

-- Called when the inventory is exited. By default, nothing special.
function sys_inventory_exit(ppos, who)
	return
end

-- This is code that is executed when any monster anywhere dies,
-- so we create whatever death cloud is defined, or a base if
-- nothing is, and drop anything the monster is carrying.
function sys_kill_monster(id)
	local m_arch = dsb_find_arch(id)
	local lev, xc, yc, tile = dsb_get_coords(id)
	local cloud_name = "monster_death"
	local sdelay = 1
	local ddelta = 1
	local dsize = 16
	
	if (lev < 0) then
		return
	end
	
	if (m_arch.death_cloud) then
	    cloud_name = m_arch.death_cloud
	end
	
	if (m_arch.death_delta) then
	    ddelta = m_arch.death_delta
	end

	local cloud_id = dsb_spawn(cloud_name, lev, xc, yc, tile)
	if (m_arch.death_size) then
	    dsize = m_arch.death_size
	end
	dsb_set_charge(cloud_id, dsize)
	exvar[cloud_id] = { delta = ddelta }
	
	-- Stop any looping sounds
	stop_sound_handle(id, "step_sound")
	stop_sound_handle(id, "attack_sound")
	stop_sound_handle(id, "attack_sound_ranged") 
	
	-- Play the death sound
	if (m_arch.death_sound) then
	    local_sound(cloud_id, m_arch.death_sound)
	    sdelay = 3
	end
	
	-- Call a hook function to help in adding new behavior
	h_monster_died(id)
	
	-- Drop things this monster is carrying
	local inside_obj = dsb_fetch(IN_OBJ, id, -1, TABLE)
	if (inside_obj) then
		local i
		for i in pairs(inside_obj) do
			local rtile = tile
			local v = inside_obj[i]
			
		    if (rtile == CENTER) then
		        rtile = dsb_rand(0, 3)
			elseif (m_arch.size == 2) then
			    if (dsb_rand(0, 1) == 0) then
			    	rtile = dsb_tileshift(rtile, dsb_get_facedir(id))
				end
			end
			
		    dsb_move(v, lev, xc, yc, rtile)
		    local droparch = dsb_find_arch(v)
		    if (droparch.type == "THING") then
			    local hitsound = base_hit_sound
			    if (droparch.hit_sound) then
			        hitsound = droparch.hit_sound
				end
			    dsb_delay_func(sdelay, function()
			        dsb_3dsound(hitsound, lev, xc, yc)
				end)
			    sdelay = sdelay + 1
			    if (sdelay > 8) then sdelay = 2 end
			end
		end
	end
end

-- Called when a monster is spawned on or changes levels
-- Useful when emulating DM or CSB's allowed monster lists
function sys_monster_enter_level(id, lev)
	if (not monster_level_info) then return end
	
	if (monster_level_info[lev]) then
		local mon_arch = dsb_find_arch(id)
		local thislev = monster_level_info[lev]
		for i=1,#thislev do
			local curmon = thislev[i]
			
			if (type(curmon) == "string") then
				if (mon_arch == obj[curmon]) then
					return
				end
			else
				-- This allows on the fly monster substitution for
				-- things like the different colored worms in CSB
				if (type(curmon[1]) == "string") then
					if (mon_arch == obj[curmon[1]]) then
						dsb_qswap(id, curmon[2])
						return
					end
				end
			end
		end
		
		-- It's not allowed. Kill it!
		dsb_msg(0, id, M_DESTROY, 0)
	end
end

-- A generic mouse throw
-- A specific object's "on_throw" is called by the engine directly.
function sys_mouse_throw(id, ppos, who, side)
	local arch = dsb_find_arch(id)
	local lev, xc, yc, travel_dir = dsb_party_coords()
	local throw_power, damage, delta = calc_throw(who, id, mouse_throwing_hand)
	local tile_pos = (travel_dir + side) % 4

	dsb_pop_mouse()
	dsb_set_openshot(id, travel_dir)    -- to not get smacked immediately
	dsb_shoot(id, lev, xc, yc, travel_dir, tile_pos, throw_power, damage, delta)
	
	dsb_sound(base_throw_sound)
	
	dsb_set_idle(ppos, dsb_get_idle(ppos) + 5)
end

-- Does a flying object hit the party?
-- For now it always does.
function sys_party_col(what, ppos, targ_party)
	return true
end

-- Called every time the party successfully moves under its own power
function sys_party_move()
	local footp = dsb_get_condition(PARTY, C_FOOTPRINTS)
	if (footp) then
	    local lev, xc, yc = dsb_party_coords()
	    local fpid = dsb_spawn("footprints", lev, xc, yc, CENTER)
		exvar[fpid] = { index = g_footprint_counter }
		g_footprint_counter = g_footprint_counter + 1
	end

	local ppos
	local have_party = false
	local slowest_speed = 0
	for ppos=0,3 do
		local who = dsb_ppos_char(ppos)
		if (valid_and_alive(who)) then
			local l = dsb_get_load(who)
			local ml = dsb_get_maxload(who)
			burn_stamina(who, ((3*l)/ml)+1)
			have_party = true
			
			local load_level = compute_load_level(l, ml)
			local my_delay				
			if (load_level == LOAD_RED) then				
				my_delay = 3 + (4*(l-ml))/ml
			elseif (load_level == LOAD_YELLOW) then
				my_delay = 2
			else
				my_delay = 1
			end
			
			if (dsb_get_injury(who, INV_FEET)) then
				my_delay = my_delay + 1
				if (dsb_get_injury(who, INV_FEET) > 70) then
					my_delay = my_delay + 1
				end	
			elseif (ch_exvar[who] and ch_exvar[who].speed_bonus) then
				my_delay = my_delay - ch_exvar[who].speed_bonus
			end
			
			if (my_delay > slowest_speed) then
				slowest_speed = my_delay
			end	
		end
	end	
	g_last_party_move = 0
	
	-- Hook this to allow easier overriding and modification
	slowest_speed = h_party_move(have_party, slowest_speed) 
	
	-- Returns the time until you can move again. The ghost moves
	-- immediately, everyone else has to wait for the slowest member.
	if (have_party) then
		return slowest_speed
	else
		return 0
	end
end

-- Called any time the party order is rearranged
-- Does nothing for now.
function sys_party_rearrange(ppos, oldpos, newpos)
	return nil
end

-- Called any time the party changes direction voluntarily or otherwise
-- Does nothing for now.
function sys_party_turn(dir)
	return nil
end

-- This function is called when the champion's bars are clicked with
-- an object. Return false to pop up the inventory. Return true if
-- the item has been automatically put away. The put_object_away
-- function is defined in base/util.lua.
function sys_put_away(ppos, what)
	if (what) then
		local who = dsb_ppos_char(ppos)
		
		return (put_object_away(who, what))
	end
end

-- Called when the middle button is clicked. Attempt to put away
-- the currently held object in a sensible way.
function sys_put_away_click(what)
	if (what) then
		local leader_ppos = dsb_get_leader()
		
		-- Arrows go back to whoever shot them
		if (exvar[what] and exvar[what].last_owner) then
			local last_owner = exvar[what].last_owner
			if (valid_and_alive(last_owner)) then
				local lo_ppos = dsb_char_ppos(last_owner)
				if (lo_ppos) then
					if (put_object_away(last_owner, what, nil, true)) then return end
				end
			end
		end
		
		put_object_away(dsb_ppos_char(leader_ppos), what)
	end
end
		
-- When an individual rune is cast, this function is called.
-- This handles calculating the rune costs and deducting the
-- mana (assuming you have enough, anyway), and adding the
-- cast rune to the pending spell.
function sys_rune_cast(ppos, who, rune, ...)
    local arg = {...}

	local mana = dsb_get_bar(who, MANA)
	if (mana <= 0) then return false end
	
	local runecost = magic_info.rune_costs[rune]
	local power = arg[1]
	if (power > 0) then
		runecost = runecost * magic_info.power_multipliers[power]
	end
	
	if (mana >= runecost) then
		dsb_set_bar(who, MANA, mana - runecost)
		
		gt_spell_flash = rune
		
		if (arg[magic_info.rune_sets] > 0) then
		    dsb_set_pendingspell(ppos, rune)
			return true
		end
		
		local i
		for i=1,magic_info.rune_sets do
			if (arg[i] == 0) then
			    arg[i] = rune
			    break
			end
		end
        dsb_set_pendingspell(ppos, unpack(arg))
		return true
	end
	
	return false
end

-- This function is called when the party goes to sleep. Right now,
-- it doesn't do anything.
function sys_sleep()
	return nil
end

-- This function controls all spells, the runes are passed in args
-- Realistically, unless you're totally revamping the magic system, there's
-- no point in touching this function. You can create new spells by
-- changing the "spell" table. See base/magic.lua.
function sys_spell_cast(ppos, who, ...)
    local arg = {...}

	local namewho = dsb_get_charname(who)
	
	-- Turn the spell into a simple number
	local power = arg[1]
	local i
	local sr = 0
	for i=2,8 do
		if (arg[i] == 0) then break
		else sr = sr * 10 end
		sr = sr + (arg[i] - magic_info.runes_per_set*(i-1))
	end
	
	if (spell[sr]) then
	    local needskill = spell[sr].difficulty + power
	    local xp_gain = dsb_rand(0,7) + 16*needskill
	    
		xp_gain = xp_gain + ((power - 1) * spell[sr].difficulty * 8)
	    xp_gain = xp_gain + (needskill * needskill)
	    
	    -- Changed in DSB 0.54: A headache now makes your magic more
	    -- likely to fail. It used to slow the spell casting time down.
		-- I added this because otherwise a head injury doesn't hurt you
	    -- at all.
	    local injval = dsb_get_injury(who, INV_HEAD)
	    local hurtpenalty = 0
	    if (injval) then
			hurtpenalty = injval / 5
			if (hurtpenalty > 15) then
			    hurtpenalty = 15
			end
	    end	
	    
		-- +1 because no skill is level 1 in DM, but 0 in DSB
	    local skill = determine_xp_level(who, spell[sr].class, spell[sr].subskill) + 1
	    if (needskill > skill) then
   			local wisdom = (dsb_get_stat(who, STAT_WIS)/10) + (15 - hurtpenalty)
			if (wisdom > 115) then wisdom = 115 end
			local fail_xp_gain = xp_gain
			local checks
			for checks=1,(needskill-skill) do
			    fail_xp_gain = fail_xp_gain / 2
			end
			for checks=1,(needskill-skill) do
			    local randchance = dsb_rand(0, 127)
				if (randchance > wisdom) then
					needs_more_practice_with_spell(namewho, sr)
	    			xp_up(who, spell[sr].class, spell[sr].subskill,
						fail_xp_gain)
					return false
				end
			end
	    end
	    
		if (spell[sr]:cast(ppos, who, power, skill)) then
		    return true
		else
		    local itime = dsb_get_idle(ppos)
		    if (itime > 80) then itime = 80 end
		    dsb_set_idle(ppos, itime + spell[sr].idleness)
		    
		    xp_up(who, spell[sr].class, spell[sr].subskill, xp_gain)
		end
		
	else
		mumbles_meaningless_spell(namewho)
	end
	
end

-- Handle positive valued SYSTEM messages.
-- It's up to the designer what they are and what they'll do.
function sys_system_message(msg, data, ext_data)
	return nil
end

-- Runs every tick, so don't do anything too complicated in here!
function sys_tick(tick_clock)
	g_last_party_move = g_last_party_move + 1
	g_last_monster_attack = g_last_monster_attack + 1
	
	if (g_total_pit_damage) then
		if (g_total_pit_damage > 0) then		
			pit_damage(g_total_pit_damage)
		end
		g_total_pit_damage = nil
	end
	
	for ppos=0,3 do
		local who = dsb_ppos_char(ppos)
		
		-- You might want to override h_party_char_tick for various
		-- tasks performed on a given character. It usually is less
		-- messy than trying to override this function.
		h_party_char_tick(ppos, who, tick_clock)
		
		if (ch_exvar[who]) then
	        db = ch_exvar[who].ddefense
			if (db) then
							
				if (db > 0) then
					if (db <= 2) then db = 0
					else db = db - 2 end
			    elseif (db < 0) then
			    	if (db >= -2) then db = 0
					else db = db + 2 end
			    end
			    
			    if (db == 0) then
			        ch_exvar[who].ddefense = nil
				else
				    ch_exvar[who].ddefense = db
				end
			end
		end
	end
end

-- Runs every frame, so be even more careful.
-- Not even going to define it since it's not used in base DM.
--[[
function sys_tick_frame()
	return nil
end
]]

-- This function handles stat regeneration, burning of food, and so on
-- Based on CSBwin TenSecondUpdate
function sys_update(clock_tick)
	local asleep = dsb_get_sleepstate()
	local move_time = g_last_party_move
	
	-- Emulation of crazy code in DM that bases events on the gameclock.
	-- This weird timing will now remain even when sleeping. Instead of
	-- doing anything here, the core engine will simply call sys_update
	-- 4 times as often, but not tick the regen clock for the three
	-- "extra" calls. When not asleep, "clock_tick" is always true.
	-- This is almost exactly the way DM does it.
	if (clock_tick) then
		g_rclock = g_rclock + 32
		if (g_rclock >= 144) then
			g_rclock = 0
		elseif (g_rclock == 128) then
			g_rclock = 16
		end
	end
	 
	local clock_val = g_rclock
		
	for ppos=0,3 do
		local who = dsb_ppos_char(ppos)
		if (valid_and_alive(who)) then
			local regen_mana_boost = 0
			local c
			local sub
			
			if (ch_exvar[who]) then
				if (ch_exvar[who].regen_mana_boost) then
					regen_mana_boost = ch_exvar[who].regen_mana_boost
				end	
			end
			
			for c=0,3 do
			    for sub=0,4 do
					local skv = dsb_get_temp_xp(who, c, sub)
					if (skv > 0) then
					    skv = skv - 1
						dsb_set_temp_xp(who, c, sub, skv)
					end
				end
			end
			
			-- I never could find any special code for handling luck; I think this
			-- is probably because there is no special code. As of DSB 0.58, Luck is
			-- handled like every other stat, right here.
			local stat
		    for stat=STAT_STR,STAT_LUC do
				local s_val = dsb_get_stat(who, stat)
				local s_max_val = dsb_get_maxstat(who, stat)
				if (s_val > s_max_val) then
					s_val = s_val - 10
					
					-- Tweak as of DSB 0.52 to prevent massive potion exploits
					-- Very high boosts can drop off faster
					if (s_val > (2*s_max_val) and dsb_rand(0, 2) ~= 0) then
						if (s_max_val > 0) then
							local ext_dropoff = math.floor(10 * ((s_val / s_max_val) - 1))						
							s_val = s_val - ext_dropoff
						end
					end
					
					if (s_max_val > s_val) then s_val = s_max_val end
					
				elseif (s_max_val > s_val) then
					s_val = s_val + 10
					if (s_val > s_max_val) then s_val = s_max_val end
				end
				dsb_set_stat(who, stat, s_val)
		    end
		    
			-- But we'll at least let curses matter a little bit
			if (dsb_rand(0, 7) == 0) then
				local luck = dsb_get_stat(who, STAT_LUC)
				local maxluck = dsb_get_maxstat(who, STAT_LUC)
				
				if (ch_exvar[who]) then
				    local cursed = false
					if (ch_exvar[who].curses) then
					    cursed = true
						luck = luck - (ch_exvar[who].curses * (dsb_rand(5, 60)))
					end
					if (ch_exvar[who].luck_bonus) then
					    luck = luck + dsb_rand(10, 50)
					    if (not cursed and luck < maxluck/4) then
					        luck = maxluck/4
						end
					end
				end
				
				if (luck < 0) then luck = 0 end

				dsb_set_stat(who, STAT_LUC, luck)
			end

		    
			local stamina = dsb_get_bar(who, STAMINA)
			local max_stamina = dsb_get_maxbar(who, STAMINA)
			local d_stamina = 0
			local loop_reps = 4
			local tmp_stamina = max_stamina / 2
			
			-- Solve a glitch that eats all your food because
			-- a stamina of 0 causes loop_reps to go crazy
			if (stamina < 1) then stamina = 1 end
			                   
			while (stamina < tmp_stamina) do
			    loop_reps = loop_reps + 2
			    tmp_stamina = tmp_stamina / 2
			end
			local dd_stamina = math.floor(max_stamina/256) - 1
			if (dd_stamina < 1) then
			    dd_stamina = 1
			elseif (dd_stamina > 6) then
			    dd_stamina = 6
			end
			if (asleep) then
			    dd_stamina = dd_stamina * 2
			end
		    if (g_last_party_move > 80) then
		    	dd_stamina = dd_stamina + 1
		    	if (g_last_party_move > 250) then
		    		dd_stamina = dd_stamina + 1
		    	end
		    end		    
		    repeat
		    	local half = false
		    	if (loop_reps <= 4) then
		    		half = true
		    	end
		    	
		    	local food = dsb_get_food(who)
		    	if (food < 512) then
		    		if (half) then
		    			d_stamina = d_stamina + dd_stamina
		    			food = food - 2
		    		end
		    	else
		    		if (food >= 1024) then
		    			d_stamina = d_stamina - dd_stamina
		    		end
		    		
		    		if (half) then
		    			food = food - dsb_rand(1, 3)
		    		else
		    			food = food - (loop_reps/2)
		    		end
		    	end
		    	dsb_set_food(who, food)
		    	
		    	local water = dsb_get_water(who)
		    	if (water < 512) then
		    		if (half) then
		    			d_stamina = d_stamina + dd_stamina
		    			water = water - 1
		    		end
		    	else
		    		if (water >= 1024) then
		    			d_stamina = d_stamina - dd_stamina
		    		end
		    		
		    		if (half) then
		    			water = water - 1
		    		else
		    			water = water - (loop_reps/2)
		    		end
		    	end	
				dsb_set_water(who, water)	    	
		    			    	
		    	loop_reps = loop_reps - 1
		    	if (loop_reps <= 0) then
		    		break
		    	end
		    until (stamina >= max_stamina + d_stamina)

			if (stamina <= max_stamina or d_stamina > 0) then
				if (d_stamina < 0) then
					if (stamina > max_stamina) then
						d_stamina = 0
					elseif (d_stamina < stamina - max_stamina) then
						d_stamina = stamina - max_stamina
					end
				end
				
		    	burn_stamina(who, d_stamina)
		    end

		    local hp = dsb_get_bar(who, HEALTH)
		    local max_hp = dsb_get_maxbar(who, HEALTH)		    
		    if (hp < max_hp) then
				stamina = dsb_get_bar(who, STAMINA)
				if (stamina >= (max_stamina / 4)) then
					local vit = (dsb_get_stat(who, STAT_VIT)/10) + 12					
					if (vit > clock_val) then
						local mhp = max_hp/128
						local rec = dsb_rand(mhp+5, mhp+15)
						if (asleep) then
							rec = rec * 2
						end
						if (ch_exvar[who] and ch_exvar[who].health_bonus) then
							rec = rec + (ch_exvar[who].health_bonus * (rec/2 + 10))
						end
						
						if (hp + rec > max_hp) then
							dsb_set_bar(who, HEALTH, max_hp)
						else
							dsb_set_bar(who, HEALTH, hp + rec)
						end						
					end
				end
			end
			
			local mana = dsb_get_bar(who, MANA)
			local max_mana = dsb_get_maxbar(who, MANA)
			if (mana > max_mana) then
				mana = mana - dsb_rand(5, 15)
				if (mana < max_mana) then
					mana = max_mana
				end
				dsb_set_bar(who, MANA, mana)	
			elseif (mana < max_mana) then
				local skills = determine_xp_level(who, CLASS_WIZARD, 0)
				skills = skills + determine_xp_level(who, CLASS_PRIEST, 0)
				-- +1 for each because "neophyte" is level 1 in DM, but 0 in DSB
				skills = skills + 2
				local level = skills + math.floor(dsb_get_stat(who, STAT_WIS)/10)
				
				if (level + regen_mana_boost >= clock_val) then
					local rec = (max_mana)/400
					if (asleep) then
						rec = rec * 2
					end
					rec = rec + 1
					local multiplier = 7
					local sk_targ = 16 - (skills + math.floor(regen_mana_boost / 4))
					if (sk_targ > multiplier) then
						multiplier = sk_targ
					end
					
					if (dsb_get_bar(who, STAMINA) > multiplier * rec) then
						burn_stamina(who, multiplier * rec)
						
						local scaled_rec = (rec * 10) + dsb_rand(-5, 5)
						mana = mana + scaled_rec
					end
					
					if (mana > max_mana) then
						dsb_set_bar(who, MANA, max_mana)
					else
						dsb_set_bar(who, MANA, mana)
					end
				end
			end
			
			-- User code to do a character update
			h_char_update(who, clock_tick)
					    
		end
	end

end

-- When your view changes to a different level, this function is
-- executed. This may not necessarily have anything to do with a 
-- physical move. Overrides are deleted, which may not be what you
-- want, but usually is.
function sys_viewto_level(level)
	dsb_override_floor(nil)
	dsb_override_roof(nil)
	return nil
end

function sys_wall_hit(level, xc, yc, dir)
	local hitpos1, hitpos2

	hitpos1 = dsb_tile_ppos(dir)
	hitpos2 = dsb_tile_ppos((dir+1) % 4)
	if (not hitpos1 and not hitpos2) then
		hitpos1 = dsb_tile_ppos((dir+2) % 4)
		hitpos2 = dsb_tile_ppos((dir+3) % 4)
	end

	dsb_sound(base_wall_hit_sound)

	-- DM actually used its whole messy damage formula
	-- for this. This is pretty much the same result in
	-- practice.
	if (hitpos1) then
		damage_ppos(hitpos1, HEALTH, dsb_rand(1, 3))
	end
	if (hitpos2) then
		damage_ppos(hitpos2, HEALTH, dsb_rand(1, 3))
	end
end

-- type 1 is solid wall
-- type 4 is fake wall
function sys_wall_knock(type)
	local lev, xc, yc, face = dsb_party_coords()
	
	if (type == 4) then
	    dsb_hide_mouse()
     	dsb_delay_func(2, dsb_show_mouse)
	else
		dsb_sound(snd.thud)
	end
end

-- Something is incoming! Warn the monsters.
function sys_warning_flying_impact(what, lev, x, y, tile)
	local whatshere = dsb_fetch(lev, x, y, tile)
    if (whatshere) then
		local i
		for i in pairs(whatshere) do
		    local inst = whatshere[i]
		    local arch = dsb_find_arch(inst)
			if (arch.on_incoming_impact) then
				arch:on_incoming_impact(inst, what)
			end
		end
	end
end

-- objects that have no msg_handler defined use this one
-- and as of v0.37 messages will fallthrough
sys_default_msg_handler = base_msg_handler

