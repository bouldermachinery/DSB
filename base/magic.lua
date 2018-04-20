-- Magic spells base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- This table and the data therein are used sys_spell_cast.
-- If you want to add or replace spells, you should modify
-- the spell table in your own dungeon's startup.lua. You
-- could also replace sys_spell_cast directly, but then
-- you will have to control the entire magic system
-- yourself.

magic_info = {
	magic_system_colors = {
		{0, 0, 0},       -- character name
		{255, 255, 255}, -- flash background
		{0, 222, 222},   -- active rune
		{0, 222, 222},   -- spell in progress
		{0, 64, 64}      -- disabled rune
	},

	runes_per_set = 6,
	rune_sets = 4,
	magic_runes = {
		"a", "b", "c", "d", "e", "f",
		"g", "h", "i", "j", "k", "l",
		"m", "n", "o", "p", "q", "r",
		"s", "t", "u", "v", "w", "x"
	},

	power_multipliers = { 1.0, 1.5, 2.0, 2.5, 3.0, 3.5 },

	rune_costs = {
		10, 20, 30, 40, 50, 60,
		20, 30, 40, 50, 60, 70,
		40, 50, 60, 70, 70, 90,
		20, 20, 30, 40, 60, 70
	}
}

function unimplemented_spell(atype, ppos, who, power, skill, delay)
	dsb_write(system_color, "THIS SPELL IS CURRENTLY NOT IMPLEMENTED IN DSB.")
end

function magic_missile_power(skill, power)
	local m_power = (2*skill+4)*(power+2)
	if (m_power < 21) then
	    m_power = 21
	elseif (m_power > 255) then
	    m_power = 255
	end
	return m_power
end

function throw_magic_missile(atype, ppos, who, power, skill, delay)
	local m_power = magic_missile_power(skill, power)

	local lev, xc, yc, dir = dsb_party_coords()
	dsb_set_pfacing(ppos, 0)
	local tilepos = dsb_ppos_tile(ppos)
	local side = 1
	if (tilepos == dir or (tilepos+1)%4 == dir) then
	    side = 0
	end
	local start_pos = (dir + side) % 4

	-- DM used a flat value of 90 and then ignored it.
	-- We'll just set them to be the same, and use both in
	-- the formula. This makes tweaks easier later.
	local damage = m_power
	
	local d = dsb_get_maxbar(who, MANA) / 8
	if (d > 8) then d = 8 end
	local delta = 10 - d
	if (m_power < 4*delta) then
	    m_power = m_power + 3
	    delta = delta - 1
	end

	local missile_id = dsb_spawn(atype.missile, LIMBO, 0, 0, 0)
	dsb_set_openshot(missile_id, dir)
	dsb_shoot(missile_id, lev, xc, yc, dir, start_pos, m_power, damage, delta)
	
	-- The spell might set a different flyreps value
	if (atype.flyreps) then
	    dsb_set_flyreps(missile_id, atype.flyreps)
	end
	
	return false, missile_id
end

function find_arch_in_hand(who, archname, failmsg)
	local look = dsb_fetch(CHARACTER, who, INV_L_HAND, 0)
	if (not look or dsb_find_arch(look) ~= obj[archname]) then
		look = dsb_fetch(CHARACTER, who, INV_R_HAND, 0)
		if (not look or dsb_find_arch(look) ~= obj[archname]) then
			if (failmsg) then
				if (type(failmsg) == "function") then
					failmsg(dsb_get_charname(who), archname)
				else
					dsb_write(system_color, failmsg)
				end
			end
			return nil
		end
	end	
	return look
end
                                               
function create_potion(atype, ppos, who, pow, skill, delay)
	local flask = find_arch_in_hand(who, "flask", needs_an_empty_flask)
	
	if (flask) then
		dsb_swap(flask, atype.potion)
		exvar[flask] = { power = pow }
	else
		return true
	end
	
	return false, flask
end

function create_object(atype, ppos, who, pow, skill, delay)
	local item_id
	if (dsb_fetch(CHARACTER, who, INV_L_HAND, 0)) then
	    if (dsb_fetch(CHARACTER, who, INV_R_HAND, 0)) then
			local lev, xc, yc, dir = dsb_party_coords()
			item_id = dsb_spawn(atype.object, lev, xc, yc, dir)
		else
			item_id = dsb_spawn(atype.object, CHARACTER, who, INV_R_HAND, 0)
		end
	else
		item_id = dsb_spawn(atype.object, CHARACTER, who, INV_L_HAND, 0)
	end 
	exvar[item_id] = { power = pow }
	
	return false, item_id
end

