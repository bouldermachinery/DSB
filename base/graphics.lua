-- Global graphics/sound config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- If you want to add new graphics or sounds to your
-- dungeon, it's a much better idea to put them in your
-- own dungeon's startup.lua, or in a graphics.lua that
-- you create in your dungeon's directory, loaded by your
-- lua_manifest.

gfx = {}
snd = {}
wallset = {}

function setup_icons(tablename, imagename, image_long_path)
	local x, y
	local counter = 0
	local iconsheet
	if (image_long_path) then 
		iconsheet = dsb_get_bitmap(imagename, image_long_path)
	else
		iconsheet = dsb_get_bitmap(imagename)
	end
			
	gfx[tablename] = {}

	for y=0,(dsb_bitmap_height(iconsheet)-32),32 do
		for x=0,(dsb_bitmap_width(iconsheet)-32),32 do
			gfx[tablename][counter] = dsb_new_bitmap(32, 32)
			dsb_bitmap_blit(iconsheet, gfx[tablename][counter], x, y, 0, 0, 32, 32)
			counter = counter + 1
		end
	end
end
setup_icons("icons", "ICONGRID")

gfx.floor = dsb_get_bitmap("WALLSET_FLOOR")
gfx.roof = dsb_get_bitmap("WALLSET_ROOF")
gfx.pers0 = dsb_get_bitmap("WALLSET_PERS0")
gfx.pers0alt = dsb_get_bitmap("WALLSET_PERS0ALT")
gfx.pers1 = dsb_get_bitmap("WALLSET_PERS1")
gfx.pers1alt = dsb_get_bitmap("WALLSET_PERS1ALT")
gfx.pers2 = dsb_get_bitmap("WALLSET_PERS2")
gfx.pers2alt = dsb_get_bitmap("WALLSET_PERS2ALT")
gfx.pers3 = dsb_get_bitmap("WALLSET_PERS3")
gfx.pers3alt = dsb_get_bitmap("WALLSET_PERS3ALT")
gfx.farwall3 = dsb_get_bitmap("WALLSET_FARWALL3")
gfx.farwall3alt = dsb_get_bitmap("WALLSET_FARWALL3ALT")
gfx.front1 = dsb_get_bitmap("WALLSET_FRONT1")
gfx.front2 = dsb_get_bitmap("WALLSET_FRONT2")
gfx.front3 = dsb_get_bitmap("WALLSET_FRONT3")
gfx.left1 = dsb_get_bitmap("WALLSET_LEFT1")
gfx.left2 = dsb_get_bitmap("WALLSET_LEFT2")
gfx.left3 = dsb_get_bitmap("WALLSET_LEFT3")
gfx.left1alt = dsb_get_bitmap("WALLSET_LEFT1ALT")
gfx.left2alt = dsb_get_bitmap("WALLSET_LEFT2ALT")
gfx.left3alt = dsb_get_bitmap("WALLSET_LEFT3ALT")

-- Old bitmaps needed for teleport mask/old dungeons
gfx.oldfront1 = dsb_get_bitmap("WALLSET_OLDFRONT1")
gfx.oldfront2 = dsb_get_bitmap("WALLSET_OLDFRONT2")
gfx.oldfront3 = dsb_get_bitmap("WALLSET_OLDFRONT3")

-- These "patch" files are for masking off the
-- bits of bricks so buttons/texts look nicer
-- when using the old walls, like old CSB.
-- Or something.
-- In all honesty, I pretty much hate them and I've
-- tried to make it so sane people don't need them.
gfx.patch1 = dsb_get_bitmap("WALLSET_PATCH1")
gfx.patch1.y_off = 4
gfx.patch2 = dsb_get_bitmap("WALLSET_PATCH2")
gfx.patch2.y_off = 2
gfx.patch3 = dsb_get_bitmap("WALLSET_PATCH3")
gfx.patchside = dsb_get_bitmap("WALLSET_PATCHSIDE")

gfx.wallwindow = dsb_get_mask_bitmap("WALLSET_WINDOW")

-- This must be first, or the teleport drawing code breaks.
-- I know it's ugly. :P
wallset.__old_default = dsb_make_wallset(gfx.floor, gfx.roof, gfx.pers0, gfx.pers0alt,
	gfx.pers1, gfx.pers1alt, gfx.pers2, gfx.pers2alt, gfx.pers3, gfx.pers3alt,
	gfx.farwall3, gfx.farwall3alt, gfx.oldfront1, gfx.oldfront2, gfx.oldfront3,
    gfx.patch1, gfx.patch2, gfx.patch3, gfx.patchside, gfx.wallwindow)

-- This uses an ext-wallset and passes 22 parameters because it uses no "patches"
wallset.default = dsb_make_wallset_ext(gfx.floor, gfx.roof, gfx.pers0, gfx.pers0alt,
	gfx.pers1, gfx.pers1alt, gfx.pers2, gfx.pers2alt, gfx.pers3, gfx.pers3alt,
	gfx.farwall3, gfx.farwall3alt, gfx.front1, gfx.front2, gfx.front3,
	gfx.left1, gfx.left1alt, gfx.left2, gfx.left2alt, gfx.left3, gfx.left3alt, gfx.wallwindow)

gfx.scratches_front = dsb_get_bitmap("SCRATCHES_FRONT")
gfx.scratches_side = dsb_get_bitmap("SCRATCHES_SIDE")

gfx.holes_dagger_front = dsb_get_bitmap("HOLES_DAGGER_FRONT")
gfx.holes_dagger_front.y_off = 8
gfx.holes_dagger_side = dsb_get_bitmap("HOLES_DAGGER_SIDE")
gfx.holes_dagger_side.y_off = 4
gfx.holes_fireball_front = dsb_get_bitmap("HOLES_FIREBALL_FRONT")
gfx.holes_fireball_front.y_off = 8
gfx.holes_fireball_side = dsb_get_bitmap("HOLES_FIREBALL_SIDE")
gfx.holes_fireball_side.y_off = 4
gfx.holes_poison_front = dsb_get_bitmap("HOLES_POISON_FRONT")
gfx.holes_poison_front.y_off = 8
gfx.holes_poison_side = dsb_get_bitmap("HOLES_POISON_SIDE")
gfx.holes_poison_side.y_off = 4

gfx.hook_front = dsb_get_bitmap("HOOK_FRONT")
gfx.hook_side = dsb_get_bitmap("HOOK_SIDE")
gfx.dent_front = dsb_get_bitmap("DENT_FRONT")
gfx.dent_side = dsb_get_bitmap("DENT_SIDE")
gfx.dent2_front = dsb_get_bitmap("DENT2_FRONT")
gfx.dent2_side = dsb_get_bitmap("DENT2_SIDE")
gfx.peg_front = dsb_get_bitmap("WALLPEG_FRONT")
gfx.peg_side = dsb_get_bitmap("WALLPEG_SIDE")
gfx.ring_wood_front = dsb_get_bitmap("RING_WOOD_FRONT")
gfx.ring_wood_side = dsb_get_bitmap("RING_WOOD_SIDE")
gfx.ring_plain_front = dsb_get_bitmap("RING_PLAIN_FRONT")
gfx.ring_plain_side = dsb_get_bitmap("RING_PLAIN_SIDE")

gfx.wallgrate_front = dsb_get_bitmap("WALLGRATE_FRONT")
gfx.wallgrate_front.y_off = 110
gfx.wallgrate_side = dsb_get_bitmap("WALLGRATE_SIDE")
gfx.wallgrate_side.y_off = 90
gfx.wallgrate_side.far_y_tweak = 2

gfx.wallslime_front = dsb_get_bitmap("WALLSLIME_FRONT")
gfx.wallslime_front.y_off = 54
gfx.wallslime_side = dsb_get_bitmap("WALLSLIME_SIDE")
gfx.wallslime_side.y_off = 48

gfx.slimedrain_front = dsb_get_bitmap("SLIMEDRAIN_FRONT")
gfx.slimedrain_front.y_off = 112
gfx.slimedrain_side = dsb_get_bitmap("SLIMEDRAIN_SIDE")
gfx.slimedrain_side.y_off = 82

gfx.crack_front = dsb_get_bitmap("WALLCRACK_FRONT")
gfx.crack_front.x_off = 2
gfx.crack_front.y_off = 110
gfx.crack_side = dsb_get_bitmap("WALLCRACK_SIDE")
gfx.crack_side.x_off = 2
gfx.crack_side.y_off = 82
gfx.crack_side.far_y_tweak = 2

