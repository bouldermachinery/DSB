
#if (defined __linux__) || (defined  __MINGW32__)
typedef int FMOD_SOUND;
typedef int FMOD_CHANNEL;
typedef int FMOD_SYSTEM;
typedef struct FMOD_CREATESOUNDEXINFO {
	int cbsize;
	int length;
} FMOD_CREATESOUNDEXINFO;
static const int FMOD_OPENMEMORY=0;
static const int FMOD_2D=0;
static const int FMOD_CHANNEL_FREE=0;
typedef int FMOD_VECTOR;
typedef int FMOD_RESULT;;

void FMOD_System_CreateSound(void* system, void* data, int flags, void* p1, void *p2);
void FMOD_System_PlaySound(void* system, int flaggs, FMOD_SOUND* ptr, int loop, void* chan);
void FMOD_System_Stop(FMOD_SOUND* ptr);

void FMOD_Sound_Release(FMOD_SOUND* ptr);

void FMOD_Channel_SetLoopCount(FMOD_SOUND*, int count);
void FMOD_Channel_SetPaused(FMOD_SOUND* ptr, int paused);
void FMOD_Channel_PlaySound(void* system, int flag, FMOD_SOUND* ptr, int loop, void* chan);
void FMOD_Channel_Stop(FMOD_SOUND* ptr);

#endif