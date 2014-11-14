// LinuxSDLWindow16bpp.h
//
//      Class that implements a Linux SDL Windowed 16bpp mode Plugin
//
//	Solo se implementa el minimo de funciones necesarias, y no todas
//	las del interfaz IDrawPlugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_WINDOW_16BPP_H_
#define _LINUX_SDL_WINDOW_16BPP_H_


#include "LinuxSDL16bpp.h"

class LinuxSDLWindow16bpp : public LinuxSDL16bpp
{
public:
	LinuxSDLWindow16bpp(){ }
	 ~LinuxSDLWindow16bpp(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal) ;
};

#endif // _LINUX_SDL_WINDOW_16BPP_H_
