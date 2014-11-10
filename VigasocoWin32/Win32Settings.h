// Win32Settings.h
//
//	Class with all important Win32 state info
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _WIN32_SETTINGS_H_
#define _WIN32_SETTINGS_H_


#include <string>
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

class Win32Settings
{
//types
protected:
	typedef LRESULT (CALLBACK *WindowProcedure)(HWND, UINT, WPARAM, LPARAM);

// fields
protected:
	HWND _hWnd;						// window handle
	HINSTANCE _appInstance;			// application instance
	LONG _windowParam;				// user data attached to the window
	WindowProcedure _wndProc;		// window procedure
	std::string _VIGASOCOClassName;	// window class

// methods
public:
	Win32Settings(HINSTANCE appInstance, LONG windowParam, WindowProcedure proc);
	virtual ~Win32Settings();

	// getters & setters
	virtual void setHWnd(HWND hWnd){ _hWnd = hWnd; }
	virtual HWND getHWnd() const { return _hWnd; }
	virtual HINSTANCE getAppInstance() const { return _appInstance; }
	virtual LONG getWndParam() const { return _windowParam; }
	virtual WindowProcedure getWindowProc() const { return _wndProc; }
	virtual const char *getAppClassName() const;

protected:
	int regWndClass();
};


#endif // _WIN32_SETTINGS_H_
