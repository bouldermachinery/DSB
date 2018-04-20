-- Attack methods base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- These functions are not called by the engine directly,
-- but they are used by objects and so you should be careful
-- about overriding them.

-- utility function to handle a lot of dirty work
function method_finish(m, ppos, who, what, xxp)
	if (xxp == nil or xxp) then
	    if (xxp == nil or xxp == true) then xxp = 1 end
	    local extra = 0
	    if (m.extra_xp) then extra = m.extra_xp end
		xp_up(who, m.xp_class, m.xp_sub, xxp * (m.xp_get + extra))
	end
	att_idle(ppos, m.idleness)
	burn_stamina(who, m.stamina_used)
	if (m.charge) then
		local ch = m.charge
		use_charge(what, ch)
	end
end

-- utility function to play a method's sound
function play_method_sound(m, ppos, who, what, lev, px, py, default_sound)
	local active_sound = nil
	
	if (m.sound) then       	
		active_sound = m.sound
	elseif (default_sound) then
		active_sound = default_sound
	end
	
	if (active_sound) then		
		if (type(active_sound) == "function") then
			local use_sound = active_sound(m, ppos, who, what)
			if (use_sound) then
				dsb_3dsound(use_sound, lev, px, py)
			end
		else
			dsb_3dsound(active_sound, lev, px, py)
		end 
	end
end

-- Make this something easy to override, for two handed etc. fighting
function att_idle(ppos, idleness)
	dsb_set_idle(ppos, idleness)
end

-- dummy method
function method_x(name, ppos, who, what)
	local namewho = dsb_get_charname(who)
	dsb_write(debug_color, namewho .. " DID A " .. name .. ".")

 	att_idle(ppos, 4)
end

function method_flip_coin(name, ppos, who, what)
	local m = lookup_method_info(name, what)
	if (not m) then return end
	
	if (dsb_rand(0, 1) == 0) then
	    dsb_write(system_color, "IT COMES UP HEADS.")
	else
	    dsb_write(system_color, "IT COMES UP TAILS.")
	end

	att_idle(ppos, m.idleness)
end

