-- Damage functions base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.
							   
-- These functions are not called by the engine directly,
-- but they are used by objects and so you should be careful
-- about overriding them.

-- Controls how well shields protect the various
-- body regions. If you're going to mess with the body
-- parts in inventory_info.lua, you will probably have 
-- to alter this table as well.
-- These are taken directly from CSBwin's byte1412,
-- loaded from graphics.dat item 562.
shield_zone_multiplier = {
	[INV_R_HAND] = 5,
	[INV_L_HAND] = 5,
	[INV_HEAD] = 4,
	[INV_TORSO] = 6,
	[INV_LEGS] = 3,
	[INV_FEET] = 1
}

function hurt_sound(ppos, who)
	dsb_sound(snd.oof[dsb_rand(0,3)])
end

-- This is the main function for when a flying object impacts
-- a member of the party or a monster. It runs some checks and
-- does damage appropriately.
function standard_object_impact(id, hit_what, hit_ppos)
	if (absorb_test(self, id, hit_what)) then
		return true
	end
	
	local arch = dsb_find_arch(id)
	
	local sound = base_hit_sound
	if (arch.hit_sound) then
		sound = arch.hit_sound
	end
	local_sound(id, sound)

	local hit_power = arch.mass/2
	hit_power = hit_power + math.floor(inside_mass(id) / 2)
	if (arch.impact) then
	    hit_power = hit_power + arch.impact
	else
	    hit_power = hit_power + dsb_rand(0, 3)
	end
	
	local base_damage = 0
	if (hit_what or hit_ppos) then
		base_damage = calc_impact_damage(id, hit_power)
	end
	
	impact_success(arch, id, exvar[id], hit_what, hit_ppos)

    if (hit_ppos) then
	    local who = dsb_ppos_char(hit_ppos)			
		if (arch.hits_nonmat) then
			base_damage = base_damage / 2
		end	    
		local adj_damage = physical_damage(hit_ppos, who,
			base_damage, false, { INV_HEAD, INV_TORSO })
	    hurt_sound(hit_ppos, who)
		do_damage(hit_ppos, who, HEALTH, adj_damage)
	end
	
	if (hit_what) then
	    local hp = dsb_get_hp(hit_what)
	    if (hp) then
	    	local m_arch = dsb_find_arch(hit_what)
			
			if (arch.hits_nonmat and not m_arch.nonmat) then
				base_damage = base_damage / 2
			end
			
			hp = physical_damage_monster(hit_what, base_damage)
						
			if (m_arch.proj_stick and arch.can_stick and hp > 0) then
				if (dsb_rand(0, 99) < m_arch.proj_stick) then
					dsb_move(id, IN_OBJ, hit_what, -1, 0)
				end
			end
	    end
	end
end

-- This is the main damage-receiving function.
-- it will automatically keep the values sane, scale
-- them to the internal representation, and pop up the
-- little icon to show how much damage was taken.
-- The actual rendering of the damage icon is handled by
-- sys_render_character_damage in render.lua
function do_damage(ppos, char, dtype, amount, passive)
	local val = dsb_get_bar(char, dtype)
		
	if (val == 0) then
		return
	end
	
	local ntype, namount = h_char_take_damage(ppos, char, dtype, amount, passive)
	if (ntype and namount) then
		dtype = ntype
		amount = namount
	end
	
	if (amount < 1) then
		return
	end
	amount = math.floor(amount)

	-- internal values are 10x
	local i_amount = (10*amount)
	val = val - i_amount
	if (val < 0) then
		amount = i_amount + val
		val = 0
	end
	dsb_set_bar(char, dtype, val)
	
	if (ppos) then
		dsb_damage_popup(ppos, dtype, i_amount)
		
		if (not passive and dsb_get_sleepstate()) then
			dsb_wakeup()
		end
	end
end