gfx.crackswitch_front = dsb_get_bitmap("CRACKSWITCH_FRONT")
gfx.crackswitch_front.x_off = 2
gfx.crackswitch_front.y_off = 112
gfx.crackswitch_pushed_front = dsb_get_bitmap("CRACKSWITCH_PUSHED_FRONT")
gfx.crackswitch_pushed_front.x_off = 2
gfx.crackswitch_pushed_front.y_off = 112
gfx.crackswitch_side = dsb_get_bitmap("CRACKSWITCH_SIDE")
gfx.crackswitch_side.x_off = 2
gfx.crackswitch_side.y_off = 82
gfx.crackswitch_side.far_y_tweak = 2

gfx.keyhole_plain_front = dsb_get_bitmap("KEYHOLE_PLAIN_FRONT")
gfx.keyhole_plain_side = dsb_get_bitmap("KEYHOLE_PLAIN_SIDE")
gfx.keyhole_cross_front = dsb_get_bitmap("KEYHOLE_CROSS_FRONT")
gfx.keyhole_cross_side = dsb_get_bitmap("KEYHOLE_CROSS_SIDE")
gfx.keyhole_double_front = dsb_get_bitmap("KEYHOLE_DOUBLE_FRONT")
gfx.keyhole_double_side = dsb_get_bitmap("KEYHOLE_DOUBLE_SIDE")
gfx.keyhole_emerald_front = dsb_get_bitmap("KEYHOLE_EMERALD_FRONT")
gfx.keyhole_emerald_side = dsb_get_bitmap("KEYHOLE_EMERALD_SIDE")
gfx.keyhole_gold_front = dsb_get_bitmap("KEYHOLE_GOLD_FRONT")
gfx.keyhole_gold_side = dsb_get_bitmap("KEYHOLE_GOLD_SIDE")
gfx.keyhole_master_front = dsb_get_bitmap("KEYHOLE_MASTER_FRONT")
gfx.keyhole_master_side = dsb_get_bitmap("KEYHOLE_MASTER_SIDE")
gfx.keyhole_onyx_front = dsb_get_bitmap("KEYHOLE_ONYX_FRONT")
gfx.keyhole_onyx_side = dsb_get_bitmap("KEYHOLE_ONYX_SIDE")
gfx.keyhole_ra_front = dsb_get_bitmap("KEYHOLE_RA_FRONT")
gfx.keyhole_ra_side = dsb_get_bitmap("KEYHOLE_RA_SIDE")
gfx.keyhole_ruby_front = dsb_get_bitmap("KEYHOLE_RUBY_FRONT")
gfx.keyhole_ruby_side = dsb_get_bitmap("KEYHOLE_RUBY_SIDE")
gfx.keyhole_skeleton_front = dsb_get_bitmap("KEYHOLE_SKELETON_FRONT")
gfx.keyhole_skeleton_side = dsb_get_bitmap("KEYHOLE_SKELETON_SIDE")
gfx.keyhole_solid_front = dsb_get_bitmap("KEYHOLE_SOLID_FRONT")
gfx.keyhole_solid_side = dsb_get_bitmap("KEYHOLE_SOLID_SIDE")
gfx.keyhole_square_front = dsb_get_bitmap("KEYHOLE_SQUARE_FRONT")
gfx.keyhole_square_side = dsb_get_bitmap("KEYHOLE_SQUARE_SIDE")
gfx.keyhole_topaz_front = dsb_get_bitmap("KEYHOLE_TOPAZ_FRONT")
gfx.keyhole_topaz_side = dsb_get_bitmap("KEYHOLE_TOPAZ_SIDE")
gfx.keyhole_turquoise_front = dsb_get_bitmap("KEYHOLE_TURQUOISE_FRONT")
gfx.keyhole_turquoise_side = dsb_get_bitmap("KEYHOLE_TURQUOISE_SIDE")
gfx.keyhole_winged_front = dsb_get_bitmap("KEYHOLE_WINGED_FRONT")
gfx.keyhole_winged_side = dsb_get_bitmap("KEYHOLE_WINGED_SIDE")
gfx.coinslot_front = dsb_get_bitmap("COINSLOT_FRONT")
gfx.coinslot_side = dsb_get_bitmap("COINSLOT_SIDE")
gfx.gemhole_front = dsb_get_bitmap("GEMHOLE_FRONT")
gfx.gemhole_side = dsb_get_bitmap("GEMHOLE_SIDE")
gfx.eye_front = dsb_get_bitmap("EYE_FRONT")
gfx.eye_side = dsb_get_bitmap("EYE_SIDE")

gfx.lever_down_front = dsb_get_bitmap("LEVER_DOWN_FRONT")
gfx.lever_down_side = dsb_get_bitmap("LEVER_DOWN_SIDE")
gfx.lever_up_front = dsb_get_bitmap("LEVER_UP_FRONT")
gfx.lever_up_side = dsb_get_bitmap("LEVER_UP_SIDE")

gfx.brickswitch_front = dsb_get_bitmap("BRICKSWITCH_FRONT")
gfx.brickswitch_front.x_off = 2
gfx.brickswitch_side = dsb_get_bitmap("BRICKSWITCH_SIDE")
gfx.brickswitch_pushed_front = dsb_get_bitmap("BRICKSWITCH_PUSHED_FRONT")
gfx.brickswitch_pushed_front.x_off = 2
gfx.brickswitch_pushed_side = dsb_get_bitmap("BRICKSWITCH_PUSHED_SIDE")

gfx.button_green_front = dsb_get_bitmap("BUTTON_GREEN_FRONT")
gfx.button_green_side = dsb_get_bitmap("BUTTON_GREEN_SIDE")
gfx.button_green_pushed_front = dsb_get_bitmap("BUTTON_GREEN_PUSHED_FRONT")
gfx.button_green_pushed_side = dsb_get_bitmap("BUTTON_GREEN_PUSHED_SIDE")
gfx.button_blue_front = dsb_get_bitmap("BUTTON_BLUE_FRONT")
gfx.button_blue_side = dsb_get_bitmap("BUTTON_BLUE_SIDE")
gfx.button_blue_pushed_front = dsb_get_bitmap("BUTTON_BLUE_PUSHED_FRONT")
gfx.button_blue_pushed_side = dsb_get_bitmap("BUTTON_BLUE_PUSHED_SIDE")
gfx.button_redcross_front = dsb_get_bitmap("BUTTON_RED_FRONT")
gfx.button_redcross_front.x_off = 2
gfx.button_redcross_side = dsb_get_bitmap("BUTTON_RED_SIDE")
gfx.button_redcross_pushed_front = dsb_get_bitmap("BUTTON_RED_PUSHED_FRONT")
gfx.button_redcross_pushed_front.x_off = 2
gfx.button_redcross_pushed_side = dsb_get_bitmap("BUTTON_RED_PUSHED_SIDE")
gfx.smallswitch_front = dsb_get_bitmap("SMALLSWITCH_FRONT")
gfx.smallswitch_front.x_off = -2
gfx.smallswitch_front.y_off = 56
gfx.smallswitch_side = dsb_get_bitmap("SMALLSWITCH_SIDE")
gfx.smallswitch_side.x_off = -26
gfx.smallswitch_side.y_off = 68
gfx.tinyswitch_front = dsb_get_bitmap("TINYBUTTON_FRONT")
gfx.tinyswitch_front.x_off = 72
gfx.tinyswitch_front.y_off = -6
gfx.tinyswitch_side = dsb_get_bitmap("TINYBUTTON_SIDE")
gfx.tinyswitch_side.x_off = -8
gfx.tinyswitch_side.y_off = -4
gfx.tinyswitch_otherside = dsb_get_bitmap("TINYBUTTON_SIDE")
gfx.tinyswitch_otherside.x_off = -48
gfx.tinyswitch_otherside.y_off = -4

gfx.mirror_front = dsb_get_bitmap("MIRROR_FRONT")
gfx.mirror_side = dsb_get_bitmap("MIRROR_SIDE")
gfx.mirror_front.y_off = -14
gfx.mirror_side.x_off = -14
gfx.mirror_side.y_off = -14
gfx.mirror_inside = dsb_get_bitmap("MIRROR_INSIDE")
gfx.mirror_inside.x_off = 32
gfx.mirror_inside.y_off = 12

