--- multivexirk.lua ---
-- This is an importable archetype of a vexirk whose attack bitmap changes
-- depending on the spell chosen. This is accomplished with the
-- AI_ATTACK_BMP AI message: dsb_ai(id, AI_ATTACK_BMP, bmpnumber), where
-- bmpnumber is matching an index in the arch.attack table.
--
-- For a better documented example of importable archetypes themselves,
-- see moneybox.lua. The documentation in this file is concerned only with
-- demonstrating how to use multiple attack bitmaps.

gfx[ROOT_NAME .. "_attack_red"] = dsb_get_bitmap("MULTIVEXIRK_ATTACK_RED")
gfx[ROOT_NAME .. "_attack_green"] = dsb_get_bitmap("MULTIVEXIRK_ATTACK_GREEN")
gfx[ROOT_NAME .. "_attack_purple"] = dsb_get_bitmap("MULTIVEXIRK_ATTACK_PURPLE")
gfx[ROOT_NAME .. "_attack_yellow"] = dsb_get_bitmap("MULTIVEXIRK_ATTACK_YELLOW")

-- This function is called via arch.sel_attack_close, which is called by the
-- base code whenever the monster is about to make a close attack.
-- See base/monster.lua for details.
--
-- To give the monster the ability to have different attack methods that
-- do different things, rather simply look different, all you have to do is
-- return a new attack type. The base code will use that value as the monster's
-- attack type instead of arch.attack_type.
--
-- Note for those who really want to hack around with things:
-- You can also manipulate values in the arch itself to a degree, but be careful
-- because you're really changing the value for all instances! Thus, it's only
-- really safe to change values that are only used by attack methods, so they
-- will always be touched by this function before the instance in question
-- tries to use them. Things like the act_rate, quickness, etc. are off-limits.
--
-- In this case, set the attack bitmap to be the close attack bitmap, and have
-- a random chance of doing fire damage instead of magical damage.
function multivexirk_close(arch, id, back_tile)
	dsb_ai(id, AI_ATTACK_BMP, 4)
	
	if (dsb_rand(0, 2) == 0) then
	    return ATTACK_ANTI_FIRE
	end
end

-- There's also the option to have an arch.sel_attack_ranged, but it's
-- not used by this monster-- it's usually more useful to specify an
-- attack bitmap with various missile animations, as seen below.
--[[
function multivexirk_ranged(arch, id, why_shoot)
	return nil
end
]]

-- This function is invoked via arch.missile_type. It is a wrapper of
-- of vexirk_missiles from the base code, but this version selects a
-- missile and also returns a second parameter specifying what to change
-- the attack bitmap to.
-- See base/monster.lua to see where this is actually used.
function multivexirk_missiles(self, id, why_shoot)

	local vm = vexirk_missiles(self, id, why_shoot)

	if (vm == "poison_ohven" or vm == "poison_desven") then
	    return vm, 2
	elseif (vm == "zospell") then
	    return vm, 3
	else
		return vm, 1
	end
	
end

-- Now, define the object, using the dynamic name specified by the designer.
-- We'll start with a basic clone of a vexirk, and then specify a table of changes.
obj[ROOT_NAME] = clone_arch(obj.vexirk, {
    name="MULTI VEXIRK",

	-- Still use the base mon vexirk bitmaps for anything but attacking...
	front=gfx.vexirk2_front,
	side=gfx.vexirk2_side,
	back=gfx.vexirk2_back,
	
	-- ...but specify a table here, to give the different attack bitmaps.
	attack = {
		gfx[ROOT_NAME .. "_attack_red"],
		gfx[ROOT_NAME .. "_attack_green"],
		gfx[ROOT_NAME .. "_attack_purple"],
		gfx[ROOT_NAME .. "_attack_yellow"]
	},
	
	sel_attack_close=multivexirk_close,     -- This is new. See above.
	missile_type=multivexirk_missiles,      -- This is changed. See above.
} )