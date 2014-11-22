// SDLTimer.h
//
//	Timer using SDL
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _SDL_TIMER_H_
#define _SDL_TIMER_H_

#include "ITimer.h"

class SDLTimer : public ITimer
{
// fields
protected:
	INT64 _ticksPerSecond;
	INT64 _ticksPerMilliSecond;

// methods
public:
	virtual bool init();
	virtual void end();

	virtual INT64 getTime();
	virtual INT64 getTicksPerSecond();
	virtual void sleep(UINT32 milliseconds);

	// initialization and cleanup
	SDLTimer();
	virtual ~SDLTimer();

// helper methods
protected:
	INT64 calcTicksPerSecond();
};

#endif	// _SDL_TIMER_H_
