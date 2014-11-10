// LinuxSDLCriticalSection.h
//
//	Class that encapsulates a Linux SDL thread
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUXSDL_CRITICAL_SECTION_H_
#define _LINUXSDL_CRITICAL_SECTION_H_


#include "ICriticalSection.h"
#include "SDL.h"

class LinuxSDLCriticalSection : public ICriticalSection
{
// fields
protected:
	SDL_mutex *cs;
	

public:
	// initialization and cleanup
	LinuxSDLCriticalSection();
	virtual ~LinuxSDLCriticalSection();

	// ICriticalSection interface
	virtual void init();
	virtual void destroy();
	virtual void enter();
	virtual void leave();
};

#endif	// _LINUXSDL_CRITICAL_SECTION_H_