-- A standard physical attack method used by most weapons
function method_physattack(name, ppos, who, what)
	local lev, px, py, pface = dsb_party_coords()
	local cface = dsb_get_pfacing(ppos)
	local where = dsb_ppos_tile(ppos)
	local front_row = false
	local char_dir = (pface+cface)%4
	local weapon = nil
	if (what) then weapon = dsb_find_arch(what) end
	
	local m = lookup_method_info(name, weapon)
	if (not m) then return end
	
	if (m.back_attack or (weapon and weapon.back_attack)) then
	    front_row = true
	else
	    front_row = front_row_check(where, char_dir)
	end

	-- Find where the monster is
	local dx, dy = dsb_forward(char_dir)
	local monx = px+dx
	local mony = py+dy
	
	local monster_id = search_for_monster(lev, monx, mony, where, char_dir)
	local door_id = nil	
	if (not monster_id) then
		door_id = search_for_type(lev, monx, mony, CENTER, "DOOR")
	end
	
	if ((monster_id or door_id) and not front_row) then
		dsb_attack_text("CAN'T REACH")
	    return false
	end
	
	local default_sound = base_physical_attack_sound
	if (weapon and weapon.physical_attack_sound) then
		default_sound = weapon.physical_attack_sound
	end	       
	play_method_sound(m, ppos, who, what, lev, px, py, default_sound)	
		
	if (not monster_id) then
		local dv = false
		if (door_id) then
			if (m.door_basher) then
			    attack_door(ppos, who, door_id, what, weapon)
			else
			    dsb_msg(2, door_id, M_BASH, 0)
			end
			dv = true
		end
		if (weapon and weapon.on_empty_square_attack) then
			weapon:on_empty_square_attack(what, ppos, who, m, lev, monx, mony, char_dir)
		    return true
		end
		
		if (not dv) then
		    dsb_set_pfacing(ppos, 0)
		end
		
		failed_attack(m, ppos, who, multiplier)
		return dv
	end

	local monster_arch = dsb_find_arch(monster_id)
	
	-- Make sure we're swinging the right weapon at
	-- the right kind of monster
	local type_ok = false
	if (monster_arch.nonmat) then
	    if (weapon and weapon.hits_nonmat) then
	        type_ok = true
		elseif (m.hits_nonmat) then
	        type_ok = true
		end
	else
	    type_ok = true
	    if (weapon and weapon.only_nonmat) then
	        type_ok = false
		elseif (m.only_nonmat) then
	        type_ok = false
		end
	end
	
	type_ok = h_nonmaterial_check(type_ok, who, monster_id, weapon)
	
	if (not type_ok) then
		failed_attack_idle(m, ppos)
	    return false
	end
		
	local quickness = calc_quickness(who)
	if (ch_exvar[who] and ch_exvar[who].quickness_bonus) then
		quickness = quickness + ch_exvar[who].quickness_bonus
	end

	local difficulty
	local multiplier
	if (exvar[monster_id] and exvar[monster_id].multiplier) then
		multiplier = exvar[monster_id].multiplier
		difficulty = exvar[monster_id].multiplier
	else		
		difficulty = dsb_get_xp_multiplier(lev)	
		multiplier = nil
	end
	
	local req_quickness = monster_arch.quickness + dsb_rand(0, 31)
	req_quickness = req_quickness + difficulty - 16
	
	local hit = false
	if (quickness > req_quickness) then
	    hit = true
	elseif (dsb_rand(0, 3) == 0) then
	    hit = true
	elseif (have_luck(who, 75 - m.req_luck)) then
	    hit = true
	end
	
	hit = h_hit_calculation(hit, who, monster_id, quickness, req_quickness, weapon)
	
	if (ch_exvar[who] and ch_exvar[who].ddefense) then
		ch_exvar[who].ddefense = nil
	end
	
	if (not hit) then
		failed_attack(m, ppos, who, multiplier)
		return false
	end
	
	local used_method, att_loc = dsb_get_lastmethod(ppos)
	local hit_power = calc_tpower(who, what, att_loc, false)
	if (hit_power > 0) then
	    hit_power = hit_power + dsb_rand(0, (hit_power/2)+1)
	    hit_power = hit_power * m.power / 32
		local monster_def = difficulty + monster_arch.armor + dsb_rand(0, 31)
		if (weapon and weapon.monster_def_factor) then
		    monster_def = math.floor(monster_def * weapon.monster_def_factor)
		end
		hit_power = (hit_power + dsb_rand(0, 31)) - monster_def
	end
	
	local b_power = 0
	if (weapon) then
		-- Curses remove the ability to get bonus power. Since bonus power is my
		-- tweak anyway, I might as well make curses matter a little more.
		if (not weapon.cursed and (not exvar[what] or not exvar[what].cursed)) then
			if (weapon.bonus_power) then
				b_power = b_power + (weapon.bonus_power * dsb_rand(2, 3))
			end
			if (exvar[what] and exvar[what].bonus_power) then
				b_power = b_power + (exvar[what].bonus_power * dsb_rand(2, 3))
			end	
		end
	end	
	
	if (b_power > 0) then
	    if (dsb_rand(0, 5) == 0) then
	    	b_power = b_power * 2
	    end
	    hit_power = hit_power + b_power
	end
		
	-- Armor would block everything, see if we can do damage anyway
	if (hit_power < 2) then
		local rand = dsb_rand(0, 3)
		if (rand == 0) then
			monster_retaliate(monster_arch, monster_id, ppos, who, char_dir)
		    failed_attack(m, ppos, who, multiplier)
		    return false
		end
		hit_power = hit_power + dsb_rand(0, 15)
		if (hit_power > 0 or (dsb_rand(0, 1) > 0)) then
		    local old_hit_power = hit_power
		    hit_power = rand + dsb_rand(0, 3)
		    if (dsb_rand(0, 3) == 0) then
		        local hit_bonus = dsb_rand(0, 15) + old_hit_power
		        if (hit_bonus < 1) then hit_bonus = 1 end
				hit_power = hit_power + hit_bonus
			end
		end
	end
	hit_power = hit_power / 2
	if (hit_power > 1) then
		hit_power = hit_power + dsb_rand(0, hit_power)
	end
	hit_power = hit_power + dsb_rand(0, 3)
	if (hit_power > 0) then
	    hit_power = hit_power + dsb_rand(0, hit_power)
	end
	hit_power = (hit_power / 4) + dsb_rand(1, 4)
	
	if (weapon) then
		if (weapon.hits_nonmat and (not monster_arch.nonmat)) then
		    hit_power = hit_power / 2
		    if (hit_power < 1) then
		    	monster_retaliate(monster_arch, monster_id, ppos, who, char_dir)
		        failed_attack(m, ppos, who, multiplier)
		        return false
			end
		end
	end
	
	-- Ninja skill bonus
	-- This is something I added mainly for custom dungeons where ninja
	-- skills might possibly be more important
	if (m.backstab and not monster_arch.instant_turn) then
		local facedir = dsb_get_facedir(monster_id)
		if (facedir == char_dir) then
			local n_skill = determine_xp_level(who, CLASS_NINJA, SKILL_MARTIALARTS)
			hit_power = hit_power + dsb_rand(1, ((m.backstab * n_skill) + 1))		
		end	
	end
	
	-- +1 because "neophyte" is level 1 in DM, but 0 in DSB
	local my_skill = determine_xp_level(who, m.xp_class, m.xp_sub) + 1
	local vs_skill = dsb_rand(0, 63)
	if (my_skill >= vs_skill) then
		-- DM had a flat 10 hp bonus, all the time, but we'll include a hook
		-- for more deadly methods to hit harder sometimes. It's rare enough...
		if (m.enhanced_critical_hit and my_skill >= 3) then
		    hit_power = hit_power + (3*my_skill) + dsb_rand(1, 6)
		else
		    hit_power = hit_power + 10
		end
	end
	
	if (monster_arch.armor == 999) then
		hit_power = 0
	end

	if (hit_power < 1) then
		monster_retaliate(monster_arch, monster_id, ppos, who, char_dir)
	    failed_attack(m, ppos, who, multiplier)
	    return false
	end
	
	if (m.bonus_damage) then
	    hit_power = hit_power + m.bonus_damage
	end
	if (weapon and exvar[what] and exvar[what].bonus_damage) then
		hit_power = hit_power + exvar[what].bonus_damage
	end	
	hit_power = math.floor(hit_power + 0.5)

	att_idle(ppos, m.idleness)
	local xpb = m.xp_get + ((hit_power * monster_arch.xp_factor) / 16) + 3
	if (m.extra_xp) then
	    xpb = xpb + m.extra_xp
	end
	xp_up(who, m.xp_class, m.xp_sub, xpb, multiplier)
	attack_stamina(who, m.stamina_used)

	if (m.ddefense) then
		defensive_attack(m, ppos, who, monster_id, hit_power)
	end
	
	if (hit_power and hit_power > 0) then
		hit_power = monster_damaged(true, hit_power, "armor", monster_id, what,
			monster_arch, weapon, who)

        if (not hit_power) then hit_power = 0 end

		if (hit_power > 0) then
		    if (m.special_effect) then
				m:special_effect(ppos, who, monster_id, hit_power)
			end
			
			if (weapon and weapon.on_melee_damage_monster) then
				local rv = weapon:on_melee_damage_monster(what, ppos, who, monster_id, hit_power)
				if (rv) then hit_power = rv end
			end
			
			if (monster_arch.on_take_melee_damage) then
				local rv = monster_arch:on_take_melee_damage(monster_id, ppos, who, what, name, hit_power)
				if (rv) then hit_power = rv end
			end				
						
			local new_monster_hp = dsb_get_hp(monster_id) - hit_power
			if (new_monster_hp >= 1) then
				monster_retaliate(monster_arch, monster_id, ppos, who, char_dir, true)
			else
			    new_monster_hp = 0
			end
			
        	dsb_attack_damage(hit_power)
        	dsb_hide_mouse(true)
        	dsb_delay_func(2, dsb_show_mouse)
			dsb_set_hp(monster_id, new_monster_hp)
		end
	end
	
	return true
end

-- A helper function to knock down a door
function attack_door(ppos, who, door_id, what, weapon)
	local success = 0
	local used_method, att_loc = dsb_get_lastmethod(ppos)
	local my_bash_power = calc_tpower(who, what, att_loc, false)
	local door_bash_power = 9999
	local door_arch = dsb_find_arch(door_id)
	
	if (exvar[door_id] and exvar[door_id].bash_power) then
	    door_bash_power = exvar[door_id].bash_power
	else
	    local door_arch = dsb_find_arch(door_id)
		if (door_arch.bash_power) then
		    door_bash_power = door_arch.bash_power
		end
	end
	
	if (my_bash_power > door_bash_power) then
	    success = 1
	end
	
	dsb_msg(2, door_id, M_BASH, success)
end

-- A helper function to find something to attack
function search_for_monster(lev, monx, mony, where, char_dir)
	local front_mon = where
	local back_mon = where
	local shift_mon = dsb_tileshift(where, char_dir)
	if (char_dir == where or (char_dir+1)%4 == where) then
	    front_mon = shift_mon
	else
		back_mon = shift_mon
	end
	local monster_id = search_for_type(lev, monx, mony, front_mon, "MONSTER")
	if (monster_id) then
	    return monster_id
	end
	
	local monster_id = search_for_type(lev, monx, mony, CENTER, "MONSTER")
	if (monster_id) then
	    return monster_id
	end

	monster_id = search_for_type(lev, monx, mony, back_mon, "MONSTER")
	if (monster_id) then
	    return monster_id
	end

	front_mon = dsb_tileshift(front_mon, (char_dir+1)%4)
	back_mon = dsb_tileshift(back_mon, (char_dir+1)%4)
	monster_id = search_for_type(lev, monx, mony, front_mon, "MONSTER")
	if (not monster_id) then
		monster_id = search_for_type(lev, monx, mony, back_mon, "MONSTER")
	end
	return monster_id
