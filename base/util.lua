-- Utility functions base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- These functions are not called by the engine directly,
-- but they are used by the default system functions and
-- by objects to do various tasks, and you should be careful
-- about overriding them.
		
function alticon(self, id, who) dsb_set_gfxflag(id, GF_ALT_ICON) end
function normicon(self, id, who) dsb_clear_gfxflag(id, GF_ALT_ICON) end

function spawn_in_pack(arch, whose_pack)
	local slot = INV_PACK
	         
	while(dsb_fetch(CHARACTER, whose_pack, slot, 0)) do
		slot = slot + 1
	end
	
	return (dsb_spawn(arch, CHARACTER, whose_pack, slot, 0))
end

-- Called when someone dies.
function drop_all_items_and_magicshields(ppos, who, mouse_drop)
	local lev, xc, yc, tile_pos
	
	lev, xc, yc = dsb_party_coords()
	tile_pos = dsb_ppos_tile(ppos)

	local slot = 0
	while(slot < MAX_INV_SLOTS) do
	 	local item = dsb_fetch(CHARACTER, who, slot, 0)
	 	if (item) then
	 		dsb_move(item, lev, xc, yc, tile_pos)
	 	end

	 	slot = slot + 1
	end
	
	-- Drop the mouse hand item too, if necessary
	if (mouse_drop) then
		dsb_move(mouse_drop, lev, xc, yc, tile_pos)
	end
	
	-- If there are instances bound to this character
	-- (for now shield controllers, but it could be anything)
	-- then destroy them...
	local id
	for id in dsb_insts() do
		local i_arch = dsb_find_arch(id)
		if (i_arch.bound_to_character) then
			if (exvar[id].owner == who) then
				dsb_delete(id)
			end
		end
	end
end

-- These functions were primarily to support DDM and hand coders.
-- DDM seems dead, and hand coding never really took off.
-- So I'm declaring them all deprecated. The first time ESB parses
-- a dungeon that used them, they'll vanish, anyway.
--
-- Deprecated
function spawn_pit(lev, xc, yc, pit_type, ceil_pit_type, deactive)

	if (pit_type == nil) then pit_type = "pit" end
	
	local pit_id = dsb_spawn(pit_type, lev, xc, yc, CENTER)
		
	if (deactive == true) then
		dsb_disable(pit_id)
	end
	
	return(pit_id)
end
-- Deprecated
function spawn_door(lev, xc, yc, type, button, frame_type)

	if (frame_type == nil) then frame_type = "doorframe" end
	if (frame_type ~= false) then
		dsb_spawn(frame_type, lev, xc, yc, CENTER)
	end
	
	local targ = dsb_spawn(type, lev, xc, yc, CENTER)
	if (button) then
		if (button == true) then button = "doorbutton" end
		local tmp = dsb_spawn(button, lev, xc, yc, CENTER)
		exvar[tmp] = { target=targ }
	end
	
	return targ
end
-- Deprecated
function spawn_monster(type, lev, xc, yc, pos, hp) 
	tmp = dsb_spawn(type, lev, xc, yc, pos) 
    if (hp and hp > 0) then 
    	dsb_set_hp(tmp, hp) 
        dsb_set_maxhp(tmp, hp) 
    end 
    
    return tmp 
end

-- This one is still used by ESB
function mon_hp(mon, hp)
	dsb_set_hp(mon, hp) 
    dsb_set_maxhp(mon, hp) 
end

-- Invoked via sys_init_monster_hp
function calc_monster_initial_hp(base_hp, level, multiplier)
 	local xpm
	if (multiplier) then
		xpm = multiplier
	else
		xpm = dsb_get_xp_multiplier(level)
	end
	local rand = dsb_rand(0, (base_hp/4)+1)
	return ((xpm*base_hp) + rand)
end

-- An object is changing into something else
-- (or disappearing if nothing is defined)
function do_convert(arch, id, typestr)
	local convtype = "convert_" .. typestr
	local convarch = arch[convtype]
	local use_qswap = false 
	
	if (exvar[id] and exvar[id][convtype]) then
		convarch = exvar[id][convtype]
		if (exvar[id][convtype .. "_qswap"]) then
			use_qswap = true
		end
	end
	
	if (convarch) then
		if (arch[convtype .. "_qswap"]) then
			use_qswap = true
		end
			
		if (use_qswap) then
			dsb_qswap(id, convarch)
		else
			dsb_swap(id, convarch)
		end 
	else
		dsb_msg(0, id, M_CLEANUP, 0)
		dsb_msg(0, id, M_DESTROY, 0)
	end
end

-- Returns coordinates independent of being carried etc.
function determine_dungeon_location(id)
	local lev, x, y, pos = dsb_get_coords(id)

	if (lev == CHARACTER or lev == MOUSE_HAND) then
		lev, x, y = dsb_party_coords()
		return lev, x, y, CENTER
	elseif (lev == IN_OBJ) then
	    return determine_dungeon_location(x)
	else
	    return lev, x, y, pos
	end
end

-- Sums up the mass of anything inside this object
function inside_mass(id)
	local sum = 0
	
	for iobj in dsb_in_obj(id) do
		local iarch = dsb_find_arch(iobj)
		if (iarch.mass) then
			sum = sum + iarch.mass
		end
		sum = sum + inside_mass(iobj)
	end
	
	return sum	
end

-- Creates a blank exvar table for an instance
-- without exvars so Lua won't complain about
-- accessing nils
function use_exvar(id)
	if (not exvar[id]) then
		exvar[id] = { }
	end
end

function use_ch_exvar(id)
	if (not ch_exvar[id]) then
		ch_exvar[id] = { }
	end
end