function see_thru_walls(atype, ppos, who, power, skill, delay)
	local duration = ((4*power)+1)/2
	duration = duration * duration

	local cpower = dsb_get_condition(PARTY, C_WINDOW)
	if (not cpower) then cpower = duration
	else
		cpower = cpower + duration
	end
	
	dsb_set_condition(PARTY, C_WINDOW, cpower)
	dsb_set_gameflag(GAME_WINDOW)
	
end

function magic_footprints(atype, ppos, who, power, skill, delay)
	local duration = ((4*power)+1)
	duration = duration * duration
	local cpower = dsb_get_condition(PARTY, C_FOOTPRINTS)
	if (not cpower) then cpower = duration
	else
		cpower = cpower + duration
	end
	dsb_set_condition(PARTY, C_FOOTPRINTS, cpower)
end

function party_invisible(atype, ppos, who, power, skill, delay)
	local duration = ((6*power)+2)
	local cpower = dsb_get_condition(PARTY, C_INVISIBLE)
	if (not cpower) then cpower = duration
	else
		cpower = cpower + duration
	end
	dsb_set_condition(PARTY, C_INVISIBLE, cpower)
	dsb_set_gameflag(GAME_PARTY_INVIS)
end

function magic_light(brightness, delta, fade_time)
	local lc = dsb_spawn("light_controller", LIMBO, 0, 0, 0)
	dsb_set_light("magic", dsb_get_light("magic") + brightness)
	exvar[lc] = { light=brightness }
	dsb_msg(fade_time, lc, M_NEXTTICK, delta)
end

function weak_light(atype, ppos, who, power, skill, delay)
	local fade_power = 4*(power+1)
	local fade_time = 4000 + 128 * (fade_power-3)
	local brightness = 6*(power+2)	
	magic_light(brightness, power+2, fade_time)
end	

function strong_light(atype, ppos, who, power, skill, delay)
	local my_power = (2*(power+1)) - 1
	local fade_time = 10000 + 512*(4*(power+1) - 8)
	local brightness = 6*(my_power)
	magic_light(brightness, my_power, fade_time)
end

function darkness(atype, ppos, who, power, skill, delay)
	local my_power = power+1
	magic_light(-6*my_power, my_power, (32*power)+3)
end

function cast_shield(atype, ppos, who, power, skill, delay)
	local n_ppos
	for n_ppos=0,3 do
		local char = dsb_ppos_char(n_ppos)
		if (valid_and_alive(char)) then
			local sh_power = 4*power + 1
			magic_shield(char, atype.shield_type, sh_power,
				 sh_power * sh_power + atype.time_bonus)
		end
	end
end

function magic_shield(who, stype, sh_power, timer_time)	
	local cur_shield = dsb_get_condition(who, stype)
	if (not cur_shield) then cur_shield = 0 end
	
	-- DM/CSB had the power of new shields power drop to 25%
	-- if the current power was 50, otherwise it'd leave them alone.
	-- This makes a smoother curve.
	if (cur_shield > 25) then
	    local div = cur_shield / 25
		local adj_shield = sh_power / div
		if (adj_shield < sh_power) then
		    sh_power = adj_shield
		end
	end
	sh_power = math.floor(sh_power + 0.5)
	if (sh_power < 1) then sh_power = 1 end
    dsb_set_condition(who, stype, cur_shield + sh_power)
	
	local controller = dsb_spawn("shield_controller", LIMBO, 0, 0, 0)
	exvar[controller] = { type = stype, owner = who, power = sh_power }
	dsb_msg(timer_time, controller, M_DESTROY, 0)
end

function mumbles_meaningless_spell(namewho)
	dsb_write(system_color, namewho .. " MUMBLES A MEANINGLESS SPELL.")
end

function needs_an_empty_flask(namewho, needarch)
	dsb_write(system_color, namewho .. " NEEDS AN EMPTY FLASK IN HAND FOR POTION.")
end

function needs_more_practice_with_spell(namewho, sr)
	dsb_write(system_color, namewho ..
		" NEEDS MORE PRACTICE WITH THIS "
	    .. xp_classnames[spell[sr].class + 1] .. " SPELL.")
end

-- Utility function to clear the flashed rune
function clear_spell_flash()
	gt_spell_flash = nil
	gt_spell_flash_half_over = nil
end

