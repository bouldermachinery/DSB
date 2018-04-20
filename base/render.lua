-- System rendering functions base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- If you want to override these functions, you should
-- do so in your own dungeon's startup.lua instead.

-- These are all called by the engine (or other system
-- functions) to render parts of the screen. You can
-- change the look and feel of the game by overriding
-- these functions, but you NEED these functions or the
-- game will lack a lot of functionality. (and be ugly, too)

base_background = {255, 0, 255}
base_text = {182, 182, 182}
highlight_text = { 0, 222, 0 }

shading_info = {
	WALLITEM = { front = {0, 56, 56}, pers = {0, 56, 72} },
	FLOORFLAT = { front = {0, 64, 64}, pers = {0, 64, 64} },
	FLOORUPRIGHT = { front = {0, 64, 64}, pers = {0, 64, 64} },
	MONSTER = { front = {0, 60, 60}, pers = {0, 60, 60} },	
	THING = { front = {0, 64, 64}, pers = {0, 64, 64} },	
	DOOR = { front = {0, 64, 56}, pers = {0, 64, 56} },
	CLOUD = { front = {0, 64, 64}, pers = {0, 64, 64} }	
}
-- Make metal keys more visible on the dungeon floor
metal_key_shade = { front = {0, 4, 48}, pers = {0, 4, 48} }

-- Draw the movement arrows
function sys_render_arrows(bmp, lit_up, frozen)
    dsb_bitmap_clear(bmp, {0, 0, 0} )

    dsb_bitmap_draw(gfx.move_arrows, bmp, 0, 4, false)
    if (frozen) then
        dsb_bitmap_rect(bmp, 0, 4, 173, 93, PATTERN_MODE, true)
        return
	end
	
	local la = 0
	local y = 0
    while (y < 90) do
        x = 0
        while (x < 120) do

			local siz
			if (la % 3 == 1) then siz = 56
            else siz = 58 end

			la = la + 1

            if (lit_up == la) then
            	dsb_bitmap_blit(gfx.move_activearrows, bmp,
					x, y, x, 4+y, siz, 46)
			end
			
            dsb_msgzone(bmp, SYSTEM, la, x, 4+y, siz, 46,
				SYS_MOVE_ARROW, la, 0)
			
			x = x + siz
		end
		y = y + 46
	end
end

-- Renders the menu for the chosen attack method
function sys_render_attack_method(bmp, frozen, ppos, slot, inst, num, names)
	dsb_bitmap_clear(bmp, {0, 0, 0} )
	
    dsb_bitmap_blit(gfx.choose_method, bmp, 0, 0, 10, 0,
		dsb_bitmap_width(gfx.choose_method), (num*24) + 18)

	local char = dsb_ppos_char(ppos)
	local char_name = dsb_get_charname(char)
	dsb_bitmap_textout(bmp, sys_font, char_name, 14, 4, LEFT, {0, 0, 0})
	
	local n_inst
	if (not inst) then n_inst = 0 else n_inst = inst end

	local i
    for i=1, num do
        dsb_bitmap_textout(bmp, sys_font, names[i],
			26, 24*i, LEFT, system_color)

		if (not frozen) then
			dsb_msgzone(bmp, SYSTEM, i, 10, 18 + 24*(i - 1), 170, 22,
			    SYS_METHOD_SEL, n_inst, i)
		end
	end

    if (frozen) then
        dsb_bitmap_rect(bmp, 0, 0,
			dsb_bitmap_width(bmp), dsb_bitmap_height(bmp), PATTERN_MODE, true)
	else
		if (dsb_get_gameflag(GAME_NO_METHOD_PASS)) then
			dsb_bitmap_rect(bmp, 100, 0, 100+84, 15, {0, 0, 0}, true)
		else
        	dsb_msgzone(bmp, SYSTEM, 0, 100, 0, 84, 16, SYS_METHOD_CLEAR, ppos, 0)
        end
	end
	
end

