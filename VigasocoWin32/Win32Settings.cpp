// Win32Settings.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Win32Settings.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

Win32Settings::Win32Settings(HINSTANCE appInstance, LONG windowParam, WindowProcedure proc)
{
	_appInstance = appInstance;
	_windowParam = windowParam;
	_wndProc = proc;
	_hWnd = 0;
	_VIGASOCOClassName = "VIGASOCOWndClass";

	// registrates a window class for the application
	regWndClass();
}

Win32Settings::~Win32Settings()
{
}

/////////////////////////////////////////////////////////////////////////////
// windows registration
/////////////////////////////////////////////////////////////////////////////

// register a window class for the application
int Win32Settings::regWndClass()
{
	WNDCLASSEX wCls;

	memset(&wCls, 0, sizeof(wCls));
	wCls.cbSize = sizeof(wCls);

	// set class settings
	wCls.lpszClassName = getAppClassName();
	wCls.hInstance = _appInstance;
	wCls.lpfnWndProc = _wndProc;
	wCls.hCursor = LoadCursor(NULL, IDC_ARROW);
	wCls.hIcon = LoadIcon(NULL, IDI_APPLICATION);
	wCls.lpszMenuName = NULL;
	wCls.hbrBackground = NULL;
	wCls.style = 0;
	wCls.cbClsExtra = 0;
	wCls.cbWndExtra = 0;

	// try to register the class
	return RegisterClassEx(&wCls);
}

const char *Win32Settings::getAppClassName() const
{ 
	return _VIGASOCOClassName.c_str();
}