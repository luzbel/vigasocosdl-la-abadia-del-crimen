// PluginHandler.h
//
//	Class that handles loading and unloading of shared library (.so) plugins with SDL in Linux
//
//	VIGASOCO shared library (.so) plugin format specification:
//		The calling convention used to call the plugin functions is C (extern "C" DECLSPEC)
//		The plugin should have 6 exported functions:
//		+ void createPlugin(const char *name,void **plugin); // Different from VIGASOCOWin32 version
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
#include "SDL_loadso.h"

typedef void (*CREATE_PLUGIN)(const char *,void**);
typedef void (*DESTROY_PLUGIN)(void *);
typedef int (*GET_VERSION)();
typedef int (*GET_TYPE)();
typedef const char ** (*GET_PLUGINS)(int *num);
typedef const char * (*GET_DESCRIPTION)();

struct DLLEntry {
	void *libHandle;
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

// methods
public:
	// initialization and cleanup
	~PluginHandler(){};

	// load/unload
	bool loadPlugin(std::string DLLName, std::string pluginName, PluginType type, int version, DLLEntry *info);
	void unloadPlugin(DLLEntry *info);
};

#endif	// _PLUGIN_HANDLER_H_
