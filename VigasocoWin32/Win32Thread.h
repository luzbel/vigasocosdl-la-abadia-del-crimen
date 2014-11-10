// Win32Thread.h
//
//	Class that encapsulates a windows thread
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _WIN32_THREAD_H_
#define _WIN32_THREAD_H_


#include "IThread.h"
#define WINDOWS_LEAN_AND_MEAN
#include <windows.h>

class Win32Thread : public IThread
{
// fields
protected:
	HANDLE _handle;			// thread handle
	DWORD _id;				// thread id

public:
	// initialization and cleanup
	Win32Thread();
	virtual ~Win32Thread();

	// IThread interface
	virtual bool start();
	virtual void end();
	virtual void pause();
	virtual void resume();

	// helper method
	static DWORD WINAPI ThreadProc(Win32Thread *thread);
};

#endif	// _WIN32_THREAD_H_