-- Renders the four icons to choose the party member
function sys_render_attack_options(bmp, frozen)
	dsb_bitmap_clear(bmp, {0, 0, 0} )
	local i
	for i=0,3 do
		local char = dsb_ppos_char(i)
		if (valid_and_alive(char)) then
		    dsb_bitmap_draw(gfx.actionbutton, bmp, 10+44*i, 18, false)
		    
		    local iobj = dsb_fetch(CHARACTER, char, INV_R_HAND, 0)
			local icon = nil
			if (iobj) then
			    local arch = dsb_find_arch(iobj)
			    if (arch.methods) then
				    if (arch.alt_icon and dsb_get_gfxflag(iobj, GF_ALT_ICON)) then
				    	icon = arch.alt_icon
					else icon = arch.icon end
					
					if (arch.rend_method_check) then
					    if (not arch.rend_method_check(iobj)) then
					        icon = nil
						end
					end
					
				end
			else
				icon = gfx.blank_attack
			end
			
			if (icon) then
				dsb_bitmap_draw(icon, bmp, 10+44*i + 4, 36, SHADOW_MODE)
			end

		    if (frozen or (dsb_get_idle(i) > 0)) then
				dsb_bitmap_rect(bmp, 10+44*i, 18, 10+44*i+39, 18+69, PATTERN_MODE, true)
			elseif (icon) then
		    	dsb_msgzone(bmp, SYSTEM, i, 10+44*i, 18, 40, 70,
					SYS_METHOD_OBJ, i, INV_R_HAND)
			end
		end
	end
end

-- Render damage burst graphic or whatever else happened
function sys_render_attack_result(bmp, frozen, message, damage_burst)
	local y_offset = 0
	dsb_bitmap_clear(bmp, {0, 0, 0})
	
	if (damage_burst) then
		local w = dsb_bitmap_width(gfx.monster_damaged)
		local h = dsb_bitmap_height(gfx.monster_damaged)
		local dmgval = message
		local dmgscale = dmgval + 18
		
		if (dmgscale < 40) then dmgscale = 40 end
        if (dmgval < 90 and dmgscale > 90) then dmgscale = 90 end       
        
        if (dmgscale >= 100) then
			dsb_bitmap_blit(gfx.monster_damaged, bmp, 0, 0, 0, 0, w, h)
		else			
			local hdmgscale = (dmgscale * 3) / 2
			if (hdmgscale > 100) then hdmgscale = 100 end
			
			local neww = math.floor(w * dmgscale / 100)
			local newh = math.floor(h * hdmgscale / 100)			
			local newx = math.floor((w - neww)/2)
            local newy = math.floor((h - newh)/2)
            			
			dsb_bitmap_blit(gfx.monster_damaged, bmp, 0, 0, newx, newy, w, h, neww, newh)
		end
		y_offset = 2
	end
	
	dsb_bitmap_textout(bmp, sys_font, message, 92, 38 + y_offset, CENTER, system_color)
	
	if (frozen) then
	    dsb_bitmap_rect(bmp, 0, 0, 185, 89, PATTERN_MODE, true)
	end	
end

