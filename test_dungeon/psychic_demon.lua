--- psychic_demon.lua ---
-- This is an importable archetype of a demon that shoots bolts that
-- drain wisdom and mana, and kill party members when their wisdom is 0.
-- It serves as a demonstration of how to create new spell projectiles
-- that do various things, like punish party members' stats.
-- 
-- For a better documented example of importable archetypes themselves,
-- see moneybox.lua. The documentation in this file is concerned only with
-- demonstrating how to make a demon with a new projectile attack.

-- The psychic attack has exploded somewhere. See if the party is here,
-- and if it is, drain the members' mana and wisdom, and kill them if
-- they have no wisdom left.
function psychic_explode_square(lev, xc, yc, range, dmgpower, hit_type)
	local p_at = dsb_party_at(lev, xc, yc)
	if (p_at) then
		local base_dmg = calc_fireball_damage(range, dmgpower)
		local ppos
		for ppos=0,3 do
			local who = dsb_ppos_char(ppos)
			if (valid_and_alive(who)) then
				-- Compute damage resitance based on Anti-Magic and
				-- then damage the character's mana by the amount of
				-- damage done. Reduced because this formula is suited
				-- for attacks based on health, and mana is generally lower.
				local dmg = magic_damage(ppos, who, base_dmg, true)
				do_damage(ppos, who, MANA, dmg * 0.75)
				
				-- Damage the character's wisdom, and kill when
				-- it gets too low. The damage value works pretty
				-- well as-is because all stats are 10x internally.
				local wis = dsb_get_stat(who, STAT_WIS)
				wis = wis - dmg
				if (wis < 10) then
					dsb_set_bar(who, HEALTH, 0)
				else
					dsb_set_stat(who, STAT_WIS, wis)
				end
			end
	    end
	end
end

-- The psychic projectile. It is a fairly standard spell, only
-- with our new explosion function.
obj[ROOT_NAME .. "_projectile"] = {
    name="PSYCHIC BLAST",
    type="THING",
    class="SPELL",
    renderer_hack="POWERSCALE",
	flying_only=true,
    icon=gfx.icons[197],
	dungeon=gfx.lightning,
	flying_away=gfx.lightning,
	flying_toward=gfx.lightning,
	flying_side=gfx.lightning_side,	
	missile_type=MISSILE_MAGIC,
	on_impact=spell_explosion,
	on_location_explode=psychic_explode_square,
	explode_into="zap",
	explode_sound=snd.zap,
	no_shade = true
}

-- Clone a CSB demon, only give it our new projectile
obj[ROOT_NAME] = clone_arch(obj.demon2, {
	missile_type = ROOT_NAME .. "_projectile",
	door_opener = false
} )