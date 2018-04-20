-- Monster AI base script
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- These functions are invoked via sys_ai_* calls in system.lua.
-- They control how monsters move and attack.

-- If you want to change how monsters behave, you can change the
-- variables referenced by these functions, create a special AI
-- for a given monster to be called here, or create entirely
-- new versions in your dungeon's startup.lua.

-- Constants to control wall belief
WALL_BELIEVE_NONE = 0
WALL_BELIEVE_PARTY = 1
WALL_BELIEVE_ALL = 2

-- Monster group types
GT_SELF_ONLY = 0
GT_BLUE_CLUB = 1
GT_WORMS = 2
GT_FAST_FLYERS = 3
GT_NONMATS = 4
GT_SLIMES = 5
GT_FLYING_EYES = 6
GT_RABID_BEASTS = 7
GT_WIZARDS = 8
GT_KNIGHTS = 9
GT_NONMAT_SPELLCASTERS = 10
GT_DEMONS = 11

-- args to sneakuponyousideways
SC_BACK_ROW_SPLIT = 0
SC_BOTH_ROWS_SPLIT = 1
SC_BREAK_SIDEWAYS = 2
SC_BREAK_FRONTWARD = 3

function ai_monster(id, sight)
	local mon_arch = dsb_find_arch(id)

	-- If the monster has a special AI, call that instead
	if (mon_arch.ai_near) then
	    return (mon_arch.ai_near(id, sight))
	end
	
	return (default_ai_monster(id, sight))
end