end

function have_luck(who, needed)
	if (dsb_rand(0, 1) == 0 and dsb_rand(0, 100) > needed) then
	    return true
	end
	local got_luck = (dsb_get_stat(who, STAT_LUC)/10)
	if (dsb_rand(0, got_luck) > needed) then
	    got_luck = got_luck*10 - dsb_rand(15, 25)
	    if (got_luck < 10) then got_luck = 0 end
	    dsb_set_stat(who, STAT_LUC, got_luck)
	    return true
	else
	    got_luck = got_luck*10 + dsb_rand(15, 25)
		local maxluck = dsb_get_maxstat(who, STAT_LUC)
		if (got_luck > maxluck) then
		    dsb_set_stat(who, STAT_LUC, maxluck)
		else
		    dsb_set_stat(who, STAT_LUC, got_luck)
		end
		    
	    return false
	end
	
	return false
end

function failed_attack_idle(info, ppos)
	local staminause = info.stamina_used + dsb_rand(2, 3)
	local idletime = info.idleness
	local who = dsb_ppos_char(ppos)
	burn_stamina(who, staminause)
	att_idle(ppos, idletime)
end

function failed_attack(info, ppos, who, multiplier)
	local xpbonus = info.xp_get / 2
	if (info.extra_xp) then xpbonus = xpbonus + info.extra_xp end
	local staminause = info.stamina_used + dsb_rand(2, 3)
	local idletime = info.idleness
		
	xp_up(who, info.xp_class, info.xp_sub, xpbonus, multiplier)
	burn_stamina(who, staminause)
	att_idle(ppos, idletime)
end

function attack_stamina(who, use)
	burn_stamina(who, use + dsb_rand(4, 7))
end

-- War crying and other such methods
function method_causefear(name, ppos, who, what)
	local lev, px, py, pface = dsb_party_coords()
	local cface = dsb_get_pfacing(ppos)
	local char_dir = (pface+cface)%4
	
	local weapon = nil
	if (what) then weapon = dsb_find_arch(what) end

	local m = lookup_method_info(name, weapon)
	if (not m) then return end
	
	local xxp = 0
	if (m.extra_xp) then xxp = m.extra_xp end
	
	local dx, dy = dsb_forward(char_dir)
	local monx = px+dx
	local mony = py+dy
	
	local bdir = dsb_rand(0, 4)
	local near_mon
	for p=0,4 do
		local dir = (p+bdir)%5
		near_mon = search_for_type(lev, monx, mony, dir, "MONSTER")
		if (near_mon) then break end
	end

	play_method_sound(m, ppos, who, what, lev, px, py, nil)
	att_idle(ppos, m.idleness)

	if (not near_mon) then return end
	local fear_mon = dsb_ai_boss(near_mon)
	local mon_arch = dsb_find_arch(fear_mon)
	
	if (mon_arch.bravery >= 15) then
		xp_up(who, CLASS_PRIEST, SKILL_FEAR, xxp + m.xp_get / 2)
	    return
	end
	
	local max_fear = m.base_fear + determine_xp_level(who, CLASS_PRIEST, SKILL_FEAR) + 1
	local cause_fear = dsb_rand(0, max_fear)

	if (cause_fear < mon_arch.bravery) then
	    xp_up(who, CLASS_PRIEST, SKILL_FEAR, xxp + m.xp_get / 2)
		return
	end
	
	xp_up(who, CLASS_PRIEST, SKILL_FEAR, xxp + m.xp_get)

	-- As of DSB 0.58, I've reverted back to the DM formula because I can't
	-- find anything in the CSBwin code that suggests anything other than
	-- StateOfFear5 actually makes the monster run away. The other states 
	-- have to do with whether the monster is attacking, hunting the party
	-- or whatever. Fear durations still seem somewhat short in DSB compared
	-- to CSBwin, but that's probably just because the clock ticks faster.
	-- I'll just add 1 round to the fear duration to compensate.
	dsb_ai(fear_mon, AI_FEAR, ((4*(16-mon_arch.bravery)) / mon_arch.act_rate) + 1)

	if (m.charge) then	
		use_charge(what, m.charge)
	end
			
end

-- Magical items that shoot a spell (flamitt, stormring, etc.)
function method_shoot_spell(name, ppos, who, what)
	local obj_arch = dsb_find_arch(what)
	
	local m = lookup_method_info(name, obj_arch)
	if (not m) then return end
	
	local lev, xc, yc, dir = dsb_party_coords()
	dsb_set_pfacing(ppos, 0)
	local tilepos = dsb_ppos_tile(ppos)
	local side = 1
	if (tilepos == dir or (tilepos+1)%4 == dir) then
	    side = 0
	end
	local start_pos = (dir + side) % 4

	local p = obj_arch.spell_power	
	if (obj_arch.random_spell_power) then
		p = p + dsb_rand(0, obj_arch.random_spell_power)
	end
	if (m.mana_used) then
		-- +1 because "neophyte" is level 1 in DM, but 0 in DSB
		local sk = determine_xp_level(who, m.xp_class, m.xp_sub) + 1
		local usemana = m.mana_used - (sk * 10)
		if (usemana < 10) then usemana = 10 end
		
		local mana = dsb_get_bar(who, MANA)
		if (mana < usemana) then
				
			-- Sharp power reduction if you are short of mana
			-- if it even works at all
			if (m.must_have_mana) then
			    att_idle(ppos, m.idleness / 2)
			    return
			end
			
			local pmod = (mana/usemana)
			if (pmod < 0.125) then pmod = 0.125 end
			
			p = p * pmod
			dsb_set_bar(who, MANA, 0)
		else
			dsb_set_bar(who, MANA, mana - usemana)
		end			
	end
    
	local d = dsb_get_maxbar(who, MANA) / 8
	if (d > 8) then d = 8 end
	local delta = 10 - d
	if (p < 4*delta) then
	    p = p + 3
	    delta = delta - 1
	end
	
	local missile_type
	if (obj_arch.missile_type) then
		missile_type = obj_arch.missile_type
	else missile_type = m.missile_type end
	
	if (type(missile_type) == "function") then
		missile_type = missile_type(what)
	end
	
	local default_sound = nil
	if (weapon and weapon.ranged_attack_sound) then
		default_sound = weapon.ranged_attack_sound
	end	
	play_method_sound(m, ppos, who, what, lev, xc, yc, default_sound) 
	
	local missile_id = dsb_spawn(missile_type, LIMBO, 0, 0, 0)
	dsb_set_openshot(missile_id, dir)
	dsb_shoot(missile_id, lev, xc, yc, dir, start_pos, p, p, delta)
	set_thrower_owner(missile_id, who)

	-- The launcher can set the shot object's flyreps
	if (obj_arch.flyreps) then
	    dsb_set_flyreps(missile_id, obj_arch.flyreps)
	end
	
	method_finish(m, ppos, who, what)
