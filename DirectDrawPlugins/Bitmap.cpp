// Bitmap.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Bitmap.h"
#include <cassert>

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

Bitmap::Bitmap(int width, int height, int bpp)
{
	_width = width;
	_height = height;
	_bpp = bpp;

	_data = new UINT8[width*height*bpp/8];

	clear();
	setNoClip();
}

Bitmap::~Bitmap()
{
	delete[] _data;
}


void Bitmap::clear()
{
	memset(_data, 0, _width*_height*_bpp/8);
}

/////////////////////////////////////////////////////////////////////////////
// clip related methods
/////////////////////////////////////////////////////////////////////////////

// sets the clipping area to cover the entire bitmap
void Bitmap::setNoClip()
{
	_clipArea.left = 0;
	_clipArea.top = 0;
	_clipArea.right = _width - 1;
	_clipArea.bottom = _height - 1;
}

// sets the clipping area
void Bitmap::setClipArea(int x, int y, int width, int height)
{
	assert((x >= 0) && (x < _width));
	assert((y >= 0) && (y < _height));
	assert(width >= 0);
	assert(height >= 0);
	assert((x + width) < _width);
	assert((y + height) < _height);

	_clipArea.left = x;
	_clipArea.top = y;
	_clipArea.right = x + width - 1;
	_clipArea.bottom = y + height - 1;
}

/////////////////////////////////////////////////////////////////////////////
// bitmap composition methods
/////////////////////////////////////////////////////////////////////////////

// composes two similar bitmaps
void Bitmap::copySimilar(Bitmap *source)
{
	assert((_width == source->_width) && (_height == source->_height));
	assert(_bpp == source->_bpp);

	// copy full bitmap
	memcpy(_data, source->_data, _width*_height*_bpp/8);
}

/////////////////////////////////////////////////////////////////////////////
// drawing methods are in bitmaptemplate.cpp
/////////////////////////////////////////////////////////////////////////////