-- Draw the magic spell casting interface
function sys_render_magic(bmp, sel_ppos, frozen, forbidden)
	local runes = { dsb_get_pendingspell(sel_ppos) }

	local locked = false
	if (frozen) then
	    locked = true
	end
	
	dsb_bitmap_clear(bmp, {0, 0, 0})
	dsb_bitmap_draw(gfx.magic, bmp, 0, 16, 0, 16, 174, 50, false)
	dsb_bitmap_draw(gfx.magic, bmp, 0, 0, (28*sel_ppos), 0, 90, 16, false)
	
	local c_name = dsb_get_charname(dsb_ppos_char(sel_ppos))
	dsb_bitmap_textout(bmp, sys_font, c_name, (28*sel_ppos)+4, 4,
        LEFT, magic_info.magic_system_colors[1])
        
	local tx = 0
    for i=0,3 do
        if (i == sel_ppos) then
            tx = tx + 66 + 28
		else
			local char = dsb_ppos_char(i)
	        if (valid_and_alive(char)) then
	            dsb_bitmap_blit(gfx.magic, bmp, 94, 0, tx, 0, 26, 16)
	            if (not locked) then
	                dsb_msgzone(bmp, SYSTEM, i, tx, 0, 26, 16,
	                    SYS_MAGIC_PPOS, i, 0)
				end
			end
			tx = tx + 28
		end
	end
        
	local max_set = 0
	local i
	for i=1,8 do
	    if (runes[i] > 0) then
			max_set = max_set + 1
			draw_rune(bmp, 16+(18*(i-1)), 48, runes[i],
				magic_info.magic_system_colors[4])
	    else break end
	end

	if (runes[1] > 0 and not locked) then
	    dsb_msgzone(bmp, SYSTEM, 4, 144, 42, 28, 22,
			SYS_MAGIC_BACK, sel_ppos, 0)
			
		dsb_msgzone(bmp, SYSTEM, 5, 2, 42, 140, 22,
			SYS_MAGIC_CAST, sel_ppos, 0)
	end

	max_set = max_set % magic_info.rune_sets
	local base_rune = (max_set * magic_info.runes_per_set) + 1
	for i=0,5 do
	    local rune_num = base_rune + i
	    
		local d_rune_num = rune_num
		if (gt_spell_flash) then
	        d_rune_num = d_rune_num - magic_info.runes_per_set
	        if (d_rune_num <= 0) then
	            d_rune_num = d_rune_num + (magic_info.runes_per_set * magic_info.rune_sets)
			end
		end
	    
	    if (gt_spell_flash == d_rune_num) then
	        dsb_bitmap_rect(bmp, 4+(28*i), 18, 29+(28*i), 39,
				magic_info.magic_system_colors[2], true)
	        draw_rune(bmp, 12+(28*i), 24, d_rune_num,
				magic_info.magic_system_colors[1])
			
			if (gt_spell_flash_half_over) then
				clear_spell_flash()
			else
				gt_spell_flash_half_over = true
			end
		else
			draw_rune(bmp, 12+(28*i), 24, d_rune_num)
		end
		
		if (not locked and not g_disabled_runes[rune_num]) then
		    dsb_msgzone(bmp, SYSTEM, 6+i, 4+(28*i), 18, 26, 22,
		        SYS_MAGIC_RUNE, sel_ppos, rune_num)
		end
	end
	
	if (frozen) then
	    dsb_bitmap_rect(bmp, 0, 0, 173, 69, PATTERN_MODE, true)
	end
end

-- Draws an individual spell rune. By default, this just
-- grabs characters out of a table, but if you want to display
-- your runes differently, you can override this function.
function draw_rune(bmp, x, y, rune_num, color)
	if (color == nil) then
		color = magic_info.magic_system_colors[3]
	 	if (g_disabled_runes[rune_num]) then
			color = magic_info.magic_system_colors[5]
		end
	end
	dsb_bitmap_textout(bmp, sys_font, magic_info.magic_runes[rune_num],
	    x, y, LEFT, color)
end

-- This function isn't even called unless w and h are defined for
-- gui_info.current_item. Normally, they are not defined and the
-- game just writes the current item name directly on the game screen.
-- Defining w and h, on the other hand, will call this code and make
-- current_item work like the other Lua renderers defined here.
function sys_render_current_item_text(bmp, item_name, frozen)
    dsb_bitmap_clear(bmp, { 0, 0, 0 } )
	dsb_bitmap_textout(bmp, sys_font, item_name, 0, 0, LEFT, system_color)
end

-- Render something else that is defined in gui_info.lua.
-- We don't know what it is, so it passes the name so we can figure out 
-- what to do with it. By default, this function isn't used.
-- The default code just clears it to bright green so it's obvious that
-- it is working... or not working, if you were expecting something else.
function sys_render_other(bmp, gui_name, frozen)
	dsb_bitmap_clear(bmp, { 0, 255, 0 } )
end

-- Determine the color to display load in.
-- Return nil for the default.
-- Invokes compute_load_level, found in base/util.lua.
function calc_loadcolor(l, ml)
	local load_level = compute_load_level(l, ml)
	if (load_level == LOAD_RED) then
		return { 255, 0, 0 }
	elseif (load_level == LOAD_YELLOW) then
		return { 255, 255, 0 }
	end
	return nil
end

