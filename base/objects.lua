-- Global base objects file     
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how objects in DSB work.
-- This is where the main properties of objects are stored,
-- and so this is the file you want to read over if you're
-- curious how objects work.

-- If you want to add new objects, it's a much better idea
-- to create an "objects.lua" in your dungeon's directory
-- and add the new objects there. You can use the clone_arch
-- function to make it a lot easier to create new objects
-- based on existing ones.
				
-- Note that it's pointless to change the contents of obj
-- during runtime: this file gets parsed anew every time
-- and any changes you made aren't saved in the dungeon.

obj.light_controller = {
	type="UNDEFINED",
	msg_handler=light_msg_handler
}

obj.shield_controller = {
	type="UNDEFINED",
	bound_to_character=true,
	msg_handler=shield_msg_handler
}

obj.x_relay = {
	type="UNDEFINED",
	class="EMULATION",
	msg_handler=x_relay_msg_handler,
	esb_take_targets = true
}

obj.x_counter = {
	type="UNDEFINED",
	class="EMULATION",
	msg_handler=x_counter_msg_handler,
	esb_take_targets = true
}

obj.counter = {
	type="FLOORFLAT",
	class="MECHANICS",
	default_silent = true,
	msg_handler=counter_msg_handler,
	esb_take_targets = true,
	esb_counter = true
}

obj.msg_sender = {
	type="FLOORFLAT",
	class="MECHANICS",
	default_silent = true,
	msg_handler=msg_sender_msg_handler,
	esb_take_targets = true,
	esb_repeating = true
}

obj.trigger_controller = {
	type="FLOORFLAT",
	class="MECHANICS",
	msg_handler=probability_msg_handler,
	esb_always_silent = true,
	esb_take_targets = true,
	esb_trigger_controller = true,
	esb_probability = true
}

-- Deprecated object
obj.probability = clone_arch(obj.trigger_controller, {
	type="UNDEFINED"
} )

obj.sequencer = {
	type="FLOORFLAT",
	class="MECHANICS",
	default_silent = true,
	msg_handler=sequencer_msg_handler,
	esb_take_targets = true
}             

obj.qswapper = {
	type="FLOORFLAT",
	class="MECHANICS",
	msg_handler=qswapper_msg_handler,
	esb_swapper = true,
	esb_special_trigger = true,
	esb_targ_draw_color = { 96, 64, 180 }
}

obj.item_action = {
	type="FLOORFLAT",
	class="MECHANICS",
	msg_handler=item_action_msg_handler,
	esb_item_action = true,
	esb_special_trigger = true,
	esb_targ_draw_color = { 200, 0, 120 }
}

obj.monster_generator = {
	type="FLOORFLAT",
	class="MECHANICS",
	msg_handler=generator_msg_handler,
	esb_monster_generator = true
}

obj.monster_blocker = {
	type="FLOORFLAT",
	class="MECHANICS",
	no_monsters=blocker_no_monsters
}

obj.function_caller = {
	type="FLOORFLAT",
	class="MECHANICS",
	msg_handler=function_caller_msg_handler,
	esb_function_caller = true,
	esb_special_trigger = true,
	esb_targ_draw_color = { 32, 160, 128 }
}

obj.floortext = {
	type="FLOORFLAT",
	class="MECHANICS",
	on_trigger=show_floortext
}

obj.floordamager = {
	type="FLOORFLAT",
	class="MECHANICS",
	on_trigger=damage_something
}

obj.ambient_sound = {
	type="FLOORFLAT",
	class="MECHANICS",
	msg_handler=ambient_sound_msg_handler
}

obj.floorcrack = {
	type="FLOORFLAT",
	class="DECO",
	front=gfx.floorcrack_front[1],
	front_med=gfx.floorcrack_front[2],
	front_far=gfx.floorcrack_front[3],
	side=gfx.floorcrack_side[1],
	side_med=gfx.floorcrack_side[2],
	side_far=gfx.floorcrack_side[3],
}

obj.puddle = {
	type="FLOORFLAT",
	class="DECO",
	front=gfx.puddle_front[1],
	front_med=gfx.puddle_front[2],
	front_far=gfx.puddle_front[3],
	side=gfx.puddle_side[1],
	side_med=gfx.puddle_side[2],
	side_far=gfx.puddle_side[3],
}

obj.floorslime = {
	type="FLOORFLAT",
	class="DECO",
	front=gfx.floorslime_front[1],
	front_med=gfx.floorslime_front[2],
	front_far=gfx.floorslime_front[3],
	side=gfx.floorslime_side[1],
	side_med=gfx.floorslime_side[2],
	side_far=gfx.floorslime_side[3]
}

obj.rounddrain = {
	type="FLOORFLAT",
	class="DRAIN",
	front=gfx.rounddrain_front[1],
	front_med=gfx.rounddrain_front[2],
	front_far=gfx.rounddrain_front[3],
	side=gfx.rounddrain_side[1],
	side_med=gfx.rounddrain_side[2],
	side_far=gfx.rounddrain_side[3],
}

obj.squaredrain = {
	type="FLOORFLAT",
	class="DRAIN",
	front=gfx.squaredrain_front[1],
	front_med=gfx.squaredrain_front[2],
	front_far=gfx.squaredrain_front[3],
	side=gfx.squaredrain_side[1],
	side_med=gfx.squaredrain_side[2],
	side_far=gfx.squaredrain_side[3],
}

obj.firepit = {
	type="FLOORFLAT",
	class="FIREPIT",
	front=gfx.firepit_front[1],
	front_med=gfx.firepit_front[2],
	front_far=gfx.firepit_front[3],
	side=gfx.firepit_side[1],
	side_med=gfx.firepit_side[2],
	side_far=gfx.firepit_side[3],
}

obj.trigger = {
	type="FLOORFLAT",
	class="TRIGGER",
	on_trigger=floor_trigger,
	off_trigger=floor_trigger_off,
	on_turn=turn_trigger,
	off_turn=turn_trigger_off,
	on_location_pickup=trigger_pickup,
	on_location_drop=trigger_drop,
	default_silent = true
}

obj.pad = clone_arch(obj.trigger, {
	front=gfx.pad_front[1],
	front_med=gfx.pad_front[2],
	front_far=gfx.pad_front[3],
	side=gfx.pad_side[1],
	side_med=gfx.pad_side[2],
	side_far=gfx.pad_side[3],
	default_silent = false
} )

obj.pad_small = clone_arch(obj.trigger, {
	front=gfx.pad_small_front[1],
	front_med=gfx.pad_small_front[2],
	front_far=gfx.pad_small_front[3],
	side=gfx.pad_small_side[1],
	side_med=gfx.pad_small_side[2],
	side_far=gfx.pad_small_side[3],
	default_silent = false
} )

obj.pad_tiny = clone_arch(obj.trigger, {
	only_defined_gfx=true,
	front=gfx.pad_tiny_front,
	default_silent = false
} )

obj.pit = {
	type="FLOORFLAT",
	class="PIT",
	same_square=gfx.pit_front[0],
	front=gfx.pit_front[1],
	front_med=gfx.pit_front[2],
	front_far=gfx.pit_front[3],
	near_side=gfx.pit_side[0],
	side=gfx.pit_side[1],
	side_med=gfx.pit_side[2],
	side_far=gfx.pit_side[3],
	on_trigger=base_pitfall,
	no_monsters=pit_no_monsters,
	on_spawn=create_linked_object,
	link_object = "ceiling_pit",
	link_offset = {1, 0, 0}
}

obj.ipit = {
	type="FLOORFLAT",
	class="PIT",
	only_defined_gfx=true,
	same_square=gfx.ipit_front[0],
	front=gfx.ipit_front[1],
	front_med=gfx.ipit_front[2],
	near_side=gfx.ipit_side[0],
	side=gfx.ipit_side[1],
	side_med=gfx.ipit_side[2],
	on_trigger=base_pitfall,
	no_monsters=pit_no_monsters,
	on_spawn=create_linked_object,
	link_object = "ceiling_pit",
	link_offset = {1, 0, 0}
}

obj.fakepit = {
	type="FLOORFLAT",
	class="PIT_FAKE",
	same_square=gfx.pit_front[0],
	front=gfx.pit_front[1],
	front_med=gfx.pit_front[2],
	front_far=gfx.pit_front[3],
	near_side=gfx.pit_side[0],
	side=gfx.pit_side[1],
	side_med=gfx.pit_side[2],
	side_far=gfx.pit_side[3],
	no_monsters=fakepit_no_monsters
}

obj.ceiling_pit = {
	type="FLOORFLAT",
	class="PIT_CEIL",
	only_defined_gfx=true,
	same_square=gfx.ceiling_pit_front[0],
	front=gfx.ceiling_pit_front[1],
	front_med=gfx.ceiling_pit_front[2],
	near_side=gfx.ceiling_pit_side[0],
	side=gfx.ceiling_pit_side[1],
	side_med=gfx.ceiling_pit_side[2]
}

obj.teleporter = {
    type="FLOORFLAT",
    class="TELEPORTER",
    on_trigger=base_teleporter,
	msg_handler=teleporter_msg_handler,
    esb_use_coordinates=true,
    esb_can_spin=true
}

obj.fakewall = {
    type="FLOORFLAT",
    renderer_hack="FAKEWALL",
    class="WALL"
}

obj.invisiblewall = {
    type="FLOORFLAT",
    renderer_hack="INVISIBLEWALL",
    class="WALL"
}

obj.movablewall = {
	type="FLOORFLAT",
	msg_handler=movable_wall_msg_handler,
	class="WALL"
}

obj.footprints = {
	type="FLOORFLAT",
	class="MAGIC",
	trail_marker=true,
	magic_footprint=true,
	front=gfx.footprints_front[1],
	front_med=gfx.footprints_front[2],
	front_far=gfx.footprints_front[3],
	side=gfx.footprints_side[1],
	side_med=gfx.footprints_side[2],
	side_far=gfx.footprints_side[3],

}

obj.stairsdown = {
    type="FLOORUPRIGHT",
    renderer_hack="STAIRS",
    class="STAIRS",
    only_defined_gfx=true,
    col=stairs_col,
    same_square=gfx.stairsdown_front[0],
	front=gfx.stairsdown_front[1],
	front_med=gfx.stairsdown_front[2],
	front_far=gfx.stairsdown_front[3],
	near_side=gfx.stairsdown_side[0],
	side=gfx.stairsdown_side[1],
	side_med=gfx.stairsdown_side[2],
	side_far=gfx.stairsdown_side[3],
	xside=gfx.stairsdown_xside[1],
	xside_med=gfx.stairsdown_xside[2],
	stairs_dir=1,
	on_trigger=base_stairs,
	on_turn=stairs_turn,
	on_try_move=stairs_backup,
	no_monsters=true,
	no_party_triggerable=true,
	esb_use_coordinates=true
}

obj.stairsup = {
    type="FLOORUPRIGHT",
    renderer_hack="STAIRS",
    class="STAIRS",
    only_defined_gfx=true,
    col=stairs_col,
    same_square=gfx.stairsup_front[0],
	front=gfx.stairsup_front[1],
	front_med=gfx.stairsup_front[2],
	front_far=gfx.stairsup_front[3],
	near_side=gfx.stairsdown_side[0],
	side=gfx.stairsup_side[1],
	side_med=gfx.stairsup_side[2],
	side_far=gfx.stairsup_side[3],
	xside=gfx.stairsup_xside[1],
	xside_med=gfx.stairsdown_xside[2],
	stairs_dir=-1,
	on_trigger=base_stairs,
	on_turn=stairs_turn,
	on_try_move=stairs_backup,
	no_monsters=true,
	no_party_triggerable=true,
	esb_use_coordinates=true
}

obj.doorframe = {
	type="FLOORUPRIGHT",
	renderer_hack="DOORFRAME",
	class="DOORFRAME",
	col=doorframe_col,
	same_square=gfx.doorframe_front[0],
	front=gfx.doorframe_front[1],
	front_med=gfx.doorframe_front[2],
	front_far=gfx.doorframe_front[3],
	side=gfx.doorframe_side[1],
	side_med=gfx.doorframe_side[2],
	side_far=gfx.doorframe_side[3]
}

obj.doorbutton = {
    type="FLOORUPRIGHT",
    renderer_hack="DOORBUTTON",
    class="DOORBUTTON",
    door_actuator=true,
    front=gfx.doorbutton,
    side=gfx.doorbutton_side,
    clickable=true,
    on_click=doorbutton_push,
    default_msg=M_TOGGLE
}

obj.door_wood = {
	type="DOOR",
	class="WOOD",
	front=gfx.door_wood,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler,
	bash_power = 20,
	fire_power = 40
}

obj.door_wood_strong = {
	type="DOOR",
	class="WOOD",
	front=gfx.door_wood,
	deco=gfx.door_deco_wood,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler,
	bash_power = 90,
	fire_power = 40
}

