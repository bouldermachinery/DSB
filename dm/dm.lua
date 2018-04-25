-- These changes are needed to make the DM dungeon work as expected in DSB
-- (This file is up to date as of DSB 0.58)

-- Doors and false walls open, and counters increment
-- Just change around the message handlers
door_msg_handler[M_ACTIVATE] = "door_open"
door_msg_handler[M_DEACTIVATE] = "door_close"
movable_wall_msg_handler[M_ACTIVATE] = "wall_disappears"
movable_wall_msg_handler[M_DEACTIVATE] = "wall_appears"
counter_msg_handler[M_ACTIVATE] = "counter_up"
counter_msg_handler[M_DEACTIVATE] = "counter_down"

-- This stuff in DM responds to clears
generator_msg_handler[M_DEACTIVATE] = "generate_monster"
shooter_msg_handler[M_DEACTIVATE] = "shooter_shoot"

-- function print_instance(id)
--    print("PRINTING INSTANCE: " .. id)
--    local gfx = "FALSE"
--    if dsb_get_gfxflag(id, GF_INACTIVE) then
-- 	  gfx = "TRUE"
--    end
--    print("GFXFLAG: " .. gfx)
--    if exvar[id] then
-- 	  print("EXVAR: " .. inspect(exvar[id]))
--    end
--    local lev,x,y,pos = dsb_get_coords(id)
--    print("POSITION: " ..lev .. " " .. x .. " " .. y .. " " .. pos)
-- end

function csb_local_rotate(id, what)
   local lev, x, y, pos = dsb_get_coords(id)


   -- print("-------------- BEFORE ROTATE")
   -- print_instance(271)
   -- print_instance(272)
   -- print_instance(273)
   -- print_instance(274)

   dsb_tileptr_rotate(lev, x, y, pos)

   -- print("-------------- AFTER ROTATE")
   -- print_instance(271)
   -- print_instance(272)
   -- print_instance(273)
   -- print_instance(274)
   
end

function csb_win_game()
	dsb_lock_game()
	dsb_delay_func(60, function()
		dsb_game_end()
	end)
end

function csb_clear_blacklist()
	dsb_delay_func(1, function()
		for x in pairs(exvar) do
			exvar[x].blacklist = nil
		end
	end)
end

function sys_game_export()
	csb_clear_blacklist()
end

csb_clear_blacklist()