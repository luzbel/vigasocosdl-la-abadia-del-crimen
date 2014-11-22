// SDLBasicDrawPlugin.h
//
//      Template with basic drawing functionality
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _SDL_BASIC_DRAW_PLUGIN_H_
#define _SDL_BASIC_DRAW_PLUGIN_H_

#include "SDLDrawPlugin.h"

class DEFAULT
{
	public:
		static const Uint32 flags;
		static const int bpp;
};

template<typename T>
class SDLBasicDrawPlugin : public SDLDrawPlugin
{
protected:
	SDL_mutex *cs;
//Sint16 minX,minY,maxX,maxY;
//SDL_Rect r2;
bool updated;
//bool updatedr1;
//bool updatedr2;
        SDL_Surface *screen;
	SDL_Surface *surface;
	bool _isInitialized;
	UINT32 _flags;
	int _bpp;
	T *_palette;
private:
	IPalette *_originalPalette;
public:
	SDLBasicDrawPlugin(){ cs=SDL_CreateMutex(); screen = NULL; surface = NULL; _isInitialized=false; _flags = DEFAULT::flags; _bpp = DEFAULT::bpp ; _palette = NULL; _originalPalette=NULL; }
	virtual ~SDLBasicDrawPlugin(){ SDL_DestroyMutex(cs); }
	virtual bool init(const VideoInfo *vi, IPalette *pal);
	virtual void end(void);
	// getters
	 virtual bool isInitialized() const { return _isInitialized; };
	 virtual bool isFullScreen() const  {};

	// bitmap creation/destruction
	 virtual int createBitmap(int width, int height)  {};
	 virtual void destroyBitmap(int bitmap)  {};

	// bitmap methods
	 virtual void setActiveBitmap(int bitmap) {};
	 virtual void compose(int bitmap, int mode, int attr) {};
	 virtual void getDimensions(int &width, int &height) const {};

	// clipping methods
	 virtual const Rect *getClipArea() const {};
	 virtual void setClipArea(int x, int y, int width, int height) {};
	 virtual void setNoClip() {};

	// drawing methods
	 virtual void render(bool throttle);
	virtual void setPixel(int x, int y, int color);

	 virtual void drawLine(int x0, int y0, int x1, int y1, int color) {};
	 virtual void drawRect(Rect *rect, int color) {};
	 virtual void drawRect(int x0, int y0, int width, int height, int color) {};
	 virtual void drawCircle(int x, int y, int radius, int color) {};
	 virtual void drawEllipse(int x, int y, int a, int b, int color) {};

	 virtual void fillRect(Rect *rect, int color) {};
	 virtual void fillRect(int x0, int y0, int width, int height, int color);
	 virtual void fillCircle(int x, int y, int radius, int color) {};
	 virtual void fillEllipse(int x, int y, int a, int b, int color) {};

	 virtual void drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr) {};
	 virtual void drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr) {};
	 virtual void drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) {};
	 virtual void drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) {};

	// access to custom plugin properties
	 virtual const std::string *getProperties(int *num) const {};
	 virtual const int *getPropertiesType() const {};
	 virtual void setProperty(std::string prop, int data) {};
	 virtual void setProperty(std::string prop, int index, int data) {};
	 virtual int getProperty(std::string prop) const {};
	 virtual int getProperty(std::string prop, int index) const {};
private:
	// helper methods
	void fillScanLine(int x0, int x1, int y, int color);
protected:
	// palette changed notification
	virtual void update(IPalette *palette, int data);
	virtual void updateFullPalette(IPalette *palette);
};

#include "SDLBasicDrawPluginTemplates.cpp"

#endif // _SDL_BASIC_DRAW_PLUGIN_H_