gfx.alcove_front = dsb_get_bitmap("ALCOVE_FRONT")
gfx.alcove_side = dsb_get_bitmap("ALCOVE_SIDE")
gfx.alcove_side.x_off = -4
gfx.alcove_side.y_off = -4
gfx.alcove2_front = dsb_get_bitmap("ALCOVE2_FRONT")
gfx.alcove2_side = dsb_get_bitmap("ALCOVE2_SIDE")
gfx.alcove2_side.x_off = -4
gfx.alcove2_side.y_off = -4
gfx.alcove2_side.mid_x_compress = 16
gfx.alcove2_side.far_x_compress = 10
gfx.alcove2_side.mid_x_tweak = -4
gfx.alcove2_side.far_x_tweak = -2
gfx.alcove2_side.far_y_tweak = -2
gfx.alcove_vi_front = dsb_get_bitmap("VI_FRONT")
gfx.alcove_vi_side = dsb_get_bitmap("VI_SIDE")
gfx.alcove_vi_side.x_off = -4
gfx.alcove_vi_side.y_off = -4

gfx.manacles_front = dsb_get_bitmap("MANACLES_FRONT")
gfx.manacles_side = dsb_get_bitmap("MANACLES_SIDE")
gfx.manacles_side.x_off = -4

gfx.gorface_front = dsb_get_bitmap("GORFACE_FRONT")
gfx.gorface_side = dsb_get_bitmap("GORFACE_SIDE")

gfx.wallwriting_front = dsb_get_bitmap("WALLWRITING_FRONT")
gfx.wallwriting_side = dsb_get_bitmap("WALLWRITING_SIDE")

gfx.sconce_empty_front = dsb_get_bitmap("SCONCE_EMPTY_FRONT")
gfx.sconce_empty_side = dsb_get_bitmap("SCONCE_EMPTY_SIDE")
gfx.sconce_empty_side.y_off = -4
gfx.sconce_full_front = dsb_get_bitmap("SCONCE_FULL_FRONT")
gfx.sconce_full_side = dsb_get_bitmap("SCONCE_FULL_SIDE")
gfx.sconce_full_side.y_off = -4

gfx.fountain_lion_front = dsb_get_bitmap("FOUNTAIN_LION_FRONT")
gfx.fountain_lion_side = dsb_get_bitmap("FOUNTAIN_LION_SIDE")
gfx.fountain_lion_side.x_off = 8
gfx.fountain_medusa_front = dsb_get_bitmap("FOUNTAIN_MEDUSA_FRONT")
gfx.fountain_medusa_side = dsb_get_bitmap("FOUNTAIN_MEDUSA_SIDE")
gfx.fountain_medusa_side.x_off = 8

gfx.outside = dsb_get_bitmap("OUTSIDE")
gfx.outside.y_off = -54

gfx.amalgam = dsb_get_bitmap("AMALGAM")
gfx.amalgam.y_off = -54
gfx.amalgam_gembare = dsb_get_bitmap("AMALGAM_GEMBARE")
gfx.amalgam_gembare.y_off = -54
gfx.amalgam_empty = dsb_get_bitmap("AMALGAM_EMPTY")
gfx.amalgam_empty.y_off = -54

gfx.doorframe_front = {
	[0] = dsb_get_bitmap("DOORFRAME_FRONT0"),
    [1] = dsb_get_bitmap("DOORFRAME_FRONT1"),
    [2] = dsb_get_bitmap("DOORFRAME_FRONT2"),
	[3] = dsb_get_bitmap("DOORFRAME_FRONT3")
}
gfx.doorframe_front[0].y_off = -26

gfx.doorframe_side = {
    [1] = dsb_get_bitmap("DOORFRAME_SIDE1"),
    [2] = dsb_get_bitmap("DOORFRAME_SIDE2"),
    [3] = dsb_get_bitmap("DOORFRAME_SIDE3")
}
gfx.doorframe_side[1].x_off = -120
gfx.doorframe_side[1].y_off = -182
gfx.doorframe_side[2].x_off = -42
gfx.doorframe_side[2].y_off = -124

gfx.doorbutton = dsb_get_bitmap("DOORBUTTON")
gfx.doorbutton.x_off = 120
gfx.doorbutton.y_off = -110
gfx.doorbutton_side = dsb_get_bitmap("DOORBUTTON")
gfx.doorbutton_side.x_off = 84
gfx.doorbutton_side.y_off = -110

gfx.door_bashed = dsb_get_mask_bitmap("DOOR_BASHED")

gfx.door_wood = dsb_get_bitmap("DOOR_WOOD")
gfx.door_metal = dsb_get_bitmap("DOOR_METAL")
gfx.door_portcullis = dsb_get_bitmap("DOOR_PORTCULLIS")
gfx.door_black = dsb_get_bitmap("DOOR_BLACK")
gfx.door_ra = dsb_get_bitmap("DOOR_RA")
dsb_animate(gfx.door_ra, 4, 12)

gfx.door_deco_damage = dsb_get_bitmap("DOOR_DECO_DAMAGE")
gfx.door_deco_metalbars = dsb_get_bitmap("DOOR_DECO_METALBARS")
gfx.door_deco_ornate = dsb_get_bitmap("DOOR_DECO_ORNATE")
gfx.door_deco_wood = dsb_get_bitmap("DOOR_DECO_WOOD")
gfx.door_deco_magic = dsb_get_bitmap("DOOR_DECO_MAGIC")
dsb_animate(gfx.door_deco_magic, 4, 12)

gfx.door_deco_redlock = dsb_get_bitmap("DOOR_DECO_REDLOCK")
gfx.door_deco_metallock = dsb_get_bitmap("DOOR_DECO_METALLOCK")

gfx.door_deco_metallock2 = dsb_get_bitmap("DOOR_DECO_METALLOCK2")
gfx.door_deco_metallock2.x_off = 24
gfx.door_deco_metallock2.y_off = 51

gfx.door_deco_metallock3 = dsb_get_bitmap("DOOR_DECO_METALLOCK3")

gfx.door_deco_cwindow = dsb_get_mask_bitmap("DOOR_DECO_CWINDOW")
gfx.door_deco_cwindow.y_off = -42
gfx.door_deco_swindow = dsb_get_mask_bitmap("DOOR_DECO_SWINDOW")
gfx.door_deco_swindow.y_off = -42

gfx.pad_tiny_front = dsb_get_bitmap("PAD_TINY_FRONT1")

gfx.floorcrack_front = {
	[1] = dsb_get_bitmap("FLOORCRACK_FRONT1"),
	[2] = dsb_get_bitmap("FLOORCRACK_FRONT2"),
	[3] = dsb_get_bitmap("FLOORCRACK_FRONT3")
}
gfx.floorcrack_side = {
	[1] = dsb_get_bitmap("BLANK_IMAGE"),
	[2] = dsb_get_bitmap("FLOORCRACK_SIDE2"),
	[3] = dsb_get_bitmap("FLOORCRACK_SIDE3")
}
gfx.floorslime_front = {
	[1] = dsb_get_bitmap("FLOORSLIME_FRONT1"),
	[2] = dsb_get_bitmap("FLOORSLIME_FRONT2"),
	[3] = dsb_get_bitmap("FLOORSLIME_FRONT3")
}
gfx.floorslime_side = {
	[1] = dsb_get_bitmap("FLOORSLIME_SIDE1"),
	[2] = dsb_get_bitmap("FLOORSLIME_SIDE2"),
	[3] = dsb_get_bitmap("FLOORSLIME_SIDE3")
}

gfx.puddle_front = {
	[1] = dsb_get_bitmap("PUDDLE_FRONT1"),
	[2] = dsb_get_bitmap("PUDDLE_FRONT2"),
	[3] = dsb_get_bitmap("PUDDLE_FRONT3")
}
gfx.puddle_side = {
	[1] = dsb_get_bitmap("PUDDLE_SIDE1"),
	[2] = dsb_get_bitmap("PUDDLE_SIDE2"),
	[3] = dsb_get_bitmap("PUDDLE_SIDE3")
}

