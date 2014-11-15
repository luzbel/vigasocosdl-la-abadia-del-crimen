// LinuxSDLWindow8bpp.h
//
//      Class that implements a Linux SDL Windowed 8bpp mode Plugin
//
//	Solo se implementa el minimo de funciones necesarias, y no todas
//	las del interfaz IDrawPlugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_WINDOW_8BPP_H_
#define _LINUX_SDL_WINDOW_8BPP_H_


#include "IDrawPlugin.h"
#include "LinuxSDL8bpp.h"

class LinuxSDLWindow8bpp : public LinuxSDL8bpp
{
public:
	LinuxSDLWindow8bpp(){ }
	 ~LinuxSDLWindow8bpp(){}
};

#endif // _LINUX_SDL_WINDOW_16BPP_H_