-- Render the portraits, names, hands, and so on
-- It returns the location (x, y) to draw the completed image
-- (relative to the coordinates given by gui_info.portraits)
function sys_render_portraits_and_info(bmp, ppos, who, is_dead, in_inv, name_draw_type, portrait_name)
	
	-- Draw the hands
	if (not is_dead and not in_inv) then
		dsb_objzone(bmp, SYSTEM, inventory_info.top_row[ppos+1][1], 8, 20)		
		dsb_objzone(bmp, SYSTEM, inventory_info.top_row[ppos+1][2], 48, 20)		
		dsb_msgzone(bmp, SYSTEM, AUTOMATIC, 88, 0, 46, 58, SYS_OBJ_PUT_AWAY, ppos, 0)
	end
	
	-- Draw the bars
	if (not is_dead) then
		local bsize = 25
		local b
		for b=HEALTH,MANA do
			local v = dsb_get_bar(who, b)
			local maxv = dsb_get_maxbar(who, b)
			
			if (maxv < v) then maxv = v end
						
			if (v > 0) then
				local cut = (bsize - math.floor(bsize * (math.floor(v/10) / math.floor(maxv/10)))) * 2
				local dest_x = 92 + 14*b

				-- Always show at least a little something for health and stamina
				-- (or mana if we actually have a castable rune)
				if (b < MANA or (v >= 10)) then
					if (cut == (bsize*2)) then
						cut = cut - 2
					end
				end
				
				if (cut < (bsize*2)) then
					local rcolor = player_colors[ppos+1]
					if (not rcolor[1]) then
						-- This "color" is a bitmap with a pattern
						dsb_bitmap_draw(rcolor, bmp, 0, cut, dest_x, 4+cut, 8, ((bsize*2)-cut), false)
					else
						dsb_bitmap_rect(bmp, dest_x, 4+cut, dest_x + 7, 53, rcolor, true)
					end
				end
				 
			end
		end
	end
	
	-- Set leader
	if (in_inv) then
		dsb_msgzone(bmp, SYSTEM, AUTOMATIC, 0, 0, 86, 58, SYS_LEADER_SET, ppos, 0) 
	else
		dsb_msgzone(bmp, SYSTEM, AUTOMATIC, 0, 0, 86, 14, SYS_LEADER_SET, ppos, 0)
	end

	-- Write the character's name
	if (not in_inv) then
		dsb_bitmap_textout(bmp, sys_font,
			dsb_get_charname(who), 2, 2, LEFT, name_draw_colors[name_draw_type])
	end
	
	-- Draw the portrait
	if (in_inv) then
		local portname = dsb_get_portraitname(who)
		local portimg = gfx[portname]
		if (portimg) then
			dsb_bitmap_draw(portimg, bmp, 14, 0, false)
		end
	end

	return ppos * (dsb_bitmap_width(bmp) + 4), 0
end

-- Render the damage taken by a character
function sys_render_character_damage(bmp, ppos, who, is_dead, in_inv, damage_type, damage_val)
	local damage_image
	
	-- Graphics coordinates
	local xc = 0
	local yc = 0
	
	--Text coordinates
	local txc = 0
	local tyc = 0
	
	if (in_inv) then
		damage_image = gfx.damage_full
		xc = 14
		txc = 48
		tyc = 24
	else
		damage_image = gfx.damage_bar
		txc = 44
		tyc = 2
	end
	
	local dwidth = dsb_bitmap_width(damage_image)
	local dheight = math.floor(dsb_bitmap_height(damage_image) / 3)
	
	dsb_bitmap_draw(damage_image, bmp, 0, damage_type * dheight, xc, yc, dwidth, dheight, false)
	dsb_bitmap_textout(bmp, sys_font, damage_val, txc, tyc, CENTER, {255,255,255} )   
		
end