gfx.rounddrain_front = {
	[1] = dsb_get_bitmap("ROUNDDRAIN_FRONT1"),
	[2] = dsb_get_bitmap("ROUNDDRAIN_FRONT2"),
	[3] = dsb_get_bitmap("ROUNDDRAIN_FRONT3")
}
gfx.rounddrain_side = {
	[1] = dsb_get_bitmap("ROUNDDRAIN_SIDE1"),
	[2] = dsb_get_bitmap("ROUNDDRAIN_SIDE2"),
	[3] = dsb_get_bitmap("ROUNDDRAIN_SIDE3")
}
gfx.squaredrain_front = {
	[1] = dsb_get_bitmap("SQUAREDRAIN_FRONT1"),
	[2] = dsb_get_bitmap("SQUAREDRAIN_FRONT2"),
	[3] = dsb_get_bitmap("SQUAREDRAIN_FRONT3")
}
gfx.squaredrain_side = {
	[1] = dsb_get_bitmap("SQUAREDRAIN_SIDE1"),
	[2] = dsb_get_bitmap("SQUAREDRAIN_SIDE2"),
	[3] = dsb_get_bitmap("SQUAREDRAIN_SIDE3")
}
gfx.firepit_front = {
	[1] = dsb_get_bitmap("FIREPIT_FRONT1"),
	[2] = dsb_get_bitmap("FIREPIT_FRONT2"),
	[3] = dsb_get_bitmap("FIREPIT_FRONT3")
}
gfx.firepit_side = {
	[1] = dsb_get_bitmap("FIREPIT_SIDE1"),
	[2] = dsb_get_bitmap("FIREPIT_SIDE2"),
	[3] = dsb_get_bitmap("FIREPIT_SIDE3")
}
gfx.pad_front = {
	[1] = dsb_get_bitmap("PAD_FRONT1"),
	[2] = dsb_get_bitmap("PAD_FRONT2"),
	[3] = dsb_get_bitmap("PAD_FRONT3")
}
gfx.pad_side = {
	[1] = dsb_get_bitmap("PAD_SIDE1"),
	[2] = dsb_get_bitmap("PAD_SIDE2"),
	[3] = dsb_get_bitmap("PAD_SIDE3")
}
gfx.pad_small_front = {
	[1] = dsb_get_bitmap("PAD_SMALL_FRONT1"),
	[2] = dsb_get_bitmap("PAD_SMALL_FRONT2"),
	[3] = dsb_get_bitmap("PAD_SMALL_FRONT3")
}
gfx.pad_small_side = {
	[1] = dsb_get_bitmap("PAD_SMALL_SIDE1"),
	[2] = dsb_get_bitmap("PAD_SMALL_SIDE2"),
	[3] = dsb_get_bitmap("PAD_SMALL_SIDE3")
}
gfx.footprints_front = {
	[1] = dsb_get_bitmap("FOOTPRINTS_FRONT1"),
	[2] = dsb_get_bitmap("FOOTPRINTS_FRONT2"),
	[3] = dsb_get_bitmap("FOOTPRINTS_FRONT3")
}
gfx.footprints_side = {
	[1] = dsb_get_bitmap("FOOTPRINTS_SIDE1"),
	[2] = dsb_get_bitmap("FOOTPRINTS_SIDE2"),
	[3] = dsb_get_bitmap("FOOTPRINTS_SIDE3")
}

gfx.stairsdown_front = {
    [0] = dsb_get_bitmap("STAIRSDOWN_FRONT0"),
	[1] = dsb_get_bitmap("STAIRSDOWN_FRONT1"),
	[2] = dsb_get_bitmap("STAIRSDOWN_FRONT2"),
	[3] = dsb_get_bitmap("STAIRSDOWN_FRONT3")
}
gfx.stairsdown_side = {
    [0] = dsb_get_bitmap("STAIRSDOWN_SIDE0"),
	[1] = dsb_get_bitmap("STAIRSDOWN_SIDE1"),
	[2] = dsb_get_bitmap("STAIRSDOWN_SIDE2"),
	[3] = dsb_get_bitmap("STAIRSDOWN_SIDE3")
}
gfx.stairsdown_side[0].y_off = -104
gfx.stairsdown_xside = {
	[1] = dsb_get_bitmap("STAIRSDOWN_XSIDE1"),
	[2] = dsb_get_bitmap("STAIRSDOWN_XSIDE2")
}
gfx.stairsdown_xside[1].x_off = 64
gfx.stairsdown_xside[1].y_off = -6
gfx.stairsdown_xside[2].x_off = 120
gfx.stairsdown_xside[2].y_off = -1

gfx.stairsup_front = {
    [0] = dsb_get_bitmap("STAIRSUP_FRONT0"),
	[1] = dsb_get_bitmap("STAIRSUP_FRONT1"),
	[2] = dsb_get_bitmap("STAIRSUP_FRONT2"),
	[3] = dsb_get_bitmap("STAIRSUP_FRONT3")
}
gfx.stairsup_side = {
	[1] = dsb_get_bitmap("STAIRSUP_SIDE1"),
	[2] = dsb_get_bitmap("STAIRSUP_SIDE2"),
	[3] = dsb_get_bitmap("STAIRSUP_SIDE3")
}
gfx.stairsup_xside = {
	[1] = dsb_get_bitmap("STAIRSUP_XSIDE1"),
}
gfx.stairsup_xside[1].x_off = 64
gfx.stairsup_xside[1].y_off = -6

gfx.pit_front = {
    [0] = dsb_get_bitmap("PIT_FRONT0"),
	[1] = dsb_get_bitmap("PIT_FRONT1"),
	[2] = dsb_get_bitmap("PIT_FRONT2"),
	[3] = dsb_get_bitmap("PIT_FRONT3")
}
gfx.pit_front[1].y_off = 1
gfx.pit_front[2].y_off = -1
gfx.pit_side = {
    [0] = dsb_get_bitmap("PIT_SIDE0"),
	[1] = dsb_get_bitmap("PIT_SIDE1"),
	[2] = dsb_get_bitmap("PIT_SIDE2"),
	[3] = dsb_get_bitmap("PIT_SIDE3")
}
gfx.pit_side[1].y_off = 1
gfx.pit_side[2].y_off = -1
gfx.pit_side[3].x_off = -60

gfx.ipit_front = {
    [0] = dsb_get_bitmap("IPIT_FRONT0"),
	[1] = dsb_get_bitmap("IPIT_FRONT1"),
	[2] = dsb_get_bitmap("IPIT_FRONT2")
}
gfx.ipit_front[1].y_off = 1
gfx.ipit_front[2].y_off = -1
gfx.ipit_side = {
    [0] = dsb_get_bitmap("IPIT_SIDE0"),
	[1] = dsb_get_bitmap("IPIT_SIDE1"),
	[2] = dsb_get_bitmap("IPIT_SIDE2")
}
gfx.ipit_side[1].y_off = 1
gfx.ipit_side[2].y_off = -1

gfx.ceiling_pit_front = {
    [0] = dsb_get_bitmap("CEILING_PIT_FRONT0"),
	[1] = dsb_get_bitmap("CEILING_PIT_FRONT1"),
	[2] = dsb_get_bitmap("CEILING_PIT_FRONT2")
}
gfx.ceiling_pit_front[0].y_off = -264
gfx.ceiling_pit_front[1].y_off = -180
gfx.ceiling_pit_front[2].y_off = -120
gfx.ceiling_pit_side = {
    [0] = dsb_get_bitmap("CEILING_PIT_SIDE0"),
	[1] = dsb_get_bitmap("CEILING_PIT_SIDE1"),
	[2] = dsb_get_bitmap("CEILING_PIT_SIDE2")
}
gfx.ceiling_pit_side[0].y_off = -264
gfx.ceiling_pit_side[1].y_off = -180
gfx.ceiling_pit_side[2].y_off = -120

gfx.bluehaze = dsb_get_bitmap("BLUEHAZE")
gfx.fluxcagehaze = dsb_get_bitmap("FLUXCAGEHAZE")

gfx.cloud_monster_death = dsb_get_bitmap("CLOUD_MONSTER_DEATH")
gfx.incloud_monster_weak = dsb_get_bitmap("INCLOUD_MONSTER_WEAK")
gfx.incloud_monster_med = dsb_get_bitmap("INCLOUD_MONSTER_MED")
gfx.incloud_monster_strong = dsb_get_bitmap("INCLOUD_MONSTER_STRONG")
gfx.cloud_poison = dsb_get_bitmap("CLOUD_POISON")
gfx.incloud_poison_weak = dsb_get_bitmap("INCLOUD_POISON_WEAK")
gfx.incloud_poison_med = dsb_get_bitmap("INCLOUD_POISON_MED")
gfx.incloud_poison_strong = dsb_get_bitmap("INCLOUD_POISON_STRONG")
gfx.cloud_explosion = dsb_get_bitmap("CLOUD_EXPLOSION")
gfx.incloud_explosion_weak = dsb_get_bitmap("INCLOUD_EXPLOSION_WEAK")
gfx.incloud_explosion_med = dsb_get_bitmap("INCLOUD_EXPLOSION_MED")
gfx.incloud_explosion_strong = dsb_get_bitmap("INCLOUD_EXPLOSION_STRONG")
gfx.cloud_zap = dsb_get_bitmap("CLOUD_ZAP")
gfx.incloud_zap_weak = dsb_get_bitmap("INCLOUD_ZAP_WEAK")
gfx.incloud_zap_med = dsb_get_bitmap("INCLOUD_ZAP_MED")
gfx.incloud_zap_strong = dsb_get_bitmap("INCLOUD_ZAP_STRONG")

