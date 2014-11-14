// prueba fullscreen 24bpp, deberia compartir todo el codigo con la version para ventana de 24bpp
// y solo cambiar el flag del SetVideoMode

// LinuxSDLFullScreen24bpp.h
//
//      Class that implements a Linux SDL Windowed 16bpp mode Plugin
//
//	Solo se implementa el minimo de funciones necesarias, y no todas
//	las del interfaz IDrawPlugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_FULLSCREEN_24BPP_H_
#define _LINUX_SDL_FULLSCREEN_24BPP_H_

#include "LinuxSDL24bpp.h"

class LinuxSDLFullScreen24bpp : public LinuxSDL24bpp
{
public:
	LinuxSDLFullScreen24bpp(){ }
	 ~LinuxSDLFullScreen24bpp(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal) ;
};

#endif // _LINUX_SDL_FULLSCREEN_24BPP_H_
