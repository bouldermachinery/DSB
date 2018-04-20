-- Game hooks base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- If you want to override these functions, you should
-- do so in your own dungeon's startup.lua (or one of
-- the files loaded in your lua_manifest) instead.

-- These are all called by various complicated pieces of
-- base code at various times. They exist to allow for
-- customizability of various events without having to
-- override and rewrite some very large, complex functions.



-- This function is called by sys_update on each character
-- after it finishes doing the base update, to do any
-- updates a custom dungeon might need. 
function h_char_update(who, clock_tick)
end 

-- This function is called by do_damage when a character
-- is damaged by anything. It returns the damage type and
-- amount, in case you want to modify them for some reason.
function h_char_take_damage(ppos, who, dmg_type, amount, passive)
	return dmg_type, amount
end 

-- This function is called by sys_tick on each character.
function h_party_char_tick(ppos, who, tick_clock)
end 

-- This is a replacement for the door_hit_char function
-- and has the same functionality. If you wrote a custom
-- version of that function, simply rename it and it will
-- work the same as before.
function h_door_hits_char(ppos, who)
	do_damage(ppos, who, HEALTH, dsb_rand(4, 8))
	if (dsb_rand(0, 4) == 0) then
		cause_injury(who, INV_HEAD, 20)
	end
end

-- This is a replacement for the monster_got_doored function
-- and has the same functionality. If you wrote a custom
-- version of that function, simply rename it and it will
-- work the same as before.
function h_door_hits_monster(mon, mon_arch, door)

	local dmg = (60 * dsb_rand(3, 6))
	dmg = dmg / mon_arch.armor

	local maxd = dsb_get_maxhp(mon)/7
	if (dmg > maxd) then
		dmg = maxd
		if (dmg < 3) then dmg = 3 end
	end

	dsb_ai(mon, AI_HAZARD, dmg)
	if (mon_arch.armor < 800) then
	    dmg = monster_damaged(false, dmg, "armor", mon, door,
			mon_arch, dsb_find_arch(door), nil)
		if (dmg) then
			dsb_set_hp(mon, dsb_get_hp(mon) - dmg)
		end
	end
end

-- Called after Lord Chaos is successfully fused
-- chaos_id will have been swapped to a greylord instead.
function h_fused_chaos(chaos_id)
end

-- Called when a party member makes a melee attack to see if the attack can hit.
-- By default, just return what the base code already figured out.
function h_nonmaterial_check(type_ok, who, monster_id, weapon_arch)
	return type_ok
end

-- Called when a party member makes a melee attack to see if they hit.
-- By default, just return what the base code already figured out.
function h_hit_calculation(hit, who, monster_id, quickness, req_quickness, weapon_arch)
	return hit
end

-- This function is blank for now. You can override
-- it if you want it to do something interesting.
function h_monster_died(monster_id)
	return nil
end

-- This function takes the coordinates of the pit, and returns
-- the damage done as well as the new coordinates.
function h_monster_falls_down(lev, x, y, face)
	return 20, lev+1, x, y, face
end

-- This function is blank for now. You can override
-- it if you want it to do something, though, like
-- play an impact noise when a monster gets smacked
-- by a weapon, or something else special. If it returns
-- a value, that value is used for the damage instead of
-- the one passed in.
function h_monster_took_damage(melee, howmuch, dmg_type, mon, wep, mon_arch, wep_arch, who)
	return nil
end

-- This function takes the coordinates of the pit, and returns
-- the damage done as well as the new coordinates.
-- For now the party and monsters are handled the same, but
-- they don't have to be.
function h_party_falls_down(lev, x, y, face)
	return 20, lev+1, x, y, face
end

-- This function takes whether or not there are party members
-- (or it is just the "ghost") and the current move delay, and
-- returns the new move delay. By default, return the delay
-- that the base code already figured out.
function h_party_move(have_party, delay)
	return delay
end

