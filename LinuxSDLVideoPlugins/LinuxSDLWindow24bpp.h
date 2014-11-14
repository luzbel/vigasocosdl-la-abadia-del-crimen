// LinuxSDLWindow24bpp.h
//
//      Class that implements a Linux SDL Windowed 16bpp mode Plugin
//
//	Solo se implementa el minimo de funciones necesarias, y no todas
//	las del interfaz IDrawPlugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_WINDOW_24BPP_H_
#define _LINUX_SDL_WINDOW_24BPP_H_


#include "LinuxSDL24bpp.h"

class LinuxSDLWindow24bpp : public LinuxSDL24bpp
{
public:
	LinuxSDLWindow24bpp(){ }
	 ~LinuxSDLWindow24bpp(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal) ;
};

#endif // _LINUX_SDL_WINDOW_24BPP_H_
