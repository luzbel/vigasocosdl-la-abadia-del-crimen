// PluginMain.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "DirectDrawFullScreen16bpp.h"
#include "DirectDrawFullScreen32bpp.h"
#include "DirectDrawFullScreenTB16bpp.h"
#include "DirectDrawFullScreenTB32bpp.h"
#include "DirectDrawWindow16bpp.h"
#include "DirectDrawWindow32bpp.h"

static const char *description = "VIGASOCO DirectDraw Plugins v1.0";

static const char *plugins[] = {
	{ "win16" },
	{ "win32" },
	{ "full16" },
	{ "full32" },
	{ "fullTB16" },
	{ "fullTB32" }
};

/////////////////////////////////////////////////////////////////////////////
// plugin creation/destruction
/////////////////////////////////////////////////////////////////////////////

extern "C" __declspec(dllexport) 
IDrawPlugin * createPlugin(Win32Settings *settings, const char *name)
{
	if (strcmp(name, plugins[0]) == 0){
		return new DirectDrawWindow16bpp(settings);
	} else if (strcmp(name, plugins[1]) == 0){
		return new DirectDrawWindow32bpp(settings);
	} else if (strcmp(name, plugins[2]) == 0){
		return new DirectDrawFullScreen16bpp(settings);
	} else if (strcmp(name, plugins[3]) == 0){
		return new DirectDrawFullScreen32bpp(settings);
	} else if (strcmp(name, plugins[4]) == 0){
		return new DirectDrawFullScreenTB16bpp(settings);
	} else if (strcmp(name, plugins[5]) == 0){
		return new DirectDrawFullScreenTB32bpp(settings);
	} else {
		return 0;
	}
}

extern "C" __declspec(dllexport)
void destroyPlugin(IDrawPlugin *plugin)
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
	return VIDEO_PLUGIN;
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
