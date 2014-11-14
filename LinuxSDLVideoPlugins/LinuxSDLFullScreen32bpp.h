// prueba fullscreen 32bpp, deberia compartir todo el codigo con la version para ventana de 32bpp
// y solo cambiar el flag del SetVideoMode

// LinuxSDLFullScreen32bpp.h
//
//      Class that implements a Linux SDL Windowed 16bpp mode Plugin
//
//	Solo se implementa el minimo de funciones necesarias, y no todas
//	las del interfaz IDrawPlugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_FULLSCREEN_32BPP_H_
#define _LINUX_SDL_FULLSCREEN_32BPP_H_

#include "LinuxSDL32bpp.h"

class LinuxSDLFullScreen32bpp : public LinuxSDL32bpp
{
public:
	LinuxSDLFullScreen32bpp(){ }
	 ~LinuxSDLFullScreen32bpp(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal) ;

	 virtual void render(bool throttle);
	 virtual void setPixel(int x, int y, int color);
};

#endif // _LINUX_SDL_FULLSCREEN_32BPP_H_
