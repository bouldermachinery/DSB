-- Inventory info base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- If you want to override these settings, you should
-- do so in your own dungeon's startup.lua instead.

-- This controls how the inventory looks, and what the slots
-- are named. Drastic alterations to this structure are possible,
-- but will probably require drastic alterations to a lot of
-- other code to make the game still function properly.

inventory_info = {
    [INV_R_HAND] =	{ name = "r_hand",
		x = 124, y = 106, icon = gfx.icons[214], hurt_icon = gfx.icons[215] },
	[INV_L_HAND] =	{ name = "l_hand",
		x = 12, y = 106, icon = gfx.icons[212], hurt_icon = gfx.icons[213] },
	[INV_HEAD] =    { name = "head",
	    x = 68, y = 52, icon = gfx.icons[216], hurt_icon = gfx.icons[217] },
	[INV_TORSO] =   { name = "torso",
	    x = 68, y = 92, icon = gfx.icons[218], hurt_icon = gfx.icons[219] },
	[INV_LEGS] =    { name = "legs",
	    x = 68, y = 132, icon = gfx.icons[220], hurt_icon = gfx.icons[221] },
	[INV_FEET] =    { name = "feet",
	    x = 68, y = 172, icon = gfx.icons[222], hurt_icon = gfx.icons[223] },
	[INV_NECK] =    { name = "neck", x = 12, y = 66, icon = gfx.icons[208] },
	[INV_POUCH] =   { name = "pouch", x = 12, y = 146, icon = gfx.icons[209] },
	[INV_POUCH2] =  { name = "pouch", x = 12, y = 180 },
	[INV_QUIVER] =  { name = "quiver", x = 124, y = 146, icon = gfx.icons[210] },
	[INV_QUIV2] =   { name = "quiver", x = 158, y = 146 },
	[INV_QUIV3] =   { name = "quiver", x = 124, y = 180 },
	[INV_QUIV4] =   { name = "quiver", x = 158, y = 180 },
	[INV_PACK] =    { name = "pack", x = 132, y = 66, icon = gfx.icons[211], take_all = true },
	
	main_background = nil,
	background = gfx.inventory_background,
			
	subrenderer = { x = 200, y = 104 },
	
	selection_box = gfx.box_sel,
	boost_box = gfx.box_boost,
	hurt_box = gfx.box_hurt,

	eye = { x = 24, y = 26, icon = gfx.icons[202], look_icon = gfx.icons[203] },
	mouth = { x = 112, y = 26, icon = base_mouth_icon },
	save = { x = 346, y = 4, icon = gfx.icon_save },
	sleep = { x = 374, y = 4, icon = gfx.icon_zzz },
	exitbox = { x = 420, y = 6, icon = nil },
				
	stat_minimum = 0,			
	stat_maximum = 9990,
	
	top_hands = gfx.top_hands,
	top_port = gfx.top_port,
	top_dead = gfx.top_dead,
	
	top_row = {	{INV_L_HAND, INV_R_HAND},
				{INV_L_HAND, INV_R_HAND},
				{INV_L_HAND, INV_R_HAND},
				{INV_L_HAND, INV_R_HAND} },	
				
				
	injurable_zones = { INV_L_HAND, INV_R_HAND,
		INV_HEAD, INV_TORSO, INV_LEGS, INV_FEET },
		
	-- See injure_zones in damage.lua to see how this works
	highest_random_injury = 7,
	
	-- Item classes that are usually used in the hand. Important
	-- for making item properties (currently, only cursing) work right.
	hand_classes = { CLUB = true, MAGIC = true, MISC = true,
		SHIELD = true, SHOOTING = true, STAFF = true, WEAPON = true }
		
}
-- set up the rest of the pack slots
for x=INV_PACK+1, MAX_INV_SLOTS-1 do
	local v = x - (INV_PACK+1)
	local mx = 166 + 34*(v % 8)
	local my = 32 + 34*(math.floor(v / 8))
	inventory_info[x] = { name = "pack", x = mx, y = my, take_all = true }
end