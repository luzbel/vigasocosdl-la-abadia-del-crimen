// DirectDrawFullScreen32bpp.h
//
//	Class that implements a DirectDraw FullScreen 32bpp mode Plugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _DIRECT_DRAW_FULLSCREEN_32BPP_H_
#define _DIRECT_DRAW_FULLSCREEN_32BPP_H_


#include "DirectDrawFullScreen.h"

class DirectDrawFullScreen32bpp : public DirectDrawFullScreen
{
// fields
protected:
	UINT32 *_palette;

// inherited methods
public:
	// initialization and cleanup
	DirectDrawFullScreen32bpp(Win32Settings *settings);
	virtual ~DirectDrawFullScreen32bpp();
	virtual bool init(const VideoInfo *vi, IPalette *pal);
	virtual void end();

	// drawing functions
	virtual void render(bool throttle);

	virtual void setPixel(int x, int y, int color);

	virtual void drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr);
	virtual void drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr);
	virtual void drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData);
	virtual void drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData);
};


#endif // _DIRECT_DRAW_FULLSCREEN_32BPP_H