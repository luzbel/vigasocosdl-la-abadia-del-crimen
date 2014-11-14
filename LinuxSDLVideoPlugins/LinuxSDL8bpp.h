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

class LinuxSDL8bpp : public LinuxSDLBasicDrawPlugin
{
public:
	LinuxSDL8bpp(){ }
	 ~LinuxSDL8bpp(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal);

	// drawing methods
	 virtual void render(bool throttle) ;

	 virtual void setPixel(int x, int y, int color) ;

protected:
	         // palette changed notification
         virtual void update(IPalette *palette, int data);
                 void updateFullPalette(IPalette *palette);
};

#endif // _LINUX_SDL_8BPP_H_
