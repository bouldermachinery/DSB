--- new_magic.lua ---
-- This is an example how to modify the spell table in order to
-- create new spells and modify existing ones. Though this file
-- contains a few well-documented simple examples, the best way
-- to figure out how everything really works is to look around
-- inside DSB's spell system directly. Most of the code is
-- contained in magic.lua, but the function sys_spell_cast in
-- system.lua is also very important.

-- Spells are stored in the table as simply a number that 
-- specifies their runes. So, to move an existing spell to a new
-- rune value, simply copy the old value and then nil it out.
-- Let's move fireball from Ful Ir to Ful Kath.
spell[43] = spell[44]
spell[44] = nil

-- Adding new spells works the same way, you just have to create a
-- table that describes the spell. Here is a priest spell to create
-- water into a flask, assigned to Vi Bro Neta.
spell[254] = {
	class = CLASS_PRIEST,
	subskill = SKILL_POTIONS,
	difficulty = 1,
	idleness = 15,
	potion = "flask_water",
	cast = create_potion
}

-- Custom cast functions are, of course, doable. The parameters are the
-- table entry in spell (for convenience), the party position of the
-- caster, the character id of the caster, the power level, and the
-- casting skill. This spell announces the power level that it was
-- cast at, and then conjures a ful bomb of the appropriate power.
function announce_and_make_bomb(atype, ppos, who, pow, skill)
	local rune = powchar[pow]
	dsb_write(system_color, dsb_get_charname(who) .. " CASTS THE SPELL AT " .. rune .. " POWER")
	
	-- Summon the bomb into the party's square
	local lev, x, y, dir = dsb_party_coords()
	local newbomb = dsb_spawn("fulbomb", lev, x, y, dir)
	-- Make the power of the bomb the spell power
	exvar[newbomb] = { power = pow }
end

-- Now we assign the new spell to a set of runes in the table. Ful Gor works.
spell[46] = {
	class = CLASS_WIZARD,
	subskill = SKILL_FIRE,
	difficulty = 2,
	idleness = 20,
	cast = announce_and_make_bomb
}

