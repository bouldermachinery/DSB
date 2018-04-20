--- quiver.lua ---
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

-- This example is rather simple because most of the support for quivers
-- is already part of the base code. If you want a more detailed
-- example of how to add a new container object, look at moneybox.lua.

-- Load any graphics that your custom object will need.
-- Temporary bitmaps should be declared local so the garbage collector
-- will be able to take care of them.
--
gfx[ROOT_NAME] = dsb_get_bitmap("QUIVER")
gfx[ROOT_NAME .. "_icon"] = dsb_get_bitmap("QUIVER_ICON")
gfx[ROOT_NAME .. "_inside"] = dsb_get_bitmap("QUIVER_INSIDE")

-- Define a function needed by the quiver to verify that
-- what you're putting into it is indeed an arrow.
function quiver_zone_check(arch, id, putting_in, zone)
	if (putting_in) then
		local in_arch = dsb_find_arch(putting_in)
		if (in_arch.fit_quiver and in_arch.missile_type == MISSILE_ARROW) then
			return true
		end
	end
	
	return false
end

--
-- Declare the new arch into the object table, using the
-- dynamic name assigned by the dungeon designer.
--
obj[ROOT_NAME] = {
	name="QUIVER",
	type="THING",
	class="CONTAINER",
	mass=11,
	
	dungeon=gfx[ROOT_NAME],
	icon=gfx[ROOT_NAME .. "_icon"],
	alt_icon=gfx[ROOT_NAME .. "_alticon"],
	inside_gfx=gfx[ROOT_NAME .. "_inside"],
	
	-- It goes in the first quiver slot
	fit_sheath = true,
	
	-- Most of the support for quiver-like objects is already in the base
	-- code. All you have to do to enable it is to set this flag.
	ammo_holder = true,
	
	-- To be able to shoot with this container in the left hand, set
	-- this flag to true. Right now the left hand still has to be holding
	-- the ammo directly. 
	ammo_holder_hand = false,
	
	-- This is the same subrenderer as the chest, with 8 objects arranged
	-- in the same fashion.
	subrenderer = basic_8_object_subrenderer,
	
	-- The objzone_check controls which items are allowed to go into
	-- the container.
	objzone_check = quiver_zone_check,
	
	-- Only holds 8 items
	capacity = 8,
		
	-- Throwing the quiver itself isn't effective
	max_throw_power=30
}


