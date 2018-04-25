-- LUADSB, a Lua core for DSB
-- Please see https://dmwiki.atomas.com/wiki/DSB

DSB_VERSION="0.68"

LUADSB_VERSION="luadsb 0.1"

print("\n~ Dungeon Strikes Back ~")
print("DSB " .. DSB_VERSION)
print(LUADSB_VERSION)
major, minor, revision, codename = love.getVersion()
print("LOVE " .. major .. "." .. minor .. "."  .. revision .. " \"" .. codename .. "\"")
print("" .. _VERSION)
print("" .. love.system.getOS())
print()

if major < 11 then
   print("\n\n!!! ERROR: Please use LOVE >= 11.0 !!!\n\n")
   os.exit(1)
end

-- local fun = require "fun"

-------------
-- Globals --
-------------

is_love = true

dungeon = "dm"
-- dungeon = "csb"
-- dungeon = "Eoc"

obj = {}
images = {}

STATE_INTRO = -1
STATE_MOVE = 0
STATE_INVENTORY = 1
STATE_OFFER = 2
STATE_SAVE = 3
STATE_END = 4

g_state = STATE_INTRO
g_lock = 0
g_character = nil

dark_grey = {75,75,75}
light_grey = {125,125,125}

base_background = dark_grey;
xp_skillnames = { {"SWING", "THRUST", "CLUB", "PARRY"},
   {"CLIMB", "FIGHT", "THROW", "SHOOT"},
   {"LUCK", "POTIONS", "FEAR", "SHIELDS"},
   {"FIRE","AIR","EARTH","WATER"} }
exports = {}
sounds = {}
bitmap_id = 0
intro_time = 0

function reset_globals()
   g_characters = {}
   g_conditions = {}
   g_next_condition = 0
end


function reset_game()
   base_background = dark_grey -- change from pink
   bitmap_id = dungeon_bitmap_id + 1

   g_next_id = -1
   g_rclock = 0
   g_last_party_move = 0
   -- g_last_monster_attack = nil
   -- g_rclock = nil
   -- g_illum = nil
   -- g_footprint_counter = nil
   -- g_disabled_runes = nil
   -- g_total_pit_damage = nil

   -- TODO: g_state = {}
   g_frame = 0
   g_frame_counter = 0
   g_next_char = 0
   g_lights = {}
   g_console = {}
   g_new_messages = {}
   g_message_id = 0
   g_message_chains = {}

   reset_globals()

   last_color = {255,255,255}
   dark_level = nil

   messages = {}
   delay_functions = {}
   id_table = {}
   champions = {}
   world = {}
   wallitems = {}
   flying_instances = {}

   damage_amount = 0
   trace = 1

   party = {}
   party.id = 0
   party.leader = 0
   party.conditions = {}
   party.positions = {}
   party.magician = 0
   party.triggers = {}

   fullscreen_return = 0

   exvar = {}
   ch_exvar = {}

   id_table = {}
   dsb_table = {}

   drop_holding()
   love.mouse.setVisible(false)

   g_state = STATE_MOVE
end


--------------------
-- LOVE callbacks --
--------------------

function love.load()
   love.window.setTitle(LUADSB_VERSION .. " (dsb " .. DSB_VERSION .. ")")
   init_game()
   start_game()
end


function love.update(dt)
   if g_state == STATE_END then
	  return
   elseif g_state == STATE_INTRO then
	  intro_time = intro_time + dt
	  if intro_time > 5 then
		 dsb_bitmap_clear(fullscreen_bitmap, {0,0,0})
		 start_game()
	  end
   elseif g_state == STATE_SAVE then
	  return
   else
	  g_frame = g_frame + dt

	  frame_time = 0.2
	  if dsb_get_sleepstate() then
		 frame_time = 0.005
	  end
	  if g_frame > 0.04 and fullscreen_func then
		 love.graphics.setCanvas()
		 local result = fullscreen_func(fullscreen_bitmap, mouse_x(), mouse_y())
		 if result == 0 then
			state = STATE_MOVE
			fullscreen_func = nil
			fullscreen_click = nil
			sys_game_beginplay()
			dsb_bitmap_clear(fullscreen_bitmap, {0,0,0})
			update_view()
		 end
		 g_frame = 0
	  elseif g_frame > frame_time then
		 update_dungeon()
		 g_frame = 0
	  end
   end
end


function love.run()

   if love.math then
	  love.math.setRandomSeed(os.time())
   end

   if love.load then love.load(arg) end

   -- We don't want the first frame's dt to include time taken by love.load.
   if love.timer then love.timer.step() end

   local dt = 0

   -- Main loop time.
   while true do
	  -- Process events.
	  if love.event then
		 love.event.pump()
		 for name, a,b,c,d,e,f in love.event.poll() do
			if name == "quit" then
			   if not love.quit or not love.quit() then
				  return a
			   end
			end
			love.handlers[name](a,b,c,d,e,f)
		 end
	  end

	  -- Update dt, as we'll be passing it to update
	  if love.timer then
		 love.timer.step()
		 dt = love.timer.getDelta()
	  end

	  -- Call update and draw
	  if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

	  if love.graphics and love.graphics.isActive() then
		 love.graphics.clear(love.graphics.getBackgroundColor())
		 love.graphics.origin()
		 if love.draw then love.draw() end
		 love.graphics.present()
	  end

	  if love.timer then love.timer.sleep(0.001) end
   end
end


function update_monsters()
   for _,monster in pairs(world[party.pos[1]].monsters) do
	  local arch = monster.arch
	  if math.fmod(g_frame_counter,arch.shift_rate) == 0 then	  
		 local fear = monster.fear
		 if fear and fear > 0 then
			monster.fear = monster.fear - 1
			if monster.fear == 0 then
			   monster.fear = nil
			end
		 end

		 if monster.timer and monster.timer > 0 then
			monster.timer = monster.timer - 1
		 elseif true then -- monster.id == 100 then
			sys_ai_near(monster.id, 10, 0)
			-- sys_ai_far(monster.id)
			if dsb_rand(0,4) == 0 then
			   monster.flip = not monster.flip
			end
			if dsb_rand(0,1) == 0 then
			   monster.offx = dsb_rand(0,4) - 2
			   monster.offy = dsb_rand(0,4) - 2
			end
		 end
	  end
   end
end


function update_dungeon()
   if dsb_rand(1,100) == 0 then
	  save_game(savefile)
	  load_game(savefile)
   end

   g_frame_counter = g_frame_counter + 1

   if restart_timer then
	  restart_timer = restart_timer - 1
	  if restart_timer <= 0 then
		 restart_timer = nil
		 dsb_game_end()
		 -- love.event.quit()
	  end
	  return
   end

   if math.fmod(g_frame_counter, 1) == 0 then
	  update_monsters()
   end

   if math.fmod(g_frame_counter, 4) == 0 then
	  update_flying()
   end

   if math.fmod(g_frame_counter, 1) == 0 then
	  party_move()
	  update_view()
   end

   if math.fmod(g_frame_counter, 1) == 0 then
	  local old = {}
	  for _,message in pairs(g_new_messages) do
		 messages[message[6]] = message
	  end
	  g_new_messages = {}
	  for _,message in pairs(messages) do
		 message[1] = message[1] - 1
		 if message[1] <= 0 then
			old[message[6]] = message
			handle_msg(message)
		 end
	  end
	  for _,message in pairs(old) do
		 messages[message[6]] = nil
	  end
   end

   if math.fmod(g_frame_counter, 1) == 0 then
	  for ppos = 0,3 do
		 if get_ppos(ppos) then
			local idle = dsb_get_idle(ppos)
			if idle > 0 then
			   dsb_set_idle(ppos, idle - 1)
			end
		 end
	  end
   end

   if math.fmod(g_frame_counter, 100) == 0 then
	  sys_update(dt)
   end

   -- go backwards so table.remove works
   for i=#delay_functions,1,-1 do
	  local df = delay_functions[i]
	  if df then
		 local delay = df[1]
		 local func = df[2]
		 if delay == END_OF_FRAME then
			func()
			table.remove(delay_functions, i)
		 else
			df[1] = df[1] - 1
			if df[1] == 0 then
			   func()
			   table.remove(delay_functions, i)
			end
		 end
	  end
   end

   local dead = everyone_dead()
   if dead then
	  dsb_write({190,212,176}, "EVERYONE DIED.")
	  restart_timer = sys_everyone_dead()
   end
end


function draw_slot(n)
   local info = inventory_info[n]
   dsb_objzone(view_bitmap, SYSTEM, n, info.x, info.y, inventory_ppos())
end


function draw_character(tile)
   local ppos = party.positions[tile]
   if ppos and valid_and_alive(ppos_info(ppos).id) and g_character ~= tile then
	  dsb_bitmap_draw(guy_icons[ppos+1] , fullscreen_bitmap, gui_info.guy_icons.x + (math.fmod(tile,2) * 40), gui_info.guy_icons.y + (math.floor((tile) / 2) * 31))
   end
end


function draw_portrait(ppos)
   local col = 3
   if ppos == party.leader then
	  col = 4;
   end
   local in_inv = false
   dsb_bitmap_clear(ppos_portrait(ppos),dark_grey)
   if valid_and_alive(ppos_info(ppos).id) then
	  in_inv = (g_state == STATE_INVENTORY and (inventory_ppos() == ppos))
	  if in_inv then
		 dsb_bitmap_draw(gfx.top_port,ppos_portrait(ppos),0,0)
	  else
		 dsb_bitmap_draw(gfx.top_hands,ppos_portrait(ppos),0,0)
	  end
   else
	  dsb_bitmap_draw(gfx.top_dead,ppos_portrait(ppos),0,0)
   end
   local is_dead = dsb_get_bar(ppos_info(ppos).id,HEALTH) <= 0

   local x, y = sys_render_portraits_and_info(ppos_portrait(ppos), ppos, ppos_info(ppos).id, is_dead, in_inv, col, get_ppos(ppos).portrait_gfxname)

   ppos_portrait(ppos).x = x + gui_info.portraits.x
   ppos_portrait(ppos).y = y + gui_info.portraits.y

   local health_damage = ppos_info(ppos).damage[HEALTH]
   if health_damage then
	  health_damage = math.floor(health_damage * 0.1)
	  if in_inv then
		 dsb_bitmap_draw(gfx.damage_full,ppos_portrait(ppos), 0, 0, 0, 0, 84, 14, false)
	  else
		 dsb_bitmap_draw(gfx.damage_bar,ppos_portrait(ppos), 0, 0, 0, 0, 84, 14, false)
	  end
	  dsb_bitmap_textout(ppos_portrait(ppos), sys_font, "" .. health_damage, 30,
						 1, LEFT, magic_info.magic_system_colors[2])
	  ppos_info(ppos).damage = {}
   end

   dsb_bitmap_draw(ppos_portrait(ppos), fullscreen_bitmap, ppos_portrait(ppos).x, ppos_portrait(ppos).y)
end


function draw_characters()
   for ppos = 0,3 do
	  if get_ppos(ppos) then
		 draw_portrait(ppos)
	  end			 
   end
   for tile = 0,3 do
   	  draw_character(tile)
   end
end


function draw_icon(icon)
   local bitmap = icon.icon
   local frames = bitmap.frames or 1
   local frame = math.floor(math.fmod(g_frame_counter / (1 or 1), frames))
   local w = dsb_bitmap_width(bitmap) / frames
   local h = dsb_bitmap_height(bitmap)

   dsb_bitmap_draw(bitmap, view_bitmap, w * frame, 0, icon.x, icon.y, w, h, false)
end


function draw_inventory()
   dsb_bitmap_draw(inventory_info.background, view_bitmap, 0, 0)

   for n = INV_R_HAND,MAX_INV_SLOTS-1 do
	  draw_slot(n)
   end

   draw_icon(inventory_info.mouth)
   if not (g_state == STATE_OFFER) then
	  draw_icon(inventory_info.save)
	  draw_icon(inventory_info.sleep)
   end

   dsb_bitmap_clear(subrender_bitmap,dark_grey)
   if view_stats == true then
	  if party.holding then
		 local instance = id_table[party.holding]
		 if instance.arch.subrenderer then
			instance.arch:subrenderer(party.holding)
		 else
			sys_render_object(g_characters[inventory_ppos()].id, party.holding, instance.arch.name)
		 end
	  else
		 sys_render_stats(g_characters[inventory_ppos()].id)
	  end
	  dsb_bitmap_draw(inventory_info.eye.look_icon, view_bitmap, inventory_info.eye.x, inventory_info.eye.y)
   else
	  dsb_bitmap_draw(inventory_info.eye.icon, view_bitmap, inventory_info.eye.x, inventory_info.eye.y)
	  if g_state == STATE_OFFER then
		 dsb_bitmap_draw(res_rei, subrender_bitmap, 0,0)
	  elseif g_state == STATE_INVENTORY then
		 local rhand = dsb_fetch(CHARACTER,g_characters[inventory_ppos()].id,INV_R_HAND)
		 if rhand and id_table[rhand].arch.subrenderer then
			id_table[rhand].arch:subrenderer(rhand)
		 else
			sys_render_mainsub(g_characters[inventory_ppos()].id)
		 end
	  end
   end
   dsb_bitmap_draw(subrender_bitmap, view_bitmap, inventory_info.subrenderer.x, inventory_info.subrenderer.y)
   
   sys_render_inventory_text(view_bitmap, g_characters[inventory_ppos()].id, 1)
end


function draw_methods()
   if g_next_char > 0 then
	  if not party.attacking then
		 sys_render_attack_options(attack_bitmap, dsb_get_sleepstate() or (g_state == STATE_OFFER))
	  else
		 local count = #method_names
		 local char = party.attacking
		 sys_render_attack_method(attack_bitmap, dsb_get_sleepstate() or (g_state == STATE_OFFER), char, char, char, count, method_names)
	  end
   end
end


function draw_magic()
   sys_render_magic(magic_bitmap, party.magician, dsb_get_sleepstate() or (g_state == STATE_OFFER), false)
   dsb_bitmap_draw(magic_bitmap, fullscreen_bitmap, gui_info.magic.x, gui_info.magic.y)
end


function get_scale()
   width, height = love.graphics.getDimensions()

   local sx = width / 640
   local sy = height / 480

   return sx, sy
end


function draw_console()
   for i = 0,3 do
	  local line = g_console[i]
	  if line then
		 dsb_bitmap_textout(fullscreen_bitmap, sys_font, line[2], 5,
							gui_info.console.y + (16 * i), LEFT, line[1])
	  end
   end
end


function love.draw(dt)
   love.graphics.clear()

   if redraw then
	  dsb_bitmap_clear(fullscreen_bitmap, {0,0,0})
   end

   if g_state == STATE_END then
	  dsb_bitmap_clear(fullscreen_bitmap, {0,0,72})
	  dsb_bitmap_draw(end_bitmap, fullscreen_bitmap, 320 - dsb_bitmap_width(end_bitmap)/2,240 - dsb_bitmap_height(end_bitmap)/2)
	  dsb_bitmap_draw(restart_button, fullscreen_bitmap, 320 - dsb_bitmap_width(restart_button)/2,400 - dsb_bitmap_height(restart_button)/2)	  
	  love.graphics.draw(fullscreen_bitmap.image, 0, 0, 0, sx, sy)	  
   elseif g_state == STATE_INTRO then
	  local width, height = love.graphics.getDimensions()
	  local sx,sy = get_scale()
	  local scale = math.min(intro_time * 0.5,1)
	  dsb_bitmap_clear(fullscreen_bitmap, {0,0,72})
	  if scale < 1 then

		 dsb_bitmap_draw(intro_dsb, fullscreen_bitmap, 320,180, scale,scale)
	  else
		 dsb_bitmap_draw(intro_dsbs, fullscreen_bitmap, 320,230, 2,2)
	  end
	  love.graphics.draw(fullscreen_bitmap.image, 0, 0, 0, sx, sy)
	  return
   elseif fullscreen_func then
   elseif g_state == STATE_SAVE then
	  dsb_bitmap_draw(control_background, view_bitmap,0,0)
	  dsb_bitmap_textout(view_bitmap, sys_font, "OPTIONS", 225, 50, CENTRE, {255,255,255})
	  dsb_bitmap_draw(control_short, view_bitmap,20,120)
	  dsb_bitmap_textout(view_bitmap, sys_font, "LOAD GAME", 115, 140, CENTRE, {255,255,255})
	  dsb_bitmap_draw(control_short, view_bitmap,230,120)
	  dsb_bitmap_textout(view_bitmap, sys_font, "CANCEL", 330, 140, CENTRE, {255,255,255})
	  dsb_bitmap_draw(control_short, view_bitmap,20,200)
	  dsb_bitmap_textout(view_bitmap, sys_font, "SAVE GAME", 115, 220, CENTRE, {255,255,255})
	  dsb_bitmap_draw(control_short, view_bitmap,230,200)
	  dsb_bitmap_textout(view_bitmap, sys_font, "QUIT GAME", 330, 220, CENTRE, {255,255,255})
	  dsb_bitmap_draw(view_bitmap, fullscreen_bitmap, gui_info.viewport.x, gui_info.viewport.y)
   elseif redraw then
	  objzones = {}
	  msgzones = {}

	  dsb_bitmap_clear(fullscreen_bitmap, {0,0,0})

	  if damage_amount > 0 then
		 sys_render_attack_result(attack_bitmap, false, damage_amount, true)
		 damage_amount = 0
	  else
		 draw_methods()
	  end
	  dsb_bitmap_draw(attack_bitmap, fullscreen_bitmap,gui_info.methods.x, gui_info.methods.y)

	  if g_next_char > 0 then
		 draw_magic()
	  end

	  if dsb_get_sleepstate() then
		 dsb_bitmap_clear(view_bitmap, {0,0,0})
		 dsb_bitmap_textout(view_bitmap, sys_font, "WAKE UP", 180,
							120, LEFT, magic_info.magic_system_colors[3])
	  elseif g_state == STATE_MOVE then
		 if not view_bitmap then
			update_view()
		 end
	  elseif g_state == STATE_INVENTORY or g_state == STATE_OFFER then
		 draw_inventory()
	  end

	  draw_characters()

	  sys_render_arrows(arrows_bitmap, party.move, not (g_state == STATE_MOVE))

	  dsb_bitmap_draw(arrows_bitmap, fullscreen_bitmap, gui_info.movement.x, gui_info.movement.y+4)
	  dsb_bitmap_draw(view_bitmap, fullscreen_bitmap, gui_info.viewport.x, gui_info.viewport.y)

	  if party.holding and dsb_find_arch(party.holding).name then
		 local name = dsb_find_arch(party.holding).name
		 dsb_bitmap_textout(fullscreen_bitmap, sys_font, name, gui_info.current_item.x,
							gui_info.current_item.y, LEFT, magic_info.magic_system_colors[3])
	  end
	  party.move = 0

   end

   if g_state ~= STATE_END then
	  draw_console()
   end

   local sx,sy = get_scale()
   love.graphics.draw(fullscreen_bitmap.image, 0, 0, 0, sx, sy)

   if not view_stats then
	  draw_mouse()
   end

   redraw = false
end


-----------
-- Input --
-----------

function love.keypressed(key)
   -- print(key)
   local moved = false
   if key == "h" then
	  print("PARTY @ " .. party.pos[1] .. " " .. party.pos[2] .. " " .. party.pos[3] .. " " .. party.pos[4])
   elseif key == "s" then
	  save_game(savefile)
   elseif key == "l" then
	  load_game(savefile)
   elseif key == "escape" then
	  love.event.quit()
   elseif key == "up" or key == "kp8" then
	  party.move = 2
   elseif key == "down" or key == "kp5" then
	  party.move = 5
   elseif key == "left" or key == "kp7" then
	  party.move = 1
   elseif key == "right" or key == "kp9" then
	  party.move = 3
   elseif key == "kp4" then
	  party.move = 4
   elseif key == "kp6" then
	  party.move = 6
   elseif key == "pageup" then
	  party.move = 7
   elseif key == "pagedown" then
	  party.move = 8
   end
end


function mouse_x()
   local sx,sy = get_scale()
   return love.mouse.getX() / sx
end


function mouse_y()
   local sx,sy = get_scale()

   return love.mouse.getY() / sy
end


function mouse_position()
   local x = mouse_x()
   local y = mouse_y()
   if not (mouse_cursor == hand_cursor) then
	  x = x - 16
	  y = y - 16
   end

   return x,y
