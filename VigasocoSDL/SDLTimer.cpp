//ESTO TODAVIA NO FUNCIONA

// SDLTimer.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "SDLTimer.h"
#include "SDL.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

SDLTimer::SDLTimer()
{
}

SDLTimer::~SDLTimer()
{
}

bool SDLTimer::init()
{
	_ticksPerSecond = calcTicksPerSecond();
	_ticksPerMilliSecond = _ticksPerSecond/1000;
fprintf(stderr,"_ticksPerMilliSecond: %lld\n",_ticksPerMilliSecond);
	return true;
}

void SDLTimer::end()
{
}

/////////////////////////////////////////////////////////////////////////////
// timer methods
/////////////////////////////////////////////////////////////////////////////

INT64 SDLTimer::getTime()
{
	return SDL_GetTicks();
}

INT64 SDLTimer::getTicksPerSecond()
{
	return _ticksPerSecond;
}

// windows Sleep function isn't precise enough, so here it's a better sleep method
void SDLTimer::sleep(UINT32 milliseconds)
{
	INT64 time1, time2; 
	bool finished = false;

	time1 = getTime();
	
	while (!finished){
		time2 = getTime();

		finished = (time2 - time1) >= _ticksPerMilliSecond*milliseconds;
		if (!finished){
			SDL_Delay(0);
		}
	} 
// No es suficiente con un simple SDL_Delay???
// Count on a delay granularity of at least 10 ms. 
//	SDL_Delay(milliseconds);
}

/////////////////////////////////////////////////////////////////////////////
// helper methods
/////////////////////////////////////////////////////////////////////////////

INT64 SDLTimer::calcTicksPerSecond()
{
	return 1000;
	/*
	// raise the priority for accurate timing
	// ¡¡¡ FALTA POR IMPLEMENTAR !!!

	// wait for 0.25 seconds
	INT64 begin = SDLTimer::getTime();

//	SDL_Delay(1000/4);
	SDL_Delay(1000*10);

	INT64 end = SDLTimer::getTime();

	// restore the previous priority
	// ¡¡¡ FALTA POR IMPLEMENTAR !!!

//fprintf(stderr,"calcTicksPerSecond %lld\n",(end - begin)*4);
fprintf(stderr,"calcTicksPerSecond %lld\n",(end - begin)/10);
//	return (end - begin)*4;
	return (end - begin)/10; */
}
