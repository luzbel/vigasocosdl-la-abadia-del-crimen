// LinuxSDLWindow32bpp.h
//
//      Class that implements a Linux SDL Windowed 16bpp mode Plugin
//
//	Solo se implementa el minimo de funciones necesarias, y no todas
//	las del interfaz IDrawPlugin
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LINUX_SDL_WINDOW_16BPP_H_
#define _LINUX_SDL_WINDOW_16BPP_H_


#include "IDrawPlugin.h"
#include "LinuxSDLBasicDrawPlugin.h"

class LinuxSDLWindow32bpp : public LinuxSDLBasicDrawPlugin
{
public:
	LinuxSDLWindow32bpp(){ }
	 ~LinuxSDLWindow32bpp(){}
	 bool init(const VideoInfo *vi, IPalette *pal) ;
	 void end() ;

	// getters
	 bool isInitialized() const ;
	 bool isFullScreen() const ;

	// bitmap creation/destruction
	 int createBitmap(int width, int height) ;
	 void destroyBitmap(int bitmap) ;

	// bitmap methods
	 void setActiveBitmap(int bitmap) ;
	 void compose(int bitmap, int mode, int attr) ;
	 void getDimensions(int &width, int &height) const ;

	// clipping methods
	 const Rect *getClipArea() const ;
	 void setClipArea(int x, int y, int width, int height) ;
	 void setNoClip() ;

	// drawing methods
	 void render(bool throttle) ;

	 void setPixel(int x, int y, int color) ;

	 void drawLine(int x0, int y0, int x1, int y1, int color) ;
	 void drawRect(Rect *rect, int color) ;
	 void drawRect(int x0, int y0, int width, int height, int color) ;
	 void drawCircle(int x, int y, int radius, int color) ;
	 void drawEllipse(int x, int y, int a, int b, int color) ;

	 void fillRect(Rect *rect, int color) ;
	 void fillRect(int x0, int y0, int width, int height, int color) ;
	 void fillCircle(int x, int y, int radius, int color) ;
	 void fillEllipse(int x, int y, int a, int b, int color) ;

	 void drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr) ;
	 void drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr) ;
	 void drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) ;
	 void drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) ;

	// access to custom plugin properties
	 const std::string *getProperties(int *num) const ;
	 const int *getPropertiesType() const ;
	 void setProperty(std::string prop, int data) ;
	 void setProperty(std::string prop, int index, int data) ;
	 int getProperty(std::string prop) const ;
	 int getProperty(std::string prop, int index) const ;
	virtual void update(IPalette *palette, int data) {};
	void updateFullPalette(IPalette *palette) {};
};

#endif // _LINUX_SDL_WINDOW_16BPP_H_
