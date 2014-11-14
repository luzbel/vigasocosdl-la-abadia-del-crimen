// LinuxSDL24bpp.h
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_24BPP_H_
#define _LINUX_SDL_24BPP_H_

#include "LinuxSDLBasicDrawPlugin.h"

class LinuxSDL24bpp : public LinuxSDLBasicDrawPlugin
{
public:
	LinuxSDL24bpp(){ }
	 ~LinuxSDL24bpp(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal) ;

	 virtual void setPixel(int x, int y, int color);
};

#endif // _LINUX_SDL_24BPP_H_
