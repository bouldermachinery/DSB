-- Monster functions base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- These functions are not called by the engine directly,
-- but they are used by objects and so you should be careful
-- about overriding them.

-- constants for why the monster is ranged attacking
SHOOT_OPEN_SPACE = 0
SHOOT_DOOR_SOLID = 1
SHOOT_DOOR_BARS = 2

-- constants for why the monster is moving
MOVE_NORMAL = 0
MOVE_PARTY = 1
MOVE_FEAR = 2

function monster_step(self, id, group_leader)
	if (group_leader) then
	    if (self.step_sound) then
	        local lev = dsb_get_coords(id)
			local p_lev = dsb_party_coords()
			if (lev == p_lev) then
				play_arch_local_sound(self, id, "step_sound")
			end
		end
	end
end

-- Calculates the base damage a monster will do against a character
-- Based on CSBwin MonsterDamagesCharacter
-- The procedure by which a monster determines which zone on the
-- character to damage has been moved to here, and revised significantly
-- based on information from: http://dmweb.free.fr/?q=node/1395
function calc_monster_basedamage(mon, monid, ppos, char)
	local mlev = dsb_get_coords(monid)
	
	local multiplier
	if (exvar[monid] and exvar[monid].multiplier) then
		multiplier = exvar[monid].multiplier		
	else
		multiplier = dsb_get_xp_multiplier(mlev)
	end
	local base_difficulty = 2 * multiplier
	
	local quik = calc_quickness(char)
	local mon_quik = mon.quickness + base_difficulty + dsb_rand(-16, 16)
	
	-- Override a hardcoded DM value if we want to
	local monster_luck	
	if (mon.luck) then monster_luck = mon.luck
	else monster_luck = 60 end
	
	xp_up(char, CLASS_FIGHTER, SKILL_DEFENSE, mon.xp_factor, multiplier)
	
	if (quik < mon_quik or dsb_rand(0, 3) == 0) then
		if (have_luck(char, monster_luck)) then return(0) end
		local hit_chance = mon.base_power + base_difficulty + dsb_rand(0, 15)
		local char_chance = determine_xp_level(char, CLASS_FIGHTER, SKILL_DEFENSE)
		local attack_power = hit_chance - char_chance
		if (attack_power <= 1) then
			if (dsb_rand(0, 1) ~= 0) then return(0) end
			attack_power = dsb_rand(2, 5)
		end
		attack_power = attack_power / 2
		attack_power = attack_power + dsb_rand(0, attack_power)
		attack_power = attack_power + dsb_rand(0, 3)
		attack_power = attack_power / 4
		attack_power = attack_power + dsb_rand(0, 3) + 1
		if (dsb_rand(0, 1) ~= 0) then
			attack_power = attack_power - dsb_rand(0, attack_power/2)
		end
		
		if (attack_power < 1) then attack_power = 0 end
		
		if (mon.attack_zonetable) then
			zone = zone_from_zonetable(mon.attack_zonetable)
		elseif (mon.attack_zone) then
			zone = mon.attack_zone
		else
			zone = random_body_loc()
		end

		return attack_power, zone
	end

	return 0, nil	
end

function set_monster_attack(mon_arch, id)
	if (mon_arch.attack) then
	    local duration = 2
		dsb_set_gfxflag(id, GF_ATTACKING)
		if (mon_arch.attack_show_duration and
		    mon_arch.attack_show_duration > 0)
		then
		    duration = mon_arch.attack_show_duration
		end
		dsb_msg(duration, id, M_STOPATTACK, 0)
	end
		
	g_last_monster_attack = 0
end

