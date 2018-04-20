-- Global base config script   
-- IT'S NOT A GOOD IDEA TO CHANGE THINGS IN HERE UNLESS
-- YOU KNOW WHAT YOU'RE DOING, but reading this file over
-- is a good way to get to know how DSB works.

-- If you want to add new functions/variables to your
-- dungeon, it's a much better idea to put them in your
-- own dungeon's startup.lua.

-- where to put things
NORTH = 0
EAST = 1
SOUTH = 2
WEST = 3

-- flooritems and wallitems use similar location structure
NORTHWEST = 0
NORTHEAST = 1
SOUTHEAST = 2
SOUTHWEST = 3

-- spell it either way
CENTER = 4
CENTRE = 4

-- xp data
xp_classes = 4
xp_subskills = {4, 4, 4, 4}
xp_classnames = { "FIGHTER", "NINJA", "PRIEST", "WIZARD" }
xp_levels = 15		
xp_levelnames = { "NEOPHYTE", "NOVICE", "APPRENTICE",
	"JOURNEYMAN", "CRAFTSMAN", "ARTISAN", "ADEPT",
	"EXPERT", "a MASTER", "b MASTER", "c MASTER",
	"d MASTER", "e MASTER", "f MASTER", "ARCHMASTER" }		
xp_levelamounts = { 500, 1000, 2000, 
	4000, 8000, 16000, 32000, 
	64000, 128000, 256000, 512000, 
	1024000, 2048000, 4096000, 8192000 } 

barnames = { "HEALTH", "STAMINA", "MANA" }

statnames = { "STRENGTH", "DEXTERITY", "WISDOM", 
	"VITALITY", "ANTI-MAGIC", "ANTI-FIRE" }
	
msg_resurrected = " RESURRECTED."
msg_reincarnated = " REINCARNATED."

powchar = { "a", "b", "c", "d", "e", "f" }

-- Special "Level" targets
PARTY = -1
IN_OBJ = -2
CHARACTER = -3
MOUSE_HAND = -4
LIMBO = -5

-- Messages
-- Message ids above 100000 are reserved for the base code
-- Feel free to use anything below that
dsb_add_msgtype("M_ACTIVATE", 100000)
dsb_add_msgtype("M_DEACTIVATE", 100001) 
dsb_add_msgtype("M_TOGGLE", 100002)
dsb_add_msgtype("M_NEXTTICK",100003)
dsb_add_msgtype("M_ALT_NEXTTICK", 100004)
dsb_add_msgtype("M_RESET", 100005)
dsb_add_msgtype("M_STOPATTACK", 100006)
dsb_add_msgtype("M_CLEANUP", 100007)
dsb_add_msgtype("M_BASH", 100008)
dsb_add_msgtype("M_TINT", 100009)
dsb_add_msgtype("M_EXPIRE", 100010)
dsb_add_msgtype("M_REARRANGE", 100100)
dsb_add_msgtype("M_TURN", 100101)
dsb_add_msgtype("M_ATTACK_MELEE", 100110)
dsb_add_msgtype("M_ATTACK_RANGED", 100111)
dsb_add_msgtype("M_ALIGNED", 100120)
dsb_add_msgtype("M_SUSPEND_CHECK", 100121)
dsb_add_msgtype("M_POUNCE", 100122)
dsb_add_msgtype("M_SPECIAL",100125)
dsb_add_msgtype("M_DESTROY", 100255)

-- Alternate names. They've already
-- been registered so we don't have to do
-- anything special.
M_TEMPORARY_REVERSE = 100004
M_UNFREEZE = 100005
M_DELETE = 100255

-- System Message Targets
-- Negative values are reserved for the core engine.
-- Positive values can be used by designer-defined system hooks.
SYSTEM = -1
SYS_METHOD_OBJ = -1
SYS_METHOD_SEL = -2
SYS_METHOD_CLEAR = -3
SYS_MOVE_ARROW = -4
SYS_MAGIC_PPOS = -11
SYS_MAGIC_RUNE = -12
SYS_MAGIC_BACK = -13
SYS_MAGIC_CAST = -14
SYS_OBJ_PUT_AWAY = -20
SYS_LEADER_SET = -30

-- AI Messages
AI_FEAR = 1
AI_DELAY_ACTION = 2
AI_STUN = 3
AI_HAZARD = 4
AI_WALL_BELIEF = 5
AI_ATTACK_BMP = 6
AI_DELAY_EVERYTHING = 7
AI_DELAY_TIMER = 12
AI_MOVE_NOW = 16
AI_SEE_PARTY = 32
AI_TARGET = 33
AI_UNGROUP = 34
AI_MOVE = 512
AI_TURN = 513
AI_TIMER = 514

-- Special spawning parameter
FORCE_INSTANT = 0

-- Special delay parameter
END_OF_FRAME = -5999

-- Special AI parameters
AUTOMATIC = -8
UNDEFINE = -16
QUERY = -6000

-- missiles
MISSILE_MISC = 1
MISSILE_ARROW = 2
MISSILE_ROCK = 3
MISSILE_DART = 4
MISSILE_STAR = 5
MISSILE_DAGGER = 6
MISSILE_MAGIC = 999

-- condition attributes
INDIVIDUAL = -255

-- condition flags
COND_MOUTH_RED = 1
COND_MOUTH_GREEN = 2
COND_EYE_RED = 4
COND_EYE_GREEN = 8

