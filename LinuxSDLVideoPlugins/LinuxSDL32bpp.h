// LinuxSDL32bpp.h
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_32BPP_H_
#define _LINUX_SDL_32BPP_H_

#include "LinuxSDLBasicDrawPlugin.h"

class LinuxSDL32bpp : public LinuxSDLBasicDrawPlugin
{
public:
	LinuxSDL32bpp(){ }
	 ~LinuxSDL32bpp(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal) ;

	 virtual void render(bool throttle);
	 virtual void setPixel(int x, int y, int color);
};

#endif // _LINUX_SDL_32BPP_H_
