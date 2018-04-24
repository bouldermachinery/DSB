#include "dummywin.h"

static int GFX_DIRECTX = 0;

void CloseHandle(int handle) {}
void ReleaseSemaphore(int semaphore, int p1, void* p2) {}
void* CreateSemaphore(void* p1, int p2, int p3, void* p4) {}
void WaitForSingleObject(int semaphore, int time) {}

						 
void InitializeCriticalSectionAndSpinCount(void* queue, int p1) {}
void EnterCriticalSection(void* queue) {}
void LeaveCriticalSection(void* queue) {}
void DeleteCriticalSection(void* queue) {}

void GetTempPath(int p1, char* dir) { return dir; }
int MessageBox(void* win, char* message, char* type, int e) { return 1; }
void* win_get_window() { return 0; }

static int MB_ICONEXCLAMATION = 1;
static int MB_ICONSTOP = 1;
static int MB_ICONINFORMATION = 1;
static int MB_YESNO = 1;

void Sleep(int s) { usleep(s); }