obj.door_wood_metalbars = {
	type="DOOR",
	class="WOOD",
	front=gfx.door_wood,
	deco=gfx.door_deco_metalbars,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_wood_metallock = {
	type="DOOR",
	class="WOOD",
	renderer_hack="LEFTRIGHT",
	front=gfx.door_wood,
	deco=gfx.door_deco_metallock,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_wood_redlock = {
	type="DOOR",
	class="WOOD",
	renderer_hack="LEFTRIGHT",
	front=gfx.door_wood,
	deco=gfx.door_deco_redlock,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_wood_ornate = {
	type="DOOR",
	class="WOOD",
	renderer_hack="LEFTRIGHT",
	front=gfx.door_wood,
	deco=gfx.door_deco_ornate,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_wood_cwindow = {
	type="DOOR",
	class="WOOD",
	front=gfx.door_wood,
	deco=gfx.door_deco_cwindow,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_wood_swindow = {
	type="DOOR",
	class="WOOD",
	front=gfx.door_wood,
	deco=gfx.door_deco_swindow,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}
	
obj.door_portcullis = {
	type="DOOR",
	class="PORTCULLIS",
	front=gfx.door_portcullis,
	bash_mask=gfx.door_bashed,
	bars=true,
	col=door_collide,
	msg_handler=door_msg_handler,
	fire_power = 60
}

obj.door_portcullis_cwindow = {
	type="DOOR",              
	class="PORTCULLIS",	
	front=gfx.door_portcullis,
	deco=gfx.door_deco_cwindow,
	bash_mask=gfx.door_bashed,
	bars=true,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_portcullis_swindow = {
	type="DOOR",
	class="PORTCULLIS",
	front=gfx.door_portcullis,
	deco=gfx.door_deco_swindow,
	bash_mask=gfx.door_bashed,
	bars=true,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_portcullis_metallock = {
	type="DOOR",
	class="PORTCULLIS",
	renderer_hack="LEFTRIGHT",
	front=gfx.door_portcullis,
	deco=gfx.door_deco_metallock,
	bash_mask=gfx.door_bashed,
	bars=true,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_portcullis_redlock = {
	type="DOOR",
	class="PORTCULLIS",
	renderer_hack="LEFTRIGHT",
	front=gfx.door_portcullis,
	deco=gfx.door_deco_redlock,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler,
	bars=true
}

obj.door_portcullis_bottomlock = {
	type="DOOR",
	class="PORTCULLIS",
	front=gfx.door_portcullis,
	deco=gfx.door_deco_metallock2,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler,
	bars=true
}

obj.door_portcullis_ornate = {
	type="DOOR",
	class="PORTCULLIS",
	renderer_hack="LEFTRIGHT",
	front=gfx.door_portcullis,
	deco=gfx.door_deco_ornate,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler,
	bars=true
}

obj.door_metal = {
	type="DOOR",
	class="METAL",
	front=gfx.door_metal,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_metal_sideways = {
	type="DOOR",
	class="METAL",
	renderer_hack="NORTHWEST",
	front=gfx.door_metal,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_metal_metallock = {
	type="DOOR",
	class="METAL",
	front=gfx.door_metal,
	deco=gfx.door_deco_metallock,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_metal_redlock = {
	type="DOOR",
	class="METAL",
	renderer_hack="LEFTRIGHT",
	front=gfx.door_metal,
	deco=gfx.door_deco_redlock,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_metal_damaged = {
	type="DOOR",
	class="METAL",
	front=gfx.door_metal,
	deco=gfx.door_deco_damage,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_metal_ornate = {
	type="DOOR",
	class="METAL",
	front=gfx.door_metal,
	deco=gfx.door_deco_ornate,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_black = {
	type="DOOR",
	class="BLACK",
	renderer_hack="LEFTRIGHT",
	front=gfx.door_black,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler
}

obj.door_ra = {
	type="DOOR",
	class="RA",
	renderer_hack="MAGICDOOR",
	front=gfx.door_ra,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler,
	silent = true,
	thud_sound = snd.buzz
}

obj.door_ra_magic = {
	type="DOOR",
	class="RA",
	renderer_hack="MAGICDOOR",
	front=gfx.door_ra,
	deco=gfx.door_deco_magic,
	bash_mask=gfx.door_bashed,
	col=door_collide,
	msg_handler=door_msg_handler,
	silent = true,
	thud_sound = snd.buzz
}

obj.bluehaze = {
	type="HAZE",
	renderer_hack="HAZE",
	class="HAZE",
	dungeon=gfx.bluehaze
}

obj.fluxcage = {
	type="HAZE",
	renderer_hack="HAZE",
	class="FLUXCAGE",
	dungeon=gfx.fluxcagehaze,
	no_monsters=forbid_monsterclass,
	forbidden="CHAOS"
}

obj.monster_death = {
    type="CLOUD",
    class="HARMLESS",
    y_tweak = 16,
    dungeon=gfx.cloud_monster_death,
    inside_weak=gfx.incloud_monster_weak,
    inside_med=gfx.incloud_monster_med,
	inside_strong=gfx.incloud_monster_strong,
	msg_handler=cloud_msg_handler,
	on_spawn=cloud_created
}

obj.poison_cloud = {
    type="CLOUD",
    class="POISON",
    dangerous = "poison",
    dungeon=gfx.cloud_poison,
    inside_weak=gfx.incloud_poison_weak,
    inside_med=gfx.incloud_poison_med,
	inside_strong=gfx.incloud_poison_strong,
	msg_handler=poison_cloud_msg_handler,
	on_spawn=poison_cloud_created
}

obj.explosion = {
    type="CLOUD",
    class="FIRE",
    dungeon=gfx.cloud_explosion,
    inside_weak=gfx.incloud_explosion_weak,
    inside_med=gfx.incloud_explosion_med,
	inside_strong=gfx.incloud_explosion_strong,
	msg_handler=cloud_msg_handler,
	on_spawn=explosion_created,
	no_shade=true
}

obj.zap = {
    type="CLOUD",
    class="HARMLESS",
    dungeon=gfx.cloud_zap,
    inside_weak=gfx.incloud_zap_weak,
    inside_med=gfx.incloud_zap_med,
	inside_strong=gfx.incloud_zap_strong,
	msg_handler=cloud_msg_handler,
	on_spawn=explosion_created,
	no_shade=true
}

obj.wallwriting = {
    type="WALLITEM",
    renderer_hack="WRITING",
    top_offset = 8,
    mid_offset = 8,
    class="WRITING",
    front=gfx.wallwriting_front,
    side=gfx.wallwriting_side,
    font=gfx.wall_font,
    bitmap_tweaker=wallwriting_alter,
    wall_patch=true
}

obj.fountain_lion = {
    type="WALLITEM",
    class="FOUNTAIN",
    front=gfx.fountain_lion_front,
	side=gfx.fountain_lion_side,
	on_click=fountain_click,
	fill_class = {
		FLASK = "flask_water",
		WATERSKIN = "waterskin_full"
	}
}

obj.fountain_medusa = {
    type="WALLITEM",
    class="FOUNTAIN",
    front=gfx.fountain_medusa_front,
	side=gfx.fountain_medusa_side,
	on_click=fountain_click,
	fill_class = {
		FLASK = "flask_water_yucky",
		WATERSKIN = "waterskin_full"
	}
}

obj.mirror = {
	type="WALLITEM",
	class="CHAMPION_HOLDER",
	renderer_hack="MIRROR",
	no_party_clickable=true,
	default_silent=true,
	front=gfx.mirror_front,
	side=gfx.mirror_side,
	mirror_inside=gfx.mirror_inside,
	esb_mirror=true
}

obj.gorface = {
	type="WALLITEM",
	class="DECO",
	front=gfx.gorface_front,
	side=gfx.gorface_side,
	on_click=wallitem_click
}

obj.dent = {
	type="WALLITEM",
	class="DECO",
	front=gfx.dent_front,
	side=gfx.dent_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.dent2 = {
	type="WALLITEM",
	class="DECO",
	front=gfx.dent2_front,
	side=gfx.dent2_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.crack = {
	type="WALLITEM",
	class="DECO",
	front=gfx.crack_front,
	side=gfx.crack_side,
	on_click=wallitem_click
}

obj.slimedrain = {
	type="WALLITEM",
	class="DECO",
	front=gfx.slimedrain_front,
	side=gfx.slimedrain_side,
	on_click=wallitem_click
}

obj.hook = {
	type="WALLITEM",
	class="DECO",
	front=gfx.hook_front,
	side=gfx.hook_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.peg = {
	type="WALLITEM",
	class="DECO",
	front=gfx.peg_front,
	side=gfx.peg_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.wallslime = {
	type="WALLITEM",
	class="DECO",
	front=gfx.wallslime_front,
	side=gfx.wallslime_side,
	on_click=wallitem_click
}

obj.wallgrate = {
	type="WALLITEM",
	class="DECO",
	front=gfx.wallgrate_front,
	side=gfx.wallgrate_side,
	on_click=wallitem_click
}
	
obj.manacles = {
	type="WALLITEM",
	class="DECO",
	front=gfx.manacles_front,
	side=gfx.manacles_side,
	on_click=wallitem_click
}

obj.scratches = {
	type="WALLITEM",
	class="DECO",
	front=gfx.scratches_front,
	side=gfx.scratches_side,
	on_click=wallitem_click
}

obj.ring_wood = {
	type="WALLITEM",
	class="DECO",
	front=gfx.ring_wood_front,
	side=gfx.ring_wood_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.ring_plain = {
	type="WALLITEM",
	class="DECO",
	front=gfx.ring_plain_front,
	side=gfx.ring_plain_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_plain = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_plain_front,
	side=gfx.keyhole_plain_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_cross = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_cross_front,
	side=gfx.keyhole_cross_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_double = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_double_front,
	side=gfx.keyhole_double_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_emerald = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_emerald_front,
	side=gfx.keyhole_emerald_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_gold = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_gold_front,
	side=gfx.keyhole_gold_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_master = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_master_front,
	side=gfx.keyhole_master_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_onyx = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_onyx_front,
	side=gfx.keyhole_onyx_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_ra = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_ra_front,
	side=gfx.keyhole_ra_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_ruby = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_ruby_front,
	side=gfx.keyhole_ruby_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_skeleton = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_skeleton_front,
	side=gfx.keyhole_skeleton_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_solid = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_solid_front,
	side=gfx.keyhole_solid_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_square = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_square_front,
	side=gfx.keyhole_square_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_topaz = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_topaz_front,
	side=gfx.keyhole_topaz_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_turquoise = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_turquoise_front,
	side=gfx.keyhole_turquoise_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.keyhole_winged = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.keyhole_winged_front,
	side=gfx.keyhole_winged_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.coinslot = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.coinslot_front,
	side=gfx.coinslot_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.gemhole = {
	type="WALLITEM",
	class="KEYHOLE",
	front=gfx.gemhole_front,
	side=gfx.gemhole_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.eye = {
	type="WALLITEM",
	class="ITEMTRIGGER",
	front=gfx.eye_front,
	side=gfx.eye_side,
	wall_patch=true,
	on_click=wallitem_click
}

obj.smallswitch = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.smallswitch_front,
	side=gfx.smallswitch_side,
	on_click=wallitem_click
}

obj.tinyswitch = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.tinyswitch_front,
	side=gfx.tinyswitch_side,
	other_side=gfx.tinyswitch_otherside,
	on_click=wallitem_click
}

obj.lever_down = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.lever_down_front,
	side=gfx.lever_down_side,
	wall_patch=true,
	on_click=wallitem_click,
	click_to="lever_up"
}

obj.lever_up = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.lever_up_front,
	side=gfx.lever_up_side,
	wall_patch=true,
	on_click=wallitem_click,
	click_to="lever_down"
}

obj.brickswitch = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.brickswitch_front,
	side=gfx.brickswitch_side,
	on_click=wallitem_click,
	click_to="brickswitch_pushed"
}

obj.brickswitch_pushed = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.brickswitch_pushed_front,
	side=gfx.brickswitch_pushed_side,
	on_click=wallitem_click,
	click_to="brickswitch"
}

obj.crackswitch = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.crackswitch_front,
	side=gfx.crackswitch_side,
	on_click=wallitem_click,
	click_to="crackswitch_pushed"
}

obj.crackswitch_pushed = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.crackswitch_pushed_front,
	side=gfx.crackswitch_side,
	on_click=wallitem_click,
	click_to="crackswitch"
}

obj.button_green = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.button_green_front,
	side=gfx.button_green_side,
	wall_patch=true,
	on_click=wallitem_click,
	click_to="button_green_pushed"
}

obj.button_green_pushed = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.button_green_pushed_front,
	side=gfx.button_green_pushed_side,
	wall_patch=true,
	on_click=wallitem_click,
	click_to="button_green"
}

obj.button_blue = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.button_blue_front,
	side=gfx.button_blue_side,
	wall_patch=true,
	on_click=wallitem_click,
	click_to="button_blue_pushed"
}

obj.button_blue_pushed = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.button_blue_pushed_front,
	side=gfx.button_blue_pushed_side,
	wall_patch=true,
	on_click=wallitem_click,
	click_to="button_blue"
}

obj.button_redcross = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.button_redcross_front,
	side=gfx.button_redcross_side,
	wall_patch=true,
	on_click=wallitem_click,
	click_to="button_redcross_pushed"
}

obj.button_redcross_pushed = {
	type="WALLITEM",
	class="BUTTON",
	front=gfx.button_redcross_pushed_front,
	side=gfx.button_redcross_pushed_side,
	wall_patch=true,
	on_click=wallitem_click,
	click_to="button_redcross"
}

obj.alcove = {
	type="WALLITEM",
	class="ALCOVE",
	front=gfx.alcove_front,
	side=gfx.alcove_side,
	on_click=wallitem_click,
	drop_zone=true,
	ignore_empty_clicks=true
}

obj.alcove2 = {
	type="WALLITEM",
	class="ALCOVE",
	front=gfx.alcove2_front,
	side=gfx.alcove2_side,
	on_click=wallitem_click,
	drop_zone=true,
	ignore_empty_clicks=true
}

obj.alcove_vi = {
	type="WALLITEM",
	class="ALCOVE",
	front=gfx.alcove_vi_front,
	side=gfx.alcove_vi_side,
	on_click=use_vi_altar,
	msg_handler = vi_altar_msg_handler,
	revive_class = "BONES",
	drop_zone=true,
	ignore_empty_clicks=true
}

obj.sconce_empty = {
	type="WALLITEM",
	class="SCONCE",
	front=gfx.sconce_empty_front,
	side=gfx.sconce_empty_side,
	on_click=wallitem_take_object,
	take_class="TORCH",
	convert_take_object="sconce_full"
}

obj.sconce_full = {
	type="WALLITEM",
	class="SCONCE",
	front=gfx.sconce_full_front,
	side=gfx.sconce_full_side,
	on_click=wallitem_click,
	convert_release_object="sconce_empty"
}

obj.shooter = {
	type="WALLITEM",
	class="SHOOTER",
	msg_handler=shooter_msg_handler,
	esb_shooter=true
}

obj.holes_dagger = {
	type="WALLITEM",
	class="HOLES",
	front=gfx.holes_dagger_front,
	side=gfx.holes_dagger_side,
	on_click=wallitem_click
}

obj.holes_fireball = {
	type="WALLITEM",
	class="HOLES",
	front=gfx.holes_fireball_front,
	side=gfx.holes_fireball_side,
	on_click=wallitem_click
}	

obj.holes_poison = {
	type="WALLITEM",
	class="HOLES",
	front=gfx.holes_poison_front,
	side=gfx.holes_poison_side,
	on_click=wallitem_click
}

obj.outside = {
	type="WALLITEM",
	class="DECO",
	front=gfx.outside,
	on_click=wallitem_click
}

obj.amalgam = {
	type="WALLITEM",
	class="AMALGAM",
	front=gfx.amalgam,
	on_click=wallitem_click
}

obj.amalgam_gembare = {
	type="WALLITEM",
	class="AMALGAM",
	front=gfx.amalgam_gembare,
	on_click=wallitem_click
}

obj.amalgam_empty = {
	type="WALLITEM",
	class="AMALGAM",
	front=gfx.amalgam_empty,
	on_click=wallitem_click
}			

obj.bones = {
	name="BONES",
	type="THING",
	class="BONES",
	mass=15,
	icon=gfx.icons[198],
	dungeon=gfx.bones,
	impact=2
}

obj.torch = {
    name="TORCH",
    type="THING",
    class="TORCH",
    mass=11,
    icon=gfx.icons[4],
    alt_icon=gfx.icons[7],
    dungeon=gfx.torch,
    methods=swing_method,
    msg_handler = torch_msg_handler,
    to_l_hand = torch_light,
    to_r_hand = torch_light,
    after_to_l_hand = set_torch_levels,
    after_to_r_hand = set_torch_levels,
    from_l_hand = torch_dark,
    from_r_hand = torch_dark,
    after_from_l_hand = set_torch_levels,
    after_from_r_hand = set_torch_levels,
    min_light=85,
    diff_light=15,
    def_charge=500,
	convert_burn = "torch_2",
    fit_sheath=true,
    fit_chest=true,
	impact=2,
	base_tpower = 12
}

obj.torch_2 = clone_arch(obj.torch, {
    alt_icon=gfx.icons[6],
	min_light=60,
	diff_light=25,
    convert_burn = "torch_3",
	base_tpower = 10
} )

obj.torch_3 = clone_arch(obj.torch, {
    alt_icon=gfx.icons[5],
	min_light=20,
	diff_light=40,
    convert_burn = "torch_x",
	base_tpower = 8
} )

obj.torch_x = {
    name="TORCH",
    type="THING",
    class="TORCH",
    shortdesc="BURNT OUT",
    mass=11,
    icon=gfx.icons[4],
    dungeon=gfx.torch,
    methods=swing_method,
    fit_sheath=true,
    fit_chest=true,
	impact=2,
	base_tpower = 8
}

obj.dart = {
	name="POISON DART",
	type="THING",
	class="MISSILE",
	mass=3,
	icon=gfx.icons[55],
	dungeon=gfx.dart,
	flying_away=gfx.dart_flying_away,
	flying_toward=gfx.dart_flying_toward,
	flying_side=gfx.dart_flying_side,
	fit_quiver=true,
	fit_pouch=true,
	missile_type=MISSILE_DART,
	methods = throwable_object_methods,
	base_range=12,
	impact=15,
	bonus_damage=2,
	hit_sound=snd.dink,
	can_stick = true,
	go_thru_bars = true
}

obj.dart_csb = clone_arch(obj.dart, {
	name="POISON DART",
	icon=gfx.icons[240]
} )

obj.throwing_star = {
	name="THROWING STAR",
	type="THING",
	class="MISSILE",
	mass=1,
	icon=gfx.icons[56],
	dungeon=gfx.star,
	flying_away=gfx.star_flying,
	flying_toward=gfx.star_flying,
	flying_side=gfx.star_flying_side,
	fit_quiver=true,
	fit_pouch=true,
	missile_type=MISSILE_STAR,
	methods = throw_method,
	base_range=19,
	impact=19,
	bonus_damage=4,
	hit_sound=snd.dink,
	can_stick = true,
	go_thru_bars = true
}

obj.arrow = {
    name="ARROW",
    type="THING",
    class="MISSILE",
    mass=2,
    icon=gfx.icons[51],
	dungeon=gfx.arrow,
	flying_away=gfx.arrow_flying_away,
	flying_toward=gfx.arrow_flying_toward,
	flying_side=gfx.arrow_flying_side,
	fit_quiver=true,
	fit_pouch=true,
	missile_type=MISSILE_ARROW,
	methods = throwable_object_methods,
	base_range=10,
	impact=10,
	hit_sound=snd.dink,
	can_stick = true,
	go_thru_bars = true
}

obj.slayer = {
    name="SLAYER",
    type="THING",
    class="MISSILE",
    mass=2,
    icon=gfx.icons[52],
	dungeon=gfx.slayer,
	flying_away=gfx.slayer_flying_away,
	flying_toward=gfx.slayer_flying_toward,
	flying_side=gfx.slayer_flying_side,
	fit_quiver=true,
	fit_pouch=true,
	missile_type=MISSILE_ARROW,
	methods = throwable_object_methods,
	base_range=12,
	impact=28,
	hit_sound=snd.dink,
	can_stick = true,
	go_thru_bars = true
}

obj.rock = {
	name="ROCK",
	type="THING",
	class="MISSILE",
	mass=10,
	icon=gfx.icons[54],
	dungeon=gfx.rock,
	fit_quiver=true,
	fit_pouch=true,
	missile_type=MISSILE_ROCK,
	methods = throw_method,
	base_range=6,
	impact=18,
	hit_sound=snd.dink,
	go_thru_bars = true
}

obj.dagger = {
    name="DAGGER",
    type="THING",
    class="MISSILE",
    mass=5,
    icon=gfx.icons[32],
	dungeon=gfx.dagger,
	flying_away=gfx.dagger_flying_away,
	flying_toward=gfx.dagger_flying_toward,
	flying_side=gfx.dagger_flying_side,
	fit_quiver=true,
	fit_pouch=true,
	missile_type=MISSILE_DAGGER,
	methods = {
		{ "THROW", 0, CLASS_NINJA, method_throw_obj },
		{ "STAB", 0, CLASS_NINJA, method_physattack },
		{ "SLASH", 1, CLASS_NINJA, method_physattack }
	},			
	base_range=12,
	impact=19,
	hit_sound=snd.dink,
	can_stick = true,
	go_thru_bars = true
}	
	
obj.poison_desven = {
    name="POISON",
    type="THING",
    class="SPELL",
    renderer_hack="POWERSCALE",
	flying_only=true,
    icon=gfx.icons[197],
	dungeon=gfx.poisonspell,
	missile_type=MISSILE_MAGIC,
	on_impact=spell_explosion,
	on_target_explode=poison_impact,
	explosion_display_power_modifier=0.25,
	explode_into="poison_cloud",
	explode_sound=snd.zap,
	go_thru_bars = true
}

obj.poison_slime = clone_arch(obj.poison_desven, {
    name="SLIME",
	explode_sound=snd.thud
} )

obj.poison_ohven = {
    name="POISON",
    type="THING",
    class="SPELL",
    renderer_hack="POWERSCALE",
	flying_only=true,
    icon=gfx.icons[197],
	dungeon=gfx.poisonspell,
	missile_type=MISSILE_MAGIC,
	on_impact=spell_explosion,
	explode_into_cloud=true,
	explode_into="poison_cloud",
	explode_sound=snd.zap,
	go_thru_bars = true
}	
	
obj.fireball = {
    name="FIREBALL",
    type="THING",
    class="SPELL",
    renderer_hack="POWERSCALE",
	flying_only=true,
    icon=gfx.icons[197],
	dungeon=gfx.fireball,
	missile_type=MISSILE_MAGIC,
	on_impact=spell_explosion,
	on_location_explode=explode_square,
	explode_into="explosion",
	explode_sound=snd.explosion,
	no_shade = true
}

obj.desewspell = {
    name="DES EW SPELL",
    type="THING",
    class="SPELL",
    renderer_hack="POWERSCALE",
	flying_only=true,
	flying_hits_nonmat=true,
    icon=gfx.icons[197],
	dungeon=gfx.zapspell,
	flying_away=gfx.zapspell,
	flying_toward=gfx.zapspell,
	flying_side=gfx.zapspell,	
	missile_type=MISSILE_MAGIC,
	on_impact=spell_explosion,
	on_location_explode=desew_explode_square,
	explode_into="zap",
	explode_sound=snd.zap,
	no_shade = true
}

obj.lightning = {
    name="LIGHTNING",
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
	on_target_explode=lightning_impact,
	on_location_explode=explode_square,
	explosion_power_modifier=0.5,
	explode_into="explosion",
	explode_sound=snd.explosion,
	no_shade = true
}

obj.zospell = {
    name="ZO SPELL",
    type="THING",
    class="SPELL",
    renderer_hack="POWERSCALE",
	flying_only=true,
    icon=gfx.icons[197],
	dungeon=gfx.zapspell,
	flying_away=gfx.zapspell,
	flying_toward=gfx.zapspell,
	flying_side=gfx.zapspell,
	missile_type=MISSILE_MAGIC,
	zo_spell = true,
	hits_doorframes=true,
	on_impact=spell_explosion,
	on_location_explode=zo_explode_square,
	impact_success=false,
	explode_into="zap",
	explode_sound=snd.zap,
	no_shade = true
}

obj.zokathra = {
	name="ZOKATHRA SPELL",
	type="THING",
	class="SPELLITEM",
	mass=0,
	icon=gfx.icons[197],
	dungeon=gfx.corbum,
	no_fit_inventory=true,
	useless_thrown=true
}

obj.flamitt = {
	name = "FLAMITT",
	type="THING",
	class = "MAGIC",
	mass=12,
	icon=gfx.icons[15],
	dungeon=gfx.flamitt,
	fits_chest=true,
	def_charge=7,
	methods = {
	    { "SWING", 0, CLASS_FIGHTER, method_physattack },
	    { "FIREBALL", 5, { CLASS_WIZARD, SKILL_FIRE }, method_shoot_spell }
	},
	spell_power=150,
	convert_deplete="flamitt_x",
	base_tpower=24
}

obj.flamitt_x = {
	name = "FLAMITT",
	type="THING",
	class = "MAGIC",
	mass=12,
	icon=gfx.icons[14],
	dungeon=gfx.flamitt,
	fits_chest=true,
	methods = swing_method,
	base_tpower=12
}	

obj.flask = {
    name="EMPTY FLASK",
    type="THING",
    class="FLASK",
    mass=1,
    icon=gfx.icons[195],
	dungeon=gfx.flask_empty,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.flask_bro = {
	name="BRO POTION",
	type="THING",
	class="POTION",
	shortdesc="CONSUMABLE",
	mass=3,
	icon=gfx.icons[158],
	dungeon=gfx.flask_full,
	fit_pouch=true,
	hit_sound=snd.dink,
	on_consume=drinkpotion, 
	namechanger=potion_namechanger
}

obj.flask_dane = {
	name="DANE POTION",
	type="THING",
	class="POTION",
	shortdesc="CONSUMABLE",
	mass=3,
	icon=gfx.icons[156],
	dungeon=gfx.flask_full,
	fit_pouch=true,
	hit_sound=snd.dink,
	on_consume=drinkpotion,
	namechanger=potion_namechanger
}

obj.flask_ee = {
	name="EE POTION",
	type="THING",
	class="POTION",
	shortdesc="CONSUMABLE",
	mass=3,
	icon=gfx.icons[161],
	dungeon=gfx.flask_full,
	fit_pouch=true,
	hit_sound=snd.dink,
	on_consume=drinkpotion,
	namechanger=potion_namechanger
}
	
obj.flask_ku = {
	name="KU POTION",
	type="THING",
	class="POTION",
	shortdesc="CONSUMABLE",
	mass=3,
	icon=gfx.icons[155],
	dungeon=gfx.flask_full,
	fit_pouch=true,
	hit_sound=snd.dink,
	on_consume=drinkpotion,
	namechanger=potion_namechanger
}	

obj.flask_mon = {
	name="MON POTION",
	type="THING",
	class="POTION",
	shortdesc="CONSUMABLE",
	mass=3,
	icon=gfx.icons[159],
	dungeon=gfx.flask_full,
	fit_pouch=true,
	hit_sound=snd.dink,
	on_consume=drinkpotion,
	namechanger=potion_namechanger
}

obj.flask_neta = {
	name="NETA POTION",
	type="THING",
	class="POTION",
	shortdesc="CONSUMABLE",
	mass=3,
	icon=gfx.icons[157],
	dungeon=gfx.flask_full,
	fit_pouch=true,
	hit_sound=snd.dink,
	on_consume=drinkpotion,
	namechanger=potion_namechanger
}

obj.flask_ros = {
	name="ROS POTION",
	type="THING",
	class="POTION",
	shortdesc="CONSUMABLE",
	mass=3,
	icon=gfx.icons[154],
	dungeon=gfx.flask_full,
	fit_pouch=true,
	hit_sound=snd.dink,
	on_consume=drinkpotion,
	namechanger=potion_namechanger
}				

obj.flask_vi = {
	name="VI POTION",
	type="THING",
	class="POTION",
	shortdesc="CONSUMABLE",
	mass=3,
	icon=gfx.icons[162],
	dungeon=gfx.flask_full,
	fit_pouch=true,
	hit_sound=snd.dink,
	on_consume=drinkpotion,
	namechanger=potion_namechanger
}

obj.flask_ya = {
	name="YA POTION",
	type="THING",
	class="POTION",
	shortdesc="CONSUMABLE",
	mass=3,
	icon=gfx.icons[160],
	dungeon=gfx.flask_full,
	fit_pouch=true,
	hit_sound=snd.dink,
	on_consume=drinkpotion,
	namechanger=potion_namechanger
}

obj.flask_water = {
	name="FLASK OF WATER",
	type="THING",
	class="FLASK_WATER",
	shortdesc="CONSUMABLE",
	mass=3,
	icon=gfx.icons[163],
	dungeon=gfx.flask_full,
	fit_pouch=true,
	hit_sound=snd.dink,
	on_consume=eatdrink,
	waterval=1600,
	convert_consume="flask"
}
		
obj.flask_water_yucky = clone_arch(obj.flask_water, {
	icon=gfx.icons[249],
})

obj.flask_sar = {
	name="SAR_POTION",
    type="THING",
    class="USELESS",
    mass=1,
    icon=gfx.icons[152],
	dungeon=gfx.flask_full,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.flask_zo = {
	name="ZO_POTION",
    type="THING",
    class="USELESS",
    mass=1,
    icon=gfx.icons[154],
	dungeon=gfx.flask_full,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.fulbomb = {          
	name="FUL BOMB",
	type="THING",
	class="BOMB",
	mass=3,
	icon=gfx.icons[167],
	dungeon=gfx.fulbomb,
	methods= throw_method,
	on_impact=explode_thing,
	missile_type=MISSILE_MISC,
	explode_into="explosion",
	explode_sound=snd.explosion,
	fit_sheath=true,
	fit_pouch=true,
	namechanger=bomb_namechanger
}

obj.venbomb = {
	name="VEN BOMB",
	type="THING",
	class="BOMB",
	mass=3,
	icon=gfx.icons[151],
	dungeon=gfx.venbomb,
	methods= throw_method,
	on_impact=poisonbomb_thing,
	missile_type=MISSILE_MISC,
	explode_into="poison_cloud",
	explode_sound=snd.zap,
	fit_sheath=true,
	fit_pouch=true,
	namechanger=bomb_namechanger
}

obj.horn_of_fear = {
    name="HORN OF FEAR",
    type="THING",
    class="MISC",
    mass=8,
    def_charge=1,
    icon=gfx.icons[135],
    dungeon=gfx.horn,
	methods = {
		{ "BLOW HORN", 0, CLASS_PRIEST, method_causefear }
	}, 
    fit_pouch = true,
    fit_sheath = true
}

obj.rope = {
    name="ROPE",
    type="THING",
    class="MISC",
    mass=10,
    icon=gfx.icons[136],
    dungeon=gfx.rope,
	methods = {
		{ "CLIMB DOWN", 0, CLASS_NINJA, method_climbdown }
	}, 
    fit_chest=true,
    useless_thrown=true
}

obj.magicbox_blue = {
    name="MAGICAL BOX",
    type="THING",
    class="MAGIC",
    mass=6,
    def_charge=1,
    icon=gfx.icons[132],
    dungeon=gfx.magicbox_blue,
    methods = magicbox_methods,
    freeze_time = 30,
    fit_chest=true
}

obj.magicbox_green = clone_arch(obj.magicbox_blue, {
    mass=9,
    icon=gfx.icons[133],
    dungeon=gfx.magicbox_green,
    freeze_time = 125,
} )
	
obj.eye_of_time = {
	name="EYE OF TIME",
	type="THING",
	class="MAGIC",
	mass=1,
	def_charge=5,
	icon=gfx.icons[17],
	dungeon=gfx.ring,
	methods = {
		{ "PUNCH", 0, CLASS_NINJA, method_physattack },
		{ "FREEZE LIFE", 0, CLASS_WIZARD, method_freezelife }
	},
	freeze_time = 125,
	fit_pouch=true,
	convert_deplete="eye_of_time_x",
	hit_sound=snd.dink	
}

obj.eye_of_time_x = {
	name="EYE OF TIME",
	type="THING",
	class="MAGIC",
	mass=1,
	icon=gfx.icons[16],
	dungeon=gfx.ring,
	methods = {
		{ "PUNCH", 0, CLASS_NINJA, method_physattack }
	},
	fit_pouch=true,
	hit_sound=snd.dink	
}

obj.stormring = {
	name="STORMRING",
	type="THING",
	class="MAGIC",
	mass=1,
	def_charge=4,
	icon=gfx.icons[19],
	dungeon=gfx.ring,
	methods = {
		{ "PUNCH", 0, CLASS_NINJA, method_physattack },
		{ "LIGHTNING", 2, { CLASS_WIZARD, SKILL_AIR }, method_shoot_spell }
	},
	spell_power=180,
	fit_pouch=true,
	convert_deplete="stormring_x",
	hit_sound=snd.dink
}

obj.stormring_x = {
	name="STORMRING",
	type="THING",
	class="MAGIC",
	mass=1,
	icon=gfx.icons[18],
	dungeon=gfx.ring,
	methods = {
		{ "PUNCH", 0, CLASS_NINJA, method_physattack }
	},
	fit_pouch=true,
	hit_sound=snd.dink	
}

obj.wand = {
	name="WAND",
	type="THING",
	class="MAGIC",
	mass=1,
	icon=gfx.icons[59],
	dungeon=gfx.wand,
	methods = {
		{ "CALM", 0, CLASS_PRIEST, method_causefear },
		{ "SPELLSHIELD", 1, { CLASS_PRIEST, SKILL_SHIELDS }, method_shield },
		{ "HEAL", 2, { CLASS_PRIEST, SKILL_POTIONS }, method_heal }
	},
	def_charge=15,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 10,
	shield_power = 16,
	shield_duration = 280,
	convert_deplete="wand_x",
	hit_sound = snd.dink,
	go_thru_bars = true,
	fit_pouch = true,
	fit_sheath = true
}

obj.wand_x = {
	name="WAND",
	type="THING",
	class="MAGIC",
	mass=1,
	icon=gfx.icons[59],
	dungeon=gfx.wand,
	methods = {
		{ "CALM", 0, CLASS_PRIEST, method_causefear },
		{ "HEAL", 2, { CLASS_PRIEST, SKILL_POTIONS }, method_heal }
	},
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 10,
	hit_sound = snd.dink,
	go_thru_bars = true,
	fit_pouch = true,
	fit_sheath = true
}

obj.teowand = {
	name="TEOWAND",
	type="THING",
	class="MAGIC",
	mass=2,
	icon=gfx.icons[60],
	dungeon=gfx.wand,
	methods = {
		{ "CALM", 0, CLASS_PRIEST, method_causefear },
		{ "SPELLSHIELD", 2, { CLASS_PRIEST, SKILL_SHIELDS }, method_shield },
		{ "FIRESHIELD", 3, { CLASS_PRIEST, SKILL_SHIELDS }, method_shield }
	},
	def_charge=15,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 60,
	shield_power = 18,
	shield_duration = 280,
	convert_deplete="teowand_x",
	hit_sound = snd.dink,
	go_thru_bars = true,
	fit_pouch = true,
	fit_sheath = true
}

obj.teowand_x = {
	name="TEOWAND",
	type="THING",
	class="MAGIC",
	mass=2,
	icon=gfx.icons[60],
	dungeon=gfx.wand,
	methods = {
		{ "CALM", 0, CLASS_PRIEST, method_causefear }
	},
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 60,
	hit_sound = snd.dink,
	go_thru_bars = true,
	fit_pouch = true,
	fit_sheath = true
}

obj.staff = {
	name="STAFF",
	type="THING",
	mass=26,
	class="STAFF",
	icon=gfx.icons[58],
	dungeon=gfx.staff_plain,
	methods=swing_method,
	fit_sheath = true,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 20,
	base_tpower = 12
}		

obj.staff_claws = {
	name = "STAFF OF CLAWS",
	type="THING",
	mass=9,
	class="STAFF",
	icon=gfx.icons[21],
	dungeon=gfx.staff_plain,
	def_charge=15,
	methods = {
		{ "SLASH", 0, CLASS_FIGHTER, method_physattack },
		{ "BRANDISH", 0, CLASS_PRIEST, method_causefear },
		{ "CONFUSE", 2, { CLASS_PRIEST, SKILL_FEAR }, method_causefear }
	},
	fit_sheath=true,
	convert_deplete="staff_claws_x",
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 40,
	base_tpower = 16,
}

obj.staff_claws_x = {
	name = "STAFF OF CLAWS",
	type="THING",
	mass=9,
	class="STAFF",
	icon=gfx.icons[20],
	dungeon=gfx.staff_plain,
	methods = {
		{ "SLASH", 0, CLASS_FIGHTER, method_physattack },
		{ "BRANDISH", 0, CLASS_PRIEST, method_causefear }
	},
	fit_sheath=true,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 40,
	base_tpower = 16
}

obj.staff_yew = {
	name = "YEW STAFF",
	type="THING",
	mass=35,
	class="STAFF",
	icon=gfx.icons[61],
	dungeon=gfx.staff_plain,
	methods = {
		{ "PARRY", 0, CLASS_FIGHTER, method_physattack },
		{ "LIGHT", 0, CLASS_WIZARD, method_light },
		{ "DISPELL", 2, { CLASS_WIZARD, SKILL_DES }, method_shoot_spell }
	},
	fit_sheath=true,
	def_charge=12,
	spell_power=140,
	light_power=60,
	light_fade=2,
	light_fade_time=2500,
	convert_deplete="staff_yew_x",
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 40,
	base_tpower = 18	
}

obj.staff_yew_x = {
	name = "YEW STAFF",
	type="THING",
	mass=35,
	class="STAFF",
	icon=gfx.icons[61],
	dungeon=gfx.staff_plain,
	methods = {
		{ "PARRY", 0, CLASS_FIGHTER, method_physattack }
	},
	fit_sheath=true,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 40,
	base_tpower = 18		
}

obj.staff_manar = {
	name = "STAFF OF MANAR",
	type="THING",
	mass=29,
	class="STAFF",
	icon=gfx.icons[62],
	dungeon=gfx.staff_plain,
	methods = {
		{ "SWING", 0, CLASS_FIGHTER, method_physattack },
		{ "DISPELL", 2, { CLASS_WIZARD, SKILL_DES }, method_shoot_spell },
		{ "FIRESHIELD", 3, { CLASS_PRIEST, SKILL_SHIELDS }, method_shield }
	},
	fit_sheath=true,
	def_charge=15,
	spell_power=160,
	shield_power = 16,
	shield_duration = 280,
	convert_deplete="staff_manar_x",
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 100	
}

obj.staff_manar_x = {
	name = "STAFF OF MANAR",
	type="THING",
	mass=29,
	class="STAFF",
	icon=gfx.icons[62],
	dungeon=gfx.staff_plain,
	methods = {
		{ "SWING", 0, CLASS_FIGHTER, method_physattack }
	},
	fit_sheath=true,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 100		
}

obj.staff_irra = clone_arch(obj.staff_manar, {
	name = "STAFF OF IRRA",
	icon=gfx.icons[233],
	convert_deplete="staff_irra_x"
} )

obj.staff_irra_x = clone_arch(obj.staff_manar_x, {
	name = "STAFF OF IRRA",
	icon=gfx.icons[233]
} )

obj.staff_snake = {
	name = "SNAKE STAFF",
	type="THING",
	mass=21,
	class="STAFF",
	icon=gfx.icons[63],
	dungeon=gfx.staff_plain,
	methods = {
		{ "HEAL", 0, CLASS_PRIEST, method_heal },
		{ "CALM", 0, CLASS_PRIEST, method_causefear },
		{ "BRANDISH", 0, CLASS_PRIEST, method_causefear }
	},
	fit_sheath=true,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 80		
}

obj.staff_neta = clone_arch(obj.staff_snake, {
	name = "CROSS OF NETA",
	icon=gfx.icons[234],
	dungeon=gfx.staff_ornate
} )

obj.staff_conduit = {
	name = "THE CONDUIT",
	type="THING",
	mass=33,
	class="STAFF",
	icon=gfx.icons[64],
	dungeon=gfx.staff_conduit,
	methods = {
		{ "SWING", 0, CLASS_FIGHTER, method_physattack },
		{ "LIGHTNING", 1, { CLASS_WIZARD, SKILL_AIR }, method_shoot_spell },
		{ "WINDOW", 3, { CLASS_WIZARD, SKILL_DES }, method_window }
	},
	convert_deplete="staff_conduit_x",
	def_charge=15,
	fit_sheath=true,
	spell_power=180,
	window_duration=120,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 160		
}

obj.staff_conduit_x = {
	name = "THE CONDUIT",
	type="THING",
	mass=33,
	class="STAFF",
	icon=gfx.icons[64],
	dungeon=gfx.staff_conduit,
	methods = {
		{ "SWING", 0, CLASS_FIGHTER, method_physattack }
	},
	fit_sheath=true,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 160		
}

obj.staff_serpent = clone_arch(obj.staff_conduit, {
	name = "SERPENT STAFF",
	icon=gfx.icons[235],
	dungeon=gfx.staff_serpent,
	convert_deplete="staff_serpent_x"
} )

obj.staff_serpent_x = clone_arch(obj.staff_conduit_x, {
	name = "SERPENT STAFF",
	icon=gfx.icons[235],
	dungeon=gfx.staff_serpent
} )

-- This is a dragon spit with a "SPIT" method, as hypothesized
-- but is not actually in DM. Use the discharged version,
-- dragon_spit_x, to get the one that is actually in DM.
obj.dragon_spit = {
	name = "DRAGON SPIT",
	type="THING",
	class="MAGIC",
	mass = 8,
	icon=gfx.icons[65],
	dungeon=gfx.dragon_spit,
	methods = {
		{ "SWING", 0, CLASS_FIGHTER, method_physattack },
		{ "SPIT", 4, { CLASS_WIZARD, SKILL_FIRE }, method_shoot_spell }
	},
	def_charge=8,
	convert_deplete="dragon_spit_x",
	spell_power=190,
	fit_chest = true,
	fit_sheath = true,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 70
}

obj.dragon_spit_x = {
	name = "DRAGON SPIT",
	type="THING",
	class="MAGIC",
	mass = 8,
	icon=gfx.icons[65],
	dungeon=gfx.dragon_spit,
	methods = {
		{ "SWING", 0, CLASS_FIGHTER, method_physattack }
	},
	fit_chest = true,
	fit_sheath = true,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 70
}

obj.firestaff = {
	name = "THE FIRESTAFF",
	type="THING",
	class="STAFF",
	mass = 24,
	icon=gfx.icons[27],
	dungeon=gfx.firestaff,
	methods = {
		{ "PARRY", 0, CLASS_FIGHTER, method_physattack },
		{ "BRANDISH", 2, { CLASS_PRIEST, SKILL_FEAR }, method_causefear },
		{ "FIRESHIELD", 3, { CLASS_PRIEST, SKILL_SHIELDS }, method_shield }
	},
	shield_power = 22,
	shield_duration = 300,
	fit_sheath = true,
	to_l_hand = boost_all_skills,
	to_r_hand = boost_all_skills,
	from_l_hand = boost_all_skills_off,
	from_r_hand = boost_all_skills_off,
	boost = 1
}

obj.firestaff_gem = {
	name = "THE FIRESTAFF",
	type="THING",
	class="STAFF",
	mass = 36,
	icon=gfx.icons[28],
	dungeon=gfx.firestaff_gem,
	methods = {
		{ "INVOKE", 0, CLASS_WIZARD, method_shoot_spell },
		{ "FUSE", 0, CLASS_WIZARD, method_fuse },
		{ "FLUXCAGE", 0, CLASS_WIZARD, method_fluxcage }
	},
	spell_power=100,
	random_spell_power=127,
	fit_sheath = true,
	to_l_hand = boost_all_skills,
	to_r_hand = boost_all_skills,
	from_l_hand = boost_all_skills_off,
	from_r_hand = boost_all_skills_off,
	boost = 2
}

obj.lyf = {
	name = "SCEPTRE OF LYF",
	type="THING",
	class="STAFF",
	mass = 18,
	icon=gfx.icons[66],
	dungeon=gfx.staff_ornate,
	methods = {
		{ "PARRY", 0, CLASS_FIGHTER, method_physattack },
		{ "HEAL", 2, { CLASS_PRIEST, SKILL_POTIONS }, method_heal },
		{ "LIGHT", 3, { CLASS_WIZARD, SKILL_AIR }, method_light }
	},
	def_charge = 15,
	light_power=60,
	light_fade=2,
	light_fade_time=2500,
	fit_sheath=true,
	to_l_hand = lyf_boost,
	to_r_hand = lyf_boost,
	from_l_hand = lyf_boost_off,
	from_r_hand = lyf_boost_off,
	convert_deplete = "lyf_x"
}  

obj.lyf_x = {
	name = "SCEPTRE OF LYF",
	type="THING",
	class="STAFF",
	mass = 18,
	icon=gfx.icons[66],
	dungeon=gfx.staff_ornate,
	methods = {
		{ "PARRY", 0, CLASS_FIGHTER, method_physattack },
		{ "HEAL", 2, { CLASS_PRIEST, SKILL_POTIONS }, method_heal }
	},
	fit_sheath=true,
	to_l_hand = lyf_boost,
	to_r_hand = lyf_boost,
	from_l_hand = lyf_boost_off,
	from_r_hand = lyf_boost_off
}

obj.cape = {
	name="CAPE",
	type="THING",
	class="CAPE",
	mass=3,
	icon=gfx.icons[80],
	dungeon=gfx.clothes_brown,
	fit_torso=true,
	fit_neck=true,
	fit_chest=true,
	armor_str = 5,
	sharp_resist = 1,
	useless_thrown=true
}

obj.cloak_night = {
	name="CLOAK OF NIGHT",
	type="THING",
	class="CAPE",
	mass=4,
	icon=gfx.icons[81],
	dungeon=gfx.clothes_brown,
	fit_torso=true,
	fit_neck=true,
	fit_chest=true,
	armor_str = 10,
	sharp_resist = 1,
	to_torso = stat_bonus,
	to_neck = stat_bonus,
	from_torso = stat_bonus_off,
	from_neck = stat_bonus_off,
	stat = STAT_DEX,
	stat_up = 80,
	useless_thrown=true
}

obj.halter = {
	name="HALTER",
	type="THING",
	class="TORSO",
	mass=2,
	icon=gfx.icons[196],
	dungeon=gfx.halter,
	fit_torso=true,
	fit_chest=true,
	armor_str = 3,
	sharp_resist = 3,
	useless_thrown=true
}

obj.tattered_shirt = {
	name = "TATTERED SHIRT",
	type="THING",
	class="TORSO",
	mass = 4,
	icon=gfx.icons[236],
	dungeon=gfx.clothes_green,
	fit_torso=true,
	fit_chest=true,
	armor_str = 5,
	sharp_resist = 0,
	useless_thrown=true
}

obj.robe_top = {
	name = "ROBE",
	type="THING",
	class="TORSO",
	mass = 4,
	icon=gfx.icons[67],
	dungeon=gfx.clothes_white,
	fit_torso=true,
	fit_chest=true,
	armor_str = 5,
	sharp_resist = 0,
	useless_thrown=true
}

obj.robe_fine_top = {
	name = "FINE ROBE",
	type="THING",
	class="TORSO",
	mass = 4,
	icon=gfx.icons[68],
	dungeon=gfx.clothes_white,
	fit_torso=true,
	fit_chest=true,
	armor_str = 7,
	sharp_resist = 1,
	useless_thrown=true
}

obj.kirtle = {
	name = "KIRTLE",
	type="THING",
	class="TORSO",
	mass = 4,
	icon=gfx.icons[69],
	dungeon=gfx.clothes_blue,
	fit_torso=true,
	fit_chest=true,
	armor_str = 6,
	sharp_resist = 1,
	useless_thrown=true
}

obj.silk_shirt = {
	name = "SILK SHIRT",
	type="THING",
	class="TORSO",
	mass = 2,
	icon=gfx.icons[70],
	dungeon=gfx.clothes_white,
	fit_torso=true,
	fit_chest=true,
	armor_str = 4,
	sharp_resist = 0,
	useless_thrown=true
}

obj.elven_doublet = {
	name = "ELVEN DOUBLET",
	type="THING",
	class="TORSO",
	mass = 3,
	icon=gfx.icons[71],
	dungeon=gfx.clothes_green,
	fit_torso=true,
	fit_chest=true,
	armor_str = 11,
	sharp_resist = 2,
	useless_thrown=true
}			

obj.leather_jerkin = {
	name = "LEATHER JERKIN",
	type="THING",
	class="TORSO",
	mass = 6,
	icon=gfx.icons[72],
	dungeon=gfx.clothes_brown,
	fit_torso=true,
	fit_chest=true,
	armor_str = 17,
	sharp_resist = 3,
	useless_thrown=true
}

obj.tunic = {
	name = "TUNIC",
	type="THING",
	class="TORSO",
	mass = 5,
	icon=gfx.icons[73],
	dungeon=gfx.clothes_blue,
	fit_torso=true,
	fit_chest=true,
	armor_str = 9,
	sharp_resist = 1,
	useless_thrown=true
}	
				
obj.ghi = {
	name = "GHI",
	type="THING",
	class="TORSO",
	mass = 5,
	icon=gfx.icons[74],
	dungeon=gfx.clothes_white,
	fit_torso=true,
	fit_chest=true,
	armor_str = 8,
	sharp_resist = 1,
	useless_thrown=true
}

obj.mail_aketon = {
	name = "MAIL AKETON",
	type="THING",
	class="TORSO",
	mass = 65,
	icon=gfx.icons[75],
	dungeon=gfx.mail,
	fit_torso=true,
	fit_chest=true,
	armor_str = 35,
	sharp_resist = 5,
	useless_thrown=true
}	

obj.mithral_aketon = {
	name = "MITHRAL AKETON",
	type="THING",
	class="TORSO",
	mass = 52,
	icon=gfx.icons[76],
	dungeon=gfx.mail,
	fit_torso=true,
	fit_chest=true,
	armor_str = 70,
	sharp_resist = 7,
	useless_thrown=true
}

obj.flamebain = {
	name = "FLAMEBAIN",
	type="THING",
	class="TORSO",
	mass = 57,
	icon=gfx.icons[141],
	dungeon=gfx.mail,
	fit_torso=true,
	fit_chest=true,
	armor_str = 60,
	sharp_resist = 7,
	to_torso = stat_bonus,
	from_torso = stat_bonus_off,
	stat = STAT_AFI,
	stat_up = 120,
	useless_thrown=true
}

obj.torsoplate = {
    name="TORSO PLATE",
	type="THING",
	class="TORSO",
	mass=120,
	icon=gfx.icons[77],
	dungeon=gfx.torsoplate,
	fit_torso = true,
	armor_str = 65,
	sharp_resist = 4,
	hit_sound=snd.dink
}

obj.torsoplate_cursed = clone_arch(obj.torsoplate, {
	shortdesc="CURSED",
	cursed = true
})

obj.torsoplate_lyte = {
    name="PLATE OF LYTE",
	type="THING",
	class="TORSO",
	mass=108,
	icon=gfx.icons[78],
	dungeon=gfx.torsoplate,
	fit_torso = true,
	armor_str = 125,
	sharp_resist = 4,
	hit_sound=snd.dink
}

obj.torsoplate_ra = clone_arch(obj.torsoplate_lyte, {
    name="PLATE OF RA",
	icon=gfx.icons[238]
})

obj.torsoplate_darc = {
    name="PLATE OF DARC",
	type="THING",
	class="TORSO",
	mass=141,
	icon=gfx.icons[79],
	dungeon=gfx.torsoplate,
	fit_torso = true,
	armor_str = 160,
	sharp_resist = 4,
	hit_sound=snd.dink
}	

obj.torsoplate_dragon = clone_arch(obj.torsoplate_darc, {
    name="DRAGON PLATE",
	icon=gfx.icons[239]
})

obj.barbarian_hide = {
	name="BARBARIAN HIDE",
	type="THING",
	class="LEGS",
	mass=3,
	icon=gfx.icons[82],
	dungeon=gfx.clothes_brown,
	fit_legs=true,
	fit_chest=true,
	armor_str = 4,
	sharp_resist = 1,
	useless_thrown=true
}

obj.tattered_pants = {
	name="TATTERED PANTS",
	type="THING",
	class="LEGS",
	mass=3,
	icon=gfx.icons[237],
	dungeon=gfx.clothes_brown,
	fit_legs=true,
	fit_chest=true,
	armor_str = 4,
	sharp_resist = 1,
	useless_thrown=true
}											

obj.robe_bottom = {
	name = "ROBE",
	type="THING",
	class="LEGS",
	mass = 4,
	icon=gfx.icons[83],
	dungeon=gfx.clothes_white,
	fit_legs=true,
	fit_chest=true,
	armor_str = 5,
	sharp_resist = 0,
	useless_thrown=true
}

obj.robe_fine_bottom = {
	name = "FINE ROBE",
	type="THING",
	class="LEGS",
	mass = 4,
	icon=gfx.icons[84],
	dungeon=gfx.clothes_white,
	fit_legs=true,
	fit_chest=true,
	armor_str = 7,
	sharp_resist = 1,
	useless_thrown=true
}

obj.tabard = {
	name = "TABARD",
	type="THING",
	class="LEGS",
	mass = 4,
	icon=gfx.icons[85],
	dungeon=gfx.clothes_white,
	fit_legs=true,
	fit_chest=true,
	armor_str = 5,
	sharp_resist = 1,
	useless_thrown=true
}

obj.gunna = {
	name = "GUNNA",
	type="THING",
	class="LEGS",
	mass = 5,
	icon=gfx.icons[86],
	dungeon=gfx.clothes_blue,
	fit_legs=true,
	fit_chest=true,
	armor_str = 7,
	sharp_resist = 1,
	useless_thrown=true
}

obj.elven_huke = {
	name = "ELVEN HUKE",
	type="THING",
	class="LEGS",
	mass = 3,
	icon=gfx.icons[87],
	dungeon=gfx.clothes_green,
	fit_legs=true,
	fit_chest=true,
	armor_str = 13,
	sharp_resist = 2,
	useless_thrown=true
}			

obj.leather_pants = {
	name = "LEATHER PANTS",
	type="THING",
	class="LEGS",
	mass = 8,
	icon=gfx.icons[88],
	dungeon=gfx.clothes_brown,
	fit_legs=true,
	fit_chest=true,
	armor_str = 20,
	sharp_resist = 3,
	useless_thrown=true
}

obj.blue_pants = {
	name = "BLUE PANTS",
	type="THING",
	class="LEGS",
	mass = 6,
	icon=gfx.icons[89],
	dungeon=gfx.clothes_blue,
	fit_legs=true,
	fit_chest=true,
	armor_str = 12,
	sharp_resist = 2,
	useless_thrown=true
}	

obj.ghi_trousers = {
	name = "GHI TROUSERS",
	type="THING",
	class="LEGS",
	mass = 5,
	icon=gfx.icons[90],
	dungeon=gfx.clothes_white,
	fit_legs=true,
	fit_chest=true,
	armor_str = 9,
	sharp_resist = 1,
	useless_thrown=true
}

obj.leg_mail = {
	name = "LEG MAIL",
	type="THING",
	class="LEGS",
	mass = 53,
	icon=gfx.icons[91],
	dungeon=gfx.mail,
	fit_legs=true,
	fit_chest=true,
	armor_str = 35,
	sharp_resist = 5,
	useless_thrown=true
}	

obj.mithral_mail = {
	name = "MITHRAL MAIL",
	type="THING",
	class="LEGS",
	mass = 41,
	icon=gfx.icons[92],
	dungeon=gfx.mail,
	fit_legs=true,
	fit_chest=true,
	armor_str = 55,
	sharp_resist = 7,
	useless_thrown=true
}

obj.legplate = {
    name="LEG PLATE",
	type="THING",
	class="LEGS",
	mass=80,
	icon=gfx.icons[93],
	dungeon=gfx.legplate,
	fit_legs = true,
	armor_str = 56,
	sharp_resist = 4,
	hit_sound=snd.dink
}

obj.legplate_cursed = clone_arch(obj.legplate, {
	shortdesc="CURSED",
	cursed = true
})

obj.legplate_lyte = {
    name="POLEYN OF LYTE",
	type="THING",
	class="LEGS",
	mass=72,
	icon=gfx.icons[94],
	dungeon=gfx.legplate,
	fit_legs = true,
	armor_str = 90,
	sharp_resist = 4,
	hit_sound=snd.dink
}

obj.legplate_ra = clone_arch(obj.legplate_lyte, {
    name="POLEYN OF RA",
	icon=gfx.icons[254]
})

obj.legplate_darc = {
    name="POLEYN OF DARC",
	type="THING",
	class="LEGS",
	mass=90,
	icon=gfx.icons[95],
	dungeon=gfx.legplate,
	fit_legs = true,
	armor_str = 101,
	sharp_resist = 4,
	hit_sound=snd.dink
}

obj.legplate_dragon = clone_arch(obj.legplate_darc, {
    name="DRAGON POLEYN",
	icon=gfx.icons[255]
})

obj.powertowers = {
    name="POWERTOWERS",
	type="THING",
	class="LEGS",
	mass=81,
	icon=gfx.icons[142],
	dungeon=gfx.legplate,
	fit_legs = true,
	fit_chest = true, -- Someone managed to cram them in one in CSB!
	armor_str = 88,
	sharp_resist = 4,
	hit_sound=snd.dink,
	to_legs = stat_bonus,
	from_legs = stat_bonus_off,
	stat = STAT_STR,
	stat_up = 100	
}

obj.berzerker_helm = {
    name="BERZERKER HELM",
	type="THING",
	class="HEAD",
	mass=11,
	icon=gfx.icons[96],
	dungeon=gfx.helmet,
	fit_head = true,
	fit_chest = true,
	armor_str = 12,
	sharp_resist = 5,
	hit_sound=snd.dink
}

obj.berzerker_helm_csb = clone_arch(obj.berzerker_helm, {
	icon=gfx.icons[248]
} )

obj.helmet = {
    name="HELMET",
	type="THING",
	class="HEAD",
	mass=14,
	icon=gfx.icons[97],
	dungeon=gfx.helmet,
	fit_head = true,
	fit_chest = true,
	armor_str = 17,
	sharp_resist = 5,
	hit_sound=snd.dink
}

obj.basinet = {
    name="BASINET",
	type="THING",
	class="HEAD",
	mass=15,
	icon=gfx.icons[98],
	dungeon=gfx.helmet,
	fit_head = true,
	fit_chest = true,
	armor_str = 20,
	sharp_resist = 5,
	hit_sound=snd.dink
}

obj.casquencoif = {
    name="CASQUE'N COIF",
	type="THING",
	class="HEAD",
	mass=16,
	icon=gfx.icons[99],
	dungeon=gfx.helmet,
	fit_head = true,
	fit_chest = true,
	armor_str = 26,
	sharp_resist = 6,
	hit_sound=snd.dink
}
						
obj.armet = {
    name="ARMET",
	type="THING",
	class="HEAD",
	mass=19,
	icon=gfx.icons[100],
	dungeon=gfx.helmet2,
	fit_head = true,
	fit_chest  =true,
	armor_str = 40,
	sharp_resist = 7,
	hit_sound=snd.dink
}

obj.armet_cursed = clone_arch(obj.armet, {
	shortdesc="CURSED",
	cursed = true
})

obj.helm_lyte = {
    name="HELM OF LYTE",
	type="THING",
	class="HEAD",
	mass=17,
	icon=gfx.icons[101],
	dungeon=gfx.helmet2,
	fit_head = true,
	fit_chest = true,
	armor_str = 62,
	sharp_resist = 5,
	hit_sound=snd.dink
}

obj.helm_ra = clone_arch(obj.helm_lyte, {
    name="HELM OF RA",
	icon=gfx.icons[149]
})

obj.helm_darc = {
    name="HELM OF DARC",
	type="THING",
	class="HEAD",
	mass=35,
	icon=gfx.icons[102],
	dungeon=gfx.helmet2,
	fit_head = true,
	fit_chest = true,
	armor_str = 76,
	sharp_resist = 4,
	hit_sound=snd.dink
}

obj.helm_dragon = clone_arch(obj.helm_darc, {
    name="DRAGON HELM",
	icon=gfx.icons[150]
})

obj.dexhelm = {
    name="DEXHELM",
	type="THING",
	class="HEAD",
	mass=14,
	icon=gfx.icons[140],
	dungeon=gfx.helmet2,
	fit_head = true,
	fit_chest = true,
	armor_str = 54,
	sharp_resist = 6,
	hit_sound=snd.dink,
	to_head = stat_bonus,
	from_head = stat_bonus_off,
	stat = STAT_DEX,
	stat_up = 100
}

obj.calista = {
    name="CALISTA",
	type="THING",
	class="HEAD",
	mass=4,
	icon=gfx.icons[103],
	dungeon=gfx.crown,
	fit_head = true,
	fit_chest = true,
	armor_str = 1,
	sharp_resist = 4
}	

obj.crown_nerra = {
    name="CROWN OF NERRA",
	type="THING",
	class="HEAD",
	mass=6,
	icon=gfx.icons[104],
	dungeon=gfx.crown,
	fit_head = true,
	fit_chest = true,
	armor_str = 5,
	sharp_resist = 4,
	to_head = stat_bonus,
	from_head = stat_bonus_off,
	stat = STAT_WIS,
	stat_up = 100
}

obj.sandals = {
    name="SANDALS",
	type="THING",
	class="FEET",
	mass=6,
	icon=gfx.icons[112],
	dungeon=gfx.sandals,
	fit_feet = true,
	fit_chest = true,
	armor_str = 5,
	sharp_resist = 2,
	useless_thrown=true
}

obj.boots_suede = {
    name="SUEDE BOOTS",
	type="THING",
	class="FEET",
	mass=14,
	icon=gfx.icons[113],
	dungeon=gfx.boots_brown,
	fit_feet = true,
	fit_chest = true,
	armor_str = 20,
	sharp_resist = 3
}

obj.boots_leather = {
    name="LEATHER BOOTS",
	type="THING",
	class="FEET",
	mass=16,
	icon=gfx.icons[114],
	dungeon=gfx.boots_black,
	fit_feet = true,
	fit_chest = true,
	armor_str = 25,
	sharp_resist = 4
}

obj.hosen = {
    name="HOSEN",
	type="THING",
	class="FEET",
	mass=16,
	icon=gfx.icons[115],
	dungeon=gfx.mail,
	fit_feet = true,
	fit_chest = true,
	armor_str = 30,
	sharp_resist = 6,
	useless_thrown=true
}
	
obj.footplate = {
    name="FOOT PLATE",
	type="THING",
	class="FEET",
	mass=28,
	icon=gfx.icons[116],
	dungeon=gfx.footplate,
	fit_feet = true,
	armor_str = 37,
	sharp_resist = 5,
	hit_sound=snd.dink
}

obj.footplate_cursed = clone_arch(obj.footplate, {
	shortdesc="CURSED",
	cursed = true
})

obj.footplate_lyte = {
    name="GREAVE OF LYTE",
	type="THING",
	class="FEET",
	mass=24,
	icon=gfx.icons[117],
	dungeon=gfx.footplate,
	fit_feet = true,
	armor_str = 50,
	sharp_resist = 5,
	hit_sound=snd.dink
}

obj.footplate_ra = clone_arch(obj.footplate_lyte, {
    name="GREAVE OF RA",
	icon=gfx.icons[165]
})

obj.footplate_darc = {
    name="GREAVE OF DARC",
	type="THING",
	class="FEET",
	mass=31,
	icon=gfx.icons[118],
	dungeon=gfx.footplate,
	fit_feet = true,
	armor_str = 60,
	sharp_resist = 5,
	hit_sound=snd.dink
}

obj.footplate_dragon = clone_arch(obj.footplate_darc, {
    name="DRAGON GREAVE",
	icon=gfx.icons[166]
})

obj.boots_elven = {
    name="ELVEN BOOTS",
	type="THING",
	class="FEET",
	mass=4,
	icon=gfx.icons[119],
	dungeon=gfx.boots_elven,
	fit_feet = true,
	fit_chest = true,
	armor_str = 13,
	sharp_resist = 2
}

obj.boots_speed = {
    name="BOOTS OF SPEED",
	type="THING",
	class="FEET",
	mass=3,
	icon=gfx.icons[194],
	dungeon=gfx.boots_speed,
	fit_feet = true,
	fit_chest = true,
	armor_str = 16,
	sharp_resist = 2
}

obj.club = {
    name="CLUB",
    type="THING",
    class="CLUB",
    mass=36,
    icon=gfx.icons[47],
	dungeon=gfx.club,
	flying_away=gfx.club_flying,
	flying_toward=gfx.club_flying,
	flying_side=gfx.club_flying_side,
	methods = club_methods,
	base_tpower=19,
	base_range=10,
	impact=10,
    fit_sheath=true
}

obj.club_stone = {
    name="STONE CLUB",
    type="THING",
    class="CLUB",
    mass=110,
    icon=gfx.icons[48],
	dungeon=gfx.club_stone,
	flying_away=gfx.club_stone_flying,
	flying_toward=gfx.club_stone_flying,
	flying_side=gfx.club_stone_flying_side,
	methods = club_methods,
	base_tpower=44,
	base_range=4,
	impact=22,
    fit_sheath=true
}

obj.boltblade = {
    name="BOLT BLADE",
    type="THING",
    class="WEAPON",
    mass=30,
    icon=gfx.icons[24],
    dungeon=gfx.sword,
	flying_away=gfx.sword_flying_away,
	flying_toward=gfx.sword_flying_toward,
	flying_side=gfx.sword_flying_side,
	methods = {
	    { "JAB", 0, CLASS_FIGHTER, method_physattack },
	    { "CHOP", 2, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack },
	    { "LIGHTNING", 3, { CLASS_WIZARD, SKILL_AIR }, method_shoot_spell }
	},
	def_charge=14,
	spell_power=180,
	base_range=10,
	base_tpower=49,
	impact=14,
	bonus_power=6,
	fit_sheath=true,
	hit_sound=snd.dink,
	convert_deplete="boltblade_x",
}

obj.boltblade_x = {
    name="BOLT BLADE",
    type="THING",
    class="WEAPON",
    mass=30,
    icon=gfx.icons[23],
    dungeon=gfx.sword,
	flying_away=gfx.sword_flying_away,
	flying_toward=gfx.sword_flying_toward,
	flying_side=gfx.sword_flying_side,
	methods = {
	    { "JAB", 0, CLASS_FIGHTER, method_physattack },
	    { "CHOP", 2, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack }
	},
	base_range=10,
	base_tpower=49,
	impact=10,
	bonus_power=6,
	fit_sheath=true,
	hit_sound=snd.dink
}

obj.storm = clone_arch(obj.boltblade, {
    name="STORM",
    icon=gfx.icons[225],
	convert_deplete="storm_x"
} )

obj.storm_x = clone_arch(obj.boltblade_x, {
    name="STORM",
    icon=gfx.icons[224]
} )

obj.fury = {
    name="FURY",
    type="THING",
    class="WEAPON",
    mass=47,
    icon=gfx.icons[26],
    dungeon=gfx.sword,
	flying_away=gfx.sword_flying_away,
	flying_toward=gfx.sword_flying_toward,
	flying_side=gfx.sword_flying_side,
	methods = {
	    { "CHOP", 0, CLASS_FIGHTER, method_physattack },
	    { "MELEE", 3, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack },
	    { "FIREBALL", 5, { CLASS_WIZARD, SKILL_FIRE }, method_shoot_spell }
	},
	def_charge=8,
	spell_power=150,
	base_range=10,
	base_tpower=55,
	impact=20,
	bonus_power=8,
	fit_sheath=true,
	hit_sound=snd.dink,
	convert_deplete="fury_x"
}

obj.fury_x = {
    name="FURY",
    type="THING",
    class="WEAPON",
    mass=47,
    icon=gfx.icons[25],
    dungeon=gfx.sword,
	flying_away=gfx.sword_flying_away,
	flying_toward=gfx.sword_flying_toward,
	flying_side=gfx.sword_flying_side,
	methods = {
	    { "CHOP", 0, CLASS_FIGHTER, method_physattack },
	    { "MELEE", 3, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack }
	},
	base_range=10,
	base_tpower=55,
	impact=10,
	bonus_power=8,
	fit_sheath=true,
	hit_sound=snd.dink
}

obj.rablade = clone_arch(obj.fury, {
    name="RA BLADE",
    icon=gfx.icons[227],
	convert_deplete="rablade_x"
} )

obj.rablade_x = clone_arch(obj.fury_x, {
    name="RA BLADE",
    icon=gfx.icons[226]
} )

obj.falchion = {
    name="FALCHION",
    type="THING",
    class="WEAPON",
    mass=33,
    icon=gfx.icons[33],
    dungeon=gfx.sword,
	flying_away=gfx.sword_flying_away,
	flying_toward=gfx.sword_flying_toward,
	flying_side=gfx.sword_flying_side,
	methods = {
	    { "SWING", 0, CLASS_FIGHTER, method_physattack },
	    { "PARRY", 1, { CLASS_FIGHTER, SKILL_DEFENSE }, method_physattack },
	    { "CHOP", 2, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack }
	},
	base_range=10,
	base_tpower=30,
	impact=8,
	fit_sheath=true,
	hit_sound=snd.dink
}

obj.sword = {
    name="SWORD",
    type="THING",
    class="WEAPON",
    mass=32,
    icon=gfx.icons[34],
    dungeon=gfx.sword,
	flying_away=gfx.sword_flying_away,
	flying_toward=gfx.sword_flying_toward,
	flying_side=gfx.sword_flying_side,
	methods = {
	    { "SWING", 0, CLASS_FIGHTER, method_physattack },
	    { "PARRY", 1, { CLASS_FIGHTER, SKILL_DEFENSE }, method_physattack },
	    { "CHOP", 2, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack }
	},
	base_range=10,
	base_tpower=34,
	impact=10,
	fit_sheath=true,
	hit_sound=snd.dink
}

obj.sword_cursed = clone_arch(obj.sword, {
    shortdesc="CURSED",
	-- It's cursed! So make the damage less.
	base_tpower=22,
	cursed = true
})

obj.rapier = {
    name="RAPIER",
    type="THING",
    class="WEAPON",
    mass=26,
    icon=gfx.icons[35],
    dungeon=gfx.sword,
	flying_away=gfx.sword_flying_away,
	flying_toward=gfx.sword_flying_toward,
	flying_side=gfx.sword_flying_side,
	methods = {
	    { "JAB", 0, CLASS_FIGHTER, method_physattack },
	    { "PARRY", 0, CLASS_FIGHTER, method_physattack },
	    { "THRUST", 4, { CLASS_FIGHTER, SKILL_STABBING }, method_physattack }
	},

	base_range=10,
	base_tpower=38,
	impact=10,
	fit_sheath=true,
	hit_sound=snd.dink
}

obj.sabre = {
    name="SABRE",
    type="THING",
    class="WEAPON",
    mass=35,
    icon=gfx.icons[36],
    dungeon=gfx.sword,
	flying_away=gfx.sword_flying_away,
	flying_toward=gfx.sword_flying_toward,
	flying_side=gfx.sword_flying_side,
	methods = {
	    { "SLASH", 0, CLASS_NINJA, method_physattack },
	    { "PARRY", 0, CLASS_FIGHTER, method_physattack },
	    { "MELEE", 4, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack }
	},
	base_range=10,
	base_tpower=42,
	base_tpower=1,
	impact=11,
	fit_sheath=true,
	hit_sound=snd.dink
}

-- The CSB biter seems more "unique" than just a sabre, so
-- I'll make it slightly better. For purists, it doesn't
-- actually matter because it only shows up cursed in
-- CSB, and the cursing makes it the same.
obj.biter = clone_arch(obj.sabre, {
    name="BITER",
    icon=gfx.icons[228],
	bonus_power=8
} )

obj.sword_samurai = {
    name="SAMURAI SWORD",
    type="THING",
    class="WEAPON",
    mass=36,
    icon=gfx.icons[37],
    dungeon=gfx.sword,
	flying_away=gfx.sword_flying_away,
	flying_toward=gfx.sword_flying_toward,
	flying_side=gfx.sword_flying_side,
	methods = {
	    { "SLASH", 0, CLASS_NINJA, method_physattack },
	    { "PARRY", 0, CLASS_FIGHTER, method_physattack },
	    { "MELEE", 4, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack }
	},
	base_range=10,
	base_tpower=46,
	impact=12,
	fit_sheath=true,
	hit_sound=snd.dink
}

obj.delta = {
    name="DELTA",
    type="THING",
    class="WEAPON",
    mass=33,
    icon=gfx.icons[38],
    dungeon=gfx.sword,
	flying_away=gfx.sword_flying_away,
	flying_toward=gfx.sword_flying_toward,
	flying_side=gfx.sword_flying_side,
	methods = {
	    { "CHOP", 0, CLASS_FIGHTER, method_physattack },
	    { "MELEE", 4, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack },
	    { "THRUST", 5, { CLASS_FIGHTER, SKILL_STABBING }, method_physattack }
	},
	base_range=10,
	base_tpower=50,
	impact=14,
	fit_sheath=true,
	hit_sound=snd.dink,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 10
}

obj.side_splitter = clone_arch(obj.delta, {
    name="SIDE SPLITTER",
    icon=gfx.icons[229]
} )

obj.diamond_edge = {
    name="DIAMOND EDGE",
    type="THING",
    class="WEAPON",
    mass=37,
    icon=gfx.icons[39],
    dungeon=gfx.sword,
	flying_away=gfx.sword_flying_away,
	flying_toward=gfx.sword_flying_toward,
	flying_side=gfx.sword_flying_side,
	methods = {
	    { "STAB", 0, CLASS_FIGHTER, method_physattack },
	    { "CHOP", 1, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack },
	    { "CLEAVE", 4, { CLASS_FIGHTER, SKILL_SWINGING }, method_physattack }
	},

	base_range=10,
	base_tpower=62,
	impact=14,
	bonus_power=4,
	monster_def_factor=0.75,
	fit_sheath=true,
	hit_sound=snd.dink
}

obj.inquisitor = {
    name="THE INQUISITOR",
    type="THING",
    class="WEAPON",
    mass=39,
    icon=gfx.icons[41],
    dungeon=gfx.sword,
	flying_away=gfx.sword_flying_away,
	flying_toward=gfx.sword_flying_toward,
	flying_side=gfx.sword_flying_side,
	methods = {
	    { "SWING", 0, CLASS_FIGHTER, method_physattack },
	    { "THRUST", 4, { CLASS_FIGHTER, SKILL_STABBING }, method_physattack },
	    { "BERZERK", 6, { CLASS_FIGHTER, SKILL_SWINGING }, method_physattack }
	},
	base_range=10,
	base_tpower=58,
	impact=15,
	fit_sheath=true,
	hit_sound=snd.dink,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 20
}

obj.dragon_fang = clone_arch(obj.inquisitor, {
    name="DRAGON FANG",
    icon=gfx.icons[230]
} )

obj.vorpal = {
    name="VORPAL BLADE",
    type="THING",
    class="WEAPON",
    mass=30,
    icon=gfx.icons[40],
    dungeon=gfx.vorpal,
	methods = {
	    { "JAB", 0, CLASS_FIGHTER, method_physattack },
	    { "CLEAVE", 1, { CLASS_FIGHTER, SKILL_SWINGING }, method_physattack },
	    { "DISRUPT", 3, { CLASS_WIZARD, SKILL_DES }, method_physattack }
	},
	hits_nonmat=true,
	flying_hits_nonmat=true,
	base_range=10,
	base_tpower=48,
	impact=12,
	fit_sheath=true,
	hit_sound=snd.dink,
	to_l_hand = mana_boost,
	to_r_hand = mana_boost,
	from_l_hand = mana_boost_off,
	from_r_hand = mana_boost_off,
	mana_up = 40
}

obj.axe = {
	name="AXE",
	type="THING",
	class="WEAPON",
	mass=43,
	icon=gfx.icons[42],
	dungeon=gfx.axe,
	flying_away=gfx.axe_flying,
	flying_toward=gfx.axe_flying,
	flying_side=gfx.axe_flying_side,		
	methods = {
	    { "SWING", 0, CLASS_FIGHTER, method_physattack },
	    { "CHOP", 0, CLASS_FIGHTER, method_physattack },
	    { "MELEE", 4, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack }
	},
	base_range=10,
	base_tpower=49,
	impact=33,
	fit_sheath=true,
	hit_sound=snd.dink
}

obj.hardcleave = {
	name="HARDCLEAVE",
	type="THING",
	class="WEAPON",
	mass=65,
	icon=gfx.icons[43],
	dungeon=gfx.axe,
	flying_away=gfx.axe_flying,
	flying_toward=gfx.axe_flying,
	flying_side=gfx.axe_flying_side,		
	methods = {
	    { "CHOP", 0, CLASS_FIGHTER, method_physattack },
	    { "CLEAVE", 2, { CLASS_FIGHTER, SKILL_SWINGING }, method_physattack },
	    { "BERZERK", 7, { CLASS_FIGHTER, SKILL_SWINGING }, method_physattack }
	},	
	base_range=10,
	base_tpower=70,
	impact=33,
	bonus_power=8,
	monster_def_factor=0.875,
	fit_sheath=true,
	hit_sound=snd.dink
}

obj.executioner = clone_arch(obj.hardcleave, {
	name="EXECUTIONER",
	icon=gfx.icons[232]
} )

obj.mace = {
	name="MACE",
	type="THING",
	class="WEAPON",
	mass=31,
	icon=gfx.icons[44],
	dungeon=gfx.mace,		
	methods = {
	    { "SWING", 0, CLASS_FIGHTER, method_physattack },
	    { "BASH", 1, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack },
	    { "STUN", 3, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack }
	},	
	base_range=10,
	base_tpower=32,
	impact=10,
	fit_sheath=true,
	hit_sound=snd.dink
}

obj.mace_order = {
	name="MACE OF ORDER",
	type="THING",
	class="WEAPON",
	mass=41,
	icon=gfx.icons[45],
	dungeon=gfx.mace,		
	methods = {
	    { "SWING", 0, CLASS_FIGHTER, method_physattack },
	    { "BASH", 1, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack },
	    { "STUN", 3, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack }
	},
	base_range=10,
	base_tpower=42,
	impact=13,
	fit_sheath=true,
	hit_sound=snd.dink,
	to_l_hand = stat_bonus,
	to_r_hand = stat_bonus,
	from_l_hand = stat_bonus_off,
	from_r_hand = stat_bonus_off,
	stat = STAT_STR,
	stat_up = 50
}

obj.morningstar = {
	name="MORNINGSTAR",
	type="THING",
	class="WEAPON",
	mass=50,
	icon=gfx.icons[46],
	dungeon=gfx.morningstar,		
	methods = {
	    { "SWING", 0, CLASS_FIGHTER, method_physattack },
	    { "STUN", 2, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack },
	    { "MELEE", 5, { CLASS_FIGHTER, SKILL_BASHING }, method_physattack }
	},	
	base_range=10,
	base_tpower=60,
	impact=15,
	fit_sheath=true,
	hit_sound=snd.dink
}

obj.bow = {
    name="BOW",
    type="THING",
    class="SHOOTING",
    mass=10,
    icon=gfx.icons[49],
    dungeon=gfx.bow,
	methods = shoot_method,
    base_shot_power=50,
    base_shot_damage=50,
    base_delta=12,
	min_delta=5,	    
    need_ammo_type=MISSILE_ARROW,
    fit_sheath = true
}

obj.bow_claw = clone_arch(obj.bow, {
    name="CLAW BOW",
    icon=gfx.icons[231]
} )

obj.crossbow = {
    name="CROSSBOW",
    type="THING",
    class="SHOOTING",
    mass=28,
    icon=gfx.icons[50],
    dungeon=gfx.crossbow,
	methods = shoot_method,
	msg_handler=shooting_weapon_msg_handler,
    base_shot_power=120,
    base_shot_damage=180,
    base_delta=14,
	min_delta=5,	    
    need_ammo_type=MISSILE_ARROW,
    fit_sheath = true
}

obj.speedbow = {
    name="SPEEDBOW",
    type="THING",
    class="SHOOTING",
    mass=30,
    icon=gfx.icons[143],
    dungeon=gfx.crossbow,
	methods = shoot_method,
    base_shot_power=125,
    base_shot_damage=225,
    base_delta=10,
	min_delta=4,	    
    need_ammo_type=MISSILE_ARROW,
    fit_sheath = true
}

obj.sling = {
    name="SLING",
    type="THING",
    class="SHOOTING",
    mass=19,
    icon=gfx.icons[53],
    dungeon=gfx.staff_plain,
	methods = shoot_method,
    base_shot_power=20,
    base_shot_damage=50,
    base_delta=10,
	min_delta=6,	    
    need_ammo_type=MISSILE_ROCK,
    fit_sheath = true
}

obj.shield_buckler = {
    name = "BUCKLER",
    type="THING",
    class="SHIELD",
    mass=11,
    icon=gfx.icons[105],
    dungeon=gfx.buckler,
    methods = shield_methods,
    armor_str = 22,
	sharp_resist = 5,
	fit_chest = true
}

obj.shield_neta = clone_arch(obj.shield_buckler, {
    name = "SHIELD OF NETA",
    icon=gfx.icons[241]
} )

obj.shield_hide = {
    name = "HIDE SHIELD",
    type="THING",
    class="SHIELD",
    mass=10,
    icon=gfx.icons[106],
    dungeon=gfx.buckler,
    methods = shield_methods,
    armor_str = 16,
	sharp_resist = 2
}

obj.shield_crystal = {
    name = "CRYSTAL SHIELD",
    type="THING",
    class="SHIELD",
    mass=10,
    icon=gfx.icons[242],
    dungeon=gfx.buckler,
    methods = shield_methods,
    armor_str = 46, -- Tweaked
	sharp_resist = 2
}

obj.shield_small = {
    name = "SMALL SHIELD",
    type="THING",
    class="SHIELD",
    mass=21,
    icon=gfx.icons[107],
    dungeon=gfx.buckler,
    methods = shield_methods,
    armor_str = 35,
	sharp_resist = 4
}

obj.shield_wood = {
    name = "WOODEN SHIELD",
    type="THING",
    class="SHIELD",
    mass=14,
    icon=gfx.icons[108],
    dungeon=gfx.shield,
    methods = shield_methods,
    armor_str = 20,
	sharp_resist = 3
}

obj.shield_large = {
    name = "LARGE SHIELD",
    type="THING",
    class="SHIELD",
    mass=34,
    icon=gfx.icons[109],
    dungeon=gfx.shield,
    methods = shield_methods,
    armor_str = 56,
	sharp_resist = 4
}

obj.shield_sar = clone_arch(obj.shield_large, {
    name = "SAR SHIELD",
    icon=gfx.icons[245],
} )

obj.shield_lyte = {
    name = "SHIELD OF LYTE",
    type="THING",
    class="SHIELD",
    mass=30,
    icon=gfx.icons[110],
    dungeon=gfx.shield,
    methods = shield_methods,
    armor_str = 85,
	sharp_resist = 4
}

obj.shield_ra = clone_arch(obj.shield_lyte, {
    name = "SHIELD OF RA",
    icon=gfx.icons[246]
})

obj.shield_darc = {
    name = "SHIELD OF DARC",
    type="THING",
    class="SHIELD",
    mass=40,
    icon=gfx.icons[111],
    dungeon=gfx.shield,
    methods = shield_methods,
    armor_str = 54,
	sharp_resist = 6
}

obj.shield_dragon = clone_arch(obj.shield_darc, {
    name = "DRAGON SHIELD",
    icon=gfx.icons[247]
})

obj.choker = {
	name="CHOKER",
	type="THING",
	class="NECK",
	mass=1,
	icon=gfx.icons[139],
	dungeon=gfx.choker,
	fit_pouch=true,
	fit_neck=true
}

obj.jewelsymal = {
	name="JEWEL SYMAL",
	type="THING",
	class="NECK",
	mass=2,
	icon=gfx.icons[10],
	alt_icon=gfx.icons[11],
	dungeon=gfx.neck_gold,
	fit_pouch=true,
	fit_neck=true
}

obj.illumulet = {
	name="ILLUMULET",
	type="THING",
	class="NECK",
	mass=2,
	icon=gfx.icons[12],
	alt_icon=gfx.icons[13],
	dungeon=gfx.neck_gold,
	fit_pouch=true,
	fit_neck=true
}

obj.gem_of_ages = {
    name="GEM OF AGES",
    type="THING",
	class="NECK",
    mass=2,
    icon=gfx.icons[120],
    dungeon=gfx.neck_gold,
    fit_pouch=true,
    fit_neck=true
}

obj.ekkhard_cross = {
    name="EKKHARD CROSS",
    type="THING",
	class="NECK",
    mass=3,
    icon=gfx.icons[121],
    dungeon=gfx.neck_gold,
    fit_pouch=true,
    fit_neck=true
}
		
obj.moonstone = {
    name="MOONSTONE",
    type="THING",
	class="NECK",
    mass=2,
    icon=gfx.icons[122],
    dungeon=gfx.neck_silver,
    fit_pouch=true,
    fit_neck=true
}

obj.hellion = {
    name="HELLION",
    type="THING",
	class="NECK",
    mass=2,
    icon=gfx.icons[123],
    dungeon=gfx.neck_black,
    fit_pouch=true,
    fit_neck=true
}

obj.pendant_feral = {
    name="PENDANT FERAL",
    type="THING",
	class="NECK",
    mass=2,
    icon=gfx.icons[124],
    dungeon=gfx.neck_black,
    fit_pouch=true,
    fit_neck=true
}

obj.compass_n = {
    name="COMPASS",
    type="THING",
    text="FACING NORTH",
    class="COMPASS",
    mass=1,
    icon=gfx.icons[0],
    dungeon=gfx.compass,
    fit_pouch=true,
    on_click=comp_fix_facing_pickup,
    on_turn=comp_fix_facing
}

obj.compass_e = clone_arch(obj.compass_n, {
    text="FACING EAST",
    icon=gfx.icons[1]
} )

obj.compass_s = clone_arch(obj.compass_n, {
    text="FACING SOUTH",
    icon=gfx.icons[2]
} )

obj.compass_w = clone_arch(obj.compass_n, {
    text="FACING WEST",
    icon=gfx.icons[3]
} )

obj.key_iron = {
    name="IRON KEY",
	type="THING",
	class="KEY",
	mass=2,
	icon=gfx.icons[176],
	dungeon=gfx.key_metal,
	fit_pouch=true,
	hit_sound=snd.dink,
	shading_info = metal_key_shade
}

obj.key_b = {
    name="KEY OF B",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[177],
	dungeon=gfx.key_metal,
	fit_pouch=true,
	hit_sound=snd.dink,
	shading_info = metal_key_shade
}

obj.key_solid = {
    name="SOLID KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[178],
	dungeon=gfx.key_metal,
	fit_pouch=true,
	hit_sound=snd.dink,
	shading_info = metal_key_shade
}

obj.key_square = {
    name="SQUARE KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[179],
	dungeon=gfx.key_metal,
	fit_pouch=true,
	hit_sound=snd.dink,
	shading_info = metal_key_shade
}

obj.key_tourquoise = {
    name="TOURQUOISE KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[180],
	dungeon=gfx.key_metal,
	fit_pouch=true,
	hit_sound=snd.dink,
	shading_info = metal_key_shade
}

obj.key_cross = {
    name="CROSS KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[181],
	dungeon=gfx.key_metal,
	fit_pouch=true,
	hit_sound=snd.dink,
	shading_info = metal_key_shade
}

obj.key_onyx = {
    name="ONYX KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[182],
	dungeon=gfx.key_metal,
	fit_pouch=true,
	hit_sound=snd.dink,
	shading_info = metal_key_shade
}

obj.key_skeleton = {
    name="SKELETON KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[183],
	dungeon=gfx.key_metal,
	fit_pouch=true,
	hit_sound=snd.dink,
	shading_info = metal_key_shade
}

obj.key_gold = {
    name="GOLD KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[184],
	dungeon=gfx.key_gold,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.key_winged = {
    name="WINGED KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[185],
	dungeon=gfx.key_gold,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.key_topaz = {
    name="TOPAZ KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[186],
	dungeon=gfx.key_gold,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.key_sapphire = {
    name="SAPPHIRE KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[187],
	dungeon=gfx.key_gold,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.key_emerald = {
    name="EMERALD KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[188],
	dungeon=gfx.key_gold,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.key_ruby = {
    name="RUBY KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[189],
	dungeon=gfx.key_gold,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.key_ra = {
    name="RA KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[190],
	dungeon=gfx.key_gold,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.key_master = {
    name="MASTER KEY",
	type="THING",
	class="KEY",
	mass=1,
	icon=gfx.icons[191],
	dungeon=gfx.key_gold,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.gem_blue = {
    name="BLUE GEM",
	type="THING",
	class="GEM",
	mass=2,
	icon=gfx.icons[129],
	dungeon=gfx.gem_blue,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.gem_orange = {
    name="ORANGE GEM",
	type="THING",
	class="GEM",
	mass=3,
	icon=gfx.icons[130],
	dungeon=gfx.gem_orange,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.gem_green = {
    name="GREEN GEM",
	type="THING",
	class="GEM",
	mass=2,
	icon=gfx.icons[131],
	dungeon=gfx.gem_green,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.coin_copper = {
    name="COPPER COIN",
	type="THING",
	class="COIN",
	mass=1,
	icon=gfx.icons[125],
	methods=coin_methods,
	dungeon=gfx.coin_gold,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.coin_silver = {
    name="SILVER COIN",
	type="THING",
	class="COIN",
	mass=1,
	icon=gfx.icons[126],
	methods=coin_methods,
	dungeon=gfx.coin_silver,
	fit_pouch=true,
	hit_sound=snd.dink,
	shading_info = metal_key_shade
}

obj.coin_gold = {
    name="GOLD COIN",
	type="THING",
	class="COIN",
	mass=1,
	icon=gfx.icons[127],
	methods=coin_methods,
	dungeon=gfx.coin_gold,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.coin_gor = {
    name="GOR COIN",
	type="THING",
	class="COIN",
	mass=1,
	icon=gfx.icons[243],
	methods=coin_methods,
	dungeon=gfx.coin_gold,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.coin_sar = {
    name="SAR COIN",
	type="THING",
	class="COIN",
	mass=1,
	icon=gfx.icons[244],
	methods=coin_methods,
	dungeon=gfx.coin_gold,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.waterskin = {
    name="WATERSKIN",
    type="THING",
    class="WATERSKIN",
    shortdesc="EMPTY",
    mass=3,
    icon=gfx.icons[8],
    dungeon=gfx.waterskin_empty,
    fit_pouch=true
}

obj.waterskin_1 = {
    name="WATER",
    type="THING",
    class="WATERSKIN",
    shortdesc="ALMOST EMPTY",
    mass=5,
    icon=gfx.icons[9],
    dungeon=gfx.waterskin_full,
    fit_pouch=true,
    waterval=800,
    on_consume=eatdrink,
    convert_consume="waterskin"
}

obj.waterskin_2 = {
    name="WATER",
    type="THING",
    class="WATERSKIN",
    shortdesc="ALMOST FULL",
    mass=7,
    icon=gfx.icons[9],
    dungeon=gfx.waterskin_full,
    fit_pouch=true,
    waterval=800,
    on_consume=eatdrink,
    convert_consume="waterskin_1"
}

obj.waterskin_full = {
    name="WATER",
    type="THING",
    class="WATERSKIN",
    shortdesc="FULL",
    mass=9,
    icon=gfx.icons[9],
    dungeon=gfx.waterskin_full,
    fit_pouch=true,
    waterval=800,
	on_consume=eatdrink,
    convert_consume="waterskin_2"
}

obj.apple = {
	name="APPLE",
	type="THING",
	shortdesc="CONSUMABLE",
	class="FOOD",
	mass=4,
	icon=gfx.icons[168],
	dungeon=gfx.apple,
	foodval=500,
	fit_pouch = true,		
	on_consume=eatdrink
}

obj.bread = {
	name="BREAD",
	type="THING",
	shortdesc="CONSUMABLE",
	class="FOOD",
	mass=3,
	icon=gfx.icons[170],
	dungeon=gfx.bread,
	foodval=650,
	fit_chest = true,
	on_consume=eatdrink
}

obj.cheese = {
	name="CHEESE",
	type="THING",
	shortdesc="CONSUMABLE",
	class="FOOD",
	mass=8,
	icon=gfx.icons[171],
	dungeon=gfx.cheese,
	foodval=820,
	fit_chest = true,
	on_consume=eatdrink
}

obj.corn = {
	name="CORN",
	type="THING",
	shortdesc="CONSUMABLE",
	class="FOOD",
	mass=4,
	icon=gfx.icons[169],
	dungeon=gfx.corn,
	foodval=600,
	fit_pouch = true,		
	on_consume=eatdrink
}

obj.drumstick = {
    name="DRUMSTICK",
    type="THING",
    shortdesc="CONSUMABLE",
    class="FOOD",
    mass=4,
    icon=gfx.icons[174],
    dungeon=gfx.drumstick,
    foodval=990,
    fit_pouch = true,
    on_consume=eatdrink
}

obj.shank = {
    name="SHANK",
    type="THING",
    shortdesc="CONSUMABLE",
    class="FOOD",
    mass=4,
    icon=gfx.icons[250],
    dungeon=gfx.shank,
    foodval=990,
    fit_pouch = true,
    on_consume=eatdrink
}

obj.s_slice = {
	name="SCREAMER SLICE",
	type="THING",
	shortdesc="CONSUMABLE",
	class="FOOD",
	mass=5,
	icon=gfx.icons[172],
	dungeon=gfx.s_slice,
	foodval=550,
	fit_chest = true,		
	on_consume=eatdrink
}

obj.worm_round = {
    name="WORM ROUND",
    type="THING",
    shortdesc="CONSUMABLE",
    class="FOOD",
    mass=11,
    icon=gfx.icons[173],
    dungeon=gfx.worm_round,
    foodval=350,
    fit_chest = true,
    on_consume=eatdrink
}

obj.d_steak = {
    name="DRAGON STEAK",
	type="THING",
	shortdesc="CONSUMABLE",
	class="FOOD",
	mass=6,
	icon=gfx.icons[175],
	dungeon=gfx.d_steak,
	foodval=1400,
	fit_chest = true,
	on_consume=eatdrink
}

obj.scroll = {
	name="SCROLL",
	type="THING",
	class="SCROLL",
	mass=1,
	icon=gfx.icons[31],
	alt_icon=gfx.icons[30],
	dungeon=gfx.scroll,
	to_r_hand = alticon,
	from_r_hand = normicon,
	fit_pouch = true
}

obj.chest = {
	name="CHEST",
	type="THING",
	class="CONTAINER",
	mass=50,
	icon=gfx.icons[144],
	alt_icon=gfx.icons[145],
	dungeon=gfx.chest,
	inside_gfx=gfx.chest_inside,
	to_r_hand = alticon,
	from_r_hand = normicon,
	subrenderer = basic_8_object_subrenderer,
	capacity = 8
}

obj.lockpicks = {
    name="LOCK PICKS",
	type="THING",
	class="MISC",
	mass=1,
	icon=gfx.icons[192],
	dungeon=gfx.lockpicks,
	fit_pouch=true
}

obj.mirror_of_dawn = {
    name="MIRROR OF DAWN",
	type="THING",
	class="MISC",
	mass=3,
	icon=gfx.icons[134],
	dungeon=gfx.mirror,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.magnifier = {
    name="MAGNIFIER",
	type="THING",
	class="MISC",
	mass=2,
	icon=gfx.icons[193],
	dungeon=gfx.magnifier,
	fit_pouch=true,
	hit_sound=snd.dink
}

obj.boulder = {
	name="BOULDER",
	type="THING",
	class="JUNK",
	mass=81,
	icon=gfx.icons[128],
	dungeon=gfx.boulder,
	impact=30
}

obj.ashes = {
	name="ASHES",
	type="THING",
	class="JUNK",
	mass=4,
	icon=gfx.icons[146],
	dungeon=gfx.ashes,
	useless_thrown=true,
}

obj.stick = {
	name="STICK",
	type="THING",
	class="JUNK",
	mass=8,
	icon=gfx.icons[57],
	dungeon=gfx.stick,
	methods=swing_method,
	fit_sheath = true	
}

obj.corbum = {
	name="CORBUM",
	type="THING",
	class="MISC",
	mass=0,
	icon=gfx.icons[138],
	dungeon=gfx.corbum,
	fit_chest=true,
	max_throw_power = 100
}

obj.rabbits_foot = {
	name="RABBIT'S FOOT",
	type="THING",
	class="MISC",
	mass=1,
	icon=gfx.icons[137],
	dungeon=gfx.rabbits_foot,
	to_anywhere=apply_luck,
	from_anywhere=remove_luck,
	fit_pouch=true,
	go_thru_bars=true
}

obj.mummy = {
    name="MUMMY",
	type="MONSTER",
	class="HUMANOID",
	size=1,
	col=true,
	no_bump=true,
	hp=33,
	front=gfx.mummy_front,
	side=gfx.mummy_side,
	back=gfx.mummy_back,
	attack=gfx.mummy_attack,
	sight=true,
	perception=4,
	awareness=2,
	darkvision=true,
	bravery=9,
	act_rate=17,
	quick_act_rate=9,
	attack_delay=-5,
	shift_rate=19,
	quickness=40,
	base_power=20,
	armor=25,
	anti_fire=20,
	anti_poison=999,
	anti_desew=999,
	xp_factor=4,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_attack_close=monster_attack,
	on_incoming_impact=monster_dodge,
	step_sound=snd.step_footstep,
	attack_sound=snd.monster_haa,
	attack_type=ATTACK_PHYSICAL,
	attack_zonetable=ZT_TORSO_MUMMY,
	attack_show_duration=4,
	hit_height=24,
	death_size=16,
	death_delta=2,
	proj_stick=66
}

obj.screamer = {
    name="SCREAMER",
    type="MONSTER",
    class="EDIBLE",
    size=1,
    col=true,
    no_bump=true,
    stupid=true,
    instant_turn=true,
    hp=165,
    front=gfx.screamer_base,
    side=gfx.screamer_base,
    back=gfx.screamer_base,
    attack=gfx.screamer_attack,
	sight=false,
    perception=1,
    awareness=2,
    bravery=15,
    act_rate=120,
	quick_act_rate=15,
    attack_delay=-110,
	shift_rate=27,
    flip_rate=90,
    quickness=5,
    base_power=5,
    armor=5,
    anti_fire=22,
    anti_poison=64,
    anti_desew=999,
    xp_factor=0,
    msg_handler=monster_msg_handler,
    on_move=monster_step,
    on_die=setup_food_drop,
    on_attack_close=monster_attack,
    on_incoming_impact=monster_dodge,
    step_sound=snd.step_scuffle,
    attack_sound=snd.monster_squeak,
    attack_type=ATTACK_WISDOM,
    attack_from_back=true,
    attack_zonetable=ZT_ATTACK_ANYWHERE,
	food_type="s_slice",
    hit_height=16,
    death_size=16,
    death_delta=2,
    proj_stick=90
}

obj.rockpile = {
    name="ROCK PILE",
    type="MONSTER",
    class="BEAST",
    size=1,
    col=true,
    no_bump=true,
    stupid=true,
    hp=50,
    front=gfx.rockpile_base,
    side=gfx.rockpile_base,
    back=gfx.rockpile_base,
    attack=gfx.rockpile_attack,
    sight=false,
    perception=3,
    awareness=4,
    bravery=12,
    act_rate=185,
	quick_act_rate=15,
    attack_delay=-170,
	shift_rate=50,
    quickness=10,
    base_power=40,
    poison=5,
    armor=170,
    anti_fire=80,
    anti_poison=28,
    anti_desew=999,
    xp_factor=5,
    msg_handler=monster_msg_handler,
    on_move=monster_step,
    on_attack_close=monster_attack,
    on_incoming_impact=monster_dodge,
    on_die=setup_rockpile_drop,  
    step_sound=snd.step_scuffle,
    attack_sound=snd.monster_rockattack,
    attack_type=ATTACK_PIERCING,
    attack_zonetable=ZT_LEGS_OR_FEET_HIGH,
    attack_show_duration=4,
    hit_height=8,
    death_size=16,
    death_delta=2
}

obj.trolin = {
    name="TROLIN",
	type="MONSTER",
	class="HUMANOID",
	group_type=GT_BLUE_CLUB,
	size=1,
	col=true,
	no_bump=true,
	crafty=true,
	hp=20,
	front=gfx.trolin_front,
	side=gfx.trolin_side,
	back=gfx.trolin_back,
	attack=gfx.trolin_attack,
	sight=true,
	perception=3,
	awareness=3,
	bravery=4,
	act_rate=13,
	quick_act_rate=5,
	attack_delay=-5,
	shift_rate=12,
	quickness=41,
	base_power=25,
	armor=28,
	anti_fire=24,
	anti_poison=12,
	anti_desew=999,
	xp_factor=1,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_attack_close=monster_attack,
	on_incoming_impact=monster_dodge,
	on_die=setup_item_drop,
	drop_item_type="club",
	step_sound=snd.step_footstep,
	attack_sound=snd.thud,
	attack_type=ATTACK_PHYSICAL,
	attack_zonetable=ZT_TORSO_LOWER,
	hit_height=24,
	death_size=16,
	death_delta=2,
	proj_stick=50
}

obj.antman = clone_arch(obj.trolin, {
    name="ANT MAN",
	front=gfx.antman_front,
	side=gfx.antman_side,
	back=gfx.antman_back,
	attack=gfx.antman_attack
} )

obj.worm = {
    name="WORM",
	type="MONSTER",
	class="EDIBLE",
	group_type=GT_WORMS,
	size=2,
	col=true,
	no_bump=true,
	hp=70,
	front=gfx.worm_front,
	side=gfx.worm_side,
	back=gfx.worm_back,
	attack=gfx.worm_attack,
	sight=false,
	perception=1,
	awareness=8,
	bravery=10,
	act_rate=18,
	quick_act_rate=5,
	attack_delay=1,
	shift_rate=9,
	flip_rate=39,
	quickness=35,
	base_power=45,
	poison=35,
	armor=72,
	anti_fire=40,
	anti_poison=52,
	anti_desew=999,
	xp_factor=5,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_die=setup_food_drop,
	on_attack_close=monster_attack,
	on_incoming_impact=monster_dodge,
	step_sound=snd.step_scuffle,
	attack_sound=snd.monster_wormgrowl,
	attack_type=ATTACK_PIERCING,
	attack_zonetable=ZT_FEET,
	food_type="worm_round",
	max_food=3,
	hit_height=8,
	death_size=24,
	death_delta=3,
	proj_stick=50
}

obj.worm2b = clone_arch(obj.worm, {
    name="ARMOURED WORM",
	front=gfx.worm2b_front,
	side=gfx.worm2b_side,
	back=gfx.worm2b_back,
	attack=gfx.worm2b_attack
} )

obj.worm2y = clone_arch(obj.worm, {
    name="ARMOURED WORM",
	front=gfx.worm2y_front,
	side=gfx.worm2y_side,
	back=gfx.worm2y_back,
	attack=gfx.worm2y_attack
} )

obj.wasp = {
    name="WASP",
    type="MONSTER",
    class="FLYING",
    group_type=GT_FAST_FLYERS,
    size=1,
    col=true,
    no_bump=true,
    hover=true,
    no_stopclicks=true,
    crafty=true,
    swarmy=true,
    hp=8,
    front=gfx.wasp_front,
    side=gfx.wasp_side,
    back=gfx.wasp_back,
    attack=gfx.wasp_attack,
    sight=true,
    perception=2,
    awareness=4,
    bravery=15,
    act_rate=2,
	quick_act_rate=2,
    attack_delay=12,
	shift_rate=9,
    flip_rate=3,
    quickness=150,
    base_power=20,
    poison=10,
    armor=180,
    anti_fire=8,
    anti_poison=4,
    anti_desew=999,
    xp_factor=9,
    msg_handler=monster_msg_handler,
    on_move=monster_step,
    on_attack_close=monster_attack,
    on_incoming_impact=monster_dodge,
    step_sound=snd.step_flying,
    attack_type=ATTACK_PIERCING,
    attack_zonetable=ZT_HEAD,
    hit_height=24,
    death_size=16,
    death_delta=2,
    proj_stick=10
}

obj.muncher = clone_arch(obj.wasp, {
    name="MUNCHER",
    front=gfx.muncher_front,
    side=gfx.muncher_side,
    back=gfx.muncher_back,
    attack=gfx.muncher_attack
} )

obj.ghost = {
    name="GHOST",
    type="MONSTER",
    class="NONMAT",
    group_type=GT_NONMATS,
    size=1,
    col=nonmat_col,
    no_bump=true,
    nonmat=true,
    hover=true,
    no_stopclicks=true,
    instant_turn=true,
    hp=30,
    front=gfx.ghost_base,
    side=gfx.ghost_base,
    back=gfx.ghost_base,
    attack=gfx.ghost_attack,
    sight=true,
    perception=3,
    awareness=4,
    darkvision=true,
    bravery=6,
    act_rate=11,
	quick_act_rate=5,
    attack_delay=5,
	shift_rate=7,
    flip_rate=4,
    quickness=80,
    base_power=55,
    armor=15,
	anti_desew=52,
    anti_fire=360,
    anti_poison=999,
    xp_factor=6,
    msg_handler=monster_msg_handler,
    on_move=monster_step,
    on_attack_close=monster_attack,
    on_incoming_impact=monster_dodge,
    attack_sound=snd.monster_haa,
    attack_type=ATTACK_WISDOM,
    attack_zonetable=ZT_TORSO_GHOST,
    attack_show_duration=4,
    death_size=16,
    death_delta=2
}

obj.rive = clone_arch(obj.ghost, {
    name="RIVE",
    front=gfx.rive_base,
    side=gfx.rive_base,
    back=gfx.rive_base,
    attack=gfx.rive_attack
} )

obj.swampslime = {
    name="SWAMP SLIME",
    type="MONSTER",
    class="SLIME",
    group_type=GT_SLIMES,
    size=1,
    col=true,
    no_bump=true,
    stupid=true,
    hp=110,
    front=gfx.swampslime_base,
    side=gfx.swampslime_base,
    back=gfx.swampslime_base,
    attack=gfx.swampslime_attack,
    sight=true,
    perception=2,
    awareness=2,
	attack_range=2,
    bravery=10,
    act_rate=15,
	quick_act_rate=8,
    attack_delay=17,
	shift_rate=14,
    flip_rate=19,
    quickness=20,
    base_power=80,
    armor=20,
    anti_fire=32,
    anti_poison=256,
    anti_desew=999,
    xp_factor=3,
    msg_handler=monster_msg_handler,
    on_move=monster_step,
    on_attack_close=monster_attack,
	on_attack_ranged=monster_missile,
	should_attack_ranged=halfranged,
	on_incoming_impact=monster_dodge,
    step_sound=snd.step_wet,
    attack_type=ATTACK_PHYSICAL,
    attack_zonetable=ZT_TORSO_FEET_HITTABLE,
    attack_show_duration=4,
    prefer_ranged=true,
	missile_type="poison_slime",
	missile_power=45,
	missile_damage=20,
	hit_height=16,
    death_size=24,
    death_delta=3,
    proj_stick=75
}

obj.slimedevil = clone_arch(obj.swampslime, {
    name="SLIME DEVIL",
    front=gfx.slimedevil_base,
    side=gfx.slimedevil_base,
    back=gfx.slimedevil_base,
    attack=gfx.slimedevil_attack
} )

obj.couatl = {
    name="COUATL",
    type="MONSTER",
    class="FLYING",
    size=4,
    col=true,
    no_bump=true,
    hover=true,
    no_stopclicks=true,
    smart=true,
    swarmy=true,
    pounces=true,
    pounce_eagerness=70,
    hp=39,
    front=gfx.couatl_front,
    side=gfx.couatl_side,
    back=gfx.couatl_back,
    attack=gfx.couatl_attack,
    sight=true,
    perception=3,
    awareness=3,
    darkvision=true,
    bravery=3,
    act_rate=5,
	quick_act_rate=2,
    attack_delay=5,
	shift_rate=3,
    flip_rate=4,
    quickness=88,
    base_power=90,
    poison=90,
    armor=42,
    anti_fire=26,
    anti_poison=28,
    anti_desew=999,
    xp_factor=7,
    msg_handler=monster_msg_handler,
    on_move=monster_step,
    on_attack_close=monster_attack,
    on_incoming_impact=monster_dodge,
    step_sound=snd.step_flying,
    attack_type=ATTACK_PIERCING,
    attack_zonetable=ZT_TORSO,
    attack_sound=snd.monster_screech,
    hit_height=24,
    death_size=48,
    death_delta=6,
    proj_stick=45
}

obj.wizardeye = {
    name="WIZARD EYE",
    type="MONSTER",
    class="FLYING",
    group_type=GT_FLYING_EYES,
    size=1,
    col=true,
    no_bump=true,
    hover=true,
    no_stopclicks=true,
    crafty=true,
    instant_turn=true,
    hp=40,
    front=gfx.wizardeye_base,
    side=gfx.wizardeye_base,
    back=gfx.wizardeye_base,
    attack=gfx.wizardeye_attack,
    sight=true,
    perception=8,
    awareness=2,
    bravery=10,
    act_rate=10,
	quick_act_rate=2,
    attack_delay=11,
	shift_rate=3,
    flip_rate=11,
    quickness=80,
    base_power=58,
    armor=30,
    anti_fire=26,
    anti_poison=64,
    anti_desew=999,
    xp_factor=6,
    msg_handler=monster_msg_handler,
    on_move=monster_step,
    on_attack_close=monster_attack,
	on_attack_ranged=monster_missile,
	should_attack_ranged=halfranged,
	prefer_ranged=true,
	attack_type=ATTACK_ANTI_MAGIC,
	attack_zonetable=ZT_HEAD_OR_TORSO_HIGH,
	missile_type="lightning",
	missile_power=48,
	missile_damage=80,
	door_opener="zospell",
	on_incoming_impact=monster_dodge,
	on_shot_missile_impact=zo_success_check,
    hit_height=24,
    death_size=32,
    death_delta=4,
    proj_stick=32
}

obj.gazer = clone_arch(obj.wizardeye, {
    name="GAZER",
    front=gfx.gazer_base,
    side=gfx.gazer_base,
    back=gfx.gazer_base,
    attack=gfx.gazer_attack
} )

obj.skeleton = {
    name="SKELETON",
	type="MONSTER",
	class="HUMANOID",
	size=1,
	col=true,
	no_bump=true,
	hp=20,
	front=gfx.skeleton_front,
	side=gfx.skeleton_side,
	back=gfx.skeleton_back,
	attack=gfx.skeleton_attack,
	sight=true,
	perception=3,
	awareness=1,
	darkvision=true,
	bravery=9,
	act_rate=7,
	quick_act_rate=3,
	shift_rate=6,
	quickness=80,
	base_power=22,
	armor=22,
	anti_fire=32,
	anti_poison=999,
	anti_desew=999,
	xp_factor=1,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_die=setup_item_drop,
	drop_item_type={ "falchion", "shield_wood" },
	on_attack_close=monster_attack,
	on_incoming_impact=monster_dodge,
	step_sound=snd.step_skeleton,
	attack_sound=snd.swish,
	attack_type=ATTACK_PIERCING,
	attack_zonetable=ZT_TORSO,
	hit_height=24,
	death_size=16,
	death_delta=2
}

obj.golem = {
    name="STONE GOLEM",
	type="MONSTER",
	class="HUMANOID",
	size=4,
	col=true,
	no_bump=true,
	hp=120,
	front=gfx.golem_front,
	side=gfx.golem_side,
	back=gfx.golem_back,
	attack=gfx.golem_attack,
	sight=true,
	perception=3,
	awareness=1,
	bravery=15,
	act_rate=21,
	quick_act_rate=15,
	attack_delay=-7,
	quickness=35,
	base_power=219,
	armor=240,
	anti_fire=768,
	anti_poison=999,
	anti_desew=999,
	xp_factor=11,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_attack_close=monster_attack,
	on_incoming_impact=monster_dodge,
	on_die=setup_item_drop,
	drop_item_type="club_stone",
	step_sound=snd.step_footstep,
	attack_sound=snd.thud,
	attack_type=ATTACK_PHYSICAL,
	attack_zonetable=ZT_HEAD_OR_TORSO_LOW,
	hit_height=24,
	death_size=48,
	death_delta=6
}

obj.giggler = {
    name="GIGGLER",
    type="MONSTER",
    class="BEAST",
    size=1,
    col=true,
    no_bump=true,
    no_group=true,
    crafty=true,
    paranoid=true,
    hp=12,
    front=gfx.giggler_front,
    side=gfx.giggler_side,
    back=gfx.giggler_back,
    sight=true,
    perception=6,
    awareness=3,
    bravery=1,
    act_rate=3,
	quick_act_rate=3,
    attack_delay=2,
	shift_rate=3,
    flip_rate=7,
    quickness=110,
    base_power=10,
    armor=50,
    anti_fire=8,
    anti_poison=32,
    anti_desew=999,
    xp_factor=1,
    msg_handler=monster_msg_handler,
    on_move=monster_step,
    on_attack_close=monster_attack,
    on_incoming_impact=monster_dodge,
    step_sound=snd.step_footstep,
    attack_sound=snd.monster_oowooah,
    attack_type=ATTACK_STEAL,
    hit_height=8,
    death_size=16,
    death_delta=2,
    proj_stick=70
}

obj.rat = {
    name="PAIN RAT",
	type="MONSTER",
	class="EDIBLE",
	group_type=GT_RABID_BEASTS,
	size=2,
	col=true,
	no_bump=true,
	hp=101,
	front=gfx.rat_front,
	side=gfx.rat_side,
	back=gfx.rat_back,
	attack=gfx.rat_attack,
	sight=true,
	perception=4,
	awareness=5,
	bravery=15,
	act_rate=9,
	quick_act_rate=4,
	attack_delay=-1,
	shift_rate=7,
	flip_rate=16,
	quickness=65,
	base_power=90,
	armor=45,
	anti_fire=42,
	anti_poison=78,
	anti_desew=999,
	xp_factor=8,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_die=setup_food_drop,
	on_attack_close=monster_attack,
	on_incoming_impact=monster_dodge,
	step_sound=snd.step_scuffle,
	attack_sound=snd.monster_roar,
	attack_type=ATTACK_PIERCING,
	attack_zonetable=ZT_LEGS_OR_FEET_LOW,
	food_type="drumstick",
	hit_height=8,
	death_size=24,
	death_delta=3,
	proj_stick=50
}

obj.hellhound = clone_arch(obj.rat, {
    name="HELL HOUND",
	front=gfx.hellhound_front,
	side=gfx.hellhound_side,
	back=gfx.hellhound_back,
	attack=gfx.hellhound_attack,
	food_type="shank"
} )

obj.vexirk = {
    name="VEXIRK",
	type="MONSTER",
	class="HUMANOID",
	group_type=GT_WIZARDS,
	size=1,
	col=true,
	no_bump=true,
	smart=true,
	crafty=true,
	hover=true,
	hp=33,
	front=gfx.vexirk_front,
	side=gfx.vexirk_side,
	back=gfx.vexirk_back,
	attack=gfx.vexirk_attack,
	sight=true,
	perception=5,
	awareness=3,
	attack_range=4,
	bravery=5,
	act_rate=10,
	quick_act_rate=6,
	attack_delay=10,
	shift_rate=26,
	quickness=90,
	base_power=75,
	armor=47,
	anti_fire=32,
	anti_poison=18,
	anti_desew=999,
	xp_factor=9,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_attack_close=monster_attack,
	on_attack_ranged=monster_missile,
	should_attack_ranged=threefourthsranged,
	prefer_ranged=true,
	attack_type=ATTACK_ANTI_MAGIC,
	attack_zonetable=ZT_LEGS,
	attack_show_duration=4,
	missile_type=vexirk_missiles,
	door_opener="zospell",
	missile_power=56,
	missile_damage=90,
	on_incoming_impact=monster_dodge,
	on_shot_missile_impact=zo_success_check,
	step_sound=snd.step_footstep,
	hit_height=16,
	death_size=16,
	death_delta=2,
	proj_stick=35
}

obj.vexirk2 = clone_arch(obj.vexirk, {
    name="MON VEXIRK",
	front=gfx.vexirk2_front,
	side=gfx.vexirk2_side,
	back=gfx.vexirk2_back,
	attack=gfx.vexirk2_attack
} )

obj.ruster = {
    name="RUSTER",
	type="MONSTER",
	class="BEAST",
	size=2,
	col=true,
	no_bump=true,
	stupid=true,
	hp=60,
	front=gfx.ruster_front,
	side=gfx.ruster_side,
	back=gfx.ruster_back,
	sight=true,
	perception=2,
	awareness=2,
	bravery=3,
	act_rate=20,
	quick_act_rate=6,
	attack_delay=-2,
	shift_rate=11,
	flip_rate=24,
	quickness=30,
	base_power=30,
	armor=100,
	anti_fire=48,
	anti_poison=28,
	anti_desew=999,
	xp_factor=3,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_attack_close=monster_attack,
	on_incoming_impact=monster_dodge,
	step_sound=snd.step_scuffle,
	attack_type=ATTACK_PHYSICAL,
	attack_zonetable=ZT_FEET_RUSTER,
	hit_height=8,
	death_size=24,
	death_delta=3,
	proj_stick=50
}

obj.scorpion = {
    name="SCORPION",
	type="MONSTER",
	class="BEAST",
	size=4,
	col=true,
	no_bump=true,
	crafty=true,
	hp=150,
	front=gfx.scorpion_front,
	side=gfx.scorpion_side,
	back=gfx.scorpion_back,
	attack=gfx.scorpion_attack,
	sight=true,
	perception=3,
	awareness=1,
	bravery=9,
	act_rate=8,
	quick_act_rate=3,
	attack_delay=12,
	shift_rate=9,
	flip_rate=13,
	quickness=55,
	base_power=150,
	poison=240,
	armor=55,
	anti_fire=52,
	anti_poison=48,
	anti_desew=999,
	xp_factor=9,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_attack_close=monster_attack,
	on_incoming_impact=monster_dodge,
	step_sound=snd.step_scuffle,
	attack_sound=snd.monster_snarl,
	attack_type=ATTACK_PIERCING,
	attack_zonetable=ZT_TORSO_SCORPION,
	attack_show_duration=4,
	hit_height=16,
	death_size=64,
	death_delta=4,
	proj_stick=60
}

obj.waterelem = {
    name="WATER ELEMENTAL",
    type="MONSTER",
    class="NONMAT",
    size=4,
    col=nonmat_col,
    no_bump=true,
    nonmat=true,
    instant_turn=true,
    hp=144,
    front=gfx.waterelem_base,
    side=gfx.waterelem_base,
    back=gfx.waterelem_base,
    attack=gfx.waterelem_attack,
    sight=false,
    perception=2,
    awareness=2,
    darkvision=true,
    bravery=7,
    act_rate=25,
	quick_act_rate=7,
	shift_rate=32,
    quickness=50,
    base_power=66,
    armor=75,
	anti_desew=36,
    anti_fire=999,
    anti_poison=128,
    xp_factor=6,
    msg_handler=monster_msg_handler,
    on_move=monster_step,
    on_attack_close=monster_attack,
    on_incoming_impact=monster_dodge,
    step_sound=snd.step_wet,
    attack_sound=snd.monster_wetattack,
    attack_type=ATTACK_PHYSICAL,
    attack_zonetable=ZT_LEGS_OR_FEET_HIGH,
    attack_show_duration=5,
    death_size=32,
    death_delta=2
}

obj.knight_armour = {
    name="ANIMATED ARMOUR",
	type="MONSTER",
	class="HUMANOID",
	group_type=GT_KNIGHTS,
	size=1,
	col=true,
	no_bump=true,
	smart=true,
	counterattack=true,
	hp=60,
	front=gfx.knight_armour_front,
	side=gfx.knight_armour_side,
	back=gfx.knight_armour_back,
	attack=gfx.knight_armour_attack,
	sight=true,
	perception=5,
	awareness=2,
	bravery=15,
	act_rate=14,
	quick_act_rate=5,
	attack_delay=-7,
	shift_rate=11,
	flip_rate=15,
	quickness=70,
	base_power=105,
	armor=140,
	anti_fire=999,
	anti_poison=999,
	anti_desew=999,
	xp_factor=10,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_die=setup_knight_drop,
	on_attack_close=monster_attack,
	on_incoming_impact=monster_dodge,
	step_sound=snd.step_knight,
	attack_sound=snd.swish,
	attack_type=ATTACK_PIERCING,
	attack_zonetable=ZT_TORSO,
	hit_height=24,
	death_size=16,
	death_delta=2
}

obj.knight_deth = clone_arch(obj.knight_armour, {
    name="DETH KNIGHT",
	front=gfx.knight_deth_front,
	side=gfx.knight_deth_side,
	back=gfx.knight_deth_back,
	attack=gfx.knight_deth_attack
} )

obj.oitu = {
    name="OITU",
	type="MONSTER",
	class="BEAST",
	size=4,
	col=true,
	no_bump=true,
	crafty=true,
	hp=77,
	front=gfx.oitu_front,
	side=gfx.oitu_side,
	back=gfx.oitu_back,
	attack=gfx.oitu_attack,
	sight=true,
	perception=2,
	awareness=5,
	bravery=6,
	act_rate=15,
	quick_act_rate=4,
	attack_delay=16,
	shift_rate=11,
	flip_rate=11,
	quickness=60,
	base_power=130,
	armor=33,
	anti_fire=32,
	anti_poison=48,
	anti_desew=999,
	xp_factor=9,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_attack_close=monster_attack,
	on_incoming_impact=monster_dodge,
	step_sound=snd.step_scuffle,
	attack_sound=snd.monster_squeak,
	attack_type=ATTACK_PIERCING,
	attack_zonetable=ZT_TORSO_LOWER,
	attack_show_duration=4,
	hit_height=16,
	death_size=64,
	death_delta=4
}

obj.oitu2 = clone_arch(obj.oitu, {
    name="GREATER OITU",
	front=gfx.oitu2_front,
	side=gfx.oitu2_side,
	back=gfx.oitu2_back,
	attack=gfx.oitu2_attack
} )

obj.materializer = {
    name="MATERIALIZER",
	type="MONSTER",
	class="NONMAT",
	group_type=GT_NONMAT_SPELLCASTERS,
	size=1,
	col=nonmat_col,
	no_bump=true,
	nonmat=true,
	hover=true,
	no_stopclicks=true,
	materializing=true,
	smart=true,
	crafty=true,
	hp=33,
	front=gfx.materializer_front,
	side=gfx.materializer_side,
	back=gfx.materializer_back,
	attack=gfx.materializer_attack,
	sight=false,
	perception=8,
	awareness=2,
	bravery=7,
	act_rate=5,
	quick_act_rate=5,
	attack_delay=13,
	shift_rate=9,
	flip_rate=4,
	quickness=65,
	base_power=61,
	armor=45,
	anti_fire=128,
	anti_poison=999,
	anti_desew=16,
	xp_factor=12,
	msg_handler=monster_msg_handler,
	on_attack_close=monster_attack,
	on_attack_ranged=monster_missile,
	should_attack_ranged=halfranged,
	prefer_ranged=true,
	attack_type=ATTACK_ANTI_MAGIC,
	attack_zonetable=ZT_TORSO_ZYTAZ,
	attack_show_duration=7,
	missile_type=materializer_missiles,
	missile_power=40,
	missile_damage=60,
	on_incoming_impact=monster_dodge,
	death_size=24,
	death_delta=3,
	proj_stick=60
}

obj.zytaz = clone_arch(obj.materializer, {
    name="ZYTAZ",
	front=gfx.zytaz_front,
	side=gfx.zytaz_side,
	back=gfx.zytaz_back,
	attack=gfx.zytaz_attack
} )

obj.blackflame = {
    name="BLACK FLAME",
	type="MONSTER",
	class="NONMAT",
	size=4,
	col=nonmat_col,
	no_bump=true,
	nonmat=true,
	stupid=true,
	instant_turn=true,
	absorbs="fireball",
	hp=80,
	front=gfx.blackflame_base,
	side=gfx.blackflame_base,
	back=gfx.blackflame_base,
	attack=gfx.blackflame_attack,
	sight=false,
	immobile=true,
	perception=3,
	awareness=3,
	darkvision=true,
	bravery=15,
	act_rate=10,
	quick_act_rate=8,
	flip_rate=3,
	quickness=60,
	base_power=105,
	armor=45,
	anti_fire=999,
	anti_poison=999,
	anti_desew=64,
	xp_factor=5,
	msg_handler=monster_msg_handler,
	on_attack_close=monster_attack,
	on_absorb=eat_fireball_for_hp,
	attack_type=ATTACK_ANTI_FIRE,
	attack_zonetable=ZT_FEET_OR_LEGS,
	attack_show_duration=4,
	death_size=48,
	death_delta=6
}

obj.demon = {
    name="DEMON",
	type="MONSTER",
	class="BEAST",
	group_type=GT_DEMONS,
	size=1,
	col=true,
	no_bump=true,
	smart=true,
	hp=100,
	front=gfx.demon_front,
	side=gfx.demon_side,
	back=gfx.demon_back,
	attack=gfx.demon_attack,
	sight=true,
	perception=4,
	awareness=3,
	attack_range=3, -- In DM, this is 4. But their fireballs can't usually go 4 squares...
	darkvision=true,
	bravery=15,
	act_rate=10,
	quick_act_rate=6,
	attack_delay=4,
	shift_rate=12,
	flip_rate=9,
	quickness=75,
	base_power=100,
	armor=68,
	anti_fire=32,
	anti_poison=78,
	anti_desew=999,
	xp_factor=13,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_attack_close=monster_attack,
	on_attack_ranged=monster_missile,
	should_attack_ranged=halfranged,
	missile_type="fireball",
	missile_power=56,
	missile_damage=75,
	on_incoming_impact=monster_dodge,
	step_sound=snd.step_footstep,
	attack_sound=snd.monster_haa,
	attack_type=ATTACK_PHYSICAL,
	attack_zonetable=ZT_HEAD_OR_TORSO_LOW,
	attack_show_duration=4,
	hit_height=24,
	death_size=24,
	death_delta=4,
	proj_stick=40
}

obj.demon2 = clone_arch(obj.demon, {
    name="VIPER DEMON",
	front=gfx.demon2_front,
	side=gfx.demon2_side,
	back=gfx.demon2_back,
	attack=gfx.demon2_attack
} )

obj.dragon = {
    name="RED DRAGON",
	type="MONSTER",
	class="EDIBLE",
	size=4,
	col=true,
	no_bump=true,
	crafty=true,
	counterattack=true,
	hp=255,
	front=gfx.dragon_front,
	side=gfx.dragon_side,
	back=gfx.dragon_back,
	attack=gfx.dragon_attack,
	sight=true,
	perception=5,
	awareness=5,
	bravery=7,
	act_rate=14,
	quick_act_rate=8,
	attack_delay=14,
	shift_rate=17,
	flip_rate=13,
	quickness=70,
	base_power=255,
	armor=110,
	anti_fire=68,
	anti_poison=32,
	anti_desew=999,
	xp_factor=15,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_die=setup_food_drop,
	on_attack_close=monster_attack,
	on_attack_ranged=monster_missile,
	should_attack_ranged=halfranged,
	missile_type="fireball",
	door_breaker="fireball",
	missile_power=150,
	missile_damage=70,
	on_incoming_impact=monster_dodge,
	step_sound=snd.step_dragon,
	attack_sound=snd.monster_roar,
	attack_type=ATTACK_PIERCING,
	attack_zonetable=ZT_TORSO_LOWER,
	food_type="d_steak",
	min_food=8,
	max_food=10,
	hit_height=24,
	death_size=64,
	death_delta=4,
	proj_stick=60
}

obj.lordchaos = {
    name="LORD CHAOS",
	type="MONSTER",
	class="CHAOS",
	size=4,
	col=true,
	no_bump=true,
	smart=true,
	crafty=true,
	hp=1,
	front=gfx.lordchaos_front,
	side=gfx.lordchaos_side,
	back=gfx.lordchaos_back,
	attack=gfx.lordchaos_attack,
	sight=true,
	hover=true,
	perception=8,
	awareness=3,
	attack_range=6,
	darkvision=true,
	bravery=3,
	act_rate=12,
	quick_act_rate=5,
	attack_delay=10,
	shift_rate=26,
	quickness=130,
	base_power=210,
	armor=999,
	anti_fire=999,
	anti_poison=999,
	anti_desew=999,
	xp_factor=15,
	msg_handler=monster_msg_handler,
	on_move=monster_step,
	on_attack_close=monster_attack,
	on_attack_ranged=monster_missile,
	should_attack_ranged=threefourthsranged,
	prefer_ranged=true,
	attack_type=ATTACK_ANTI_MAGIC,
	attack_zonetable=ZT_TORSO_FEET_HITTABLE,
	missile_type=vexirk_missiles,
	door_opener="zospell",
	door_breaker="fireball",
	on_shot_missile_impact=zo_success_check,
	missile_power=120,
	missile_damage=130,
	hit_height=24,
	death_size=64,
	death_delta=4,
	escape=chaos_teleport,
	no_freeze=true,
	sees_invisible=true
}

obj.lordorder = {
	name="LORD ORDER",
	type="MONSTER",
	class="USELESS",
	front=gfx.lordorder,
	side=gfx.lordorder,
	back=gfx.lordorder,
	attack=gfx.lordorder,
	size=4,
	col=true,
	no_bump=true,
	oblivious=true,
	immobile=true,
	hp=1,
	perception=1,
	bravery=15,
	act_rate=1000,
	quick_act_rate=1000,
	shift_rate=20,
	armor=999,
	anti_fire=999,
	anti_poison=999,
	anti_desew=999,
	no_freeze=true
}

obj.greylord = clone_arch(obj.lordorder, {
	name="GREY LORD",
	front=gfx.greylord,
	side=gfx.greylord,
	back=gfx.greylord,
	attack=gfx.greylord
})

function obj.bones:namechanger(id, who_look)
	if (exvar[id] and exvar[id].owner) then
		return dsb_get_charname(exvar[id].owner) .. " " .. self.name
	else
		return nil
	end
end

function obj.bones:on_click(id)
	if (exvar[id] and exvar[id].in_altar) then
		return true
	else
		return nil
	end
end

function obj.flask_bro:potion_effect(id, who, base_power)
	local cure
	if (base_power >= 240) then
		-- A mon bro potion will cure anything
		cure = 9999
	else
		cure = base_power * 2
	end	
	if (self.ignore_power) then cure = 9999 end
	
	local poi = dsb_get_condition(who, C_POISON)
	if (poi) then
		poi = poi - cure
		set_poison(who, poi)
	end
end

function obj.flask_dane:potion_effect(id, who, base_power)
	stat_booster(who, STAT_WIS, base_power)
end 

function obj.flask_ee:potion_effect(id, who, base_power)
	local m_power = 10*base_power / 25
	local mana = dsb_get_bar(who, MANA)
	local manamax = dsb_get_maxbar(who, MANA)
	local mana_up = mana + 2*m_power + 80
	if (mana_up > manamax) then
		mana_up = mana + m_power + 40
		if (mana_up < manamax) then mana_up = manamax end
	end
	dsb_set_bar(who, MANA, mana_up)
end

-- Ku potions don't use the standard stat_booster() because
-- they boost strength less than the others boost their stat
function obj.flask_ku:potion_effect(id, who, base_power)
	local boost = 10*base_power/35 + 50
	local st = dsb_get_stat(who, STAT_STR)
	local mst = dsb_get_maxstat(who, STAT_STR)
	
	-- Very big boosts are not as effective
	if (mst > 0 and (st > mst*2)) then
		local over = st/mst
		boost = math.floor(boost * (2/over))
		if (boost < 10) then boost = 10 end
	end
	
	dsb_set_stat(who, STAT_STR, st + boost)
end 

function obj.flask_mon:potion_effect(id, who, base_power)
	local s_power = (base_power+1)/8 + 32
	local stam_divide = (511 - base_power) / (2 * s_power)
	local maxstamina = dsb_get_maxbar(who, STAMINA)
	local stamina = dsb_get_bar(who, STAMINA)
	local adj_stamina = maxstamina/stam_divide
	stamina = stamina + adj_stamina
	if (stamina > maxstamina) then stamina = maxstamina end
	dsb_set_bar(who, STAMINA, stamina)
end 

function obj.flask_neta:potion_effect(id, who, base_power)
	stat_booster(who, STAT_VIT, base_power)
end 

function obj.flask_ros:potion_effect(id, who, base_power)
	stat_booster(who, STAT_DEX, base_power)
end 

function obj.flask_vi:potion_effect(id, who, base_power)
	local s_power = (base_power+1)/8 + 32
	local heal_divide = (511 - base_power) / (2 * s_power)
	local maxhp = dsb_get_maxbar(who, HEALTH)
	local gain_hp = maxhp / heal_divide
	local hp = dsb_get_bar(who, HEALTH) + gain_hp
	if (hp > maxhp) then hp = maxhp end
	
	local i_heal = base_power/42
	if (i_heal < 1) then i_heal = 1 end
	i_heal = i_heal * 9
	local c
	for c=0,i_heal do
		local inj_loc = random_body_loc()
		local inj = dsb_get_injury(who, inj_loc)
		if (inj) then
		    local ipower = s_power/4
		    if (ipower > 45) then ipower = 45 end
		    
			inj = inj - ipower
			
			if (inj <= 0) then
				dsb_set_injury(who, inj_loc, 0)
			else
				dsb_set_injury(who, inj_loc, inj)
			end
		end
	end
	
	dsb_set_bar(who, HEALTH, hp)	
end

function obj.flask_ya:potion_effect(id, who, base_power)
	local sh_power = base_power/25 + base_power/50 + 12
	
	magic_shield(who, C_SPELLSHIELD, sh_power, sh_power * sh_power)
end

function obj.chest:objzone_check(id, putting_in, zone)
	if (putting_in) then
		local in_arch = dsb_find_arch(putting_in)
		if (in_arch.fit_pouch or in_arch.fit_chest) then
			return true
		end
	end
	
	return false
end

function obj.scroll:subrenderer(id)
	local sr = dsb_subrenderer_target()
	dsb_bitmap_draw(gfx.scroll_inside, sr, 0, 0, false)
	
	if (exvar[id] and exvar[id].text) then
		local lines, num_lines = dsb_linesplit(exvar[id].text, "/")
		local y_base = 72 - (num_lines*7) + (num_lines % 2)
		local i
		
		for i=1,num_lines do
		    dsb_bitmap_textout(sr, gfx.scroll_font, lines[i],
				124, y_base+((i-1)*14), CENTER, scroll_color)
		end
	end
end

function obj.mirror:on_click(id, clicked_with)
	if (clicked_with == nil and exvar[id]) then
		local inside = exvar[id].champion
		if (inside) then
			local offer_mode = 3
			if (exvar[id].offer_mode) then
				offer_mode = exvar[id].offer_mode
			end
			dsb_offer_champion(inside, offer_mode, function ()
				exvar[id].champion = nil
				got_triggered(id, nil)
			end)
		end
	end
end

function obj.boots_elven:to_feet(id, who)
	change_ch_exvar(who, "load_bonus", 1)
end

function obj.boots_elven:from_feet(id, who)
	change_ch_exvar(who, "load_bonus", -1)
end

function obj.boots_speed:to_feet(id, who)
	change_ch_exvar(who, "speed_bonus", 1)
end

function obj.boots_speed:from_feet(id, who)
	change_ch_exvar(who, "speed_bonus", -1)
end

function obj.jewelsymal:to_neck(id, who)
	dsb_set_stat(who, STAT_AMA, dsb_get_stat(who, STAT_AMA)+150)
	dsb_set_maxstat(who, STAT_AMA, dsb_get_maxstat(who, STAT_AMA)+150)
	dsb_set_gfxflag(id, GF_ALT_ICON)	
end

function obj.jewelsymal:from_neck(id, who)
    dsb_set_stat(who, STAT_AMA, dsb_get_stat(who, STAT_AMA)-150)
	dsb_set_maxstat(who, STAT_AMA, dsb_get_maxstat(who, STAT_AMA)-150)
	dsb_clear_gfxflag(id, GF_ALT_ICON)	
end

function obj.illumulet:to_neck(id, who)
	-- Only do this if the character is in the party
	if (dsb_char_ppos(who)) then
		g_illum = g_illum + 1
		if (g_illum == 1) then
			dsb_set_light("illumulets", 40)
		end	
		dsb_set_gfxflag(id, GF_ALT_ICON)
	end
end

function obj.illumulet:from_neck(id, who)
	-- Only do this if the character is in the party
	if (dsb_char_ppos(who)) then
		g_illum = g_illum - 1
		if (g_illum == 0) then
			dsb_set_light("illumulets", 0)
		end	
		dsb_clear_gfxflag(id, GF_ALT_ICON)
	end	
end

function obj.gem_of_ages:to_neck(id, who)
	local b = dsb_get_bonus(who, CLASS_PRIEST, SKILL_POTIONS)
	dsb_set_bonus(who, CLASS_PRIEST, SKILL_POTIONS, b+1)
end

function obj.gem_of_ages:from_neck(id, who)
	local b = dsb_get_bonus(who, CLASS_PRIEST, SKILL_POTIONS)
	dsb_set_bonus(who, CLASS_PRIEST, SKILL_POTIONS, b-1)
end

function obj.ekkhard_cross:to_neck(id, who)
	local b = dsb_get_bonus(who, CLASS_PRIEST, SKILL_SHIELDS)
	dsb_set_bonus(who, CLASS_PRIEST, SKILL_SHIELDS, b+1)
end

function obj.ekkhard_cross:from_neck(id, who)
	local b = dsb_get_bonus(who, CLASS_PRIEST, SKILL_SHIELDS)
	dsb_set_bonus(who, CLASS_PRIEST, SKILL_SHIELDS, b-1)
end

function obj.moonstone:to_neck(id, who)
	boost_with_overflow(who, MANA, 30)
	local b = dsb_get_bonus(who, CLASS_PRIEST, SKILL_FEAR)
	dsb_set_bonus(who, CLASS_PRIEST, SKILL_FEAR, b+1)
end

function obj.moonstone:from_neck(id, who)
	boost_with_overflow(who, MANA, -30)
	local b = dsb_get_bonus(who, CLASS_PRIEST, SKILL_FEAR)
	dsb_set_bonus(who, CLASS_PRIEST, SKILL_FEAR, b-1)
end

function obj.pendant_feral:to_neck(id, who)
	local b = dsb_get_bonus(who, CLASS_WIZARD, 0)
	dsb_set_bonus(who, CLASS_WIZARD, 0, b+1)
end

function obj.pendant_feral:from_neck(id, who)
	local b = dsb_get_bonus(who, CLASS_WIZARD, 0)
	dsb_set_bonus(who, CLASS_WIZARD, 0, b-1)
end