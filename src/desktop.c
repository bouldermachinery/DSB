#include <stdio.h>
#include <dsballegro.h>
#include "objects.h"
#include "global_data.h"
#include "uproto.h"
#include "gproto.h"

struct animap *grab_desktop(void) {
#ifdef _WIN32
    struct animap *desktop_a; 
    BITMAP *dskb;
    HWND hwnd;
    HDC ddc;
    RECT sz;

    hwnd = GetDesktopWindow();
    ddc = GetDC(hwnd);
    GetWindowRect(hwnd, &sz);
    
    dskb = create_bitmap(sz.right, sz.bottom);
    desktop_a = dsbmalloc(sizeof(struct animap));
    memset(desktop_a, 0, sizeof(struct animap));
    desktop_a->b = dskb; 
    
    blit_from_hdc(ddc, dskb, 0, 0, 0, 0, sz.right, sz.bottom); 
    ReleaseDC(hwnd, ddc);
    
    return desktop_a;
#else
	return NULL;
#endif
}


   
