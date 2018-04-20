#include <allegro.h>
#include <winalleg.h>

#ifdef _WIN32
static unsigned long long int perfreq;
static unsigned long long int m_freq;
LARGE_INTEGER per_v;
LARGE_INTEGER old_v;
#else
#include <sys/time.h>
double perfreq;
double m_freq;
struct timeval clock_ts;
#endif

extern int T_BPS;

void init_systemtimer(void) {
#ifdef _WIN32
    LARGE_INTEGER p_freq;
    QueryPerformanceFrequency(&p_freq);
    perfreq = p_freq.QuadPart / T_BPS;
    m_freq = p_freq.QuadPart / 1000;
    
    per_v.QuadPart = 0;
    old_v.QuadPart = 0;
#else
	gettimeofday(&clock_ts,NULL);		
	perfreq = 1.0 / T_BPS;
	m_freq = 1.0 / 1000.0;
#endif
}

int getsleeptime(void) {
#ifdef _WIN32
    unsigned long long int d;
    LARGE_INTEGER c_v;
    
    QueryPerformanceCounter(&c_v);

    if (c_v.QuadPart >= old_v.QuadPart + perfreq)
        return 0;
        
    d = (old_v.QuadPart + perfreq) - c_v.QuadPart;
 
    return ((d/m_freq) - 1);
#else
	struct timeval new_ts;
	gettimeofday(&new_ts,NULL);
	
	double seconds = (new_ts.tv_sec + new_ts.tv_usec / 1000000.0);
	double old_seconds = (clock_ts.tv_sec + clock_ts.tv_usec / 1000000.0);

	int st = 0;
	if (seconds <= old_seconds + perfreq) {
		
		double d = (old_seconds + perfreq) - seconds;
		st = ((d / m_freq) - 1);
	}
	return st;
#endif	
}

int systemtimer(void) {
#ifdef _WIN32    
    QueryPerformanceCounter(&per_v);
    
    if (per_v.QuadPart > old_v.QuadPart + perfreq) {
        int ticks = (per_v.QuadPart - old_v.QuadPart)/perfreq;
        old_v.QuadPart = per_v.QuadPart;
        
        return ticks;
    }
	else
		return 0;

#else
	struct timeval new_ts;
	gettimeofday(&new_ts,NULL);
	
	double seconds = (new_ts.tv_sec + new_ts.tv_usec / 1000000.0);
	double old_seconds = (clock_ts.tv_sec + clock_ts.tv_usec / 1000000.0);

	int ticks = 0;

	if (seconds > old_seconds + perfreq) {
		ticks = ((seconds - old_seconds) / perfreq);
		clock_ts = new_ts;
	}
	return ticks;
#endif	
}
