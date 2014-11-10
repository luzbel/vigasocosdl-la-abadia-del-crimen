// Win32Thread.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Win32Thread.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

Win32Thread::Win32Thread()
{
	_handle = NULL;
	_id = 0;
}

Win32Thread::~Win32Thread()
{
	end();
}

/////////////////////////////////////////////////////////////////////////////
// thread function
/////////////////////////////////////////////////////////////////////////////

DWORD WINAPI Win32Thread::ThreadProc(Win32Thread *thread)
{
	return thread->run();
}

/////////////////////////////////////////////////////////////////////////////
// thread life cycle
/////////////////////////////////////////////////////////////////////////////

bool Win32Thread::start()
{
	if (_isRunning){
		return false;
	}

	// creates the thread
	_handle = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)ThreadProc, this, 0, &_id);

	if (_handle == NULL){
		// error creating the thread
		return false;
	}

	_isRunning = true;

	return true;
}

void Win32Thread::end()
{
	if (_handle != NULL){
		_isRunning = false;

		// kill the thread
		TerminateThread(_handle, 0);

		CloseHandle(_handle);
		_handle = NULL;
		_id = 0;
	}
}

void Win32Thread::pause()
{
	SuspendThread(_handle);
}

void Win32Thread::resume()
{
	ResumeThread(_handle);
}