function injure_zones(char, val, zonelist)	

	if (zonelist == true) then
		zonelist = inventory_info.injurable_zones
	end

	-- As of DSB 0.65 we grab the value directly from inventory_info
	-- This was formerly hardcoded for no good reason
	local rand_highest = inventory_info.highest_random_injury
	
	-- This code is odd because it potentially targets
	-- more zones than can actually be injured.
	-- CSBwin does the same thing. All it does is somewhat
	-- reduce the chances of actually getting hurt, which
	-- I guess was the idea.
	local targeted_zone = { }
	for d=0,rand_highest do
		targeted_zone[d] = false
	end
	if (type(zonelist) == "table") then
		for i in pairs(zonelist) do
			targeted_zone[zonelist[i]] = true
		end
	else
		targeted_zone[zonelist] = true
	end
				
	-- Originally this would be code of the form:
	-- (170 * (dsb_rand(10, 137)) / 128
	-- which results in a number from ~13 to ~181.
	-- In CSBwin there was a call to TAG016426 in here, which
	-- was probably intended to reduce the odds of an injury if
	-- you had high vitality. The problem with that is TAG016426
	-- would have actually increased the odds of injury the higher
	-- your vitality got. This didn't matter since TAG016426
	-- was broken on the Atari... but apparently it worked on the Amiga.
	-- I'm just going to leave this the way it is because it makes
	-- more sense than any other approach.
	local target_val = dsb_rand(13, 181)
	local hit_zone = { }
	while (val > target_val) do
		local rzone = dsb_rand(0, rand_highest)
		if (targeted_zone[rzone]) then
			-- In DM, injury was just a boolean, so I'm improvising.
			if (not hit_zone[rzone]) then		
				local idmg = math.floor(val / 4) + 1
				cause_injury(char, rzone, idmg)
				hit_zone[rzone] = true
			end
		end
		target_val = target_val * 2
	end
end

function damage_ppos(ppos, type, amount, passive)
	local char

	char = dsb_ppos_char(ppos)

	if (char) then
		do_damage(ppos, char, type, amount, passive)
	end

end

function damage_char(char, type, amount, passive)
	local ppos

	ppos = dsb_char_ppos(char)

	do_damage(ppos, char, type, amount, passive)
end

-- Set a body part to red
function cause_injury(char, where, amount)
	local i_level = dsb_get_injury(char, where)
	if (i_level) then
		dsb_set_injury(char, where, i_level + amount)
	else
		dsb_set_injury(char, where, amount)
	end
end

function poison_dmg_monster(self, id, damage)
	-- Only set the hazard flag on a random chance
	-- or the monster will flee too fast.
	-- Let's base the chance on the monster's poison resist, too.
	local mon_arch = dsb_find_arch(id)
	local pnum = mon_arch.anti_poison
	if (not pnum or pnum > 63) then pnum = 63 end
	if (dsb_rand(0, pnum) < damage) then
		dsb_ai(id, AI_HAZARD, damage)
	end
end


function physical_damage_monster(what, damage_amount)
	local m_arch = dsb_find_arch(what)
	return damage_a_monster(what, m_arch, "armor", damage_amount, 64, 0, nil)

end
			
function damage_a_monster(v, hit_arch, resist_type,
	base_dmg, mfactor, min, callback)
	
	local monster_hp = dsb_get_hp(v)
	
	local res = default_monster_dmgresist[resist_type]
	if (not res) then res = 999 end
	
	local my_res = hit_arch[resist_type]
	if (my_res) then res = my_res end
	
	if (not mfactor) then mfactor = 64 end
	
	if (res < 999) then
		local dmg = (mfactor * base_dmg) / res
		if (min and dmg < min) then dmg = min end
		if (callback) then callback(hit_arch, v, dmg) end
		
		local monster_arch = dsb_find_arch(v)
		
		if (dmg and dmg > 0) then
			dmg = monster_damaged(false, dmg, resist_type,
				v, nil, monster_arch, nil, nil)

			if (not dmg) then dmg = 0 end
			local c_hp = math.floor(monster_hp - dmg)
			if (c_hp < 1) then c_hp = 0 end
			dsb_set_hp(v, c_hp)
			if (c_hp > 1) then
				motivate_slothful_monsters(v)
			end
			return c_hp
		end		
	end
	
	return monster_hp
end

function damage_monster_group(lev, xc, yc, base_dmg, mfactor, 
	resist_type, min, callback)
	
	local hit_mon = dsb_fetch(lev, xc, yc, -1)
	if (hit_mon) then
		local i
		for i in pairs(hit_mon) do
			local v = hit_mon[i]
			local hit_arch = dsb_find_arch(v)
			if (hit_arch.type == "MONSTER") then
				local no_hit = false
				local ext_dmg = 0
			
				if (hit_arch.materializing) then
					no_hit = true
					if (dsb_get_gfxflag(v, GF_ATTACKING)) then
						-- Materializers are harder to zap, because they
						-- are only hit when they are phased in, so they
						-- suffer a bit of bonus damage. The way CSBwin
						-- does this is fairly messy; we can just do it
						-- like this and the results are basically the same.
						ext_dmg = dsb_rand(0, math.floor(base_dmg/8)+1) + dsb_rand(0, 3)
						no_hit = false
					end
				end
				
				if (not no_hit) then
					damage_a_monster(v, hit_arch, resist_type, base_dmg + ext_dmg,
						mfactor, min, callback)
				end
				
			end
		end
	end
end

-- This function happens when a ful bomb goes boom
function explode_thing(self, id, hit_what, hit_ppos)
	local lev, xc, yc, pos = determine_dungeon_location(id)
	local pow = getpower(id)	
	local power = pow*30 + dsb_rand(8, 20)	
	explode_square(lev, xc, yc, power, power, "fire", id)
	local cloudid = dsb_spawn(self.explode_into, lev, xc, yc, pos)
	dsb_set_charge(cloudid, (pow+2)*8)
	dsb_3dsound(self.explode_sound, lev, xc, yc)
	dsb_delete(id)
	
	return true
end

-- This function happens when a ven bomb goes boom
function poisonbomb_thing(self, id, hit_what, hit_ppos)
	local lev, xc, yc, pos = determine_dungeon_location(id)
	local pow = getpower(id)
	local power = pow*30 + dsb_rand(8, 20)
	create_poison_cloud(self.explode_into, id, power, power)
	dsb_3dsound(self.explode_sound, lev, xc, yc)
	dsb_delete(id)
	
	return true
end


-- This function happens when a spell goes boom
function create_spell_burst(s, id, range)
	local lev, xc, yc, pos = determine_dungeon_location(id)
	local cloudid = dsb_spawn(s.explode_into, lev, xc, yc, pos)
	local p_range = range/3
	if (p_range > 60) then
	    p_range = 64
	elseif (p_range < 20) then
		p_range = 20
	end
	
	dsb_set_charge(cloudid, p_range)
	dsb_3dsound(s.explode_sound, lev, xc, yc)
	
	return lev, xc, yc, pos
end

-- Lets black flames absorb fireballs (or whatever)
function absorb_test(arch, id, hit_what)
	if (hit_what) then
		local hit_what_arch = dsb_find_arch(hit_what)
		if (hit_what_arch.absorbs) then
			if (arch == obj[hit_what_arch.absorbs]) then
				hit_what_arch:on_absorb(hit_what, id)
				dsb_msg(0, id, M_DESTROY, 0)
				return true
			end
		end
	end
	return false				
end

-- Informs monster AI that a missile successfully hit
-- (if it's actually still around, that is)
function impact_success(arch, id, exv_table, hit_what, hit_ppos)
	if (exv_table and exv_table.shooter_id) then
		local sid = exv_table.shooter_id
		-- There is a chance that the actual shooter died and some other monster
		-- spawned right away and got the exact same id, so we'll check a tag we stuck
		-- into the shot object.
		if (dsb_valid_inst(sid) and exvar[sid] and (exvar[sid].mai_shoot_tag == exv_table.shoot_tag)) then
			local shooter_arch = dsb_find_arch(sid)
			if (shooter_arch.on_shot_missile_impact) then
				shooter_arch:on_shot_missile_impact(sid, exv_table.shooter_boss, arch, hit_what, hit_ppos)
			end
		end
	end
end

-- Tweaked so you will only get poisoned if you take
-- a non-trivial amount of damage from the poison impact
function player_poison_impact(hit_ppos, poi)
	local hit_char = dsb_ppos_char(hit_ppos)

	local ddmg = magic_damage(hit_ppos, hit_char, poi)
	if (ddmg < 1) then ddmg = 1 end
	hurt_sound(hit_ppos, hit_char)
	do_damage(hit_ppos, hit_char, HEALTH, ddmg)
	
	if (ddmg > 5 and dsb_rand(0, 1) == 0) then
		poison_character(hit_char, poi)
	end
						  
end	

function poison_impact(self, id, hit_what, hit_ppos, range, dmg)
	-- In CSBwin, rdmg is another random number between 0 and 15.
	-- Using the damage like this doesn't change the overall results much,
	-- but lets it actually matter in the calculation.
	local rdmg = math.floor(dmg/15)
	if (rdmg > 15) then rdmg = 15 end
	local poi_hit_power = dsb_rand(0, 31) + rdmg
	local poi = calc_impact_damage(id, poi_hit_power)
	
	if (hit_ppos) then
		player_poison_impact(hit_ppos, poi)
	end
	
	if (hit_what) then
	    local hp = dsb_get_hp(hit_what)
	    if (hp) then
	    	local arch = dsb_find_arch(hit_what)
			dsb_set_tint(hit_what, {0, 192, 0})
			dsb_msg(2, hit_what, M_TINT, 0)		
			-- In DM, desven should be* extremely powerful against monsters
			-- with armor <= 64, and completely ineffective against
			-- monsters with armor > 64. I'm not sure if this was
			-- intentional or a side effect of DM trying to re-use
			-- lots of code and data to save space. It seems a little
			-- weird to me, though, so I've tweaked it.
			-- (Revised in 0.37 to get a smoother damage curve)
			--
			-- *Note as of DSB 0.59: it says "should be" because apparently
			-- desven is hardcoded to only do 1 HP of damage. I don't know
			-- what's up with that, but I am not going to copy that behavior...
			local armor = arch.armor
			if (armor < 160) then
				if (armor > 40) then
					local armor_val = (armor - 40) / 120
					armor_val = 1.0 - armor_val
					poi = math.floor(poi * armor_val)
				end       
				damage_a_monster(hit_what, arch, "anti_poison", poi, 32, 1, nil)
			end
		end
	end
	return true
end

-- Lightning did less cloud damage than fireballs, but
-- unlike fireballs, the impact damage was significant.
function lightning_impact(self, id, hit_what, hit_ppos, range, dmg)
	-- In CSBwin, rdmg is another random number between 0 and 15.
	-- Using the damage like this doesn't change the overall results much,
	-- but lets it actually matter in the calculation.
	local rdmg = math.floor(dmg/15)
	if (rdmg > 15) then rdmg = 15 end
	local hit_power = 5 * (10 + dsb_rand(0, 15) + rdmg)

	local strike_damage = calc_impact_damage(id, hit_power)

    if (hit_ppos) then
	    local who = dsb_ppos_char(hit_ppos)
		local adj_damage = magic_damage(hit_ppos, who, strike_damage)
		do_damage(hit_ppos, who, HEALTH, adj_damage)
	end

	if (hit_what) then
	    local hp = dsb_get_hp(hit_what)
	    if (hp) then
	    	dsb_set_tint(hit_what, {255, 255, 0})
			dsb_msg(2, hit_what, M_TINT, 0)			
			physical_damage_monster(hit_what, strike_damage)

	    end
	end
	
	return true
end

function spell_explosion(self, id, hit_what, hit_ppos)
	if (absorb_test(self, id, hit_what)) then
		return true
	end
	local range, dir, dmg = dsb_get_flystate(id)
	
	local dmod = 1
	if (self.explosion_power_modifier) then
		dmod = self.explosion_power_modifier
	end
	
	local imod = 1
	if (self.impact_power_modifier) then
		imod = self.impact_power_modifier
	end
	
	local dispmod = 1
	if (self.explosion_display_power_modifier) then
		dispmod = self.explosion_display_power_modifier
	end
	
	local lev, xc, yc, pos
	if (self.explode_into_cloud) then
		lev, xc, yc, pos = determine_dungeon_location(id)
		create_poison_cloud(self.explode_into, id, range, dmg)
		local_sound(id, self.explode_sound)
	elseif (not self.explode_into) then
		local_sound(id, self.explode_sound)
	else
		lev, xc, yc, pos = create_spell_burst(self, id, range * dmod * dispmod)
	end
	
	if (self.on_impact_success) then
		self:on_impact_success(id, exvar[id], hit_what, hit_ppos)
	elseif (self.impact_success ~= false) then
		impact_success(self, id, exvar[id], hit_what, hit_ppos)
	end
	
	if (self.on_target_explode) then
		self.on_target_explode(self, id, hit_what, hit_ppos, range * imod, dmg * imod)
	end
	
	if (self.on_location_explode) then
		self.on_location_explode(lev, xc, yc, range * dmod, dmg * dmod,
			self.explosion_type, id)
	end
	
	dsb_delete(id)
	return true
end


function desew_explode_square(lev, xc, yc, range, dmg)
	local base_dmg = calc_fireball_damage(range, dmg)
	damage_monster_group(lev, xc, yc, base_dmg, 32, "anti_desew", 1, nil)
	return true
end

-- Not strictly a "damage" function, but grouped with the
-- other spell explosions for consistency...
function zo_explode_square(lev, xc, yc, range, dmg, type, current_id)
	local got_button = false
	local c_objs = dsb_fetch(lev, xc, yc, CENTER)
	if (not c_objs) then return(true) end
	
	-- Zo only works on a door with a control on it
	for i in pairs(c_objs) do
	    local v = c_objs[i]
	    local v_arch = dsb_find_arch(v)	
	    
	    if (exvar[v] and exvar[v].zoable) then
	    	local zo_value = exvar[v].zoable
	    	if (zo_value == true) then
	    		got_button = true
	    	else
	    		local z_power = calc_fireball_damage(range, dmg)
				if (z_power >= zo_value) then
					got_button = true
				end	
	    	end
	    	break
	    end
	    
	        
		if (v_arch.door_actuator) then
			got_button = true
			break
		end           
		
	end
	
	if (not got_button) then
		return true
	end
	
	local current_arch = dsb_find_arch(current_id)
	for i in pairs(c_objs) do
	    local v = c_objs[i]
	    local v_arch = dsb_find_arch(v)
	    if (v_arch.type == "DOOR") then
			dsb_msg(0, v, M_TOGGLE, 0)
			impact_success(current_arch, current_id, exvar[current_id], v, hit_ppos)
		end
	end
	
	return true
end

function create_poison_cloud(exp_into, id, range, dmg)
    local lev, xc, yc = determine_dungeon_location(id)
    
    local cloud_there = dsb_fetch(lev, xc, yc, CENTER)
    local cloudid
	if (cloud_there) then
		local i
	    for i in pairs(cloud_there) do
	    	local v = cloud_there[i]
	    	local v_arch = dsb_find_arch(v)
	    	if (v_arch == obj[exp_into]) then
	    		cloudid = v
				break	
			end
	    end
	end
    
    -- Range is not used, only dmg. However, in the formulas that
    -- use this function, range and dmg are set to the same value.
    if (not cloudid) then
		cloudid = dsb_spawn(exp_into, lev, xc, yc, CENTER)
		exvar[cloudid] = { delta = 2, apower = dmg }
	else
		exvar[cloudid].apower = exvar[cloudid].apower + dmg
	end
	
	if (exvar[cloudid].apower > 360) then
		exvar[cloudid].apower = 360
	end
	
	local p_range = (exvar[cloudid].apower)/3
	if (p_range > 60) then
	    p_range = 64
	elseif (p_range < 18) then
		p_range = 18
	end
	dsb_set_charge(cloudid, p_range)	              		
	
	return cloudid
end

function poison_damage_inside(id, data)
	if (not exvar[id] or not exvar[id].apower) then
		return
	end
	
	local lev, xc, yc = dsb_get_coords(id)
	local apower = exvar[id].apower
	local base_dmg = apower/32
	if (apower < 176 and base_dmg > 4) then base_dmg = 4 end
	base_dmg = base_dmg + dsb_rand(0,1)
	if (base_dmg < 1) then base_dmg = 1
	elseif (base_dmg > 6) then base_dmg = 6 end
	
	local p_at = dsb_party_at(lev, xc, yc)
	if (p_at) then
		local ppos
		for ppos=0,3 do
			local who = dsb_ppos_char(ppos, p_at)
			if (valid_and_alive(who)) then
				do_damage(ppos, who, HEALTH, base_dmg)
			end
		end
	else	
		damage_monster_group(lev, xc, yc, base_dmg, 32,
			"anti_poison", 0, poison_dmg_monster)
	end
	
	dsb_msg(1, id, M_NEXTTICK, 0)
end

function explode_square(lev, xc, yc, range, dmgpower, hit_type, exploding_inst)
	local base_dmg = calc_fireball_damage(range, dmgpower)
	local p_at = dsb_party_at(lev, xc, yc)
	local dmgresist
	
	-- A bit of a hack. Monster fireballs in CSBwin never seem
	-- to blow up doors. So aside from monsters who specifically have
	-- a door_breaker defined, don't let them do anything to doors.
	local can_explode_door = true
	if (exvar[exploding_inst] and exvar[exploding_inst].no_door_break) then
		can_explode_door = false
	end
	
	-- A brief note as of version 0.56:
	-- After looking through the CSBwin source code again,
	-- I'm sort of confused as to where I got the fire damage
	-- algorithm that I use in DSB. The one in DM seems to be
	-- based on subracting (resistance * 2 + 1) from fire damage,
	-- not doing a "multiply then divide", like poison, melee, etc.
	-- So it would appear I used the wrong algorithm when porting.
	-- Too much coding late at night, or something like that, maybe.
	-- Anyway, it seems to work fine so I'm not going to make any
	-- huge changes now, but if something seems off, this is
	-- a good guess why...
	if (hit_type == nil) then dmgresist = "anti_fire"
	else dmgresist = "anti_" .. hit_type end

	if (p_at) then
		local ppos
		for ppos=0,3 do
			local who = dsb_ppos_char(ppos, p_at)
			if (valid_and_alive(who)) then
				local dmg = fire_damage(ppos, who, base_dmg, true)
				do_damage(ppos, who, HEALTH, dmg)
				injure_zones(who, dmg, true)
			end
	    end
	else
		damage_monster_group(lev, xc, yc, base_dmg, 32, dmgresist, 1, nil)
	end
	
	if (can_explode_door) then
		local door_id = search_for_type(lev, xc, yc, CENTER, "DOOR")
		if (door_id) then
			explode_door(door_id, base_dmg)
		end
	end
end

-- Determines the effectiveness of armor
-- Based on CSBwin TAG01680a and TAG009470
function calc_armor_power(who, where, piercing)
	local armor_power = 0
	local armor = dsb_fetch(CHARACTER, who, where, 0)

	if (armor) then
		local aarch = dsb_find_arch(armor)
		
		-- so a suit of armor held in hand isn't worth anything
		if (where <= INV_L_HAND and aarch.class ~= "SHIELD") then
			return 0
		else
			if (aarch.armor_str) then
				if (piercing) then
				    armor_power = (aarch.armor_str*(aarch.sharp_resist+4))/8
				else
				    armor_power = aarch.armor_str
				end
			end
		end
	end

	local injval = dsb_get_injury(who, where)
	if (injval) then
		injval = math.floor(injval/10) + dsb_rand(0, 2)
		if (injval < 8) then injval = 8 end
		armor_power = armor_power - injval
		if (armor_power < 0) then armor_power = 0 end
	end

	return armor_power
end

-- Averages the armor power over a few inventory zones
-- Based on CSBwin DamageCharacter
function average_zone_armor_power(who, zones, piercing)
	
	if (not zones) then
		return 0
	end
	
	local zt = zones
	if (zones == true) then
		zt = inventory_info.injurable_zones
	elseif (type(zones) ~= "table") then
		zt = { zones }
	end

	local avgsum = 0
	local i = 1
	while (zt[i]) do
		local lsp = calc_shield_power(who, piercing, INV_L_HAND) *
			shield_zone_multiplier[zt[i]]
		local rsp = calc_shield_power(who, piercing, INV_R_HAND) *
			shield_zone_multiplier[zt[i]]
		
		if (zt[i] == INV_L_HAND) then
			avgsum = avgsum + (lsp / 16) + (rsp / 32)
		elseif (zt[i] == INV_R_HAND) then
			avgsum = avgsum + (lsp / 32) + (rsp / 16)
		else 	 
			avgsum = avgsum + calc_armor_power(who, zt[i], piercing)
			avgsum = avgsum + (lsp / 32)
			avgsum = avgsum + (rsp / 32)	
		end      
		i = i + 1
	end
	-- Stop division by zero if we get passed a stupid table
	if (i == 1) then return 0 end
	
	local avg = math.floor(avgsum / (i - 1))
	return avg
end

-- Determines the effectiveness of shields
-- Based on CSBwin TAG01680a
-- It would appear that the common conception that shields in DM are
-- completely ignored is not correct, as I couldn't find anything
-- in the code that implied shields were completely thrown out. Their
-- contribution to the overall armor power was partially figured upon
-- the shield's throwing distance, and then divided by 32, though, so
-- we ended up with a rather strange value that might well have been
-- a negligible contribution in normal play... 
-- I've done my best to reproduce it faithfully, however!
-- Custom dungeon designers who want more powerful shields
-- can tweak the shield_zone_multiplier table.
function calc_shield_power(who, piercing, loc)
	local total_shield = 0
	local item = dsb_fetch(CHARACTER, who, loc, 0)
	if (item) then
		local ap = calc_armor_power(who, loc, piercing)
		if (ap > 0) then
			local block_power = calc_tpower(who, item, loc, false)
			total_shield = ap + block_power
		end
	else
		return 0
	end
	return total_shield
end

-- Add in any physical defensive bonuses, such as ddefense and vitality
-- Based on CSBwin TAG01680a
function calc_total_phys_defense(who, piercing, base)
	local vit_base_bonus = (dsb_get_stat(who, STAT_VIT) / 80) + 1
	local vit_bonus = dsb_rand(0, vit_base_bonus)
	if (piercing) then vit_bonus = vit_bonus / 2 end
	
	local defense_bonus = 0
	-- A character's word64 in CSBwin
    if (ch_exvar[who] and ch_exvar[who].ddefense) then
		defense_bonus = defense_bonus + ch_exvar[who].ddefense
	end		
	local shield = dsb_get_condition(who, C_SHIELD)
	if (shield) then
		defense_bonus = defense_bonus + shield	
	end
	
	local bonus = math.floor(base + vit_bonus + defense_bonus)
	if (bonus > 100) then
		bonus = 100
	elseif (bonus < 0) then
		bonus = 0
	end
	return bonus
end

-- A thrown instance has hit something
-- Based on CSBwin DetermineMagicDamage (actually used for more than magic)
-- DM's default function was IMO broken for objects: "damagepower," which
-- was heavily affected by ninjaskill was used as follows:
-- 		sub_damage = (32 - damagepower/8)
--    	if (dmg/2 < dmg - sub_damage) then return (dmg - sub_damage)
-- This is (almost?) never true, and hardly ever matters, anyway...
-- I've added "power_factor" as a tweak to make the skill matter more here.
-- It factors in the damagepower more heavily.
function calc_impact_damage(id, hit_power)
	local range, dir, damagepower = dsb_get_flystate(id)
	local r_dmg = (range + hit_power)/16 + 1
	local power_factor = dsb_rand(damagepower/24, (damagepower/12) + 1)
	local rand_factor = dsb_rand(0, r_dmg/2 + 1)

	local dmg = (r_dmg + rand_factor + power_factor)/2

	return (dmg)
end

-- This one is pulled out of CSBwin CreateCloud. Fireballs also
-- do impact damage, like objects, but it's pathetic, and covered
-- here by just adding a small random value.
function calc_fireball_damage(range, power)
	local dmg = range/2 + dsb_rand(1, 5)
	dmg = dmg + dsb_rand(1, math.floor((power/2)+1))
	return (dmg)
end

-- These damage functions are all roughly inspired by CSBwin
-- DamageCharacter, but I've replaced the one gigantic function
-- (and its black magic) with some smaller, more specialized
-- functions that should hopefully be easier to handle.
-- I've gone back through the code, and I'm fairly certain that
-- these functions are now much closer to the way DM actually
-- takes care of things...
function physical_damage(ppos, who, base_damage, piercing, zones)
	if (base_damage == 0) then return 0 end
	
	local armor = average_zone_armor_power(who, zones, piercing)			
	local def = calc_total_phys_defense(who, piercing, armor)

	local a_factor = (130 - def)
	local adj_damage = (base_damage * a_factor) / 64
	if (adj_damage < 1) then
	    adj_damage = 1
	end
	
	return adj_damage
end

-- I had this wrong before. Apparently, a wisdom-based
-- attack goes through -everything-, including any shields,
-- armor and magical defenses. So it's a really simple
-- formula.
function wisdom_damage(ppos, who, base_damage)
	if (base_damage == 0) then return 0 end
	
	local wis = dsb_get_stat(who, STAT_WIS)

	local dmg = ((1150-wis) * base_damage)/640
	if (dmg < 1) then dmg = 0 end

	return dmg
end

-- Magic-based attacks go through everything, too, except
-- for spellshields. Armor can't save you.
function magic_damage(ppos, who, base_damage)
	if (base_damage == 0) then return 0 end
	
	local antimagic = dsb_get_stat(who, STAT_AMA)
	local adj_damage = ((1700-antimagic) * base_damage)/1280

	local spellshield = dsb_get_condition(who, C_SPELLSHIELD)
	if (spellshield) then
		adj_damage = adj_damage - spellshield
		if (adj_damage < 1) then
			return 0
		end
	end

	-- My tweak. DM let the damage drop to 0
	-- Without a spellshield, I think you should always take
	-- a little bit of damage.
	if (adj_damage < 5) then adj_damage = dsb_rand(2, 5) end

	return adj_damage
end

function fire_damage(ppos, who, base_damage, zones)
	if (base_damage == 0) then return 0 end
	
	local antifire = dsb_get_stat(who, STAT_AFI)
	
	local adj_damage = ((1700-antifire) * base_damage)/1280
	
	-- Fire damage is never allowed to drop to less than 20% of 
	-- its base value due to anti-fire. Anti-fire was broken on
	-- the Atari ST version of DM (and in CSBwin for a long time)
	-- so this is a little nod to those extra-deadly fireballs.
	-- (Anti-magic was broken, too, but nobody really noticed
	-- because there wasn't anything nearly as nasty that you 
	-- were getting hit with that used it as a resistance stat...)
	if (base_damage > 40 and base_damage > (adj_damage*5)) then
		adj_damage = math.floor(base_damage/5)
	end
		
	local fireshield = dsb_get_condition(who, C_FIRESHIELD)
	if (fireshield) then
		adj_damage = adj_damage - fireshield
		if (adj_damage < 1) then
			return 0
		end
	end
	
	local armor = average_zone_armor_power(who, zones, false)			
	local def = calc_total_phys_defense(who, false, armor)

	local a_factor = (130 - def)
	local adj_damage = (adj_damage * a_factor) / 64
	
	-- My tweak. DM let the damage drop to 0
	-- Without a fireshield, I think you should always take
	-- a little bit of damage.
	if (adj_damage < 5) then adj_damage = dsb_rand(2, 5) end

	return adj_damage
end


-- This function was completely rewritten for DSB 0.58. The old version was
-- hacked together by observation, and tended to produce fairly DM-like
-- results, but used an algorithm completely different from how it worked
-- in DM. This one hopefully is much more accurate.
function pit_damage(base_damage)
	local ppos
	for ppos=0,3 do
	    local who = dsb_ppos_char(ppos)
		if (valid_and_alive(who)) then
			local pit_zones = { INV_LEGS, INV_FEET }
			
			local adj_damage = physical_damage(ppos, who, base_damage, false, pit_zones)
			-- Falling down a pit should always hurt a little!
			if (adj_damage < 4) then
				adj_damage = dsb_rand(1, 4)
			end
			
			-- Added in DSB 0.58. No base code uses this, but
			-- custom dungeons may want to hook onto it.
			if (ch_exvar[who] and ch_exvar[who].fall_safety) then
				adj_damage = 0
			end
			
			if (adj_damage > 0) then
				do_damage(ppos, who, HEALTH, adj_damage, false)
				if (adj_damage > 10) then
					injure_zones(who, adj_damage, pit_zones)
				end
			end
					
		end
	end
end