// LinuxSDLWindow32bpp.h
//
//      Class that implements a Linux SDL Windowed 16bpp mode Plugin
//
//	Solo se implementa el minimo de funciones necesarias, y no todas
//	las del interfaz IDrawPlugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_WINDOW_32BPP_H_
#define _LINUX_SDL_WINDOW_32BPP_H_


#include "LinuxSDL32bpp.h"

class LinuxSDLWindow32bpp : public LinuxSDL32bpp
{
public:
	LinuxSDLWindow32bpp(){ }
	 ~LinuxSDLWindow32bpp(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal) ;
};

#endif // _LINUX_SDL_WINDOW_32BPP_H_