-- A monster is attacking (close up)
function monster_attack(self, id)
										 
	-- Code to handle multiple parties on the Lua level has
	-- mostly been removed, because the engine now handles this all
	-- automatically. It makes the code lot cleaner looking.	
	local lev, x, y, tile = dsb_get_coords(id)
	-- There's really nothing to do if I'm floating around elsewhere...
	if (lev < 0) then
		return false
	end
	
	local p_lev, p_x, p_y, p_face = dsb_party_coords()
	-- They ran away!
	if (p_lev ~= lev) then
		return false
	end
	
	local face = dsb_get_facedir(id)
	local pdir, range = linedirfrom(x, y, p_x, p_y)

    local in_range = false
    local wrong_tile = false
	if (pdir == face and range == 1) then
	    in_range = true
	else
	    in_range = false
	end
	
	if (in_range) then
	    if (tile ~= CENTER) then
			if (tile ~= pdir and tile ~= ((pdir+1) % 4)) then
			    if (not self.attack_from_back) then
			    	in_range = false
				end
			    wrong_tile = true
			end
		end
	end
	
	local attack_type = nil
	if (self.sel_attack_close) then
	    attack_type = self:sel_attack_close(id, wrong_tile)
	    
	    if (not in_range and self.attack_from_back) then
	        in_range = true
		end
	end
	
	if (self.on_attack_ranged) then
		if (pdir == face and in_range == false) then
			return (self:on_attack_ranged(id, 0))
		end
	end
	
	if (not in_range) then
	    return false
	end

	set_monster_attack(self, id)
	play_arch_local_sound(self, id, "attack_sound")
	
	if (attack_type == nil) then
	    attack_type = self.attack_type
	end
	
	local adir = dsb_get_facedir(id)
	local apos1 = (adir+2) % 4
	local apos2 = (adir+3) % 4
	local hitpos1 = dsb_tile_ppos(apos1)
	local hitpos2 = dsb_tile_ppos(apos2)
	if (not hitpos1) then 
		hitpos1 = dsb_tile_ppos((apos2+2) % 4) end
	if (not hitpos2) then 
		hitpos2 = dsb_tile_ppos((apos1+2) % 4) end
	if (not hitpos2) then hitpos2 = hitpos1
	elseif (not hitpos1) then hitpos1 = hitpos2 end
	
	if (not hitpos1 and not hitpos2) then return(false) end
	
	local targppos
	if (dsb_rand(0, 1) == 0) then targppos = hitpos1
	else targppos = hitpos2 end
	
	local targchar = dsb_ppos_char(targppos)
	local t_damage, c_damage, zone
	if (type(attack_type) == "function") then
		t_damage, c_damage, zone = attack_type(targppos, targchar, self, id)
	else	
		t_damage, c_damage, zone = 
			monster_attack_types[attack_type](targppos, targchar, self, id)
	end
			
	if (dsb_get_sleepstate()) then
		dsb_wakeup()
	end
	
	dsb_set_pfacing(targppos, ((apos1 + 4) - p_face) % 4)
	
	if (self.on_damage_char and c_damage > 0) then
		local ntd, ncd, nz = self:on_damage_char(id, targppos, targchar, t_damage, c_damage)
		if (ntd) then t_damage = ntd end
		if (ncd) then c_damage = ncd end
		if (nz) then zone = nz end
	end
		
	if (c_damage > 0) then
		local ntd, ncd, nz = monster_specialattack(self, id, targppos, targchar, t_damage, c_damage)
		if (ntd) then t_damage = ntd end
		if (ncd) then c_damage = ncd end
		if (nz) then zone = nz end
		if (c_damage > 0) then
			dsb_delay_func(2, function() hurt_sound(targppos, targchar) end)
			do_damage(targppos, targchar, t_damage, c_damage)
			monster_cause_injuries(self, id, targppos, targchar, t_damage, c_damage, zone)
		end
	end
	
	if (self.on_succeed_attack_close) then
	    self:on_succeed_attack_close(id, targppos, targchar)
	end

	local boss_id = dsb_ai_boss(id)
    apply_attack_delay(self, boss_id, 2)
    
	return true
end

function monster_specialattack(arch, id, targppos, targchar, t_damage, c_damage)
	local att_func = nil
	local att_chances
	
	if (arch.special_attack) then att_func = arch.special_attack
	elseif (arch.poison) then att_func = monster_poisonattack
	end
	
	if (arch.special_chance) then att_chances = arch.special_chance
	else att_chances = 50
	end

	if (att_func and dsb_rand(0, 99) <= att_chances) then
		return att_func(arch, id, targppos, targchar, t_damage, c_damage)
	end
	
	return nil
end

function monster_poisonattack(arch, id, targppos, targchar, t_damage, c_damage)
	local poison = arch.poison
	if (not poison) then poison = 1 end
	poison_character(targchar, poison)
	return nil
