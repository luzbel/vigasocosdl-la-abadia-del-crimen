// PluginMain.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "ZipLoader.h"
#include "Win32Settings.h"

static const char *description = "VIGASOCO Zip Loader Plugin v1.0 (using ZipArchive library)";

static const char *plugins[] = {
	{ "CustomLoader" }
};

/////////////////////////////////////////////////////////////////////////////
// plugin creation/destruction
/////////////////////////////////////////////////////////////////////////////

extern "C" __declspec(dllexport)
ILoader *createPlugin(Win32Settings *settings, const char *name)
{
	if (strcmp(name, plugins[0]) == 0){
		return new ZipLoader();
	} else {
		return 0;
	}
}

extern "C" __declspec(dllexport)
void destroyPlugin(ILoader *plugin)
{
	delete plugin;
}

/////////////////////////////////////////////////////////////////////////////
// plugin information
/////////////////////////////////////////////////////////////////////////////

extern "C" __declspec(dllexport)
int getVersion()
{
	return 1;
}

extern "C" __declspec(dllexport)
int getType()
{
	return LOADER_PLUGIN;
}

extern "C" __declspec(dllexport)
const char **getPlugins(int *num)
{
	*num = sizeof(plugins)/sizeof(plugins[0]);
	return plugins;
}

extern "C" __declspec(dllexport)
const char *getDLLDescription(int *num)
{
	return description;
}
