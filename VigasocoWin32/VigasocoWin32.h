// VigasocoWin32.h
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _VIGASOCO_WIN32_H_
#define _VIGASOCO_WIN32_H_


#include "Vigasoco.h"
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "PluginHandler.h"
#include "ILoader.h"
#include <string>
#include <vector>

class Win32Settings;	// defined in Win32Settings.h

class VigasocoWin32 : public Vigasoco
{
// types
public:
	typedef std::vector<std::string> Strings;

// constants
protected:
	static int g_currentVideoPluginVersion;
	static int g_currentInputPluginVersion;
	static int g_currentLoaderPluginVersion;

	static std::string g_videoPluginPath;
	static std::string g_inputPluginPath;
	static std::string g_loaderPluginPath;

// types
protected:
	typedef std::vector<DLLEntry> DLLEntries;

// fields
protected:
	Win32Settings *_settings;

	// port options
	std::string _sDrawPluginsDLL;
	std::string _sDrawPlugin;
	Strings _sInputPluginsDLLs;
	Strings _sInputPlugins;
	Strings _sPaths;

	// DLL stuff
	PluginHandler *_pluginHandler;
	DLLEntry _drawPluginInfo;
	DLLEntries _inputPluginsInfo;
	DLLEntries _loaderPluginsInfo;

// methods
public:
	// initialization and cleanup
	VigasocoWin32(HINSTANCE hInstance, std::string game, std::string drawPluginsDLL,
					std::string drawPlugin, Strings inputPluginsDLLs, 
					Strings inputPlugins, Strings paths);
	virtual ~VigasocoWin32();

	// platform services
	virtual ICriticalSection *createCriticalSection();

protected:
	// template methods overrides

	// construction
	virtual bool platformSpecificInit();
	virtual void createPalette();
	virtual void addCustomLoaders(FileLoader *fl);
	virtual void createDrawPlugin();
	virtual void addCustomInputPlugins();
	virtual void createTimer();
	virtual void createAsyncThread();
	virtual void initCompleted();

	// destruction
	virtual void destroyAsyncThread();
	virtual void destroyTimer();
	virtual void removeCustomInputPlugins();
	virtual void destroyDrawPlugin();
	virtual void removeCustomLoaders(FileLoader *fl);
	virtual void destroyPalette();
	virtual void platformSpecificEnd();

	virtual bool processEvents();

private:
	static LRESULT CALLBACK wndProc(HWND hWnd, UINT iMsg, WPARAM wParam, LPARAM lParam);
};

#endif	// _VIGASOCO_WIN32_H_
