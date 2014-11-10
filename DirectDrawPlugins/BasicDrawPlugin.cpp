// BasicDrawPlugin.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include <cassert>
#include "BasicDrawPlugin.h"


/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

BasicDrawPlugin::BasicDrawPlugin()
{
	_gameWidth = _gameHeight = 0;
	_numColors = 0;
	_visAreaOffsX = _visAreaOffsY = 0;
	_visAreaWidth = _visAreaHeight = 0;

	_bpp = 0;
	_refreshRate = 0;
	_fullScreen = false;
	_vSync = false;
	_isInitialized = false;

	_actualBitmap = 0;

	_errorMsg = "";
}

BasicDrawPlugin::~BasicDrawPlugin()
{
	assert(_bitmaps.size() == 0);
}

/////////////////////////////////////////////////////////////////////////////
// bitmap creation/destruction
/////////////////////////////////////////////////////////////////////////////

int BasicDrawPlugin::createBitmap(int width, int height)
{
	Bitmap *b = new Bitmap(width, height, _bpp);
	int pos = (int)_bitmaps.size();
	_bitmaps.push_back(b);

	return pos;
}

void BasicDrawPlugin::destroyBitmap(int bitmap)
{
	assert((bitmap >= 0) && bitmap < ((int)_bitmaps.size()));

	delete _bitmaps[bitmap];
	_bitmaps[bitmap] = 0;
}

/////////////////////////////////////////////////////////////////////////////
// bitmap methods
/////////////////////////////////////////////////////////////////////////////

void BasicDrawPlugin::setActiveBitmap(int bitmap)
{
	assert((bitmap >= 0) && bitmap < ((int)_bitmaps.size()));
	assert(_bitmaps[bitmap] != 0);

	_actualBitmap = _bitmaps[bitmap];
}

// composes actual bitmap with selected one
void BasicDrawPlugin::compose(int bitmap, int mode, int attr)
{
	_actualBitmap->copySimilar(_bitmaps[bitmap]);
}

// gets bipmap's dimensions
void BasicDrawPlugin::getDimensions(int &width, int &height) const
{
	width = _actualBitmap->getWidth();
	height = _actualBitmap->getHeight();
}
/////////////////////////////////////////////////////////////////////////////
// clipping methods
/////////////////////////////////////////////////////////////////////////////

// gets the clipping area for the active bitmap
const Rect *BasicDrawPlugin::getClipArea() const
{
	return _actualBitmap->getClipArea();
}

// sets the clipping area for the active bitmap
void BasicDrawPlugin::setClipArea(int x, int y, int width, int height)
{
	_actualBitmap->setClipArea(x, y, width, height);
}

// sets the clipping area to the whole bitmap (in the active bitmap)
void BasicDrawPlugin::setNoClip()
{
	_actualBitmap->setNoClip();
}

/////////////////////////////////////////////////////////////////////////////
// drawing primitives
/////////////////////////////////////////////////////////////////////////////

// draws a line using the midpoint algorithm
void BasicDrawPlugin::drawLine(int x0, int y0, int x1, int y1, int color)
{
	// line->F(x,y) = ax + by + c = 0, y = mx + b, where m = dy/dx -> a = dy, b = -dx
	// always draw from left to right
	if (x1 < x0){
		std::swap<int>(x0, x1);
		std::swap<int>(y0, y1);
	}

	// compute increments
	int dx = x1 - x0;
	int dy = y1 - y0;

	// depending on the dominant axis, set increments if d > 0
	int xNonDom = 1;
	int yNonDom = (dy >= 0) ? 1 : -1;

	// store length only
	dy = abs(dy);

	int xDom, yDom;

	// depending on the slope, set increments if d <= 0
	if (dy > dx){	// |m| > 1
		std::swap<int>(dx, dy);		// dx = dominant axis
		xDom = 0;
		yDom = yNonDom;
	} else {		// |m| <= 1
		xDom = xNonDom;
		yDom = 0;
	}

	// calculate decision variable vars
	int incrDom = dy;
	int incrNonDom = dy - dx;
	int d = 2*dy - dx;

	// draw the pixels
	for (int x = x0, y = y0, i = 0; i <= dx; i++){
		setPixel(x, y, color);
		if (d <= 0){		// pixel closer to the dominant axis
			d += incrDom;
			x += xDom;
			y += yDom;
		} else {			// pixel closer to the nondominant axis
			d += incrNonDom;
			x += xNonDom;
			y += yNonDom;
		}
	}
}

// draws a rectangle
void BasicDrawPlugin::drawRect(int x, int y, int width, int height, int color)
{
	width--; height--;

	drawLine(x, y, x + width, y, color);
	drawLine(x + width, y, x + width, y + height, color);
	drawLine(x + width, y + height, x, y + height, color);
	drawLine(x, y + height, x, y, color);
}

