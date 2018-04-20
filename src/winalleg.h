
#ifndef WINALLEG_H
#define WINALLEG_H 1

#ifndef WIN32
//#include "gproto.h"
#include "allegro.h"

typedef int HANDLE;
typedef int CRITICAL_SECTION;
#define MAX_PATH 256
static int GFX_DIRECTX;

void CloseHandle(int handle);
void ReleaseSemaphore(int semaphore, int p1, void* p2);
void* CreateSemaphore(void* p1, int p2, int p3, void* p4);
void WaitForSingleObject(int semaphore, int time);

void InitializeCriticalSectionAndSpinCount(void* queue, int p1);
void EnterCriticalSection(void* queue);
void LeaveCriticalSection(void* queue);
void DeleteCriticalSection(void* queue);

void GetTempPath(int p1, char* dir);
int MessageBox(void* win, char* message, char* type, int e);
void* win_get_window();
void init_systemtimer();
void initmovequeue(void);
void purge_object_translation_table();
void reget_lua_font_handle();
void initialize_lua();
void dsbfree(void *mem);

static int MB_ICONEXCLAMATION;
static int MB_ICONSTOP;
static int MB_ICONINFORMATION;
static int MB_YESNO;

void Sleep(int s);

typedef int HWND;
typedef long LARGE_INTEGER;
#endif
#endif