gfx.antman_front = dsb_get_bitmap("ANTMAN_FRONT")
gfx.antman_side = dsb_get_bitmap("ANTMAN_SIDE")
gfx.antman_back = dsb_get_bitmap("ANTMAN_BACK")
gfx.antman_attack = dsb_get_bitmap("ANTMAN_ATTACK")

gfx.blackflame_base = dsb_get_bitmap("BLACKFLAME_BASE")
gfx.blackflame_base.y_off = 8
gfx.blackflame_attack = dsb_get_bitmap("BLACKFLAME_ATTACK")
gfx.blackflame_attack.y_off = 8

gfx.couatl_front = dsb_get_bitmap("COUATL_FRONT")
gfx.couatl_front.y_off = 8
gfx.couatl_side = dsb_get_bitmap("COUATL_SIDE")
gfx.couatl_side.y_off = 8
gfx.couatl_back = dsb_get_bitmap("COUATL_BACK")
gfx.couatl_back.y_off = 8
gfx.couatl_attack = dsb_get_bitmap("COUATL_ATTACK")
gfx.couatl_attack.y_off = 8

gfx.demon_front = dsb_get_bitmap("DEMON_FRONT")
gfx.demon_front.x_off = -8
gfx.demon_side = dsb_get_bitmap("DEMON_SIDE")
gfx.demon_side.x_off = -8
gfx.demon_back = dsb_get_bitmap("DEMON_BACK")
gfx.demon_back.x_off = -8
gfx.demon_attack = dsb_get_bitmap("DEMON_ATTACK")
gfx.demon_attack.x_off = -8

gfx.demon2_front = dsb_get_bitmap("DEMON2_FRONT")
gfx.demon2_front.x_off = -8
gfx.demon2_side = dsb_get_bitmap("DEMON2_SIDE")
gfx.demon2_side.x_off = -8
gfx.demon2_back = dsb_get_bitmap("DEMON2_BACK")
gfx.demon2_back.x_off = -8
gfx.demon2_attack = dsb_get_bitmap("DEMON2_ATTACK")
gfx.demon2_attack.x_off = -8

gfx.dragon_front = dsb_get_bitmap("DRAGON_FRONT")
gfx.dragon_front.y_off = 16
gfx.dragon_side = dsb_get_bitmap("DRAGON_SIDE")
gfx.dragon_side.y_off = 16
gfx.dragon_back = dsb_get_bitmap("DRAGON_BACK")
gfx.dragon_back.y_off = 16
gfx.dragon_attack = dsb_get_bitmap("DRAGON_ATTACK")
gfx.dragon_attack.y_off = 16

gfx.gazer_base = dsb_get_bitmap("GAZER_FRONT")
gfx.gazer_base.x_off = -8
gfx.gazer_base.y_off = -48
gfx.gazer_attack = dsb_get_bitmap("GAZER_ATTACK")
gfx.gazer_attack.x_off = -8
gfx.gazer_attack.y_off = -48

gfx.ghost_base = dsb_get_bitmap("GHOST_BASE")
gfx.ghost_attack = dsb_get_bitmap("GHOST_ATTACK")

gfx.giggler_front = dsb_get_bitmap("GIGGLER_FRONT")
gfx.giggler_side = dsb_get_bitmap("GIGGLER_SIDE")
gfx.giggler_back = dsb_get_bitmap("GIGGLER_BACK")

gfx.golem_front = dsb_get_bitmap("GOLEM_FRONT")
gfx.golem_front.y_off = 16
gfx.golem_side = dsb_get_bitmap("GOLEM_SIDE")
gfx.golem_side.y_off = 16
gfx.golem_back = dsb_get_bitmap("GOLEM_BACK")
gfx.golem_back.y_off = 16
gfx.golem_attack = dsb_get_bitmap("GOLEM_ATTACK")
gfx.golem_attack.y_off = 16

gfx.hellhound_front = dsb_get_bitmap("HELLHOUND_FRONT")
gfx.hellhound_front.y_off = 8
gfx.hellhound_side = dsb_get_bitmap("HELLHOUND_SIDE")
gfx.hellhound_side.y_off = 8
gfx.hellhound_back = dsb_get_bitmap("HELLHOUND_BACK")
gfx.hellhound_back.y_off = 8
gfx.hellhound_attack = dsb_get_bitmap("HELLHOUND_ATTACK")
gfx.hellhound_attack.y_off = 8

gfx.knight_armour_front = dsb_get_bitmap("KNIGHT_ARMOUR_FRONT")
gfx.knight_armour_front.y_off = 8
gfx.knight_armour_side = dsb_get_bitmap("KNIGHT_ARMOUR_SIDE")
gfx.knight_armour_side.y_off = 8
gfx.knight_armour_back = dsb_get_bitmap("KNIGHT_ARMOUR_BACK")
gfx.knight_armour_back.y_off = 8
gfx.knight_armour_attack = dsb_get_bitmap("KNIGHT_ARMOUR_ATTACK")
gfx.knight_armour_attack.y_off = 8

gfx.knight_deth_front = dsb_get_bitmap("KNIGHT_DETH_FRONT")
gfx.knight_deth_front.y_off = 8
gfx.knight_deth_side = dsb_get_bitmap("KNIGHT_DETH_SIDE")
gfx.knight_deth_side.y_off = 8
gfx.knight_deth_back = dsb_get_bitmap("KNIGHT_DETH_BACK")
gfx.knight_deth_back.y_off = 8
gfx.knight_deth_attack = dsb_get_bitmap("KNIGHT_DETH_ATTACK")
gfx.knight_deth_attack.y_off = 8

gfx.lordchaos_front = dsb_get_bitmap("LORDCHAOS_FRONT")
gfx.lordchaos_side = dsb_get_bitmap("LORDCHAOS_SIDE")
gfx.lordchaos_back = dsb_get_bitmap("LORDCHAOS_BACK")
gfx.lordchaos_attack = dsb_get_bitmap("LORDCHAOS_ATTACK")

gfx.lordorder = dsb_get_bitmap("LORDORDER")

gfx.greylord = dsb_get_bitmap("GREYLORD")

gfx.materializer_front = dsb_get_bitmap("MATERIALIZER_FRONT")
gfx.materializer_side = dsb_get_bitmap("MATERIALIZER_SIDE")
gfx.materializer_back = dsb_get_bitmap("MATERIALIZER_BACK")
gfx.materializer_attack = dsb_get_bitmap("MATERIALIZER_ATTACK")

gfx.mummy_front = dsb_get_bitmap("MUMMY_FRONT")
gfx.mummy_side = dsb_get_bitmap("MUMMY_SIDE")
gfx.mummy_back = dsb_get_bitmap("MUMMY_BACK")
gfx.mummy_attack = dsb_get_bitmap("MUMMY_ATTACK")

gfx.muncher_front = dsb_get_bitmap("MUNCHER_FRONT")
gfx.muncher_front.y_off = -74
gfx.muncher_side = dsb_get_bitmap("MUNCHER_SIDE")
gfx.muncher_side.y_off = -74
gfx.muncher_back = dsb_get_bitmap("MUNCHER_BACK")
gfx.muncher_back.y_off = -74
gfx.muncher_attack = dsb_get_bitmap("MUNCHER_ATTACK")
gfx.muncher_attack.y_off = -74

gfx.oitu_front = dsb_get_bitmap("OITU_FRONT")
gfx.oitu_front.y_off = 16
gfx.oitu_side = dsb_get_bitmap("OITU_SIDE")
gfx.oitu_side.y_off = 16
gfx.oitu_back = dsb_get_bitmap("OITU_BACK")
gfx.oitu_back.y_off = 16
gfx.oitu_attack = dsb_get_bitmap("OITU_ATTACK")
gfx.oitu_attack.y_off = 16

gfx.oitu2_front = dsb_get_bitmap("OITU2_FRONT")
gfx.oitu2_front.y_off = 16
gfx.oitu2_side = dsb_get_bitmap("OITU2_SIDE")
gfx.oitu2_side.y_off = 16
gfx.oitu2_back = dsb_get_bitmap("OITU2_BACK")
gfx.oitu2_back.y_off = 16
gfx.oitu2_attack = dsb_get_bitmap("OITU2_ATTACK")
gfx.oitu2_attack.y_off = 16

