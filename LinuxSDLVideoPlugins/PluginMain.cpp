// PluginMain.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLWindow8bpp.h"
#include "LinuxSDLWindow16bpp.h"
#include "LinuxSDLWindow24bpp.h"
#include "LinuxSDLWindow32bpp.h"
#include "LinuxSDLFullScreen8bpp.h"
#include "LinuxSDLFullScreen16bpp.h"
#include "LinuxSDLFullScreen24bpp.h"
#include "LinuxSDLFullScreen32bpp.h"

#include "SDL.h"

static const char *description = "VIGASOCO Linux SDL Plugins v1.0";

static const char *plugins[] = {
	 "win8" , "win16" , "win24", "win32", "full8" , "full16", "full24" , "full32"
};

/////////////////////////////////////////////////////////////////////////////
// plugin creation/destruction
/////////////////////////////////////////////////////////////////////////////

extern "C" DECLSPEC
void createPlugin(const char *name,void**a)
{
	if (strcmp(name, plugins[0]) == 0){
		*a=new LinuxSDLWindow8bpp(); 
	} else if (strcmp(name, plugins[1]) == 0){
		*a=new LinuxSDLWindow16bpp();
	} else if (strcmp(name, plugins[2]) == 0){
		*a=new LinuxSDLWindow24bpp();
	} else if (strcmp(name, plugins[3]) == 0){
		*a=new LinuxSDLWindow32bpp();
	} else if (strcmp(name, plugins[4]) == 0){
		*a=new LinuxSDLFullScreen8bpp();
	} else if (strcmp(name, plugins[5]) == 0){
		*a=new LinuxSDLFullScreen16bpp();
	} else if (strcmp(name, plugins[6]) == 0){
		*a=new LinuxSDLFullScreen24bpp();
	} else if (strcmp(name, plugins[7]) == 0){
		*a=new LinuxSDLFullScreen24bpp();
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
