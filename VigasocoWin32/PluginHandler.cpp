// PluginHandler.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "PluginHandler.h"

/////////////////////////////////////////////////////////////////////////////
// load/unload
/////////////////////////////////////////////////////////////////////////////

bool PluginHandler::loadPlugin(std::string DLLName, std::string pluginName, PluginType type, int version, DLLEntry *info)
{
	// load DLL
	HMODULE hModule = (HMODULE)LoadLibrary(DLLName.c_str());

	// if the system can't find the DLL, error
	if (hModule == NULL){
		return false;
	}

	// get address of the plugin interface functions
	CREATE_PLUGIN createPlugin = (CREATE_PLUGIN)GetProcAddress(hModule, "createPlugin");
	DESTROY_PLUGIN destroyPlugin = (DESTROY_PLUGIN)GetProcAddress(hModule, "destroyPlugin");
	GET_TYPE getVersion = (GET_TYPE)GetProcAddress(hModule, "getVersion");
	GET_TYPE getType = (GET_TYPE)GetProcAddress(hModule, "getType");
	GET_PLUGINS getPlugins = (GET_PLUGINS)GetProcAddress(hModule, "getPlugins");
	GET_DESCRIPTION getDLLDescription = (GET_DESCRIPTION)GetProcAddress(hModule, "getDLLDescription");

	// if the DLL doesn't have the interface, error
	if ((createPlugin == NULL) || (destroyPlugin == NULL) || (getVersion == NULL) || 
		(getType == NULL) || (getPlugins == NULL) || (getDLLDescription == NULL)){
		// free DLL
		FreeLibrary(hModule);
		return false;
	}

	// if the DLL is not compatible
	if ((type != getType()) || (getVersion() < version))
	{
		// free DLL
		FreeLibrary(hModule);
		return false;
	}

	// if the plugin isn't one of the available types, exit
	int num;
	const char ** plugins = getPlugins(&num);

	bool found = false;
	for (int i = 0; i < num; i++){
		if (pluginName.compare(plugins[i]) == 0){
			found = true;
			break;
		}
	}

	if (!found){
		// free DLL
		FreeLibrary(hModule);
		return false;
	}

	// everything went OK, copy DLL settings for later
	info->libHandle = hModule;
	info->createPlugin = createPlugin;
	info->destroyPlugin = destroyPlugin;
	info->description = getDLLDescription();
	info->plugin = createPlugin(_settings, pluginName.c_str());

	return true;
}

void PluginHandler::unloadPlugin(DLLEntry *info)
{
	// delete plugin and free DLL
	if (info->libHandle != 0){
		info->destroyPlugin(info->plugin);
		FreeLibrary(info->libHandle);

		info->libHandle = 0;
		info->createPlugin = 0;
		info->destroyPlugin = 0;
		info->description = 0;
		info->plugin = 0;
	}
}