end

-- The monster landed a hit. If it's health (like everything by default),
-- it can injure the zone that the monster attacked. See injure_zones in
-- damage.lua for the dirty details.
function monster_cause_injuries(arch, id, targppos, targchar, t_damage, c_damage, zone)
	if (t_damage ~= HEALTH) then
		return
	end
	injure_zones(targchar, c_damage, zone)
end

function monster_missile(self, id, why_shoot)

	if (self.sel_attack_ranged) then
	    self:sel_attack_ranged(id, why_shoot)
	end

	local lev, xc, yc, shootside = dsb_get_coords(id)
	-- There's really nothing to do if I'm floating around elsewhere...
	if (lev < 0) then
		return false
	end
	
	local facedir = dsb_get_facedir(id)
	
	-- Randomly determine a side for a center monster to shoot from
	-- if i don't have one stored, and then move up the back
	-- row shooters' shots so they don't blast the front row
	if (exvar[id] and exvar[id].mai_bestside) then
		shootside = exvar[id].mai_bestside
		exvar[id].mai_bestside = nil
	elseif (shootside == CENTER) then shootside = dsb_rand(0, 3) end

	if (shootside ~= facedir and shootside ~= (facedir+1) % 4)
	then
		shootside = dsb_tileshift(shootside, facedir)
	end
	
	local mtype
    local boss_id = dsb_ai_boss(id)
		    
    use_exvar(boss_id)
    if (exvar[boss_id].mai_missile) then
		mtype = exvar[boss_id].mai_missile
		if (exvar[boss_id].mai_att_bmp) then
			dsb_ai(id, AI_ATTACK_BMP, exvar[boss_id].mai_att_bmp)
		end
	elseif (type(self.missile_type) == "function") then
		-- The call to self.missile_type now can return two parameters:
		-- A missile, and an attack bitmap to set. Set it if we have one.
		local att_bmp
	    mtype, att_bmp = self:missile_type(id, why_shoot)
	 	if (att_bmp) then
			dsb_ai(id, AI_ATTACK_BMP, att_bmp)
		end
	else
	    mtype = determine_missile_type(self, id, why_shoot)
	end
	
	if (not mtype) then return false end
	
	set_monster_attack(self, id)
	if (self.attack_sound_ranged) then
		play_arch_local_sound(self, id, "attack_sound_ranged")
	elseif (self.attack_sound) then
		play_arch_local_sound(self, id, "attack_sound")
	end
	
	local missile_id = dsb_spawn(mtype, LIMBO, 0, 0, 0)
	local pow = self.missile_power
	
	local damage = self.missile_power
	if (self.missile_damage) then
		damage = self.missile_damage
	end
	
	local delta = 8
	if (self.missile_delta) then
		delta = self.missile_delta
	end
	
	local ddelta = nil
	if (self.missile_damage_delta) then
		ddelta = self.missile_damage_delta
	end
	
	dsb_set_openshot(missile_id)
	dsb_shoot(missile_id, lev, xc, yc, facedir, shootside, pow, damage, delta, ddelta)
	if (not exvar[id]) then use_exvar(id) end
	if (not exvar[id].mai_shoot_tag) then
		exvar[id].mai_shoot_tag = dsb_rand(1, 65535)
	end
	exvar[missile_id] = { shooter_id = id, shooter_boss = boss_id, shoot_tag = exvar[id].mai_shoot_tag }
	
	-- If the monster isn't supposed to be smashing doors then don't let the monster smash doors.
	if (not self.door_breaker) then
		exvar[missile_id].no_door_break = true
	end
	
	if (self.on_succeed_attack_ranged) then
	    self:on_succeed_attack_ranged(id, missile_id)
	end
	
	apply_attack_delay(self, boss_id, 4)
	
	return true
end

function monster_stopattack(id, data)
	dsb_clear_gfxflag(id, GF_ATTACKING)
end

function monster_unfreeze(id, data)
	if (exvar[id] and exvar[id].freeze_count > 0) then
	    exvar[id].freeze_count = exvar[id].freeze_count - 1
	    if (exvar[id].freeze_count == 0) then
	        exvar[id].freeze_count = nil
			dsb_clear_gfxflag(id, GF_FREEZE)
		end
	end
