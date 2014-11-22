// PluginMain.cpp
//
/////////////////////////////////////////////////////////////////////////////

// Para DECLSPEC en SDL_loadso.h
#include "SDL.h"

#include "SDLInputKeyboardPlugin.h"

static const char *description = "VIGASOCO SDL Keyboard Plugin v1.0";

static const char *plugins[] = {
	"SDLInputPlugin" 
};

/////////////////////////////////////////////////////////////////////////////
// plugin creation/destruction
/////////////////////////////////////////////////////////////////////////////

extern "C" DECLSPEC
void createPlugin(const char *name,void**plugin)
{
	if (strcmp(name, plugins[0]) == 0){
		*plugin = new SDLInputKeyboardPlugin();
	} else {
		*plugin = NULL;
	}
}

extern "C" DECLSPEC
void destroyPlugin(IInputPlugin *plugin)
{
	delete plugin;
}

/////////////////////////////////////////////////////////////////////////////
// plugin information
/////////////////////////////////////////////////////////////////////////////

extern "C" DECLSPEC
int getVersion()
{
	return 1;
}

extern "C" DECLSPEC
int getType()
{
	return INPUT_PLUGIN;
}

extern "C" DECLSPEC
const char **getPlugins(int *num)
{
	*num = sizeof(plugins)/sizeof(plugins[0]);
	return plugins;
}

extern "C" DECLSPEC
const char *getDLLDescription(int *num)
{
	return description;
}
