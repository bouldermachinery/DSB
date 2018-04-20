-- Experience handling functions base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- These functions are not called by the engine directly,
-- but they are used by objects and so you should be careful
-- about overriding them.

-- Influenced by CSBwin's AdjustSkills
function xp_up(who, skill, subskill, xp, multiplier)

	local gxp = math.floor(xp)
	if (gxp == 0) then
	    return
	end
	
	local old_mastery = dsb_xp_level_nobonus(who, skill, 0)
	local fast_advance = dsb_get_gameflag(GAME_FAST_ADVANCEMENT)
	
	if (not fast_advance) then 
		if (g_last_monster_attack > 150) then
			if (skill == CLASS_FIGHTER or skill == CLASS_NINJA) then
		    	gxp = math.floor(gxp / 2)
		    end
		end
	end
		
	local xp_m
	if (multiplier) then
		xp_m = multiplier
	else
		local chp = dsb_char_ppos(who)
	    if (chp) then
			local belong_party = dsb_party_contains(chp)
			local level = dsb_party_coords(belong_party)
			xp_m = dsb_get_xp_multiplier(level)
			if (xp_m == 0) then
				if (not dsb_get_gameflag(GAME_ZERO_EXP)) then
					xp_m = 1
				end
			end
		else
			xp_m = 1
		end
	end
	gxp = gxp * xp_m
	
	if (ch_exvar[who] and ch_exvar[who].forbid_class and
		ch_exvar[who].forbid_class[skill + 1]) 
	then	
		gxp = 0
	end
	
	if (gxp <= 0) then
	    return
	end
	
	if (subskill and (subskill > 0 and (fast_advance or g_last_monster_attack < 25))) then
	    gxp = gxp * 2
	end

	dsb_give_xp(who, skill, subskill, gxp)

	local txp = math.floor(gxp/8)
	if (txp < 1) then
	    txp = 1
	elseif (txp > 100) then
	    txp = 100
	end

	local ctxpv = dsb_get_temp_xp(who, skill, subskill) + txp
	if (ctxpv > 32000) then
	    ctxpv = 32000
	end
	dsb_set_temp_xp(who, skill, subskill, ctxpv)

	local new_mastery = dsb_xp_level_nobonus(who, skill, 0)

	-- Fixed so that just in case you (somehow?) gain more than
	-- one level at a time, they will all be given to you.
	while (new_mastery > old_mastery) do
		old_mastery = old_mastery + 1
		level_up(who, skill, old_mastery)
	end
end

function mark_highlight(who, type, what)
	local base = gt_highlight[who][type][what + 1]
	if (not base) then base = 0 end
	gt_highlight[who][type][what + 1] = base + 1
	dsb_delay_func(60, function()
	    if (gt_highlight[who][type][what + 1] > 1) then
	        gt_highlight[who][type][what + 1] =
				gt_highlight[who][type][what + 1] - 1
		else
	    	gt_highlight[who][type][what + 1] = nil
		end
	end)
end

function level_up(who, what, new_level)
	local whoname = dsb_get_charname(who)
	local cppos = dsb_char_ppos(who) + 1
	local major_up = dsb_rand(10, 20)
	local minor_up = dsb_rand(1, 10)
	local base_max_stamina = dsb_get_maxbar(who, STAMINA)
	local hp_up = (new_level + 1) * 10
	local vitality_up = dsb_rand(1, 5)
	local anti_magic_up = 0
	local anti_fire_up = dsb_rand(1, 5)
	local mana_up = 0
	local major_stat
	local minor_stat
	local stamina_up = 0
	local max_stat_up = dsb_get_gameflag(GAME_MAX_STAT_UP)
	
	if (max_stat_up) then
		major_up = 20
		minor_up = 10
		if ((new_level % 2) == 1) then
			anti_fire_up = 10
		else
			vitality_up = 10
		end
	end

	if (what == CLASS_FIGHTER) then
	    hp_up = hp_up * 3
	    stamina_up = base_max_stamina / 16
	    major_stat = STAT_STR
	    minor_stat = STAT_DEX
	elseif (what == CLASS_NINJA) then
	    hp_up = hp_up * 2
	    stamina_up = base_max_stamina / 21
	    major_stat = STAT_DEX
		minor_stat = STAT_STR
	elseif (what == CLASS_PRIEST) then
	    local rand_mana_up = dsb_rand(1, 30)
		if (max_stat_up) then rand_mana_up = 30 end
	    if (rand_mana_up > (new_level * 10)) then
	        rand_mana_up = new_level * 10
		end

		hp_up = hp_up + ((new_level + 1)/2) * 10
	    stamina_up = base_max_stamina / 25
		
		if (max_stat_up) then
			vitality_up = 10
			anti_magic_up = 20
		else
			vitality_up = dsb_rand(4, 10)
			anti_magic_up = dsb_rand(5, 25)
	    end
		
	    minor_stat = STAT_WIS
	    mana_up = ((new_level + 1) * 10) + rand_mana_up
	elseif (what == CLASS_WIZARD) then
	    local rand_mana_up = dsb_rand(1, 30)
		if (max_stat_up) then rand_mana_up = 30 end
	    if (rand_mana_up > (new_level * 10)) then
	        rand_mana_up = new_level * 10
		end

		stamina_up = base_max_stamina / 32
		if (max_stat_up) then
			anti_magic_up = 20
		else
			anti_magic_up = dsb_rand(5, 25)
		end
	    major_stat = STAT_WIS
	    mana_up = ((new_level + 1) * 15) + rand_mana_up
	end
	
	-- Prior to DSB 0.41, DSB's hp increases weren't as big as CSBwin's
	-- because I had mistakenly left out this random bonus.
	if (max_stat_up) then
		hp_up = hp_up + math.floor(hp_up / 2)
	else
		hp_up = hp_up + math.floor(dsb_rand(0, hp_up / 2))
	end
	
	local hp = dsb_get_maxbar(who, HEALTH) + hp_up
	dsb_set_maxbar(who, HEALTH, hp)
	local stamina = base_max_stamina + stamina_up
	dsb_set_maxbar(who, STAMINA, stamina)
	local mana = dsb_get_maxbar(who, MANA) + mana_up
	dsb_set_maxbar(who, MANA, mana)

	announce_level_up(cppos, whoname, what)
	    
	-- Mark the leveled up values for highlighting
	if (not gt_highlight) then gt_highlight = { } end
	if (not gt_highlight[who]) then
		gt_highlight[who] = {class = { }, stat = { } }
	end
	mark_highlight(who, "class", what)
	
	perform_stat_increase(who, major_stat, major_up)
	perform_stat_increase(who, minor_stat, minor_up)
	perform_stat_increase(who, STAT_VIT, vitality_up)
	perform_stat_increase(who, STAT_AMA, anti_magic_up)
	perform_stat_increase(who, STAT_AFI, anti_fire_up)

end

function announce_level_up(cppos, whoname, what)
	dsb_write(player_colors[cppos], whoname .. " JUST GAINED A " ..
	    xp_classnames[what+1] .. " LEVEL!")
end

function perform_stat_increase(who, stat_num, value_up)
	if (stat_num and value_up and value_up > 0) then
		stat = dsb_get_maxstat(who, stat_num)
		dsb_set_maxstat(who, stat_num, stat + value_up)
	    if (math.floor((stat + value_up) / 10) > math.floor(stat / 10)) then
	    	mark_highlight(who, "stat", stat_num)
		end
	end
end

-- For easier overriding
function determine_xp_level(char, class, subskill)
	return (dsb_xp_level(char, class, subskill))
end