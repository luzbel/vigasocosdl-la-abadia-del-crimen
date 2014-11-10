// PluginHandler.h
//
//	Class that handles loading and unloading of DLL plugins
//
//	VIGASOCO DLL plugin format specification:
//		The calling convention used to call the plugin functions is __cdecl.
//		The plugin should have 6 exported functions:
//		+ IPlugin * createPlugin(Win32Settings *settings, const char *name);
//		+ void destroyPlugin(IPlugin *plugin);
//		+ int getVersion();
//		+ int getType();
//		+ const char **getPlugins(int *num);
//		+ const char *getDLLDescription();
//
//	getVersion is used for version control, because a plugin's interface may
//	change in the future, and plugins using the obsolete interface,
//	will not be loaded.
//	Since all plugins have the same interface for creating and destroying 
//	them (createPlugin/destroyPlugin), getType is used to avoid loading a
//	plugin of completely different purpose by mistake.
//	getPlugins and getDLLDescription are for completeness and to allow
//	external applications figure out which plugins are exposed by a DLL.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _PLUGIN_HANDLER_H_
#define _PLUGIN_HANDLER_H_


#include "util/Singleton.h"
#include <string>
#include "Types.h"
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

class Win32Settings;	// defined in Win32Settings.h

typedef void * (*CREATE_PLUGIN)(Win32Settings *, const char *);
typedef void (*DESTROY_PLUGIN)(void *);
typedef int (*GET_VERSION)();
typedef int (*GET_TYPE)();
typedef const char ** (*GET_PLUGINS)(int *num);
typedef const char * (*GET_DESCRIPTION)();

struct DLLEntry {
	HMODULE libHandle;
	CREATE_PLUGIN createPlugin;
	DESTROY_PLUGIN destroyPlugin;
	const char *description;
	void *plugin;

	DLLEntry()
	{
		libHandle = 0;
		createPlugin = 0;
		destroyPlugin = 0;
		description = 0;
		plugin = 0;
	}
};

class PluginHandler : Singleton<PluginHandler>
{
// fields
protected:
	Win32Settings *_settings;

// methods
public:
	// initialization and cleanup
	PluginHandler(Win32Settings *settings) { _settings = settings; }
	~PluginHandler(){}

	// load/unload
	bool loadPlugin(std::string DLLName, std::string pluginName, PluginType type, int version, DLLEntry *info);
	void unloadPlugin(DLLEntry *info);
};


#endif	// _PLUGIN_HANDLER_H_