-- Do housekeeping on exvars so most
-- functions that use them don't have to care about
-- whether something is undefined or not
function change_exvar(who, val, delta, max)
	if (not exvar[who]) then
	    exvar[who] = { [val] = 0 }
	end

	if (exvar[who][val]) then
	    exvar[who][val] = exvar[who][val] + delta
	else
	    exvar[who][val] = delta
	end
	
	if (delta < 0 and max) then
		if (max and exvar[who][val] < max) then
			exvar[who][val] = max
		end
		max = nil
	end	

	if (exvar[who][val] == 0) then
	    exvar[who][val] = nil
	else
		if (max and exvar[who][val] > max) then
			exvar[who][val] = max
		end
	end
end

function change_ch_exvar(who, val, delta, max)
	if (not ch_exvar[who]) then
	    ch_exvar[who] = {
	        [val] = 0
		}
	end
	
	if (ch_exvar[who][val]) then
	    ch_exvar[who][val] = ch_exvar[who][val] + delta
	else
	    ch_exvar[who][val] = delta
	end
	
	if (delta < 0 and max) then
		if (max and ch_exvar[who][val] < max) then
			ch_exvar[who][val] = max
		end
		max = nil
	end	
	
	if (ch_exvar[who][val] == 0) then
	    ch_exvar[who][val] = nil
	else
		if (max and ch_exvar[who][val] > max) then
			ch_exvar[who][val] = max
		end
	end
end

-- Lookup the power exvar and complain if it's not there
function getpower(id)
	if (exvar[id] and exvar[id].power) then
	    return exvar[id].power
	else
	    local arch = dsb_find_arch(id)
	    dsb_write(debug_color, "ERROR: POWER NEEDED AND NOT DEFINED FOR INST " .. id)
		dsb_write(debug_color, "  (" .. arch.name .. ")")
		
		use_exvar(id)
		exvar[id].power = 1
	    return 1
	end
end

function valid_and_alive(who)
	if (who and dsb_get_bar(who, HEALTH) > 0) then
		return true
	end
	
	return false
end

function local_sound(id, p_sound, table_lookup, ex_loop)

	local lev, xc, yc, pos = dsb_get_coords(id)
	
	local real_sound = p_sound
	if (table_lookup) then
	    real_sound = snd[p_sound]
	    if (not real_sound) then
			dsb_write(debug_color, "ERROR: INVALID SOUND " .. string.upper(p_sound))
			return nil
		end
	end
	
	return dsb_3dsound(real_sound, lev, xc, yc, ex_loop)
end

function play_arch_local_sound(arch, id, sound_name)
	local msound = nil
	
	if (arch[sound_name]) then
		if (type(arch[sound_name]) == "function") then
			msound = arch[sound_name](arch, id)
		else
			msound = arch[sound_name]
		end
	end
	
	if (msound) then
		local loopname = "loop_" .. sound_name
		local loophandle = "loop_" .. sound_name .. "_hand"
		local ex_loop = false
		if (arch[loopname]) then
			ex_loop = true
			use_exvar(id)
			if (exvar[id][loophandle]) then
				dsb_stopsound(exvar[id][loophandle])
			end
		end
		local snd_id = local_sound(id, msound, nil, ex_loop)
		if (ex_loop) then
			exvar[id][loophandle] = snd_id 
		end
	end
end

function click_sound(arch, id)
	if (not exvar[id]) then return end
	if (not exvar[id].silent) then
		if (exvar[id].sound) then
		    dsb_sound(snd[exvar[id].sound])
		elseif (not arch.default_silent) then
		    if (arch.default_sound) then
		        dsb_sound(snd[arch.default_sound])
			else
			    dsb_sound(snd.click)
			end
		end
	end
end


function stop_sound_handle(id, sound_name)
	local loophandle = "loop_" .. sound_name .. "_hand"
	if (exvar[id] and exvar[id][loophandle]) then
		dsb_stopsound(exvar[id][loophandle])
		exvar[id][loophandle] = nil
	end
end

function attenuate_by_stamina(who, power)
	local stam = dsb_get_bar(who, STAMINA)
	local halfmaxstam = dsb_get_maxbar(who, STAMINA)/2

	if (stam < halfmaxstam) then
		local adj_power = ((power/2) * stam) / halfmaxstam
		
		power = (power/2) + adj_power
	end
	
	return power
end

function burn_stamina(who, howmuch)
	local stamina = dsb_get_bar(who, STAMINA)	
	stamina = stamina - howmuch	
	if (stamina < 0) then
	    damage_char(who, HEALTH, -1 * math.floor(stamina / 20 + 0.5))
		dsb_set_bar(who, STAMINA, 0)
	else
		dsb_set_bar(who, STAMINA, stamina)
	end
end

-- Shows the power of a bomb only if you're a good enough
-- wizard to figure out what it is
function bomb_namechanger(self, id, who_look)
	if (not who_look) then
		return nil
	end
	
	if (not exvar[id] or not exvar[id].power) then
	    return "FIX ME"
	end

	local level = determine_xp_level(who_look, CLASS_WIZARD, 0)
	if (level >= 2) then
		return powchar[exvar[id].power] .. " " .. self.name
	else
		return nil
	end
end

-- Shows the power of a potion only if you're a good enough
-- priest to figure out what it is
function potion_namechanger(self, id, who_look)
	if (not who_look) then
		return nil
	end
	
	if (not exvar[id] or not exvar[id].power) then
	    return "FIX ME"
	end

	local level = determine_xp_level(who_look, CLASS_PRIEST, 0)
	if (level >= 2) then
		return powchar[exvar[id].power] .. " " .. self.name
	else
		return nil
	end
end


function basic_8_object_subrenderer(arch, id)
	local sr = dsb_subrenderer_target()
	dsb_bitmap_draw(arch.inside_gfx, sr, 0, 0, false)
	dsb_objzone(sr, id, 0, 32, 14)
	dsb_objzone(sr, id, 1, 10, 48)
	dsb_objzone(sr, id, 2, 20, 82)
	dsb_objzone(sr, id, 3, 54, 92)
	dsb_objzone(sr, id, 4, 88, 98)
	dsb_objzone(sr, id, 5, 122, 102)
	dsb_objzone(sr, id, 6, 156, 104)
	dsb_objzone(sr, id, 7, 190, 106)
end