gfx.rat_front = dsb_get_bitmap("RAT_FRONT")
gfx.rat_front.y_off = 8
gfx.rat_side = dsb_get_bitmap("RAT_SIDE")
gfx.rat_side.y_off = 8
gfx.rat_back = dsb_get_bitmap("RAT_BACK")
gfx.rat_back.y_off = 8
gfx.rat_attack = dsb_get_bitmap("RAT_ATTACK")
gfx.rat_attack.y_off = 8

gfx.rive_base = dsb_get_bitmap("RIVE_BASE")
gfx.rive_attack = dsb_get_bitmap("RIVE_ATTACK")

gfx.rockpile_base = dsb_get_bitmap("ROCKPILE_BASE")
gfx.rockpile_base.x_off = -8
gfx.rockpile_attack = dsb_get_bitmap("ROCKPILE_ATTACK")
gfx.rockpile_attack.x_off = -8

gfx.ruster_front = dsb_get_bitmap("RUSTER_FRONT")
gfx.ruster_front.y_off = 8
gfx.ruster_side = dsb_get_bitmap("RUSTER_SIDE")
gfx.ruster_side.y_off = 8
gfx.ruster_back = dsb_get_bitmap("RUSTER_BACK")
gfx.ruster_back.y_off = 8

gfx.scorpion_front = dsb_get_bitmap("SCORPION_FRONT")
gfx.scorpion_front.y_off = 16
gfx.scorpion_side = dsb_get_bitmap("SCORPION_SIDE")
gfx.scorpion_side.y_off = 16
gfx.scorpion_back = dsb_get_bitmap("SCORPION_BACK")
gfx.scorpion_back.y_off = 16
gfx.scorpion_attack = dsb_get_bitmap("SCORPION_ATTACK")
gfx.scorpion_attack.y_off = 16

gfx.screamer_base = dsb_get_bitmap("SCREAMER_BASE")
gfx.screamer_attack = dsb_get_bitmap("SCREAMER_ATTACK")

gfx.skeleton_front = dsb_get_bitmap("SKELETON_FRONT")
gfx.skeleton_side = dsb_get_bitmap("SKELETON_SIDE")
gfx.skeleton_back = dsb_get_bitmap("SKELETON_BACK")
gfx.skeleton_attack = dsb_get_bitmap("SKELETON_ATTACK")

gfx.slimedevil_base = dsb_get_bitmap("SLIMEDEVIL_BASE")
gfx.slimedevil_base.x_off = -8
gfx.slimedevil_attack = dsb_get_bitmap("SLIMEDEVIL_ATTACK")
gfx.slimedevil_attack.x_off = -8

gfx.swampslime_base = dsb_get_bitmap("SWAMPSLIME_BASE")
gfx.swampslime_base.x_off = -8
gfx.swampslime_attack = dsb_get_bitmap("SWAMPSLIME_ATTACK")
gfx.swampslime_attack.x_off = -8

gfx.trolin_front = dsb_get_bitmap("TROLIN_FRONT")
gfx.trolin_side = dsb_get_bitmap("TROLIN_SIDE")
gfx.trolin_back = dsb_get_bitmap("TROLIN_BACK")
gfx.trolin_attack = dsb_get_bitmap("TROLIN_ATTACK")

gfx.vexirk_front = dsb_get_bitmap("VEXIRK_FRONT")
gfx.vexirk_side = dsb_get_bitmap("VEXIRK_SIDE")
gfx.vexirk_back = dsb_get_bitmap("VEXIRK_BACK")
gfx.vexirk_attack = dsb_get_bitmap("VEXIRK_ATTACK")
gfx.vexirk2_front = dsb_get_bitmap("VEXIRK2_FRONT")
gfx.vexirk2_side = dsb_get_bitmap("VEXIRK2_SIDE")
gfx.vexirk2_back = dsb_get_bitmap("VEXIRK2_BACK")
gfx.vexirk2_attack = dsb_get_bitmap("VEXIRK2_ATTACK")

gfx.wasp_front = dsb_get_bitmap("WASP_FRONT")
gfx.wasp_front.y_off = -74
gfx.wasp_side = dsb_get_bitmap("WASP_SIDE")
gfx.wasp_side.y_off = -74
gfx.wasp_back = dsb_get_bitmap("WASP_BACK")
gfx.wasp_back.y_off = -74
gfx.wasp_attack = dsb_get_bitmap("WASP_ATTACK")
gfx.wasp_attack.y_off = -74

gfx.waterelem_base = dsb_get_bitmap("WATERELEM_BASE")
gfx.waterelem_attack = dsb_get_bitmap("WATERELEM_ATTACK")

gfx.wizardeye_base = dsb_get_bitmap("WIZARDEYE_BASE")
gfx.wizardeye_base.x_off = -8
gfx.wizardeye_base.y_off = -48
gfx.wizardeye_attack = dsb_get_bitmap("WIZARDEYE_ATTACK")
gfx.wizardeye_attack.x_off = -8
gfx.wizardeye_attack.y_off = -48

gfx.worm_front = dsb_get_bitmap("WORM_FRONT")
gfx.worm_front.y_off = 8
gfx.worm_side = dsb_get_bitmap("WORM_SIDE")
gfx.worm_side.y_off = 6
gfx.worm_back = dsb_get_bitmap("WORM_BACK")
gfx.worm_back.y_off = 8
gfx.worm_attack = dsb_get_bitmap("WORM_ATTACK")
gfx.worm_attack.y_off = 8

gfx.worm2b_front = dsb_get_bitmap("WORM2_BROWN_FRONT")
gfx.worm2b_front.y_off = 8
gfx.worm2b_side = dsb_get_bitmap("WORM2_BROWN_SIDE")
gfx.worm2b_side.y_off = 6
gfx.worm2b_back = dsb_get_bitmap("WORM2_BROWN_BACK")
gfx.worm2b_back.y_off = 8
gfx.worm2b_attack = dsb_get_bitmap("WORM2_BROWN_ATTACK")
gfx.worm2b_attack.y_off = 8

gfx.worm2y_front = dsb_get_bitmap("WORM2_YELLOW_FRONT")
gfx.worm2y_front.y_off = 8
gfx.worm2y_side = dsb_get_bitmap("WORM2_YELLOW_SIDE")
gfx.worm2y_side.y_off = 6
gfx.worm2y_back = dsb_get_bitmap("WORM2_YELLOW_BACK")
gfx.worm2y_back.y_off = 8
gfx.worm2y_attack = dsb_get_bitmap("WORM2_YELLOW_ATTACK")
gfx.worm2y_attack.y_off = 8

gfx.zytaz_front = dsb_get_bitmap("ZYTAZ_FRONT")
gfx.zytaz_side = dsb_get_bitmap("ZYTAZ_SIDE")
gfx.zytaz_back = dsb_get_bitmap("ZYTAZ_BACK")
gfx.zytaz_attack = dsb_get_bitmap("ZYTAZ_ATTACK")

gfx.fireball = dsb_get_bitmap("FIREBALL")
gfx.poisonspell = dsb_get_bitmap("POISONSPELL")
gfx.zapspell = dsb_get_bitmap("ZAPSPELL")
gfx.lightning = dsb_get_bitmap("LIGHTNING_FLYING")
gfx.lightning_side = dsb_get_bitmap("LIGHTNING_FLYING_SIDE")

gfx.dart = dsb_get_bitmap("DART")
gfx.dart_flying_away = dsb_get_bitmap("DART_FLYING_AWAY")
gfx.dart_flying_toward = dsb_get_bitmap("DART_FLYING_TOWARD")
gfx.dart_flying_side = dsb_get_bitmap("DART_FLYING_SIDE")
gfx.dagger = dsb_get_bitmap("DAGGER")
gfx.dagger_flying_away = dsb_get_bitmap("DAGGER_FLYING_AWAY")
gfx.dagger_flying_toward = dsb_get_bitmap("DAGGER_FLYING_TOWARD")
gfx.dagger_flying_side = dsb_get_bitmap("DAGGER_FLYING_SIDE")
gfx.arrow = dsb_get_bitmap("ARROW")
gfx.arrow_flying_away = dsb_get_bitmap("ARROW_FLYING_AWAY")
gfx.arrow_flying_toward = dsb_get_bitmap("ARROW_FLYING_TOWARD")
gfx.arrow_flying_side = dsb_get_bitmap("ARROW_FLYING_SIDE")
gfx.slayer = dsb_get_bitmap("SLAYER")
gfx.slayer_flying_away = dsb_get_bitmap("SLAYER_FLYING_AWAY")
gfx.slayer_flying_toward = dsb_get_bitmap("SLAYER_FLYING_TOWARD")
gfx.slayer_flying_side = dsb_get_bitmap("SLAYER_FLYING_SIDE")
gfx.star = dsb_get_bitmap("STAR")
gfx.star_flying = dsb_get_bitmap("STAR_FLYING")
gfx.star_flying_side = dsb_get_bitmap("STAR_FLYING_SIDE")