spell = {
	[1] = {
		class = CLASS_PRIEST,
		subskill = SKILL_POTIONS,
		difficulty = 2,
		idleness = 15,
		potion = "flask_mon",
		cast = create_potion
	},
	
	[14] = {
		class = CLASS_PRIEST,
		subskill = SKILL_SHIELDS,
		difficulty = 2,
		idleness = 30,
		shield_type = C_SHIELD,
		time_bonus = 0,
		cast = cast_shield
	},

    [15] = {
		class = CLASS_PRIEST,
		subskill = SKILL_POTIONS,
		difficulty = 2,
		idleness = 25,
		potion = "flask_ya",
		cast = create_potion
	},
	
	[152] = {
	    class = CLASS_WIZARD,
	    subskill = SKILL_DES,
	    difficulty = 1,
		idleness = 18,
		cast = magic_footprints
	},
    
	[153] = {
		class = CLASS_PRIEST,
		subskill = SKILL_POTIONS,
		difficulty = 4,
		idleness = 15,
		potion = "flask_dane",
		cast = create_potion
	},
	
	[154] = {
		class = CLASS_PRIEST,
		subskill = SKILL_POTIONS,
		difficulty = 4,
		idleness = 15,
		potion = "flask_neta",
		cast = create_potion
	},
		
	[2] = {
		class = CLASS_PRIEST,
		subskill = SKILL_POTIONS,
		difficulty = 1,
		idleness = 32,
		potion = "flask_vi",
		cast = create_potion
	},
	
	[25] = {
		class = CLASS_PRIEST,
		subskill = SKILL_POTIONS,
		difficulty = 1,
		idleness = 26,
		potion = "flask_bro",
		cast = create_potion
	},
			
	[31] = {
		class = CLASS_WIZARD,
		subskill = SKILL_POISON,
		difficulty = 3,
		idleness = 27,
		missile = "poison_ohven",
		cast = throw_magic_missile
	},
	
	[325] = {
	    class = CLASS_WIZARD,
	    subskill = SKILL_DES,
	    difficulty = 3,
		idleness = 33,
		cast = see_thru_walls
	},
	
	[326] = {
		class = CLASS_WIZARD,
		subskill = SKILL_AIR,
		difficulty = 3,
		idleness = 45,
		cast = party_invisible
	},
	
	[335] = {
		class = CLASS_WIZARD,
		subskill = SKILL_AIR,
		difficulty = 4,
		idleness = 30,
		missile = "lightning",
		cast = throw_magic_missile
	},
	
	[345] = {
		class = CLASS_WIZARD,
		subskill = SKILL_AIR,
		difficulty = 4,
		idleness = 22,   
		cast = strong_light
	},
	
	[352] = {
		class = CLASS_PRIEST,
		subskill = SKILL_POTIONS,
		difficulty = 4,
		idleness = 15,
		potion = "flask_ros",
		cast = create_potion
	},	
	
	[4] = {
		class = CLASS_WIZARD,
		subskill = SKILL_FIRE,
		difficulty = 1,
		idleness = 15,
		cast = weak_light
	},	
	
	[44] = {
	    class = CLASS_WIZARD,
	    subskill = SKILL_FIRE,
		difficulty = 3,
		idleness = 42,
		missile = "fireball",
		cast = throw_magic_missile
	},
	
	[451] = {
		class = CLASS_PRIEST,
		subskill = SKILL_POTIONS,
		difficulty = 4,
		idleness = 15,
		potion = "flask_ku",
		cast = create_potion
	},
	
	[454] = {
	    class = CLASS_PRIEST,
	    subskill = SKILL_SHIELDS,
	    difficulty = 4,
	    idleness = 28,
	    shield_type = C_FIRESHIELD,
	    time_bonus = 100,
	    cast = cast_shield
	},
	
	[51] = {
		class = CLASS_WIZARD,
		subskill = SKILL_POISON,
		difficulty = 1,
		idleness = 16,
		missile = "poison_desven",
		cast = throw_magic_missile
	},
	
	[52] = {
	    class = CLASS_WIZARD,
	    subskill = SKILL_DES,
		difficulty = 1,
		idleness = 20,
		missile = "desewspell",
		cast = throw_magic_missile
	},
		
	[546] = {
		class = CLASS_PRIEST,
		subskill = SKILL_SHIELDS,
		difficulty = 1,
		idleness = 12,
		cast = darkness,
	},		
	
	[6] = {
	    class = CLASS_WIZARD,
	    subskill = SKILL_AIR,
	    difficulty = 1,
	    idleness = 15,
	    missile = "zospell",
	    cast = throw_magic_missile
	},
	
	[61] = {
		class = CLASS_WIZARD,
		subskill = SKILL_POISON,
		difficulty = 0,
		idleness = 1,
		cast = unimplemented_spell
	},
	
	[635] = {
		class = CLASS_WIZARD,
		subskill = 0,
		difficulty = 0,
		idleness = 15,
		object = "zokathra",
		cast = create_object
	},
	
	[655] = {
		class = CLASS_PRIEST,
		subskill = 0,
		difficulty = 3,
		idleness = 63,
		potion = "flask_ee",
		cast = create_potion
	}
}
	