end


function draw_mouse()
   local x,y = mouse_position()
   local mx = mouse_x()
   local my = mouse_y()
   local sx,sy = get_scale()

   if (mx < 448 or (my < 86 and mx < 552)) and g_next_char > 0 and fullscreen_func == nil then
	  if not (mouse_cursor == hand_cursor) then
		 set_color({0,0,0})
		 love.graphics.draw(mouse_cursor.image, (x + 4) * sx, (y + 4) * sy, 0, sx, sy)
		 set_color()
	  end
	  g_character = nil
	  love.graphics.draw(mouse_cursor.image, x*sx, y*sy,0,sx,sy)
   else
	  if g_character then		 
		 love.graphics.draw(guy_icons[party.positions[g_character]+1].image, mx*sx, my*sy,0,sx,sy)
	  else
		 love.graphics.draw(arrow_cursor.image, mx*sx, my*sy,0,sx,sy)
	  end
   end
end


---------------
-- Iterators --
---------------

-- This is an iterator used in Lua's for loops. To iterate over all instances of objects in a DSB dungeon, use something like:
-- for i in dsb_insts()
function dsb_insts()
   return pairs(id_table)
end

-- Another iterator; see above for usage. This one is used to iterate all over all instances that are inside the given instance.
function dsb_in_obj(id)
   return pairs({})
end


----------------
-- Filesystem --
----------------

function file_exists(name)   
   -- local f=io.open(name,"r")
   local f=love.filesystem.exists(name)
   -- if f~=nil then io.close(f) return true else return false end
   return f
end


function find_path(name, ext)
   local name = string.lower(name)
   local path = "data/" .. name .. "." .. ext
   if file_exists(path) then
	  return path
   end
   path = dungeon .. "/" .. name .. "." .. ext
   print("checking " .. path)
   if file_exists(path) then
	  return path
   end
end

function find_path_noext(name)
   if file_exists("data/" .. name) then
	  return "data/" .. name
   elseif file_exists("data/" .. string.lower(name)) then
	  return "data/" .. string.lower(name)
   elseif file_exists(dungeon .. "/" .. name) then
	  return dungeon .. "/" .. name
   elseif file_exists(dungeon .. "/" .. string.lower(name)) then
	  return dungeon .. "/" .. string.lower(name)	  
   end
end


-------------------------
-- Bitmaps and Drawing --
-------------------------

-- Searches the dungeon's directory for the bitmap, and then graphics.dsb, and finally the default graphics.dat. Returns a truecolor bitmap, but the bitmap can be 256 colors on disk to save space. Don't specify a file extension as DSB will figure it out.
-- returns: bitmap
function dsb_get_bitmap1(name)
   local path = find_path(name, "png")
   if not path then
	  path = find_path(name, "bmp")
	  if not path then
		 print("Can't find graphics file: " .. name)
		 return
	  end
   end

   local image = load_image(path)
   local canvas = love.graphics.newCanvas(image:getWidth(), image:getHeight())
   love.graphics.setCanvas(canvas)
   love.graphics.draw(image)
   love.graphics.setCanvas()

   bitmap = {id = bitmap_id, image = canvas, raw = image}
   bitmap_id = bitmap_id + 1

   return bitmap
end


function dsb_get_bitmap3(name)
   local path = find_path(name, "png")
   if not path then
	  path = find_path(name, "bmp")
	  if not path then
		 print("Can't find graphics file: " .. name)
		 return
	  end
   end

   local image = load_image(path)
   local canvas = love.graphics.newCanvas(image:getWidth(), image:getHeight())
   love.graphics.setCanvas(canvas)
   love.graphics.draw(image)
   love.graphics.setCanvas()

   bitmap = {id = bitmap_id, image = image, raw = image}
   bitmap_id = bitmap_id + 1

   return bitmap
end


function load_image(path)
   if not images[path] then
	  images[path] = love.graphics.newImage(path)
   end
   return images[path]
end


-- Same as above but with subdirectories. Example: "path/to/actual/file.ext"
-- returns: bitmap
function dsb_get_bitmap2(name, relative_path)
   local path = find_path_noext(relative_path)

   print("GOT: " .. path)
   local image = load_image(path)
   local canvas = love.graphics.newCanvas(image:getWidth(), image:getHeight())
   love.graphics.setCanvas(canvas)
   love.graphics.draw(image)
   love.graphics.setCanvas()

   bitmap = {id = bitmap_id, image = canvas, raw = image}
   bitmap_id = bitmap_id + 1

   return bitmap
end


function dsb_get_bitmap(...)
   local _,argl = ipairs{...}
   if argl and #argl <= 1 then return dsb_get_bitmap1(...) else return dsb_get_bitmap2(...) end
end


-- This function loads a bitmap that requires two distinct regions of transparency that are used at different times, such as see-through door decorations or magic windows. The region that is transparent when the image is first blitted is represented by color 0, whereas the region that is "see through" is in the usual magenta color. This requires a 256 color bitmap.
-- returns: bitmap
function dsb_get_mask_bitmap(name)
   return dsb_get_bitmap(name)
end


-- Creates a brand new bitmap and returns a reference to it.
-- returns: bitmap
function dsb_new_bitmap(xsize, ysize)
   local bitmap = {id = bitmap_id, image = love.graphics.newCanvas(xsize, ysize)}
   bitmap_id = bitmap_id + 1
   bitmap.x = 0
   bitmap.y = 0
   return bitmap
end


-- Completely destroys a bitmap. Rarely needed, as Lua's garbage collector will automatically scoop up out-of-scope bitmaps. You should only invoke this by hand if you know for sure why you need it.
function dsb_destroy_bitmap(bitmap)
end


-- Creates a "virtual bitmap" clone of the specified bitmap. It shares the same actual memory, but can have different offsets. This is useful if you, for example, have several wallitems for which you want to draw the same image on different parts of the wall.
-- returns: bitmap
function dsb_clone_bitmap(bitmap)
end


-- Sets up a bitmap that is a series of frames for animation.
function dsb_animate(bitmap, frames, frame_delay)
   bitmap.frames = frames
   bitmap.frame_delay = frame_delay
end


-- Clears a bitmap to the specified RGB value. An RGB is specified as a table of { R, G, B }.
function dsb_bitmap_clear(bitmap, RGB)
   love.graphics.setCanvas(bitmap.image)
   set_color(RGB)
   love.graphics.rectangle("fill", 0, 0, dsb_bitmap_width(bitmap), dsb_bitmap_height(bitmap))
   love.graphics.setCanvas()
   set_color()
end


-- Blits one bitmap onto another.
-- This function takes either 8 or 10 parameters. In the 10 parameter version, the last two parameters define the size of the final bitmap to be rendered. This allows you to scale bitmaps dynamically. There's no anti-aliasing, so this works best with simple pixel images.
function dsb_bitmap_blit1(src_bmp, dest_bmp, x_src, y_src, x_dest, y_dest, width, height, scale)
   if not scale then
	  scale = 1
   end

   local quad = love.graphics.newQuad(x_src,y_src,width,height,src_bmp.image:getDimensions())
   love.graphics.setCanvas(dest_bmp.image)
   love.graphics.draw(get_image(src_bmp), quad, x_dest, y_dest,0,scale,scale,0, 0)
   love.graphics.setCanvas()
end


function dsb_bitmap_blit2(src_bmp, dest_bmp, x_src, y_src, x_dest, y_dest, src_width, src_height, final_width, final_height)
   if final_width <= 0 then return end
   love.graphics.setCanvas(dest_bmp.image)
   -- local src = src_bmp.image or src_bmp
   love.graphics.draw(get_image(src_bmp), 0, 0, 0, 1, 1, 0, 0)
   love.graphics.setCanvas()
end


function dsb_bitmap_blit(...)
   local _,argl = ipairs{...}
   if argl and #argl <= 9 then
	  dsb_bitmap_blit1(...)
   else
	  dsb_bitmap_blit2(...)
   end
end


function darken( x, y, r, g, b, a )
   local d = dark_level
   r = math.max(r - d, 0)
   g = math.max(g - d, 0)
   b = math.max(b - d, 0)
   return r,g,b,a
end


function get_image(bitmap)
   if dark_level and dark_level > 0 then
	  if not bitmap.dark then
		 bitmap.dark = {}
	  end
	  if not bitmap.dark[dark_level] then
		 local data = bitmap.image:newImageData()
		 data:mapPixel(darken)
		 bitmap.dark[dark_level] = love.graphics.newImage(data)
	  end

	  return bitmap.dark[dark_level]
   end
   return bitmap.image
end


-- Draws the entire source bitmap on to the destination, taking any animation or offsets into account. Pass true to the last parameter to horizontally flip the bitmap. Pass only 5 parameters to draw a simple bitmap at x,y, or pass 9 parameters to scale the bitmap dynamically.
function dsb_bitmap_draw1(src_bmp, dest_bmp, x, y, flip)
   -- if trace then print("->dsb_bitmap_draw1:" .. x .. " " .. y) end

   love.graphics.setCanvas(dest_bmp.image)
   local xscale = 1
   if flip == true then
	  xscale = -1
	  x = x + (dsb_bitmap_width(src_bmp) * 1)
   elseif flip == 2 then
	  love.graphics.setColor(0,0,0)
   end

   love.graphics.draw(get_image(src_bmp), x, y, 0, xscale, 1, 0, 0)
   love.graphics.setCanvas()

   set_color(last_color)

   src_bmp.x = dest_bmp.x + x
   src_bmp.y = dest_bmp.y + y
end


function dsb_bitmap_draw3(src_bmp, dest_bmp, x, y, sx, sy, flip)
   local width = dsb_bitmap_width(src_bmp)
   local height = dsb_bitmap_height(src_bmp)

   love.graphics.setCanvas(dest_bmp.image)
   local xscale = 1
   if flip == true then
	  xscale = -1
   end

   love.graphics.setCanvas(dest_bmp.image)
   love.graphics.draw(get_image(src_bmp), x, y, 0, sx * xscale, sy, width/2, height/2)
   love.graphics.setCanvas()

   src_bmp.x = dest_bmp.x + x
   src_bmp.y = dest_bmp.y + y
end


function dsb_thing_draw(arch, dest_bmp, x, y, sx, sy,dist,instance)
   local off = 0
   local bitmap = arch.dungeon

   if dsb_table[instance.id].flying then
	  if (dist == 3) then
		 off = -30
	  elseif (dist == 2) then
		 off = -50
	  elseif (dist == 1) then
		 off = -100
	  else
		 off = -150
	  end
	  if arch.flying_away then
		 bitmap = arch.flying_away
	  end
   end

   dsb_bitmap_draw(bitmap, dest_bmp, x, y + off, sx, sy)
end


function dsb_bitmap_draw2(src_bmp, dest_bmp, src_x, src_y, dest_x, dest_y, src_width, src_height, flip)
   if src_width <= 0 then return end
   local quad = love.graphics.newQuad(src_x,src_y,src_width,src_height,src_bmp.image:getDimensions(), src_bmp.image:getDimensions())
   love.graphics.setCanvas(dest_bmp.image)
   local xscale = 1
   if flip then
	  xscale = -1
   end
   love.graphics.draw(get_image(src_bmp), quad, dest_x, dest_y)
   love.graphics.setCanvas()

   src_bmp.x = dest_bmp.x + src_x
   src_bmp.y = dest_bmp.y + src_y
end


function dsb_bitmap_draw(...)
   local _,argl = ipairs{...}
   if argl and #argl <= 5 then
	  dsb_bitmap_draw1(...)
   elseif argl and #argl <= 7 then
	  dsb_bitmap_draw3(...)
   else
	  dsb_bitmap_draw2(...)
   end
end

-- Returns the dimension of the bitmap.
-- returns: integer
function dsb_bitmap_width(bitmap)
   return bitmap.image:getWidth()
end


function dsb_bitmap_height(bitmap)
   return bitmap.image:getHeight()
end


function set_color(color)
   if color then
	  last_color = color
	  -- for some reason when i built love2d myself i ended up with verion 0.11.0
	  if major < 11 and (not major == 0) then
		 love.graphics.setColor(color[1],color[2],color[3],255)
	  else
		 love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255, 255)
	  end
   else
	  last_color = {255,255,255}
	  set_color(last_color)
   end
end


-- Draws a rectangle. Pass true to filled for a filled rectangle.
function dsb_bitmap_rect(bitmap, x_src, y_src, x_dest, y_dest, color, filled)
   love.graphics.setCanvas(bitmap.image)
   if type(color) == "number" then
	  love.graphics.setColor(0.4,0.4,0.4,0.4)
   else
	  set_color(color)
   end
   local style = "line"
   if filled == true then style = "fill" end
   love.graphics.rectangle(style, x_src-1, y_src-1, (x_dest - x_src) + 1, (y_dest - y_src) + 1)
   love.graphics.setCanvas()
   set_color()
end