gfx.bow = dsb_get_bitmap("BOW")
gfx.bow.y_off = 10
gfx.bow.x_off = -8
gfx.crossbow = dsb_get_bitmap("CROSSBOW")
gfx.crossbow.y_off = 10
gfx.crossbow.x_off = -8

gfx.boots_black = dsb_get_bitmap("BOOTS_BLACK")
gfx.boots_brown = dsb_get_bitmap("BOOTS_BROWN")
gfx.boots_elven = dsb_get_bitmap("BOOTS_ELVEN")
gfx.boots_speed = dsb_get_bitmap("BOOTS_SPEED")
gfx.buckler = dsb_get_bitmap("BUCKLER")
gfx.choker = dsb_get_bitmap("CHOKER")
gfx.crown = dsb_get_bitmap("CROWN")
gfx.clothes_blue = dsb_get_bitmap("CLOTHES_BLUE")
gfx.clothes_brown = dsb_get_bitmap("CLOTHES_BROWN")
gfx.clothes_green = dsb_get_bitmap("CLOTHES_GREEN")
gfx.clothes_white = dsb_get_bitmap("CLOTHES_WHITE")
gfx.footplate = dsb_get_bitmap("FOOTPLATE")
gfx.halter = dsb_get_bitmap("HALTER")
gfx.helmet = dsb_get_bitmap("HELMET")
gfx.helmet2 = dsb_get_bitmap("HELMET2")
gfx.legplate = dsb_get_bitmap("LEGPLATE")
gfx.legplate.y_off = 4
gfx.mail = dsb_get_bitmap("MAIL")
gfx.sandals = dsb_get_bitmap("SANDALS")
gfx.shield = dsb_get_bitmap("SHIELD")
gfx.shield.y_off = 4
gfx.torsoplate = dsb_get_bitmap("TORSOPLATE")
gfx.torsoplate.x_off = -4
gfx.torsoplate.y_off = 4

gfx.coin_gold = dsb_get_bitmap("COIN_GOLD")
gfx.coin_silver = dsb_get_bitmap("COIN_SILVER")
gfx.gem_blue = dsb_get_bitmap("GEM_BLUE")
gfx.gem_green = dsb_get_bitmap("GEM_GREEN")
gfx.gem_orange = dsb_get_bitmap("GEM_ORANGE")
gfx.horn = dsb_get_bitmap("HORN")
gfx.rabbits_foot = dsb_get_bitmap("RABBITS_FOOT")
gfx.key_gold = dsb_get_bitmap("KEY_GOLD")
gfx.key_metal = dsb_get_bitmap("KEY_METAL")
gfx.lockpicks = dsb_get_bitmap("LOCKPICKS")
gfx.mirror = dsb_get_bitmap("MIRROR")
gfx.magnifier = dsb_get_bitmap("MAGNIFIER")
gfx.ring = dsb_get_bitmap("RING")
gfx.staff_conduit = dsb_get_bitmap("STAFF_CONDUIT")
gfx.staff_conduit.y_off = 4
gfx.staff_serpent = dsb_get_bitmap("STAFF_SERPENT")
gfx.staff_serpent.y_off = 4
gfx.staff_ornate = dsb_get_bitmap("STAFF_ORNATE")
gfx.staff_plain = dsb_get_bitmap("STAFF_PLAIN")

gfx.torch = dsb_get_bitmap("TORCH")
gfx.wand = dsb_get_bitmap("WAND")
gfx.firestaff = dsb_get_bitmap("FIRESTAFF")
gfx.firestaff_gem = dsb_get_bitmap("FIRESTAFF_GEM")
gfx.dragon_spit = dsb_get_bitmap("DRAGON_SPIT")

gfx.flamitt = dsb_get_bitmap("FLAMITT")
gfx.rope = dsb_get_bitmap("ROPE")
gfx.mace = dsb_get_bitmap("MACE")
gfx.mace.x_off = -8
gfx.morningstar = dsb_get_bitmap("MORNINGSTAR")
gfx.morningstar.x_off = -8
gfx.stick = dsb_get_bitmap("STICK")
gfx.vorpal = dsb_get_bitmap("VORPAL")
gfx.vorpal.x_off = -8
gfx.sword = dsb_get_bitmap("SWORD")
gfx.sword.x_off = -8
gfx.sword_flying_away = dsb_get_bitmap("SWORD_FLYING_AWAY")
gfx.sword_flying_toward = dsb_get_bitmap("SWORD_FLYING_TOWARD")
gfx.sword_flying_side = dsb_get_bitmap("SWORD_FLYING_SIDE")
gfx.axe = dsb_get_bitmap("AXE")
gfx.axe.x_off = -4
gfx.axe.y_off = 8
gfx.axe_flying = dsb_get_bitmap("AXE_FLYING")
dsb_animate(gfx.axe_flying, 4, 6)
gfx.axe_flying_side = dsb_get_bitmap("AXE_FLYING_SIDE")
dsb_animate(gfx.axe_flying_side, 4, 6)
gfx.club = dsb_get_bitmap("CLUB")
gfx.club_flying = dsb_get_bitmap("CLUB_FLYING")
dsb_animate(gfx.club_flying, 4, 6)
gfx.club_flying_side = dsb_get_bitmap("CLUB_FLYING_SIDE")
dsb_animate(gfx.club_flying_side, 4, 6)
gfx.club_stone = dsb_get_bitmap("CLUB_STONE")
gfx.club_stone_flying = dsb_get_bitmap("CLUB_STONE_FLYING")
dsb_animate(gfx.club_stone_flying, 4, 6)
gfx.club_stone_flying_side = dsb_get_bitmap("CLUB_STONE_FLYING_SIDE")
dsb_animate(gfx.club_stone_flying_side, 4, 6)

gfx.ashes = dsb_get_bitmap("ASHES")
gfx.bones = dsb_get_bitmap("BONES")
gfx.bones.x_off = 12
gfx.boulder = dsb_get_bitmap("BOULDER")
gfx.corbum = dsb_get_bitmap("CORBUM")
gfx.fulbomb = dsb_get_bitmap("FULBOMB")
gfx.venbomb = dsb_get_bitmap("VENBOMB")
gfx.neck_silver = dsb_get_bitmap("MOONSTONE")
gfx.neck_gold = dsb_get_bitmap("GEMOFAGES")
gfx.neck_black = dsb_get_bitmap("THEHELLION")
gfx.flask_empty = dsb_get_bitmap("FLASK_EMPTY")
gfx.flask_full = dsb_get_bitmap("FLASK_FULL")
gfx.apple = dsb_get_bitmap("APPLE")
gfx.bread = dsb_get_bitmap("BREAD")
gfx.cheese = dsb_get_bitmap("CHEESE")
gfx.corn = dsb_get_bitmap("CORN")
gfx.drumstick = dsb_get_bitmap("DRUMSTICK")
gfx.shank = dsb_get_bitmap("SHANK")
gfx.s_slice = dsb_get_bitmap("SSLICE")
gfx.worm_round = dsb_get_bitmap("WROUND")
gfx.d_steak = dsb_get_bitmap("DSTEAK")
gfx.waterskin_full = dsb_get_bitmap("WATERSKIN_FULL")
gfx.waterskin_empty = dsb_get_bitmap("WATERSKIN_EMPTY")
gfx.compass = dsb_get_bitmap("COMPASS")
gfx.chest = dsb_get_bitmap("CHEST")
gfx.scroll = dsb_get_bitmap("SCROLL")
gfx.rock = dsb_get_bitmap("ROCK")
gfx.magicbox_blue = dsb_get_bitmap("MAGICBOX_BLUE")
gfx.magicbox_green = dsb_get_bitmap("MAGICBOX_GREEN")

gfx.blueshield = dsb_get_bitmap("BLUESHIELD")
gfx.spellshield = dsb_get_bitmap("SPELLSHIELD")
gfx.fireshield = dsb_get_bitmap("FIRESHIELD")

gfx.chest_inside = dsb_get_bitmap("CHEST_INSIDE")
gfx.scroll_inside = dsb_get_bitmap("SCROLL_INSIDE")

gfx.scroll_font = dsb_get_font("SCROLLFONT")
gfx.wall_font = dsb_get_font("WALLFONT")

