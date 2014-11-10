// Bitmap.h
//
//	Class that models a bitmap
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _BITMAP_H_
#define _BITMAP_H_


#include "GfxData.h"
#include "Types.h"

class Bitmap
{
// fields
protected:
	int _width, _height;	// bitmap dimensiones
	int _bpp;				// bits per pixel
	UINT8 *_data;			// bitmap data
	Rect _clipArea;			// clipping area

// methods
public:
	// initialization and cleanup
	Bitmap(int width, int height, int bpp);
	virtual ~Bitmap();

	// getters & setters
	int getWidth() const { return _width; }
	int getHeight() const { return _height; }
	int getBpp() const { return _bpp; }
	UINT8 *getData() const { return (UINT8 *)_data; }
	const Rect *getClipArea() const { return &_clipArea; }
	void setClipArea(int x, int y, int width, int height);
	
	void setNoClip();
	void clear();

	// bitmap composition methods
	void copySimilar(Bitmap *source);

	// drawing methods
	template <typename T, int bpp>
	void setPixel(int x, int y, T packedRGB);

	template <typename T, int bpp>
	void drawGfx(GfxElement *gfx, T *palette, int code, int color, int x, int y, int attr);
	template <typename T, int bpp>
	void drawGfxClip(GfxElement *gfx, T *palette, int code, int color, int x, int y, int attr);

	template <typename T, int bpp>
	void drawGfxTrans(GfxElement *gfx, T *palette, int code, int color, int x, int y, int attr, int transData);
	template <typename T, int bpp>
	void drawGfxClipTrans(GfxElement *gfx, T *palette, int code, int color, int x, int y, int attr, int transData);
};

#include "BitmapTemplates.cpp"

#endif // _BITMAP_H_