end

function method_freezelife(name, ppos, who, what)
	local obj_arch = dsb_find_arch(what)
	local freeze = obj_arch.freeze_time
	
	local m = lookup_method_info(name, obj_arch)
	if (not m) then return end
	
	for id in dsb_insts() do
		local arch = dsb_find_arch(id)
		if (arch.type == "MONSTER" and not arch.no_freeze) then
			dsb_ai(id, AI_DELAY_EVERYTHING, freeze + 1)
			dsb_set_gfxflag(id, GF_FREEZE)
			change_exvar(id, "freeze_count", 1)
			dsb_delay_msgs_to(id, freeze + 1)
			dsb_msg(freeze, id, M_UNFREEZE, 0, what)
		end
	end
	
	local lev, px, py = dsb_party_coords()
	play_method_sound(m, ppos, who, what, lev, px, py)

	method_finish(m, ppos, who, what)
end

function method_shield(name, ppos, who, what)
	local m = lookup_method_info(name, what)
	if (not m) then return end
	
	local mana = dsb_get_bar(who, MANA)
	local itime = m.idleness
	
	if (mana <= 0) then
		burn_stamina(who, m.stamina_used)
		att_idle(ppos, itime / 2)
	    return
	end
	
	local arch = dsb_find_arch(what)
	local sh_power = arch.shield_power
	local sh_duration = arch.shield_duration
		
	local n_ppos
	for n_ppos=0,3 do
		local char = dsb_ppos_char(n_ppos)
		if (valid_and_alive(char)) then
			magic_shield(char, m.shield_type, sh_power, sh_duration)
		end
	end
	
	local lev, px, py = dsb_party_coords()
	play_method_sound(m, ppos, who, what, lev, px, py)

    method_finish(m, ppos, who, what)
end

function method_light(name, ppos, who, what)
	local arch = dsb_find_arch(what)
	local m = lookup_method_info(name, arch)
	if (not m) then return end
		
	magic_light(arch.light_power, arch.light_fade, arch.light_fade_time)
	
	local lev, px, py = dsb_party_coords()
	play_method_sound(m, ppos, who, what, lev, px, py)
	
	method_finish(m, ppos, who, what)
end

function method_window(name, ppos, who, what)
	local arch = dsb_find_arch(what)
	local m = lookup_method_info(name, obj_arch)
	if (not m) then return end
	
	local duration = arch.window_duration

	local cpower = dsb_get_condition(PARTY, C_WINDOW)
	if (not cpower) then cpower = duration
	else
		cpower = cpower + duration
	end
	
	dsb_set_condition(PARTY, C_WINDOW, cpower)
	dsb_set_gameflag(GAME_WINDOW)
	
	local lev, px, py = dsb_party_coords()
	play_method_sound(m, ppos, who, what, lev, px, py)
	
	method_finish(m, ppos, who, what)
end

function method_heal(name, ppos, who, what)	
	local m = lookup_method_info(name, what)
	if (not m) then return end
	
	att_idle(ppos, m.idleness)
	burn_stamina(who, m.stamina_used)

	local hp = dsb_get_bar(who, HEALTH)
	local needed_hp = dsb_get_maxbar(who, HEALTH) - hp
	if (needed_hp > 0) then
		local mana = dsb_get_bar(who, MANA)
		if (mana > 0) then
			local healinc = (determine_xp_level(who, m.xp_class, m.xp_sub) + 1) * 10
			if (healinc > 100) then healinc = 100 end
			for i=0,29 do
				hp = hp + healinc
				needed_hp = needed_hp - healinc
				mana = mana - m.mana_used
				if (needed_hp < healinc) then healinc = needed_hp end
				xp_up(who, m.xp_class, m.xp_sub, m.xp_get)
				if (mana <= 0 or needed_hp <= 0) then break end 
			end			
			if (mana < 0) then dsb_set_bar(who, MANA, 0)
			else dsb_set_bar(who, MANA, mana) end			
			dsb_set_bar(who, HEALTH, hp)
		else
			return
		end
	else
		return
	end
	
	local lev, px, py = dsb_party_coords()
	play_method_sound(m, ppos, who, what, lev, px, py)
		
	if (m.charge) then 
		use_charge(what, m.charge)
	end
end	

function method_climbdown(name, ppos, who, what)
	local idle_set = false
	
	local m = lookup_method_info(name, what)
	if (not m) then return end
	
	local lev, xc, yc, face = dsb_party_coords()
	local dx, dy = dsb_forward(face)
	xc = xc + dx
	yc = yc + dy
	
	local always_give_xp = false 
	if (what) then
		local what_arch = dsb_find_arch(what)
		always_give_xp = what_arch.always_give_xp
	end
	
	-- Original DM gives xp even if there is no pit. 
	-- I consider it a bug, but some people liked this behavior,
	-- so let's just make it an option.
	if (always_give_xp) then
		burn_stamina(who, m.stamina_used)
		att_idle(ppos, m.idleness)
		idle_set = true
		xp_up(who, m.xp_class, m.xp_sub, m.xp_get)	
	end
	
	local got_pit = dsb_fetch(lev, xc, yc, CENTER)
	if (got_pit) then
		local blocked = false
	    for d=0,4 do
	    	local got_monster = search_for_type(lev, xc, yc, d, "MONSTER")
	    	if (got_monster) then
				blocked = true
				break
			end
		end
		
		if (not blocked) then	
			for i in pairs(got_pit) do
				local v = got_pit[i]
				local arch = dsb_find_arch(v)
				if (arch.class == "PIT") then
				    if (not dsb_get_gfxflag(v, GF_INACTIVE)) then
						if (not always_give_xp) then
							burn_stamina(who, m.stamina_used)
							att_idle(ppos, m.idleness)
							idle_set = true
							xp_up(who, m.xp_class, m.xp_sub, m.xp_get)
						end
						gt_rope_use = true
						dsb_party_place(lev, xc, yc, face)
					end
				end
			end
		end
	end
	
	if (not idle_set) then
		att_idle(ppos, m.idleness / 2)
	end		
end

