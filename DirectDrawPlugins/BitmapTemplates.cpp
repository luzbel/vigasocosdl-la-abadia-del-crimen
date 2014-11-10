// BitmapTemplates.cpp
//
//	Generic templatized drawing methods. This file is included in Bitmap.h
//	because it's needed by the compiler in order to expand the templates.
//
/////////////////////////////////////////////////////////////////////////////

#include <cassert>

/////////////////////////////////////////////////////////////////////////////
// pixel drawing methods
/////////////////////////////////////////////////////////////////////////////

template <typename T, int bpp>
void Bitmap::setPixel(int x, int y, T packedRGB)
{
	assert(_bpp == bpp);

	if ((x >= _clipArea.left) && (x <= _clipArea.right) && (y >= _clipArea.top) && (y <= _clipArea.bottom)){
		((T *)_data)[_width*y + x] = packedRGB;
	}
}

/////////////////////////////////////////////////////////////////////////////
// opaque gfx drawing methods
/////////////////////////////////////////////////////////////////////////////

template <typename T, int bpp>
void Bitmap::drawGfx(GfxElement *gfx, T *palette, int code, int color, int x, int y, int attr)
{
	assert((x >= 0) && ((x + gfx->sizeX) <= _width));
	assert((y >= 0) && ((y + gfx->sizeY) <= _height));
	assert((code >= 0) && (code < gfx->numEntries));
	assert(_bpp == bpp);

	// get initial destination address
	T *pDest = &((T *)_data)[y*_width + x];

	// get initial char address
	const UINT8 *pChar = &gfx->data[attr & 0x03][code*gfx->entrySize];

	// get initial color index
	color = color << gfx->bpp;

	for (int cy = 0; cy < gfx->sizeY; cy++){
		for (int cx = 0; cx < gfx->sizeX; cx++){
			// get current palette index
			int c = *pChar;

			// store asociated color in the destination bitmap position
			*pDest = palette[color + c];

			// advances to the next pixel
			pChar++;
			pDest++;
		}

		// advances to the next bitmap line
		pDest += _width - gfx->sizeX;
	}
}

template <typename T, int bpp>
void Bitmap::drawGfxClip(GfxElement *gfx, T *palette, int code, int color, int x, int y, int attr)
{
	assert((code >= 0) && (code < gfx->numEntries));
	assert(_bpp == bpp);

	int srcX = 0;
	int srcY = 0;
	int sizeX = gfx->sizeX;
	int sizeY = gfx->sizeY;

	// if the graphic is completely outside the clipping rectangle, exit
	if (((x + sizeX) <= _clipArea.left) || (x > _clipArea.right) || ((y + sizeY) <= _clipArea.top) || (y > _clipArea.bottom)){
		return;
	}

	// clip in the plane X = _clipArea.left
	if (x < _clipArea.left){
		sizeX -= _clipArea.left - x;
		srcX += _clipArea.left - x;
		x = _clipArea.left;
	}

	// clip in the plane X = _clipArea.right
	if ((x + sizeX) >= _clipArea.right){
		sizeX = _clipArea.right - x + 1;
	}

	// clip in the plane Y = _clipArea.top
	if (y < _clipArea.top){
		sizeY -= _clipArea.top - y;
		srcY += _clipArea.top - y;
		y = _clipArea.top;
	}

	// clip in the plane Y = _clipArea.bottom
	if ((y + sizeY) >= _clipArea.bottom){
		sizeY = _clipArea.bottom - y + 1;
	}

	// if the intersection was outside the clipping area, exit
	if (((x + sizeX) <= _clipArea.left) || (x > _clipArea.right) || ((y + sizeY) <= _clipArea.top) || (y > _clipArea.bottom)){
		return;
	}

	// get initial destination address
	T *pDest = &((T *)_data)[y*_width + x];

	// get initial char address
	const UINT8 *pChar = &gfx->data[attr & 0x03][code*gfx->entrySize];

	// adjust char address
	pChar = &pChar[srcY*gfx->sizeY + srcX];

	// get initial color index
	color = color << gfx->bpp;

	for (int cy = 0; cy < sizeY; cy++){
		for (int cx = 0; cx < sizeX; cx++){
			// get current palette index
			int c = *pChar;

			// store asociated color in the destination bitmap position
			*pDest = palette[color + c];

			// advances to the next pixel
			pChar++;
			pDest++;
		}

		pChar += gfx->sizeX - sizeX;

		// advances to the next bitmap line
		pDest += _width - sizeX;
	}
}

