// BasicDrawPlugin.h
//
//	Abstract class with basic drawing functionality
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _BASIC_DRAW_PLUGIN_H_
#define _BASIC_DRAW_PLUGIN_H_

#include <vector>
#include "IDrawPlugin.h"
#include "Bitmap.h"

class BasicDrawPlugin : public IDrawPlugin
{
// types
protected:
	typedef std::vector<Bitmap *> GameBitmaps;
// fields
protected:
	// game data
	int _gameWidth, _gameHeight;
	int _numColors;
	int _visAreaOffsX, _visAreaOffsY;
	int _visAreaWidth, _visAreaHeight;

	// plugin data
	int _bpp;
	int _refreshRate;
	bool _fullScreen;
	bool _vSync;
	bool _isInitialized;

	GameBitmaps _bitmaps;				// all game bitmaps
	Bitmap *_actualBitmap;				// current screen bitmap

	std::string _errorMsg;				// error message

// methods
public:
	// initialization and cleanup
	BasicDrawPlugin();
	virtual ~BasicDrawPlugin();
	virtual bool init(const VideoInfo *vi, IPalette *pal) = 0;
	virtual void end() = 0;

	// getters
	virtual bool isInitialized() const { return _isInitialized; }
	virtual bool isFullScreen() const { return _fullScreen; }

	// bitmap creation/destruction
	virtual int createBitmap(int width, int height);
	virtual void destroyBitmap(int bitmap);

	// bitmap methods
	virtual void setActiveBitmap(int bitmap);
	virtual void compose(int bitmap, int mode, int attr);
	virtual void getDimensions(int &width, int &height) const;

	// clipping methods
	virtual const Rect *getClipArea() const;
	virtual void setClipArea(int x, int y, int width, int height);
	virtual void setNoClip();

	// drawing functions
	virtual void render(bool throttle) = 0;

	virtual void setPixel(int x, int y, int color) = 0;

	virtual void drawLine(int x0, int y0, int x1, int y1, int color);
	virtual void drawRect(Rect *rect, int color);
	virtual void drawRect(int x0, int y0, int width, int height, int color);
	virtual void drawCircle(int x, int y, int radius, int color);
	virtual void drawEllipse(int x, int y, int a, int b, int color);

	virtual void fillRect(Rect *rect, int color);
	virtual void fillRect(int x0, int y0, int width, int height, int color);
	virtual void fillCircle(int x, int y, int radius, int color);
	virtual void fillEllipse(int x, int y, int a, int b, int color);

	virtual void drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr) = 0;
	virtual void drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr) = 0;
	virtual void drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) = 0;
	virtual void drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) = 0;

	// custom properties
	virtual const std::string *getProperties(int *num) const;
	virtual const int *getPropertiesType() const;
	virtual void setProperty(std::string prop, int data);
	virtual void setProperty(std::string prop, int index, int data);
	virtual int getProperty(std::string prop) const;
	virtual int getProperty(std::string prop, int index) const;

// helper methods
private:
	void fillScanLine(int x0, int x1, int y, int color);

	void drawSymmetrical4Points(int x, int y, int centX, int centY, int color);
	void drawSymmetrical8Points(int x, int y, int centX, int centY, int color);
	void fillSymmetrical2ScanLines(int x, int y, int centX, int centY, int color);
	void fillSymmetrical4ScanLines(int x, int y, int centX, int centY, int color);

	template <bool fill>
	void circle(int xOri, int yOri, int radius, int color);

	template <bool fill>
	void ellipse(int xOri, int yOri, int a, int b, int color);

};

#include "BasicDrawPluginTemplates.cpp"

#endif // _BASIC_DRAW_PLUGIN_H_
