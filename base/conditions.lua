-- Conditions base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- These functions are used to set up the various "conditions"
-- that can change the status of characters. They are called
-- by the engine in response to setting the condition
-- variables for a character or the party.

function poison_func(who, str)

	if (dsb_char_ppos(who) == nil) then
	    return str
	end
	
	local po_dmg = math.floor(str/32)
	if (po_dmg < 1) then po_dmg = 1 end
	damage_char(who, HEALTH, po_dmg, true)
	
	if (str > 90) then
		str = str - 1
	end
	
	return(str-1)
end

function window_func(str)
	str = str - 8
	if (str <= 0) then
	    dsb_clear_gameflag(GAME_WINDOW)
		return 0
	else
	    return str
	end
end

function invisible_func(str)
	str = str - 5
	if (str <= 0) then
	    dsb_clear_gameflag(GAME_PARTY_INVIS)
		return 0
	else
	    return str
	end
end

function footprint_func(str)
	str = str - 8
	if (str <= 0) then

		for id in dsb_insts() do
			local arch = dsb_find_arch(id)
			if (arch.magic_footprint) then
			    dsb_delete(id)
			end
	    end
	    
	    g_footprint_counter = 0
	    
		return 0
	else
	    return str
	end
end

C_POISON = dsb_add_condition(INDIVIDUAL, gfx.poisoned,
			nil, 24, poison_func, COND_MOUTH_RED)
			
			
-- Moved into its own function to ease imposing limits, overriding, etc.
function set_poison(who, val)	
	if (val > max_poison_value) then 
		val = max_poison_value 
	elseif (val < 0) then
		val = 0
	end	
	dsb_set_condition(who, C_POISON, val)
end
max_poison_value = 319

function poison_character(targchar, poi_strength)	
	local char_poi = dsb_get_condition(targchar, C_POISON)
	if (not char_poi) then char_poi = 0 end
	
	-- Not used by the standard DM objects, but dungeon designers
	-- might want to create objects that grant poison resistance.
	local adj_poi_strength = poi_strength
	use_ch_exvar(targchar)
	if (ch_exvar[targchar].poison_resist) then
		local resist = ch_exvar[targchar].poison_resist
		if (resist >= 9999 or resist == true) then
			-- Immune to poison
			adj_poi_strength = 0
			return
		else
			if (resist < -99) then resist = -99 end
			adj_poi_strength = math.floor(poi_strength * 100 / (100 + resist)) 
		end
	end
	
	set_poison(targchar, adj_poi_strength + char_poi)
end
		
C_SHIELD = dsb_add_condition(INDIVIDUAL, nil, gfx.blueshield, 0, nil)
C_SPELLSHIELD = dsb_add_condition(INDIVIDUAL, nil, gfx.spellshield, 0, nil)
C_FIRESHIELD = dsb_add_condition(INDIVIDUAL, nil, gfx.fireshield, 0, nil)

C_WINDOW = dsb_add_condition(PARTY, nil, nil, 8, window_func)
C_FOOTPRINTS = dsb_add_condition(PARTY, nil, nil, 8, footprint_func)
C_INVISIBLE = dsb_add_condition(PARTY, nil, nil, 5, invisible_func)   

function handle_object_properties(direction, arch, id, who, slotname)
	local applicable_slot = false
	
	if ((slotname == "l_hand" or slotname == "r_hand") and 
		inventory_info.hand_classes[arch.class]) 
	then
		applicable_slot = true
	elseif (slotname == "head" and arch.fit_head) then
		applicable_slot = true
	elseif (slotname == "torso" and arch.fit_torso) then
		applicable_slot = true
	elseif (slotname == "legs" and arch.fit_legs) then
		applicable_slot = true
	elseif (slotname == "feet" and arch.fit_torso) then
		applicable_slot = true
	elseif (slotname == "neck" and arch.fit_neck) then
		applicable_slot = true
	end
	
	if (applicable_slot) then
		for c_iph in pairs(item_property_handlers) do
			if (arch[c_iph] or (exvar[id] and exvar[id][c_iph])) then
				local handler = item_property_handlers[c_iph]
				local hfunc = handler[direction]
				if (type(hfunc) == "string") then
					hfunc = dsb_lookup_global(hfunc)
				end
				hfunc(arch, id, who)
			end
		end
	end
end

item_property_handlers = {
	cursed = { to = "apply_curse", from = "remove_curse" }
}
