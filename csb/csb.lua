-- These changes are needed to make the CSB dungeon work as expected in DSB
-- (This file is up to date as of DSB 0.58)

-- Start in the prison
DUNGEON_FILENAME = "prison.lua"
COMPILED_DUNGEON_FILENAME = "prison.dsb"
-- And go to the dungeon
TARGET_FILENAME = "dungeon.lua"
COMPILED_TARGET_FILENAME = "dungeon.dsb"

-- Doors and false walls open, and counters increment
-- Just change around the message handlers
door_msg_handler[M_ACTIVATE] = "door_open"
door_msg_handler[M_DEACTIVATE] = "door_close"
movable_wall_msg_handler[M_ACTIVATE] = "wall_disappears"
movable_wall_msg_handler[M_DEACTIVATE] = "wall_appears"
counter_msg_handler[M_ACTIVATE] = "counter_up"
counter_msg_handler[M_DEACTIVATE] = "counter_down"

-- This stuff in CSB responds to clears
generator_msg_handler[M_DEACTIVATE] = "generate_monster"
shooter_msg_handler[M_DEACTIVATE] = "shooter_shoot"

monster_level_info = {
	[0] = { "blackflame", "demon2", "greylord", "lordchaos", "worm2b", "zytaz" },
	[1] = { "giggler", "golem", "hellhound", "mummy", "rockpile" }, -- Rockpile is here as a hack to make the prison work...
	[2] = { "blackflame", "demon2", "giggler", "golem", "knight_deth", "rockpile" },
	[3] = { "giggler", "dragon", "mummy", "skeleton" },
	[4] = { "gazer", "golem", "scorpion", { "worm2b", "worm2y" }, "worm2y" },
	[5] = { "couatl", "giggler", "rive", "slimedevil" },
	[6] = { "antman",  "giggler", "mummy", "rive", "waterelem" },
	[7] = { "giggler", "knight_deth", "muncher", "oitu2", "rockpile", "screamer" },
	[8] = { "giggler", "knight_deth", "mummy", "muncher", "vexirk2" },
	[9] = { "giggler", "dragon", "worm2b" }
}

function csb_local_rotate(id, what)
	local lev, x, y, pos = dsb_get_coords(id)
	
	dsb_tileptr_rotate(lev, x, y, pos)
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