function method_fuse(name, ppos, who, what)	
	local escaped = false
	local fused = false
	local m = lookup_method_info(name, what)
	if (not m) then return end

	local lev, px, py, face = dsb_party_coords()
	local dx, dy = dsb_forward(face)
	local xc = px + dx
	local yc = py + dy
	
	local chaos_id = nil
	local mons = dsb_fetch(lev, xc, yc, CENTER)
	if (mons) then
		for i in pairs(mons) do
			local v = mons[i]
			local arch = dsb_find_arch(v)
			if (arch.type == "MONSTER" and arch.class == "CHAOS") then
				dsb_ai(v, AI_HAZARD, 0)
				dsb_ai(v, AI_MOVE_NOW, 0)
				chaos_id = v
			end
		end
	end
	
	if (chaos_id) then
		local clev, cxc, cyc = dsb_get_coords(chaos_id)
		if (cxc == xc and cyc == yc) then
			local chaos_arch = dsb_find_arch(chaos_id)
			escaped = chaos_arch:escape(chaos_id)
			if (not escaped) then
				dsb_set_facedir(chaos_id, (face + 2) % 4)
				
				-- Don't let the fluxcages block our view of the festivities
				local cage_here = search_for_class(lev, px, py, CENTER, "FLUXCAGE")
				if (cage_here) then dsb_delete(cage_here) end			
				local cage_there = search_for_class(lev, xc, yc, CENTER, "FLUXCAGE")
				if (cage_there) then dsb_delete(cage_there) end
				
				dsb_lock_game()
				local zid = dsb_spawn("zap", lev, xc, yc, CENTER)
				dsb_set_charge(zid, 16)
				dsb_sound(snd.zap)
				
				dsb_delay_func(2, function()
					dsb_set_charge(zid, 32)
					dsb_sound(snd.zap)
				end)
				
				dsb_delay_func(4, function()
					dsb_set_charge(zid, 48)
					dsb_sound(snd.zap)
				end)
				
				dsb_delay_func(6, function()
					dsb_set_charge(zid, 64)
					dsb_sound(snd.zap)
				end)
				
				dsb_delay_func(8, function()
					dsb_qswap(zid, "explosion")
					dsb_set_charge(zid, 16)
					dsb_sound(snd.explosion)
				end)
				
				dsb_delay_func(10, function()
					dsb_set_charge(zid, 32)
					dsb_sound(snd.explosion)
				end)
				
				dsb_delay_func(12, function()
					dsb_set_charge(zid, 48)
					dsb_sound(snd.explosion)
				end)
				
				dsb_delay_func(14, function()
					dsb_set_charge(zid, 64)
					dsb_sound(snd.explosion)
				end)	
				
				dsb_delay_func(20, function()
					dsb_disable(zid)
					dsb_qswap(chaos_id, "lordorder")
					dsb_sound(snd.buzz)
				end)
				
				dsb_delay_func(24, function()
					dsb_qswap(chaos_id, "lordchaos")
					dsb_sound(snd.buzz)
				end)
				
				dsb_delay_func(26, function()
					dsb_qswap(chaos_id, "lordorder")
					dsb_sound(snd.buzz)
				end)
				
				dsb_delay_func(28, function()
					dsb_qswap(chaos_id, "lordchaos")
					dsb_sound(snd.buzz)
				end)
				
				dsb_delay_func(29, function()
					dsb_qswap(chaos_id, "lordorder")
					dsb_sound(snd.buzz)
				end)
				
				dsb_delay_func(30, function()
					dsb_qswap(chaos_id, "lordchaos")
					dsb_sound(snd.buzz)
				end)
				
				dsb_delay_func(31, function()
					dsb_qswap(chaos_id, "lordorder")
					dsb_sound(snd.buzz)
				end)
				
				dsb_delay_func(32, function()
					dsb_qswap(chaos_id, "lordchaos")
					dsb_sound(snd.buzz)
				end)
				
				dsb_delay_func(34, function()
					dsb_set_charge(zid, 64)
					dsb_enable(zid)
					dsb_swap(chaos_id, "greylord")
					dsb_sound(snd.explosion)
				end)
				
				dsb_delay_func(36, function()
					dsb_delete(zid)
				end)
				
				dsb_delay_func(38, function()
					dsb_unlock_game()
					if (h_fused_chaos) then
						h_fused_chaos(chaos_id)
					end
				end)
				
				fused = true
				
			end
		end
	end
	
	if (not fused) then
		if (escaped) then
			dsb_delay_func(2, function()
				dsb_sound(snd.zap)
				local id = dsb_spawn("zap", lev, xc, yc, CENTER)
				dsb_set_charge(id, 48)
			end)
		else
			dsb_sound(snd.zap)
			local id = dsb_spawn("zap", lev, xc, yc, CENTER)
			dsb_set_charge(id, 48)
		end
	end
	
	damage_monster_group(lev, xc, yc, 100, 32, "anti_desew", 1, nil)
	burn_stamina(who, m.stamina_used)
	att_idle(ppos, m.idleness)
	xp_up(who, m.xp_class, m.xp_sub, m.xp_get)	
end

function method_fluxcage(name, ppos, who, what)	
	local m = lookup_method_info(name, what)
	if (not m) then return end

	local lev, xc, yc, face = dsb_party_coords()
	local dx, dy = dsb_forward(face)
	xc = xc + dx
	yc = yc + dy
	
	if (not dsb_get_cell(lev, xc, yc)) then
		local id = dsb_spawn("fluxcage", lev, xc, yc, CENTER)
		dsb_msg(90, id, M_DESTROY, 0)
	end
	
	play_method_sound(m, ppos, who, what, lev, xc, yc)
		
	method_finish(m, ppos, who, what)
end

-- For the bow etc.
function method_shoot_ammo(name, ppos, who, what)
	local weapon = dsb_find_arch(what)
	local shooting

	local ammoloc = weapon.ammo_location
	if (ammoloc == nil) then ammoloc = INV_L_HAND end
	
	local m = lookup_method_info(name, weapon)
	if (not m) then return end

	local ammo, ammo_obj, shooting = find_ammo_at_loc(who, ammoloc, weapon, false) 
	if (not ammo) then
	    dsb_attack_text("NEED AMMO")
	    att_idle(ppos, 6)
		if (not dsb_fetch(CHARACTER, who, ammoloc, 0)) then
			get_more_shooting_ammo(ppos, who, ammoloc, weapon.need_ammo_type)
		end
		return
	end

	local lev, xc, yc, dir = dsb_party_coords()
	dsb_set_pfacing(ppos, 0)
	local tilepos = dsb_ppos_tile(ppos)
	local side = 1
	if (tilepos == dir or (tilepos+1)%4 == dir) then
	    side = 0
	end
	local start_pos = (dir + side) % 4

	local ninjaskill = determine_xp_level(who, CLASS_NINJA, SKILL_SHOOTING)
	local shot_power = weapon.base_shot_power + ninjaskill + 1

	-- If throwing the ammo would give more power than using the weapon,
	-- use the throwing power, so the weapon doesn't seem worthless.
	-- (That is, a strong but not very skilled character can get more power
	-- by just using brute force)
	local used_method, att_loc = dsb_get_lastmethod(ppos)
	local arm_power = (calc_tpower(who, ammo, att_loc, true)*3)/2
	if (arm_power > shot_power) then
	    shot_power = arm_power
	end
	shot_power = shot_power + shooting.base_range + dsb_rand(0, 31)

	-- DM sets damage, clobbers it, and then sets damage and delta to the
	-- same value. Completely insane! I doubt if it mattered much to the DM
	-- engine, though, since the "damage" value rarely got used in the code
	-- for when flying things impacted the party or monsters. However, since
	-- I've made it count, I'll have to improvise these a bit.
	local damage = (8*ninjaskill) + dsb_rand(1, weapon.base_shot_damage)
	if (shooting.bonus_damage) then
	    damage = damage + shooting.bonus_damage
	end

	local delta = weapon.base_delta - ninjaskill
	if (delta < weapon.min_delta) then
	    delta = weapon.min_delta
	end

	local xpsub = 0
	if (m.xp_sub) then xpsub = m.xp_sub end
	xp_up(who, m.xp_class, xpsub, m.xp_get)
	att_idle(ppos, m.idleness)
	attack_stamina(who, m.stamina_used)
	dsb_set_openshot(ammo, dir)
	dsb_shoot(ammo, lev, xc, yc, dir, start_pos, shot_power, damage, delta)
	set_thrower_owner(ammo, who)
	
	-- The launcher can set the shot object's flyreps
	if (weapon.flyreps) then
	    dsb_set_flyreps(ammo, weapon.flyreps)
	end

	local default_sound = base_throw_sound
	if (weapon and weapon.ranged_attack_sound) then
		default_sound = weapon.ranged_attack_sound
	end	
	play_method_sound(m, ppos, who, what, lev, xc, yc, default_sound)        

	if (m.charge) then
		use_charge(what, m.charge)
	end

	get_more_shooting_ammo(ppos, who, ammoloc, weapon.need_ammo_type)