function default_ai_monster(id, sight)
	local mon_arch = dsb_find_arch(id)
	local lev, x, y = dsb_get_coords(id)	
	local p_lev, p_x, p_y, p_face = dsb_party_coords()
	local face = dsb_get_facedir(id)
		
	local p_invis = dsb_get_gameflag(GAME_PARTY_INVIS)
	if (mon_arch.sees_invisible) then
		p_invis = false
	end
	
	local membs, team = dsb_ai_subordinates(id)
	local i
	for i in pairs(team) do
	    local tid = team[i].id
		if (not exvar[tid]) then exvar[tid] = { } end
		exvar[tid].mai_arrange = nil
		exvar[tid].mai_attack = nil
		exvar[tid].mai_missile = nil
		exvar[tid].mai_groupalign = nil
		exvar[tid].mai_suspend = nil
		exvar[tid].mai_counterattacked = nil
		exvar[tid].mai_attackdelay = nil
		exvar[tid].mai_nowake = nil
	end

	del_monster_target(id, x, y)
	update_monster_targetlist(id)
	
	decrement_and_delete(id, "mai_nogrouping", -1)
	decrement_and_delete(id, "mai_twoshot", -1)
	decrement_and_delete(id, "mai_leave_doors_alone", -1)
	decrement_and_delete(id, "mai_pounced", -1)
	
	local want_attack = true
	local door_buster = false
	local hunting_party = false
	
	local interval = dsb_ai(id, AI_TIMER, QUERY)
	local shortinterval
	
	-- As of DSB 0.58 I'm actually not sure if this is even needed any more...
	if (not interval) then
	    interval = mon_arch.act_rate
	    if (not interval) then interval = 10 end
	end
	
	shortinterval = sys_calc_shortinterval(interval)

	-- Introduce a short delay to make monster action not so deterministic
	if (dsb_rand(0, 3) == 0) then
		if (interval < 10) then
			dsb_ai(id, AI_TIMER, interval + 1)
		else
			dsb_ai(id, AI_TIMER, interval + dsb_rand(1, 3))
		end
	end
	
	local scan = { }
	local hazard = dsb_ai(id, AI_HAZARD, QUERY)
	if (not hazard) then
	    exvar[id].mai_hazcnt = nil
	end
	
	local fear = dsb_ai(id, AI_FEAR, QUERY)
	if (fear) then
	    dsb_ai(id, AI_FEAR, -1)
	end
	local must_move = dsb_ai(id, AI_MOVE_NOW, QUERY)
	if (mon_arch.immobile) then
	    fear = false
		must_move = false
	end
	
	local past_memory = dsb_ai(id, AI_SEE_PARTY, QUERY)
	
	if (not mon_arch.sight) then
	    dsb_ai(id, AI_WALL_BELIEF, WALL_BELIEVE_NONE)
	else
		if (not mon_arch.stupid and (mon_arch.smart or past_memory)) then
			dsb_ai(id, AI_WALL_BELIEF, WALL_BELIEVE_PARTY)
		else
	    	dsb_ai(id, AI_WALL_BELIEF, WALL_BELIEVE_ALL)
		end
	end

	local pdir, range = linedirfrom(x, y, p_x, p_y)
	local clouddir = nil
	local straight_line_to_party = nil
		
	if (range > 2) then
		exvar[id].mai_twostepyou = nil
	end

	if (pdir and range > sight) then pdir = false end
	if (p_invis) then
		if (range > 1 and dsb_rand(0, 3) ~= 0) then
			pdir = false
		elseif (range == 1 and face ~= pdir) then
		    pdir = false
		end
	end
	
	if (pdir) then
		scan = scandirection("party_scan", mon_arch, id, pdir, range, lev, x, y, true)

		if (not fear and scan.reach and scan.visible) then
		    local sm
		    if (mon_arch.smart) then sm = 7 else sm = 5 end
			
			dsb_ai(id, AI_SEE_PARTY, sm)
			straight_line_to_party = range
			if (not mon_arch.stupid) then
				add_monster_target(id, sm+1, p_x, p_y)
			end
		    
		    if (scan.cloud or (mon_arch.paranoid and range > 2)) then
		    	clouddir = { pdir = pdir, range = range, scan = scan }
		    	scan = { reach = false }
		    	pdir = nil
		    	range = nil
		    end		    
		end
	end
	
	if (fear) then
		do_fearful_move(mon_arch, id, pdir, scan, lev, x, y)
		return true
	end
	
	-- Maybe we can push someone out of the way and slide in to attack
	-- (Added in DSB 0.58)
	if (scan.reach and scan.immed_mon_group and (dsb_rand(0, 5) ~= 0)) then
		if (range == 2 and not mon_arch.stupid and not mon_arch.prefer_ranged) then
			local targ_id = scan.immed_mon_group
			local targ_arch = dsb_find_arch(targ_id)
			local t_membs, t_team = dsb_ai_subordinates(targ_id)
			if ((mon_arch.smart and targ_arch.smart) or (targ_arch == mon_arch) or 
				(targ_arch.group_type and (targ_arch.group_type == mon_arch.group_type))) 
			then
				local t_timer = dsb_ai(targ_id, AI_TIMER, QUERY)
				local t_att = dsb_get_gfxflag(targ_id, GF_ATTACKING)
				local t_face = dsb_get_facedir(targ_id)
				if (((x == p_x) or (y == p_y)) and (t_face == pdir) and (face ~= ((pdir + 2) % 4))) then
					if ((t_timer <= 5) and (not t_att) and (t_membs <= membs)) then
						local dx, dy = dsb_forward(pdir)
						local t_x = x + dx
						local t_y = y + dy
						local sneak = sneakuponyousideways(targ_arch, t_membs, t_team, interval,
							pdir, lev, t_x, t_y, SC_BOTH_ROWS_SPLIT, true)
						if (sneak) then
							dsb_ai(id, AI_TURN, pdir)
							exvar[id].mai_setdir = pdir
							dsb_ai(id, AI_TIMER, shortinterval)
							return true
						end
					else
						-- increase the interval so we have a chance of making this work next time
						dsb_ai(id, AI_TIMER, interval + 1)
					end
				end
			end
		end
	end
	
	if (not mon_arch.oblivious and 
		(pdir == nil or (pdir and not scan.reach)))
	then
		local coordset = {
			{x = x, y = p_y },
			{x = p_x, y = y },
			{x = p_x + 1, y = y, px = 1},
			{x = p_x - 1, y = y, px = -1 },
			{x = x, y = p_y + 1, py = 1},
			{x = x, y = p_y - 1, py = -1 }
		}
		
		pdir = nil
	    scan = nil

		local goodscans = { }
		local gsct = 0

		local i
		for i=1,6 do
		    local tx = coordset[i].x
		    local ty = coordset[i].y
		    
			local dir, rng = linedirfrom(x, y, tx, ty)
			
			local max_range = 0
			if (not dir) then
			    rng = 1
			else
				max_range = sight
	 			if (mon_arch.smart) then max_range = max_range + 1 end
				if (mon_arch.crafty) then max_range = max_range + 1 end
			end

			-- sscan from my location to the target "corner"
			-- then pbscan from that location to the party's location
			local sscan
			if (not dir or rng > max_range) then
			    sscan = { reach = false }
			else
				sscan = scandirection("corner_scan", mon_arch, id, dir, rng, lev, x, y)
				max_range = max_range - rng
			end
			local pmemory = dsb_ai(id, AI_SEE_PARTY, QUERY)			
			if (sscan.reach and (not sscan.door or pmemory)) then
			    local px = p_x
			    if (coordset[i].px) then px = px + coordset[i].px end
                local py = p_y
			    if (coordset[i].py) then py = py + coordset[i].py end
			    
			    local pbdir, pbrng = linedirfrom(tx, ty, px, py)
			    if (pbdir and pbrng <= max_range) then
			    	local pbscan = scandirection("corner_to_party_scan", mon_arch, id, pbdir, pbrng, lev, tx, ty)
				    if (pbscan.reach) then
						gsct = gsct + 1
						local pen = dsb_rand(0, 4)
						
						if (exvar[id].mai_likedir) then
							if (exvar[id].mai_likedir == dir) then
								pen = 0
							else
								pen = pen + 1
							end
						end
						
						if (exvar[id].mai_setdir) then
							if (exvar[id].mai_setdir == dir) then
								pen = 0
							else
								pen = pen + 5
							end
						end
						
						if (pbscan.no_move) then
							pen = pen + 6
							if (pbscan.immed_no_move) then
								pen = pen + 4
							end
						end
						if (sscan.no_move) then pen = pen + 6 end
						if (pbscan.door) then pen = pen + 4 end
						
						-- Don't turn to approach a group if another way is better
						if (sscan.immed_mon_group) then
							if (dir ~= face) then
								pen = pen + 2
								if (sscan.immed_mon_group) then
									pen = pen + 6
								end
							end
						end
						
						if (pbscan.mon_group) then pen = pen + 2 end
						if (sscan.cloud or pbscan.cloud) then 
							pen = pen + 2
							if (sscan.immed_into_cloud) then
								pen = pen + 7
							elseif (pbscan.immed_into_cloud) then
								pen = pen + 1
							end
						end
						if (dir ~= face) then pen = pen + 1 end
						if (dir == (face+2)%4) then pen = pen + 2 end
						
				        goodscans[gsct] = {pdir = dir, prange = rng,
							pen = pen, pscan = sscan, tx = tx, ty = ty }
				    end
				end
			end
		end
		
		local target_x = nil
		local target_y = nil		
		if (gsct > 0) then 
		    local best = 99
		    for i=1, gsct do
		        local rval = (goodscans[i].prange * 2) + goodscans[i].pen
		        if (rval < best) then
		            pdir = goodscans[i].pdir
		            range = goodscans[i].prange + 1
		            scan = goodscans[i].pscan
		            scan.visible = true
		            scan.indirect = true
		            
		            if (clouddir) then
		            	clouddir.attack_scan = true
		            else
		            	want_attack = false
		            end
		            
					hunting_party = true	            
		            best = rval
		            
		            target_x = goodscans[i].tx
		            target_y = goodscans[i].ty
				end
			end
			
			if (not mon_arch.stupid and (target_x and target_y)) then
				add_monster_target(id, 6, target_x, target_y)
			end
			 
			if (best < 99) then
			    if (not mon_arch.stupid) then
		            local rval = dsb_rand(0, 9)
		            if (mon_arch.smart or mon_arch.crafty) then
		            	rval = rval - 4
		            end
		            
		            if (rval < 1) then
			            scan.door_solid_only = true
			            door_buster = true
			        end
					
			    end
			end
		end
	end	
	
	-- I moved the stupidity check up above so stupid monsters can
	-- still be given targets, just not automatically
	if (not pdir and exvar[id].mai_targetlist) then
		local rscans = { }
		local numscans = 0
		local bpen = 99
		local rscan
		
		for tl in pairs(exvar[id].mai_targetlist) do
			local targx = exvar[id].mai_targetlist[tl].x
			local targy = exvar[id].mai_targetlist[tl].y
			local tpdir, trange = linedirfrom(x, y, targx, targy)
			
			if (tpdir) then
				if (trange <= sight) then
        			local tscan = scandirection("target_scan", mon_arch, id, tpdir, trange, lev, x, y)
		        	if (tscan.reach and
						not tscan.immed_no_move and
						not tscan.immed_into_cloud) 
					then
		        		local pen = dsb_rand(0, 3)
		        		
		                tscan.visible = true
						tscan.indirect = true
		                
						if (exvar[id].mai_setdir) then
							if (exvar[id].mai_setdir == dir) then
								pen = 0
							else
								pen = pen + 3
							end
						end
		                
						if (tscan.no_move) then pen = pen + 7 end
						if (tscan.door) then pen = pen + 4 end
						if (tscan.mon_group) then pen = pen + 4 end
						if (tscan.cloud) then
							pen = pen + 2
						end
						if (tpdir ~= face) then pen = pen + 1 end
						if (tpdir == (face+2)%4) then pen = pen + 2 end
								                
		                numscans = numscans + 1
		                if (pen < bpen) then
		                	rscan = { pdir = tpdir, scan = tscan,
								range = trange, pen = pen }
							bpen = pen
						end
		                
					end
				end
			end
		end
		
		if (numscans > 0) then
			scan = rscan.scan
			pdir = rscan.pdir
			range = rscan.range	
        	want_attack = nil
        	
			local p_sight = dsb_ai(id, AI_SEE_PARTY, QUERY)
			if (not p_sight) then want_attack = false end
	
			range = range + 1
		end		
	end
	
	-- Move this down here so target lists are considered before
	-- we go walking through any clouds or other nastiness
	if (not pdir and clouddir) then
		pdir = clouddir.pdir
		range = clouddir.range
		scan = clouddir.scan
		scan.clouddir_best_choice = true
		want_attack = true                                            
	end
	
	-- All scans complete, time to act
	if (pdir and scan.reach) then
		local see_you = scan.visible
		-- Not really seeing you, but remembering you're there
		if (not see_you) then
			local p_sight = dsb_ai(id, AI_SEE_PARTY, QUERY)
		    if (p_sight) then
				see_you = true
				
				-- Attack, but only to bash doors
				if (want_attack == nil and scan.door) then
					scan.door_solid_only = true
					door_buster = true
				end
			end
		end
		
		if (must_move) then
		    want_attack = false
		end
		
		-- I have no idea who is there... but if I'm smart, maybe I
		-- can make a lucky guess once in a while
		if (range > 1 and scan.fakewall) then
			if (not mon_arch.smart or (dsb_rand(0, 5) ~= 0)) then
				want_attack = false
			end
		end
	
	    if (must_move or (range > 1 and see_you)) then
	        if (mon_arch.on_attack_ranged and 
				(want_attack or door_buster))
			then
				local attack_pdir = pdir
				local attack_range = range
				local attack_scan = scan
	            if (clouddir and clouddir.attack_scan) then
	            	attack_scan = clouddir.scan
	            	attack_range = clouddir.range
	            	attack_pdir = clouddir.pdir
	            end	
	            
	            local v
	            
				if (attack_scan.door) then
					if (attack_scan.door_dist < 2) then
				    	v = takedownadoor(mon_arch, membs, team, interval,
				        	face, attack_pdir, attack_scan, straight_line_to_party)
						if (v) then return true end
					end
				else
				    if (hazardmove(mon_arch, membs, team,
						pdir, shortinterval))
					then
				        return true
					end
					
				    local att = nil				  
					local out_of_range = isattackoutofrange(mon_arch, attack_range)
									
					if (not want_attack or out_of_range) then 
						att = false
					else
						-- Always try shooting through a cloud
						if (attack_scan.cloud and
							(not attack_scan.clouddir_best_choice or
							attack_scan.immed_into_cloud)) 
						then
							att = true
						else
							att = mon_arch:should_attack_ranged(id)
						end
					end 
					
				    if (att) then
			            if (align_for_attack(id, team, attack_pdir)) then
			                return true
						end
						v = beginrangedattack(mon_arch, membs, team,
							interval, attack_pdir, SHOOT_OPEN_SPACE,
							attack_scan)
						if (v) then
						    return true
						else
						    change_exvar(id, "mai_bottleneck", 1)
       						if (exvar[id].mai_bottleneck < 3) then
								return true
							end
						end
					end
				end				
			end
			
			-- No ranged attack. Movement instead..
			if (scan.immed_no_move) then
				change_exvar(id, "mai_bottleneck", 1)
				v = false
			else
				-- You can't dodge me forever
				local manu = exvar[id].mai_manuvered
				local rfactor
				local s_cap = 5
				local diag = false
				if (not mon_arch.crafty) then s_cap = s_cap + 1 end
				if (mon_arch.stupid) then s_cap = s_cap + 2 end
				if (x ~= p_x and y ~= p_y) then
					rfactor = dsb_rand(3, s_cap)
					diag = true
				else
					rfactor = dsb_rand(4, s_cap + 3)
				end
				if (manu and manu > rfactor) then
					if (membs >= 2) then
						local moveboss
						local newboss
						if (membs == 2) then
							dsb_ai(team[2].id, AI_UNGROUP, 0)
							moveboss = 1 
							newboss = 2
						else
							for n=1, membs do
								if (team[n].tile == (pdir + 2) % 4
									or team[n].tile == (pdir + 3) % 4)
								then
									dsb_ai(team[n].id, AI_UNGROUP, 0)
									newboss = n
								else
									moveboss = n
								end
							end
						end
							
						dsb_ai_promote(team[moveboss].id)	 
						v = moveindir(mon_arch, team[moveboss].id, pdir, shortinterval, true)
												
						if (v) then
						    local obid = team[moveboss].id
							local nbid = team[newboss].id
							dsb_ai_promote(nbid)
							dsb_ai(nbid, AI_TIMER, shortinterval)
							
							use_exvar(obid)
							exvar[obid].mai_nogrouping = 4
							
							use_exvar(nbid)
							exvar[nbid].mai_nogrouping = 4
							
							exvar[team[moveboss].id].mai_manuvered = nil
							return true
						else
							dsb_ai_promote(id)
						end
					else
						if (not mon_arch.stupid) then
						    local df = 20
						    if (mon_arch.pounces) then df = df - 8 end
							if (diag and (dsb_rand(0, 50) < df)) then

								local mintime = mon_arch.act_rate
								local maxtime = mon_arch.act_rate * 4
								if (mintime < 10) then mintime = 10 end
								if (maxtime > 40) then maxtime = 40 end
								if (mintime > maxtime) then
									mintime = 10
									maxtime = 40
								end 
								local rtimer = dsb_rand(mintime, maxtime)
								exvar[id].mai_suspend = dsb_rand(0, 1)
								exvar[id].mai_manuvered = nil
								dsb_ai(id, AI_TIMER, rtimer + 1)
								dsb_msg(2, id, M_SUSPEND_CHECK, 0)
								return true
							end
						end
					end
				end
				
				v = nil
				
				-- Try to avoid blundering into a poison cloud
				if (scan.immed_into_cloud) then
					v = random_move(id, 4, pdir)
					if (not v) then
						if (not must_move and (mon_arch.smart or
							mon_arch.paranoid or dsb_rand(0, 3) ~= 0)) 
						then
							dsb_ai(id, AI_TIMER, shortinterval)
							return true
						end
					end
				end
				
				-- Occasionally move randomly instead
				-- just to give some variety to the AI
				-- but not if we like a specific direction
				if (not v and not exvar[id].mai_likedir and
					(dsb_rand(0, 5) == 0)) 
				then
					v = random_move(id, 2, (pdir + 2) % 4)
				end
				
				exvar[id].mai_likedir = nil
				
				-- Also sometimes make a random move if the way
				-- we're trying to go will eventually be blocked
				if (not v and scan.no_move and dsb_rand(0, 3) == 0) then
					v = random_move(id, 2, nil)
				end	
				
				if (not v) then
	        		v = moveindir(mon_arch, id, pdir, shortinterval, true)
	        	end
	        end
	        
	        if (v) then 
        		if (hunting_party and range == 2) then
	        		change_exvar(id, "mai_manuvered", 1)
        		end
        		
        		if (mon_arch.pounces and range == 2) then
              		local lev, x, y = dsb_get_coords(id)
        		    local new_pdir, new_range = linedirfrom(x, y, p_x, p_y)
        		    if (new_pdir and new_range == 1) then
						local my_facedir = dsb_get_facedir(id)
						if (my_facedir ~= (new_pdir + 2) % 4) then
							local eagerness = 50
							if (mon_arch.pounce_eagerness) then
								eagerness = mon_arch.pounce_eagerness
							end
							if (dsb_rand(0, 2) == 0 and dsb_rand(0, 99) < eagerness) then
								if (not exvar[id] or not exvar[id].mai_pounced) then
							    	dsb_msg(1, id, M_POUNCE, new_pdir)
									dsb_ai(id, AI_DELAY_TIMER, 4)
								end
							end
						end
					end
				end
	        	
	            return true
			else
			    -- If I can't approach then try to take a potshot anyway
				local out_of_range = isattackoutofrange(mon_arch, range)
			    if (mon_arch.on_attack_ranged and want_attack and not out_of_range) then
					if (align_for_attack(id, team, pdir)) then
				    	return true
					end
					if (not scan.vis_obs) then
						v = beginrangedattack(mon_arch, membs, team, interval, pdir,
							SHOOT_OPEN_SPACE, scan)
						if (v) then return true end
					end
				end
				
				if (not hazard and not must_move) then
					change_exvar(id, "mai_bottleneck", 1)
					if (exvar[id].mai_bottleneck < 4) then
	   					if (align_for_attack(id, team, pdir)) then
					    	return true
						end
					    if (dsb_rand(0, 3) == 0) then
					        dsb_ai(id, AI_TIMER, shortinterval)
						end
						return true
					end
				end
			end
		end

    	-- Perform a close attack
		if (not mon_arch.on_attack_close) then
	        want_attack = false
		end
		if (range == 1 and want_attack) then
		
		    if (nearhazardmove(mon_arch, membs, team, pdir)) then
		        return true
			end

			if (align_for_attack(id, team, pdir)) then
				return true
			end
			
			-- Maybe try a little stunt if I've got a back row and I'm sneaky (or random)
			if (membs == 4 and (mon_arch.smart or mon_arch.crafty or (dsb_rand(0, 4) == 0))) then
			    local sf
			    if (hazard) then sf = 32 else
				    if (interval < 5) then sf = 21
				    elseif (interval < 13) then sf = 16
				    elseif (interval < 18) then sf = 10
				    else sf = 8 end
				    
				    if (mon_arch.swarmy) then sf = math.floor(sf / 2) end
				end
			    
			    if (dsb_rand(0, sf) == 0) then
					if (sneakuponyousideways(mon_arch, membs,
						team, interval, pdir, lev, x, y, SC_BACK_ROW_SPLIT, true))
					then
						return true
					end
				end
			end
			
			if (hazard) then
				if (not exvar[id].mai_hazcnt) then
				    local hazcnt = dsb_rand(1, 2)
					local myhp = dsb_get_hp(id)
				    if (myhp > 40 and myhp > (dsb_get_maxhp(id) / 2)) then
						hazcnt = hazcnt + 1
					end
					if (dsb_rand(0, (hazcnt + 2)) == 0) then hazcnt = 0 end
					exvar[id].mai_hazcnt = hazcnt
				end
				
				if (exvar[id].mai_hazcnt == 0) then
				    local v
				    dsb_ai(id, AI_TURN, (pdir + 1 + (2*dsb_rand(0, 1))) % 4)
				    v = moveindir(mon_arch, id, (pdir + 2) % 4, -1, false)
				    if (v) then
				    	exvar[id].mai_hazcnt = nil
						return true
					else
					    -- Fight to the death if I'm boxed in
					    exvar[id].mai_hazcnt = 3
					    dsb_ai(id, AI_TIMER, shortinterval)
					end
				else
				    exvar[id].mai_hazcnt = exvar[id].mai_hazcnt - 1
				end
			end
			
			if (exvar[id].mai_manuvered) then
				if (exvar[id].mai_manuvered >= 2) then
					change_exvar(id, "mai_manuvered", -2)
				else
					exvar[id].mai_manuvered = nil
				end
			end
			
			-- Speedy monsters will try to "two-step" the party just like
			-- they're probably going to be doing to them...
			if (exvar[id].mai_twostepyou) then
				
				exvar[id].mai_twostepyou = nil
				
				if (pdir == ((p_face + 2) % 4)) then	
					local tries = 0
					local a_trydir = 1 + (2 * dsb_rand(0, 1))
					local trydir = (pdir + a_trydir) % 4
					while (tries < 2) do
						local dx, dy = dsb_forward(pdir)
						local cdx, cdy = dsb_forward(trydir)
						if (canigo(mon_arch, id, lev, x + dx + cdx, y + dy + cdy, true)) then
							local v = false
							
							if (membs > 2) then
								v = sneakuponyousideways(mon_arch, membs, team,
									interval, trydir, lev, x, y, SC_BREAK_FRONTWARD, false)
							end
							if (not v) then 
								v = moveindir(mon_arch, id, trydir, shortinterval, true)
							end
							
							if (v) then
								temporaryblock(lev, x, y, shortinterval + 1)
								dsb_ai(id, AI_TIMER, shortinterval)
								exvar[id].mai_likedir = pdir
								exvar[id].mai_nowake = true
								return true
							end
						end 
						trydir = (trydir + 2) % 4
						tries = tries + 1
					end
				end				
			end
			
			begingroupattack(mon_arch, membs, team, interval, pdir)
			
			if (mon_arch.paranoid or mon_arch.swarmy) then				
				local targedval = 4
				if (pdir ~= (p_face + 2) % 4) then targedval = 2 end
				if ((mon_arch.swarmy or mon_arch.act_rate <= 5) and
					dsb_rand(0, 4) >= targedval)
				then
					exvar[id].mai_twostepyou = true	
					exvar[id].mai_nowake = true
				end
			end
			
			return true
		end
	end
	
	if (mon_arch.immobile) then
	    if (dsb_rand(0, 9) > 5) then
			dsb_ai(id, AI_TIMER, shortinterval)
		end
		return true
	else
		local rdir = 1 + (2 * dsb_rand(0, 1))
		v = moveindir(mon_arch, id, (face + rdir) % 4, shortinterval, true)
		if (v) then
			exvar[id].mai_bottleneck = nil
			return true
		end
		rdir = rdir + 2
		v = moveindir(mon_arch, id, (face + rdir) % 4, shortinterval, true)
		if (v) then
			exvar[id].mai_bottleneck = nil
			return true
		end

		if (not must_move and not hazard) then
			local backdir = (face + 2) % 4
			local dx, dy = dsb_forward(backdir)
			
			if (canigo(mon_arch, id, lev, x + dx, y + dy, false)) then  
		    	dsb_ai(id, AI_TURN, (face + rdir) % 4)
		    	if (not dsb_ai(id, AI_FEAR, QUERY)) then
		    		dsb_ai(id, AI_FEAR, 2)
		    	end
			end
			
		    return true
		end
	end
	
	-- If all else fails, just go random
	return (random_move(id, 4, nil))
