--- objects.lua ---
-- This is an example of some new objects that might be
-- useful in the creation of custom dungeons

-- Importable archetypes, contained in their own files.
-- They are self-contained, and as long as you've also copied
-- any bitmaps they need, you need only this one line and their
-- Lua source file to use them in your custom dungeons. Feel
-- free to use any of these importable archetypes in your own
-- creations.
dsb_import_arch("moneybox.lua", "moneybox")
dsb_import_arch("quiver.lua", "quiver")
dsb_import_arch("doublealcoves.lua", "alcove_short")
dsb_import_arch("throwtrolin.lua", "throwtrolin")
dsb_import_arch("multivexirk.lua", "multivexirk")
dsb_import_arch("ruster.lua", "rusting_ruster")
dsb_import_arch("poisondart.lua", "dart_poison")
dsb_import_arch("monstercapture.lua", "monster_capturer")
dsb_import_arch("psychic_demon.lua", "psychic_demon")
dsb_import_arch("dm2table.lua", "dm2table")

-- The crazy axe flies around randomly if you throw it, using an
-- overridden on_fly that changes the direction that it is facing.
obj.crazy_axe = clone_arch(obj.axe, {
	name = "CRAZY AXE",
	text = "YOU DON'T KNOW WHAT MIGHT HAPPEN IF YOU THROW IT!"
} )
function obj.crazy_axe:on_fly(id, x, y, tile, face, flytimer)
	if (dsb_rand(0, 2) == 0) then
		face = dsb_rand(0, 3)
	end

	return x, y, tile, face, flytimer
end

-- The skillscroll will display your wizard skill in all four
-- hidden skills, using a subrenderer. It is similar to a normal
-- scroll, but a bit more complicated.
obj.skillscroll = clone_arch(obj.scroll)
function obj.skillscroll:subrenderer(id)
	local ch, who = dsb_get_coords(id)
	if (ch == MOUSE_HAND) then
		who = dsb_ppos_char(dsb_current_inventory())
	end
	
	local names = { "FUL", "IR", "DES", "VEN" }
	local lines = { "SCROLL OF", "WIZARDRY", "" }
	for i=1,4 do
		local skillnum = dsb_xp_level(who, CLASS_WIZARD, i)
		local s_skill
		if (skillnum == 0) then
			s_skill = "NO SKILL IN " .. names[i]
		else
			s_skill = names[i] .. " " .. xp_levelnames[skillnum] 
		end
		
		lines[3+i] = s_skill
	end
	local num_lines = 7
	
	local y_base = 72 - (num_lines*7) + (num_lines % 2)	
    local sr = dsb_subrenderer_target()
	dsb_bitmap_draw(gfx.scroll_inside, sr, 0, 0, false)
	for i=1,num_lines do
	    dsb_bitmap_textout(sr, gfx.scroll_font, lines[i],
			124, y_base+((i-1)*14), CENTER, scroll_color)
	end	
end

-- This apple will send messages to its target list when eaten, causing
-- interesting things to happen.
obj.trigger_apple = clone_arch(obj.apple, {
	-- Inform ESB to allow this object to designate targets
	esb_take_targets = true,
	-- Inform ESB that this object never makes an activation sound
	esb_always_silent = true
} )
function obj.trigger_apple:on_consume(id, who)
	-- If some targets are defined, send messages to them.
	-- "id" is given twice because we send this instance as the
	-- opby as well, as that is really what makes the most sense. 
	if (exvar[id] and exvar[id].target) then
		messages_to_targets(id, id, exvar[id].target,
			exvar[id].msg, exvar[id].delay)
	end
	-- Call the basic function
	eatdrink(self, id, who)
end




	