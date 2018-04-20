-- GUI info base config script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- If you want to override these settings, you should
-- do so in your own dungeon's startup.lua instead.

-- This controls how the GUI looks at the high level.
-- You will need to change the lower-level rendering functions found
-- in render.lua to have more control over what is actually drawn.

gui_info = {

	viewport = {
		x = 0,
		y = 86
	},
	
	portraits = {
		x = 0,
		y = 20
	},
		
	guy_icons = {
		x = 560,
		y = 20
	},
	
	console = {
		x = 0,
		y = 366,
		lines = 4
	},
	
	current_item = {
		x = 466,
		y = 86,
		-- By default, DSB will simply draw the text at the specified
		-- location. However, if w and h are defined for current_item,
		-- a bitmap will be created and sys_render_current_item_text
		-- will be called, handling it like many of the other GUI objects.
		-- w = 174,
		-- h = 20
	},
	
	methods = {
		x = 456,
		y = 174,
		w = 186,
		h = 90
	},
	
	magic = {
		x = 466,
		y = 104,
		w = 174,
		h = 70
	},
	
	movement = {
		x = 466,
		y = 264,
		w = 174,
		h = 94
	}	
}