-- Render the health/stamina/mana, load, etc.
function sys_render_inventory_text(bmp, who, name_draw_type)
	
	dsb_bitmap_textout(bmp, sys_font,
		dsb_get_charname(who) .. " " .. dsb_get_chartitle(who),
		6, 6, LEFT, name_draw_colors[name_draw_type])

    for i=HEALTH,MANA do
        local bv = dsb_get_bar(who, i)
		local dbv = math.floor(bv/10)
        local mbv = dsb_get_maxbar(who, i)
    	local dmbv = math.floor(mbv/10)
        
        -- health + stamina have values of 1-9 displayed as 1
        -- mana has the value displayed as 0, so spellcasting doesn't seem odd
        if (i <= STAMINA) then
            if (bv > 0 and dbv == 0) then dbv = 1 end
            if (mbv > 0 and dmbv == 0) then dmbv = 1 end
        end
        
        dsb_bitmap_textout(bmp, sys_font, dbv, 146, 16*i+224, RIGHT, base_text)
        dsb_bitmap_textout(bmp, sys_font, dmbv, 194, 16*i+224, RIGHT, base_text)
        dsb_bitmap_textout(bmp, sys_font, "/", 146, 16*i+224, LEFT, base_text)
        dsb_bitmap_textout(bmp, sys_font, barnames[i+1], 10, 16*i+224, LEFT, base_text)
    end
    
    local load = dsb_get_load(who)
    local maxload = dsb_get_maxload(who)
    local load_color = calc_loadcolor(load, maxload)
    if (not load_color) then load_color = base_text end
    
    dsb_bitmap_textout(bmp, sys_font, "LOAD", 208, 256, LEFT, load_color)
    dsb_bitmap_textout(bmp, sys_font, ".", 332, 256, LEFT, load_color)
    dsb_bitmap_textout(bmp, sys_font, "/", 356, 256,LEFT, load_color)
    dsb_bitmap_textout(bmp, sys_font, "KG", 416, 256, LEFT, load_color)
    dsb_bitmap_textout(bmp, sys_font, math.floor(load / 10), 332, 256, RIGHT, load_color)
    dsb_bitmap_textout(bmp, sys_font, load % 10, 344, 256, LEFT, load_color)
    dsb_bitmap_textout(bmp, sys_font, math.floor(maxload / 10), 404, 256, RIGHT, load_color)

end

-- A subrenderer for the main inventory
function sys_render_mainsub(who)
	local sr = dsb_subrenderer_target()
	
	dsb_bitmap_clear(sr, base_background)
	dsb_bitmap_draw(gfx.inter_foodwater, sr, 6, 0, false)
	
	local baseval = dsb_get_food(who)
    local barlen = math.floor((192 * baseval) / 3072) - 1
   	local ccolor = adjust_bar(baseval, {148, 72, 0})
    dsb_bitmap_rect(sr, 28, 38, 30+barlen, 51, {0, 0, 0}, true)
	dsb_bitmap_rect(sr, 24, 34, 26+barlen, 47, ccolor, true)
        
    baseval = dsb_get_water(who)
    barlen = math.floor((192 * baseval) / 3072) - 1
    ccolor = adjust_bar(baseval, {0, 0, 255})
    dsb_bitmap_rect(sr, 28, 84, 30+barlen, 97, {0, 0, 0}, true)
	dsb_bitmap_rect(sr, 24, 80, 26+barlen, 93, ccolor, true)
end

-- Utility function for coloring the bar
function adjust_bar(val, default)
	local rv
	
    if (val < 512) then
        rv = {255, 0, 0}  
    elseif (val < 1024) then
        rv = {255, 255, 0}
    else
    	rv = default
    end

    return rv 	
end

