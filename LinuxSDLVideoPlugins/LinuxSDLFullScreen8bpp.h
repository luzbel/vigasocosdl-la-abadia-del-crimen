// LinuxSDLFullScreen8bpp.h
//
//      Class that implements a Linux SDL Windowed 8bpp mode Plugin
//
//	Solo se implementa el minimo de funciones necesarias, y no todas
//	las del interfaz IDrawPlugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_FULLSCREEN_8BPP_H_
#define _LINUX_SDL_FULLSCREEN_8BPP_H_


#include "IDrawPlugin.h"
#include "LinuxSDL8bpp.h"

class LinuxSDLFullScreen8bpp : public LinuxSDL8bpp
{
public:
	LinuxSDLFullScreen8bpp(){ }
	 ~LinuxSDLFullScreen8bpp(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal) ;
};

#endif // _LINUX_SDL_FULLSCREEN_8BPP_H_
