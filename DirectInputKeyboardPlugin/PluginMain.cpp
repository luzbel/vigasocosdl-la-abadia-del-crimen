// PluginMain.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "DirectInputKeyboardPlugin.h"

static const char *description = "VIGASOCO DirectInput Keyboard Plugin v1.0";

static const char *plugins[] = {
	{ "DIKeyb" }
};

/////////////////////////////////////////////////////////////////////////////
// plugin creation/destruction
/////////////////////////////////////////////////////////////////////////////

extern "C" __declspec(dllexport)
IInputPlugin *createPlugin(Win32Settings *settings, const char *name)
{
	if (strcmp(name, plugins[0]) == 0){
		return new DirectInputKeyboardPlugin(settings);
	} else {
		return 0;
	}
}

extern "C" __declspec(dllexport)
void destroyPlugin(IInputPlugin *plugin)
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
	return INPUT_PLUGIN;
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