end

function monster_hptozero(id, data)
	dsb_set_hp(id, 0)
end

-- For monsters that move and attack at different rates
-- Before 0.58, there was no mai_attackdelay check. This
-- meant that if the boss was not in on the attack (which
-- could happen in in groups of 3 or 4 size 1 monsters)
-- then the attacks would continue at the normal movement
-- rate. Wasps and munchers could kill a party in seconds!
function apply_attack_delay(self, id, mindelay)
	
	use_exvar(id)
		
	if (exvar[id].mai_attackdelay) then
		exvar[id].mai_nowake = true
		return
	end
	
	if (self.attack_delay) then
		local t = dsb_ai(id, AI_TIMER, QUERY)
		if (self.attack_delay < 0) then		    
			if ((t + self.attack_delay) >= mindelay) then
				dsb_ai(id, AI_TIMER, t + self.attack_delay)
			else
				dsb_ai(id, AI_TIMER, mindelay)
			end
		else
			dsb_ai(id, AI_TIMER, t + self.attack_delay)
		end
		
		exvar[id].mai_attackdelay = true
	end
	
	exvar[id].mai_nowake = true
	
end

-- A monster has been attacked with a melee attack. What will it do in response?
function monster_retaliate(monster_arch, monster_id, ppos, who, vector, success)
	local boss_id = dsb_ai_boss(monster_id)
	
	-- frozen monsters will never react
    if (dsb_get_gfxflag(boss_id, GF_FREEZE)) then
		return
	end
	
	-- beating up monsters makes them eager to fight back
	local fearchange = -1
	if (success) then
		fearchange = fearchange - dsb_rand(0, 2)
	elseif (boss_id == monster_id and dsb_rand(0, 2) == 0) then
		fearchange = fearchange - 1
	end
	dsb_ai(boss_id, AI_FEAR, fearchange)
		
	-- Monsters that will attack immediately after you attack them
	if (monster_arch.counterattack and dsb_rand(0, 3) == 0) then
		local attack_ok = true
		local my_dir = dsb_get_facedir(monster_id)
		local timer_len = dsb_ai(boss_id, AI_TIMER, QUERY)
		local delay_len = dsb_ai(boss_id, AI_DELAY_ACTION, QUERY)
		local max_timer = monster_arch.act_rate
		if (vector == my_dir) then
			attack_ok = false
		elseif (dsb_get_gfxflag(monster_id, GF_ATTACKING)) then
			attack_ok = false
		elseif (dsb_get_gfxflag(monster_id, GF_FREEZE)) then
			attack_ok = false
		elseif (exvar[monster_id] and exvar[monster_id].mai_pendingattack) then
			attack_ok = false
		elseif (exvar[boss_id] and exvar[boss_id].mai_counterattacked) then
			attack_ok = false
		elseif (exvar[boss_id] and exvar[boss_id].mai_pounced) then
			attack_ok = false
		elseif (timer_len < 3 or (timer_len > max_timer)) then
			attack_ok = false
		elseif (delay_len > 0) then
		    attack_ok = false
		end
		
		if (attack_ok) then
			local lev, x, y, tile = dsb_get_coords(monster_id)
			local rvector = (vector + 2) % 4
			if (tile == CENTER or tile == rvector or
				tile == (vector + 3) % 4)
			then
				if (my_dir ~= rvector) then
					dsb_set_facedir(monster_id, rvector)
				end
				dsb_ai(boss_id, AI_DELAY_ACTION, 4)
				dsb_msg(1, monster_id, M_ATTACK_MELEE, 0)
				change_exvar(boss_id, "mai_counterattacked", 1)	
			end			
		end
	end

end

function monster_meleeattack(ppos, who, mon, monid)
	local base_damage, zone = calc_monster_basedamage(mon, monid, ppos, who)	
	return HEALTH, physical_damage(ppos, who, base_damage, false, zone), zone
end

function monster_pierceattack(ppos, who, mon, monid)
	local base_damage, zone = calc_monster_basedamage(mon, monid, ppos, who)
	return HEALTH, physical_damage(ppos, who, base_damage, true, zone), zone
end