end

function method_throw_obj(name, ppos, who, what)
	local throw_arch = dsb_find_arch(what)
    local used_method, att_loc = dsb_get_lastmethod(ppos)
    local alt_loc = INV_L_HAND

	-- call the on_throw so we're consistent with sys_mouse_throw
	if (throw_arch.on_throw and throw_arch:on_throw(what, att_loc, who)) then
	    return true
	end

	local lev, xc, yc, dir = dsb_party_coords()
	dsb_set_pfacing(ppos, 0)
	local tilepos = dsb_ppos_tile(ppos)
	local side = 1
	if (tilepos == dir or (tilepos+1)%4 == dir) then
	    side = 0
	end
	local start_pos = (dir + side) % 4
	
	local power, damage, delta = calc_throw(who, what, att_loc)

    dsb_set_openshot(what, dir)
	dsb_shoot(what, lev, xc, yc, dir, start_pos, power, damage, delta)
	set_thrower_owner(what, who)
	dsb_sound(base_throw_sound)
	att_idle(ppos, 5)

	get_more_throwing_ammo(ppos, who, att_loc, nil, alt_loc)
end

function set_thrower_owner(what, who)
	use_exvar(what)
	exvar[what].last_owner = who 
end

function get_more_shooting_ammo(ppos, who, location, type)
	local ammo = search_quiv_for_ammo(who, type)
	if (ammo) then
	    dsb_set_gfxflag(ammo, GF_UNMOVED)

		if (dsb_get_idle(ppos) < 5) then
	        dsb_set_idle(ppos, 5)
		end
		
	    delay_ammo_move(5, ammo, who, location)
	end
end

function get_more_throwing_ammo(ppos, who, location, type, alt_location)
	local moved = false
	local v_weapon = { need_ammo_type = type }
	local lhandammo, lhand, lhandammoarch, lhandarch = find_ammo_at_loc(who, alt_location, v_weapon, true) 	
	local quivammo = search_quiv_for_ammo(who, type)
	
	if (lhandammo) then
	    dsb_set_gfxflag(lhandammo, GF_UNMOVED)
	    delay_ammo_move(3, lhandammo, who, location)
	    -- The ammo didn't come out of a container
		if (lhandammoarch == lhandarch) then
			if (quivammo) then
	    		dsb_set_gfxflag(quivammo, GF_UNMOVED)
				delay_ammo_move(5, quivammo, who, alt_location)
			end
		end
		moved = true
	elseif (quivammo) then
	    dsb_set_gfxflag(quivammo, GF_UNMOVED)
	    delay_ammo_move(5, quivammo, who, location)
		moved = true
	end
	
	if (moved) then
		if (dsb_get_idle(ppos) < 5) then
	    	dsb_set_idle(ppos, 5)
		end
	end

end

function search_quiv_for_ammo(who, need_type)
	local qloclist = { INV_QUIVER, INV_QUIV2, INV_QUIV3, INV_QUIV4 }
	local ploclist = { INV_POUCH, INV_POUCH2 }
	
	local qammo
	qammo = search_llist_for_ammo(who, need_type, qloclist, false)
	if (not qammo) then
	    qammo = search_llist_for_ammo(who, need_type, ploclist, false)
	    if (not qammo) then
	        qammo = search_llist_for_ammo(who, need_type, qloclist, true)
		end
	end
	return qammo
end

function search_llist_for_ammo(who, need_type, llist, anygrab)
	local ic
	
	-- Grab anything!
    if (anygrab) then
		for ic=1,#llist do
		    local loc = llist[ic]
	        local qitem = dsb_fetch(CHARACTER, who, loc, 0)
	        if (qitem) then
	        	local qarch = dsb_find_arch(qitem)
	        	if (not qarch.ammo_holder) then
					return qitem
				end
			end
	    end
	    return false
	end
	
	-- grab loose missiles first
	for ic=1,#llist do
	    local loc = llist[ic]
        local qitem = dsb_fetch(CHARACTER, who, loc, 0)
        if (qitem) then
			local qarch = dsb_find_arch(qitem)
            if (qarch.missile_type) then
				if (not need_type or qarch.missile_type == need_type) then
					return qitem
				end
			end
		end
	end


	-- Support for containers, DM2 style quivers etc.
	for ic=1,#llist do
	    local loc = llist[ic]
        local qitem = dsb_fetch(CHARACTER, who, loc, 0)
        if (qitem) then
        	local qarch = dsb_find_arch(qitem)
			if (qarch.ammo_holder) then
				local iobj
				for iobj in dsb_in_obj(qitem) do
					local iarch = dsb_find_arch(iobj)
					if (iarch.missile_type) then
						if (not need_type or
							iarch.missile_type == need_type)
						then
							return iobj
						end
					end
				end
			end
        end
    end
    
    return false
end

function delay_ammo_move(delay, ammo_id, owner, dest)
	dsb_delay_func(delay,
		function() move_ammo_in(ammo_id, owner, dest) end
	)
end

function move_ammo_in(ammo_id, owner, dest)
	if (not dsb_get_gfxflag(ammo_id, GF_UNMOVED)) then
	    return false
	end

	local ch, c_owner, where_now = dsb_get_coords(ammo_id)
	if (ch == CHARACTER and c_owner == owner) then
		if (where_now == dest) then return true end
	end
	
	if (dsb_fetch(CHARACTER, owner, dest, 0)) then
	    return false
	end
	
	dsb_move(ammo_id, CHARACTER, owner, dest, 0)
	return true
end

-- Randomly determines something to shoot
function invoke_firestaff(id)
	local shot = dsb_rand(0, 5)
	
	if (shot == 0) then
		return "poison_desven"
	elseif (shot == 1) then
		return "poison_ohven"
	elseif (shot == 2) then
		return "desewspell"
	else
		return "fireball"
	end
	
