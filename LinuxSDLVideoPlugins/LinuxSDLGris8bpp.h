// LinuxSDLGris8bpp.h
//
//      Class that implements a Linux SDL Windowed 8bpp mode Plugin
//
//	Solo se implementa el minimo de funciones necesarias, y no todas
//	las del interfaz IDrawPlugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_GRIS_8BPP_H_
#define _LINUX_SDL_GRIS_8BPP_H_

#include "LinuxSDLBasicDrawPlugin.h"

class LinuxSDLGris8bpp : public SDLBasicDrawPluginT<UINT8,8>
{
public:
	LinuxSDLGris8bpp(){ }
	 ~LinuxSDLGris8bpp(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal);
};

#endif // _LINUX_SDL_GRIS_8BPP_H_
