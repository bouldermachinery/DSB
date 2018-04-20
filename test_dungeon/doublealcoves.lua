--- doublealcoves.lua ---
-- This is an example how to create an importable archetype,
-- that any DSB dungeon can then load via dsb_import_arch(file, root_name).
-- All you have to distribute is this single Lua file, and any
-- bitmaps that the new object needs.
--
-- The names used by the data structures created here should be
-- dynamically generated, using the ROOT_NAME variable that
-- will be defined by the engine when this file is parsed.
-- This helps to prevent name collisions if the dungeon designer
-- wants to use several similarly named items.

-- This example is rather simple because most of the support for more
-- than one alcove on the same wall is already part of the base code.
-- If you want more detailed examples of how to create an importable
-- archetype, look at moneybox.lua and throwtrolin.lua.

-- Load any graphics that your custom object will need.
-- Temporary bitmaps should be declared local so the garbage collector
-- will be able to take care of them.
--
gfx[ROOT_NAME .. "_front_top"] = dsb_get_bitmap("ALCOVE_SHORT_FRONT")
gfx[ROOT_NAME .. "_front_top"].y_off = -40
gfx[ROOT_NAME .. "_front_bottom"] = dsb_clone_bitmap(gfx.alcove_short_front_top)
gfx[ROOT_NAME .. "_front_bottom"].y_off = 72
gfx[ROOT_NAME .. "_side_top"] = dsb_get_bitmap("ALCOVE_SHORT_SIDE_TOP")
gfx[ROOT_NAME .. "_side_top"].x_off = -4
gfx[ROOT_NAME .. "_side_top"].y_off = -26
gfx[ROOT_NAME .. "_side_bottom"] = dsb_get_bitmap("ALCOVE_SHORT_SIDE_BOTTOM")
gfx[ROOT_NAME .. "_side_bottom"].x_off = -4
gfx[ROOT_NAME .. "_side_bottom"].y_off = 58

-- Define a function to make the short alcoves respond properly to being
-- clicked. The actual take and release functions are part of the base
-- code, we just need to invoke them properly.
function short_alcove_click(self, id, what, x, y)
	-- Objects can make use of their exact click coordinates, if you want.
	--dsb_write({255,255,255}, "YOU CLICKED AT " .. x .. " " .. y)
	
 	if (what) then
 		wallitem_take_object(self, id, what)
 	else
 		wallitem_release_object(self, id, what)
 	end	
end

--
-- Declare the new archs into the object table, using the
-- dynamic name assigned by the dungeon designer.
--
obj[ROOT_NAME .. "_top"] = {
	type="WALLITEM",
	class="ALCOVE",
	front=gfx[ROOT_NAME .. "_front_top"],
	side=gfx[ROOT_NAME .. "_side_top"],
	on_click=short_alcove_click,
	draw_contents=true
}

--
-- The bottom is more or less a clone of the top, just with
-- different bitmaps.
--
obj[ROOT_NAME .. "_bottom"] = clone_arch(obj[ROOT_NAME .. "_top"], {
	front=gfx[ROOT_NAME .. "_front_bottom"],
	side=gfx[ROOT_NAME .. "_side_bottom"]
} )