end

-- Get information on the attack method in use
function lookup_method_info(name, weapon)
	local m = nil
	if (weapon) then
		-- Take the weapon value as an id or an arch
		if (type(weapon) ~= "table") then
			if (type(weapon) == "string") then
				weapon = obj[weapon]
			else
				weapon = dsb_find_arch(weapon)
			end
		end
	    if (weapon.method_info and weapon.method_info[name]) then
			return weapon.method_info[name]
		end
	end
	
	m = method_info[name]
	
	if (m) then return m
	else
	    dsb_write(debug_color, "ERROR: NO INFO FOR " .. name)
	    return nil
	end
end

-- An attack might give a temporary boost or penalty
function defensive_attack(self, ppos, who, id, hit_power)
	local db = self.ddefense
	
	if (db > 0) then db = db + 2
	elseif (db < 0) then db = db - 2 end
	
	if (not ch_exvar[who]) then
	    ch_exvar[who] = { ddefense = db }
	else
		local my_db = ch_exvar[who].ddefense
		if (not my_db) then
		    ch_exvar[who].ddefense = db
		else
		    if (db > my_db) then
		    	ch_exvar[who].ddefense = db
			end
		end
	end
end

-- An attack so imposing looking it can cause fear to the monster
-- As of DSB 0.64, I decided this was sort of stupid...
function frightening_attack(self, ppos, who, id, hit_power)
	return
end

-- A stun attack can freeze the monster momentarily
function stun_attack(self, ppos, who, id, hit_power)
	if (hit_power > 30) then
		if (dsb_rand(0, 7) == 0) then
			local boss_id = dsb_ai_boss(id)
			dsb_ai(boss_id, AI_STUN, dsb_rand(2, 3))
		end
	end
end

unarmed_methods = {
	{ "PUNCH", 0, CLASS_NINJA, "method_physattack" },
	{ "KICK", 0, CLASS_NINJA, "method_physattack" },
	{ "WAR CRY", 0, CLASS_PRIEST, "method_causefear" }
}

shield_methods = {
	{ "BLOCK", 0, CLASS_FIGHTER, "method_physattack" },
	{ "HIT", 0, CLASS_NINJA, "method_physattack" }
}

club_methods = {
	{ "THROW", 0, CLASS_NINJA, "method_throw_obj" },
	{ "BASH", 0, CLASS_FIGHTER, "method_physattack" }
}

coin_methods = {
	{ "FLIP", 0, CLASS_PRIEST, "method_flip_coin" }
}

magicbox_methods = {
	{ "FREEZE LIFE", 0, CLASS_WIZARD, "method_freezelife" }
}

throwable_object_methods = {
	{ "THROW", 0, CLASS_NINJA, "method_throw_obj" },
	{ "STAB", 0, CLASS_NINJA, "method_physattack" }
}

swing_method = {
	{ "SWING", 0, CLASS_FIGHTER, "method_physattack" }
}

shoot_method = {
	{ "SHOOT", 0, CLASS_NINJA, "method_shoot_ammo" }
}

throw_method = {
	{ "THROW", 0, CLASS_NINJA, "method_throw_obj" }
}	

