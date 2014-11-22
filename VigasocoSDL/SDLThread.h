// SDLThread.h
//
//	Class that encapsulates a SDL thread
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _SDL_THREAD_H_
#define _SDL_THREAD_H_


#include "IThread.h"
#include "SDL.h"
#include "SDL_thread.h"

class SDLThread : public IThread
{
// fields
protected:
	SDL_Thread *_handle;

public:
	// initialization and cleanup
	SDLThread();
	virtual ~SDLThread();

	// IThread interface
	virtual bool start();
	virtual void end();
	virtual void pause();
	virtual void resume();

	// helper method
	static int ThreadProc(SDLThread *thread);
};

#endif	// _SDL_THREAD_H_
