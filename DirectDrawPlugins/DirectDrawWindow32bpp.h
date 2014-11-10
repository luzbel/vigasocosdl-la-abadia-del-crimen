// DirectDrawWindow32bpp.h
//
//	Class that implements a DirectDraw Windowed 32bpp mode Plugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _DIRECT_DRAW_WINDOW_32BPP_H_
#define _DIRECT_DRAW_WINDOW_32BPP_H_


#include "DirectDrawWindow.h"

class DirectDrawWindow32bpp : public DirectDrawWindow
{
// fields
protected:
	UINT32 *_palette;

// inherited methods
public:
	// initialization and cleanup
	DirectDrawWindow32bpp(Win32Settings *settings);
	virtual ~DirectDrawWindow32bpp();
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


#endif // _DIRECT_DRAW_WINDOW_32BPP_H