gfx.poisoned = dsb_get_bitmap("POISONED")
gfx.poisoned.x_off = 16
gfx.poisoned.y_off = 106

gfx.frontdoor_bkg = dsb_get_bitmap("FRONTDOOR")
gfx.frontdoor_left = dsb_get_bitmap("FRONTDOOR_DOORL")
gfx.frontdoor_right = dsb_get_bitmap("FRONTDOOR_DOORR")

gfx.inter_blank = dsb_get_bitmap("INTER_BLANK")
gfx.inter_foodwater = dsb_get_bitmap("INTER_FOODWATER")
gfx.inter_objlook = dsb_get_bitmap("INTER_OBJLOOK")

gfx.port_alex = dsb_get_bitmap("PORT_ALEX")
gfx.port_azizi = dsb_get_bitmap("PORT_AZIZI")
gfx.port_boris = dsb_get_bitmap("PORT_BORIS")
gfx.port_chani = dsb_get_bitmap("PORT_CHANI")
gfx.port_daroou = dsb_get_bitmap("PORT_DAROOU")
gfx.port_elija = dsb_get_bitmap("PORT_ELIJA")
gfx.port_gando = dsb_get_bitmap("PORT_GANDO")
gfx.port_gothmog = dsb_get_bitmap("PORT_GOTHMOG")
gfx.port_halk = dsb_get_bitmap("PORT_HALK")
gfx.port_hawk = dsb_get_bitmap("PORT_HAWK")
gfx.port_hissssa = dsb_get_bitmap("PORT_HISSSSA")
gfx.port_iaido = dsb_get_bitmap("PORT_IAIDO")
gfx.port_leif = dsb_get_bitmap("PORT_LEIF")
gfx.port_leyla = dsb_get_bitmap("PORT_LEYLA")
gfx.port_linflas = dsb_get_bitmap("PORT_LINFLAS")
gfx.port_mophus = dsb_get_bitmap("PORT_MOPHUS")
gfx.port_nabi = dsb_get_bitmap("PORT_NABI")
gfx.port_sonja = dsb_get_bitmap("PORT_SONJA")
gfx.port_stamm = dsb_get_bitmap("PORT_STAMM")
gfx.port_syra = dsb_get_bitmap("PORT_SYRA")
gfx.port_tiggy = dsb_get_bitmap("PORT_TIGGY")
gfx.port_wutse = dsb_get_bitmap("PORT_WUTSE")
gfx.port_wuuf = dsb_get_bitmap("PORT_WUUF")
gfx.port_zed = dsb_get_bitmap("PORT_ZED")

gfx.port_airwing = dsb_get_bitmap("PORT_AIRWING")
gfx.port_algor = dsb_get_bitmap("PORT_ALGOR")
gfx.port_aroc = dsb_get_bitmap("PORT_AROC")
gfx.port_buzzzzz = dsb_get_bitmap("PORT_BUZZZZZ")
gfx.port_dema = dsb_get_bitmap("PORT_DEMA")
gfx.port_deth = dsb_get_bitmap("PORT_DETH")
gfx.port_gnatu = dsb_get_bitmap("PORT_GNATU")
gfx.port_itza = dsb_get_bitmap("PORT_ITZA")
gfx.port_kazai = dsb_get_bitmap("PORT_KAZAI")
gfx.port_lana = dsb_get_bitmap("PORT_LANA")
gfx.port_leta = dsb_get_bitmap("PORT_LETA")
gfx.port_lor = dsb_get_bitmap("PORT_LOR")
gfx.port_mantia = dsb_get_bitmap("PORT_MANTIA")
gfx.port_necro = dsb_get_bitmap("PORT_NECRO")
gfx.port_petal = dsb_get_bitmap("PORT_PETAL")
gfx.port_plague = dsb_get_bitmap("PORT_PLAGUE")
gfx.port_skelar = dsb_get_bitmap("PORT_SKELAR")
gfx.port_slogar = dsb_get_bitmap("PORT_SLOGAR")
gfx.port_sting = dsb_get_bitmap("PORT_STING")
gfx.port_talon = dsb_get_bitmap("PORT_TALON")
gfx.port_toadrot = dsb_get_bitmap("PORT_TOADROT")
gfx.port_tula = dsb_get_bitmap("PORT_TULA")
gfx.port_tunda = dsb_get_bitmap("PORT_TUNDA")
gfx.port_ven = dsb_get_bitmap("PORT_VEN")

gfx.inventory_background = dsb_get_bitmap("INVENTORY")
gfx.top_hands = dsb_get_bitmap("TOP_HANDS")
gfx.top_port = dsb_get_bitmap("TOP_PORT")
gfx.top_dead = dsb_get_bitmap("TOP_DEAD")

base_mouth_icon = gfx.icons[205]
gfx.mouth_chewing = dsb_get_bitmap("MOUTH_CHEWING")
dsb_animate(gfx.mouth_chewing, 4, 3)

gfx.icon_save = dsb_get_bitmap("ICON_SAVE")
gfx.icon_zzz = dsb_get_bitmap("ICON_ZZZ")
gfx.box_sel = dsb_get_bitmap("BOX_SEL")
gfx.box_sel.x_off = -2
gfx.box_sel.y_off = -2
gfx.box_boost = dsb_get_bitmap("BOX_BOOST")
gfx.box_boost.x_off = -2
gfx.box_boost.y_off = -2
gfx.box_hurt = dsb_get_bitmap("BOX_HURT")
gfx.box_hurt.x_off = -2
gfx.box_hurt.y_off = -2

gfx.actionbutton = dsb_get_bitmap("ACTIONBUTTON")
gfx.choose_method = dsb_get_bitmap("CHOOSE_METHOD")
gfx.blank_attack = gfx.icons[201]
gfx.magic = dsb_get_bitmap("MAGIC")
gfx.move_arrows = dsb_get_bitmap("ARROWS")
gfx.move_activearrows = dsb_get_bitmap("ACTIVEARROWS")
gfx.monster_damaged = dsb_get_bitmap("DAMAGE")
gfx.damage_bar = dsb_get_bitmap("BAR_DAMAGE")
gfx.damage_full = dsb_get_bitmap("FULL_DAMAGE")

snd.buzz = dsb_get_sound("BUZZ")
snd.click = dsb_get_sound("CLICK")
snd.dink = dsb_get_sound("DINK")
snd.doorclank = dsb_get_sound("DOORCLANK")
snd.explosion = dsb_get_sound("BOOM")
snd.gulp = dsb_get_sound("GULP")
snd.horn_of_fear = dsb_get_sound("HORN_OF_FEAR")
snd.scream = dsb_get_sound("SCREAM")
snd.swish = dsb_get_sound("SWISH")
snd.thud = dsb_get_sound("THUD")
snd.walloof = dsb_get_sound("WALLOOF")
snd.warcry = dsb_get_sound("WARCRY")
snd.zap = dsb_get_sound("ZAP")
snd.oof = {
    [0] = dsb_get_sound("OOF1"),
    [1] = dsb_get_sound("OOF2"),
    [2] = dsb_get_sound("OOF3"),
    [3] = dsb_get_sound("OOF4")
}

snd.step_dragon = dsb_get_sound("STEP_DRAGON")
snd.step_flying = dsb_get_sound("STEP_FLYING")
snd.step_footstep = dsb_get_sound("STEP_FOOTSTEP")
snd.step_knight = dsb_get_sound("STEP_KNIGHT")
snd.step_scuffle = dsb_get_sound("STEP_SCUFFLE")
snd.step_skeleton = dsb_get_sound("STEP_SKELETON")
snd.step_wet = dsb_get_sound("STEP_WET")

snd.monster_haa = dsb_get_sound("MONSTER_HAA")
snd.monster_oowooah = dsb_get_sound("MONSTER_OOWOOAH")
snd.monster_rockattack = dsb_get_sound("MONSTER_ROCKATTACK")
snd.monster_roar = dsb_get_sound("MONSTER_ROAR")
snd.monster_screech = dsb_get_sound("MONSTER_SCREECH")
snd.monster_snarl = dsb_get_sound("MONSTER_SNARL")
snd.monster_squeak = dsb_get_sound("MONSTER_SQUEAK")
snd.monster_wetattack = dsb_get_sound("MONSTER_WETATTACK")
snd.monster_wormgrowl = dsb_get_sound("MONSTER_WORMGROWL")

base_eat_sound = snd.gulp
base_hit_sound = snd.thud
base_throw_sound = snd.swish
base_physical_attack_sound = snd.swish
base_wall_hit_sound = snd.walloof
base_warcry_sound = snd.warcry