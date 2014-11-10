// Win32CriticalSection.h
//
//	Class that encapsulates a windows thread
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _WIN32_CRITICAL_SECTION_H_
#define _WIN32_CRITICAL_SECTION_H_


#include "ICriticalSection.h"
#define WINDOWS_LEAN_AND_MEAN
#include <windows.h>

class Win32CriticalSection : public ICriticalSection
{
// fields
protected:
	CRITICAL_SECTION cs;

public:
	// initialization and cleanup
	Win32CriticalSection();
	virtual ~Win32CriticalSection();

	// ICriticalSection interface
	virtual void init();
	virtual void destroy();
	virtual void enter();
	virtual void leave();
};

#endif	// _WIN32_CRITICAL_SECTION_H_
