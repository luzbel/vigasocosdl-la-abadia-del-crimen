// LinuxSDLThread.h
//
//	Class that encapsulates a Linux SDL thread
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUXSDL_THREAD_H_
#define _LINUXSDL_THREAD_H_


#include "IThread.h"
#include "SDL.h"
#include "SDL_thread.h"

class LinuxSDLThread : public IThread
{
// fields
protected:
	SDL_Thread *_handle;

public:
	// initialization and cleanup
	LinuxSDLThread();
	virtual ~LinuxSDLThread();

	// IThread interface
	virtual bool start();
	virtual void end();
	virtual void pause();
	virtual void resume();

	// helper method
	static int ThreadProc(LinuxSDLThread *thread);
};

#endif	// _LINUXSDL_THREAD_H_
