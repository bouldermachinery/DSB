#include "fmod.h"

void FMOD_System_CreateSound(void* system, void* data, int flags, void* p1, void *p2) {}
void FMOD_System_PlaySound(void* system, int flaggs, FMOD_SOUND* ptr, int loop, void* chan) {}
void FMOD_System_Stop(FMOD_SOUND* ptr) {}

void FMOD_Sound_Release(FMOD_SOUND* ptr) {}

void FMOD_Channel_SetLoopCount(FMOD_SOUND* ptr, int count) {}
void FMOD_Channel_SetPaused(FMOD_SOUND* ptr, int paused) {}
void FMOD_Channel_PlaySound(void* system, int flag, FMOD_SOUND* ptr, int loop, void* chan) {}
void FMOD_Channel_Stop(FMOD_SOUND* ptr) {}
