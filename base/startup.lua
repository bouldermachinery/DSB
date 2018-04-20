-- Global base startup script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- If you want to change what happens here it's much better
-- to change your own dungeon's "startup.lua" rather than
-- this global one.

function default_exports()
	g_last_monster_attack = 1000
	dsb_export("g_last_party_move")
	dsb_export("g_last_monster_attack")
	dsb_export("g_rclock")
	dsb_export("g_illum")
	dsb_export("g_footprint_counter")
	dsb_export("g_disabled_runes")
	dsb_export("g_total_pit_damage")
end

function test_function()
	dsb_write(debug_color, "TEST")
end

-- Deprecated functions that will still be supported for now
function dsb_rune_enable(rune)
	g_disabled_runes[rune] = false
end

function dsb_rune_disable(rune)
	g_disabled_runes[rune] = true
end

global_startup()
default_exports()