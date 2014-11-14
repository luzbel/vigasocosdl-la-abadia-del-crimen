// LinuxSDLBasicDrawPlugin.h
//
//      Abstract class with basic drawing functionality
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_BASIC_DRAW_PLUGIN_H_
#define _LINUX_SDL_BASIC_DRAW_PLUGIN_H_

#include "IDrawPlugin.h"
#include "SDL.h"
#include "util/INotificationSuscriber.h"

class LinuxSDLBasicDrawPlugin: public IDrawPlugin,public INotificationSuscriber<IPalette>
{
protected:
        SDL_Surface *screen;
	SDL_Surface *surface;
	UINT32 *_palette;
	bool _isInitialized;
	UINT32 _flags;
	int _bpp;
private:
	IPalette *_originalPalette;
public:
	LinuxSDLBasicDrawPlugin(){ screen = NULL; _palette = NULL; _isInitialized=false; _flags=0; _bpp=8; _originalPalette=NULL; }
	 virtual ~LinuxSDLBasicDrawPlugin(){}
	 virtual bool init(const VideoInfo *vi, IPalette *pal) = 0 ;
	 void end() ;

	// getters
	 virtual bool isInitialized() const ;
	 virtual bool isFullScreen() const  = 0;

	// bitmap creation/destruction
	 virtual int createBitmap(int width, int height)  = 0;
	 virtual void destroyBitmap(int bitmap)  = 0;

	// bitmap methods
	 virtual void setActiveBitmap(int bitmap) = 0;
	 virtual void compose(int bitmap, int mode, int attr) = 0;
	 virtual void getDimensions(int &width, int &height) const = 0;

	// clipping methods
	 virtual const Rect *getClipArea() const = 0;
	 virtual void setClipArea(int x, int y, int width, int height) = 0;
	 virtual void setNoClip() = 0;

	// drawing methods
	 virtual void render(bool throttle) = 0;

	 virtual void setPixel(int x, int y, int color) = 0;

	 virtual void drawLine(int x0, int y0, int x1, int y1, int color) = 0;
	 virtual void drawRect(Rect *rect, int color) = 0;
	 virtual void drawRect(int x0, int y0, int width, int height, int color) = 0;
	 virtual void drawCircle(int x, int y, int radius, int color) = 0;
	 virtual void drawEllipse(int x, int y, int a, int b, int color) = 0;

	 virtual void fillRect(Rect *rect, int color) = 0;
	 virtual void fillRect(int x0, int y0, int width, int height, int color) = 0;
	 virtual void fillCircle(int x, int y, int radius, int color) = 0;
	 virtual void fillEllipse(int x, int y, int a, int b, int color) = 0;

	 virtual void drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr) = 0;
	 virtual void drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr) = 0;
	 virtual void drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) = 0;
	 virtual void drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) = 0;

	// access to custom plugin properties
	 virtual const std::string *getProperties(int *num) const = 0;
	 virtual const int *getPropertiesType() const = 0;
	 virtual void setProperty(std::string prop, int data) = 0;
	 virtual void setProperty(std::string prop, int index, int data) = 0;
	 virtual int getProperty(std::string prop) const = 0;
	 virtual int getProperty(std::string prop, int index) const = 0;
protected:
	// palette changed notification
//	virtual void update(IPalette *palette, int data);
//	void updateFullPalette(IPalette *palette);
};

#endif // _LINUX_SDL_BASIC_DRAW_PLUGIN_H_
