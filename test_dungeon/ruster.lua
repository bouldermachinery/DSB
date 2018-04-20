--- ruster.lua ---
-- This is an importable archetype of a ruster that actually rusts things.
-- It serves as a demonstration of how to extend a monster's attacks
-- with special_attack.
-- 
-- For a better documented example of importable archetypes themselves,
-- see moneybox.lua. The documentation in this file is concerned only with
-- demonstrating how to make a ruster that actually rusts.

-- Load the graphics
gfx.rust = dsb_get_bitmap("RUST")
gfx.rust_icon = dsb_get_bitmap("RUST_ICON")


-- This function is invoked via arch.special_attack by the base code
-- a specified percent of the time (in this case 40%) whenever the monster
-- scores a successful hit that does damage 
function rusting_attack(arch, id, ppos, char, dmg_type, dmg_amt)
	-- Start looking at a random place and then scan all locations
	local offset = dsb_rand(0, 5)
	for n=INV_R_HAND,INV_FEET do
		local loc = (n + offset) % 6
		local item = dsb_fetch(CHARACTER, char, loc, 0)
		if (item) then
			local item_arch = dsb_find_arch(item)
			for s in pairs(arch.rustable_objects) do
				if (obj[arch.rustable_objects[s]] == item_arch) then
					-- This object is on the list. Rust it!
					dsb_swap(item, arch.rust_to)
					-- Drop it to the floor if being worn
					if (loc > INV_L_HAND) then
						local lev, x, y = dsb_party_coords()
						dsb_move(item, lev, x, y, dsb_ppos_tile(ppos))
					end
					return
				end
			end
		end	
	end	 

end

-- Now, define the object, using the dynamic name specified by the designer.
-- We'll start with a basic clone of a ruster, and then specify a table of changes.
obj[ROOT_NAME] = clone_arch(obj.ruster, {
	-- Percent chance of rusting something on a hit
	special_chance = 40,	
	-- The function that actually does the rusting
	special_attack = rusting_attack,
	
	-- Objects that it will rust, pretty much every non-special weapon	
	rustable_objects= {
		"falchion", "sword", "sword_cursed",
		"rapier", "sabre", "sword_samurai", 
		"axe", "mace", "shield_buckler", "shield_small",
		"shield_large", "berzerker_helm", "berzerker_helm_csb",
		"helmet", "basinet", "casquencoif", "armet", "armet_cursed",
		"mail_aketon", "torsoplate", "torsoplate_cursed", 
		"leg_mail", "legplate", "legplate_cursed",
		"hosen", "footplate", "footplate_cursed"		    
	}, 
	
	-- What to rust objects into
	rust_to = "rust"
} )

-- Here's the rust itself, a boring object that doesn't do much.
obj.rust = clone_arch(obj.ashes, {
	name="RUST",
	icon=gfx.rust_icon,
	dungeon=gfx.rust
} )

