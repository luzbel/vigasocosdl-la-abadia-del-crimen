// VigasocoWin32.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "IDrawPlugin.h"
#include "Win32Palette.h"
#include "FileLoader.h"
#include "FontManager.h"
#include "IInputPlugin.h"
#include "InputHandler.h"
#include "TimingHandler.h"
#include "VigasocoWin32.h"
#include "RDTSCTimer.h"
#include "Win32CriticalSection.h"
#include "Win32Thread.h"
#include "Win32Settings.h"

// current plugin versions
int VigasocoWin32::g_currentVideoPluginVersion = 1;
int VigasocoWin32::g_currentInputPluginVersion = 1;
int VigasocoWin32::g_currentLoaderPluginVersion = 1;

// paths for the plugins
std::string VigasocoWin32::g_videoPluginPath = "video/";
std::string VigasocoWin32::g_inputPluginPath = "input/";
std::string VigasocoWin32::g_loaderPluginPath = "loaders/";

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

VigasocoWin32::VigasocoWin32(HINSTANCE hInstance, std::string game, std::string drawPluginsDLL,
					std::string drawPlugin, Strings inputPluginsDLLs, Strings inputPlugins, Strings paths)
{
	_settings = new Win32Settings(hInstance, (LONG) this, VigasocoWin32::wndProc);
	_pluginHandler = 0;
	_game = game;

	_sDrawPluginsDLL = drawPluginsDLL;
	_sDrawPlugin = drawPlugin;
	_sInputPluginsDLLs = inputPluginsDLLs;
	_sInputPlugins = inputPlugins;
	_sPaths = paths;
}

VigasocoWin32::~VigasocoWin32()
{
	delete _settings;
}

/////////////////////////////////////////////////////////////////////////////
// platform services
/////////////////////////////////////////////////////////////////////////////

ICriticalSection * VigasocoWin32::createCriticalSection()
{
	return new Win32CriticalSection();
}

/////////////////////////////////////////////////////////////////////////////
// construction template methods overrides
/////////////////////////////////////////////////////////////////////////////

bool VigasocoWin32::platformSpecificInit()
{
	// creates the plugin handler
	_pluginHandler = new PluginHandler(_settings);

	return true;
}

void VigasocoWin32::createPalette()
{
	_palette = new Win32Palette();
}

void VigasocoWin32::addCustomLoaders(FileLoader *fl)
{
	HANDLE hSearch;
	WIN32_FIND_DATA findData;

	SetCurrentDirectory(g_loaderPluginPath.substr(0, g_loaderPluginPath.size() - 1).c_str());

	// traverse all the files in the loader directory searching for plugins
	hSearch = FindFirstFile("*.dll", &findData);
	if (hSearch != INVALID_HANDLE_VALUE){
		do {
			ILoader *customLoader = 0;
			DLLEntry entry;

			// try to load the plugin from the DLL
			if (_pluginHandler->loadPlugin(findData.cFileName, 
				"CustomLoader", LOADER_PLUGIN, g_currentLoaderPluginVersion, &entry)){
				customLoader = (ILoader *)entry.plugin;
			}

			if (customLoader != 0){
				// save DLL reference for later
				_loaderPluginsInfo.push_back(entry);

				// add the plugin to the fileLoader
				fl->addLoader(customLoader);
			}
		} while (FindNextFile(hSearch, &findData));
	}
	FindClose(hSearch);

	SetCurrentDirectory("..");

	// add optional paths to the file loader
	for (Strings::size_type i = 0; i < _sPaths.size(); i++){
		fl->addPath(_sPaths[i]);
	}
}

void VigasocoWin32::createDrawPlugin()
{
	// load the plugin from a DLL
	if (_pluginHandler->loadPlugin(g_videoPluginPath + _sDrawPluginsDLL, 
		_sDrawPlugin, VIDEO_PLUGIN, g_currentVideoPluginVersion, &_drawPluginInfo)){
		_drawPlugin = (IDrawPlugin *)_drawPluginInfo.plugin;
	}

	if (_drawPlugin != 0){
		// TODO: set plugin properties
	}
}

void VigasocoWin32::addCustomInputPlugins()
{
	for (Strings::size_type i = 0; i < _sInputPluginsDLLs.size(); i++){
		DLLEntry entry;
		IInputPlugin *ip = 0;

		// load the plugin from a DLL
		if (_pluginHandler->loadPlugin(g_inputPluginPath + _sInputPluginsDLLs[i], 
			_sInputPlugins[i], INPUT_PLUGIN, g_currentInputPluginVersion, &entry)){
			ip = (IInputPlugin *)entry.plugin;
		}

		if (ip != 0){
			// TODO: set plugin properties

			// save DLL reference for later
			_inputPluginsInfo.push_back(entry);	

			_inputHandler->addInputPlugin(ip);
		}
	}
}

