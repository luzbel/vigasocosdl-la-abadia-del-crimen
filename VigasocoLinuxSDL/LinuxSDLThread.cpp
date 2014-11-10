// LinuxSDLThread.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLThread.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

LinuxSDLThread::LinuxSDLThread()
{
	_handle = NULL;
}

LinuxSDLThread::~LinuxSDLThread()
{
	end();
}

/////////////////////////////////////////////////////////////////////////////
// thread function
/////////////////////////////////////////////////////////////////////////////

int LinuxSDLThread::ThreadProc(LinuxSDLThread *thread)
{
	return thread->run();
}

/////////////////////////////////////////////////////////////////////////////
// thread life cycle
/////////////////////////////////////////////////////////////////////////////

bool LinuxSDLThread::start()
{
	if (_isRunning){
		return false;
	}

	// creates the thread
	_handle = SDL_CreateThread((int (*)(void*))ThreadProc, this);

	if (_handle == NULL){
		// error creating the thread
		return false;
	}

	_isRunning = true;

	return true;
}

void LinuxSDLThread::end()
{
	if (_handle != NULL){
		_isRunning = false;

		// kill the thread
		SDL_KillThread(_handle);

		_handle = NULL;
	}
}

void LinuxSDLThread::pause()
{
//SuspendThread(_handle);
// ¡¡¡ FALTA POR IMPLEMENTAR !!!
}

void LinuxSDLThread::resume()
{
//ResumeThread(_handle);
// ¡¡¡ FALTA POR IMPLEMENTAR !!!
}