end

-- Monsters looking around
-- Only boss monsters get this function called on them
-- (don't move, this isn't actually the monster's turn)
function ai_monster_investigate(id, sight)
	local mon_arch = dsb_find_arch(id)
	
	-- Get motivated if the party is next to us
	if (not exvar[id] or not exvar[id].mai_nowake) then
		local lev, x, y = dsb_get_coords(id)
		local p_lev, p_x, p_y = dsb_party_coords()
		if (lev == p_lev) then
			local adj = false
			if (p_x == x and ((y+1 == p_y) or (y-1 == p_y))) then adj = true end
			if (p_y == y and ((x+1 == p_x) or (x-1 == p_x))) then adj = true end
			if (adj) then
				motivate_slothful_monsters(id)
				use_exvar(id)
				exvar[id].mai_nowake = true
			end
		end
	end
	
	-- Oblivious monsters are oblivious
	if (mon_arch.oblivious) then
		return
	end
	
	-- Stupid monsters have a 50% chance of just being oblivious
	if (mon_arch.stupid and dsb_rand(0, 1) == 0) then
	    return
	end
	
	local p_invis = dsb_get_gameflag(GAME_PARTY_INVIS)
	if (mon_arch.sees_invisible) then
		p_invis = false
	end
	-- Invisible party turns up nothing
	if (p_invis) then
		return
	end
	
	-- Frightened monsters have better things to do than poke around
	local fear = dsb_ai(id, AI_FEAR, QUERY)
	if (fear) then
		return
	end

	-- Haven't seen the party lately, let's peek around
	local seeparty = dsb_ai(id, AI_SEE_PARTY, QUERY)
	if (not seeparty or (seeparty < 3)) then
		local lev, x, y = dsb_get_coords(id)
		local p_lev, p_x, p_y = dsb_party_coords()
    	local pdir, range = linedirfrom(x, y, p_x, p_y)
		if (pdir and range > sight) then pdir = false end
	
		if (pdir) then
			scan = scandirection("investigation_scan", mon_arch, id, pdir, range, lev, x, y, true)	
			if (scan.reach and scan.visible) then
				dsb_ai(id, AI_SEE_PARTY, 3)
			end
		end
	end
end

-- Distant monsters just move around randomly
function ai_monster_far(id)
	local mon_arch = dsb_find_arch(id)
	
	-- If the monster has a special AI, call that instead
	if (mon_arch.ai_far) then
	    return (mon_arch.ai_far(id))
	end
	
	if (mon_arch.immobile) then
	    return true
	end

	-- I assumed that the AI for monsters on the same
	-- level as the party but distant and monsters that
	-- are not on the same level as the party was 
	-- basically the same. This may still be basically
	-- true, but after noticing the "Laughing Pit" was
	-- much harder in DSB, studying AI traces revealed
	-- that monsters on the same level as the party
	-- have a 50% chance of just not moving when
	-- they're wandering around randomly.
	local lev = dsb_get_coords(id)
	local p_lev = dsb_party_coords()
	if (p_lev == lev) then
		-- Don't sit idle if we're in danger, and occasionally
		-- set the timer to a different value after doing nothing
		if (not dsb_ai(id, AI_HAZARD, QUERY)) then
			if (dsb_rand(0, 1) == 0) then
				-- Fast monsters linger for a bit, and slow monsters
				-- get another check faster. That is what I want!
				if (dsb_rand(0, 5) == 0) then
					dsb_ai(id, AI_TIMER, 6)
				end
				return true
			end
		end
	end

	return (random_move(id, false, nil))
end

function random_move(id, take_tries, baddir)
	local arch = dsb_find_arch(id)
	
	-- Randomly moving about, assume all fake walls are real
	-- ...unless the monster is smart (changed in 0.52)
	-- ..... or blind (changed in 0.54)
	if (arch.smart or (not arch.sight)) then
		dsb_ai(id, AI_WALL_BELIEF, WALL_BELIEVE_PARTY)
	else	
		dsb_ai(id, AI_WALL_BELIEF, WALL_BELIEVE_ALL)
	end

	-- Try to move once or twice, except if I'm in trouble, then
	-- make sure to try to escape all four directions
	local tries
	if (take_tries) then
	    tries = take_tries
	elseif (dsb_ai(id, AI_HAZARD, QUERY)) then
	    tries = 4
		if (arch.smart or arch.paranoid) then
			dsb_ai(id, AI_WALL_BELIEF, WALL_BELIEVE_NONE)
		end
	else
	    tries = dsb_rand(1, 2)
	end

	-- Slightly greater chance of moving in the direction facing
	local dir
	if (dsb_rand(0, 4) == 0) then
		dir = dsb_get_facedir(id)
	else
		dir = dsb_rand(0, 3)
	end
	
	use_exvar(id)
	exvar[id].mai_setdir = nil
	
	-- Move a random direction
	while (tries > 0) do
		if (not baddir or dir ~= baddir) then
			local dx, dy = dsb_forward(dir)
			local lev, x, y = dsb_get_coords(id)
			local movego = canigo(arch, id, lev, x + dx, y + dy, true)
			if (movego and dsb_ai(id, AI_MOVE, dir)) then
		    	return true
			end
		end
		
		dir = (dir + 1) % 4
		tries = tries - 1
	end
	
	return nil
end

function get_collision_info(arch, inst, myinst, check_danger)
	local colinfo = false
	local nm = false
	local danger_val = nil
	
	if (type(arch.col) == "function") then
	    colinfo = arch:col(inst, myinst)
	else colinfo = arch.col end
	
	if (type(arch.no_monsters) == "function") then
		    nm = arch:no_monsters(inst, myinst)
	else nm = arch.no_monsters end
	
	if (check_danger) then
		if (type(arch.dangerous) == "function") then
			    danger_val = arch:dangerous(inst, myinst)
		else danger_val = arch.dangerous end
		
		return colinfo, nm, danger_val
	end

	return colinfo, nm
end

function linedirfrom(lx, ly, tx, ty)
	if (tx == lx and ty == ly) then return nil, 0 end
	
	local adist = math.abs(tx-lx) + math.abs(ty-ly)
    if (tx == lx) then
        if (ly > ty) then return 0, adist end
        return 2, adist
    elseif (ty == ly) then
        if (lx > tx) then return 3, adist end
        return 1, adist
    else
        return nil, adist
	end
end

function approxlinedirfrom(lx, ly, tx, ty, e)
	if (tx == lx and ty == ly) then return nil, 0 end
	
	local lxd = math.abs(tx-lx)
	local lyd = math.abs(ty-ly)
	local adist = lxd + lyd
	
	local odd = false
	local even = false
	if (lxd == lyd) then
		if (e == 1) then odd = true
		else even = true end
	end
	
    if (lxd < lyd or odd) then
        if (ly > ty) then return 0, adist end
        return 2, adist
    elseif (lyd < lxd or even) then
        if (lx > tx) then return 3, adist end
        return 1, adist
    else
        return nil, adist
	end
end

function canigo(myarch, myinst, lev, x, y, check_danger)
	local cell = dsb_get_cell(lev, x, y)
	if (cell) then return false end
	
	local p_at = dsb_party_at(lev, x, y)
	if (p_at) then
	    return false
	end
	
    local whatshere = dsb_fetch(lev, x, y, -1)
    if (whatshere) then
		local i
		for i in pairs(whatshere) do
		    local inst = whatshere[i]
		    local arch = dsb_find_arch(inst)
		    local inactive = dsb_get_gfxflag(inst, GF_INACTIVE)
		    if (not inactive) then
				if (arch.renderer_hack == "FAKEWALL") then
				    if (not handlefakewall(myinst, myarch,
						range, max, lev, x, y))
					then
						return false
					end
				else
					local colinfo, nm, danger = get_collision_info(arch, inst, myinst, check_danger)
					if (colinfo or nm) then
						return false
					end
					
					if (check_danger and danger) then
						dval = danger_evaluate(myarch, myinst, inst, danger, false)
						if (dval) then
							return false
						end
					end
					
				end
		    end
		end
	end
	
	return true
end

function isattackoutofrange(mon_arch, range)
	local out_of_range = false
	local max_att_range = mon_arch.perception
	if (not mon_arch.darkvision) then
		local total_light = dsb_get_light_total()
		if (total_light > 84) then total_light = 84 end
		if (total_light < 0) then total_light = 0 end
		max_att_range = max_att_range - ((84-total_light) / 12)	
	end
	
	local arch_max_range = 3
	if (mon_arch.attack_range) then arch_max_range = mon_arch.attack_range end
	if (max_att_range > arch_max_range) then
		max_att_range = arch_max_range
	elseif (max_att_range < 1) then
		max_att_range = 1
	end
	
	if (range > max_att_range) then
		out_of_range = true
	end
	
	return out_of_range
end

function danger_evaluate(myarch, myinst, dangerous_inst, dangertype, priority)
	local danger_resist = "anti_" .. dangertype
	local drn = myarch[danger_resist]
	if (not drn) then
		drn = default_monster_dmgresist[danger_resist]
	end
	if (not drn) then
		return false
	end
	
	if (drn < 140) then
		if (priority and not myarch.prefer_ranged) then
			local danger_arch = dsb_find_arch(dangerous_inst)
			if (danger_arch.type == "CLOUD") then
				local minhp = dsb_get_charge(dangerous_inst)*20 + 10
				-- We can endure it for a while, so let's attack
				if (dsb_get_hp(myinst) >= minhp) then 
					return false
				end
			end
		end
		return true
	end
	
	return false	
end

function scandirection(scan_type, myarch, myinst, pdir, range, lev, x, y, pre_dec)
	local scan = { reach = false, visible = nil }
	if (range > 8) then return scan end
	local max = range
	local initial = true
	local dist = 0

	local dx, dy = dsb_forward(pdir)
	x = x + dx
	y = y + dy
	if (pre_dec) then
		range = range - 1
	end
	
	while (range > 0) do
	    local cell = dsb_get_cell(lev, x, y)
	    local door_here
	    if (cell) then return scan end
	    
	    local whatshere = dsb_fetch(lev, x, y, -1)
	    if (whatshere) then
			local i
			door_here = false
			for i in pairs(whatshere) do
			    local inst = whatshere[i]
			    local arch = dsb_find_arch(inst)
			    local inactive = dsb_get_gfxflag(inst, GF_INACTIVE)
			    
			    if (not inactive) then
				    if (arch.type == "DOOR") then
						door_here = true
				        local bashed = dsb_get_gfxflag(inst, GF_BASHED)
				        if (not bashed) then				        	
					        if (not scan.door) then
						        scan.door = true
						        scan.door_id = inst
						        scan.door_dist = dist
						        if (arch.bars) then 
									scan.door_bars = true
									scan.vis_obs = true
						        else 
									scan.visible = false
									if (myarch.stupid) then
				        				scan.object = true
				        				return scan
				        			end
								end
							else
							    if (not arch.bars and scan.door_bars) then
							        scan.door_bars = false
									scan.visible = false
								end
							end
						end
					elseif (arch.renderer_hack == "FAKEWALL") then
					    if (handlefakewall(myinst, myarch, range, max, lev, x, y)) then
							scan.fakewall = true
						else
						    scan.object = true
						    return scan
						end
					elseif (arch.type == "MONSTER") then
					    if (scan.door and not scan.door_bars and not door_here) then
					        -- solid door
					        scan.farmonster = true
					        scan.mon_group = nil
						else
							if (scan.mon_group) then
							    local t = dsb_ai_boss(inst)
							    if (t ~= scan.mon_group) then
							        scan.object = true
							        scan.nonmat_blocker = nil
									return scan
								end
							else
								local boss = dsb_ai_boss(inst)
								local boss_arch = dsb_find_arch(boss)
							    
								scan.mon_group = boss
							    if (boss_arch.nonmat) then
							    	scan.nonmat_blocker = true
							    end
								if (initial) then
									scan.immed_mon_group = boss
								end							    
							end
						end
					else
						local colinfo, nm, danger = get_collision_info(arch, inst, myinst, true)
						if (colinfo) then
						    scan.object = true
							-- As of DSB 0.58 we mark an object as immovable, too
							scan.no_move = true
							if (initial) then
						    	scan.immed_no_move = true
						    end						
						    return scan
						elseif (nm) then
							scan.no_move = true
							if (initial) then
						    	scan.immed_no_move = true
						    end
						end
						
						local priority = false
						if (scan_type == "party_scan" or scan_type == "corner_scan") then
							if (range <= 2) then
								priority = true
							end
						end
					
						if (not scan.no_move and danger) then						
							local danger_check = danger_evaluate(myarch, myinst, inst, danger, priority)												
							if (danger_check) then 
								scan.cloud = true
								if (initial) then
									scan.immed_into_cloud = true
								end
							end
						end
						
					end
				end
				
			end
		end

		dist = dist + 1
	    range = range - 1
	    x = x + dx
	    y = y + dy
	    initial = false
	end

	scan.reach = true
	if (scan.visible ~= false) then
		scan.visible = true
	end
	
	return scan
end

function moveindir(arch, id, dir, sinterval, dir_set)

	if (arch.immobile) then
	    return false
	end

	local face = dsb_get_facedir(id)
	
	-- The only time a short interval isn't given is for
	-- a hazard move, so we should move very quickly.
	if (not sinterval) then
		sinterval = 2
	end
	
	if (groupupmove(arch, id, dir, sinterval)) then
		return true
	end
			
	if (sinterval < 0) then
	    return (dsb_ai(id, AI_MOVE, dir, face))
	end
	
	local lev, x, y = dsb_get_coords(id)
	local dx, dy = dsb_forward(dir)
	local movego = canigo(arch, id, lev, x+dx, y+dy, false)
	if (not movego) then
		return false
	end
		
	if (face == (dir+2) % 4) then

		if (sinterval == nil) then
	        dsb_write(debug_color, "ERROR: NIL SINTERVAL WHEN NEEDED")
	        return false
		end
		
	    local ddir = face + 1
	    if (dsb_rand(0, 1) == 0) then ddir = ddir + 2 end
	    ddir = ddir % 4
		dsb_ai(id, AI_TURN, ddir)
		dsb_ai(id, AI_TIMER, sinterval)
		if (dir_set) then
			use_exvar(id)
			exvar[id].mai_setdir = dir
		end
		return true
	end
	
	use_exvar(id)
	exvar[id].mai_setdir = nil
	return (dsb_ai(id, AI_MOVE, dir))
end

function groupupmove(arch, id, dir, sinterval)

	if (arch.size == 4 or arch.no_group) then
		return false
	end 
	
	use_exvar(id)
	if (exvar[id].mai_shootalign) then
		return false
	end
	
	if (exvar[id].mai_nogrouping) then
		return false
	end
	
	-- If the party has been dancing around us, then
	-- forming up a group will just make it easier. so don't!
	if (exvar[id].mai_manuvered and
		exvar[id].mai_manuvered >= 3)
	then
		return false
	end

	local face = dsb_get_facedir(id)
	local lev, x, y, tpos = dsb_get_coords(id)
	local dx, dy = dsb_forward(dir)
	
	local targsq = dsb_fetch(lev, x + dx, y + dy, -1)
	if (not targsq) then return false end
	
	-- First make sure it's an ok target square
	local i
	for i in pairs(targsq) do
		local block = targsq[i]
		local block_arch = dsb_find_arch(block)
		if (block_arch.suppress_monster_grouping) then
			return false
		end
	end
	
	-- Find who is on the other square and who is the boss
	local oboss = nil
	for i in pairs(targsq) do
		local mon = targsq[i]
		local mon_arch = dsb_find_arch(mon)
		if (mon_arch.type == "MONSTER") then
			if (mon_arch.size == 4) then
				return false
				
			elseif (mon_arch ~= arch) then
				if (mon_arch.group_type and arch.group_type) then
					if (mon_arch.group_type == arch.group_type) then
						oboss = mon
						break
					else
						return false
					end
				else
					return false
				end
				
			else
				oboss = mon
				break
			end
		end
	end
	if (not oboss) then return false end
	
	-- Make sure oboss really is the other boss
	oboss = dsb_ai_boss(oboss)
	local oarch = dsb_find_arch(oboss)
	
	use_exvar(oboss)
	if (exvar[oboss].mai_shootalign) then
		return false
	end
	if (exvar[oboss].mai_nogrouping) then
		return false
	end
	
	-- If the party has been dancing around them, then
	-- forming up a group will just make it easier. so don't!
	if (exvar[oboss].mai_manuvered and
		exvar[oboss].mai_manuvered >= 4)
	then
		return false
	end

	
	local membs, team = dsb_ai_subordinates(id, true)
	local omembs, oteam = dsb_ai_subordinates(oboss, true)
	local oarch = dsb_find_arch(oboss)
	
	-- Don't even try to group if someone's frozen
	if (frozen_team_member(membs, team)) then
	    return false
	end
	if (frozen_team_member(omembs, oteam)) then
	    return false
	end
		
	local max
	if (arch.size == oarch.size) then
	    if (arch.size == 2) then max = 2
		else max = 4 end
	else max = 3 end
	if (membs + omembs > max) then return false end
	
	-- freespots @ destination square
	local freespots = { true, true, true, true }
	local ocenter = false
	for i in pairs(oteam) do
		-- If the other side is centered, I can go anywhere
		if (oteam[i].tile == CENTER) then
			ocenter = true
			break
		end
		
		-- Make free spots table relative to move direction
		local s = (oteam[i].tile + 4 - dir) % 4
		freespots[s + 1] = false
		if (oarch.size == 2) then
			local xface = dsb_get_facedir(oteam[i].id)
			local alt_tile = dsb_tileshift(oteam[i].tile, xface)
			local alt_s = (alt_tile + 4 - dir) % 4 
			freespots[alt_s + 1] = false
		end
	end

	-- filledspots @ source group
	local filledspots = { false, false, false, false }
	local mecenter = false
	for i in pairs(team) do
		-- If my side is centered, I can go anywhere
		if (team[i].tile == CENTER) then
			mecenter = true
			break
		end
		
		-- Make filled spots table relative to move direction
		local s = (team[i].tile + 4 - dir) % 4
		filledspots[s + 1] = true
		if (arch.size == 2) then
			local alt_s = dsb_tileshift(s, dsb_get_facedir(team[i].id))
			filledspots[alt_s + 1] = true
		end
	end

	local easymove = true
	for i=1,4 do
		if (filledspots[i] and not freespots[i]) then
			easymove = false
			break
		end
	end	
	
	-- It's also not an easy move if two size2s are facing opposite ways
	-- Or if it's sideways-- that's handled below.
	if (arch.size == 2) then
		local obossdir = dsb_get_facedir(oboss)
		if (face ~= obossdir) then
			dsb_ai(id, AI_TURN, obossdir)
			dsb_ai(id, AI_TIMER, 6)
			return true
		end
		if (face ~= dir) then
		    easymove = false
		    if (face == (dir+2)%4) then
		    	return false
		    end
		end
	else
	    -- Or if the whole back row is clogged up
		if (not freespots[3] and not freespots[4]) then
		    easymove = false
		end
		
		-- Or if my guys are blocked from entering the row
		if (not ocenter and not mecenter) then
			if (not freespots[3] and filledspots[2]) then
				easymove = false
			end
			if (not freespots[4] and filledspots[1]) then
				easymove = false
			end
		end
	end
	
	local extdelay = 1
	if (easymove) then		
		dsb_ai(id, AI_TURN, dir)
		
		if (ocenter) then
			for rf=0,3 do
				local sid = rf
				if (arch.size == 2) then
					if (rf > 1) then return false end
				else
					sid = (rf + 2) % 4
				end
				if (not filledspots[1 + sid]) then
					local newdir = (dir + sid) % 4
					dsb_reposition(oteam[1].id, newdir)
					freespots[1 + sid] = false
					oteam[1].tile = newdir
					break
				end
			end
		end
		
		if (mecenter) then
			for rf=0,3 do
				local sid = rf
				if (arch.size == 2) then
					if (rf > 1) then return false end
				else
					sid = (rf + 2) % 4
				end
				if (arch.size == 2 and rf > 1) then return false end
				if (freespots[1 + sid]) then
					local newdir = (dir + sid) % 4
					dsb_reposition(team[1].id, newdir)
					team[1].tile = newdir
					break
				end
			end
		end
			
		for i in pairs(team) do
			local tpos = team[i].tile
			
			-- The engine suppresses its normal call of the "on_move" event because
			-- the last parameter of dsb_move_moncol is nil. So we have to call 
			-- on_move ourselves, after everything is in order.
			-- (This note was added as of DSB 0.68, although the code has worked
			-- this way for a while before that)
			dsb_move_moncol(team[i].id, lev, x + dx, y + dy, tpos, dir, nil)
			
			if (team[i].id ~= id) then
				if (arch.on_move) then
					arch:on_move(team[i].id, false)
				end
			end                    
		end
	
		dsb_ai_promote(id) 
		dsb_ai(id, AI_DELAY_ACTION, extdelay)
		if (arch.on_move) then arch:on_move(id, true) end
		
		return true
	end
	
	if (arch.size == 2) then			
		-- Ability to take side slots with a sideways move
		if ((freespots[1] and freespots[2]) or (freespots[3] and freespots[4])) then	
			local slide
			local moved = false		
			if (tpos == dir or tpos == (dir + 1) % 4) then slide = nil
			else
				local ntpos
				if (tpos == CENTER) then
					if (face == (dir + 3) % 4) then ntpos = dir
					else ntpos = (dir + 1) % 4 end
				else ntpos = dsb_tileshift(tpos, dir) end
									
				slide = monster_rearrange(id, ntpos, "SLIDE SELF")
			end
			if (slide == false) then 
				return false
			elseif (slide == true) then
				moved = true
			end
			
			local bpos = oteam[1].tile
			if (bpos == dir or bpos == (dir + 1) % 4) then slide = nil
			else
				local ntpos
				local bface = dsb_get_facedir(oteam[1].id)
				if (bpos == CENTER) then
					if (bface == (dir + 3)%4) then ntpos = dir
					else ntpos = (dir + 1)%4 end
				else ntpos = dsb_tileshift(bpos, dir) end
			
				slide = monster_rearrange(oteam[1].id, ntpos, "SLIDE OTHER")
			end
			if (slide == false) then
				return false
			elseif (slide == true) then
				moved = true
			end
			
			if (moved == false) then
				local spos = dsb_tileshift(tpos, dir)
				dsb_move_moncol(id, lev, x + dx, y + dy, spos, dir, true)
				dsb_ai_promote(id)
				dsb_ai(id, AI_DELAY_TIMER, 4)
			else	
				dsb_ai(oboss, AI_DELAY_TIMER, 4)
			end
					
			return true			
		end
		
		-- I must be on the wrong side
		monster_rearrange(id, CENTER, "SLIDE WRONG")
		dsb_ai(id, AI_TIMER, 5)
				
		return true
	end
	
	-- No size 2 arch code beyond this point
	
	-- Clogged up back row, can we make room?
	if (not freespots[3] and not freespots[4]) then
		if (pushguysforward(dir, oteam, nil)) then
			dsb_ai(id, AI_TIMER, 4)
			return true
		else
			return false
		end
	end
	
	-- Handle all 3 + 1, 2 + 1, etc. groupings
	if (membs == 1) then
		dsb_ai(id, AI_TIMER, 3)
		local att = monster_rearrange(id, CENTER, "CENTER 1")
		if (att) then
			dsb_ai(oboss, AI_DELAY_TIMER, sinterval)
			return true
		else return false end			
	end		
	if (omembs == 1) then
		dsb_ai(id, AI_TIMER, 4)
		local att = monster_rearrange(oboss, CENTER, "CENTER 3 FOR 1")
		if (att) then
		    exvar[oboss].mai_groupalign = true
			dsb_ai(oboss, AI_DELAY_TIMER, sinterval + 1)
			pushguysforward(dir, team, nil)
			return true
		else return false end			
	end	
	
	-- Now we handle the weird 2+2 groups

	-- Slide over guys when they're all in a line
	-- This makes the next move an easymove
	if (freespots[1] == freespots[4]) then
	    if (filledspots[1] == filledspots[4]) then
	        local po
	        if (filledspots[1]) then
	        	po = pushguysforward((dir+1)%4, team, dir)
			else po = pushguysforward((dir+3)%4, team, dir) end
			return po
	    end
	end
	
	-- Front row and front row, put the new guys in the back
	if (freespots[3] and freespots[4]) then
		if (filledspots[1] and filledspots[2]) then
			for tn=1,2 do
				local fv = false
				if (team[tn].id == id) then fv = true end
				dsb_move_moncol(team[tn].id, lev, x + dx, y + dy, 
					dsb_tileshift(team[tn].tile, dir), dir, fv)
				dsb_set_facedir(team[tn].id, dir)
			end
			dsb_ai_promote(id)
			return true
		end
	end
	
	-- Get rid of weird diagonal formations
	if ((filledspots[4] and not filledspots[1]) or
		(filledspots[3] and not filledspots[2]))
	then
		if (pushguysforward(dir, team, dir)) then
			dsb_ai(id, AI_DELAY_TIMER, sinterval)
			return true
		else
			return false
		end		
	end
	
	-- Can one guy join?
	local ps = {3, 4}
	local ss = {2, 1}
	for i=1,2 do
		local p = ps[i]
		local s = ss[i]
		if (freespots[p] and (filledspots[p] or filledspots[s])) then
			local pt = (p - 1 + dir) % 4
			local st = (s - 1 + dir) % 4
			
			local theguy = nil
			if (team[1].tile == st) then theguy = 1
			elseif (team[1].tile == pt) then theguy = 1
			end
			if (team[2].tile == st) then theguy = 2
			elseif (not theguy and team[2].tile == pt) then theguy = 2
			end
			
			if (not theguy) then break end
						
			local leftbehind = team[(theguy % 2) + 1].id
			local moved = team[theguy].id
			
			dsb_move_moncol(moved, lev, x + dx, y + dy, pt, dir, true)
			dsb_set_facedir(moved, dir)	
			dsb_ai_promote(moved)
			
			dsb_ai_promote(leftbehind)
			dsb_ai(leftbehind, AI_TIMER, sinterval + 1)		
		
			return true			 
		end
	end
	
	-- Ok, forget it
	return false
end

function pushguysforward(dir, oteam, rdir)
	local xdir = (dir+1)%4
	local push
	local i
	local mv = false
	local mv2 = false
	
	for i in pairs(oteam) do
	    push = oteam[i].id
	    if (oteam[i].tile == (dir+3)%4) then
			mv = monster_rearrange(push, dir, "SHOVE")
			if (rdir and mv) then
			    dsb_set_facedir(push, rdir)
			end
		elseif (oteam[i].tile == (dir+2)%4) then
			mv2 = monster_rearrange(push, xdir, "SHOVE")
			if (rdir and mv2) then
			    dsb_set_facedir(push, rdir)
			end
		end
	end

	if (mv or mv2) then return true
	else return false end
end

function handlefakewall(inst, arch, range, max, lev, x, y)
	local belief = dsb_ai(inst, AI_WALL_BELIEF, QUERY)
	
	if (belief == WALL_BELIEVE_NONE) then
		return true
	elseif (belief == WALL_BELIEVE_ALL) then
		return false
	end
	
	if (dsb_visited(lev, x, y)) then
	    if (arch.smart) then
	        return true
		end
		
	    local seen_you = dsb_ai(inst, AI_SEE_PARTY, QUERY)
		if (seen_you) then
		    return true
		end
	end
	
	return false
end

function hazardmove(mon_arch, membs, team, dir, sinterval)
	local id = team[1].id
	local face = dsb_get_facedir(id)
	local hazard = dsb_ai(id, AI_HAZARD, QUERY)
	if (not hazard) then
	    if (not dsb_ai(id, AI_MOVE_NOW, QUERY)) then
			return false
		end
	end
	
	if (not mon_arch.instant_turn and face == (dir + 2) % 4) then
	    v = moveindir(mon_arch, id, face, nil, false)
	    if (v) then return true end
		dsb_ai(id, AI_TURN, (dir + 1 + (2*dsb_rand(0, 1))) % 4)
		dsb_ai(id, AI_TIMER, sinterval)
		return true
	else
	    local v
	    v = moveindir(mon_arch, id, dir, nil)
	    if (v) then return true end
	    if (face ~= dir) then
		    v = moveindir(mon_arch, id, face, nil)
		    if (v) then return true end
		    v = moveindir(mon_arch, id, (dir+2)%4, nil)
		    if (v) then return true end
		    dsb_ai(id, AI_TURN, dir)
		    dsb_ai(id, AI_TIMER, sinterval)
		    return true
		else
		    local c
		    local tdirs = { 1, 1 }
			tdirs[dsb_rand(1, 2)] = 3
			for c=1,2 do
			    v = moveindir(mon_arch, id, (dir + tdirs[c]) % 4, nil)
			    if (v) then return true end
			end
			dsb_ai(id, AI_TURN, (dir + tdirs[1]) % 4)
			dsb_ai(id, AI_TIMER, sinterval)
			return true
		end
	end

	return false
end

function nearhazardmove(mon_arch, membs, team, dir)
	local id = team[1].id
	local face = dsb_get_facedir(id)
	local hazard = dsb_ai(id, AI_HAZARD, QUERY)
	if (not hazard) then return false end
	
	local v
	if (face ~= dir) then
	    v = moveindir(mon_arch, id, face, nil)
	    if (v) then return true end

		if (face == (dir+2)%4) then
		    local tdirs = { 1, 1 }
			tdirs[dsb_rand(1, 2)] = 3
			for c=1,2 do
			    v = moveindir(mon_arch, id, (dir + tdirs[c]) % 4, nil)
			    if (v) then return true end
			end
		else
		    v = moveindir(mon_arch, id, (dir+2)%4, nil)
		    if (v) then return true end
		end
	end
	
	return false
end

function takedownadoor(mon_arch, membs, team, interval, face, pdir, scan, straight_line)
    local id = team[1].id

	-- I don't really understand the DM AI, but in general it feels 
	-- like DSB monsters are much more eager to go through doors.
	-- Let's calm them down just a little bit...	
	if (exvar[id].mai_leave_doors_alone) then
		return false
	end
      
    if (align_for_attack(id, team, pdir)) then
        return true
	end
	
	local v
	if (scan.door) then
		if (scan.door_bars and not scan.door_solid_only) then
		    v = beginrangedattack(mon_arch, membs, team,
				interval, pdir, SHOOT_DOOR_BARS, scan)
			if (v) then return true end
		end
		
		-- Nonmaterial monsters don't care about door blasting
		if (mon_arch.nonmat) then
			return false
		end
		
		-- And monsters that aren't very clever won't track you
		if (not straight_line) then
			if (not mon_arch.smart and not mon_arch.crafty) then
				return false
			end
		end
				
		local rand_top = straight_line
		if (not rand_top or (rand_top > 4)) then rand_top = 4 end
		exvar[id].mai_leave_doors_alone = dsb_rand(1, rand_top)

		-- After studying the DM AI, I've determined that monsters
		-- in DM (or at least in CSBwin) don't smash doors because
		-- most of the time their fireballs are too weak. For
		-- someone like dragons, that kind of ruins the whole point
		-- of the "dragon den," so I gave them stronger fireballs and
		-- I'll slow them down a little bit more here...
		if (mon_arch.door_breaker and not mon_arch.door_opener) then
			local hazardous = dsb_ai(id, AI_HAZARD, QUERY)
			if (not hazardous) then
				-- If I can't see you, usually don't bother
				if (not straight_line and (dsb_rand(0, 2) ~= 0)) then
					return false
				end
				if (dsb_rand(0, 1) == 0) then
					-- Takes up the whole turn!
					return true
				end
			end
		end
		
		v = beginrangedattack(mon_arch, membs, team,
		    interval, pdir, SHOOT_DOOR_SOLID, scan)
		if (v) then return true end
	end
	
	return false
end

function align_for_attack(id, team, pdir)

	local turn_result = dsb_ai(id, AI_TURN, pdir)
    if (not turn_result) then
		dsb_write(debug_color, "ERROR: ALIGN_FOR_ATTACK TURN BLOCKED")
        return true
	end
	
	-- If they're not yet facing their targets, they were doing a
	-- 180 degree turn and we should let it finish.
	local i = 1
	while (team[i]) do
		if (dsb_get_facedir(team[i].id) ~= pdir) then
			local boss = dsb_ai_boss(team[i].id)
	    	return true
		end
		i = i + 1
	end
	
	return false
end

function do_fearful_move(arch, id, pdir, scan, lev, x, y)
	local face = dsb_get_facedir(id)
	local trydirs
	if (dsb_rand(0, 5) ~= 0) then
		if (dsb_rand(0, 1) == 0) then
			trydirs = {face+1, face+3, face, face+2}
		else
			trydirs = {face+3, face+1, face, face+2}
		end
	else
		if (dsb_rand(0, 1) == 0) then
			trydirs = {face, face+3, face+1, face+2}
		else
			trydirs = {face, face+1, face+3, face+2}
		end
	end
	
	use_exvar(id)
	exvar[id].mai_setdir = nil
	
	if (dsb_rand(0, 3) == 0) then
		if (random_move(id, 1, pdir)) then
			return true
		end
	end
	
	for i=1,8 do
		local ds = true
		local i_n = i
		if (i > 4) then
			i_n = i - 4
			ds = false
		end
		
	    local tdir = trydirs[i_n] % 4

		if (not pdir or tdir ~= pdir) then
			local dx, dy = dsb_forward(tdir)
			if (canigo(arch, id, lev, x + dx, y + dy, ds)) then
				if (arch.instant_turn or 
					tdir ~= ((face+2) % 4))
				then
					dsb_ai(id, AI_MOVE, tdir)
				else
					local rz = 1 + (dsb_rand(0, 1) * 2)
					dsb_ai(id, AI_TURN, (tdir + rz) % 4)
					dsb_ai(id, AI_TIMER, 2)
				end
				
				return true
			end
		end
	end	
	
	-- If we can't move, at least look scared
	dsb_ai(id, AI_TURN, (face + 1) % 4)
	return false
end


function checkshootinglane(filled, hits, fire, dir)
	local altfire = dsb_tileshift(fire, dir)
	if (not filled[fire] and not filled[altfire]) then
	    return fire
	end
	
	if (hits == 2) then
	    local xfire = dsb_tileshift(fire, (dir+1)%2)
	    local altxfire = dsb_tileshift(xfire, dir)
	    if (not filled[xfire] and not filled[altxfire]) then
	        return xfire
		end
	end
	
	return false
end

function sneakuponyousideways(arch, membs, team, interval, dir, lev, x, y, scatter, like_dir)
	if (arch.size == 4) then
	    return false
	end
	
	if (frozen_team_member(membs, team)) then
		return false
	end
	
	local sneaktiles
	local sneakdirs
	local mx

	if (scatter == SC_BACK_ROW_SPLIT) then
		sneaktiles = { (dir + 2)%4, (dir + 3)%4 }
		sneakdirs = { (dir + 1)%4, (dir + 3)%4 }
		mx = 2
	elseif (scatter == SC_BOTH_ROWS_SPLIT) then
	    sneaktiles = { (dir + 2)%4, (dir + 1) % 4, (dir + 3)%4, dir }
	    sneakdirs = { (dir + 1)%4, (dir + 1)%4, (dir + 3)%4, (dir + 3)%4 }
		mx = 4
	elseif (scatter == SC_BREAK_SIDEWAYS) then
		sneaktiles = { dir, dsb_tileshift(dir, (dir+1)%4) } 
		sneakdirs = { (dir + 3)%4, (dir + 3)%4 }
		mx = 2
	elseif (scatter == SC_BREAK_FRONTWARD) then
		sneaktiles = { dir, dsb_tileshift(dir, (dir+1)%4) }
		sneakdirs = { dir, dir }
		mx = 2
	end
	
	local filled = { }
	local ssideshift = { }
	local guysleft = membs
	local sshift
	if (scatter == SC_BACK_ROW_SPLIT or arch.size == 2) then
	    sshift = true
	else sshift = false end

	for i in pairs(team) do
		local ctile = team[i].tile
		if (scatter == SC_BOTH_ROWS_SPLIT and ctile == CENTER) then
			ctile = (dir + dsb_rand(0, 1)) % 4
		end
	    filled[ctile] = team[i].id
	end
	
	ssideshift[0] = nil
	ssideshift[1] = nil
	ssideshift[2] = nil
	ssideshift[3] = nil

	local moves = 0
	local i
	local mydir = false
	local dup = false
	for i=1,mx do
		if (mydir ~= sneakdirs[i]) then
    		mydir = sneakdirs[i]
    		dup = false
		end
	    local me = filled[sneaktiles[i]]
	    if (me) then
	    	local dx, dy = dsb_forward(mydir)
	    	if (dup or canigo(arch, me, lev, x + dx, y + dy, true)) then
				local tx, ty = dsb_forward(dir)
				local rx = x + dx + tx
				local ry = y + dy + ty
				dup = true
				if (scatter > 0 or canigo(arch, me, lev, rx, ry, false)) then
				    local ntile = dsb_tileshift(sneaktiles[i], mydir)
					dsb_move_moncol(me, lev, x + dx, y + dy, ntile, mydir, nil)
					
					local xtime
					if (arch.size ~= 2) then
						dsb_set_facedir(me, mydir)
						xtime = 2
					else
					    xtime = 10
					end
					
					dsb_ai_promote(me)
					dsb_ai(me, AI_TIMER, interval + xtime)
					
					use_exvar(me)
					exvar[me].mai_nogrouping = 3
					if (like_dir) then
						exvar[me].mai_likedir = dir
					end
					
					if (sshift and dsb_rand(0, 2) ~= 0) then
						dsb_msg(6, me, M_REARRANGE, CENTER, me)
					end

					if (arch.on_move) then
						if (not ssideshift[mydir]) then
							arch:on_move(me, true)
							ssideshift[mydir] = true
						else
							arch:on_move(me, false)
						end
					end
					
					moves = moves + 1
					guysleft = guysleft - 1
				end
			end
	    end
	end

	-- Everyone scattered
	if (guysleft == 0) then return 0 end

	if (moves > 0 and guysleft > 0) then
		local i
		for i=0,3 do
		    local idir = (dir + i) % 4
		    if (filled[idir]) then
	    		dsb_ai_promote(filled[idir])
	    		dsb_ai(filled[idir], AI_TIMER, 4)
	    		return filled[idir]
			end
		end
		dsb_write(debug_color, "ERROR: SCATTER MOVEMENT WITH NO PROMOTION")
		return false
	end
	return false
end

function blocking_door(id)
   	local lev, x, y = dsb_get_coords(id)
   	local doorchk = search_for_type(lev, x, y, CENTER, "DOOR")
   	if (doorchk) then
   		if (dsb_get_gfxflag(doorchk, GF_INACTIVE)) then
   			return false
   		end
   		return doorchk
   	end
	return false
end

function begingroupattack(arch, membs, team, interval, bestdir)
	local frozen_blocked = false

	if (arch.on_attack_ranged) then
	    local missile_instead = false
	    
	    if (not arch.dont_shoot_when_close) then
			if (arch.prefer_ranged and dsb_rand(0, 1) > 0) then
				missile_instead = true
			elseif (dsb_rand(0, 4) == 0) then
				missile_instead = true
			end
		end
		
		if (missile_instead) then
		    local mi = beginrangedattack(arch, membs, team, interval, bestdir,
				SHOOT_OPEN_SPACE, nil)
		    if (mi) then return true end
		end
	end

	local sinterval
	if (interval > 8) then
	    sinterval = dsb_rand(4, 8)
	else
	    sinterval = interval
	end
	
	local maxgroup
	if (arch.size == 2) then
	    maxgroup = 2
	else
	    maxgroup = 4
	end
	
	-- Include frozen members for determining blocking and so on
	local realmembs, realteam = dsb_ai_subordinates(team[1].id, true)
	if (realmembs ~= membs) then
	    frozen_blocked = true
	end
	
	local xdir = (bestdir + 1) % 4
	local a_id
	if (membs == 1 and realmembs == 1) then
	    a_id = team[1].id
	    if (team[1].tile ~= CENTER) then
	        local do_shift = false
	        
		    if (team[1].tile ~= bestdir and team[1].tile ~= xdir) then
		        do_shift = true
			elseif (dsb_rand(0, 15) == 0) then
			    if (not exvar[a_id].mai_shootalign) then
			    	do_shift = true
				end
			end

			if (do_shift) then
				if (monster_rearrange(a_id, CENTER, "MELEE")) then
		        	dsb_ai(a_id, AI_TIMER, sinterval)
				end
		        return false
			end
		end

		dsb_msg(0, a_id, M_ATTACK_MELEE, 0)
		
	elseif (membs == maxgroup) then
		local i
		local rt = dsb_rand(0, sinterval)
		
		if (membs == 4 and arch.attack_from_back) then
		    bestdir = dsb_rand(0, 3)
		    xdir = (bestdir + dsb_rand(1, 3)) % 4
		end
		
		for i in pairs(team) do
		    if (team[i].tile == bestdir or team[i].tile == xdir) then
		    	change_exvar(team[i].id, "mai_pendingattack", 1)
		        dsb_msg(rt, team[i].id, M_ATTACK_MELEE, 0)
		        if (rt == 0) then rt = dsb_rand(1, sinterval)
				else rt = 0 end
			end
		end
		
	elseif (arch.attack_from_back and not blocking_door(team[1].id)) then
		local i
	    local rt = dsb_rand(0, sinterval)
	    local attacks = 0
	    
		while (attacks < 2) do
	    	for i in pairs(team) do
			    if (membs == 2 or dsb_rand(0, 3) == 0) then
			        local a_id = team[i].id
			        if (not exvar[a_id].mai_attack) then
			        	change_exvar(a_id, "mai_pendingattack", 1)
			        	dsb_msg(rt, a_id, M_ATTACK_MELEE, 0)
			        	if (rt == 0) then rt = dsb_rand(1, sinterval)
						else rt = 0 end
						attacks = attacks + 1
						if (attacks == 2) then break end
						exvar[a_id].mai_attack = true
					end
				end
			end
		end

	else
		local i
		local rt = dsb_rand(0, sinterval)
		local attacks = 0
		local atk = nil
		local tfrontpos = nil
		local filled = { }
		
		for i in pairs(team) do
			filled[team[i].tile] = team[i].id
		    if (team[i].tile == bestdir or team[i].tile == xdir) then
		        local a_id = team[i].id
		        change_exvar(a_id, "mai_pendingattack", 1)
		        dsb_msg(rt, a_id, M_ATTACK_MELEE, 0)

				if (rt == 0) then rt = dsb_rand(1, sinterval)
				else rt = 0 end

				attacks = attacks + 1
				exvar[a_id].mai_attack = true
				tfrontpos = team[i].tile
			end
		end
		
		-- Don't try to rearrange a frozen group
		if (frozen_blocked) then
		    if (attacks > 0) then
				return true
			else
			    local rfilled = { }
			    local frontblock = 0
			    local blockfrontpos = nil
			    
				for i in pairs(realteam) do
		    		if (realteam[i].tile == bestdir or realteam[i].tile == xdir) then
		    		    rfilled[realteam[i].tile] = true
		    	    	frontblock = frontblock + 1
		    	    	blockfrontpos = realteam[i].tile
					end
				end
				
				if (frontblock == 1) then
					attacks = 1
					tfrontpos = blockfrontpos
				end
		    	
		    	if (frontblock == 2) then
					dsb_ai(team[1].id, AI_UNGROUP, 0)
			    	dsb_ai(team[1].id, AI_HAZARD, 100)
					return false
				end
			end
		end
		
		-- Everyone's standing in the back row
		if (attacks == 0) then
		    if (arch.prefer_ranged and dsb_rand(0, 2) ~= 0) then
		        local mi = beginrangedattack(arch, membs, team, interval, bestdir, QUERY, nil)
				if (mi) then return true end
			end
		    local ndir = dsb_tileshift(bestdir, bestdir)
		    local nxdir = dsb_tileshift(xdir, bestdir)
			dsb_msg(dsb_rand(0, sinterval), filled[ndir], M_REARRANGE, bestdir)
			dsb_msg(dsb_rand(0, sinterval), filled[nxdir], M_REARRANGE, xdir)
			dsb_ai(team[1].id, AI_TIMER, sinterval + 1)
			return false
		end
		
		-- One attack: someone needs to slide to the front
		if (attacks == 1) then
			local emptyfront
			if (tfrontpos == bestdir) then emptyfront = xdir
			else emptyfront = bestdir end
			
			-- Maybe we can fire a shot instead
			if (arch.prefer_ranged and dsb_rand(0, 2) ~= 0) then
			    local hit = beginrangedattack(arch, membs, team, interval, bestdir, QUERY, nil)
				if (hit) then
					return true
				end
			end
			
			local loc = dsb_tileshift(emptyfront, bestdir)
			if (filled[loc]) then
			    dsb_msg(rt, filled[loc], M_REARRANGE, emptyfront)
			    local v = dsb_rand(2, 8)
			    if (rt + v < interval - 2) then
			    	change_exvar(filled[loc], "mai_pendingattack", 1)
			    	dsb_msg(rt + v, filled[loc], M_ATTACK_MELEE, 0)
				end
			else
				loc = dsb_tileshift(tfrontpos, bestdir)

				dsb_msg(0, filled[loc], M_REARRANGE,
					dsb_tileshift(emptyfront, bestdir))

				dsb_set_facedir(filled[loc], bestdir)
			end
		end
	end
	
	return true
end

function beginrangedattack(arch, membs, team, interval, bestdir, why, xscan)
	local i
	local scan
	if (not xscan) then scan = { mon_group = false }
	else scan = xscan end
	local xtime = 0
	local door_block = false
	local shooting_party_through_bars = false
	
	if (not arch.on_attack_ranged) then
		return false
	end

	local rwhy
	if (why == QUERY) then rwhy = 0
	else rwhy = why end
	
	if (arch.boss_ranged_attack_check) then
		local rac = arch:boss_ranged_attack_check(team[1].id, team, rwhy)
		if (rac == false) then return false end
	end
		
	if (bestdir ~= CENTER and why ~= QUERY) then
		door_block = blocking_door(team[1].id)
		if (door_block) then
			if (membs == 1) then
				if (team[1].tile ~= CENTER) then
					dsb_msg(0, team[1].id, M_REARRANGE, CENTER)
					dsb_ai(team[1].id, AI_TIMER, 2)	
					return true
				end
			else
				local filled = { }
		       	local xdir = (bestdir+1) % 4
				for i in pairs(team) do
					filled[team[i].tile] = team[i].id
				end				
				local ndir = dsb_tileshift(bestdir, bestdir)
				local nxdir = dsb_tileshift(xdir, bestdir)
				local did_move = false
				
				if (filled[ndir] and not filled[bestdir]) then
					dsb_msg(dsb_rand(0, 2), filled[ndir], M_REARRANGE, bestdir)
					did_move = true
				end
				if (filled[nxdir] and not filled[xdir]) then
					dsb_msg(dsb_rand(0, 2), filled[nxdir], M_REARRANGE, xdir)
					did_move = true
				end
				
				if (did_move) then
					dsb_ai(team[1].id, AI_TIMER, 3)
					return true
				end
			end
		end
	end
		
	if (rwhy == SHOOT_DOOR_SOLID) then
		if (arch.dont_shoot_doors) then return false end
	    if (not scan.mon_group) then
		    local randshot = team[dsb_rand(1, membs)].id
		    exvar[team[1].id].mai_pending_door = scan.door_id
		    return (arch:on_attack_ranged(randshot, rwhy))
		end
	end
	
	if (rwhy == SHOOT_DOOR_BARS) then
	    local mtype, att_bmp
	    
	    if (arch.dont_shoot_doors) then return false end
	    
		if (type(arch.missile_type) == "function") then
		    mtype, att_bmp = arch:missile_type(team[1].id, rwhy)
		else
		    mtype = determine_missile_type(arch, team[1].id, rwhy)
		    att_bmp = nil
		end
				
  		if (mtype and obj[mtype].go_thru_bars) then
  			if (scan.visible and scan.reach) then
  				shooting_party_through_bars = true
  			else
  		    	exvar[team[1].id].mai_missile = mtype
  		    	exvar[team[1].id].mai_att_bmp = att_bmp
  		    	why = QUERY
  		    end
  		else
  			return false
		end
	end

	if (bestdir ~= CENTER) then
	    local narrow = false
		local xdir = (bestdir + 1) % 4
		local backbestdir = dsb_tileshift(bestdir, bestdir)
		local backxdir = dsb_tileshift(xdir, bestdir)

		local hits = 0
		local fire_side = nil
		if (dsb_tile_ppos(bestdir) or 
			dsb_tile_ppos(backbestdir)) 
		then
		    hits = hits + 1
		    fire_side = bestdir
		end
		if (dsb_tile_ppos(xdir) or 
			dsb_tile_ppos(backxdir)) 
		then
		    hits = hits + 1
		    fire_side = xdir
		end
		
		-- Don't shoot if it's just the ghost
		if (hits == 0) then
		    return false
		end
		
		local centered = false
		if (membs == 1) then
		    if (team[1].tile == CENTER) then
				centered = true
			end
		end
		
		local firepos
		if (hits == 2) then
		    if (dsb_rand(0, 2) == 0) then
		    	firepos = { bestdir, backbestdir, xdir, backxdir }
			else
				if (dsb_rand(0, 1) == 0) then
					firepos = { bestdir, xdir, backxdir, backbestdir }
				else
			    	firepos = { xdir, bestdir, backbestdir, backxdir }
			    end
			end
		else
		    firepos = { fire_side, dsb_tileshift(fire_side, bestdir) }
		end
		
		local filled = { }
		for i in pairs(team) do
			filled[team[i].tile] = team[i].id
		end

		-- See if there's somebody in traffic and get them to move
		-- if I'm smart enough to coordinate an attack
		if (scan.mon_group and not scan.nonmat_blocker) then		
			local attackv
			local otherboss = dsb_ai_boss(scan.mon_group)
			attackv = coordinateattack(arch.smart, team[1].id, bestdir, 
				otherboss, hits, firepos[1])
			if (not attackv) then
			    local s
			    if (interval < 4) then s = interval else s = 4 end
			    dsb_ai(team[1].id, AI_TIMER, s)
			    return false
			end
			
			-- Narrow means I'm shooting down a small lane and I won't
			-- take random shots on the wrong side or I'll hit someone
			if (type(attackv) == "table") then
				narrow = true
				firepos = attackv.dtable
				hits = attackv.hits
			end
			
		end
		
	    if (centered) then
	        local a_id = team[1].id
	        exvar[a_id].mai_bestside = firepos[1]
	        if (rangedammocheck(arch, a_id, rwhy)) then
	        	dsb_msg(0, team[1].id, M_ATTACK_RANGED, rwhy)
				return true
			else
				return false
			end
		end
		
		-- Fire a shot for anyone that is actually in position
        local f
	    local shots = 0
	    local shot_side = nil
	    local shot_limit = 2
	    for f=1,(hits*2) do
			local fpos = firepos[f]
			if (filled[fpos]) then
			    local a_id = filled[fpos]
			        if (not exvar[a_id].mai_attack) then
			        	if (rangedammocheck(dsb_find_arch(a_id), a_id, rwhy)) then
			        		change_exvar(a_id, "mai_pendingattack", 1)
							dsb_msg(shots*3, a_id, M_ATTACK_RANGED, rwhy)
							xtime = shots*3 + 1
							shots = shots + 1
							shot_side = fpos
						end
					end
				if (shots == shot_limit) then break end
			end
	    end
	    
	    -- Now, move guys who couldn't shoot into a position where
	    -- they might be able to. QUERY doesn't move anyone, because
	    -- the code that is calling it will try to do other things.
	    
	    -- Everyone's on the wrong side, scoot and shoot
	    if (shots == 0) then
	    	local all_attacks_failed = true
	    	
			if (why == QUERY) then
				return false
			end
			
			if (membs == 1 and not centered) then
		        dsb_msg(0, team[1].id, M_REARRANGE, CENTER)
		        dsb_ai(team[1].id, AI_TIMER, 2)
		        return true
			end
			
	        local t = 0
	        local moved = 0
			for f=0,3 do
				if (filled[f]) then
				    local newpos = dsb_tileshift(f, xdir)
				    local sv = dsb_rand(0 + t, 2 + t)
				    local move_failed = true
				    local move_around = true
				    
				    -- Occasionally fire both sides (hits spin dodgers)
				    if (moved > 0) then
					    if (arch.smart or arch.crafty or (dsb_rand(0, 5) == 0)) then
					    	if (not arch.stupid and not narrow and not arch.dont_waste_ammo) then
					    		if (not exvar[team[1].id].mai_twoshot) then
					    			move_around = false
					    			move_failed = false
					    			exvar[team[1].id].mai_twoshot = dsb_rand(2, 5)					    			
									if (arch.smart) then
					    				sv = 1
					    			else
					    				sv = t
					    			end					    			
					    		end
							end
					    end
					end
					
					if (narrow or arch.dont_waste_ammo or move_around) then
						if (not filled[newpos]) then
					    	dsb_msg(sv, filled[f], M_REARRANGE, newpos)
					    	move_failed = false
					    	moved = moved + 1
					    end
					end

					if (not move_failed) then
						if (rangedammocheck(dsb_find_arch(filled[f]), filled[f], rwhy)) then
							change_exvar(filled[f], "mai_pendingattack", 1)
							dsb_msg(sv + 3, filled[f], M_ATTACK_RANGED, rwhy)
							all_attacks_failed = false
							
						end
					end
					
	                xtime = sv + t + 3
	                t = 3
				end
			end
			
			if (all_attacks_failed) then
				-- This has to be true because otherwise the calling code
				-- will try to pretend like it's shooting at a solid door
				-- even though our attack failed
				if (shooting_party_through_bars) then
					return true
				else
					return false
				end
			end
	    end
	    
	    -- Someone is on the wrong side, let's either shift or double-shot
	    -- If we don't prefer ranged attacks, don't screw with our positions
	    -- Also, randomly center a single guy (but he's hitting, so maybe not)
	    if (shots == 1) then

			if (why == QUERY or shooting_party_through_bars) then
		    	if (interval < xtime) then
	        		dsb_ai(team[1].id, AI_DELAY_ACTION, xtime)
				end				
				return true
			end

			if (membs == 1) then
				if (not centered and dsb_rand(0, 15) == 0) then
			        dsb_msg(0, team[1].id, M_REARRANGE, CENTER)
				end
				return true
			end
			
			-- If I'm double width this is the best I can do here
			if (hits == 1 and arch.size == 2) then return true end
			
			-- Don't mess around if I'm in a narrow shooting lane
			if (narrow) then return true end
			
			local take_twoshot = false
			if (exvar[team[1].id].mai_twoshot) then
				if (exvar[team[1].id].mai_twoshot > dsb_rand(1, 4)) then
					take_twoshot = true
				end
			end
			
			if (take_twoshot or not arch.prefer_ranged or
				(dsb_rand(0, 2) == 0 and not arch.dont_waste_ammo)) 
			then
			    local wrong = dsb_tileshift(shot_side, xdir)
			    local wrongpos = { wrong, dsb_tileshift(wrong, bestdir) }
			    
				if (arch.dont_waste_ammo and dsb_rand(0, 2) > 0) then
					-- Don't do anything yet
				else		
					for f=1,2 do
						local fpos = wrongpos[f]
						if (filled[fpos] and
							rangedammocheck(dsb_find_arch(filled[fpos]), filled[fpos], rwhy))
						then
							local rval = dsb_rand(1, 4)
							change_exvar(filled[fpos], "mai_pendingattack", 1)
							dsb_msg(rval, filled[fpos], M_ATTACK_RANGED, rwhy)
							if (rval > xtime) then xtime = rval end
							break
						end
					end
				end
			else
			    local moved = false
			    local rightpos = { shot_side, dsb_tileshift(shot_side, bestdir) }
				for f=1,2 do
					local fpos = rightpos[f]
					if (not filled[fpos]) then
						local otherside = dsb_tileshift(fpos, xdir)
						if (filled[otherside]) then
							local rtime = dsb_rand(1, 3)
							if (xtime < rtime) then xtime = rtime end
						    dsb_msg(rtime, filled[otherside], M_REARRANGE, fpos)
						    moved = true
						    break
						end
					end
				end

				if (not moved) then
				    local wrong = dsb_tileshift(shot_side, xdir)
				    local wrongpos = { wrong, dsb_tileshift(wrong, bestdir) }
				    for f=1,2 do
						local fpos = wrongpos[f]
						if (filled[fpos]) then
						    local newpos = dsb_tileshift(fpos, bestdir)
						    local rtime = dsb_rand(1, 3)
						    if (xtime < rtime) then xtime = rtime end
							dsb_msg(rtime, filled[fpos], M_REARRANGE, newpos)
							break
						end
					end

				end
				
			end
	    end
	    
	    -- Don't shoot and move too fast or we'll walk into our own stuff
	    if (interval < xtime) then
	        dsb_ai(team[1].id, AI_DELAY_ACTION, xtime)
		end
		return true
	end

	return false
end

function rangedammocheck(arch, id, why_shoot)
	if (not arch.ranged_attack_check) then
		return true
	end
	
	local rt = arch:ranged_attack_check(id, why_shoot)
	return rt
end

function coordinateattack(smart_coord, invoker, dir, boss, hits, fire)
	local i

	if (not exvar[boss]) then exvar[boss] = { } end
	
	local arch = dsb_find_arch(boss)
	
	if (arch.nonmat) then
	    return true
	end
	
	local interval = arch.act_rate
	local lev, x, y, btile = dsb_get_coords(boss)
	local face = dsb_get_facedir(boss)
	
	local membs, team = dsb_ai_subordinates(boss, true)
	
	local filled = { }
	for i in pairs(team) do
	    local it = team[i].tile
	    
		filled[it] = team[i].id
		if (arch.size == 2 and it ~= CENTER) then
		    filled[dsb_tileshift(it, face)] = team[i].id
		end
	end
	
    local v
    if (btile ~= CENTER) then
	    v = checkshootinglane(filled, hits, fire, dir)
	    if (v) then
	        teamlockmsg(team, M_ALIGNED, 22)
	    	return { dtable = { v, dsb_tileshift(v, dir) }, hits = 1 }
		end
	end
	
	if (not smart_coord) then
		return false
	end
	
	-- Stupid monsters are too stupid to even be bossed around
	if (arch.stupid) then
		return false
	end
	
	-- Can't coordinate with a frozen team member sitting there
	if (frozen_team_member(membs, team)) then
	    return false
	end
	
    local total_delay = dsb_ai(boss, AI_TIMER, QUERY) + dsb_ai(boss, AI_DELAY_ACTION, QUERY)
	if (total_delay <= 5) then
	    -- Slide out of here and create a narrow firing lane
		if (membs == 1 and arch.size < 4) then
		    local pos_ok
		    
			-- Size 2 monsters will get smacked if they're sideways
			if (arch.size == 2 and face ~= dir and face ~= (dir+2)%4) then
		        pos_ok = false
			else
			    pos_ok = true
			end
			
		    if ((btile == CENTER or btile == fire) and pos_ok) then
				local npos
				if (btile == CENTER) then
				    npos = dsb_tileshift(fire, (dir + 1) % 4)
				    -- Facing away needs to shift to the other slot
				    if (arch.size == 2 and face == (dir + 2) % 4) then
				        npos = dsb_tileshift(npos, dir)
					end
		        else
		        	npos = dsb_tileshift(btile, (dir + 1) % 4)
				end
				
				if (monster_rearrange(boss, npos, "SHOOT")) then
				    dsb_msg(0, boss, M_ALIGNED, 1)
				    dsb_msg(32, boss, M_ALIGNED, 0)
				    return { dtable = { fire, dsb_tileshift(fire, dir) },
						 hits = 1 }
				end
				return false
		    end
		end
		
		if (hits == 1 or (dsb_rand(0, 3) == 0)) then
			local sctype
			if (dir == fire) then sctype = SC_BREAK_SIDEWAYS
			else sctype = SC_BREAK_FRONTWARD end	
						 
			v = sneakuponyousideways(arch, membs, team, interval, 
				fire, lev, x, y, sctype, false)
		else
			v = sneakuponyousideways(arch, membs, team, interval,
				dir, lev, x, y, SC_BOTH_ROWS_SPLIT, false)
		end
		
		if (v == 0) then
		    temporaryblock(lev, x, y, 12)
			return true
		end
		
		if (v) then
			-- Recalculate team and filled matrix after change
			local newmembs, newteam = dsb_ai_subordinates(v, true)
			filled = { }
			for i in pairs(newteam) do
			    local it = newteam[i].tile		    
				filled[it] = newteam[i].id
				if (arch.size == 2 and it ~= CENTER) then
				    filled[dsb_tileshift(it, face)] = newteam[i].id
				end
			end
			
		    local lane = checkshootinglane(filled, hits, fire, dir)
		    if (lane) then
		        teamlockmsg(team, M_ALIGNED, 22)
		    	return { dtable = { lane, dsb_tileshift(lane, dir) }, hits = 1 }
			end
		end
	end

	return false
end

function monster_rearrange(id, data, reason)
	use_exvar(id)

    -- Prevent too much random shuffling
	if (exvar[id].mai_arrange) then
    	return false
    end

	-- Don't arrange into someone's fireball
	if (reason ~= "SHOOT") then
		if (exvar[id].mai_shootalign) then
	    	return false
	    end
	    
	    if (exvar[id].mai_groupalign) then
	    	return false
	    end
	end
	
	local lev, x, y, tpos = dsb_get_coords(id)
	-- There's really nothing to do if I'm floating around elsewhere...
	if (lev < 0) then
		return true
	end
	
	-- If I'm already where I want to be, it "fails", but differently
	if (tpos == data) then return nil end
	
	-- Make sure nobody's already occupying the position we want
	local whatsthere = dsb_fetch(lev, x, y, data)
	if (whatsthere) then
		local i
		for i in pairs(whatsthere) do
			local i_arch = dsb_find_arch(whatsthere[i])
			if (i_arch.type == "MONSTER") then
				return false
			end
		end
	end

	dsb_reposition(id, data)
	exvar[id].mai_arrange = true
	return true
end

function monster_meleemsg(id, data)
	local mon_arch = dsb_find_arch(id)
	if (exvar[id] and exvar[id].mai_pendingattack) then
		exvar[id].mai_pendingattack = nil
	end
	mon_arch:on_attack_close(id)
end

function monster_missilemsg(id, data)
	local mon_arch = dsb_find_arch(id)
	if (exvar[id] and exvar[id].mai_pendingattack) then
		exvar[id].mai_pendingattack = nil
	end
	mon_arch:on_attack_ranged(id, data)
end

function monster_alignmsg(id, data)
	if (data == 1) then
	    change_exvar(id, "mai_shootalign", 1)
	else
		change_exvar(id, "mai_shootalign", -1)
	end
end

function monster_turnmsg(id, data)
	local f = dsb_get_facedir(id)
	if (f == (data+2) % 4) then
		ndir = data + 1
		if (dsb_rand(0, 1) == 0) then ndir = ndir + 2 end
		ndir = ndir % 4
		dsb_set_facedir(id, ndir)
		dsb_msg(2, id, M_TURN, data)		
		local boss = dsb_ai_boss(id)
		if (dsb_ai(boss, AI_TIMER, QUERY) < 3) then
			dsb_ai(boss, AI_TIMER, 3)
		end
	else
		dsb_set_facedir(id, data)
	end
end

function monster_pouncemsg(id, data)
	local lev, x, y = dsb_get_coords(id)
	-- There's really nothing to do if I'm floating around elsewhere...
	if (lev < 0) then
		return true
	end
	
	local p_lev, p_x, p_y = dsb_party_coords()
	local cur_pdir, cur_range = linedirfrom(x, y, p_x, p_y)
	
	if (cur_pdir ~= data or p_lev ~= lev or cur_range ~= 1) then
	    return false
	end
	
	change_exvar(id, "mai_pounced", 2)
	
	local membs, team = dsb_ai_subordinates(id)
	if (align_for_attack(id, team, cur_pdir)) then
		return true
	end
	
	local arch = dsb_find_arch(id)
	local interval = arch.act_rate
	begingroupattack(arch, membs, team, interval, cur_pdir)

end

function monster_specialmsg(id, data)
	local lev, x, y = dsb_get_coords(id)
	-- There's really nothing to do if I'm floating around elsewhere...
	if (lev < 0) then
		return true
	end
	
	local mon_arch = dsb_find_arch(id)
	if (mon_arch.on_special) then
		mon_arch:on_special(id, dsb_ai_boss(id))
	end
end

function monster_suspendcheckmsg(id, data)
	local boss = dsb_ai_boss(id)
	if (not exvar[id] or not exvar[id].mai_suspend) then
		return
	end
	if (boss ~= id) then
		exvar[id].mai_suspend = nil
		return
	end
	
	local diag = false
	local lev, x, y = dsb_get_coords(id)
	-- There's really nothing to do if I'm floating around elsewhere...
	if (lev < 0) then
		return true
	end
	local p_lev, p_x, p_y = dsb_party_coords()
	
	if (p_lev == lev) then
		if (p_x ~= x and p_y ~= y) then
			diag = true
		end
	end
	
	-- No waiting if the party goes to sleep
	if (dsb_get_sleepstate()) then
		dsb_ai(id, AI_TIMER, dsb_rand(2, 4))
		exvar[id].mai_suspend = nil
		return
	end
	
	-- No longer in position
	if (not diag) then
		dsb_ai(id, AI_TIMER, 1)
		exvar[id].mai_suspend = nil
		return
	else
		local dir, range = approxlinedirfrom(x, y, p_x, p_y, exvar[id].mai_suspend)
		
		-- Moved away, do something else
		if (range > 3) then
			dsb_ai(id, AI_TIMER, dsb_rand(1, 3))
			exvar[id].mai_suspend = nil
			return
		end
		
		local curdir = dsb_get_facedir(id)
		if (not dir or dir == curdir) then 
			dsb_msg(1, id, M_SUSPEND_CHECK, 0)
		else
			if (dir == (curdir + 2) % 4) then
				dir = (curdir + 1 + (2 * dsb_rand(0, 1))) % 4
			end
			dsb_ai(id, AI_TURN, dir)
			dsb_msg(2, id, M_SUSPEND_CHECK, 0)
			if (range <= 2 and (dsb_rand(0, 2) == 0)) then
				dsb_ai(id, AI_DELAY_TIMER, 2)
			end
		end
	end 
end

function temporaryblock(lev, x, y, time, bl_arch)
	local mblock = dsb_spawn("monster_blocker", lev, x, y, CENTER)
	if (bl_arch) then
		exvar[mblock] = { blocks = bl_arch }
	end
	dsb_msg(time, mblock, M_DESTROY, 0)
end

function teamlockmsg(team, msg, delay)
	local i
	for i in pairs(team) do
	    local id = team[i].id
		dsb_msg(0, id, msg, 1, id)
		dsb_msg(delay, id, msg, 0, id)
	end
end

monster_msg_handler = {
	[M_DESTROY] = monster_hptozero,
	[M_CLEANUP] = clean_up_target_exvars,
	[M_STOPATTACK] = monster_stopattack,
	[M_UNFREEZE] = monster_unfreeze,
	[M_TINT] = monster_tintreset,
	[M_REARRANGE] = monster_rearrange,
	[M_TURN] = monster_turnmsg,
	[M_ATTACK_MELEE] = monster_meleemsg,
	[M_ATTACK_RANGED] = monster_missilemsg,
	[M_ALIGNED] = monster_alignmsg,
	[M_SUSPEND_CHECK] = monster_suspendcheckmsg,
	[M_POUNCE] = monster_pouncemsg,
	[M_SPECIAL] = monster_specialmsg
}

-- The attack_delay value in a monster's descriptor lets the
-- monster attack slower than it moves. You can also give it a
-- negative value and it lets slow monsters attack faster, but I'd
-- rather not rely on the monster being able to carry out an
-- attack to speed up some of the slower monsters, because it
-- forces them to just sit there and get hit if players are good at 
-- dodging around them and denying them a chance to even attack.
-- I'll add a tweak based on whether the monster is being damaged.
--
-- As of DSB 0.68, I understand a little more how DM's monster
-- timers work. Telling slow monsters to wake up is handled by
-- timer 31, and actually works similarly to how I made it work
-- in DSB before I understood this part of the DM AI code.
-- As such, I can leave this code mostly intact, but change how
-- it is actually called, trying to behave more like a timer 31.
function motivate_slothful_monsters(id)
	local myboss = dsb_ai_boss(id)
	
	-- frozen monsters will never be motivated
    if (dsb_get_gfxflag(myboss, GF_FREEZE)) then
		return
	end
	
	if (exvar[myboss]) then
		if (exvar[myboss].mai_nowake) then
			return
		end
	end
	
	local arch = dsb_find_arch(myboss)
	local tta = dsb_ai(myboss, AI_TIMER, QUERY)
	
	local quickrate = arch.quick_act_rate
	if (not quickrate) then
		quickrate = math.floor(arch.act_rate / 2)
		if (quickrate < 3) then quickrate = 3 end
	end
	
	if (tta > quickrate) then
		dsb_ai(myboss, AI_TIMER, quickrate)
	end
	
	-- Make sure monsters that got smacked don't just stand there
	if (exvar[myboss]) then
		if (exvar[myboss].mai_suspend) then
			exvar[myboss].mai_suspend = nil
			dsb_ai(myboss, AI_TIMER, dsb_rand(1, 2))
		end
	end
end

function add_monster_target(id, ttl, x, y)
	use_exvar(id)
	if (not exvar[id].mai_targetlist) then
		exvar[id].mai_targetlist = { }
	end	

    local tid = x .. "_" .. y
    if (exvar[id].mai_targetlist[tid]) then
    	if (ttl > exvar[id].mai_targetlist[tid].ttl) then
    		exvar[id].mai_targetlist[tid].ttl = ttl
    	end
	else
		exvar[id].mai_targetlist[tid] = {
			x = x, y = y, ttl = ttl
		}
	end	 	
	
end

function del_monster_target(id, x, y)
	if (not exvar[id]) then return end
	if (not exvar[id].mai_targetlist) then return end
	
	local tid = x .. "_" .. y	
	if (not exvar[id].mai_targetlist[tid]) then return end
	
	local supersede = exvar[id].mai_targetlist[tid].sprc
	exvar[id].mai_targetlist[tid] = nil

	delete_superseded_targets(id, supersede)	
end


function update_monster_targetlist(id)
	local deletions = { }
	local delnum = 1
	
	use_exvar(id)
	if (exvar[id].mai_targetlist) then
		for i in pairs(exvar[id].mai_targetlist) do
			exvar[id].mai_targetlist[i].ttl =
				exvar[id].mai_targetlist[i].ttl - 1
			if (exvar[id].mai_targetlist[i].ttl == 0) then
				-- You can't modify the array you're currently iterating over
				deletions[delnum] = i
				delnum = delnum + 1
			end			
		end
		
		if (delnum > 1) then
			for dn=1,(delnum - 1) do
				local df = deletions[dn]
				local supersede = exvar[id].mai_targetlist[df].sprc
				exvar[id].mai_targetlist[df] = nil
				delete_superseded_targets(id, supersede)			
			end
		end
		
	end
end

function delete_superseded_targets(id, supersede)
	if (supersede) then
		for sp in pairs(supersede) do
			local spcn = supersede[sp]
			del_monster_target(id, spcn.x, spcn.y)
		end
	end	
end

function decrement_and_delete(id, exvar_name, dec)
	if (exvar[id][exvar_name]) then
	    exvar[id][exvar_name] = exvar[id][exvar_name] + dec
	    if (exvar[id][exvar_name] <= 0) then
	        exvar[id][exvar_name] = nil
		end
	end
end


function frozen_team_member(membs, team)
	for t in pairs(team) do
		local id = team[t].id
		if (dsb_get_gfxflag(id, GF_FREEZE)) then
		    return true
		end
	end
	
	return false
end