-- Calculations for throwing distance
-- Based quite heavily on CSBwin ThrowByCharacter
function calc_throw(who, id, loc)
	local throw_arch = dsb_find_arch(id)
	local weapon_range = 1
	local xp_amount = 8
	local skilled_throw = false
	
	if (throw_arch.base_range) then
	    weapon_range = throw_arch.base_range

		if (weapon_range > 1) then
			local impact = throw_arch.impact
			if (not impact) then impact = 0 end
			
		    xp_amount = xp_amount + 4 + math.floor(impact/4)
		    skilled_throw = true
		end
	end
	
	local bonus_damage = 0
	if (throw_arch.bonus_damage) then
	    bonus_damage = throw_arch.bonus_damage
	    skilled_throw = true
	end

    xp_up(who, CLASS_NINJA, SKILL_THROWING, xp_amount)

	local adj_mass = throw_arch.mass/2
	adj_mass = math.floor(adj_mass + (inside_mass(id) / 2))
	local stamina_use = adj_mass
	if (stamina_use < 1) then stamina_use = 1
	elseif (stamina_use > 10) then stamina_use = 10 end
	
	-- CSBwin did something nonsensical with stamina here, but it turned
	-- out to just be a bug in CSBwin itself. Now fixed.
	adj_mass = adj_mass - 10
	while (adj_mass > 0) do
	    stamina_use = stamina_use + math.floor(adj_mass / 2)
	    adj_mass = adj_mass - 10
	end
	burn_stamina(who, stamina_use)
	
	local ninjaskill = determine_xp_level(who, CLASS_NINJA, SKILL_THROWING) + 1
    local throw_power = calc_tpower(who, id, loc, true) + weapon_range

	throw_power = (throw_power*3)/2 + dsb_rand(0, 15) + ninjaskill
	
	-- My tweak: separate the throwing of weapons from the throwing of
	-- miscellaneous random dungeon garbage (and make the second a lot
	-- less skillful and powerful)
	-- Modified in DSB 0.58 to be a little more like DM. I don't want
	-- to completely change the feel of the game.
	local min_delta
	if (skilled_throw) then
		-- This formula is used for every object in CSBwin
		damage = (8 * ninjaskill) + bonus_damage + dsb_rand(0, 31)
		if (damage < 40) then
		    damage = 40
		elseif (damage > 200) then
		    damage = 200
		end
		min_delta = 5
	else
		damage = (4 * ninjaskill) + dsb_rand(0, 31)
		if (damage > 200) then
			damage = 200
		end
		min_delta = 7
	end
		
	-- Keep some things from being thrown too hard
	local max_throw_power = 9999
	if (throw_arch.max_throw_power) then
		max_throw_power = throw_arch.max_throw_power
	elseif (throw_arch.useless_thrown) then
	    max_throw_power = 40
	    damage = 1
		min_delta = 8
	end
	
	local delta = min_delta
	if (11 - ninjaskill > min_delta) then
	    delta = 11 - ninjaskill
	end
	
	if (throw_power > max_throw_power) then
		throw_power = max_throw_power
	end
	
	--[[ (debugging)
	dsb_write(debug_color, "THROW POWER " .. throw_power
		.. " DMG " .. damage .. " DEL " .. delta)
	]]
	
	return throw_power, damage, delta
end

