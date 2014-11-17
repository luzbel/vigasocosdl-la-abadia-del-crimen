// PluginMain.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "SDLVideoPlugins.h"

#include "SDL.h"

static const char *description = "VIGASOCO Linux SDL Plugins v1.1";

static const char *plugins[] = {
	 "win8"  , "win16" , "win24"  , "win32"  , "wingris8" ,
	 "full8" , "full16", "full24" , "full32" , "fullgris8"
};

/////////////////////////////////////////////////////////////////////////////
// plugin creation/destruction
/////////////////////////////////////////////////////////////////////////////

extern "C" DECLSPEC
void createPlugin(const char *name,void**a)
{
	if (strcmp(name, plugins[0]) == 0){
		*a=new SDLDrawPluginWindow8bpp(); 
	} else if (strcmp(name, plugins[1]) == 0){
		*a=new SDLDrawPluginWindow16bpp();
	} else if (strcmp(name, plugins[2]) == 0){
		*a=new SDLDrawPluginWindow24bpp();
	} else if (strcmp(name, plugins[3]) == 0){
		*a=new SDLDrawPluginWindow32bpp();
	} else if (strcmp(name, plugins[4]) == 0){
		*a=new SDLDrawPluginWindowPaletaGrises8bpp();
	} else if (strcmp(name, plugins[5]) == 0){
		*a=new SDLDrawPluginFullScreen8bpp();
	} else if (strcmp(name, plugins[6]) == 0){
		*a=new SDLDrawPluginFullScreen16bpp();
	} else if (strcmp(name, plugins[7]) == 0){
		*a=new SDLDrawPluginFullScreen24bpp();
	} else if (strcmp(name, plugins[8]) == 0){
		*a=new SDLDrawPluginFullScreen32bpp();
	} else if (strcmp(name, plugins[9]) == 0){
		*a=new SDLDrawPluginFullScreenPaletaGrises8bpp();
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
