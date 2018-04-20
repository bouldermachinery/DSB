--- throwtrolin.lua ---
-- This is an importable archetype of a trolin that will throw its club,
-- and change to look like one without a club. This is accomplished with the
-- on_succeed_attack_* event, and group_type ensures monster groups are
-- preserved.
--
-- For a better documented example of importable archetypes themselves,
-- see moneybox.lua.

gfx[ROOT_NAME .. "_front"] = dsb_get_bitmap("TROLIN_NOCLUB_FRONT")
gfx[ROOT_NAME .. "_back"] = dsb_get_bitmap("TROLIN_NOCLUB_BACK")
gfx[ROOT_NAME .. "_side"] = dsb_get_bitmap("TROLIN_NOCLUB_SIDE")
gfx[ROOT_NAME .. "_attack"] = dsb_get_bitmap("TROLIN_NOCLUB_ATTACK")

function swap_to_other(arch, id)
	dsb_qswap(id, arch.swap_to)
end

function pick_up_obj_pos(actually_grab, want_arch, lev, x, y, d)
	local t = dsb_fetch(lev, x, y, d)
	if (t) then
		local i
		for i in pairs(t) do
			if (not dsb_get_flystate(t[i])) then
				local t_arch = dsb_find_arch(t[i])
				if (t_arch == obj[want_arch]) then
					if (actually_grab) then
						dsb_delete(t[i])
					end
					return true
				end
			end
		end
	end
	return false
end

function grab_ground_club(arch, id, grab)
	local lev, x, y, l = dsb_get_coords(id)
	
	if (l == CENTER) then
		fd = dsb_get_facedir(id)
		for dv = fd, fd+3 do
			local d = fd % 4
			if (pick_up_obj_pos(grab, "club", lev, x, y, d)) then
				return true
			end 
		end
		return false
	end
	
	if (pick_up_obj_pos(grab, "club", lev, x, y, l)) then
		return true
	end 
end

-- Invoked via arch.on_move. This will pick up a club in a
-- square the monster steps into.
function pick_up_club_step(arch, id, group_leader)
	monster_step(arch, id, group_leader)
	if (grab_ground_club(arch, id, true)) then
		dsb_qswap(id, arch.swap_to)	
	end	
end

-- Invoked via arch.on_monster_shift. This will pick up a
-- club if the monster shifts around.
function pick_up_club_step(arch, id, group_leader)
	if (grab_ground_club(arch, id, true)) then
		dsb_qswap(id, arch.swap_to)	
	end	
end

-- Invoked via arch.on_attack_close. If the monster is about
-- to attack, it will try to pick up a club first.
function pick_up_club_bash(arch, id, data)
	if (grab_ground_club(arch, id, true)) then
		dsb_qswap(id, arch.swap_to)
		arch = obj[arch.swap_to]
	end
	monster_attack(arch, id, data)
end

-- Invoked via arch.ranged_attack_check, called by
-- beginrangedattack in monster_ai.lua. This will verify
-- someone's ability to shoot.
function whohasaclub(self, id, why_shoot)
	if (grab_ground_club(arch, id, false)) then
		use_exvar(id)
		exvar[id].club = true
		return true
	end
	
	return false
end

-- If there's a club on the ground, throw it. Otherwise, just
-- a dummy function.
function noclub_ranged_attack(self, id, why_shoot)
	use_exvar(id)
	if (exvar[id].club) then
		exvar[id].club = nil
		if (grab_ground_club(arch, id, true)) then
			return (monster_missile(self, id, why_shoot))
		end
	end
	return false
end

obj[ROOT_NAME] = clone_arch(obj.trolin, {
	has_missile=true,
	on_attack_ranged=monster_missile,
	on_succeed_attack_ranged=swap_to_other,
	swap_to=ROOT_NAME .. "_noclub",
	should_attack_ranged=onefourthranged, 
	missile_type="club",
	missile_power=72,
	dont_waste_ammo=true,
	attack_sound_ranged=snd.swish
} )

obj[ROOT_NAME .. "_noclub"] = clone_arch(obj.trolin, {
	base_power=20,
	front=gfx[ROOT_NAME .. "_front"],
	side=gfx[ROOT_NAME .. "_side"],
	back=gfx[ROOT_NAME .. "_back"],
	attack = gfx[ROOT_NAME .. "_attack"],
	on_move=pick_up_club_step,
	on_attack_close=pick_up_club_bash,
	on_attack_ranged=noclub_ranged_attack,
	on_monster_shift=pick_up_club_shift,
	swap_to=ROOT_NAME,
	ranged_attack_check=whohasaclub,
	should_attack_ranged=onefourthranged,
	missile_type="club",
	missile_power=72,
	attack_sound_ranged=snd.swish,
	on_die=false
} )