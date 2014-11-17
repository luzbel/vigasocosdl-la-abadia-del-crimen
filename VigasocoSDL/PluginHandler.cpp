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
	void *hModule = SDL_LoadObject(DLLName.c_str());

	// if the system can't find the DLL, error
	if (hModule == NULL){
		return false;
	}

	// get address of the plugin interface functions
	CREATE_PLUGIN createPlugin = (CREATE_PLUGIN)SDL_LoadFunction(hModule, "createPlugin");
	DESTROY_PLUGIN destroyPlugin = (DESTROY_PLUGIN)SDL_LoadFunction(hModule, "destroyPlugin");
	GET_TYPE getVersion = (GET_TYPE)SDL_LoadFunction(hModule, "getVersion");
	GET_TYPE getType = (GET_TYPE)SDL_LoadFunction(hModule, "getType");
	GET_PLUGINS getPlugins = (GET_PLUGINS)SDL_LoadFunction(hModule, "getPlugins");
	GET_DESCRIPTION getDLLDescription = (GET_DESCRIPTION)SDL_LoadFunction(hModule, "getDLLDescription");

	// if the DLL doesn't have the interface, error
	if ((createPlugin == NULL) || (destroyPlugin == NULL) || (getVersion == NULL) || 
		(getType == NULL) || (getPlugins == NULL) || (getDLLDescription == NULL)){
		// free DLL
		SDL_UnloadObject(hModule);
		return false;
	}

	// if the DLL is not compatible
	if ((type != getType()) || (getVersion() < version))
	{
		// free DLL
		SDL_UnloadObject(hModule);
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
		SDL_UnloadObject(hModule);
		return false;
	}

	// everything went OK, copy DLL settings for later
	info->libHandle = hModule;
	info->createPlugin = createPlugin;
	info->destroyPlugin = destroyPlugin;
	info->description = getDLLDescription();
	createPlugin(pluginName.c_str(),&info->plugin);

	return true;
}

void PluginHandler::unloadPlugin(DLLEntry *info)
{
	// delete plugin and free DLL
	if (info->libHandle != 0){
		info->destroyPlugin(info->plugin);
		SDL_UnloadObject(info->libHandle);
		info->libHandle = 0;
		info->createPlugin = 0;
		info->destroyPlugin = 0;
		info->description = 0;
		info->plugin = 0;
	}
}
