// RDTSCTimer.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "RDTSCTimer.h"
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

RDTSCTimer::RDTSCTimer()
{
}

RDTSCTimer::~RDTSCTimer()
{
}

bool RDTSCTimer::init()
{
	// if the CPU doesn't support the RDTSC instruction, init fails
	if (!supportsRDTSC()){
		return false;
	}

	_ticksPerSecond = calcTicksPerSecond();
	_ticksPerMilliSecond = _ticksPerSecond/1000;

	return true;
}

void RDTSCTimer::end()
{
}

/////////////////////////////////////////////////////////////////////////////
// timer methods
/////////////////////////////////////////////////////////////////////////////

INT64 RDTSCTimer::getTime()
{
	INT64 result;

	__asm {
		rdtsc
		lea ebx,[result]
		mov [ebx],eax
		mov [ebx+4],edx
	}

	return result;
}

INT64 RDTSCTimer::getTicksPerSecond()
{
	return _ticksPerSecond;
}

// windows Sleep function isn't precise enough, so here it's a better sleep method
void RDTSCTimer::sleep(UINT32 milliseconds)
{
	INT64 time1, time2; 
	bool finished = false;

	time1 = getTime();
	
	while (!finished){
		time2 = getTime();

		finished = (time2 - time1) >= _ticksPerMilliSecond*milliseconds;
		if (!finished){
			Sleep(0);
		}
	} 
}

/////////////////////////////////////////////////////////////////////////////
// helper methods
/////////////////////////////////////////////////////////////////////////////

INT64 RDTSCTimer::calcTicksPerSecond()
{
	// raise the priority for accurate timing
	int priClass = GetPriorityClass(GetCurrentProcess());
	SetPriorityClass(GetCurrentProcess(), REALTIME_PRIORITY_CLASS);
	int priority = GetThreadPriority(GetCurrentThread());
	SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_TIME_CRITICAL);

	// wait for 0.25 seconds
	INT64 begin = RDTSCTimer::getTime();

	Sleep(1000/4);

	INT64 end = RDTSCTimer::getTime();

	// restore the previous priority
	SetPriorityClass(GetCurrentProcess(), priClass);
	SetThreadPriority(GetCurrentThread(), priority);

	return (end - begin)*4;
}

bool RDTSCTimer::supportsRDTSC()
{
	int cpuFeatures;

	__asm {
		mov eax, 1
		cpuid
		mov cpuFeatures, edx
	}

	return ((cpuFeatures & 0x10) == 0x10);
}