function monster_wisdomattack(ppos, who, mon, monid)
	local base_damage, zone = calc_monster_basedamage(mon, monid, ppos, who)
	return HEALTH, wisdom_damage(ppos, who, base_damage, zone), zone
end

function monster_fireattack(ppos, who, mon, monid)
	local base_damage, zone = calc_monster_basedamage(mon, monid, ppos, who)
	return HEALTH, fire_damage(ppos, who, base_damage, zone), zone
end

function monster_magicattack(ppos, who, mon, monid)
	local base_damage, zone = calc_monster_basedamage(mon, monid, ppos, who)
	return HEALTH, magic_damage(ppos, who, base_damage, zone), zone
end

function monster_steal(ppos, who, mon, monid)
	local steal_obj = nil
	local mlev = dsb_get_coords(monid) 
	
	local base_difficulty
	if (exvar[monid] and exvar[monid].multiplier) then
		base_difficulty = 2 * exvar[monid].multiplier
	else
		base_difficulty = 2 * dsb_get_xp_multiplier(mlev)
	end
	
	local quik = calc_quickness(who)
	local mon_quik = mon.quickness + base_difficulty + dsb_rand(-16, 16)
	local monster_luck
	if (mon.luck) then monster_luck = mon.luck
	else monster_luck = 60 end

	xp_up(who, CLASS_FIGHTER, SKILL_DEFENSE, mon.xp_factor)
	
	local mon_boss = dsb_ai_boss(monid)
	use_exvar(mon_boss)	
	local paranoia = exvar[mon_boss].mai_paranoia
	if (not paranoia) then paranoia = 0 end
	
	local steal_timeval = 0
	local steal_successful = false
	if (quik < mon_quik or dsb_rand(0, 3) == 0) then
		steal_successful = true
		if (have_luck(who, monster_luck)) then
			steal_successful = false
		end
	end
		
	if (steal_successful) then
		local firsthand = INV_L_HAND
		local secondhand = INV_R_HAND
		
		-- 1/3 chance of stealing in reverse order
		if (dsb_rand(0, 2) == 0) then
			firsthand = INV_R_HAND
			secondhand = INV_L_HAND
		end

		steal_obj = dsb_fetch(CHARACTER, who, firsthand, 0)
		steal_timeval = 5
		
		if (steal_obj) then
			local steal_arch = dsb_find_arch(steal_obj)
			if (steal_arch.no_stealing) then
			    steal_obj = nil
			end
		end
		
		if (not steal_obj) then
		    steal_obj = dsb_fetch(CHARACTER, who, secondhand, 0)
		    if (steal_obj) then
				local steal_arch = dsb_find_arch(steal_obj)
				if (steal_arch.no_stealing) then
				    steal_obj = nil
				end
			end
		end
		
		if (steal_obj) then
			local val = false
			local steal_arch = dsb_find_arch(steal_obj)
			if (steal_arch.on_steal) then
			    val = steal_arch:on_steal(steal_obj, monid)
			end
			if (val ~= true) then
				dsb_move(steal_obj, IN_OBJ, monid, -1, 0)
				steal_timeval = dsb_rand(12, 18)
			end
		end		
	end
	
	-- Don't just stand there giggling. Run away with
	-- my ill-gotten loot (or just when things are too hot)
	if (steal_obj or dsb_rand(2, 7) < paranoia) then
		dsb_ai(monid, AI_FEAR, dsb_rand(4, 8) + steal_timeval)
		dsb_ai(monid, AI_TIMER, 1)
		exvar[mon_boss].mai_paranoia = nil
	else
		-- Usually try to sidestep after a failed steal
		-- and get a little more scared
		if (dsb_rand(0, 9) ~= 0) then
			exvar[mon_boss].mai_twostepyou = true
		end
		change_exvar(mon_boss, "mai_paranoia", 1)
	end
	
	return 0, 0
end

-- Special functions for Lord Chaos
function forbid_monsterclass(self, id, what)
	local arch = dsb_find_arch(what)
	if (arch.class == self.forbidden) then
		return true
	else
		return false
	end
end

