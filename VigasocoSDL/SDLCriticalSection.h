// SDLCriticalSection.h
//
//	Class that encapsulates a SDL thread
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _SDL_CRITICAL_SECTION_H_
#define _SDL_CRITICAL_SECTION_H_


#include "ICriticalSection.h"
#include "SDL.h"

class SDLCriticalSection : public ICriticalSection
{
// fields
protected:
	SDL_mutex *cs;
	

public:
	// initialization and cleanup
	SDLCriticalSection();
	virtual ~SDLCriticalSection();

	// ICriticalSection interface
	virtual void init();
	virtual void destroy();
	virtual void enter();
	virtual void leave();
};

#endif	// _SDL_CRITICAL_SECTION_H_