/////////////////////////////////////////////////////////////////////////////
// non opaque gfx drawing methods
/////////////////////////////////////////////////////////////////////////////

template <typename T, int bpp>
void Bitmap::drawGfxTrans(GfxElement *gfx, T *palette, int code, int color, int x, int y, int attr, int transData)
{
	assert((x >= 0) && ((x + gfx->sizeX) <= _width));
	assert((y >= 0) && ((y + gfx->sizeY) <= _height));
	assert((code >= 0) && (code < gfx->numEntries));
	assert(_bpp == bpp);

	// get initial destination address
	T *pDest = &((T *)_data)[y*_width + x];

	// get initial char address
	const UINT8 *pChar = &gfx->data[attr & 0x03][code*gfx->entrySize];

	// get initial color index
	color = color << gfx->bpp;

	for (int cy = 0; cy < gfx->sizeY; cy++){
		for (int cx = 0; cx < gfx->sizeX; cx++){
			// get current palette index
			int c = *pChar;

			if (attr & TRANSPARENCY_PEN){
				// if it's not the transparent pen, store asociated color
				if (c != transData){
					*pDest = palette[color + c];
				}
			} else if (attr & TRANSPARENCY_COLOR){
				// if it's not the same color, store asociated color
				T transColor = palette[transData];
				if (transColor != palette[color + c]){
					*pDest = palette[color + c];
				}
			}

			// advances to the next pixel
			pChar++;
			pDest++;
		}

		// advances to the next bitmap line
		pDest += _width - gfx->sizeX;
	}
}

template <typename T, int bpp>
void Bitmap::drawGfxClipTrans(GfxElement *gfx, T *palette, int code, int color, int x, int y, int attr, int transData)
{
	assert((code >= 0) && (code < gfx->numEntries));
	assert(_bpp == bpp);

	int srcX = 0;
	int srcY = 0;
	int sizeX = gfx->sizeX;
	int sizeY = gfx->sizeY;

	// if the graphic is completely outside the clipping rectangle, exit
	if (((x + sizeX) <= _clipArea.left) || (x > _clipArea.right) || ((y + sizeY) <= _clipArea.top) || (y > _clipArea.bottom)){
		return;
	}

	// clip in the plane X = _clipArea.left
	if (x < _clipArea.left){
		sizeX -= _clipArea.left - x;
		srcX += _clipArea.left - x;
		x = _clipArea.left;
	}

	// clip in the plane X = _clipArea.right
	if ((x + sizeX) >= _clipArea.right){
		sizeX = _clipArea.right - x + 1;
	}

	// clip in the plane Y = _clipArea.top
	if (y < _clipArea.top){
		sizeY -= _clipArea.top - y;
		srcY += _clipArea.top - y;
		y = _clipArea.top;
	}

	// clip in the plane Y = _clipArea.bottom
	if ((y + sizeY) >= _clipArea.bottom){
		sizeY = _clipArea.bottom - y + 1;
	}

	// if the intersection was outside the clipping area, exit
	if (((x + sizeX) <= _clipArea.left) || (x > _clipArea.right) || ((y + sizeY) <= _clipArea.top) || (y > _clipArea.bottom)){
		return;
	}

	// get initial destination address
	T *pDest = &((T *)_data)[y*_width + x];

	// get initial char address
	const UINT8 *pChar = &gfx->data[attr & 0x03][code*gfx->entrySize];

	// adjust char address
	pChar = &pChar[srcY*gfx->sizeY + srcX];

	// get initial color index
	color = color << gfx->bpp;

	for (int cy = 0; cy < sizeY; cy++){
		for (int cx = 0; cx < sizeX; cx++){
			// get current palette index
			int c = *pChar;

			if (attr & TRANSPARENCY_PEN){
				// if it's not the transparent pen, store asociated color
				if (c != transData){
					*pDest = palette[color + c];
				}
			} else if (attr & TRANSPARENCY_COLOR){
				// if it's not the same color, store asociated color
				T transColor = palette[transData];
				if (transColor != palette[color + c]){
					*pDest = palette[color + c];
				}
			}

			// advances to the next pixel
			pChar++;
			pDest++;
		}

		pChar += gfx->sizeX - sizeX;

		// advances to the next bitmap line
		pDest += _width - sizeX;
	}
}