function chaos_teleport(self, id)
	local lev, xc, yc, tp = dsb_get_coords(id)
	local fdir = dsb_get_facedir(id)
	
	for n=0,3 do
		local godir = (fdir + n) % 4
		local dx, dy = dsb_forward(godir)
		
		if (not dsb_get_cell(lev, xc+dx, yc+dy)) then
			if (canigo(self, id, lev, xc+dx*2, yc+dy*2, false)) then
				local fluxfound = false
				
				fluxfound = search_for_class(lev, xc+dx, yc+dy, CENTER, "FLUXCAGE")
				if (not fluxfound) then
					fluxfound = search_for_class(lev, xc+dx*2, yc+dy*2, CENTER, "FLUXCAGE")
				end
				
				if (not fluxfound) then			
					dsb_lock_game()
					dsb_set_tint(id, {0, 192, 220})
					dsb_sound(snd.buzz)
					dsb_delay_func(1, function()
						dsb_unlock_game()
						dsb_set_tint(id, {0, 0, 0})
						dsb_move(id, lev, xc+dx*2, yc+dy*2, tp)
					end)
					return true
				end
			end
		end
	end	
	
	return false
end

-- Adds food to a monster's inventory (to be
-- immediately dropped as the monster dies)
function setup_food_drop(self, id)
	if (exvar[id] and exvar[id].no_auto_drop) then
		return
	end	
	local minf = 1
	local maxf = 2
	if (self.min_food) then minf = self.min_food end
	if (self.max_food) then maxf = self.max_food end
	local rf = dsb_rand(minf, maxf)
	local cf
	for cf=1,rf do
	    dsb_spawn(self.food_type, IN_OBJ, id, VARIABLE, 0)
	end
end

function setup_item_drop(self, id)
	if (exvar[id] and exvar[id].no_auto_drop) then
		return
	end
	if (self.drop_item_type) then
		if (type(self.drop_item_type) == "table") then
		    local i
		    for i=1,100 do
				if (self.drop_item_type[i]) then
				    dsb_spawn(self.drop_item_type[i], IN_OBJ, id, VARIABLE, 0)
				else
					break
				end
			end
		else
			dsb_spawn(self.drop_item_type, IN_OBJ, id, VARIABLE, 0)
		end
	end
end

function setup_rockpile_drop(self, id)
	if (exvar[id] and exvar[id].no_auto_drop) then
		return
	end
	
	local b = dsb_rand(1, 2)
	while (b > 0) do
		b = b - 1
		dsb_spawn("boulder", IN_OBJ, id, VARIABLE, 0)
	end	
	local r = dsb_rand(0, 2)
	while (r > 0) do
		r = r - 1
		dsb_spawn("rock", IN_OBJ, id, VARIABLE, 0)
	end
	
	if (dsb_rand(0, 1) == 0) then
		dsb_spawn("stick", IN_OBJ, id, VARIABLE, 0)
	end
end

function setup_knight_drop(self, id)
	if (exvar[id] and exvar[id].no_auto_drop) then
		return
	end
	dsb_spawn("footplate_cursed", IN_OBJ, id, VARIABLE, 0)
	dsb_spawn("legplate_cursed", IN_OBJ, id, VARIABLE, 0)
	dsb_spawn("torsoplate_cursed", IN_OBJ, id, VARIABLE, 0)
	dsb_spawn("sword_cursed", IN_OBJ, id, VARIABLE, 0)
	dsb_spawn("sword_cursed", IN_OBJ, id, VARIABLE, 0)
	dsb_spawn("armet_cursed", IN_OBJ, id, VARIABLE, 0)
end

function monster_tintreset(monster, data)
	dsb_set_tint(monster, {0, 0, 0})
end

-- Base function to decide what a monster shoots,
-- if its missile_type is not a function itself.
function determine_missile_type(arch, id, why_shoot)
	local mtype = arch.missile_type
	if (not mtype) then return nil end
	
	-- Standard shot into open space
	if (why_shoot == SHOOT_OPEN_SPACE) then
		return mtype
	end
	
    local boss = dsb_ai_boss(id)
	local door_operation = determine_door_opening(arch, id, boss, why_shoot)
	if (door_operation) then return door_operation end
	
	if (why_shoot == SHOOT_DOOR_BARS) then
		if (obj[mtype].go_thru_bars) then
			return mtype
		else
			return nil
		end
	end
	
	return nil
end