-- Default subrenderer when an object under examination doesn't
-- have its own subrenderer
function sys_render_object(who, id, name)
	local sr = dsb_subrenderer_target()
	local arch = dsb_find_arch(id)
	local y = 62

	dsb_bitmap_clear(sr, base_background)
	dsb_bitmap_draw(gfx.inter_objlook, sr, 6, 0, false)
	
	if (dsb_get_gfxflag(id, GF_ALT_ICON) and arch.alt_icon) then
		dsb_bitmap_draw(arch.alt_icon, sr, 20, 14, false)
	else
		dsb_bitmap_draw(arch.icon, sr, 20, 14, false)
	end
	
	dsb_bitmap_textout(sr, sys_font, name, 66, 24, LEFT, base_text);
	
	local shortdesc = nil
	if (exvar[id] and exvar[id].shortdesc) then
	    shortdesc = exvar[id].shortdesc
	elseif (arch.shortdesc) then
	    shortdesc = arch.shortdesc
	end
	if (shortdesc) then
		local sdesc
		if (type(shortdesc) == "function") then
			sdesc = shortdesc(arch, id, who)
		else
			sdesc = shortdesc
		end
		
		if (sdesc) then
	    	dsb_bitmap_textout(sr, sys_font, "(" .. sdesc .. ")",
	        	14, 62, LEFT, base_text)
			y = y + 14
		end
	end
	
	local mass_l = math.floor(arch.mass / 10)
	local mass_r = arch.mass % 10
	dsb_bitmap_textout(sr, sys_font,
		"WEIGHS " .. mass_l .. "." .. mass_r .. " KG.",
		14, y, LEFT, base_text)
		
	local longdesc = nil
	if (exvar[id] and exvar[id].text) then
	    longdesc = exvar[id].text
	elseif (arch.text) then
	    longdesc = arch.text
	end
	if (longdesc) then
		local ldesc
		if (type(longdesc) == "function") then
			ldesc = longdesc(arch, id, who)
		else
			ldesc = longdesc
		end
		
		if (ldesc) then
			dsb_textformat(18, 14, 4)
	    	dsb_bitmap_textout(sr, sys_font, ldesc, 14, 90,
				MULTILINE, base_text)
		end
	end
	
end

-- A subrenderer for the "eye" stats view
function sys_render_stats(who)
	local sr = dsb_subrenderer_target()
	
	dsb_bitmap_clear(sr, base_background)
	dsb_bitmap_draw(gfx.inter_blank, sr, 6, 0, false)

	local i
	local classes = 0
	local y = 0
	
	for i=0,xp_classes - 1 do
		local level = dsb_xp_level(who, i, 0)
		local text_color = base_text
		
		if (gt_highlight and gt_highlight[who]) then
		    if (gt_highlight[who].class[i + 1]) then
		        text_color = highlight_text
			end
		end
		
		if (level > 0) then		
	    	dsb_bitmap_textout(sr, sys_font, 
				xp_levelnames[level] .. " " .. xp_classnames[i + 1],
				14, y + 4, LEFT, text_color)
			
			y = y + 14
			classes = classes + 1
			if (classes == 4) then break end		
		end		
	end
	
	y = 60
	for i=0,5 do
	    local real_stat = dsb_get_stat(who, i)
	    local real_maxstat = dsb_get_maxstat(who, i)
		local stat = math.floor(real_stat / 10)
		local maxstat = math.floor(real_maxstat / 10)
		local text_name_color = base_text
		
		if (gt_highlight and gt_highlight[who]) then
		    if (gt_highlight[who].stat[i + 1]) then
		        text_name_color = highlight_text
			end
		end
		
		dsb_bitmap_textout(sr, sys_font,
			statnames[i + 1], 14, y, LEFT, text_name_color)
			
		local stat_color = base_text
		if (stat > maxstat) then stat_color = {0, 222, 0}
		elseif (stat < maxstat) then stat_color = {255, 0, 0} end	
		dsb_bitmap_textout(sr, sys_font, stat, 182, y, RIGHT, stat_color)
			
		dsb_bitmap_textout(sr, sys_font, "/", 182, y, LEFT, base_text)
		
		dsb_bitmap_textout(sr, sys_font, maxstat, 230, y, RIGHT, base_text)	
			
		y = y + 14
	end
end

-- These functions are used to draw and animate the front door.
-- It is all initially invoked from sys_game_start (in base/system.lua)

