// prueba fullscreen 16bpp, deberia compartir todo el codigo con la version para ventana de 16bpp
// y solo cambiar el flag del SetVideoMode

// LinuxSDLFullScreen16bpp.h
//
//      Class that implements a Linux SDL Windowed 16bpp mode Plugin
//
//	Solo se implementa el minimo de funciones necesarias, y no todas
//	las del interfaz IDrawPlugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_FULLSCREEN_16BPP_H_
#define _LINUX_SDL_FULLSCREEN_16BPP_H_

#include "LinuxSDL16bpp.h"

class LinuxSDLFullScreen16bpp : public LinuxSDL16bpp
{
public:
	LinuxSDLFullScreen16bpp(){ }
	 ~LinuxSDLFullScreen16bpp(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal) ;
};

#endif // _LINUX_SDL_FULLSCREEN_16BPP_H_