-- Calculate "Throwing" Power
-- Based on CSBwin DetermineThrowingDistance
-- (and used for a lot of other things)
function calc_tpower(who, idarch, hand, throwing)
	local base_str = dsb_get_stat(who, STAT_STR)/10 + dsb_rand(0, 15)
	local heavy = dsb_get_maxload(who) / 16
	local power
	local obj_mass = 0
	local id = nil
	local arch = nil
	
	-- Allow either an arch or an id for the second parameter
	if (idarch) then
		if (type(idarch) == "table") then
			id = nil
			arch = idarch
			obj_mass = arch.mass
		else
			id = idarch
			arch = dsb_find_arch(id)
			obj_mass = arch.mass
			obj_mass = obj_mass + inside_mass(id)
		end
	end
		
	if (obj_mass > heavy) then
		local very_heavy = (heavy-12)/2 + heavy
		if (very_heavy < heavy + 2) then very_heavy = heavy + 2 end
		
		if (obj_mass > very_heavy) then
		    power = base_str - 2*(obj_mass - very_heavy)
		else
			power = base_str + (obj_mass - heavy)/2
		end
	else
		power = base_str + obj_mass - 12
	end
	
	-- My tweak: If you're throwing the weapon, make the power bonus vary by
	-- ninja skill. Applying the full bonus to a thrown weapon makes some
	-- strong weapons overpowered when thrown, but it seems there are puzzles
	-- (such as DM's "test your strength") that become a bit too difficult
	-- without having the bonus exist in some form.
	if (arch and arch.base_tpower) then
	    local tpower_bonus = arch.base_tpower
		if (throwing) then
		    local ninja = determine_xp_level(who, CLASS_NINJA, 0)
			if (ninja > 8) then ninja = 8 end
			tpower_bonus = math.floor((tpower_bonus * ninja) / 8)
		end
		power = power + tpower_bonus
	end

	local skillbonus = 0	
	if (arch) then
	    -- Only give a throwing bonus when actually throwing and a swinging bonus when not
		if (throwing and arch.class == "MISSILE") then
			skillbonus = determine_xp_level(who, CLASS_NINJA, SKILL_THROWING) + 1
		elseif (throwing and arch.class == "SHOOTING") then
		    skillbonus = determine_xp_level(who, CLASS_NINJA, SKILL_SHOOTING) + 1
		elseif (not throwing and arch.class == "WEAPON") then
			skillbonus = determine_xp_level(who, CLASS_FIGHTER, SKILL_SWINGING) + 1
		end
	end	
	power = power + 2*skillbonus
	
	power = attenuate_by_stamina(who, power)
	
	local ouch = dsb_get_injury(who, hand)
	if (ouch) then
	    power = power/2
	    
	    -- badly hurt is worse
	    if (ouch > 30) then
	        power = math.floor((power * 30) / ouch)
		end
	end
	
	local r_power = math.floor(power/2)
	if (r_power < 0) then
	    r_power = 0
	elseif (r_power > 100) then
	    r_power = 100
	end
		
	return r_power
end

-- Based on CSBwin Quickness, of course
function calc_quickness(who)
	local q = (dsb_get_stat(who, STAT_DEX) + dsb_rand(0,70)) / 10	
	local loadval = ((q/2) * dsb_get_load(who)) / dsb_get_maxload(who)
		
	q = q - loadval
	
	if (dsb_get_sleepstate()) then
		q = (q/4)
	else
	    q = (q/2)
	end
	
	local lo = dsb_rand(1, 8)
	local hi = dsb_rand(93,100)
	if (q < lo) then
	    q = lo
	elseif (q > hi) then
	    q = hi
	end
	
	return math.ceil(q)
end

function search_for_type(lev, x, y, dir, obj_type)
	local hit_mon = dsb_fetch(lev, x, y, dir)

	if (hit_mon) then
		local i
    	for i in pairs(hit_mon) do
    	    local v = hit_mon[i]
			local hit_arch = dsb_find_arch(v)
			if (hit_arch.type == obj_type) then
			    if (not (dsb_get_gfxflag(v, GF_INACTIVE))) then
			    	return v
				end
			end
		end
	end

	return nil
end

function search_for_class(lev, x, y, dir, obj_class)
	local hit_mon = dsb_fetch(lev, x, y, dir)

	if (hit_mon) then
		local i
    	for i in pairs(hit_mon) do
    	    local v = hit_mon[i]
			local hit_arch = dsb_find_arch(v)
			if (hit_arch.class == obj_class) then
			    if (not (dsb_get_gfxflag(v, GF_INACTIVE))) then
			    	return v
				end
			end
		end
	end

	return nil
end

function search_for_arch(lev, x, y, dir, obj_arch_type)
	local hit_mon = dsb_fetch(lev, x, y, dir)

	if (hit_mon) then
		local i
    	for i in pairs(hit_mon) do
    	    local v = hit_mon[i]
			local hit_arch = dsb_find_arch(v)
			if (hit_arch == obj[obj_arch_type]) then
			    if (not (dsb_get_gfxflag(v, GF_INACTIVE))) then
			    	return v
				end
			end
		end
	end

	return nil
end

-- Something explosive hit a door
function explode_door(door_id, my_fire_power)
	local door_fire_power = 9999

	if (dsb_get_crop(door_id) ~= 0) then
	    return
	end

	if (exvar[door_id] and exvar[door_id].fire_power) then
	    door_fire_power = exvar[door_id].fire_power
	else
	    local door_arch = dsb_find_arch(door_id)
		if (door_arch.fire_power) then
		    door_fire_power = door_arch.fire_power
		end
	end
	
	if (my_fire_power > door_fire_power) then
     	dsb_msg(1, door_id, M_BASH, 2)
	end

end

-- Eats food (with the chewing animation) and drinks water
function eatdrink(self, id, who)
	local delay = false

	if (self.foodval) then
		inventory_info.mouth.icon = gfx.mouth_chewing
		dsb_update_inventory_info()
		dsb_hide_mouse()
		dsb_delay_func(1, function() dsb_lock_game() end)	
		dsb_delay_func(4, function ()
			dsb_show_mouse()
			dsb_sound(base_eat_sound)
			inventory_info.mouth.icon = base_mouth_icon
			dsb_update_inventory_info()
			dsb_set_food(who, dsb_get_food(who) + self.foodval)
			dsb_unlock_game()
		end)
										
		delay = true
	end

	if (self.waterval) then
		dsb_set_water(who, dsb_get_water(who) + self.waterval)
	end

	if (not delay) then
		dsb_sound(base_eat_sound)
	end
end

function drinkpotion(self, id, who)
	dsb_sound(base_eat_sound)
	
	use_exvar(id)
	local pow = getpower(id)
	
	-- Some premixed potions might want to store an absolute power
	local base_power
	if (exvar[id].base_power) then
		base_power = exvar[id].base_power
	else
		base_power = pow * 40 + dsb_rand(0, 15)
	end
	
	if (self.foodval) then
		dsb_set_water(who, dsb_get_water(who) + self.waterval)
	end
	
	if (self.waterval) then
		dsb_set_water(who, dsb_get_water(who) + self.waterval)
	end
	
	self:potion_effect(id, who, base_power)
	
	-- This is for backward compatibility with dungeons that
	-- don't explicitly define a convert_consume for potions
	local swapto = self.convert_consume
	if (not swapto) then swapto = "flask" end
	dsb_swap(id, swapto)
	return true
end

function stat_booster(who, what, base_power)
	local boost = 10*base_power/25 + 80
	local st = dsb_get_stat(who, what)
	local mst = dsb_get_maxstat(who, what)
	
	-- Very big boosts are not as effective
	if (mst > 0 and (st > mst*3)) then
		local over = st/mst
		boost = math.floor(boost * (3/over))
		if (boost < 10) then boost = 10 end
	end
		
	dsb_set_stat(who, what, st + boost)
end

-- A helper function to check if the character is in
-- a position to hit the monster
function front_row_check(where, pface)
	local front_row = false
	
	if (where == pface or where == (pface+1)%4) then
		front_row = true
	else
		local myfront = dsb_tileshift(where, pface)
		if (not dsb_tile_ppos(myfront)) then
			front_row = true
		end
	end
	return front_row
end

-- A function to use up an charge of an item and do
-- something if depleted
function use_charge(what, amount)

	if (not amount or amount <= 0) then
		return false
	end

	local ccharge = dsb_get_charge(what)
	if (not ccharge or ccharge == 0) then
	    return false
	end
	
	ccharge = ccharge - amount
	if (ccharge <= 0) then
		local obj_arch = dsb_find_arch(what)
		local stop_con = false
					
		if (obj_arch.on_deplete) then
		    stop_con = obj_arch:on_deplete(what)
		end
		
		if (not stop_con) then
		    do_convert(obj_arch, what, "deplete")
		end
		
	else
	    dsb_set_charge(what, ccharge)
	end
	
	return true
end

function normalize_stat(mindif, maxdif, amaxdif)
	if (maxdif > amaxdif) then
	    return (dsb_rand(mindif, amaxdif))
	elseif (mindif >= maxdif) then
	    return (maxdif)
	else
	    return (dsb_rand(mindif, maxdif))
	end
end

function open_facing(lev, xc, yc, face)
	local it
	for it=0,3 do
		local dx, dy = dsb_forward(it)		
		if (not dsb_get_cell(lev, xc+dx, yc+dy)) then
		    return it
		end
	end

	-- A special wall is better than an ordinary wall
	for it=0,3 do
		local dx, dy = dsb_forward(it)		
		if (search_for_class(lev, xc+dx, yc+dy, CENTER, "WALL")) then
		    return it
		end
	end
	
	return face
end

function torch_light(self, id, who)

	-- Only do this if the character is in the party
	if (dsb_char_ppos(who)) then   
	
		if (self.on_burn or self.convert_burn) then			
			use_exvar(id)
			if (not exvar[id].pmsg) then
				dsb_msg(5, id, M_NEXTTICK, who)
				exvar[id].pmsg = 1
			end
			
			alticon(self, id, who)
		end
	end
end

function torch_dark(self, id, who)
	normicon(self, id, who)
end

function use_torch_charge(id, data)
	if (dsb_get_gfxflag(id, GF_ALT_ICON)) then
		local torch_arch = dsb_find_arch(id)
	    local charge = dsb_get_charge(id)
	    charge = charge - 1
	    if (charge <= 0) then
			torch_dark(torch_arch, id, who)
			
			local stop_con = false
			if (torch_arch.on_burn) then
				stop_con = torch_arch:on_burn(id)
			end
			if (not stop_con) then
				do_convert(torch_arch, id, "burn")
			end
			
			if (dsb_valid_inst(id)) then
				if (torch_arch.convert_burn) then
					torch_light(obj[torch_arch.convert_burn], id, data)
				end
			end
		else
		    dsb_set_charge(id, charge)
            dsb_msg(4, id, M_NEXTTICK, data)
		end
		set_torch_levels()
	else
		exvar[id].pmsg = nil
	end
end

function torch_value(char, location)
	local torch = dsb_fetch(CHARACTER, char, location, 0)
	if (not torch) then return 0 end

	local arch = dsb_find_arch(torch)
	if (arch.class ~= "TORCH") then return 0 end
	if (not arch.def_charge) then return 0 end
	
	local charge = dsb_get_charge(torch)
	local light = arch.min_light
	light = light + (arch.diff_light * (charge / arch.def_charge))
	
	return light
end

function set_torch_levels()
	local sum_torch = 0
	local best_torch = 0

	local ppos
	for ppos=0,3 do
	    local char = dsb_ppos_char(ppos)
	    if (valid_and_alive(char)) then
			local t_light = torch_value(char, INV_L_HAND)
			sum_torch = sum_torch + t_light
			if (t_light > best_torch) then
				best_torch = t_light
			end
			t_light = torch_value(char, INV_R_HAND)
			sum_torch = sum_torch + t_light
			if (t_light > best_torch) then
				best_torch = t_light
			end
	    end
	end

	local best_light = (best_torch*3)/2
	if (sum_torch > best_light) then
		sum_torch = best_light
	end
	
	dsb_set_light("torches", sum_torch)
end

-- Cursed objects
function apply_curse(self, id, who)
	local max_luck = dsb_get_maxstat(who, STAT_LUC)
	dsb_set_maxstat(who, STAT_LUC, max_luck - 30)
	change_ch_exvar(who, "curses", 1)
end

function remove_curse(self, id, who)
	local max_luck = dsb_get_maxstat(who, STAT_LUC)
	dsb_set_maxstat(who, STAT_LUC, max_luck + 30)
	change_ch_exvar(who, "curses", -1)
end

-- Lucky rabbits foot
function apply_luck(self, id, who)
	change_ch_exvar(who, "luck_bonus", 1)
	if (ch_exvar[who].luck_bonus == 1) then
		local max_luck = dsb_get_maxstat(who, STAT_LUC)
		dsb_set_maxstat(who, STAT_LUC, max_luck + 100)
	end
end

function remove_luck(self, id, who)
	if (ch_exvar[who].luck_bonus == 1) then
		local max_luck = dsb_get_maxstat(who, STAT_LUC)
		dsb_set_maxstat(who, STAT_LUC, max_luck - 100)
	end
	change_ch_exvar(who, "luck_bonus", -1)
end

function boost_with_overflow(who, bar, amount)
	local val = dsb_get_maxbar(who, bar)
	
	local old_overflow = 0
	if (ch_exvar[who] and ch_exvar[who].overflow and ch_exvar[who].overflow[bar]) then
		old_overflow = ch_exvar[who].overflow[bar]
		ch_exvar[who].overflow[bar] = nil
	end
	
	local newval = val + old_overflow + amount
	
	if (newval > 9990) then
		local overflow = newval - 9990
		newval = 9990
		use_ch_exvar(who)
		if (not ch_exvar[who].overflow) then ch_exvar[who].overflow = { } end
		if (not ch_exvar[who].overflow[bar]) then ch_exvar[who].overflow[bar] = 0 end
		ch_exvar[who].overflow[bar] = ch_exvar[who].overflow[bar] + overflow
	end
	
	dsb_set_maxbar(who, bar, newval)
end

-- Utility functions for objects that give a bonus
function mana_boost(self, id, who)
	local mana_up = self.mana_up
	boost_with_overflow(who, MANA, mana_up)
end

function mana_boost_off(self, id, who)
	local mana_up = self.mana_up
	boost_with_overflow(who, MANA, -1*mana_up)
end

function apply_stat_bonus(arch, id, who, m)
	local stat = arch.stat
	local sb = arch.stat_up
	if (type(stat) ~= "table") then
	    stat = { stat }
	end
	if (type(sb) ~= "table") then
	    sb = { sb }
	end
	for s in pairs(stat) do
		local sbnum = sb[s]
		if (not sbnum) then sbnum = sb[1] end
	    dsb_set_stat(who, stat[s], dsb_get_stat(who, stat[s]) + (m * sbnum))
		dsb_set_maxstat(who, stat[s], dsb_get_maxstat(who, stat[s]) + (m * sbnum))
	end

end

function stat_bonus(self, id, who)
	apply_stat_bonus(self, id, who, 1)
end

function stat_bonus_off(self, id, who)
	apply_stat_bonus(self, id, who, -1)
end

function lyf_boost(self, id, who)
	dsb_set_maxbar(who, MANA, dsb_get_maxbar(who, MANA)+40)	
	local b = dsb_get_bonus(who, CLASS_PRIEST, SKILL_POTIONS)
	dsb_set_bonus(who, CLASS_PRIEST, SKILL_POTIONS, b+1)
end

function lyf_boost_off(self, id, who)
	dsb_set_maxbar(who, MANA, dsb_get_maxbar(who, MANA)-40)	
	local b = dsb_get_bonus(who, CLASS_PRIEST, SKILL_POTIONS)
	dsb_set_bonus(who, CLASS_PRIEST, SKILL_POTIONS, b-1)
end

function boost_all_skills(self, id, who)
	for cl=0, (xp_classes-1) do
		for sub=0, xp_subskills[cl+1] do
			local b = dsb_get_bonus(who, cl, sub)
			dsb_set_bonus(who, cl, sub, b + self.boost)
		end
	end
end

function boost_all_skills_off(self, id, who)
	for cl=0, (xp_classes-1) do
		for sub=0, xp_subskills[cl+1] do
			local b = dsb_get_bonus(who, cl, sub)
			dsb_set_bonus(who, cl, sub, b - self.boost)
		end
	end
end

function stairs_col(self, id, what)
	if (what) then
	    local fly = dsb_get_flystate(what)
	    if (fly) then return true
		else
			return false
		end
	else
	    return false
	end
end

function nonmat_col(self, id, what)
	if (what) then
		local fly = dsb_get_flystate(what)
		if (fly) then
		    local what_arch = dsb_find_arch(what)
		    if (what_arch.flying_hits_nonmat) then
		        return true
		    elseif (self.absorbs) then
				if (what_arch == obj[self.absorbs]) then
					return true
				end
				return false
			else
			    return false
			end
		end
	end
	
	return true
end

function doorframe_col(self, id, what)
	if (what) then
		local hit_arch = dsb_find_arch(what)
		if (hit_arch.hits_doorframes) then
		    return true
		end
	end

	return false
end

-- Utility functions for the compass
function compass_turn(id, dir)
	if (dir == 0) then
	    dsb_qswap(id, "compass_n")
	elseif (dir == 1) then
	    dsb_qswap(id, "compass_e")
	elseif (dir == 2) then
	    dsb_qswap(id, "compass_s")
	elseif (dir == 3) then
	    dsb_qswap(id, "compass_w")
	end
end

function comp_fix_facing(self, id, dir)
	compass_turn(id, dir)
end

function comp_fix_facing_pickup(self, id)
	local lev, xc, yc, dir = dsb_party_coords()
	compass_turn(id, dir)
end

function place_into_quiver(who, what, info_table)
	if (place_into_range(who, what, INV_QUIV2, INV_QUIV4, info_table)) then
		return true
	end
	if (place_into_containers_in_range(who, what, INV_QUIVER, INV_QUIV4, "ammo_holder", info_table)) then
		return true
	end
	if (place_into_range(who, what, INV_QUIVER, nil, info_table)) then
		return true
	end
	return false
end

function place_into_containers_in_range(who, what, min_loc, max_loc, tag, info_table)
	local ins_arch = dsb_find_arch(what)
	local i
	for i=min_loc, max_loc do
		local f = dsb_fetch(CHARACTER, who, i, 0)
		if (f) then
			local f_arch = dsb_find_arch(f)
			if ((not tag or f_arch[tag]) and (f_arch.zone_obj or f_arch.objzone_check)) then
				local zone_check = false
				
				if (f_arch.objzone_check and f_arch:objzone_check(f, what, VARIABLE)) then
					zone_check = true
				elseif (f_arch.zone_obj) then
					for zn in pairs(f_arch.zone_obj) do
						if (ins_arch == obj[f_arch.zone_obj[zn]]) then
							zone_check = true
						end
					end
				end
				
				if (zone_check) then
					local c, num_contents = dsb_fetch(IN_OBJ, f, VARIABLE, 0)
					if (not num_contents) then num_contents = 0 end
					local real_contents = num_contents
					if (info_table and info_table.con[f]) then
						num_contents = num_contents + info_table.con[f]
					end
					if (not f_arch.capacity or num_contents < f_arch.capacity) 
					then
						dsb_move(what, IN_OBJ, f, VARIABLE, 0)
						if (info_table) then
							-- It got queued, update the info_table
							local c, new_nc = dsb_fetch(IN_OBJ, f, VARIABLE, 0)
							if (new_nc == real_contents) then
								local i_value = info_table.con[f]
								if (not i_value) then i_value = 0 end
								info_table.con[f] = i_value + 1
							end
						end
						return true
					end
				end 
			end
		end
	end	
	return false
end

function place_into_range(who, what, min_loc, max_loc, info_table)
	if (not max_loc) then
	    max_loc = min_loc
	end

	local i
	for i=min_loc, max_loc do
		local f = dsb_fetch(CHARACTER, who, i, 0)
		if (not f) then
			if (not info_table or not info_table.loc[i]) then
				dsb_move(what, CHARACTER, who, i, 0)
				if (info_table) then
					info_table.loc[i] = what
				end
				return true
			end
		end
	end	
	return false
end

function place_into_slot(did, who, arch, what, where, fit_func, info_table)
	if (did) then return did end
	if (info_table and info_table.loc[where]) then
		return nil
	end
	
	if (fit_check(fit_func, arch, id, who))	 then
		local blocked = dsb_fetch(CHARACTER, who, where, 0)
		if (blocked) then return false end
		what = dsb_pop_mouse()
		dsb_move(what, CHARACTER, who, where, 0)
		if (info_table) then
			info_table.loc[where] = what
		end
		return where
	end
	return nil
end

function put_object_away(who, what, info_table, ammo_placement)		
	local arch = dsb_find_arch(what)
	local placed = false
	
	if (info_table) then
		if (not info_table.con) then info_table.con = { } end
		if (not info_table.loc) then info_table.loc = { } end
	end
	
	if (arch.no_fit_inventory) then
		return false
	end
	
	-- Try to put clothing etc. somewhere it will fit
	placed = place_into_slot(placed, who, arch, what, INV_HEAD, "fit_head", info_table)
	placed = place_into_slot(placed, who, arch, what, INV_TORSO, "fit_torso", info_table)
	placed = place_into_slot(placed, who, arch, what, INV_LEGS, "fit_legs", info_table)
	placed = place_into_slot(placed, who, arch, what, INV_FEET, "fit_feet", info_table)
	placed = place_into_slot(placed, who, arch, what, INV_NECK, "fit_neck", info_table)
	if (placed) then return true end
	
	-- If you have a container in hand, you probably want to use it
	placed = place_into_containers_in_range(who, what, INV_R_HAND, INV_L_HAND, nil, info_table)
	if (placed) then return true end
	
	if (fit_check("fit_quiver", arch, what, who)) then
		local got = place_into_quiver(who, what, info_table)
		if (got) then return true end
	end
	
	placed = place_into_slot(false, who, arch, what, INV_QUIVER, "fit_sheath", info_table)
	if (placed) then return true end
	
	if (ammo_placement) then
		placed = place_into_range(who, what, INV_R_HAND, INV_L_HAND, info_table)
		if (placed) then return true end
	end

	if (fit_check("fit_pouch", arch, what, who)) then
		local got = place_into_range(who, what, INV_POUCH, INV_POUCH2, info_table)
		if (got) then return true end
	end	
	
	placed = place_into_containers_in_range(who, what, INV_POUCH, INV_POUCH2, nil, info_table)
	if (placed) then return true end
					
	placed = place_into_range(who, what, INV_PACK, MAX_INV_SLOTS-1, info_table)
	if (placed) then return true end
	
	placed = place_into_containers_in_range(who, what, INV_PACK, MAX_INV_SLOTS-1, nil, info_table)
	if (placed) then return true end
				
	return false
end

-- These functions are useful for determining an attack/injury location.
-- This one just generates one purely randomly.
function random_body_loc()
	return dsb_rand(INV_R_HAND, INV_FEET)
end

-- This one uses a zonetable, which is a construct similar to
-- what is stored (in a much more compact form) in CSBwin
-- monsters' word22, using the masks from ubyte590.
function zone_from_zonetable(zonetable)
	if (dsb_rand(0, 7) == 0) then
		if (dsb_rand(0, 1) == 0) then
			return INV_L_HAND
		else
			return INV_R_HAND
		end
	else
		local znum = dsb_rand(0, 15)
		if (znum < zonetable[1]) then
			return INV_FEET
		elseif (znum < zonetable[2]) then
			return INV_LEGS
		elseif (znum < zonetable[3]) then
			return INV_TORSO
		else
			return INV_HEAD
		end
	end
end
-- Define some nice symbolic names since the format is a little weird.
ZT_ATTACK_ANYWHERE = { 4, 8, 12 }
ZT_HEAD = {0, 1, 7}              
ZT_HEAD_OR_TORSO_HIGH = {0, 1, 9}
ZT_HEAD_OR_TORSO_LOW = { 0, 2, 9 }
ZT_TORSO = { 0, 3, 10 }
ZT_TORSO_LOWER = { 0, 3, 12 }
ZT_TORSO_MUMMY = { 0, 2, 11 }
ZT_TORSO_GHOST = { 0, 3, 11 }
ZT_TORSO_SCORPION = { 0, 4, 13 }
ZT_TORSO_ZYTAZ = { 0, 4, 12 }
ZT_TORSO_FEET_HITTABLE = {1, 4, 12}
ZT_LEGS = {0, 6, 13}
ZT_LEGS_OR_FEET_LOW = { 3, 9, 14 }
ZT_LEGS_OR_FEET_HIGH = { 3, 9, 13 }
ZT_FEET = { 5, 12, 15 }
ZT_FEET_RUSTER = {6, 13, 15}
ZT_FEET_OR_LEGS = {5, 9, 13 }

function fit_check(val, arch, id, who)
	local checkval = arch[val]
	if (type(checkval) == "function") then
		checkval = checkval(arch, id, who)
	end
	return checkval	
end

-- Search for ammo for some sort of shooting weapon
function valid_ammo(ammo, shooting, weapon) 
	if (shooting.missile_type) then
		if (not weapon or not weapon.need_ammo_type) then
		    return true
		elseif (shooting.missile_type == weapon.need_ammo_type) then
			return true
		end
	end
	return false			
end

function find_ammo_at_loc(who, ammoloc, weapon, throwing)
    local l_hand_obj = dsb_fetch(CHARACTER, who, ammoloc, 0)
    local ammo_obj = nil
    local ammo_obj_arch = nil
    local l_hand_arch = nil
        
	if (l_hand_obj) then
		l_hand_arch = dsb_find_arch(l_hand_obj)
		if (valid_ammo(l_hand_obj, l_hand_arch, weapon)) then
			ammo_obj = l_hand_obj
			ammo_obj_arch = l_hand_arch
		elseif (l_hand_arch.ammo_holder and (throwing or l_hand_arch.ammo_holder_hand)) then
			for iobj in dsb_in_obj(l_hand_obj) do
				local iarch = dsb_find_arch(iobj)
				if (valid_ammo(iobj, iarch, weapon)) then
					ammo_obj = iobj
					ammo_obj_arch = iarch
					break
				end
			end
		end
	end
	
	return ammo_obj, l_hand_obj, ammo_obj_arch, l_hand_arch
end


-- This function is used if a dungeon is imported from another format.
-- It will fix most of the strangenesses that crop up.
function dungeon_translate(champs_only)
	local special = { }
	for i in dsb_insts() do
	    local i_arch = dsb_find_arch(i)
		if (i_arch == obj.sconce_empty or i_arch == obj.sconce_full) then
			if (not champs_only) then
				special[i] = -2
			end
		elseif (i_arch.type == "WALLITEM" and i_arch.class == "CHAMPION_HOLDER") then
		    special[i] = exvar[i].champion
		elseif (exvar[i] and exvar[i].release) then
			if (not champs_only) then
				special[i] = -1
			end
		end
	end
	
	for i in pairs(special) do
	    local lev, xc, yc, face = dsb_get_coords(i)
	    local tileobj = dsb_fetch(lev, xc, yc, face)
	    local type = special[i]
	    if (tileobj) then
			if (type == -2) then
		    	local have_torch = false
		    	
		    	for n in pairs(tileobj) do
		    	    local o = tileobj[n]
		    	    local o_arch = dsb_find_arch(o)
		    	    if (o_arch.class == "TORCH") then
		    	        dsb_move(o, IN_OBJ, i, -1, 0)
		    	        have_torch = true
		    	        break
					end
		    	end
		    	if (have_torch) then 
					dsb_qswap(i, "sconce_full")
					if (not exvar[i]) then exvar[i] = { } end
					exvar[i].release = true
		    	else dsb_qswap(i, "sconce_empty") end
		    elseif (type == -1) then
		    	for n in pairs(tileobj) do
		    	    local o = tileobj[n]
		    	    local o_arch = dsb_find_arch(o)
		    	    if (o_arch.type == "THING") then
		    	    	dsb_move(o, IN_OBJ, i, -1, 0)
		    	    end
		    	end
				exvar[i].release = true
		    else
		        local pack_idx = INV_PACK
		        local have_head = false
		        local have_torso = false
		        local have_legs = false
		        local have_feet = false
		    	for n in pairs(tileobj) do
		    	    local o = tileobj[n]
		    	    local o_arch = dsb_find_arch(o)
		    	    if (o_arch.type == "THING") then
		    	        if (o_arch.fit_head and not have_head) then
		    	            dsb_move(o, CHARACTER, type, INV_HEAD, 0)
		    	            have_head = true
						elseif (o_arch.fit_torso and not have_torso) then
		    	            dsb_move(o, CHARACTER, type, INV_TORSO, 0)
		    	            have_torso = true
               		    elseif (o_arch.fit_legs and not have_legs) then
		    	            dsb_move(o, CHARACTER, type, INV_LEGS, 0)
		    	            have_legs = true
		    	        elseif (o_arch.fit_feet and not have_feet) then
		    	            dsb_move(o, CHARACTER, type, INV_FEET, 0)
		    	            have_feet = true
						else
							dsb_move(o, CHARACTER, type, pack_idx, 0)
							pack_idx = pack_idx + 1
						end
					end
				end
			end
		end
	end
end

-- Figure out if the character is overloaded, and whether the
-- level of overload is yellow or red.
function compute_load_level(l, ml)
	if (l >= ml) then
		return LOAD_RED
	else
		if (l * 8 > ml * 5) then
			return LOAD_YELLOW
		end
	end
	return LOAD_NONE
end

-- Useful for changing actuators
-- Mostly superseded by the qswapper arch
function swapmeaway(id, opby, towhat)
	dsb_qswap(id, towhat)
end

-- If a function is required but you just need a false value
function falsereturner()
	return false
end

-- Used as part of on_spawn, on_init, and so on
function msg_send(arch, id)
	if (arch.send_msg) then
		local delay = arch.send_msg[1]
		local message = arch.send_msg[2]
		local msgdata = arch.send_msg[3]
		local msgsender = arch.send_msg[4]	
		
		if (not delay) then delay = 0 end
		if (not msgdata) then msgdata = 0 end
		if (not msgsender) then msgsender = id end
		
		if (message) then
			dsb_msg(delay, id, message, msgdata, msgsender)
		end
	end
end

-- Create a clone of a basic arch and then apply changes
function clone_arch(base, changes)
	local new_arch = { }
	if (not base) then return nil end
	
	-- Just in case...!
	if (type(base) == "string") then base = obj[base] end
	
	for b in pairs(base) do
	    if (b == "regnum" or
			b == "regobj" or
			b == "ARCH_NAME")
		then
   			-- Don't copy internal stuff added by DSB
		else
	    	new_arch[b] = base[b]
		end
	end
	if (changes) then
		for c in pairs(changes) do
		    new_arch[c] = changes[c]
		end
	end
	return new_arch
end

-- Call a function after a delay
function delay_func_call(delay, func_name, func_param)
	if (type(func_name) == "string") then
		local caller = dsb_spawn("function_caller", LIMBO, 0, 0, 0)
		exvar[caller] = {
			m_a = "delay_func_call_invoker",
			func = func_name,
			param = func_param
		}
		dsb_msg(delay, caller, M_ACTIVATE, 0)
		dsb_msg(delay+1, caller, M_DESTROY, 0)
	else
		dsb_write(debug_color, "ERROR: DELAY_FUNC_CALL FUNCTION NAME MUST BE A STRING.")
	end 
end

function delay_func_call_invoker(id, lev, xc, yc, tile, data, sender)
	local call_func = dsb_lookup_global(exvar[id].func)	
	if (call_func and type(call_func) == "function") then
		call_func(unpack(exvar[id].param))
	end	
end