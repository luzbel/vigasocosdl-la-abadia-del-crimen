// SDLThread.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "SDLThread.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

SDLThread::SDLThread()
{
	_handle = NULL;
}

SDLThread::~SDLThread()
{
	end();
}

/////////////////////////////////////////////////////////////////////////////
// thread function
/////////////////////////////////////////////////////////////////////////////

int SDLThread::ThreadProc(SDLThread *thread)
{
	return thread->run();
}

/////////////////////////////////////////////////////////////////////////////
// thread life cycle
/////////////////////////////////////////////////////////////////////////////

bool SDLThread::start()
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

void SDLThread::end()
{
	if (_handle != NULL){
		_isRunning = false;

		// kill the thread
		SDL_KillThread(_handle);

		_handle = NULL;
	}
}

void SDLThread::pause()
{
//SuspendThread(_handle);
// ¡¡¡ FALTA POR IMPLEMENTAR !!!
}

void SDLThread::resume()
{
//ResumeThread(_handle);
// ¡¡¡ FALTA POR IMPLEMENTAR !!!
}