// draws a rectangle
void BasicDrawPlugin::drawRect(Rect *rect, int color)
{
	drawLine(rect->left, rect->bottom, rect->right, rect->bottom, color);
	drawLine(rect->right, rect->bottom, rect->right, rect->top, color);
	drawLine(rect->right, rect->top, rect->left, rect->top, color);
	drawLine(rect->left, rect->top, rect->left, rect->bottom, color);
}

// draws a circle using the midpoint algorithm
void BasicDrawPlugin::drawCircle(int xOri, int yOri, int radius, int color)
{
	circle<false>(xOri, yOri, radius, color);
}

// draws an ellipse using the midpoint algorithm
void BasicDrawPlugin::drawEllipse(int xOri, int yOri, int a, int b, int color)
{
	ellipse<false>(xOri, yOri, a, b, color);
}

/////////////////////////////////////////////////////////////////////////////
// filled primitives
/////////////////////////////////////////////////////////////////////////////

// fills a rectangle
void BasicDrawPlugin::fillRect(int x, int y, int width, int height, int color)
{
	int xLimit = width + x - 1;

	for (; height > 0; height--, y++){
		fillScanLine(x, xLimit, y, color);
	}
}

// fills a rectangle
void BasicDrawPlugin::fillRect(Rect *rect, int color)
{
	for (int y = rect->top; y <= rect->bottom; y++){
		fillScanLine(rect->left, rect->right, y, color);
	}
}

// fills a circle using the midpoint algorithm
void BasicDrawPlugin::fillCircle(int xOri, int yOri, int radius, int color)
{
	circle<true>(xOri, yOri, radius, color);
}

// fills an ellipse using the midpoint algorithm
void BasicDrawPlugin::fillEllipse(int xOri, int yOri, int a, int b, int color)
{
	ellipse<true>(xOri, yOri, a, b, color);
}

/////////////////////////////////////////////////////////////////////////////
// Custom plugin properties
/////////////////////////////////////////////////////////////////////////////

const int * BasicDrawPlugin::getPropertiesType() const
{
	return 0;
}

const std::string * BasicDrawPlugin::getProperties(int *num) const 
{
	*num = 0;
	return 0;
}

void BasicDrawPlugin::setProperty(std::string prop, int data)
{
}

void BasicDrawPlugin::setProperty(std::string prop, int index, int data)
{
}

int BasicDrawPlugin::getProperty(std::string prop) const
{ 
	return -1; 
};

int BasicDrawPlugin::getProperty(std::string prop, int index) const
{ 
	return -1; 
};

/////////////////////////////////////////////////////////////////////////////
// helper methods
/////////////////////////////////////////////////////////////////////////////

// fills a horizontal line with a color
void BasicDrawPlugin::fillScanLine(int x0, int x1, int y, int color)
{
	if (x1 < x0) {
		std::swap<int>(x0, x1);
	}

	for (int x = x0; x <= x1; x++){
		setPixel(x, y, color);
	}
}

// draw 4 symmetrical points using as center (centX, centY)
void BasicDrawPlugin::drawSymmetrical4Points(int x, int y, int centX, int centY, int color)
{
	setPixel(centX + x, centY + y, color);
	setPixel(centX + x, centY - y, color);
	setPixel(centX - x, centY - y, color);
	setPixel(centX - x, centY + y, color);
}

// draw 8 symmetrical points using as center (centX, centY)
void BasicDrawPlugin::drawSymmetrical8Points(int x, int y, int centX, int centY, int color)
{
	setPixel(centX + x, centY + y, color);
	setPixel(centX + y, centY + x, color);
	setPixel(centX + y, centY - x, color);
	setPixel(centX + x, centY - y, color);
	setPixel(centX - x, centY - y, color);
	setPixel(centX - y, centY - x, color);
	setPixel(centX - y, centY + x, color);
	setPixel(centX - x, centY + y, color);
}

// fill 2 lines, using the 4 symmetrical points arount center (centX, centY)
void BasicDrawPlugin::fillSymmetrical2ScanLines(int x, int y, int centX, int centY, int color)
{
	fillScanLine(centX - x, centX + x, centY + y, color);
	fillScanLine(centX - x, centX + x, centY - y, color);
}

// draw 8 symmetrical points using as center (centX, centY)
void BasicDrawPlugin::fillSymmetrical4ScanLines(int x, int y, int centX, int centY, int color)
{
	fillScanLine(centX - x, centX + x, centY + y, color);
	fillScanLine(centX - x, centX + x, centY - y, color);
	fillScanLine(centX - y, centX + y, centY + x, color);
	fillScanLine(centX - y, centX + y, centY - x, color);
}