function front_door_draw(bmp, mx, my)
	dsb_bitmap_draw(gfx.frontdoor_bkg, bmp, 0, 20, false)
	
	if (gt_door_opening) then
	    local plev, px, py, pdir = dsb_party_coords()
	    if (plev >= 0) then
	    	local xs, ys, light = dsb_level_getinfo(plev)
			local view = dsb_dungeon_view(plev, px, py, pdir, light)
	    	dsb_bitmap_draw(view, bmp, 0, 86, false)
	    end
	end
		
	local lw = dsb_bitmap_width(gfx.frontdoor_left)
	local rw = dsb_bitmap_width(gfx.frontdoor_right)
	local lh = dsb_bitmap_height(gfx.frontdoor_left)
	local rh = dsb_bitmap_height(gfx.frontdoor_right)
	local loff = (lw * gt_doorstate) / 96
	local roff = (rw * gt_doorstate) / 96
	
	dsb_bitmap_draw(gfx.frontdoor_left, bmp, loff, 0, 0, 86, lw - loff, lh, false)
	dsb_bitmap_draw(gfx.frontdoor_right, bmp, 0, 0, 210+roff, 86, rw - roff, rh, false)

	if (gt_doorstate > 0) then
	    if (gt_doorstate == 0.1) then gt_doorstate = 0.0 end
	    gt_doorstate = gt_doorstate + 1
	    if (gt_doorstate % 16 == 1) then
			dsb_sound(snd.doorclank)
		end
	    if (gt_doorstate >= 96) then
	        return 0
		end
	end

	return nil
end

function front_door_click(x, y, b)
	if (b == 1) then
	    if (x > 488 and x < 512) then
	        if (y > 114 and y < 138) then
	        	dsb_sound(snd.click)
				gt_doorstate = 0.1
				return 999
			end

	        if (y > 178 and y < 202) then
	            if (gt_savegames > 0) then
	                dsb_sound(snd.click)
	                return 1
				end
			end

	        if (y > 242 and y < 266) then
				return 2
			end
		end
	end
	return nil
end

function front_door(savegames)
	gt_doorstate = 0
	gt_savegames = savegames
	local v = dsb_fullscreen(front_door_draw, front_door_click, nil, true)
	if (v == 999) then
	    gt_door_opening = true
	    return (dsb_fullscreen(front_door_draw, nil, nil, false))
	else
		return v
	end
end

-- A function for deciding what part of wall writing to display
-- and masking off the parts that aren't needed
function wallwriting_alter(self, id, bitmap, w, h, sideview)
	local ppink = {255, 0, 255}
	
	if (not exvar[id] or not exvar[id].text) then return 0, 0 end

	local linedims
	if (sideview) then
		linedims = { 
			{ 0.375, 0.042, 0.6875, 0.208 },
			{ 0.375, 0.223, 0.6875, 0.4375 },
			{ 0.375, 0.479, 0.6875, 0.6667 },
			{ 0.375, 0.6875, 0.6875, 0.875 }
		}
	else
		linedims = { 
			{ 0.125, 0.0071, 0.8854, 0.25 },
			{ 0.125, 0.2678, 0.8854, 0.4286 },
			{ 0.125, 0.5714, 0.8854, 0.7321 },
			{ 0.125, 0.75, 0.8854, 0.9286 }
		}
	end
	
	local nx, ny, nw, nh
	local lines, num_lines = dsb_linesplit(exvar[id].text, "/")
	
	for i=1,4 do
		local lx1 = math.floor(linedims[i][1] * w + 0.5)
		local ly1 = math.floor(linedims[i][2] * h + 0.5)
		local lx2 = math.floor(linedims[i][3] * w + 0.5)
		local ly2 = math.floor(linedims[i][4] * h + 0.5)
		local charwidth = (lx2 - lx1) / 10
		
		if (i > num_lines or lines[i] == "") then
			dsb_bitmap_rect(bitmap, lx1, ly1, lx2, ly2, ppink, true)
		else
			local nchars = string.len(lines[i])
			
			-- It's squished. We always have to show SOMETHING.
			if (sideview and nchars < 4) then nchars = 4 end
			
			if (nchars < 10) then
				local s_x, f_x
				s_x = lx1 + ((10 - nchars) * charwidth / 2) 
				f_x = lx2 - ((10 - nchars) * charwidth / 2) 
				dsb_bitmap_rect(bitmap, lx1, ly1, s_x, ly2, ppink, true)
				dsb_bitmap_rect(bitmap, f_x, ly1, lx2, ly2, ppink, true)
			end
		end
	end
		
	return 0, 0
end

-- A helper function for fullscreen renderers
function EXIT_ON_CLICK(x, y, b)
	return true
end


