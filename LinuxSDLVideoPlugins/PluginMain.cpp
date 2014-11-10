// PluginMain.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLWindow32bpp.h"

#include "SDL.h"

static const char *description = "VIGASOCO Linux SDL Plugins v1.0";

static const char *plugins[] = {
	 "win32" ,
};

/////////////////////////////////////////////////////////////////////////////
// plugin creation/destruction
/////////////////////////////////////////////////////////////////////////////

extern "C" DECLSPEC
void createPlugin(const char *name,void**a)
{
	if (strcmp(name, plugins[0]) == 0){
		*a=new LinuxSDLWindow32bpp();
	} else {
		*a=NULL;
	}
}

extern "C" DECLSPEC
void destroyPlugin(IDrawPlugin *plugin)
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
	return VIDEO_PLUGIN;
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