void VigasocoWin32::createTimer()
{
	_timer = new RDTSCTimer();
}

void VigasocoWin32::createAsyncThread()
{
	_asyncThread = new Win32Thread();
}

void VigasocoWin32::initCompleted()
{
	SetWindowText(_settings->getHWnd(), ("VIGASOCO v0.02: " + _driver->getFullName()).c_str());
}

/////////////////////////////////////////////////////////////////////////////
// destruction template methods overrides
/////////////////////////////////////////////////////////////////////////////

void VigasocoWin32::destroyAsyncThread()
{
	delete _asyncThread;
	_asyncThread = 0;
}

void VigasocoWin32::destroyTimer()
{
	delete _timer;
	_timer = 0;
}

void VigasocoWin32::removeCustomInputPlugins()
{
	// delete the plugins and free DLLs
	for (DLLEntries::size_type i = 0; i < _inputPluginsInfo.size(); i++){
		_inputHandler->removeInputPlugin((IInputPlugin *)_inputPluginsInfo[i].plugin);
		_pluginHandler->unloadPlugin(&_inputPluginsInfo[i]);
	}
	_inputPluginsInfo.clear();
}

void VigasocoWin32::destroyDrawPlugin()
{
	_pluginHandler->unloadPlugin(&_drawPluginInfo);
}

void VigasocoWin32::removeCustomLoaders(FileLoader *fl)
{
	// delete the plugins and free DLLs
	for (DLLEntries::size_type i = 0; i < _loaderPluginsInfo.size(); i++){
		fl->removeLoader((ILoader *)_loaderPluginsInfo[i].plugin);
		_pluginHandler->unloadPlugin(&_loaderPluginsInfo[i]);
	}
	_loaderPluginsInfo.clear();
}

void VigasocoWin32::destroyPalette()
{
	delete _palette;
	_palette = 0;
}

void VigasocoWin32::platformSpecificEnd()
{
	assert(!_drawPluginInfo.libHandle);
	assert(_inputPluginsInfo.size() == 0);
	assert(_loaderPluginsInfo.size() == 0);

	delete _pluginHandler;
	_pluginHandler = 0;
} 

/////////////////////////////////////////////////////////////////////////////
// main loop template methods overrides
/////////////////////////////////////////////////////////////////////////////

bool VigasocoWin32::processEvents()
{
	// dispatch window messages
	MSG msg;
	if (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)){
		DispatchMessage(&msg);
	}

	// if the application window has been closed or ESC has been pressed, exit
	if (msg.message == WM_QUIT){
		return false;
	}

	return true;
}

/////////////////////////////////////////////////////////////////////////////
// window procedure
/////////////////////////////////////////////////////////////////////////////

// windows function
LRESULT CALLBACK VigasocoWin32::wndProc(HWND hWnd, UINT iMsg, WPARAM wParam, LPARAM lParam)
{
	VigasocoWin32 *vigasoco = (VigasocoWin32 *)GetWindowLong(hWnd, GWL_USERDATA);
	IDrawPlugin *dp = (vigasoco != 0) ? vigasoco->getDrawPlugin() : 0;

	switch (iMsg){
		//////////////////////////////////
		// redrawing messages
		//////////////////////////////////

		// redraw non client area if we're in windowed mode
		case WM_NCPAINT:
			if (dp && dp->isFullScreen()){
				return 0;
			}
			break;

		// redraw the window
		case WM_PAINT:
		{
			// redraw last rendered frame
			if (dp){
				if (dp->isInitialized()){
					dp->render(vigasoco->getTimingHandler()->isThrottling());
				}
			}

			// validates the client area
			RECT rect;
			GetClientRect(hWnd, &rect);
			ValidateRect(hWnd, &rect);

			return 0;
		}

		//////////////////////////////////
		// keyboard messages
		//////////////////////////////////

		// ignore keyboard messages but ESC
		case WM_SYSKEYUP:
		case WM_SYSKEYDOWN:
		case WM_KEYUP:
		case WM_CHAR:
			return 0;

		case WM_KEYDOWN:
			if ((int)wParam == VK_ESCAPE){
				PostQuitMessage(0);
			}
			return 0;

		//////////////////////////////////
		// gain/lost focus
		//////////////////////////////////

		case WM_ACTIVATEAPP:
			if (vigasoco->getInputHandler()){
				if (wParam){
					vigasoco->getInputHandler()->acquire();
				} else {
					vigasoco->getInputHandler()->unAcquire();
				}
			}
			return 0;

		//////////////////////////////////
		// close application messages
		//////////////////////////////////

		// if the window has been closed, send a WM_QUIT message
		case WM_CLOSE:
			PostQuitMessage(0);
			return 0;

	}

	// default message processing
	return DefWindowProc (hWnd, iMsg, wParam, lParam);
}