-- Function to determine whether the monster wants to open a door
function determine_door_opening(arch, id, boss, why_shoot)
	-- Some monsters don't even understand the concept of opening doors
	if (arch.oblivious or arch.stupid) then
		return nil
	end
		
	if (why_shoot == SHOOT_DOOR_SOLID) then
		use_exvar(boss)
		
		if (arch.door_opener and arch.door_breaker) then
			local door_id = exvar[boss].mai_pending_door
			if (not door_id) then
			    dsb_write(debug_color, "ERROR: DOOR TARGET ID UNKNOWN")
			    return nil
			end
			if (door_id == exvar[boss].mai_door_failure) then
			    return arch.door_breaker
			else
			    exvar[boss].mai_door_failure = door_id
			    return arch.door_opener
			end
		elseif (arch.door_opener) then
		    return arch.door_opener
		elseif (arch.door_breaker) then
		    return arch.door_breaker
		else
		    return nil
		end
	end
	return nil
end


-- Special cases to decide what a monster shoots
function vexirk_missiles(self, id, why_shoot)

    local boss = dsb_ai_boss(id)
	local door_operation = determine_door_opening(self, id, boss, why_shoot)
	if (door_operation) then return door_operation end
	
	-- Try to slam the party under a door
	if (why_shoot == SHOOT_OPEN_SPACE and dsb_rand(0, 2) == 0 and
		not exvar[boss].mai_slam)
	then
		local plev, px, py = dsb_party_coords()
		local ptile = dsb_fetch(plev, px, py, CENTER)
		local lev, x, y = dsb_get_coords(id)
		if ((x == px or y == py) and ptile) then
			local i
			for i in pairs(ptile) do
				local arch = dsb_find_arch(ptile[i])
				if (arch.type == "DOOR" and
					dsb_get_gfxflag(ptile[i], GF_INACTIVE))
				then
					exvar[boss].mai_slam = true
					return "zospell"
				end
			end
		end
	end
	
	local m_type = dsb_rand(0, 4)
	
	if (dsb_rand(0, 2) == 0) then
		exvar[boss].mai_slam = nil
	end
	
	if (why_shoot == SHOOT_DOOR_BARS) then
	    if (m_type == 0) then
			-- Randomly try to open the door instead
	        return self.door_opener
		elseif (m_type >= 3) then
		    return "poison_ohven"
		else
		    return "poison_desven"
		end
	else
		if (m_type == 0) then
		    return "lightning"
		elseif (m_type == 1) then
		    return "poison_desven"
		elseif (m_type == 2) then
			return "poison_ohven"
		else
		    return "fireball"
		end
	end

end

function materializer_missiles(self, id, why_shoot)
	local m_type = dsb_rand(0, 2)
	
    local boss = dsb_ai_boss(id)
	local door_operation = determine_door_opening(self, id, boss, why_shoot)
	if (door_operation) then return door_operation end

	if (m_type == 1) then
	    return "poison_ohven"
	else
	    return "fireball"
	end

end

-- Probabilities for using a ranged attack
function onefourthranged(self, id)
	local chance = dsb_rand(0, 3)

	if (chance == 0) then return(true)
	else return(false) end
end

function halfranged(self, id)
	local chance = dsb_rand(0, 1)

	if (chance == 0) then return(false)
	else return(true) end
end

function threefourthsranged(self, id)
	local chance = dsb_rand(0, 3)

	if (chance == 0) then return(false)
	else return(true) end
end

-- Used by black flames
function eat_fireball_for_hp(self, id, what)
	local hp = dsb_get_hp(id)
	
	-- The DM algorithm just caps the hp at 1000.
	-- That can be prohibitive at easier levels, and
	-- punish tough black flames.
	local top_hp = dsb_get_maxhp(id) * 2
	
	local range, dir, power = dsb_get_flystate(what)
	hp = hp + calc_fireball_damage(range, power)/2
	if (hp > top_hp) then hp = top_hp end 
	dsb_set_hp(id, hp)
	set_monster_attack(self, id)
	
	local duration = 3
	if (self.attack_show_duration) then
	    duration = self.attack_show_duration + 1
	end
	dsb_ai(id, AI_DELAY_ACTION, duration)
end

