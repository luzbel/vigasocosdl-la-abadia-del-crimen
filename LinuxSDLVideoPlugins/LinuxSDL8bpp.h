// LinuxSDL8bpp.h
//
//      Class that implements a Linux SDL Windowed 8bpp mode Plugin
//
//	Solo se implementa el minimo de funciones necesarias, y no todas
//	las del interfaz IDrawPlugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_8BPP_H_
#define _LINUX_SDL_8BPP_H_


#include "IDrawPlugin.h"
#include "LinuxSDLBasicDrawPlugin.h"

typedef SDLBasicDrawPluginT<UINT8,8> LinuxSDL8bpp;

#endif // _LINUX_SDL_8BPP_H_