-- This stores information on attack methods, which may or may not
-- be bound to specific weapons. First, the specific version is searched,
-- in the method_info table of a specific arch. Then this table is searched.
method_info = {
	BASH = {
	    xp_class = CLASS_FIGHTER,
	    xp_sub = SKILL_BASHING,
	    xp_get = 11,
	    idleness = 20,
		stamina_used = 9,
		power = 50,
		req_luck = 32,
		door_basher = true
	},
	
	BERZERK = {
	    xp_class = CLASS_FIGHTER,
	    xp_sub = SKILL_SWINGING,
	    xp_get = 40,
	    idleness = 30,
	    stamina_used = 30,
	    power = 96,
	    req_luck = 46,
	    special_effect = frightening_attack,
	    ddefense = -10,
	    door_basher = true,
	    enhanced_critical_hit = true
	},
	
	BLOCK = {
	    xp_class = CLASS_FIGHTER,
		xp_sub = SKILL_DEFENSE,
		xp_get = 8,
		idleness = 6,
		stamina_used = 4,
		power = 15,
		req_luck = 22,
		ddefense = 36
	},
	
    ["BLOW HORN"] = {
	    xp_class = CLASS_PRIEST,
	    xp_sub = SKILL_FEAR,
	    xp_get = 20,
	    idleness = 10,
	    stamina_used = 2,
	    base_fear = 6,
	    sound = snd.horn_of_fear
	},
	
	BRANDISH = {
	    xp_class = CLASS_PRIEST,
	    xp_sub = SKILL_FEAR,
	    xp_get = 30,
	    idleness = 10,
	    stamina_used = 2,
	    base_fear = 6,
		ddefense = -4
	},

    CALM = {
	    xp_class = CLASS_PRIEST,
	    xp_sub = SKILL_FEAR,
	    xp_get = 35,
	    idleness = 10,
	    stamina_used = 2,
	    base_fear = 7
	},

	CHOP = {
	    xp_class = CLASS_FIGHTER,
	    xp_sub = SKILL_BASHING,
	    xp_get = 10,
	    idleness = 8,
	    stamina_used = 8,
	    power = 48,
	    req_luck = 48,
	    door_basher = true
	},

	CLEAVE = {
	    xp_class = CLASS_FIGHTER,
	    xp_sub = SKILL_SWINGING,
	    xp_get = 12,
	    idleness = 12,
	    stamina_used = 10,
	    power = 48,
	    req_luck = 40,
	    door_basher = true,
	    enhanced_critical_hit = true
	},
	
	["CLIMB DOWN"] = {
		xp_class = CLASS_NINJA,
		xp_sub = SKILL_CLIMBING,
		xp_get = 21,
		idleness = 35,
		stamina_used = 80
	},
	
	CONFUSE = {
	    xp_class = CLASS_PRIEST,
	    xp_sub = SKILL_FEAR,
	    xp_get = 45,      	
	    idleness = 10,
	    stamina_used = 2,
	    base_fear = 12,
	    charge = 1
	},
	
	DISPELL = {
		xp_class = CLASS_WIZARD,
		xp_sub = SKILL_AIR,
		xp_get = 25,
		idleness = 31,
		stamina_used = 5,
		mana_used = 70,
		missile_type = "desewspell",
		ddefense = -7,
		charge = 1
	},
	
	DISRUPT = {
	    xp_class = CLASS_WIZARD,
	    xp_sub = SKILL_AIR,
		xp_get = 10,
		idleness = 9,
	    stamina_used = 5,
	    power = 57,
	    req_luck = 46,
	    hits_nonmat = true
	},
	
	FIREBALL = {
		xp_class = CLASS_WIZARD,
		xp_sub = SKILL_FIRE,
		xp_get = 35,
		idleness = 35,
		stamina_used = 5,
		mana_used = 70,
		missile_type = "fireball",
		ddefense = -7,
		charge = 1
	},
	
	FIRESHIELD = {
		xp_class = CLASS_PRIEST,
		xp_sub = SKILL_SHIELDS,
		xp_get = 20,
		idleness = 35,
		stamina_used = 5,
		mana_used = 40,
		shield_type = C_FIRESHIELD,
		ddefense = 5,
		charge = 1
	},
	
	FLIP = {
	    xp_class = CLASS_PRIEST,
		xp_sub = SKILL_LUCK,
		xp_get = 0,
		idleness = 5,
		stamina_used = 1
	},
	
	FLUXCAGE = {
		xp_class = CLASS_WIZARD,
		xp_sub = 0,
		xp_get = 1,
		idleness = 10,
		stamina_used = 2,
		ddefense = 8
	},
	
	["FREEZE LIFE"] = {
	    xp_class = CLASS_PRIEST,
	    xp_sub = SKILL_FEAR,
	    xp_get = 22,
	    idleness = 20,
	    stamina_used = 3,
	    charge = 1
	},
	
	FUSE = {
		xp_class = CLASS_WIZARD,
		xp_sub = 0,
		xp_get = 1,
		idleness = 10,
		stamina_used = 2,
		ddefense = 8
	},

   	HEAL = {
	    xp_class = CLASS_PRIEST,
		xp_sub = SKILL_POTIONS,
		xp_get = 2,
		idleness = 10,
		stamina_used = 1,
		mana_used = 20
	},

	HIT = {
	    xp_class = CLASS_NINJA,
		xp_sub = SKILL_MARTIALARTS,
		xp_get = 10,
		idleness = 5,
		stamina_used = 3,
		power = 20,
		req_luck = 20,
		ddefense = 16
	},
	
	INVOKE = {
		xp_class = CLASS_WIZARD,
		xp_sub = 0,
		xp_get = 25,
		idleness = 20,
		stamina_used = 5,
		mana_used = 70,
		missile_type = invoke_firestaff,
		ddefense = -7
	},
	
	JAB = {
		xp_class = CLASS_FIGHTER,
		xp_sub = SKILL_STABBING,
		xp_get = 11,
		idleness = 2,
		stamina_used = 3,
		power = 8,
		req_luck = 70
	},
	
	KICK = {
		xp_class = CLASS_NINJA,
		xp_sub = SKILL_MARTIALARTS,
		xp_get = 13,
		idleness = 5,
		stamina_used = 3,
		power = 48,
		req_luck = 38,
		ddefense = -10,
		door_basher = true	
	},
	
	LIGHT = {
		xp_class = CLASS_WIZARD,
		xp_sub = SKILL_AIR,
		xp_get = 20,
		idleness = 10,
		stamina_used = 3,
		charge = 1
	},

	LIGHTNING = {
		xp_class = CLASS_WIZARD,
		xp_sub = SKILL_AIR,
		xp_get = 30,
		idleness = 35,
		stamina_used = 4,
		mana_used = 70,
		missile_type = "lightning",
		ddefense = -7,
		charge = 1
	},

	MELEE = {
	    xp_class = CLASS_FIGHTER,
	    xp_sub = SKILL_BASHING,
		xp_get = 24,
		idleness = 20,
		stamina_used = 17,
		power = 61,
		req_luck = 64,
		ddefense = -12,
		enhanced_critical_hit = true
	},
	
	PARRY = {
	    xp_class = CLASS_FIGHTER,
		xp_sub = SKILL_DEFENSE,
		xp_get = 17,
		idleness = 15,
		stamina_used = 1,
		power = 8,
		req_luck = 18,
		ddefense = 28
	},
	
	-- Not actually used in DM. However, it balances out the spell methods.
	POISON = {
		xp_class = CLASS_WIZARD,
		xp_sub = SKILL_POISON,
		xp_get = 30,
		idleness = 35,
		stamina_used = 4,
		mana_used = 70,
		missile_type = "poison_ohven",
		ddefense = -7,
		charge = 1
	},
	
	PUNCH = {
		xp_class = CLASS_NINJA,
		xp_sub = SKILL_MARTIALARTS,
		xp_get = 8,
		idleness = 2,
		stamina_used = 2,
		power = 16,
		req_luck = 38,
		ddefense = -10
	},	

	SHOOT = {
	    xp_class = CLASS_NINJA,
		xp_sub = SKILL_SHOOTING,
	    xp_get = 9,
	    idleness = 14,
	    stamina_used = 3
	},
	
	SLASH = {
		xp_class = CLASS_NINJA,
		xp_sub = SKILL_MARTIALARTS,
		xp_get = 9,
		idleness = 4,   	
		stamina_used = 3,
		power = 16,
		req_luck = 26,
		ddefense = 4
	},
	
	SPELLSHIELD = {
		xp_class = CLASS_PRIEST,
		xp_sub = SKILL_SHIELDS,
		xp_get = 20,
		idleness = 30,
		stamina_used = 5,
		mana_used = 40,
		shield_type = C_SPELLSHIELD,
		ddefense = 5,
		charge = 1
	},

    SPIT = {
		xp_class = CLASS_WIZARD,
		xp_sub = SKILL_FIRE,
		xp_get = 25,
		idleness = 20,
		stamina_used = 8,
		mana_used = 70,
		missile_type = "fireball",
		ddefense = -8,
		charge = 1
	},
	
	STAB = {
		xp_class = CLASS_NINJA,
		xp_sub = SKILL_MARTIALARTS,
		xp_get = 15,
		idleness = 5,
		stamina_used = 3,
		power = 48,
		req_luck = 30,
		ddefense = -20,
		backstab = 2
	},
	
	STUN = {
		xp_class = CLASS_FIGHTER,
		xp_sub = SKILL_BASHING,
		xp_get = 10,
		idleness = 7,
		stamina_used = 5,
		power = 16,
		req_luck = 50,
		defense = 8,
		special_effect = stun_attack
	},
	
	SWING = {
	    xp_class = CLASS_FIGHTER,
	    xp_sub = SKILL_SWINGING,
	    xp_get = 6,
	    idleness = 6,
	    stamina_used = 2,
		power = 16,
	    req_luck = 32,
	    ddefense = 5
	},

    THRUST = {
		xp_class = CLASS_FIGHTER,
		xp_sub = SKILL_STABBING,
		xp_get = 19,
		idleness = 16,
		stamina_used = 13,
		power = 66,
		req_luck = 57,
		ddefense = -20,
		enhanced_critical_hit = true
	},
	
	["WAR CRY"] = {
	    xp_class = CLASS_PRIEST,
	    xp_sub = SKILL_FEAR,
	    xp_get = 12,
	    extra_xp = 7,
	    idleness = 5,
	    stamina_used = 1,
	    base_fear = 3,
		ddefense = 4,
		sound = base_warcry_sound
	},
	
	WINDOW = {
		xp_class = CLASS_WIZARD,
		xp_sub = SKILL_DES,
		xp_get = 30,
		idleness = 12,
		stamina_used = 1,
		ddefense = -4,
		charge = 1
	}
}