-- A zo spell I shot actually hit something.
function zo_success_check(self, id, boss_id, missile_arch, hit_what, hit_ppos)
	if (missile_arch.zo_spell) then
		if (hit_what) then
		    use_exvar(boss_id)
		    if (exvar[boss_id].mai_door_failure == hit_what) then
		        exvar[boss_id].mai_door_failure = nil
			end
		end
	end
end

-- Something is coming. Maybe I can get out of the way...
function monster_dodge(self, id, what)

	local myboss = dsb_ai_boss(id)
	local arrange_dodge = true

	-- frozen monsters will never react
    if (dsb_get_gfxflag(id, GF_FREEZE)) then
		return
	end
	
	-- See if I even need to bother dodging it
	local colinfo
	if (type(self.col) == "function") then
	    colinfo = self:col(what)
	else colinfo = self.col end
	if (not colinfo) then return end
	
	-- Nowhere to slide if I'm big!
	if (self.size == 4) then
		arrange_dodge = false
	end
	
	use_exvar(myboss)	
	if (arrange_dodge) then
		if (self.perfect_dodger) then
			exvar[myboss].mai_arrange = nil
		else
			-- Don't dodge if the party is fighting toe to toe
			local lev, x, y = dsb_get_coords(id)
			local p_lev, p_x, p_y, p_face = dsb_party_coords()
			local dx, dy = dsb_forward(p_face)
			if (p_lev == lev) then
				if (p_x + dx == x and p_y + dy == y) then
					arrange_dodge = false
				end
			end
		
			if (dsb_rand(0, 3) > 0) then
				arrange_dodge = false
			end
			
			if (arrange_dodge) then
				if (exvar[myboss].mai_arrange) then return end
				if (exvar[myboss].mai_shootalign) then return end
				if (exvar[myboss].mai_groupalign) then return end
			end
		end
	end
	
	local lev, x, y, t = dsb_get_coords(id)
	local incomingdir = dsb_get_facedir(what)
	
	if (arrange_dodge) then
		local centered = false
	
		if (t == CENTER) then
			local _
			_, _, _, t = dsb_get_coords(what)
			centered = true
		end                
		local safety = dsb_tileshift(t, (incomingdir + 1) % 4) 
			
		if (self.size == 2) then
			local meface = dsb_get_facedir(id)
			if (meface == incomingdir) then
				if (centered) then 
					safety = dsb_tileshift(safety, meface)
				end
			else
				if (meface ~= (incomingdir + 2) % 4) then
					arrange_dodge = false
				end
			end		
		end
		
		if (arrange_dodge) then
			local blocker_id = search_for_type(lev, x, y, safety, "MONSTER")
			if (not blocker_id) then
				if (monster_rearrange(id, safety, "DODGE")) then
					dsb_ai(myboss, AI_DELAY_TIMER, 3)
					return
				end
			end
		end
	end	
	
	-- At some point, maybe I'll put in code that allows big
	-- monsters or monster groups to dodge by moving, also. Or
	-- maybe I won't because the AI is already a bit of a mess.
	
end

-- Don't override this function. Use the hook function.
function monster_damaged(melee, howmuch, dmg_type, mon, wep, mon_arch, wep_arch, who)
	local newpower = howmuch
	
	if (mon_arch.on_damage) then
		local np = mon_arch:on_damage(mon, howmuch, wep_arch, dmg_type)
		if (np) then newpower = np end
	end
	
	local newerpower = h_monster_took_damage(melee, newpower, dmg_type, mon, wep,
	    mon_arch, wep_arch, who)
	if (newerpower) then
		newpower = newerpower
	end
	
	return newpower
end

-- A table of monster attack types. The monster calls the
-- relevant function from this table based on what its
-- "attack_type" is set to. Of course you can add to this
-- table to create new monster attack types, too...
monster_attack_types = {
	[ATTACK_STEAL] = monster_steal,
	[ATTACK_ANTI_FIRE] = monster_fireattack,
	[ATTACK_PHYSICAL] = monster_meleeattack,
	[ATTACK_PIERCING] = monster_pierceattack,
	[ATTACK_ANTI_MAGIC] = monster_magicattack,
	[ATTACK_WISDOM] = monster_wisdomattack
}