-- special fetch mode
TABLE = 1

-- special tag for colorconvert and objects
VARIABLE = -1

-- Graphics flags
GF_ALT_ICON = 1
GF_INACTIVE = 2
GF_BASHED = 4
GF_ATTACKING = 8
GF_UNMOVED = 16
GF_FLIP = 32
GF_FREEZE = 64
GF_LAUNCHED = 128

-- Game flags
GAME_WINDOW = 1
GAME_NO_METHOD_PASS = 2
GAME_PARTY_INVIS = 4
GAME_CSB_REINCARNATION = 32
GAME_GAMEOVER_ON_EMPTY = 64
GAME_KEEP_MONSTER_DROPZONES = 128
GAME_FAST_ADVANCEMENT = 256
GAME_ONE_WALLITEM = 512
GAME_NO_LAUNCH_TELEPORT = 1024
GAME_ZERO_EXP = 2048
GAME_MAX_STAT_UP = 4096

-- Mparty flags
MPARTY_SPLIT = 1
MPARTY_COLLIDE = 2
MPARTY_ENABLED = 256

-- Game locking flags
LOCK_ACTUATORS = 1
LOCK_MOVEMENT = 2
LOCK_MOUSE = 4
LOCK_MAGIC = 8
LOCK_INVENTORY = 16
LOCK_ATTACK = 32
LOCK_FLYERS = 64
LOCK_CONDITIONS = 128
LOCK_MESSAGES = 256
LOCK_ALL_TIMERS = 512
-- Deprecated
--LOCK_MONSTERS
--LOCK_MONSTERS_ALL

-- inventory locations
INV_R_HAND = 0
INV_L_HAND = 1
INV_HEAD = 2
INV_TORSO = 3
INV_LEGS = 4
INV_FEET = 5
INV_NECK = 6
INV_POUCH = 7
INV_POUCH2 = 8
INV_QUIVER = 9
INV_QUIV2 = 10
INV_QUIV3 = 11
INV_QUIV4 = 12
INV_PACK = 13
MAX_INV_SLOTS = 30

mouse_throwing_hand = INV_R_HAND

-- basic stats
STAT_STR = 0
STAT_DEX = 1
STAT_WIS = 2
STAT_VIT = 3
STAT_AMA = 4
STAT_AFI = 5
STAT_LUC = 6 -- hidden

-- classes
CLASS_FIGHTER = 0
CLASS_NINJA = 1
CLASS_PRIEST = 2
CLASS_WIZARD = 3

-- subskills
SKILL_SWINGING = 1
SKILL_STABBING = 2
SKILL_BASHING = 3
SKILL_DEFENSE = 4

SKILL_CLIMBING = 1
SKILL_MARTIALARTS = 2
SKILL_THROWING = 3
SKILL_SHOOTING = 4

SKILL_LUCK = 1
SKILL_POTIONS = 2
SKILL_FEAR = 3
SKILL_SHIELDS = 4

SKILL_FIRE = 1
SKILL_AIR = 2
SKILL_DES = 3
SKILL_POISON = 4

-- bars
HEALTH = 0
STAMINA = 1
MANA = 2

-- Monster attack types
ATTACK_STEAL = 0
ATTACK_ANTI_FIRE = 1
_ATTACK_RESERVED = 2
ATTACK_PHYSICAL = 3
ATTACK_PIERCING = 4
ATTACK_ANTI_MAGIC = 5
ATTACK_WISDOM = 6

-- Constants for amount of load
LOAD_NONE = 0
LOAD_YELLOW = 1
LOAD_RED = 2

-- for text (CENTER is also used)
LEFT = 0
RIGHT = 1
MULTILINE = 128

-- for blitting
PATTERN_MODE = 1
SHADOW_MODE = 2

-- viewport distortion
DISTORTION_NONE = 0
DISTORTION_UNDERWATER = 1
DISTORTION_BLUR = 2
DISTORTION_STATIC = 3
DISTORTION_COLORFADE = 4

-- Basic color definitions
player_colors = {
	{0, 222, 0},
	{255, 255, 0},
	{255, 0, 0},
	{0, 0, 255}
}

name_draw_colors = {
	{182, 182, 182},
	{182, 160, 96},
	{255, 182, 0},
	{255, 255, 0}
}

system_color = {0, 222, 222}
debug_color = {255, 160, 0}
scroll_color = {0, 0, 0}

g_disabled_runes = {
	false, false, false, false, false, false,
	false, false, false, false, false, false,
	false, false, false, false, false, false,
	false, false, false, false, false, false
}

-- Set up this table for any custom code
default_monster_dmgresist = { }

-- alias to a renamed function, for old code
dsb_update_strings = dsb_update_system

-- The following files will be parsed, in this order.
-- You can also include a lua_manifest in your own custom
-- dungeon's startup.lua, if you want to break your script
-- up across multiple files.
lua_manifest = {
	"graphics.lua",
	"gui_info.lua",
	"inventory_info.lua",
	"util.lua",
	"triggers.lua",
	"conditions.lua",
	"monster.lua",
	"monster_ai.lua",
	"methods.lua",
	"damage.lua",
	"xp.lua",
	"magic.lua",
	"msg_handlers.lua",
	"hooks.lua",
	"system.lua",
	"render.lua"
}

--startup function, override it if you want
function global_startup()	
end