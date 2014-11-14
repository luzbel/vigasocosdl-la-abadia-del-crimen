// LinuxSDL16bpp.h
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_16BPP_H_
#define _LINUX_SDL_16BPP_H_

#include "LinuxSDLBasicDrawPlugin.h"

class LinuxSDL16bpp : public LinuxSDLBasicDrawPlugin
{
	protected:
		UINT16 *_palette;
public:
	LinuxSDL16bpp(){ }
	 ~LinuxSDL16bpp(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal) ;

	 virtual void setPixel(int x, int y, int color);
protected:
	 // palette changed notification
	 virtual void update(IPalette *palette, int data);
	 void updateFullPalette(IPalette *palette);
};

#endif // _LINUX_SDL_16BPP_H_
