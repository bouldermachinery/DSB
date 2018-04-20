--- poisondart.lua ---
-- This is an importable archetype of a poison dart that actually
-- poisons the monster. It serves as a demonstration about how to
-- create temporary objects that call functions, as well as how to
-- use on_melee_damage_monster hooks. 
--
-- For a better documented example of importable archetypes themselves,
-- see moneybox.lua. The documentation in this file is concerned only with
-- demonstrating how to make a poison dart that actually poisons.

-- This function is executed when the poison dart strikes a monster.
-- The function should return false so that the normal impact processing
-- is done after this function returns. on_impact functions that return
-- true override the normal impact processing.
function poison_dart_impact(self, id, hit_what, hit_ppos)
	if (hit_what) then
		local hit_arch = dsb_find_arch(hit_what)
		if (hit_arch.type == "MONSTER") then
			do_poisoning(hit_arch, hit_what)
		end
	end
	return false
end

-- Poison the monster after a successful melee hit, too.
function poison_dart_melee_damage(arch, what, ppos, who, monster_id, hit_power)
	do_poisoning(dsb_find_arch(monster_id), monster_id) 
end

-- Spawns the temporary object that actually does the poisoning (inside of
-- the monster) and sends it a message to set the process in motion.
function do_poisoning(arch, id)
	if (arch.anti_poison < 180) then
		local fid = dsb_spawn("function_caller", IN_OBJ, id, VARIABLE, 0)
		exvar[fid] = {
			m_a = "do_poison_damage",
			victim = id,
			dttl = dsb_rand(12, 22)
		} 
		dsb_msg(12, fid, M_ACTIVATE, 0)
	end
end


-- This is the function invoked by the function_caller that is inside
-- of the monster. It checks to see if it's still inside of its victim,
-- and self-destructs if it's not (the monster must have died), otherwise
-- do some poison damage to its victim.
function do_poison_damage(id, lev, xc, yc, tile, data, sender)
	if (lev == IN_OBJ) then
		if (xc == exvar[id].victim) then
			local victim = exvar[id].victim
			local victim_arch = dsb_find_arch(victim)
			
			-- Do random damage between 1 and 3, modified by poison resist.
			damage_a_monster(victim, victim_arch, "anti_poison", dsb_rand(1, 3))
			
			-- Decrease the ttl, and send another message
			-- if we're still alive.
			local nttl = exvar[id].dttl - 1
			if (nttl > 0) then
				exvar[id].dttl = nttl
				dsb_msg(12, id, M_ACTIVATE, 0)
				return
			end
		end
	end
	
	dsb_msg(1, id, M_DESTROY, 0)
end

-- Start with the basic dart, and add properties to make the poisoning work.
obj[ROOT_NAME] = clone_arch(obj.dart, {
	on_impact = poison_dart_impact,
	on_melee_damage_monster = poison_dart_melee_damage		
} )