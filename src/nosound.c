#include <dsballegro.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <fmod.h>
#include <fmod_errors.h>
#include "filedefs.h"
#include "objects.h"
#include "global_data.h"
#include "uproto.h"
#include "sound.h"
#include "sound_fmod.h"

#define MAX_VOICES 40

static FMOD_SOUND *interface_click_sound;

FMOD_SYSTEM *f_system;

extern FILE *errorlog;
extern struct global_data gd;
extern struct dungeon_level *dun;

extern const char *DSB_MasterSoundTable;

struct channel_list fchans;
extern lua_State *LUA;

void fmod_errcheck(FMOD_RESULT result) {
}

void fmod_uerrcheck(FMOD_RESULT result) {
}

int add_to_channeltable(FMOD_SOUND *samp,
    FMOD_CHANNEL *chan, const char *id_str) 
{
}

void check_sound_channels(void) {
}

int check_sound(unsigned int cid) {
}

void stop_sound(unsigned int cid) {
}

void destroy_all_sound_handles(void) {
}

void destroy_all_music_handles(void) {
}

void store_frozen_channel(int i, const char *uid, FMOD_SOUND *sample,
    float vol, int cmode, int cpos, int x, int y, int z)
{
}

void freeze_sound_channels(void) {
}

void halt_all_sound_channels(void) {
}

void unfreeze_sound_channels(void) {
}

void memset_sound(void) {
}

FMOD_SOUND *soundload(const char *sname, const char *longname,
    int compilation, int quietfail, int is_not_music) 
{
}

void sound_3d_settings(int atten) {
}

void fsound_init(void) {
}

void coord2vector(FMOD_VECTOR *fv, int lev, int x, int y) {
}    

void set_3d_soundcoords(void) {
}

int play_3dsound(FMOD_SOUND *fs, const char *id, int lev, int xx, int yy, int loop) {
}

int play_ssound(FMOD_SOUND *fs, const char *id, int loop, int use_3d) {
}

void fmod_update(void) {
}

void read_all_sounddata(PACKFILE *pf) {
}

void write_all_sounddata(PACKFILE *pf) {
}

void sound_destroy_and_dc(const char *id) {
}

void interface_click(void) {
}

void init_interface_click(void) {
}

int get_sound_vol(unsigned int shand) {
}

void set_sound_vol(unsigned int shand, unsigned int vol) {
}

FMOD_SOUND *do_load_music(const char *musicname, 
    char *unique_id, int force_loading) 
{
}

void current_music_ended(int music_chan) {
}