-- Renders text onto a bitmap in the specified font and color, with the specified alignment: (LEFT, RIGHT, CENTER, or MULTILINE). Returns the number of lines printed.
-- returns: integer
function dsb_bitmap_textout(bitmap, font, str_or_num, x, y, alignment, color)
   str = "" .. str_or_num
   for i = 1,#str do
	  local b = string.byte(str,i) - 32
	  local by = math.floor(b / 16)
	  local bx = math.fmod(b, 16)
	  bx = bx * 24
	  by = by * 24
	  set_color(color)
	  local ax = x - 2
	  if alignment == LEFT then
		 ax = ax + ((i - 1) * 12)
	  elseif alignment == RIGHT then
		 ax = (ax - ((#str + 1) * 12)) + ((i) * 12)
	  else
		 local xs = #str * 12
		 ax = (x - 2) - (xs * 0.5)
		 ax = ax + ((i - 1) * 12)
	  end
	  dsb_bitmap_blit(font, bitmap, bx, by, ax, y - 2, 16, 16)
	  set_color()
   end
end


function dsb_bitmap_textout2(bitmap, font, str_or_num, x, y, alignment, color)
   str = "" .. str_or_num
   local ay = y - 2

   local lines = string.gmatch(str,"[^/]+")
   for line in lines do
	  local spacing = 26
	  local xs = #line * spacing
	  for i = 1,#line do
		 local b = string.byte(line,i) - 32
		 local by = math.floor(b / 16)
		 local bx = math.fmod(b, 16)
		 bx = 3 + bx * 11
		 by = 3 + by * 10

		 set_color(color)
		 local ax = (x - 2) - (xs * 0.5)
		 if alignment == LEFT then
			ax = ax + ((i - 1) * 12)
		 elseif alignment == RIGHT then
			ax = (ax - ((#str + 1) * 12)) + ((i) * 12)
		 else
			ax = ax + ((i - 1) * spacing)
		 end
		 dsb_bitmap_blit(font, bitmap, bx, by, ax, ay, 8, 8, 2.5)
		 set_color()
	  end
	  ay = ay + spacing + 3
   end
end


-------------
-- Dungeon --
-------------

function wall(x, y)
   local floor = world[party.pos[1]]

   local locx = party.pos[2]
   local locy = party.pos[3]

   local mx,my = move(party.pos[4])
   locx = locx + mx * y
   locy = locy + my * y

   local mx,my = move(party.pos[4] + 1)
   locx = locx + mx * x
   locy = locy + my * x

   return locy >= floor.y_size or locy < 0 or locx >= floor.x_size or locx < 0
	  or floor.map[locx][locy].wall == 1
end


function cell(x, y)
   local floor = world[party.pos[1]]

   local locx = party.pos[2]
   local locy = party.pos[3]

   local mx,my = move(party.pos[4])
   locx = locx + mx * y
   locy = locy + my * y

   local mx,my = move(party.pos[4] + 1)
   locx = locx + mx * x
   locy = locy + my * x

   if locy >= floor.y_size or locy < 0 or locx >= floor.x_size or locx < 0 then
	  return nil
   end

   return locx, locy
end


function cell_instances(x, y, level)
   local level = level or party.pos[1]
   local floor = world[level]
   local pfloor = world[party.pos[1]]

   if not floor then return {} end

   local locx = party.pos[2]
   local locy = party.pos[3]

   local mx, my = move(party.pos[4])
   locx = locx + mx * y
   locy = locy + my * y

   local mx,my = move(party.pos[4] + 1)
   locx = locx + mx * x
   locy = locy + my * x

   if locy >= pfloor.y_size or locy < 0 or locx >= pfloor.x_size or locx < 0 then
	  return nil
   end

   if floor.map[locx] and floor.map[locx][locy] then
	  return floor.map[locx][locy].instances
   end
end


function render_instance(image,x,y,y3,y2,y1)
   if y == 3 then
	  dsb_bitmap_draw(image, view_bitmap, 224 + (x * 152), y3 ,0.45,0.45)
   elseif y == 2 then
	  dsb_bitmap_draw(image, view_bitmap, 224 + (x * 210), y2 ,0.66,0.66)
   elseif y == 1 then
	  dsb_bitmap_draw(image, view_bitmap, 224 + (x * 350), y1 ,1,1)
   end
end


function render_door(image,x,y,y3,y2,y1,c,deco)
   local w = dsb_bitmap_width(image)
   local h = dsb_bitmap_height(image)
   if y == 3 then
	  dsb_bitmap_blit(image, view_bitmap, 0, c, 224 + (x * 138) - (w/2*0.45), y3-(h/2 * 0.45),w,h-c,0.45)
   elseif y == 2 then
	  dsb_bitmap_blit(image, view_bitmap, 0, c, 224 + (x * 200) - (w/2 * 0.66), y2 -(h/2 * 0.66),w,h-c,0.66)
   elseif y == 1 then
	  local y = (y1 - h/2)
	  local c1 = c
	  local c2 = c
	  if deco then
		 y = y - c
		 c1 = math.max(c1-10,0)
		 c2 = 0
	  end

	  dsb_bitmap_blit(image, view_bitmap, 0, c1, 224 + (x * 295) - w/2, y, w, math.max(h-c2,0), 1)
   end
end


function turn(facing,turn)
   facing = facing + turn
   while facing > 3 do
	  facing = facing - 4
   end
   return facing
end


function draw_monster(instance,x,y,sx,sy)
   local arch = _G["obj"][instance.arch_type]
   local tile = instance.pos[4]

   local dir = party.pos[4]
   local flip = dir + 2
   if flip > 3 then flip = flip - 4 end

   local dir1 = dir + 1
   if dir1 > 3 then dir1 = 0 end
   local dir2 = dir + 2
   if dir2 > 3 then dir2 = dir2 - 4 end
   local dir3 = dir + 3
   if dir3 > 3 then dir3 = dir3 - 4 end

   local mdir = instance.dir
   local mflip = instance.flip

   local frame = arch.front

   if dsb_get_gfxflag(instance.id, GF_ATTACKING) then
	  frame = arch.attack
   elseif mdir == dir1 then
	  frame = arch.side
	  mflip = false
   elseif mdir == dir2 then
	  frame = arch.front
   elseif mdir == dir3 then
	  frame = arch.side
	  mflip = true
   else
	  frame = arch.back
   end

   dsb_bitmap_draw(frame, view_bitmap, x + instance.offx, y + instance.offy, sx, sy, mflip)
end


function draw_instance(instance, x, y)
   if dsb_get_gfxflag(instance.id, GF_INACTIVE) then return end

   local arch = instance.arch
   local dir = party.pos[4]
   local flip = dir + 2
   if flip > 3 then flip = flip - 4 end

   if arch.type == "THING" then
	  local draw = false
	  local is_wall = dsb_get_cell(instance.pos[1], instance.pos[2], instance.pos[3])
	  if is_wall then
		 for _,wallitem in pairs(wallitems) do
			if (wallitem.pos[4] == instance.pos[4]) and (wallitem.arch.class == "ALCOVE") then
			   draw = true
			   break
			end
		 end
	  else
		 draw = true
	  end

	  local yoff = 0
	  if draw then
		 local tile = instance.pos[4]
		 local dir1 = dir + 1
		 if dir1 > 3 then dir1 = 0 end
		 local dir2 = dir + 2
		 if dir2 > 3 then dir2 = dir2 - 4 end
		 local dir3 = dir + 3
		 if dir3 > 3 then dir3 = dir3 - 4 end

		 if y == 3 then
			if is_wall then
			   dsb_thing_draw(arch, view_bitmap, 224 + (x * 134), 105, 0.45,0.45,3,instance)
			elseif (dir3 == tile) then
			   dsb_thing_draw(arch, view_bitmap, 224 - (1 * 32) + (x * 134), 136, 0.45,0.45,3,instance)
			elseif (dir2 == tile) then
			   dsb_thing_draw(arch, view_bitmap, 224 + (1 * 32) + (x * 134), 136, 0.45,0.45,3,instance)
			end
		 elseif y == 2 then
			if is_wall then
			   dsb_thing_draw(arch, view_bitmap, 224 + (x * 160), 120, 0.45, 0.45,2,instance)
			elseif (dir == tile) then
			   dsb_thing_draw(arch, view_bitmap, (224 - (1 * 41)) + (x * 160), 150, 0.45, 0.45,2,instance)
			elseif (dir1 == tile) then
			   dsb_thing_draw(arch, view_bitmap, (224 + (1 * 41)) + (x * 160), 150, 0.45, 0.45,2,instance)
			elseif (dir2 == tile) then
			   dsb_thing_draw(arch, view_bitmap, (224 + (1 * 49)) + (x * 194), 165, 0.6,0.6,2,instance)
			elseif (dir3 == tile) then
			   dsb_thing_draw(arch, view_bitmap, (224 - (1 * 49)) + (x * 194), 165, 0.6,0.6,2,instance)
			end
		 elseif y == 1 then
			if is_wall then
			   dsb_thing_draw(arch, view_bitmap, 224 + (x * 241), 150, 0.66,0.66,1,instance)
			elseif (dir == tile) then
			   dsb_thing_draw(arch, view_bitmap, 224 - (1 * 66) + (x * 241), 181, 0.66,0.66,1,instance)
			elseif (dir1 == tile) then
			   dsb_thing_draw(arch, view_bitmap, (224 + (1 * 66)) + (x * 241), 181, 0.66,0.66,1,instance)
			elseif (dir2 == tile) then
			   dsb_thing_draw(arch, view_bitmap, 224 + (1 * 85) + (x * 274), 205, 0.85, 0.85,1,instance)
			elseif (dir3 == tile) then
			   dsb_thing_draw(arch, view_bitmap, 224 - (1 * 85) + (x * 274), 205, 0.85, 0.85,1,instance)
			end
		 else
			if dir == tile then
			   dsb_thing_draw(arch, view_bitmap, 224 - (1 * 106), 243, 1,1,0,instance)
			elseif (dir1 == tile) then
			   dsb_thing_draw(arch, view_bitmap, 224 + (1 * 106), 242, 1,1,0,instance)
			end
		 end
	  end
   elseif arch.type == "MONSTER" then
	  local dir1 = dir + 1
	  if dir1 > 3 then dir1 = 0 end
	  local dir2 = dir + 2
	  if dir2 > 3 then dir2 = dir2 - 4 end
	  local dir3 = dir + 3
	  if dir3 > 3 then dir3 = dir3 - 4 end
	  local tile = instance.pos[4]

	  if y == 3 then
		 local yback = 136
		 local yfront = 142
		 if arch.size == 1 then
			yback = 120
			yfront = 130
		 end

		 if (tile == 4) then
			if arch.size == 4 then
			   draw_monster(instance,  224 + (x * 134), 140, 0.45,0.45)
			else
			   draw_monster(instance,  224 + (x * 134), 110, 0.45,0.45)
			end
		 elseif (dir3 == tile) then
			draw_monster(instance,  224 - (1 * 32) + (x * 134), yback, 0.45,0.45)
		 elseif (dir2 == tile) then
			draw_monster(instance,  224 + (1 * 32) + (x * 134), yback, 0.45,0.45)
		 elseif (dir1 == tile) then
			draw_monster(instance,  224 + (1 * 32) + (x * 134), yfront, 0.45,0.45)
		 elseif (dir == tile) then
			draw_monster(instance,  224 - (1 * 32) + (x * 134), yfront, 0.45,0.45)
		 end
	  elseif y == 2 then
		 local yback = 150
		 local yfront = 165
		 if arch.size == 1 then
			yback = 120
			yfront = 130
		 end

		 if (tile == 4) then
			if arch.size == 4 then
			   draw_monster(instance,  224 + (x * 160), 158, 0.66,0.66)
			else
			   draw_monster(instance,  224 + (x * 160), 120, 0.66,0.66)
			end
		 elseif (dir == tile) then
			draw_monster(instance,  (224 - (1 * 41)) + (x * 160), yback, 0.66, 0.66)
		 elseif (dir1 == tile) then
			draw_monster(instance,  (224 + (1 * 41)) + (x * 160), yback, 0.66, 0.66)
		 elseif (dir2 == tile) then
			draw_monster(instance,  (224 + (1 * 49)) + (x * 194), yfront, 0.66,0.66)
		 elseif (dir3 == tile) then
			draw_monster(instance,  (224 - (1 * 49)) + (x * 194), yfront, 0.66,0.66)
		 end
	  elseif y == 1 then
		 local yback = 180
		 local yfront = 207
		 if arch.size == 1 then
			yback = 140
			yfront = 170
		 end

		 if (tile == 4) then
			if arch.size == 4 then
			   draw_monster(instance,  224 + (x * 242), 155, 1,1)
			else
			   draw_monster(instance,  224 + (x * 242), 145, 1,1)
			end
		 elseif (dir == tile) then
			draw_monster(instance,  224 - (1 * 55) + (x * 242), yback, 1,1)
		 elseif (dir1 == tile) then
			draw_monster(instance,  (224 + (1 * 55)) + (x * 242), yback, 1,1)
		 elseif (dir2 == tile) then
			draw_monster(instance,  224 + (1 * 69) + (x * 274), yfront, 1, 1)
		 elseif (dir3 == tile) then
			draw_monster(instance,  224 - (1 * 69) + (x * 274), yfront, 1, 1)
		 end
	  end
   elseif arch.type == "CLOUD" then
	  local yoff = 0
	  local frame = arch.dungeon
	  local charge = dsb_get_charge(instance.id)
	  local scale = charge / 64
	  local flip = (math.fmod(charge,2) == 0)
	  if y == 3 then
		 dsb_bitmap_draw(frame, view_bitmap, 224 + (x * 152), 98 + yoff,0.45*scale,0.45*scale,flip)
	  elseif y == 2 then
		 dsb_bitmap_draw(frame, view_bitmap, 224 + (x * 210), 108 + yoff,0.66*scale,0.66*scale,flip)
	  elseif y == 1 then
		 dsb_bitmap_draw(frame, view_bitmap, 224 + (x * 300), 122 + yoff,1*scale,1*scale,flip)
	  elseif x == 0 then
		 frame = nil
		 if charge > 48 then
			frame = arch.inside_strong
		 elseif charge > 32 then
			frame = arch.inside_med
		 elseif charge > 16 then
			frame = arch.inside_weak
		 end
		 if frame then
			dsb_bitmap_draw(arch.inside_strong, view_bitmap, 224 + (x * 300), 122 + yoff,1,1,flip)
		 end
	  end
   elseif arch.type == "FLOORUPRIGHT" then
	  local yoff = 0
	  if instance.arch_type == "stairsdown" or instance.arch_type == "stairsup" then
		 if y == 3 then
			dsb_bitmap_draw(arch.front_far, view_bitmap, 224 + (x * 152), 100, 1, 1)
		 elseif y == 2 then
			dsb_bitmap_draw(arch.front_med, view_bitmap, 224 + (x * 210), 112, 1, 1)
		 elseif y == 1 then
			local of = open_facing(instance.pos[1], instance.pos[2], instance.pos[3], 0)
			local side = ((math.fmod(dir,2) == 0 and (of == 1 or of == 3)) or
				  (math.fmod(dir,2) == 1 and (of == 0 or of == 2)))
			if x == -1 and side then
			   dsb_bitmap_draw(arch.xside, view_bitmap, 224 - 140, 119, 1, 1)
			elseif x == 1 and side then
			   dsb_bitmap_draw(arch.xside, view_bitmap, 224 + 140, 119, -1, 1)
			else
			   dsb_bitmap_draw(arch.front, view_bitmap, 224 + (x * 220), 125, 1, 1)
			end
		 else
			dsb_bitmap_draw(arch.same_square, view_bitmap, 224, 140, 1, 1)
		 end
	  elseif arch.renderer_hack == "DOORFRAME" then
		 local frame = gfx.doorframe_front[y]
		 local cx,cy = cell(x,y)
		 yoff = 0
		 if frame.y_off then
			yoff = frame.y_off
		 end
		 if y == 3 then
			dsb_bitmap_draw(frame, view_bitmap, 224 + (x * 138), 98 + yoff,1,1)
		 elseif y == 2 then
			dsb_bitmap_draw(frame, view_bitmap, 224 + (x * 200), 108 + yoff,1,1)
		 elseif y == 1 then
			dsb_bitmap_draw(frame, view_bitmap, 224 + (x * 295), 122 + yoff,1,1)
		 elseif x == 0 then
			local facing = open_facing(instance.pos[1], instance.pos[2], instance.pos[3], 0)
			if (turn(dir,1) == facing or turn(dir,3) == facing) then
			   dsb_bitmap_draw(arch.same_square, view_bitmap, 224, 123, 1, 1)
			end
		 end
	  elseif arch.renderer_hack == "DOORBUTTON" then
		 local frame = arch.front
		 local yoff = 0
		 if y == 3 then
			dsb_bitmap_draw(frame, view_bitmap, 279 + (x * 152), 85 + yoff,0.45,0.45)
		 elseif y == 2 then
			dsb_bitmap_draw(frame, view_bitmap, 307 + (x * 210), 88 + yoff,0.66,0.66)
		 elseif y == 1 then
			dsb_bitmap_draw(frame, view_bitmap, 344 + (x * 300), 97 + yoff,1,1)
		 end
	  end
   elseif arch.type == "FLOORFLAT" then
	  local yoff = 0
	  local disabled = exvar[instance.id] and exvar[instance.id].disabled
	  if arch.front_far and not disabled then
		 if y == 3 then
			dsb_bitmap_draw(arch.front_far, view_bitmap, 224 + (x * 152), 137, 1, 1)
		 elseif y == 2 then
			dsb_bitmap_draw(arch.front_med, view_bitmap, 224 + (x * 210), 165, 1, 1)
		 elseif y == 1 then
			dsb_bitmap_draw(arch.front, view_bitmap, 224 + (x * 260), 207, 1, 1)
		 elseif arch.same_square then
			dsb_bitmap_draw(arch.same_square, view_bitmap, 224 + (x * 260), 260, 1, 1)
		 end
	  end
   elseif arch.type == "HAZE" then
	  local yoff = 0
	  --if not (y == 3 and x == 0) then return end
	  if arch.dungeon then
		 if y == 3 then
			--dsb_bitmap_draw(arch.dungeon, view_bitmap, 224 + (x * 152), 137, 1, 1)
			for tx = 0,4 do
			   for ty = 0,4 do
				  dsb_bitmap_draw(arch.dungeon, view_bitmap, 224 + (x * 152) + (tx*15) - 20, 75 + (ty*10), 1, 1, dsb_rand(1,2) == 1)
			   end
			end			
		 elseif y == 2 then
			--dsb_bitmap_draw(arch.dungeon, view_bitmap, 224 + (x * 210), 165, 1, 1)
			for tx = 0,4 do
			   for ty = 0,4 do
				  dsb_bitmap_draw(arch.dungeon, view_bitmap, 224 + (x * 210) + (tx*30) - 60, 65 + (ty*25), 1, 1, dsb_rand(1,2) == 1)
			   end
			end
			
		 elseif y == 1 then
			for tx = 0,4 do
			   for ty = 0,4 do
				  dsb_bitmap_draw(arch.dungeon, view_bitmap, 224 + (x * 260) + (tx*60) - 120, 207 + (ty*35) - 160, 1, 1, dsb_rand(1,2) == 1)
			   end
			end

		 end
	  end
   elseif arch.type == "DOOR" then
	  local yoff = 0
	  yoff = 0

	  if dsb_get_crop(instance.id) then
		 yoff = yoff - dsb_get_crop(instance.id)
	  end
	  yoff = 0
	  if not dsb_get_gfxflag(instance.id, GF_INACTIVE) then
		 local bm = arch.front
		 if instance.deco then
			bm = instance.deco
		 end

		 render_door(bm,x,y,98 + yoff,108 + yoff,122 + yoff, dsb_get_crop(instance.id))
	  end
   elseif arch.type == "WALLITEM" then
	  local ys = 1
	  if y == 2 then
		 ys = 0.6
	  end
	  if instance.pos[4] == flip then
		 local yoff = 0
		 if arch.renderer_hack == "WRITING" and y == 1 and x == 0 then
			dsb_bitmap_textout2(view_bitmap, gfx.wall_font, exvar[instance.id].text, 224 + (x * 152),
								80 + yoff, CENTRE, magic_info.magic_system_colors[2])
		 elseif arch.renderer_hack == "MIRROR" then
			local yoff = arch.front.y_off or 0
			if y == 3 then
			   dsb_bitmap_draw(arch.front, view_bitmap, 224 + (x * 152), 103 + yoff, 0.45, 0.45)
			elseif y == 2 then
			   dsb_bitmap_draw(arch.front, view_bitmap, 224 + (x * 210), 108 + yoff, 0.66, 0.66)
			else
			   dsb_bitmap_draw(arch.front, view_bitmap, 224 + (x * 350), 116 + yoff, 1, 1)
			   local data = exvar[instance.id]
			   if data["champion"] and x == 0 and y == 1 then
				  dsb_bitmap_draw(champions[data["champion"]].bitmap,view_bitmap, 224 + (x * 100), 100, ys, ys)
			   end
			end
		 else
			if not arch.front then
			   print("NO INSTANCE FRONT: " .. instance.arch_type)
			else
			   local yoff = arch.front.y_off or 0
			   if (instance.arch_type ~= "manacles") and (instance.arch_type ~= "gorface") and (instance.arch.class ~= "ALCOVE") then
				  render_instance(arch.front,x,y,90 + yoff * 0.45,94 + yoff * 0.66,100 + yoff)
			   elseif true then
				  render_instance(arch.front,x,y,102,112,128)
			   end
			end
		 end
	  end
   else
	  print("UNKNOWN DRAW: " .. arch.type)
   end

   return true
end


function draw_some(x, y, includes, excludes, level)
   local instances = cell_instances(x, y, level)
   wallitems = {}
   if instances then
	  for _,id in pairs(instances) do
		 local instance = id_table[id]

		 local arch = _G["obj"][instance.arch_type]
		 local include = false
		 local exclude = false
		 if includes then
			for _,class in ipairs(includes) do
			   if (arch.class == class) then
				  include = true
				  break
			   end
			end
		 else
			include = true
		 end

		 if excludes then
			for _,class in ipairs(excludes) do
			   if (arch.class == class) then
				  exclude = true
				  break
			   end
			end
		 else
			exclude = false
		 end

		 local draw = include and not exclude
		 if instance.arch.type == "WALLITEM" then
			for _,wallitem in pairs(wallitems) do
			   if wallitem.pos[4] == instance.pos[4] then
				  draw = false
				  break
			   end
			end
		 end

		 if draw then
			local drawn = draw_instance(instance, x, y)
			if drawn and (instance.arch.type == "WALLITEM") then
			   table.insert(wallitems, instance)
			end
		 end
	  end
   end
end


function draw_instances(x,y)
   draw_some(x,y,{"DOORFRAME"},nil,party.pos[1])
   draw_some(x,y,{"DOORFRAME"},nil,LIMBO)
   draw_some(x,y,nil,{"DOORFRAME"},party.pos[1])
   draw_some(x,y,nil,{"DOORFRAME"},LIMBO)
end


-- Return a rendering of the viewport.
-- returns: bitmap
function dsb_dungeon_view(lev, x, y, dir, light)
   dsb_bitmap_clear(view_bitmap, {0,0,0})

   dark_level = 0
   if lev > 0 then
	  local light_level = 0
	  for _,light in pairs(g_lights) do
		 light_level = light_level + light
	  end
	  dark_level = math.max(1 - (light_level * 0.01), 0.0)
	  dark_level = dark_level * 4
	  dark_level = math.floor(dark_level)
	  dark_level = dark_level * 0.25
	  dark_level = math.min(dark_level, 0.7)
   end

   local flip = math.floor(math.fmod(lev + x + y + dir,2)) == 1
   dsb_bitmap_draw(gfx.floor, view_bitmap, 0,132, flip)
   dsb_bitmap_draw(gfx.roof, view_bitmap, 0,0, flip)

   local light = 150

   if wall(-1,3) then
	  dsb_bitmap_draw(flip and gfx.pers3alt or gfx.pers3, view_bitmap, 148, 50)
	  dsb_bitmap_draw(flip and gfx.left3alt or gfx.left3, view_bitmap, 0, 50)
   end

   if wall(1,3) then
	  dsb_bitmap_draw(flip and gfx.pers3alt or gfx.pers3, view_bitmap, 278, 50, true)
	  dsb_bitmap_draw(flip and gfx.left3alt or gfx.left3, view_bitmap, 300, 50, true)
   end

   if wall(0,3) then
	  dsb_bitmap_draw(gfx.front3, view_bitmap, 148, 50, flip)
   end

   draw_instances(-1,3)
   draw_instances(0,3)
   draw_instances(1,3)

   if wall(-1,2) then
	  dsb_bitmap_draw(flip and gfx.pers2alt or gfx.pers2, view_bitmap, 120, 40)
	  dsb_bitmap_draw(flip and gfx.left2alt or gfx.left2, view_bitmap, 0, 40)
   end

   if wall(1,2) then
	  dsb_bitmap_draw(flip and gfx.pers2alt or gfx.pers2, view_bitmap, 300, 40, true)
	  dsb_bitmap_draw(flip and gfx.left2alt or gfx.left2, view_bitmap, 328, 40, true)
   end

   if wall(0,2) then
	  dsb_bitmap_draw(gfx.front2, view_bitmap, 120, 40, flip)
   end

   draw_instances(0,2)
   draw_instances(-1,2)
   draw_instances(1,2)

   if wall(-1,1) then
	  dsb_bitmap_draw(flip and gfx.pers1alt or gfx.pers1, view_bitmap, 64, 18)
	  dsb_bitmap_draw(flip and gfx.left1alt or gfx.left1, view_bitmap, 0, 18)
   end

   if wall(1,1) then
	  dsb_bitmap_draw(flip and gfx.pers1alt or gfx.pers1, view_bitmap, 328, 18, true)
	  dsb_bitmap_draw(flip and gfx.left1alt or gfx.left1, view_bitmap, 384, 18, true)
   end

   draw_instances(1,1)
   draw_instances(-1,1)

   if wall(0,1) then
	  dsb_bitmap_draw(gfx.front1, view_bitmap, 64, 18, flip)
   end

   if wall(-1,0) then
	  dsb_bitmap_draw(flip and gfx.pers0alt or gfx.pers0, view_bitmap, 0, 0)
   end

   if wall(1,0) then
	  dsb_bitmap_draw(flip and gfx.pers0alt or gfx.pers0, view_bitmap, 384, 0, true)
   end

   draw_instances(0,1)
   draw_instances(0,0)

   dark_level = 0
   return view_bitmap
end


-- For viewport postprocessing
function dsb_viewport_distort(effect)
end


-- These are used for per-pixel bitmap manipulation.
-- If the pixel queried with dsb_get_pixel() has an alpha channel, then the function returns two values: the {R,G,B} table, and an extra parameter containing the alpha. If there is no alpha, this second one will be nil.
-- Alpha values for both dsb_get_pixel() and dsb_set_pixel() are in the range 0-255, where 0 is fully transparent and 255 is fully opaque.
-- Here is a short example of how you might use these function to tint a bitmap:
-- http://dungeon-master.com/forum/viewtopic.php?f=53&t=28859&p=135634#p135634
-- returns: {R,G,B},[alpha]
function dsb_get_pixel(bmp, x, y)
   r, g, b, a = bmp.image:getData():getPixel(x,y)
   return {{r,g,b},a}
end


-- {R,G,B} [alpha]
function dsb_set_pixel(bmp, x, y, rgb, alpha)
   bmp.image:getData():setPixel(x, y, rgb[1], rgb[2], rgb[3], alpha)
   bmp.image:refresh()
end


-- Converts color model.
-- returns: {H,S,V}
-- {R,G,B}
function dsb_rgb_to_hsv(rgb)
end


-- returns {R,G,B}
-- {H,S,V}
function dsb_hsv_to_rgb(hsv)
end


-- This function is called when your view changes to a different level. But what does it do?!
function dsb_override_floor()
end

-- This function is called when your view changes to a different level. But what does it do?!
function dsb_override_roof()
end


-- Takes a screenshot of the entire Windows screen and assigns it to a bitmap you can use later. If you're running the game in fullscreen mode, this will allow you to screenshot the entire game window. If you're running in Windowed mode, this will screenshot your visible Windows screen from the top/left 0,0 coordinate (probably not very useful in your dungeon!)
-- returns: bitmap
function dsb_screen_bitmap()
end


-- Fonts and Text

-- Searches the same paths as dsb_get_bitmap, loading a font. Example with a subdirectory:
-- gfx["GAUDYMEDIEVALFONT"] = dsb_get_font("GAUDYMEDIEVAL", "fonts/gaudymedieval.pcx")
-- returns: font
function dsb_get_font(name, relative_path)
   return dsb_get_bitmap(name)
end

-- This controls the format of MULTILINE text output by dsb_bitmap_textout. The Y offsets are also used by the console (the text below the game view). By setting chars_per_line to something unreasonable, you can effectively disable word wrapping.
function dsb_textformat(chars_per_line, y_offset_per_line, max_lines)
end


-- Outputs the given text string in the given color to the console. (that is, a table of { R, G, B })
function dsb_write(RGB, string)
   print(string)
   for i = 1,3 do
	  g_console[i - 1] = g_console[i]
   end
   g_console[3] = {RGB, string}
   redraw = true
end


---------------------
-- Sound and Music --
---------------------

-- Searches the same paths as dsb_get_bitmap, loading a sound.
-- returns: sound
function dsb_get_sound1(name)
   local path = find_path(name, "ogg")
   if not path then
	  path = find_path(name, "wav")
	  if not path then
		 print("Can't find sound: " .. path)
		 return
	  end
   end

   if not sounds[name] then
	  sounds[name] = love.audio.newSource(path, "static")
   end
   return sounds[name]
end

function dsb_get_sound(...)
   local _,argl = ipairs{...}
   if argl and #argl <= 1 then return dsb_get_sound1(...) else return dsb_get_sound2(...) end
end

function dsb_get_sound2(name, relative_path)
   local path = find_path_noext(relative_path)

   print("PATH: " .. path)
   if not sounds[name] then
	  sounds[name] = love.audio.newSource(path, "static")
   end
   return sounds[name]
end


--  Plays the given sound. An optional boolean parameter allows you to specify if the sound should loop. Be careful, the only way to stop a looping sound is via dsb_stopsound, so don't lose the channel handle!
-- returns: chan_handle
-- ~[loop]
function dsb_sound(sound, loop)
   sound:setLooping(loop == true)
   sound:play()
   -- love.audio.play(sound)
   return sound
end


-- Plays a sound file directly from disk instead of loading into memory first.
-- TODO: If you use dsb_music, it should at least load it on demand and destroy it when it's finished, so your memory usage will be lower than if you loaded it directly as a sound.
-- returns: chan_handle
-- ~[loop]
function dsb_music(sound, loop)
   sound:setLooping(loop == true)
   sound:play()
   return sound
end


-- Plays the given sound as though it originated from the given location in the dungeon. An optional boolean parameter allows you to specify if the sound should loop. Note that base/util.lua also includes a useful function, explained next:
-- returns: chan_handle
-- ~[loop]
function dsb_3dsound(sound, lev, x, y, loop)
   sound:setPosition(x,y,lev)
   sound:setLooping(loop == true)
   sound:play()
   return sound
end


-- Plays a sound that appears to originate from the location of a given instance.
-- returns: chan_handle
function local_sound(id, sound)
   sound:setLooping(loop == true)
   sound:play()
   return sound
end


-- Allows multiple music streams.
-- returns: ?
function dsb_music_to_background()
end


-- Stops the sound playing on a channel handle previously returned by a call to a sound playing function.
function dsb_stopsound(chan_handle)
   chan_handle:stop()
end


-- Obtains the current volume of the sound, ranging from 0 to 100.
function dsb_get_soundvol(chan_handle)
   return chan_handle:getVolume()
end


-- Adjusts the volume of the sound, with the volume range from 0 to 100.
function dsb_set_soundvol(chan_handle, volume)
   chan_handle:setVolume(volume)
end


-------------------------
-- Levels and Wallsets --
-------------------------

-- Returns the basic info about a level.
-- returns: x_size, y_size, light, xp_multiplier, wallset_name
function dsb_level_getinfo(level)
   local floor = world[level]
   return floor.x_size, floor.y_size, floor.light, floor.xp_multiplier, floor.wallset
end


-- Tells DSB to tint the dynamically scaled and shaded objects in a level a certain way. By default, this is {0, 0, 0}, causing the dungeon to fade to black, just like DM, but if the ambient light color is different, or you are outdoors and fade to a misty grey instead of black, you will probably want to change this. The third parameter is to control the level of tint applied. The default is 64 but a value of over 200 or so will make everything so dark you can't see anything.
-- ~[level]
function dsb_level_tint(level, RGB, level)
end


-- Creates a wallset from the specified bitmaps. Wallsets in DM 2.x ([CSBwin]) are easiest to use with this command, as they have a single very long wall, as opposed to assembling the front view out of "left" and "front" bitmaps. (see the next command)
-- returns: wallset
function dsb_make_wallset(floor, roof, pers0, pers0alt, pers1, pers1alt, pers2, pers2alt, pers3, persl3alt, farwall3, farwall3alt, front1, front2, front3, patch1, patch2, patch3, patchside, window)
end


-- Creates a wallset from the specified bitmaps. This command takes 6 more arguments: 6 "left side" bitmaps. If you're using a converted DM2, DSB for RTC users, or WHACK wallset, you'll find this command useful.
-- returns: wallset
function dsb_make_wallset_ext(floor, roof, pers0, pers0alt, pers1, pers1alt, pers2, pers2alt, pers3, persl3alt, farwall3, farwall3alt, front1, front2, front3, left1, left1alt, left2, left2alt, left3, left3alt, patch1, patch2, patch3, patchside, window)
end


function dsb_level_wallset(level, wallset)
   world[level].wallset = wallset
end


-- Tells DSB to use the specified wallset on the specified level.
-- (Deprecated)
function dsb_use_wallset(level, wallset)
end


--  Note: this function was formerly known as "dsb_use_wallset," and that is still a synonym for it, for now. In new dungeons, please use the new name.
-- Tells DSB to use the specified wallset only on the given direction of the given tile. If CENTER is specified, it will use that wallset on all directions of the given tile.
function dsb_alt_wallset(wallset, level, x, y, dir)
end


-- Pass true to flip to automatically flip the floor every other step, like standard floors, or pass a bitmap to have a different bitmap show up when the floor is "flipped."
function dsb_wallset_flip_floor(wallset, flip)
end


-- Pass true to flip to automatically flip the roof every other step, like standard floors, or pass a bitmap to have a different bitmap show up when the roof is "flipped."
function dsb_wallset_flip_roof(wallset, flip)
end


-- Overrides the floor with the bitmap in the gfx table with the given name, regardless of what wallset is in use. Pass true to flip to automatically flip the floor every other step, like standard floors, or pass a second bitmap name to have a different bitmap show up when the floor is "flipped."
function dsb_override_floor(bitmap_name, flip)
end


-- Overrides the roof with the bitmap in the gfx table with the given name, regardless of what wallset is in use. Pass true to flip to automatically flip the roof every other step, like standard roofs, or pass a second bitmap name to have a different bitmap show up when the roof is "flipped."
function dsb_override_roof(bitmap_name, flip)
end


-- Converts a table with a text-based map into a level. Each row of the table should represent a row of the dungeon, and contain a string with 0's or 1's representing walls and floors in that row. In this way, it is very similar to how dungeons are declared in an DSB for RTC users text file.
function dsb_text2map(level, x_size, y_size, light, xp_multiplier, maptable)
   local floor = {}
   world[level] = floor
   floor.level = level
   floor.x_size = x_size
   floor.y_size = y_size
   floor.light = light
   floor.xp_multiplier = xp_multiplier
   floor.map = {}
   for y,str in ipairs(maptable) do
	  for x = 1, #str do
		 if not floor.map[x-1] then floor.map[x-1] = {} end
		 if not floor.map[x-1][y-1] then floor.map[x-1][y-1] = {} end
		 local c = str:sub(x,x)
		 if c == "1" then
			floor.map[x-1][y-1].wall = 0
		 else
			floor.map[x-1][y-1].wall = 1
		 end
	  end
   end
   dsb_set_xp_multiplier(level, 1)
end


-- Converts a bitmap image into a level. One pixel = one square. It must be a 256 color image, where color 0 represents walls, color 1 represents open space, and further colors can be used to represent various objects in the dungeon by means of a conversion table. This function is now mostly deprecated because everyone is using ESB anyway.
-- (Deprecated)
function dsb_image2map(level, filename, light, xp_multiplier)
end


-- Returns a boolean specifying whether or not the given cell in the dungeon is a wall. Use dsb_fetch to find out anything else about what's there.
-- returns: boolean
function dsb_get_cell(level, x, y)
   local floor = world[level]
   return y >= floor.y_size or y < 0 or x >= floor.x_size or x < 0
	  or floor.map[x][y].wall == 1
end


-- Sets whether the given cell in the dungeon is a wall or open space. A value of nil, false, or 0 represents open space. A value of true or any other integer represents a wall.
function dsb_set_cell(level, x, y, value)
   world[level].map[x][y].wall = 0
end


-- Returns whether the party has visited the given dungeon cell. A wall will never be visited, unless it wasn't a wall at some point in the past.
-- returns: boolean
function dsb_visited(level, x, y)
end


-- returns: integer
function dsb_get_xp_multiplier(level)
   return world[level].xp_multiplier
end


-- Gets or sets the XP multiplier for a given level of the dungeon.
function dsb_set_xp_multiplier(level, integer)
   world[level].xp_multiplier = integer
end


----------------
-- Characters --
----------------

function inventory_ppos()
   if g_state == STATE_OFFER then
	  return g_next_char - 1
   end
   return party.inventory_ppos or dsb_get_leader()
end


function portrait_char(x)
   for ppos = 1,4 do
	  if not get_ppos(ppos) or x < ppos_portrait(ppos).x then
		 return ppos - 1
	  end
   end
end


function ppos_portrait(ppos)
   return g_portraits[ppos+1]
end


--  Adds a character to the roster and returns his/her id number, which can then be used for adjusting various stats or putting items in his/her pack. Note that the internal representations of the three bars and the 7 statistics are 10 times what is actually displayed. (That is, 100 health in-game is represented by 1000)
-- returns: char_id
function dsb_add_champion(id, varname, portrait_gfxname, first_name, last_name, health, stamina, mana, strength, dexterity, wisdom, vitality, anti_magic, anti_fire, luck, fighter_level, ninja_level, priest_level, wizard_level)
   local champion = {}
   champion.id = id
   loadstring("_G." .. varname .. " = " .. id)()
   champion.load = 0
   champion.varname = varname
   champion.maxload = 100
   champion.portrait_gfxname = portrait_gfxname
   champion.bitmap = _G["gfx"][portrait_gfxname] --dsb_get_bitmap3(portrait_gfxname)
   -- dsb_bitmap_clear(champion.bitmap, {255,0,0})
   champion.first_name = first_name
   champion.last_name = last_name
   champion.bars = {}
   champion.bars[HEALTH] = health
   champion.bars[STAMINA] = stamina
   champion.bars[MANA] = mana
   champion.maxbars = {}
   champion.maxbars[HEALTH] = health
   champion.maxbars[STAMINA] = stamina
   champion.maxbars[MANA] = mana
   champion.stats = {}
   champion.stats[STAT_STR] = strength
   champion.stats[STAT_DEX] = dexterity
   champion.stats[STAT_WIS] = wisdom
   champion.stats[STAT_VIT] = vitality
   champion.stats[STAT_AMA] = anti_magic
   champion.stats[STAT_AFI] = anti_fire
   champion.stats[STAT_LUC] = luck
   champion.maxstats = {}
   champion.maxstats[STAT_STR] = strength
   champion.maxstats[STAT_DEX] = dexterity
   champion.maxstats[STAT_WIS] = wisdom
   champion.maxstats[STAT_VIT] = vitality
   champion.maxstats[STAT_AMA] = anti_magic
   champion.maxstats[STAT_AFI] = anti_fire
   champion.maxstats[STAT_LUC] = luck
   champion.levels = {}
   champion.levels[CLASS_FIGHTER] = fighter_level
   champion.levels[CLASS_NINJA] = ninja_level
   champion.levels[CLASS_PRIEST] = priest_level
   champion.levels[CLASS_WIZARD] = wizard_level
   champions[id] = champion
end


function start_moving()
   g_state = STATE_MOVE
   sys_inventory_exit(inventory_ppos(), g_characters[inventory_ppos()].id)
   party.inventory_ppos = nil
   update_view()
end


-- Offers the given char_id, with the options specified by "mode" available.000
-- ~[1 = resurrect, 2 = reincarnate, 3 = both]. The take_function is a Lua function that is executed if the offered character is resurrected or reincarnated. It is typically used to clear out the champion's mirror, or do something else to denote that the character is no longer available.
function dsb_offer_champion(char_id, mode, take_function)
   g_state = STATE_OFFER
   dsb_champion_toparty(g_next_char, char_id)
   champion_take = take_function
end


function char_info(char)
   return get_char(char).info
end


function ppos_info(ppos)
   return g_characters[ppos].info
end


-- Adds the specified character at the specified party position. (Unlike dsb_offer_champion the player is given no choice, the character is just added) It will fail silently if that position is already occupied.
function dsb_champion_toparty(ppos, char_id)
   if not (g_characters[ppos] == nil) then return end
   local char = champions[char_id]

   info = {}

   info.ppos = ppos
   info.idle = 0
   info.injuries = {}
   info.conditions = {}
   info.bonus = {[CLASS_FIGHTER] = {0,0,0,0,0}, [CLASS_NINJA] = {0,0,0,0,0}, [CLASS_PRIEST] = {0,0,0,0,0}, [CLASS_WIZARD] = {0,0,0,0,0}}
   info.tempxp = {[CLASS_FIGHTER] = {0,0,0,0,0}, [CLASS_NINJA] = {0,0,0,0,0}, [CLASS_PRIEST] = {0,0,0,0,0}, [CLASS_WIZARD] = {0,0,0,0,0}}
   info.xp = {[CLASS_FIGHTER] = {0,0,0,0,0}, [CLASS_NINJA] = {0,0,0,0,0}, [CLASS_PRIEST] = {0,0,0,0,0}, [CLASS_WIZARD] = {0,0,0,0,0}}
   info.food = 3000
   info.water = 3000
   info.dir = 0
   info.pos = g_next_char
   info.id = char_id
   info.spell = {0,0,0,0,0,0,0,0}
   info.damage = {}

   char.info = info

   if not world[CHARACTER] then
	  world[CHARACTER] = {}
	  world[CHARACTER].map = {}
	  world[CHARACTER].map[char_id] = {}
   end

   g_characters[ppos] = char
   party.positions[ppos] = ppos

   g_next_char = g_next_char + 1
end


-- Removes anyone at the specified party position. It will fail silently if no one is there. If the party is reduced to nothing, the game will revert to "ghost mode."
function dsb_champion_fromparty(ppos)
end


-- Returns the character's name.
-- returns: string
function dsb_get_charname(char)
   return get_char(char).first_name
end


-- Returns the character's lastname or title.
-- returns: string
function dsb_get_chartitle(char)
   return get_char(char).last_name
end


function get_char(char)
   return champions[char]
end


-- returns: integer
function dsb_get_bar(char, bar)
   return get_char(char).bars[bar]
end


function everyone_dead()
   if g_next_char <= 1 then
	  return false
   end
   for ppos = 0,g_next_char-1 do
	  if get_ppos(ppos) and valid_and_alive(ppos_info(ppos).id) then
		 return false
	  end
   end
   return true
end


-- Gets or sets the value of one of the character's three bars. (HEALTH, STAMINA or MANA)
function dsb_set_bar(char, bar, integer)
   get_char(char).bars[bar] = integer
   if bar == HEALTH and integer <= 0 then
	  sys_character_die(char_info(char).pos, char, nil)
   end
end


-- returns: integer
function dsb_get_stat(char, stat)
   return get_char(char).stats[stat]
end


-- Gets or sets the value of one of the character's stats. (STAT_STR, STAT_DEX, STAT_WIS, STAT_VIT, STAT_AMA, STAT_AFI, STAT_LUC)
function dsb_set_stat(char, stat, integer)
   get_char(char).stats[stat] = integer
end


-- returns: integer
function dsb_get_maxbar(char, bar)
   return get_char(char).maxbars[bar]
end


-- returns: integer
function dsb_set_maxbar(char, bar, integer)
   get_char(char).maxbars[bar] = integer
end


function dsb_get_maxstat(char, stat)
   return champions[char].maxstats[stat]
end


-- As above, only pertaining to maximum values.
function dsb_set_maxstat(char, stat, integer)
   champions[char].maxstats[stat] = integer
end


-- This function will damage the given character at the given ppos the given amount of the given type (HEALTH, STAMINA, or MANA). The units specified here are as the player perceives them (that is, divided by ten from internal representations and the same scale used by monsters)
-- Defined in base/damage.lua.
--function do_damage(ppos, char, type, amount)
--end


-- returns: integer
function dsb_get_load(char)
   return get_char(char).load
end


-- Returns the load or max load of a given character.
-- returns: integer
function dsb_get_maxload(char)
   return get_char(char).maxload
end


-- returns: integer
function dsb_get_food(char)
   return char_info(char).food
end


function dsb_set_food(char, integer)
   if integer < 0 then
	  integer = 0
   end
   char_info(char).food = integer
end


-- returns: integer
function dsb_get_water(char)
   return char_info(char).water
end


function dsb_set_water(char, integer)
   if integer < 0 then
	  integer = 0
   end
   char_info(char).water = integer
end


-- returns: integer
function dsb_get_injury(char, location)
   return char_info(char).injuries[location]
end


-- Gets or sets the amount of injury a given location on the given character has sustained. This number is 0 if the location is uninjured and can go up to 100, but anything nonzero will highlight it in red and use the "bandaged" bitmap.
function dsb_set_injury(char, location, integer)
   char_info(char).injuries[location] = integer
end


-- Replaces the portrait of a character with the given image. This can happen on-the-fly at any time. Note that the portrait must be specified as a string, not an entry in the gfx table. That is, pass "portrait", not gfx.portrait.
function dsb_replace_portrait(char, portrait_name)
end


-- Retrieves the name of a character's portrait.
-- returns: portrait_name
function dsb_get_portraitname(char)
   return get_char(char).portrait_gfxname
end


-- An alias for dsb_replace_portrait (for symmetry).
function dsb_set_portraitname(char, portrait_name)
   get_char(char).portrait_gfxname = portrait_name
end


-- Replaces the top "hands", "portrait background" and "death" images. Pass the image names nil to leave the image alone, or 0 to go back to the default. Remember that we pass the image parameters as strings, and not a direct reference to the gfx table. Example: dsb_replace_topimages(char, nil, nil, "frozen_face_halk")
function dsb_replace_topimages(char, hands_image_name, portrait_background_image_name, death_image_name)
end


-- Replaces the "hand" of a character with the given image. This can happen on-the-fly at any time. Note that the image must be specified as a string, not an entry in the gfx table. That is, pass "hand_image", not gfx.hand_image.
function dsb_replace_charhand(char, hand_name)
end


-- Replaces the inventory background of a character with the given image. This can happen on-the-fly at any time. Note that the background image must be specified as a string, not an entry in the gfx table. That is, pass "inventory", not gfx.inventory.
function dsb_replace_inventory(char, inventory_image_name)
end


-- Replaces the default attack methods of a character with the given table of methods, or function returning a table. This can happen on-the-fly at any time. Note that the method table or function must be specified by name as a string, not as an actual table. It must a single global variable (not be contained in any other table).
function dsb_replace_methods(char, methods_table_name)
end


-- returns: integer
function dsb_xp_level2(who, skill, subskill)
   local xp = dsb_get_xp(who,skill,subskill)

   if xp == 0 then
	  return 0
   end

   local bonus = 1
   if dsb_get_xp(who,skill,0) > 0 then
	  bonus = 1
   end

   local level = 1
   local res = 0
   while level <= 15 do
	  if xp_levelamounts[level] <= xp then
		 res = res + 1
	  end
	  level = level + 1
   end

   return res + bonus
end


function dsb_xp_level(char, skill, subskill)
   return get_char(char).levels[skill][subskill+1]
end


-- These functions return the character's level of mastery at a certain skill (a class such as 'ninja') and subskill (or 0 for no subskill). The "nobonus" form does not take temporary XP or level-boosting items into account. All references to the dsb_xp_level call are wrapped by function determine_xp_level(char, class, subskill) so that it can be overridden.
-- returns: integer
function dsb_xp_level_nobonus(char, skill, subskill)
   return get_char(char).levels[skill][subskill+1]
end


-- Gives the specified amount of XP in the specified skill and subskill (or 0 for no subskill).
-- Important: This function gives XP only. It doesn't deal with XP multipliers, leveling up, bonuses, or anything else.
-- More useful to most designers will be the helper function xp_up.
function dsb_give_xp(char, skill, subskill, xp)
   char_info(char).xp[skill][subskill+1] = char_info(char).xp[skill][subskill+1] + xp
end


-- This function takes XP multipliers, leveling up, etc. into account.
-- Defined in base/xp.lua.
-- xp_up(char, skill, subskill, xp)
-- end


-- returns: xp
function dsb_get_xp(char, skill, subskill)
   return char_info(char).xp[skill][subskill+1]
end


-- Gets or sets the character's amount of experience directly. Setting XP directly doesn't do anything with stats, leveling up or down, or anything of that sort, so it is of limited use unless you really know what you're doing.
function dsb_set_xp(char, skill, subskill, xp)
   char_info(char).xp[skill][subskill+1] = xp
end


-- returns: xp
function dsb_get_temp_xp(char, skill, subskill)
   -- return char.tempxp[skill][subskill+1]
   return char_info(char).tempxp[skill][subskill+1]
end


-- Gets or sets a temporary XP bonus. This, too, is handled by xp_up automatically.
function dsb_set_temp_xp(char, skill, subskill, xp)
   return char_info(char).tempxp[skill][subskill+1]
end


-- returns: integer
function dsb_get_bonus(char, skill, subskill)
   return char_info(char).bonus[skill][subskill+1]
end


-- Gets or sets a level bonus associated with a given skill or subskill (or 0 for no subskill), such as what may be given by a magic item held in hand or worn around the neck.
function dsb_set_bonus(char, skill, subskill, integer)
   char_info(char).bonus[skill][subskill+1] = integer
end


---------------
-- The Party --
---------------

-- Many of these commands include optional support for Multiple Parties. In a standard DM dungeon, you can ignore all of that.

-- Returns the ~[specified] party's location.
-- returns: level, x, y, facing
-- ~[party]
function dsb_party_coords()
   return party.pos[1],party.pos[2],party.pos[3],party.pos[4]
end


function comparetables(t1, t2)
   if #t1 ~= #t2 then return false end
   for i=1,#t1 do
	  if t1[i] ~= t2[i] then return false end
   end
   return true
end


-- Returns which party is at a specified location, or nil if no party is there.
-- returns: party
function dsb_party_at(level, x, y)
   if party.pos[1] == level and party.pos[2] == x and party.pos[3] == y then
	  return party
   end
end


-- Places the ~[specified] party at a specific location.
-- ~[party]
function dsb_party_place(level, x, y, facing, p)
   party.pos = {level, x, y, facing}
end


-- returns: direction
function dsb_get_pfacing(ppos)
   return ppos_info(ppos).dir -- ppos.facingg
end


-- Get or set the direction a given party position is facing relative to the rest of the party. (This changes when the members are attacked from monsters to the sides or behind)
function dsb_set_pfacing(ppos, direction)
   ppos_info(ppos).dir = direction
end


-- returns: integer
function dsb_get_idle(ppos)
   return ppos_info(ppos).idle
end


-- Gets or sets the amount of time the given party position must be idle (that is, the attack method icons are ghosted). Note that these take party positions, not character numbers.
function dsb_set_idle(ppos, integer)
   ppos_info(ppos).idle = integer
end


-- Returns the party position of the party's leader.
-- returns: ppos
function dsb_get_leader()
   return party.leader
end


function dsb_set_leader(integer)
   party.leader = integer
end


-- Returns the character at the given party position, or nil if there isn't one.
-- returns: char
-- ~[party]
function dsb_ppos_char(ppos, p)
   return get_ppos(ppos) and ppos_info(ppos).id
end


-- If a party is specified, that party will be searched. If there is no party specified, only the current party will be searched. To search all parties, specify VARIABLE as the party.

-- Returns the party position a given character occupies, or nil if he/she isn't in the party.
-- returns: ppos
function dsb_char_ppos(char)
   for ppos = 0,3 do
	  if get_ppos(ppos) and ppos_info(ppos).id == char then
		 return ppos
	  end
   end
end


-- Returns the tile location that the given party position occupies.
-- returns: tile_dir
-- ~[party]
function dsb_ppos_tile(ppos, theparty)
   return ppos_info(ppos).pos -- tile
end


-- A specific party can be optionally specified.

-- Returns the party position occupied by the given tile location, or nil if nobody is there.
-- returns: ppos
-- ~[party]
function dsb_tile_ppos(tile_dir, theparty)
   for ppos = 0,3 do
	  if get_ppos(i) and ppos_info(ppos).pos == tile_dir then
		 return i
	  end
   end
end


-- A specific party can be optionally specified.

-- Returns whether or not the party is asleep.
-- returns: boolean
function dsb_get_sleepstate()
   return party.sleep
end


-- Wakes up the party if they are asleep.
function dsb_wakeup()
   party.sleep = false
end


-- If someone's inventory is being looked at, this returns the party position of the character that is being looked at. Otherwise, it returns nil.
-- returns: ppos
function dsb_current_inventory()
end


-- Returns the last attack method invoked by the given ppos.
-- returns: method, location, inst
function dsb_lastmethod(ppos)
end


-- Scans the entire party's inventory for a given arch. Returns the id for the first instance of that arch if it is found, or nil if nothing is found.
-- returns: id
function dsb_party_scanfor(arch)
end


-- Returns the current spell caster.
-- returns: ppos
function dsb_get_caster()
   return party.magician
end


----------------------
-- Multiple Parties --
----------------------

-- returns: value
function dsb_get_mpartyflag(flag)
end


function dsb_set_mpartyflag(flag)
end


function dsb_clear_mpartyflag(flag)
end


function dsb_clean_up_target_exvars()
   -- exvar[id] = nil
end


-- Gets, sets, clears, or toggles the value of a Multiple Parties flag.
function dsb_toggle_mpartyflag(flag)
end


-- This will associate a given monster inst with a character. The monster must be in LIMBO. From then on, whenever that character is seen from a 3rd person perspective, that monster will be drawn to represent that character. Don't kill this monster or bad things will happen.
function dsb_set_exviewinst(char, monster_id)
end


function dsb_party_apush(party)
end


-- The game uses a "party stack" to keep track of which sub-party the various party-related commands affect. The currently viewed party is always at the bottom. When a party steps on a trigger, it is pushed onto the stack before the trigger is processed. This means things like dsb_party_coords will generally affect the "right" party. You can directly manipulate the stack with these commands, but be careful. If you're not sure what to do with these commands, you probably don't need them.
function dsb_party_apop(party)
end


-- Returns the party containing a given character ppos
-- returns: party_id
function dsb_party_contains(ppos)
   return party.id
end


function add_instance(cell, instance)
   -- cell.instances[instance.id] = instance
   if not cell.instances then
	  cell.instances = {}
   end

   table.insert(cell.instances, 1, instance.id)
end


function add_instance_last(cell, instance)
   -- cell.instances[instance.id] = instance
   if not cell.instances then
	  cell.instances = {}
   end

   table.insert(cell.instances, instance.id)
end


function add_world_last(level,x,y,id, tile)
   local cell = world[level].map[x][y]

   if not cell.instances then
	  cell.instances = {}
   end

   id_table[id].pos[1] = level
   id_table[id].pos[2] = x
   id_table[id].pos[3] = y
   id_table[id].pos[4] = tile
	  
   table.insert(cell.instances, id)
end


function remove_value(t, value)
   for i,v in pairs(t) do
	  if v == value then
		 table.remove(t,i)
		 break
	  end
   end
end


function remove_instance(cell, instance)
   remove_value(cell.instances, instance.id)
end


function create_cell(level,x,y)
   if not world[level] then world[level] = {} end
   if not world[level].map then world[level].map = {} end
   if not world[level].map[x] then world[level].map[x] = {} end
   if not world[level].map[x][y] then world[level].map[x][y] = {} end
   if not world[level].map[x][y].instances then world[level].map[x][y].instances = {} end
end


function make_cell(level,x,y)
   if not world[level] then
	  world[level] = {}
   end
   if not world[level].map then world[level].map = {} end
   if not world[level].map[x] then world[level].map[x] = {} end
   if not world[level].map[x][y] then
	  world[level].map[x][y] = {}
	  world[level].map[x][y].pos = {level, x, y}
   end
   if not world[level].map[x][y].instances then world[level].map[x][y].instances = {} end
end


function throw_error(str)
   love.event.quit()
end


-- Interacting with Insts
-- Spawns a new instance at the specified coordinates and returns its id.
-- returns: id
function dsb_spawn2(id, arch_type, level, x, y, tile_location)
   if id_table[id] then
	  if arch_type == "ceiling_pit" then
		 return id
	  end	  
	  throw_error("Error: Can't spawn with existing id " .. id)
   end

   if level < 0 then
	  make_cell(level,x,y)
   end

   local cell = world[level].map[x][y]
   local instance = {}

   -- dsb_find_arch must come last here
   instance.arch_type = arch_type
   instance.id = id
   id_table[id] = instance

   local arch = dsb_find_arch(id)

   instance.arch = arch
   instance.pos = {level,x,y,tile_location}
   instance.dir = 0
   instance.gfxflag = 0

   dsb_table[id] = {}

   if arch.def_charge then
	  dsb_set_charge(id,charge)
   end

   if not world[level].monsters then
	  world[level].monsters = {}
   end

   if arch.on_spawn then
	  arch.on_spawn(arch, id, level, x, y, tile_location)
   end

   if level == -3 then
	  add_to_character(x,y,instance)
	  after_add_to_character(y,instance)
   else
	  add_instance(cell,instance)
   end

   if arch.type == "MONSTER" then
	  world[level].monsters[id] = instance
	  instance.hp = sys_init_monster_hp(10, level)
	  instance.gfxflag = 0
	  instance.boss = id
	  instance.offx = 0
	  instance.offy = 0

	  sys_monster_enter_level(id, level)
   end

   if arch.deco then
	  local w = dsb_bitmap_width(arch.front)
	  local h = dsb_bitmap_height(arch.front)
	  instance.deco = dsb_new_bitmap(w,h)
	  dsb_bitmap_draw(arch.front,instance.deco,0,0)
	  local yoff = 0
	  if arch.deco.y_off then
		 yoff = arch.deco.y_off
	  end
	  dsb_bitmap_draw(arch.deco,instance.deco,w/2,h/2 + yoff,1,1,false)
   end

   return id
end


function dsb_spawn1(arch_type, level, x, y, tile_location)
   dsb_spawn2(g_next_id, arch_type, level, x, y, tile_location)
   g_next_id = g_next_id - 1
   return g_next_id + 1
end


function dsb_spawn(...)
   local _,argl = ipairs{...}
   if argl and #argl <= 5 then return dsb_spawn1(...) else return dsb_spawn2(...) end
end


function cell_nil(level,x,y)
   if not world[level] then return true end
   if not world[level].map then return true end
   if not world[level].map[x] then return true end
   if not world[level].map[x][y] then return true end
   if not world[level].map[x][y].instances then return true end
   return false
end


-- Note that if "level" is negative, various Special Values can be used.
-- Moves an instance to the specified location. The Special Values can also be used.
function dsb_move(id, level, x, y, tile_location)
   if level < 0 then
	  if y < 0 then
		 y = 0
	  end
	  make_cell(level,x,y)
	  world[level].map[x][y].instances[1] = id
	  id_table[id].pos[1] = level
	  id_table[id].pos[2] = x
	  id_table[id].pos[3] = y
	  id_table[id].pos[4] = tile_location
   else
	  local ll = id_table[id].pos[1]
	  local lx = id_table[id].pos[2]
	  local ly = id_table[id].pos[3]

	  remove_value(world[ll].map[lx][ly].instances, id)

	  create_cell(level,x,y)
	  local arch = dsb_find_arch(id)
	  add_instance(world[level].map[x][y],id_table[id])

	  id_table[id].lastpos = pos
	  id_table[id].pos = {level,x,y,0}

	  local instances = dsb_fetch(level,x,y)
	  if instances then
		 for _,tid in pairs(instances) do
			local instance = id_table[tid]
			if (not dsb_get_gfxflag(tid,GF_INACTIVE)) and instance.arch.on_trigger then
			   instance.arch:on_trigger(tid, id)
			end
		 end
	  end
   end
end


-- Moves an instance to a new tile location on the same tile. Useful for rearranging monsters.
function dsb_reposition(id, tile_location)
   id_table[id].pos[4] = tile_location
end


-- Note: dsb_spawn etc. will not always immediately put the spawned/moved object into position. During the processing of a triggering event (wallitem or flooritem), all spawns and moves will be queued until the end of the processing in order to avoid changing the dungeon state while the triggering objects are still being iterated over. In most cases, the change will not be noticable, but you should be wary of this fact, especially if you are expecting to be able to manipulate the just-moved object in the same function.
-- returns: ???
function dsb_move_moncol()
end


-- Allow moving a monster and automatically handle flyer collisions.
-- Returns the coordinates of an instance. This is either the location in the dungeon, or, using special coordinates, its location in a character or monster's inventory, in limbo, etc.
-- returns: level, x, y, tile_location
function dsb_get_coords(id)
   local pos = id_table[id].pos
   return pos[1], pos[2], pos[3], pos[4]
end


-- Returns the object's coordinates before its most recent movement.
-- returns: level, x, y, tile_location
function dsb_get_coords_prev(id)
   local pos = id_table[id].lastpos
   if pos then
	  return pos[1], pos[2], pos[3], pos[4]
   end
end


-- Checks a specified location and returns what's there. If this is a special coordinate, it is either nil or just an id number. If this is a dungeon location (that is, a level >= 0) or if the special specifier TABLE is used for tile_location, it will return a table of ids. -1 can also be used for the y coordinate when using a special coordinate to return a table of all matching ids, for example, IN_OBJ will give everything inside that object. In these cases, a number is also returned matching the number of instances fetched (but can be ignored if you choose)
-- returns: id (or table of ids), ~[number]
function dsb_fetch(level, x, y, tile_location)
   if level < 0 then
	  if tile_location == TABLE then
		 if world[level].map[x] and world[level].map[x][y] then
			return {world[level].map[x][y].id}
		 else
			return {}
		 end
	  elseif y == VARIABLE then
		 local instances

		 if world[level] and world[level].map[x] and world[level].map[x][0] then
			instances = world[level].map[x][0].instances
		 end

		 return instances, #instances
	  else
		 if world[level] and world[level].map[x] and world[level].map[x][y] then
			local instances = world[level].map[x][y].instances
			return world[level].map[x][y].instances[1]
		 end
	  end
   else
	  local ids = {}
	  if world[level].map[x] and world[level].map[x][y] and world[level].map[x][y].instances then
		 return world[level].map[x][y].instances -- instances
	  end
	  return ids
   end
end


-- Determines the arch of the given instance id. This is often needed in order to access information about the object's general type.
-- returns: arch
function dsb_find_arch(id)
   local at = id_table[id].arch_type
   local arch = _G["obj"][at]
   return arch
end


function save_things(level,neg)
   if world[level] then
	  local map = world[level].map
	  -- local x_size = floor.x_size
	  -- local y_size = floor.y_size
	  for xid,x in pairs(map) do
		 for yid,y in pairs(x) do
			local instances = y.instances
			if instances then
			   --while #instances > 0 do
			   for i = 1,#instances do
				  local id = instances[(#instances + 1) - i] -- table.remove(instances)
				  if (neg and id < 0) or ((not neg) and id >= 0) then -- id >= 0 then
					 --for _,id in pairs(instances) do
					 local instance = id_table[id]
					 if not instance then
						print("NO INSTANCE " .. id .. " " .. " " .. level .. "  " .. xid .. " " .. yid .. " ")
					 end

					 io.write("dsb_spawn(" .. instance.id .. ", \"" .. instance.arch_type .. "\", " ..  instance.pos[1] .. ", " .. instance.pos[2] .. ", " .. instance.pos[3] .. ", " .. instance.pos[4] .. ")\n")
					 if dsb_get_gfxflag(instance.id, GF_INACTIVE) then
						io.write("dsb_disable(" .. instance.id .. ")\n")
					 end
					 if instance.arch.type == "MONSTER" then
						io.write("mon_hp(" .. instance.id .. ", " .. dsb_get_hp(instance.id) .. ")\n")
					 end
					 --						if instance.arch.def_charge and (instance.charge ~= instance.arch.def_charge) then
					 --						   io.write("dsb_set_charge(" .. instance.id .. ", " .. instance.charge .. ")\n")
					 --						end
				  end
			   end
			end
		 end
	  end
   end
end


function save_game(filename)
   dsb_write(system_color, "SAVING " .. string.upper(filename))

   file = io.open (filename,"w")
   io.output(file)

   io.write("---DSB ESB---\n")
   io.write("--[[ Autogenerated by ESB.\n")
   io.write("	  Trying to edit this file by hand may not give you\n")
   io.write("	  particularly good results.\n")
   io.write("]]\n")

   for level = 0,1000 do
	  if world[level] then
		 local floor = world[level]
		 local x_size = floor.x_size
		 local y_size = floor.y_size
		 io.write("dsb_text2map(" .. level .. ", " .. x_size .. ", " .. y_size .. ", " .. floor.light .. ", " .. floor.xp_multiplier .. ", {\n")
		 for y = 0,y_size do
			io.write("\"")
			for x = 0,x_size do
			   if dsb_get_cell(level, x, y) then
				  io.write("0")
			   else
				  io.write("1")
			   end
			end
			io.write("\",\n")
		 end
		 io.write("})\n")
		 if world[level].flags then
			io.write("dsb_level_flags(" .. level .. ", " .. world[level].flags .. ")\n")
		 end
	  end
   end

   for _,champion in pairs(champions) do
	  io.write("dsb_add_champion(" .. champion.id .. ", \"" .. champion.varname .. "\", \"" .. champion.portrait_gfxname .. "\", \"" .. champion.first_name .. "\", \"" .. champion.last_name .. "\", " .. champion.maxbars[HEALTH] .. ", " .. champion.maxbars[STAMINA] .. ", " .. champion.maxbars[MANA] .. ", " .. champion.maxstats[STAT_STR] .. ", " .. champion.maxstats[STAT_DEX] .. ", " .. champion.maxstats[STAT_WIS] .. ", " .. champion.maxstats[STAT_VIT] .. ", " .. champion.maxstats[STAT_AMA] .. ", " .. champion.maxstats[STAT_AFI] .. ", " .. champion.maxstats[STAT_LUC] .. ", " .. levels_string(champion,CLASS_FIGHTER) .. ", " .. levels_string(champion,CLASS_NINJA) .. ", " .. levels_string(champion,CLASS_PRIEST) .. ", " .. levels_string(champion,CLASS_WIZARD) .. ")\n")
   end

   io.write("ch_exvar = " .. inspect(ch_exvar) .. "\n")

   -- io.write("ch_exvar = {\n")
   -- io.write("}\n")

   for level = 1000,-5,-1 do
	  save_things(level,false)
   end

   -- io.write("exvar = {\n")
   -- for _,instance in pairs(id_table) do
   -- 	  if exvar[instance.id] then
   -- 		 local t = exvar[instance.id]
   -- 		 if tablelength(t) > 0 then
   -- 			io.write("[" .. instance.id .. "] = ")
   -- 			io.write(inspect(exvar[instance.id]))
   -- 			io.write(",\n")
   -- 		 end
   -- 	  end
   -- end
   -- io.write("}\n")

   io.write("exvar = " .. inspect(exvar) .. "\n")

   io.write("dsb_party_place(" .. party.pos[1] .. ", " .. party.pos[2] .. ", " .. party.pos[3] .. ", " .. party.pos[4] .. ")\n")

   io.write("\n\nif LUADSB_VERSION then\n")


   for level = 1000,-5,-1 do
	  save_things(level,true)
   end

   if party.holding then
	  local instance = id_table[party.holding]
	  io.write("dsb_spawn(" .. instance.id .. ", \"" .. instance.arch_type .. "\", " ..  instance.pos[1] .. ", " .. instance.pos[2] .. ", " .. instance.pos[3] .. ", " .. instance.pos[4] .. ")\n")
	  if dsb_get_gfxflag(instance.id, GF_INACTIVE) then
		 io.write("dsb_disable(" .. instance.id .. ")\n")
	  end
	  io.write("remove_id(" .. party.holding .. ")\n")
	  io.write("take_id(" .. party.holding .. ")\n")
   end

   for ppos = 0,3 do
	  if get_ppos(ppos) then
		 local id = ppos_info(ppos).id
		 io.write("champions[" .. id .. "].stats = " .. inspect(get_char(id).stats) .. "\n")
		 io.write("champions[" .. id .. "].bars = " .. inspect(get_char(id).bars) .. "\n")
	  end
   end

   -- io.write("dsb_table = {\n")
   -- for _,instance in pairs(id_table) do
   -- 	  if dsb_table[instance.id] then
   -- 		 local t = dsb_table[instance.id]
   -- 		 if tablelength(t) > 0 then
   -- 			io.write("[" .. instance.id .. "] = ")
   -- 			io.write(inspect(t))
   -- 			io.write(",\n")
   -- 		 end
   -- 	  end
   -- end
   -- io.write("}\n")

   io.write("dsb_table = " .. inspect(dsb_table) .. "\n")

   for _,export in pairs(exports) do
	  if _G[export] then
		 io.write(export .. " = " .. inspect(_G[export]) .. "\n")
	  end
   end

   io.write("g_next_char = 0\n")

   for ppos = 0,3 do
	  if get_ppos(ppos) then
		 io.write("dsb_champion_toparty(" .. ppos ..", " .. ppos_info(ppos).id .. ")\n")
		 io.write("get_ppos(" .. ppos .. ").info = " .. inspect(ppos_info(ppos)) .. "\n")
	  end
   end

   io.write("flying_instances = " .. inspect(flying_instances) .. "\n")

   io.write("party = " .. inspect(party) .. "\n")

   io.write("end\n")
   
   io.close(file)

   sys_game_save()
end


-- Totally destroys the targeted instance and creates a new one at its location with its id number and the new archetype. Things like exvars are not preserved.
function dsb_swap(id, new_arch)
   local instance = id_table[id]
   local level, x, y, tile = dsb_get_coords(id)
   dsb_delete(id)
   dsb_spawn(id, new_arch, level, x, y, tile)
   id_table[id].gfxflag = instance.gfxflag
   exvar[id] = {}

end


-- Quick-swaps an instance to a new archetype. That is, it changes only the arch, but no internal variables or exvars. This means that if the new arch is a radically different type, strange things will probably happen and the game might crash. It's quite handy for making push-buttons that change appearance and such, though.
function dsb_qswap(id, new_arch)
   local instance = id_table[id]
   instance.arch_type = new_arch
   instance.arch = dsb_find_arch(id)
end


-- Completely destroys an instance from the dungeon.
function dsb_delete(id)
   local arch = dsb_find_arch(id)
   local instance = id_table[id]
   if arch.type == "MONSTER" then
	  world[instance.pos[1]].monsters[id] = nil
   end
   remove_value(world[instance.pos[1]].map[instance.pos[2]][instance.pos[3]].instances, id)
   
   id_table[id] = nil
   exvar[id] = nil

   if party.holding == id then
	  drop_holding()
   end
   dsb_table[id] = nil
end

-- In most cases, it is better to send the instance an M_DESTROY message instead.
-- returns: direction
function dsb_get_facedir(id)
   return id_table[id].dir
end


-- Gets or sets the direction a monster is facing or a flying instance is currently travelling.
function dsb_set_facedir(id, direction)
   id_table[id].dir = direction
end


-- Sends the specified instance flying through the air. It originates at the given level, x, y, and tile_pos, flying in the given direction. Power and damage are variables used by the game to control how far the object flies and how hard it hits. Delta represents how much is subtracted from power each subtile of flight. Delta is also subtracted from damage, unless an optional damage delta is specified instead. When the instance runs out of power, it falls to the ground (or vanishes if flying_only is set on its archetype)
-- ~[damage_delta]
function dsb_shoot(id, level, x, y, direction, tile_pos, power, damage, delta, damage_delta)
   local instance = id_table[id]

   dsb_table[id].flying = {power, direction, damage, delta, damage_delta}

   dsb_move(id, level, x, y, tile_pos)

   table.insert(flying_instances,instance.id)
end


function find_hittable(level,x,y)
   local ids = dsb_fetch(level,x,y)
   if ids then
	  for _,id in pairs(ids) do
		 local instance = id_table[id]
		 local arch = instance.arch
		 if arch.type == "MONSTER" or (arch.type == "DOOR" and (not dsb_get_gfxflag(id,GF_INACTIVE))) then
			return id
		 end
	  end
   end
end


function update_flying()
   local stopped = {}
   for _,id in pairs(flying_instances) do
	  local instance = id_table[id]
	  local flying = dsb_table[instance.id].flying
	  local nx,ny = dsb_forward(flying[2])
	  nx = nx + instance.pos[2]
	  ny = ny + instance.pos[3]
	  local level = party.pos[1]
	  local hit = find_hittable(level, nx, ny)
	  if hit or dsb_get_cell(level, nx, ny) or flying[1] <= 0 then
		 local arch = dsb_find_arch(instance.id)

		 if (hit or dsb_get_cell(level, nx, ny)) and arch.on_impact then
			if hit then
			   dsb_move(instance.id, instance.pos[1], nx, ny, 0)
			end
			arch:on_impact(instance.id, hit, 0)
			stopped[instance.id] = instance
		 end

		 instance = id_table[id]
		 if instance then
			if not arch.explode_into then
			   dsb_table[instance.id].flying = nil
			   dsb_move(instance.id, instance.pos[1],  instance.pos[2],  instance.pos[3], 0)
			   stopped[instance.id] = instance
			end
		 end
	  else
		 flying[1] = flying[1] - 1
		 dsb_move(instance.id, instance.pos[1], nx, ny, 0)
	  end
   end

   for _,instance in pairs(stopped) do
	  remove_value(flying_instances,instance.id)
   end
end


-- Returns the information on a flying instance.
-- returns: power, direction, damage
function dsb_get_flystate(id)
   local flying = dsb_table[id].flying
   if flying then
	  return flying[1], flying[2], flying[3]
   end
end


-- This is a minor hack used to specify that the instance has been shot in open space (by a champion or monster, instead of by a wall shooter, for example) and thus should not have collision detection immediately. If this is not set, the instance will instantly run into the character or monster that was supposed to have "launched" it.
function dsb_set_openshot(id)
   id_table[id].openshot = true
end


-- Performs collision detection on a flying object for the specified location. This is useful when directly moving monsters around (e.g., via dsb_move) so that they will not apparently move "through" flying missiles.
-- returns: { {id, tile}, ~[...] }
function dsb_collide(id, lev, x, y, tile, direction)
end


-- Allows you to set the number of update repetitions (default value is 1) that a flying object performs per tick. For example, a value of 8 will cause the id flying object to move 8 sub-tiles per tick, or 4 full tiles.
function dsb_set_flyreps(id, repetitions)
   id_table[id].flyreps = repetitions
end


-- returns: value
function dsb_get_gfxflag(id, flag)
   if id_table[id].gfxflag then
	  return (bit.band(id_table[id].gfxflag, flag) > 0)
   end
end


-- Gets, sets, clears, or toggles the value of a Graphics Flag for a given instance.
function dsb_set_gfxflag(id, flag)
   id_table[id].gfxflag = bit.bor(id_table[id].gfxflag,flag)
end


function dsb_clear_gfxflag(id, flag)
   id_table[id].gfxflag = bit.band(id_table[id].gfxflag,bit.bnot(flag))
end


function dsb_toggle_gfxflag(id, flag)
   id_table[id].gfxflag = bit.bxor(id_table[id].gfxflag,flag)
end

-- returns: integer
function dsb_get_charge(id)
   return dsb_table[id].charge or 0
end


-- Gets or sets the charge of a given instance. This is normally used by limited-use items but it can have other applications. It is used to set the size of clouds and spells, too. It must be a number from 0 to 63.
function dsb_set_charge(id, integer)
   dsb_table[id].charge = integer
end


-- returns: integer
function dsb_get_crop(id)
   return dsb_table[id].crop or 0
end


-- Gets or sets how much a door is cropped in its display. This is used when they open and close.
function dsb_set_crop(id, integer)
   dsb_table[id].crop = integer
end


function dsb_spawnburst_begin()
end


-- Begins or ends a Spawnburst.
function dsb_spawnburst_end()
end


function remove_id(id)
   local instance = id_table[id]

   remove_instance(world[instance.pos[1]].map[instance.pos[2]][instance.pos[3]], instance)
end


-- A shortcut command to push the specified instance into the mouse hand.
function dsb_push_mouse(id)
   remove_id(id)
   take(id_table[id])
end


-- A shortcut command to pop anything in the mouse hand out, returning its id at the same time.
-- returns: id
function dsb_pop_mouse()
   local holding = party.holding
   drop_holding()
   return holding
end


-- Returns true if the instance exists, false if it doesn't but the id is valid, and nil if it is not a valid instance id.
-- returns: ternary value
function dsb_valid_inst(id)
   if id_table[id] == false then
	  return false
   elseif id_table[id] then
	  return true
   end
end


--------------
-- Monsters --
--------------

-- Monsters are insts as well, and (almost?) all commands that affect insts will work just the same on monsters, but monsters have their own specialized functionality as well.
-- returns: integer
function dsb_get_hp(id)
   return id_table[id].hp
end


-- Gets or sets a monster's HP. Please note that this function has nothing to do with how to get or set a character's HP. In addition, the scale used by monster HP is not scaled up by a factor of 10.
function dsb_set_hp(id, integer)
   id_table[id].hp = integer
   if integer == 0 then
	  sys_kill_monster(id)

	  dsb_delete(id)
   end
end


-- returns: integer
function dsb_get_maxhp(id)
   return id_table[id].maxhp
end


-- returns: Gets or sets a monster's max HP.
function dsb_set_maxhp(id, integer)
   id_table[id].maxhp = integer
end


-- Sets the 'tint' of a monster, to give it a glowing effect. Monsters flash when they are hit by various spells. There is finally an optional intensity level parameter, set at 127 by default with a range of 0 to 255. 0 Being completely black.
-- ~[intensity]
function dsb_set_tint(id, RGB, intensity)
   id_table[id].tint = {RGB,intensity}
end


-- Sends an Monster AI message to the given monster.
-- ~[= result]
function dsb_ai(id, message, data)
   -- print("Sending AI msg " .. message .. " to " .. id)
   if message == AI_FEAR then
	  if data == QUERY then
		 return id_table[id].fear
	  else
		 id_table[id].fear = data
	  end
   elseif message == AI_DELAY_ACTION then
   elseif message == AI_STUN then
   elseif message == AI_HAZARD then
   elseif message == AI_WALL_BELIEF then
   elseif message == AI_ATTACK_BMP then
   elseif message == AI_DELAY_EVERYTHING then
   elseif message == AI_DELAY_TIMER then
   elseif message == AI_MOVE_NOW then
   elseif message == AI_SEE_PARTY then
	  if data == QUERY then
		 return id_table[id].seeparty
	  else
		 id_table[id].seeparty = data
	  end
   elseif message == AI_TARGET then
   elseif message == AI_UNGROUP then
   elseif message == AI_MOVE then
	  local dx, dy = dsb_forward(data)
	  local level, x, y = dsb_get_coords(id)
	  dsb_move(id, level, x + dx, y + dy, 4)
	  if id_table[id].arch.on_move then
		 id_table[id].arch.on_move(id_table[id], id, id_table[id])
	  end
	  return true
   elseif message == AI_TURN then
	  id_table[id].dir = data
	  return true
   elseif message == AI_TIMER then
	  if data == QUERY then
		 return dsb_table[id].timer or 0
	  else
		 dsb_table[id].timer = data
	  end
   else
	  print("Unknown AI msg " .. messsage .. " to " .. id)
   end
end


-- If data is QUERY then the function will return information on the given value, rather than setting it. For example, dsb_ai(id, AI_FEAR, QUERY) will return the monster's current level of fear. Monster AI documentation.
-- Returns the given monster id's boss. The "boss" is the monster in each tile who controls when the entire group moves and attacks. This allows DSB monsters to all be distinct entities, but move in DM-style groups.
-- returns: boss_id
function dsb_ai_boss(id)
   return id_table[id].boss
end


-- Promotes the given monster id to be the boss of its tile.
function dsb_ai_promote(id)
   id_table[id].boss = id
   local instances = dsb_fetch(id_table[id].pos[1], id_table[id].pos[2], id_table[id].pos[3])
   for _,instance_id in pairs(instances) do
	  local instance = id_table[instance_id]
	  if instance.arch.type == "MONSTER" then
		 instance.boss = id
	  end
   end
end


-- Returns all monsters who are subordinate to the given boss.
-- returns: { {id, tile}, [...] }
function dsb_ai_subordinates(id)
   local subs = {}
   local membs = 0
   local instances = dsb_fetch(id_table[id].pos[1], id_table[id].pos[2], id_table[id].pos[3])
   for _,instance_id in pairs(instances) do
	  local instance = id_table[instance_id]
	  if instance.arch.type == "MONSTER" and instance.boss == id then -- and not (instance.id == id) then
		 membs = membs + 1
		 local inst = {}
		 inst.id = instance.id
		 inst.tile = instance.pos[4]
		 table.insert(subs, inst)
	  end
   end
   return membs, subs
end


---------------
-- Messaging --
---------------

-- Sends the specified Messages to the specified instance after the specified delay. Messages are simply integers. The object responds to the message as specified by its msg_handler, defined in its archetype. See base/msg_handlers.lua for many examples of what can be done with message handlers. Normally it doesn't matter where a message comes from. However, it is possible to assert the sender of the message, in the rare cases where it is needed. (See https://dmwiki.atomas.com/wiki/DSB/Messages for more information on how to use messages)
-- ~[sender]
function dsb_msg(delay, id, message, data, sender)
   g_new_messages[g_message_id] = {delay, id, message, data, sender, g_message_id}
   g_message_id = g_message_id + 1
   local chain = g_message_chains[id]
   if chain then
	  for _,target in pairs(chain) do
		 dsb_msg(delay,target,message,data,sender)
	  end
   end
end


function handle_msg(msg)
   local delay = msg[1]
   local id = msg[2]
   local message = msg[3]
   local data = msg[4]
   local sender = msg[5]

   if id_table[id] then
	  local hstring = base_msg_handler[message]
	  if dsb_find_arch(id).msg_handler then
		 hstring = dsb_find_arch(id).msg_handler[message]
	  end
	  if hstring then
		 if type(hstring) == "string" then
			_G[hstring](id,data)
		 else
			hstring(id,data)
		 end
	  else
		 local func = _G[sys_default_msg_handler[message]]
		 if func then
			_G[sys_default_msg_handler[message]](id,data)
		 else
			print("DSB_MSG: " .. delay .. " " .. id .. " " .. message)
			print("Has a torch received a delayed NEXTTICK message after converting to a torch_x?")
		 end
	  end
   end
end


-- This causes the first instance to relay any messages it receives to the second instance. This is useful for making ceiling pits close at the same time floor pits do, and other situations where an instance should pass messages along.
function dsb_msg_chain(id, target_id)
   if not g_message_chains[id] then
	  g_message_chains[id] = {}
   end
   table.insert(g_message_chains[id],target_id)
end


-- Delays all messages bound for a given instance by the specified delay.
function dsb_delay_msgs_to(id, delay)
end


-- Enables an instance. This will clear its INACTIVE flag as well as make sure any events, triggerings, etc. that should happen do happen. This function is easier and safer to use than setting the flag directly.
function dsb_enable(id)
   dsb_clear_gfxflag(id, GF_INACTIVE)

   local lev,x,y = dsb_get_coords(id)

   local instance = id_table[id]
   local arch = instance.arch

   local tids = dsb_fetch(lev,x,y)
   if tids then
	  for _,tid in pairs(tids) do
		 local tinstance = id_table[id]
		 if instance.arch.on_trigger then
			instance.arch:on_trigger(id, tid)
		 end
	  end
   end
end


-- Disables an instance. This will set its INACTIVE flag and make sure that any objects on it stop triggering it.
function dsb_disable(id)
   local lev,x,y = dsb_get_coords(id)

   local instance = id_table[id]
   local arch = instance.arch

   local ids = dsb_fetch(lev,x,y)
   if tids then
	  for _,tid in ids do
		 local tinstance = id_table[id]
		 if instance.arch.on_trigger then
			instance.arch:off_trigger(id, tid)
		 end
	  end
   end

   dsb_set_gfxflag(id, GF_INACTIVE)
end


-- See the previous two.
function dsb_toggle(id)
   dsb_toggle_gfxflag(id, GF_INACTIVE)
end


-- Adds a new message type to the system. Values above 100000 are reserved for the base code.
-- Custom msg types will presumably still be handled the same way the built in ones are, so may be useful for triggering events on custom archs.
-- Hmm. This could get messy if you combine msgtypes with importable archs...
-- returns: none?
function dsb_add_msgtype(code_name,int_value)
   loadstring("_G." .. code_name .. " = " .. int_value)()
end


-----------
-- Light --
-----------

-- returns: lightlevel
function dsb_get_light(handle)
   return g_lights[handle] or 0
end


-- Gets or sets the light level on the given light handle, which is an integer from 0 to 9. The light level displayed is the sum of the dungeon level's base light level plus the 10 light handles. Currently, light handle 0 is used for light spells, handle 1 is used for torches, and 2 is used by illumulets.
function dsb_set_light(handle, lightlevel)
   g_lights[handle] = lightlevel
end


----------------
-- Conditions --
----------------

-- Adds a condition (status variable) to the list of those available. The type is either PARTY (affects the whole party) or INDIVIDUAL (affects one person). For individual conditions, two graphics can be specified, one that affects the inventory screen, the other that affects the portrait area. If type is PARTY the third parameter portrait_gfx is now considered as overlay_gfx and will be seen in the dungeon view port. We can apply an underwater effect for example, as the overlay includes support for alpha channels if you want transparent parts.
-- If update_freq is > 0, the specified function will be called at the specified number of ticks. The function takes the following form:
-- ~[flags]
function dsb_add_condition(type, inventory_gfx, portrait_gfx, update_freq, func, flags)
   local condition = g_next_condition
   g_conditions[condition] = {type,inventory_gfx,portrait_gfx,update_freq,func,flags}
   g_next_condition = g_next_condition + 1
   return condition
end


-- function update_func(char, condition_strength)
--    return new_condition_strength
-- end


-- Flags can be specified to control other aspects of the condition's appearance on the inventory screen. These flags are COND_MOUTH_RED, COND_MOUTH_GREEN, COND_EYE_RED, and COND_EYE_GREEN. These flags only affect INDIVIDUAL conditions. There was formerly a condition type called BAD_INDIVIDUAL that was an INDIVIDUAL condition with COND_MOUTH_RED. It is now deprecated. Please don't use it in new code.


-- Replaces the information for the condition with the given id with the new condition. Good for changing conditions on the fly, but keep in mind that the fact that you've changed the condition won't be saved.
function dsb_replace_condition(condition_id, type, inventory_gfx, portrait_gfx, update_freq, func)
end


-- Returns the strength of the specified condition for the specified character (or, in the case of conditions for the whole party, pass PARTY as the character)
-- returns: strength
function dsb_get_condition(char, condition)
   if char == PARTY then
	  return party.conditions[condition]
   else
	  return char_info(char).conditions[condition]
   end
end

-- Sets the strength of the condition. See previous function.
function dsb_set_condition(char, condition, strength)
   if char == PARTY then
	  party.conditions[condition] = strength
   else
	  char_info(char).conditions[condition] = strength
   end
end


-------------------------
-- Popups and Readouts --
-------------------------

-- Shows the amount of damage taken by a character in a little popup over the character's name or portrait. The type is either HEALTH, STAMINA, or MANA, and a different background icon is displayed for each. The amount of damage shown should be in units as the player perceives them, not internal (so, divided by ten from internal representations)-- the default functions in base/damage.lua take care of this for you.
function dsb_damage_popup(ppos, damage_type, integer)
   ppos_info(ppos).damage[damage_type] = integer
end


-- This causes a number in a little explosion to appear in the area occupied by the attack icons. This is used for showing the amount of damage inflicted upon a monster by a melee attack.
function dsb_attack_damage(integer)
   damage_amount = integer
end


-- This causes text to momentarily appear in the area occupied by the attack icons. This is used for things like "CAN'T REACH" or "NEED AMMO."
function dsb_attack_text(string)
   dsb_write({255,255,255}, string)
end


----------------
-- Fullscreen --
----------------

-- This engages the full-screen renderer, and is used for cut scenes or other interludes. If the first parameter passed is a bitmap, that bitmap will be displayed. If the first parameter is instead a function, that function will be executed every frame. The draw function will be passed the bitmap to draw to, the mouse's x location, and the mouse's y location, in the form: draw_function(bitmap, mouse_x, mouse_y)
-- The click_func, if provided, will be executed every time the mouse is clicked. It is of the form: click_func(mouse_x, mouse_y, mouse_buttons)
-- Update_func, if provided, will be executed every game tick. It takes no parameters.
-- If mouse is nil or false, no mouse pointer will be drawn. If it is true, the standard "yellow arrow" mouse pointer will be drawn. If it is a bitmap, that bitmap will be drawn as the mouse pointer.
-- There is an optional 5th parameter (a table of booleans) that allows a fade in/fade out. The game_draw allows you to have the game view drawn in the background. So, for example, for a fullscreen view that fades in and draws the game view.
-- The full-screen renderer will run until any of its associated functions returns something other than false or nil, and the game logic does not advance while in dsb_fullscreen.
-- { fade = true, game_draw = true }
function dsb_fullscreen(bitmap_or_func, click_func, update_func, mouse, fade, game_draw)
   fade = fade == nil and true or true
   game_draw = game_draw == nil and true or true
   if type(bitmap_or_func) == "function" then
	  fullscreen_func = bitmap_or_func
	  fullscreen_click = click_func
   end
end


---------------------------------------
-- Subrenderers and System Renderers --
---------------------------------------

-- Returns a bitmap to be drawn upon. Use only in a Subrenderer.
-- returns: bitmap
function dsb_subrenderer_target()
   return subrender_bitmap
end


-- Creates an object zone associated with the given id at the given x and y coordinates on the given subrenderer or system bitmap. This object zone can be used to access instances that are stored inside of the given instance. See the implementation of chests in base/objects.lua for more information and examples.
function dsb_objzone(bitmap, id, number, x, y, ppos)
   local zone = {bitmap, id, number, x, y, ppos}
   dsb_bitmap_rect(bitmap, x, y, x + 32, y + 32, light_grey, false)

   if id == SYSTEM then	  
	  if not ppos then		
	  	 ppos = portrait_char(bitmap.x + 1)
	  end

	  local char_id = dsb_ppos_char(ppos)
	  -- print("CID:" .. ppos .. " " .. inspect(char_id))
	  if dsb_fetch(CHARACTER, char_id, number) then
		 local instance = id_table[world[CHARACTER].map[char_id][number].instances[1]]
		 local arch = dsb_find_arch(instance.id)
		 if dsb_get_gfxflag(instance.id, GF_ALT_ICON) and arch.alt_icon then
			dsb_bitmap_draw(arch.alt_icon, bitmap, x, y)
		 else
			dsb_bitmap_draw(arch.icon, bitmap, x, y)
		 end
	  elseif inventory_info[number].icon then
		 dsb_bitmap_draw(inventory_info[number].icon, bitmap, x, y)
	  end
   else
	  --print("ID: " .. id)
	  if dsb_fetch(IN_OBJ,id,number) then
		 local instance = id_table[world[IN_OBJ].map[id][number].instances[1]]
		 local arch = dsb_find_arch(instance.id)
		 if dsb_get_gfxflag(instance.id, GF_ALT_ICON) and arch.alt_icon then
			dsb_bitmap_draw(arch.alt_icon, bitmap, x, y)
		 else
			dsb_bitmap_draw(arch.icon, bitmap, x, y)
		 end
	  end
   end
   table.insert(objzones,zone)
end


-- Creates an object zone associated with the given id at the given x and y coordinates on the given subrenderer or system bitmap, with the given width and height. When it is clicked, the specified message will be sent to the instance. This can allow fairly complicated user interfaces in subrenderers.
-- The third parameter, number, allows you to override/replace zones by specifying an existing handle. It also allows msgzones to have more information about where you clicked, because the zone number you clicked is passed as the msg's data parameter. If you don't care about any of this, just keep incrementing the number for every new zone. (See DSB/Messages for more information on how to use messages)
-- ~[data1, data2]
function dsb_msgzone(bitmap, id, num, x, y, width, height, msg, data, data2)
   local k = bitmap.x + 1
   if num == AUTOMATIC then
	  num = bitmap.id
   end
   table.insert(msgzones, {bitmap,id,num,x,y,width,height,msg,data, data2})
end

-----------------------------------------------
-- Global Data, Utility Functions, and Misc. --
-----------------------------------------------

-- returns: value
function dsb_get_gameflag(flag)
end


function dsb_set_gameflag(flag)
end


function dsb_clear_gameflag(flag)
end


-- Gets, sets, clears, or toggles the value of a Global Flag.
function dsb_toggle_gameflag(flag)
end


-- ~[bool]
function dsb_hide_mouse(bool)
end


-- Functions to make the mouse pointer appear or disappear. dsb_hide_mouse Takes an optional parameter of true to allow the pointer to return after a successful melee attack, after moving the mouse.
function dsb_show_mouse()
end


-- ~[flag]
function dsb_lock_game(flag)
   local flag = flag or 1
   g_lock = bit.bor(g_lock,flag)
end


-- Functions to lock or unlock the game. Complete locking prevents most timers from running (though animations and delayed functions still will), processing any player input, or triggering anything. If you lock the game and forget to unlock it, it will be left in an unplayable state, so be very careful how you use this! Note that this takes effect immediately (that is, even before any queued moves), which may not always be what you want. You can also lock only certain parts of the game, using the locking flags.
-- ~[flag]
function dsb_unlock_game(flag)
   local flag = flag or 1
   g_lock = bit.band(g_lock,bit.bnot(flag))
end


-- Generates a random integer between min and max, inclusive.
-- You should always use this function for random number generation, not anything built into Lua.
-- While larger ranges will not cause errors per-se, the output of dsb_rand seems to be a 15 bit range (0-32767) modulused across the input range
-- returns: integer
function dsb_rand(min, max)
   return math.random(min,max)
end


-- A utility function that splits up a string into individual lines (placing the number of lines returned in number_of_lines) demarcated by the split character. "/" (slash) is a common choice for a a split character. See the implementation of scrolls in base/objects.lua for an example.
-- returns: lines, number_of_lines
function dsb_linesplit(text, delim)
   -- returns an array of fields based on text and delimiter (one character only)
   local result = {}
   local magic = "().%+-*?[]^$"

   if delim == nil then
	  delim = "%s"
   elseif string.find(delim, magic, 1, true) then
	  -- escape magic
	  delim = "%"..delim
   end

   local pattern = "[^"..delim.."]+"
   for w in string.gmatch(text, pattern) do
	  table.insert(result, w)
   end

   return result, #result
end


-- A utility function that, given a direction, returns the x and y offsets of which way is "forward." One will always be 1 or -1, the other will always be 0.
-- returns: x, y
function dsb_forward(direction)
   local hpi = math.pi / 2

   local rad = direction * hpi

   local yoff = -math.floor(math.cos(rad) + 0.5)
   local xoff = math.floor(math.sin(rad) + 0.5)

   return xoff, yoff
end


-- A utility function that shifts the specified location in the specified direction. If you don't know what this is for, you probably don't need it.
-- returns: location
function dsb_tileshift(location, direction)
   -- print("dsb_tileshift: " .. inspect(location) .. " " .. inspect(direction))
   return location
end


-- Returns the variable named by the specified string. If you don't know what this is for, you probably don't need it.
-- returns: variable
function dsb_lookup_global(string)
   return _G[string]
end

-- Executes the given function after the given delay in ticks. References to Lua functions cannot be saved, so queued functions will not be saved. This should be something nonvital if the game is not locked, and should happen quickly. In most cases, using a message on a delay, which is saved, would work better.
function dsb_delay_func(delay, func)
   table.insert(delay_functions,{delay,func})
end


-- If the inventory_info has been changed, this lets the engine know. Note that this state is not saved.
function dsb_update_inventory_info()

end


-- If the system strings or player colors have been changed, this lets the engine know. This may or may not be useful. With the moving of most inventory rendering into Lua-controlled subrenderers, this function has limited use.
-- Normally, Lua global variables aren't saved in savegames, however, a few usually need to be. If you need to store a global variable, add it to the export list with this function. Note that dsb_export requires a string giving the name of the variable. Don't pass the variable itself! You should also note that if you have a very long export list, you're probably doing something that could be done more easily with specialized code or more careful use of instances with exvars. If you don't know what this is for, you probably don't need it.
function dsb_export(string)
   table.insert(exports,string)
end


function dsb_update_system()
end


-- Sets the viewport. Odds are you should leave this one alone.
function dsb_viewport(x, y)
end


-- Deprecated
function dsb_rune_enable(rune)
end

-- Enables or disables the specified magical rune for use in spells. All spell are enabled by default, just like in original DM. The rune is specified as an integer, where 1 = LO, 2 = UM, 7 = YA, and so on.
-- These functions are now deprecated. You should manipulate the g_disabled_spell table directly. For example, disabling the VI rune (rune 8) is as simple as g_disabled_spell~[8] = false.
-- (Deprecated)
function dsb_rune_disable(rune)
end


-- Shows a game ending screen. Normally it's a bit more fun than the screen you get when the party dies, but if you pass it a boolean 'true', it will just show the standard blue "The End" screen.
-- ~[bool]
function dsb_game_end(bool)
   g_state = STATE_END   
end


-- This function creates a new arch type, from the original passed in as a parameter. See a simple example.
-- returns: new arch
function clone_arch(object_arch)
end


-- Loads and runs a named lua file relative to the dungeon's directory. The file is loaded with the ROOT_NAME variable set to the given local name, so that the code being loaded can use that to avoid interfering with the parent codebase. Can only be used from the objects.lua file. Several examples are found in the test_dungeon. Somemoreinfo
-- returns: none?
function dsb_import_arch(lua_filename,local_name)
end

-- Pending Documentation

function dsb_override_floor()
end


function dsb_override_roof()
end

-- include a file in graphics.dsb when compiling
function dsb_include_file()
end

function dsb_cache_invalidate()
end


function dsb_tileptr_exch()
end


function dsb_party_viewing()
end


function dsb_party_affecting()
end


function dsb_checksound()
end


function dsb_get_gamelocks()
end


function dsb_get_light_total()
   return 100
end


function dsb_set_light_totalmax()
end


function dsb_get_exviewinst()
end


function dsb_wallset_flip_floor()
end


function dsb_wallset_flip_roof()
end


function dsb_get_pendingspell(magician)
   return unpack(ppos_info(magician).spell) -- 0,0,0,0,0,0,0,0
end


function tablelength(T)
   local count = 0
   for i in pairs(T) do
	  -- print("I: " .. i)
	  count = count + 1
   end
   return count
end


function dsb_set_pendingspell(ppos, ...)
   local arg = {...}
   if #arg == 1 then
	  ppos_info(ppos).spell = {arg[1],0,0,0,0,0,0,0}
   else
	  ppos_info(ppos).spell = arg
   end
end


function dsb_level_flags(a,b)
   world[a].flags = b
end


function get_ppos(ppos)
   return g_characters[ppos]
end


function remove_champions()
   for ppos = 0,3 do
	  if get_ppos(ppos) then
		 local char_id = ppos_info(ppos).id
		 for id,instance in pairs(id_table) do
			-- print("ID: " .. id)
			if exvar[id] and exvar[id].champion == char_id then
			   exvar[id].champion = nil
			   got_triggered(id, nil)
			end
		 end
	  end
   end
end


function print_map()
   local floor = world[party.pos[1]]
   for y = 1,9 do
	  for x = 1,9 do
		 local locx = (party.pos[2] - 5) + x
		 local locy = (party.pos[3] - 5) + y
		 if locx == party.pos[2] and locy == party.pos[3] then
			io.write("*")
		 elseif locy >= floor.y_size or locy < 0 or locx >= floor.x_size or locx < 0 then
			io.write(".")
		 else
			io.write("" .. 1 - floor.map[locx][locy].wall)
		 end
	  end
	  io.write("\n")
   end
   io.write("\n")
end


function move(dir)
   local hpi = math.pi / 2

   local rad = dir * hpi

   local yoff = -math.floor(math.cos(rad) + 0.5)
   local xoff = math.floor(math.sin(rad) + 0.5)

   return xoff, yoff
end


function click_box(x1,y1,x2,y2)
   local x = mouse_x()
   local y = mouse_y()
   return x >= x1 and x <= x2 and y >= y1 and y <= y2
end


function update_view()
   view_bitmap = dsb_dungeon_view(party.pos[1], party.pos[2], party.pos[3], party.pos[4], 1)
   redraw = true
end


function take(instance)
   party.holding = instance.id
   mouse_cursor = instance.arch.icon
end


function take_id(id)
   party.holding = id
   mouse_cursor = id_table[id].arch.icon
end


function take_instance(y,tile)
   local instances = cell_instances(0, y)
   local dir = party.pos[4]

   local loc = dir + tile
   if loc > 3 then loc = loc - 4 end

   if not party.holding and instances then
	  local instance_id = nil
	  for _,id in pairs(instances) do
		 local instance = id_table[id]
		 if instance.pos[4] == loc then
			instance_id = id
		 end
	  end

	  if instance_id then
		 remove_value(instances,instance_id)
		 take(id_table[instance_id])

		 local instances = cell_instances(0, y)
		 for _,id in pairs(instances) do
			local instance = id_table[id]
			if instance.arch.off_trigger then
			   instance.arch.off_trigger(instance.arch, instance.id, party.holding)
			end
		 end
	  end
   elseif party.holding then
	  local cx,cy = cell(0,y)

	  if not instances then
		 create_cell(party.pos[1], cx, cy)
		 instances = cell_instances(0, y)
	  end

	  local holding = id_table[party.holding]
	  holding.pos[4] = dir + tile
	  if holding.pos[4] > 3 then holding.pos[4] = holding.pos[4] - 4 end
	  add_world_last(party.pos[1],cx,cy, party.holding)

	  for _,id in pairs(instances) do
		 local instance = id_table[id]
		 if instance.arch.on_trigger then
			instance.arch.on_trigger(instance.arch, instance.id, party.holding)
		 end
	  end

	  drop_holding()
   end
end


function drop_holding()
   party.holding = nil
   mouse_cursor = hand_cursor
end


function throw_object()
   sys_mouse_throw(party.holding, 0, g_characters[dsb_get_leader()].id, 0)
   drop_holding()
end


function dsb_set_crmotion()
end


function dsb_get_cropmax(id)
   return 180
end


function attack(id, meth)
   local char = id
   local methods = {
	  { "PUNCH", 0, CLASS_NINJA, method_physattack },
	  { "KICK", 0, CLASS_NINJA, method_physattack }}

   local char_id = dsb_ppos_char(char)
   local weapon = dsb_fetch(CHARACTER, char_id, INV_R_HAND, 0)
   if weapon then
	  methods = dsb_find_arch(weapon).methods
   end

   local method = methods[meth][4]
   if type(method) == "string" then
	  -- print("METHOD: " .. method)
	  local func = _G[method]
	  func(methods[meth][1], char, char_id, weapon)
   else
	  method(methods[meth][1], char, char_id, weapon)
   end

   party.attacking = nil
end


function choose_attack(char)
   local char_id = dsb_ppos_char(char)
   local iobj = dsb_fetch(CHARACTER, char_id, INV_R_HAND, 0)
   method_names = {}
   if iobj then
	  local arch = dsb_find_arch(iobj)
	  for _,method in ipairs(arch.methods) do
		 table.insert(method_names, method[1])
	  end
   else
	  method_names = {"PUNCH", "KICK"}
   end
   party.attacking = char
end


function enter_inventory()
   sys_inventory_enter(inventory_ppos(), g_characters[inventory_ppos()].id)
   g_state = STATE_INVENTORY
end


function is_ahead(class)
   local ahead = {}
   local instances = cell_instances(0, 1)
   if instances then
	  for _,id in pairs(instances) do
		 local instance = id_table[id]
		 if instance.arch.class == class then
			table.insert(ahead,instance)
		 end
	  end
   end
   if #ahead > 0 then
	  return ahead
   end
end


function remove_char()
   start_moving()
   g_next_char = g_next_char - 1
   g_characters[g_next_char] = nil
end


function click_icon(icon)
   return click_box(icon.x,icon.y+ gui_info.viewport.y,icon.x+32,icon.y+32+gui_info.viewport.y)
end


function levels_string(champion, skill)
   return "{" .. champion.levels[skill][1] .. ", " .. champion.levels[skill][2] .. ", " .. champion.levels[skill][3] .. ", " .. champion.levels[skill][4] .. ", " .. champion.levels[skill][5] .. "}"
end


function check_buttons()
   if click_icon(inventory_info.eye) then
	  view_stats = true
   elseif click_icon(inventory_info.mouth) then
	  if party.holding then
		 sys_click_mouth(ppos_info(inventory_ppos()).id, party.holding)
	  end
   elseif click_icon(inventory_info.save) then
	  g_state = STATE_SAVE
   elseif click_icon(inventory_info.sleep) then
	  party.sleep = true
   elseif click_icon(inventory_info.exitbox) then
	  g_state = STATE_MOVE
   end
end


function love.mousereleased( x, y, button, istouch )
   view_stats = false
end


function add_to_character(char_id,msg,instance)
   -- if msg == INV_R_HAND and instance.arch.to_r_hand then
   -- 	  instance.arch:to_r_hand(instance.id, char_id)
   -- elseif msg == INV_L_HAND and instance.arch.to_l_hand then
   -- 	  instance.arch:to_l_hand(instance.id, char_id)
   -- end

   make_cell(CHARACTER,char_id,msg)
   add_instance(world[CHARACTER].map[char_id][msg],instance)
   instance.pos = {CHARACTER,char_id,msg,0}
end


function after_add_to_character(msg,instance)
   -- if msg == INV_R_HAND and instance.arch.after_to_r_hand then
   -- 	  instance.arch:after_to_r_hand()
   -- elseif msg == INV_L_HAND and instance.arch.after_to_l_hand then
   -- 	  instance.arch:after_to_l_hand()
   -- end
end


function check_objzones(x,y)
   for _,zone in pairs(objzones) do
	  local bitmap = zone[1]
	  local id = zone[2]
	  local msg = zone[3]
	  local zx = bitmap.x + zone[4]
	  local zy = bitmap.y + zone[5]
	  if x > zx and x < zx + 32 and y > zy and y < zy + 32 then
		 local char = id
		 if id == SYSTEM then
			char = zone[6]
			if not char then		
			   char = portrait_char(x)
			end
		 end
		 
		 local char_id = dsb_ppos_char(char)
		 if party.holding then
			if id == SYSTEM then
			   local placed = sys_inventory(char_id, msg, nil, party.holding, false, false)
			   if placed then
				  local there = dsb_fetch(CHARACTER, char_id, msg)
				  local instance = id_table[party.holding]
				  add_to_character(char_id,msg,instance)

				  if there then
					 take(id_table[there])
				  else
					 drop_holding()
				  end

				  sys_inventory(char_id, msg, nil, instance.id, true,true)
				  --after_add_to_character(msg,instance)
			   end
			else
			   local placed = true --sys_inventory(id, msg, false, party.holding, false, false)
			   if placed then
				  local there = dsb_fetch(CHARACTER, char_id, msg)
				  local instance = id_table[party.holding]
				  -- add_to_character(char_id,msg,instance)

				  dsb_move(instance.id, IN_OBJ, id, msg, 0)
				  if there then
					 take(id_table[there])
				  else
					 drop_holding()
				  end

				  -- after_add_to_character(msg,instance)
			   end
			end
		 else
			if id == SYSTEM then
			   if world[CHARACTER].map[char_id] and world[CHARACTER].map[char_id][msg] then
				  local iid = world[CHARACTER].map[char_id][msg].instances[1]
				  local taken = sys_inventory(char_id, msg, iid, nil, false, false)
				  if taken then
					 local cell = world[CHARACTER].map[char_id][msg]
					 local instance = id_table[cell.instances[1]]

					 -- local arch = dsb_find_arch(instance.id)
					 -- if msg == INV_R_HAND and arch.from_r_hand then
					 -- 	arch:from_r_hand(instance.id, char_id)
					 -- elseif msg == INV_L_HAND and arch.from_l_hand then
					 -- 	arch:from_l_hand(instance.id, char_id)
					 -- end

					 remove_instance(cell, instance)
					 take(instance)

					 sys_inventory(char_id, msg, iid, nil, true, true)
					 -- if msg == INV_R_HAND and arch.after_from_r_hand then
					 -- 	arch:after_from_r_hand(party.holding, char_id)
					 -- elseif msg == INV_L_HAND and arch.after_from_l_hand then
					 -- 	arch:after_from_l_hand(party.holding, char_id)
					 -- end
				  end
			   end
			else			   
			   if world[IN_OBJ].map[id] and world[IN_OBJ].map[id][msg] then
				  local taken = true -- sys_inventory(char_id, msg, world[IN_OBJ].map[id][msg].instances[1], false, false, false)
				  if taken then
					 local cell = world[IN_OBJ].map[id][msg]
					 -- print("CELL: " .. id .. " " .. bitmap.x .. " " .. bitmap.y .. " " .. msg .. " " .. inspect(cell))
					 local instance = id_table[cell.instances[1]]
					 
					 remove_instance(cell, instance)
					 take(instance)
				  end
			   end
			end
		 end
	  end
   end
end


function check_msgzones(x,y)
   for _,zone in ipairs(msgzones) do
	  local bitmap = zone[1]
	  local id = zone[2]
	  local num = zone[3]
	  local zx = bitmap.x + zone[4]
	  local zy = bitmap.y + zone[5]
	  local msg = zone[8]
	  local data = zone[9]
	  local data2 = zone[10]

	  if x > zx and x < zx + zone[6] and y > zy and y < zy + zone[7] then
		 if msg == SYS_LEADER_SET then
			dsb_set_leader(data)
		 elseif msg == SYS_METHOD_OBJ then
			choose_attack(data)
		 elseif msg == SYS_METHOD_CLEAR then
			attack_mode = 0
		 elseif msg == SYS_METHOD_SEL then
			attack(data, data2)
		 elseif msg == SYS_MAGIC_PPOS then
			party.magician = data
		 elseif msg == SYS_MAGIC_RUNE then
			sys_rune_cast(party.magician, ppos_info(party.magician).id, data2, unpack(ppos_info(party.magician).spell))
		 elseif msg == SYS_MAGIC_BACK then
			local spell = ppos_info(party.magician).spell
			--			print("SPELL: " .. inspect(spell))
			local idx = 1
			for i = 1,8 do
			   if spell[i] == 0 then
				  idx = i
				  break
			   end
			end
			if idx > 1 then
			   spell[idx-1] = 0
			end
			dsb_set_pendingspell(party.magician, unpack(spell))
		 elseif msg == SYS_MAGIC_CAST then
			sys_spell_cast(party.magician, ppos_info(party.magician).id, unpack(ppos_info(party.magician).spell))
			dsb_set_pendingspell(party.magician, unpack({0,0,0,0,0,0,0,0}))
		 elseif msg == SYS_MOVE_ARROW then
			party.move = data
		 elseif msg == SYS_OBJ_PUT_AWAY then
			if party.holding then
			   if (sys_put_away(data, party.holding)) then
				  drop_holding()
			   end
			else
			   party.inventory_ppos = data
			   g_state = STATE_INVENTORY
			end
		 else
			print("UNKNOWN SYSTEM MESSAGE: " .. msg)
		 end
	  end
   end
end


function click_character(ppos)
   if g_character == nil then
	  if party.positions[ppos] then
		 g_character = ppos
	  end
   else
	  local character = party.positions[ppos]
	  party.positions[ppos] = party.positions[g_character]
	  party.positions[g_character] = character
	  g_character = nil
   end
end


function last_thing(lev,x,y,loc)
   local instances = cell_instances(0, 1)

   local instance_id = nil
   for _,id in pairs(instances) do
	  local instance = id_table[id]
	  if instance.pos[4] == loc and instance.arch.type == "THING" then
		 instance_id = id
	  end
   end

   return instance_id
end

function love.mousepressed(x, y, button, istouch)
   local sx, sy = get_scale()
   x = x / sx
   y = y / sy
   if love.mouse.isDown(1) then
	  -- print("LOVE.MOUSEPRESSED: " .. x .. " " .. y .. " " .. button)

	  if g_state == STATE_END then
		 if click_box(205,385,435,414) then		
			load_game(savefile)
		 end
	  elseif g_state == STATE_SAVE then
		 if click_box(26,212,211,256) then
			load_game(savefile)
		 elseif click_box(237,212,422,256) then
			g_state = STATE_INVENTORY
		 elseif click_box(26,272,212,318) then
			save_game(savefile)
			g_state = STATE_INVENTORY
		 elseif click_box(237,273,422,314) then
			love.event.quit()
		 end
		 return
	  elseif fullscreen_click then
		 local result = fullscreen_click(mouse_x(), mouse_y(), 1)
		 if result == 999 then
			if save then
			   load_game(gt_savegames[1])
			else
			   load_game(dungeon .. "/dungeon.lua")

			   -- dsb_champion_toparty(0, 9)
			   -- dsb_champion_toparty(1, 10)
			   -- dsb_champion_toparty(2, 11)
			   -- dsb_champion_toparty(3, 12)
			   
			   remove_champions()
			end
			gt_door_opening = true
			dsb_fullscreen(front_door_draw, nil, nil, false)
		 elseif result == 1 then
			load_game(savefile)
			fullscreen_func = nil
			fullscreen_click = nil
			state = STATE_MOVE
		 elseif result == 2 then
			love.event.quit()
		 end
	  elseif fullscreen_func == nil then
		 check_objzones(x,y)
		 check_msgzones(x,y)

		 if dsb_get_sleepstate() then
			party.sleep = false
		 elseif click_box(555,15,597,50) then
			click_character(0)
		 elseif click_box(599,16,636,49) then
			click_character(1)
		 elseif click_box(555,45,596,78) then
			click_character(2)
		 elseif click_box(595,50,636,82) then
			click_character(3)
		 elseif g_state == STATE_MOVE then
			if click_box(107,310,161,343) then
			   take_instance(0,0)
			elseif click_box(287,310,345,343) then
			   take_instance(0,1)
			elseif click_box(133,279,184,306) then
			   take_instance(1,0)
			elseif click_box(268,279,321,306) then
			   take_instance(1,1)
			elseif click_box(336,174,351,191) and is_ahead("DOORBUTTON") then
			   local button = is_ahead("DOORBUTTON")[1]
			   button.arch.on_click(button.arch, button.id, party.holding)
			elseif click_box(197,166,252,195) and is_ahead("KEYHOLE") and party.holding then
			   local keyhole = is_ahead("KEYHOLE")[1]
			   local rv = keyhole.arch.on_click(keyhole.arch, keyhole.id, party.holding)
			   if rv then
				  drop_holding()
			   end
			elseif click_box(197,166,252,195) and is_ahead("BUTTON") then
			   local buttons = is_ahead("BUTTON")

			   for _,button in pairs(buttons) do
				  local rv = button.arch.on_click(button.arch, button.id, party.holding)
			   end
			elseif click_box(0,86,448,257) then
			   if wall(0,1) then				  
				  local instances = cell_instances(0, 1)
				  local dir = party.pos[4]
				  local flip = dir + 2
				  if flip > 3 then flip = flip - 4 end

				  if instances then
					 for _,id in pairs(instances) do
						local instance = id_table[id]
						if instance.pos[4] == flip then
						   local arch = dsb_find_arch(instance.id)
						   if arch.class == "ALCOVE" and arch.drop_zone then
							  arch.on_click(arch, instance.id, party.holding)
							  if party.holding and arch.revive_class == "BONES" then
							  elseif party.holding then							  
								 add_world_last(instance.pos[1],instance.pos[2],instance.pos[3],party.holding, instance.pos[4])
								 drop_holding()
							  else
								 local thing = last_thing(instance.pos[1],instance.pos[2],instance.pos[3],instance.pos[4])
								 print("THING: " .. inspect(thing))
								 remove_value(instances, thing)
								 take(id_table[thing])
							  end
						   elseif ((instance.arch_type == "mirror") and (g_next_char < 4) and (arch.no_party_clickable or g_next_char > 0)) or (instance.arch_type ~= "mirror" and g_next_char > 0 and arch.on_click) then
							  arch.on_click(arch,instance.id, party.holding)

						   end
						end
					 end
				  end
			   elseif party.holding then
				  if click_box(0,127,224,256) then
					 throw_object(-1)
					 print("throw left")
				  elseif click_box(224,127,448,256) then
					 throw_object(1)
					 print("throw right")
				  end
			   end
			end
		 elseif g_state == STATE_OFFER then
			if click_box(200,191,313,306) then
			   sys_character_resurrected(g_next_char-1, g_characters[g_next_char-1].id)
			   champion_take()
			   start_moving()
			elseif click_box(318,191, 428, 306) then
			   sys_character_reincarnated(g_next_char-1, g_characters[g_next_char-1].id)
			   local champion = get_char(g_characters[g_next_char-1].id)
			   champion.levels = {}
			   champion.levels[CLASS_FIGHTER] = {0,0,0,0,0}
			   champion.levels[CLASS_NINJA] = {0,0,0,0,0}
			   champion.levels[CLASS_PRIEST] = {0,0,0,0,0}
			   champion.levels[CLASS_WIZARD] = {0,0,0,0,0}
			   champion_take()
			   start_moving()
			elseif click_box(420,90,437,109) or click_box(199,310,429,334) then
			   remove_char()
			end

			check_buttons()
		 elseif g_state == STATE_INVENTORY then
			check_buttons()
		 end
	  end
   elseif love.mouse.isDown(2) then
	  if g_state == STATE_OFFER then
		 remove_char()
	  else
		 if y < 86 then
			local char = portrait_char(x)
			if char == party.inventory_ppos then
			   start_moving()
			else
			   party.inventory_ppos = char
			   enter_inventory()
			end
		 elseif g_state == STATE_MOVE then
			if g_next_char > 0 then
			   enter_inventory()
			end
		 else
			start_moving()
		 end
	  end
   elseif love.mouse.isDown(3) then
	  if state == STATE_MOVE then
		 if party.holding then
			sys_put_away_click(party.holding)
		 end
	  end
   end
   if state == STATE_MOVE then
	  update_view()
   end
end


function can_move(x,y)
   if x < 0 or x >= world[party.pos[1]].x_size or y < 0 or y >= world[party.pos[1]].y_size or
   world[party.pos[1]].map[x][y].wall == 1 then
	  return false
   end

   local whatshere = dsb_fetch(party.pos[1], x, y, -1)
   if (whatshere) then
	  local i
	  for i in pairs(whatshere) do
		 local inst = whatshere[i]
		 local arch = dsb_find_arch(inst)
		 local inactive = dsb_get_gfxflag(inst, GF_INACTIVE)
		 if arch.type == "MONSTER" or (arch.type== "DOOR" and not inactive) then
			return false
		 end
	  end
   end
   return true
end


function get_level(who, skill, subskill)
   local xp = dsb_get_xp(who,skill,subskill)

   if xp == 0 then
	  return 0
   end

   local bonus = 1
   if dsb_get_xp(who,skill,0) > 0 then
	  bonus = 1
   end

   local level = 1
   local res = 0
   while level <= 15 do
	  if xp_levelamounts[level] <= xp then
		 res = res + 1
	  end
	  level = level + 1
   end

   return res + bonus
end


function print_skills(who)
   local whoname = dsb_get_charname(who)
   local cppos = 1
   if dsb_char_ppos(who) then
	  cppos = cppos + dsb_char_ppos(who)
   end

   for skill=0,3 do
	  dsb_write(player_colors[cppos], xp_skillnames[skill+1][1] .. ":" .. get_level(who, skill, 1) .. " " ..
				   xp_skillnames[skill+1][2] .. ":" .. get_level(who, skill, 2) .. " " ..
				   xp_skillnames[skill+1][3] .. ":" .. get_level(who, skill, 3) .. " " ..
				   xp_skillnames[skill+1][4] .. ":" .. get_level(who, skill, 4))
   end
end


function update_triggers()
   for _,id in pairs(party.triggers) do
	  local instance = id_table[id]
	  local arch = dsb_find_arch(id)
	  if (not dsb_get_gfxflag(id,GF_INACTIVE)) and arch.off_trigger then
		 arch.off_trigger(arch, id, nil, true)
	  end
   end
   party.triggers = {}
   local instances = cell_instances(0,0)
   if instances then
	  for _,id in pairs(instances) do
		 local arch = dsb_find_arch(id)
		 if (not dsb_get_gfxflag(id,GF_INACTIVE)) and arch.on_trigger then
			table.insert(party.triggers, id)
			arch:on_trigger(id, nil, true)
		 end
	  end
   end
end


function party_move()
   if not party.move or party.move == 0 then return end

   local turned = false
   mx, my = move(party.pos[4])
   local moved = nil
   if party.move == 7 then
	  party.pos[1] = math.max(party.pos[1] - 1,0)
	  moved = true
   elseif party.move == 8 then
	  party.pos[1] = math.min(party.pos[1] + 1,10)
	  moved = true
   elseif party.move == 2 then
	  local nx = party.pos[2] + mx
	  local ny = party.pos[3] + my
	  if can_move(nx,ny) then
		 party.pos[2] = nx
		 party.pos[3] = ny
		 moved = true
	  else
		 moved = false
	  end
   elseif party.move == 5 then
	  local nx = party.pos[2] - mx
	  local ny = party.pos[3] - my
	  if can_move(nx,ny) then
		 party.pos[2] = nx
		 party.pos[3] = ny
		 moved = true
	  else
		 moved = false
	  end
   elseif party.move == 4 then
	  local dir = party.pos[4]
	  dir = dir - 1
	  if dir < 0 then
		 dir = dir + 4
	  end
	  mx, my = move(dir)

	  local nx = party.pos[2] + mx
	  local ny = party.pos[3] + my
	  if can_move(nx,ny) then
		 party.pos[2] = nx
		 party.pos[3] = ny
		 moved = true
	  else
		 moved = false
	  end
   elseif party.move == 6 then
	  local dir = party.pos[4]
	  dir = dir + 1
	  if dir > 3 then
		 dir = dir - 4
	  end
	  mx, my = move(dir)

	  local nx = party.pos[2] + mx
	  local ny = party.pos[3] + my
	  if can_move(nx,ny) then
		 party.pos[2] = nx
		 party.pos[3] = ny
		 moved = true
	  else
		 moved = false
	  end

   elseif party.move == 1 then
	  party.pos[4] = party.pos[4] - 1
	  turned = true
   elseif party.move == 3 then
	  party.pos[4] = party.pos[4] + 1
	  turned = true
   end

   if party.pos[4] > 3 then party.pos[4] = 0 end
   if party.pos[4] < 0 then party.pos[4] = 3 end

   if moved == false then
	  for ppos = 0,3 do
		 if get_ppos(ppos) then
			do_damage(ppos,ppos_info(ppos).id, HEALTH, dsb_rand(1,4), false)
		 end
	  end
	  hurt_sound()
   end

   if moved and g_next_char > 0 then
	  sys_party_move()
	  update_triggers()
   end

   local instances = cell_instances(0,0)
   if instances then
	  for _,id in pairs(instances) do
		 local instance = id_table[id]
		 if instance.arch.on_turn then
			instance.arch:on_turn(instance.id)
		 end
	  end
   end

   love.audio.setPosition( party.pos[2],party.pos[3],party.pos[1] )

   local fx,fy = dsb_forward(party.pos[4])
   love.audio.setOrientation( fx, fy, 0, 0,0,-1)
   
end


function dsb_get_lastmethod(char)
   return "PUNCH", 0
end


function dsb_tileptr_rotate(lev,x,y,pos)
   instances = dsb_fetch(lev,x,y,pos)
   local instance = table.remove(instances)
   table.insert(instances, 1, instance)
end


function load_game(save)
   reset_game()

   local f = assert(loadfile(save))
   f()
   -- dofile(save)

   g_state = STATE_MOVE
   dsb_write(system_color, "LOADED " .. string.upper(save))
end


function start_dungeon(name,save)
   
   local path = name .. "/startup2"
   if not file_exists(path) then
	  path = name .. "/startup.lua"
   end
   lua_manifest = nil
   dofile(path)
   for k,v in pairs(lua_manifest) do
	  dofile(name .. "/" .. v)
   end

   if file_exists(name .. "/objects.lua") then
	  dofile(name .. "/objects.lua")
   end

end


function dofile (filename)
   -- local f = assert(loadfile(filename))
   print("DOFILE:" .. filename)
   local f = assert(love.filesystem.load(filename))
   return f()
end


function init_game()
   -- love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
   reset_globals()

   dsb_export("g_state") -- added so we can save game at any time for testing
   dsb_export("g_frame")
   dsb_export("g_frame_counter")
   dsb_export("g_next_condition")
   -- dsb_export("g_next_char") -- we call dsb_champion_toparty to increase this
   dsb_export("g_lights")
   dsb_export("g_console")
   dsb_export("g_new_messages")
   dsb_export("g_message_id")
   dsb_export("g_conditions")
   dsb_export("g_message_chains")
   dsb_export("g_next_id")
   dsb_export("g_lock")

   inspect = dofile("inspect.lua")
   dofile("base/global.lua")
   for k,v in pairs(lua_manifest) do
	  dofile("base/" .. v)
   end
   dofile("base/objects.lua")
   dofile("base/startup.lua")

   intro_dsb = dsb_get_bitmap("dsb")
   intro_dsbs = dsb_get_bitmap("dsbs")
   end_bitmap = dsb_get_bitmap("the_end")
   restart_button = dsb_get_bitmap("restart_button")
   
   control_background = dsb_get_bitmap("control_background")
   control_long = dsb_get_bitmap("control_long")
   control_short = dsb_get_bitmap("control_short")

   sys_font = dsb_get_font("fontgrid-white")
   fullscreen_bitmap = dsb_new_bitmap(640, 480)
   subrender_bitmap = dsb_new_bitmap(640, 480)
   magic_bitmap = dsb_new_bitmap(gui_info.magic.w, gui_info.magic.h)
   attack_bitmap = dsb_new_bitmap(gui_info.methods.w, gui_info.methods.h)
   view_bitmap = dsb_new_bitmap(448, 272)
   view_bitmap.x = gui_info.viewport.x
   view_bitmap.y = gui_info.viewport.y
   arrows_bitmap = dsb_new_bitmap(gui_info.movement.w, gui_info.movement.h)
   arrow_cursor = dsb_get_bitmap("mouse_arrow")
   hand_cursor = dsb_get_bitmap("mouse_hand")
   res_rei = dsb_get_bitmap("res_rei")
   guy_icons = {dsb_get_bitmap("guy_green"), dsb_get_bitmap("guy_yellow"), dsb_get_bitmap("guy_red"), dsb_get_bitmap("guy_blue")}

   g_portraits = {dsb_new_bitmap(133,56),dsb_new_bitmap(133,56),dsb_new_bitmap(133,56),dsb_new_bitmap(133,56)}

   dungeon_bitmap_id = bitmap_id
end


function start_game()
   reset_game()

   if arg[2] then
	  dungeon = arg[2]
   end
   
   if arg[3] then
	  savefile = arg[3]
   else
	  savefile = dungeon .. "/DSBSAVE1.LUA"
   end
   
   start_dungeon(dungeon)

   local saves = 0
   if file_exists(savefile) then
	  saves = 1
   end
   local start = sys_game_start(saves)
end
