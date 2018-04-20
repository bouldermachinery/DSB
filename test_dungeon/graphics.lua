-- graphics.lua --
-- This file simply loads a few extra bitmaps and creates a new wallset.

gfx.bluehaze = dsb_get_bitmap("ALPHAHAZE")

gfx.redfloor = dsb_get_bitmap("REDFLOOR")
gfx.redroof = dsb_get_bitmap("REDROOF")
                                            
wallset.redfloor = dsb_make_wallset_ext(gfx.redfloor, gfx.redroof, gfx.pers0, gfx.pers0alt,
	gfx.pers1, gfx.pers1alt, gfx.pers2, gfx.pers2alt, gfx.pers3, gfx.pers3alt,
	gfx.farwall3, gfx.farwall3alt, gfx.front1, gfx.front2, gfx.front3,
	gfx.left1, gfx.left1alt, gfx.left2, gfx.left2alt, gfx.left3, gfx.left3alt, gfx.wallwindow)
		
-- Use a player color bitmap
gfx.bright_green = dsb_get_bitmap("BRIGHT_GREEN")
player_colors[1] = gfx.bright_green