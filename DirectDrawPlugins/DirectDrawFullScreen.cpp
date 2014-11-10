// DirectDrawFullScreen.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Bitmap.h"
#include <cassert>
#include "DirectDrawFullScreen.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

DirectDrawFullScreen::DirectDrawFullScreen(Win32Settings *settings) : DirectDrawPlugin(settings)
{
	_currWidth = _currHeight = 0;
	_centerX = _centerY = 0;
	_fullScreen = true;

	_preSelectedMode = false;
}

DirectDrawFullScreen::~DirectDrawFullScreen()
{
}

/////////////////////////////////////////////////////////////////////////////
// Direct Draw initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

bool DirectDrawFullScreen::init(const VideoInfo *vi, IPalette *pal)
{
	// default DirectDraw initialization
	if (!DirectDrawPlugin::init(vi, pal)){
		return false;
	}

	// enum available display modes
	if (FAILED(_pIDD2->EnumDisplayModes(0, 0, (void *)this, (LPDDENUMMODESCALLBACK)EnumDisplayModes))){
		_errorMsg = "DirectDrawFullScreen ERROR: can't enum display modes";
		return false;
	}

	return true;
}

void DirectDrawFullScreen::end()
{
	std::list<DirectDrawMode *>::iterator i;

	// cleanup available modes
	for (i = _modes.begin(); i != _modes.end(); i++){
		delete *i;
	}

	// restore previous video mode
	_pIDD2->RestoreDisplayMode();

	DirectDrawPlugin::end();
}

/////////////////////////////////////////////////////////////////////////////
// DirectDraw callbacks
/////////////////////////////////////////////////////////////////////////////

BOOL WINAPI DirectDrawFullScreen::EnumDisplayModes(DDSURFACEDESC *DDSurfaceDesc, void *Context)
{
	DirectDrawFullScreen *ddraw = (DirectDrawFullScreen *)Context;
	int width = DDSurfaceDesc->dwWidth;
	int height = DDSurfaceDesc->dwHeight;
	int bpp = DDSurfaceDesc->ddpfPixelFormat.dwRGBBitCount;
	int refreshRate = DDSurfaceDesc->dwRefreshRate;

	ddraw->addMode(width , height, bpp, refreshRate);

	return DDENUMRET_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Helper methods
/////////////////////////////////////////////////////////////////////////////

// adds modes that match plugin's bpp
void DirectDrawFullScreen::addMode(int width, int height, int bpp, int refreshRate)
{
	if (bpp == _bpp){
		_modes.push_back(new DirectDrawMode(width, height, bpp, refreshRate));
	}
}

// select the mode that best matches game screen area and sets it
bool DirectDrawFullScreen::setBestMode()
{
	bool found = false;

	_currRefreshRate = 0;

	std::list<DirectDrawMode  *>::iterator i;

	// if a mode has been preselected, check if it's available and select it
	if (_preSelectedMode){
		for (i = _modes.begin(); i != _modes.end(); i++){
			DirectDrawMode *di = *i;

			if ((di->width == _currWidth) && (di->height == _currHeight)){
				found = true;
				// store mode with highest refresh rate
				if (di->refreshRate > _currRefreshRate){
					_currRefreshRate = di->refreshRate;
				}
			}
		}
	} else {
		_currWidth = _currHeight = 0;
	}

	// otherwise search for the best match
	if (!found){
		for (i = _modes.begin(); i != _modes.end(); i++){
			DirectDrawMode *di = *i;

			if ((di->width >= _visAreaWidth) && (di->height >= _visAreaHeight)){

				// if it's the same video mode as the best found, use the one
				// that has highest refresh rate
				if ((di->width == _currWidth) && (di->height >= _currHeight)){
					if (di->refreshRate > _currRefreshRate){
						_currRefreshRate = di->refreshRate;
					}
				}

				int newDX = di->width - _visAreaWidth;
				int newDY = di->height - _visAreaHeight;
				int currDX = _currWidth - _visAreaWidth;
				int currDY = _currHeight - _visAreaHeight;

				// if the game fits better in this video mode, select it
				if ((newDX*newDX + newDY*newDY) < (currDX*currDX + currDY*currDY)){
					_currWidth = di->width;
					_currHeight = di->height;
					_currRefreshRate = di->refreshRate;
				}
			}
		}
	}

	// sets selected display mode
	if (FAILED(_pIDD2->SetDisplayMode(_currWidth, _currHeight, _bpp, _currRefreshRate, 0))){
		_errorMsg = "DirectDrawFullScreen ERROR: can't set display mode";
		return false;
	}

	// calculates starting drawing point
	_centerX = (_currWidth - _visAreaWidth)/2;
	_centerY = (_currHeight - _visAreaHeight)/2;

	// creates the game the game bitmap
	_actualBitmap = _bitmaps[createBitmap(_gameWidth, _gameHeight)];

	return true;
}

/////////////////////////////////////////////////////////////////////////////
// Custom plugin properties
/////////////////////////////////////////////////////////////////////////////

const std::string DirectDrawFullScreen::g_properties[] = {
	"preSelectedMode",
	"width",
	"height",
};

const int DirectDrawFullScreen::g_paramTypes[] = {
	PARAM_BOOLEAN,
	PARAM_INTEGER,
	PARAM_INTEGER
};

const int * DirectDrawFullScreen::getPropertiesType() const
{
	return DirectDrawFullScreen::g_paramTypes;
}

const std::string * DirectDrawFullScreen::getProperties(int *num) const 
{
	*num = sizeof(g_paramTypes)/sizeof(g_paramTypes[0]);
	return DirectDrawFullScreen::g_properties;
}

void DirectDrawFullScreen::setProperty(std::string prop, int data)
{
	if (prop == "preSelectedMode"){
		_preSelectedMode = data != 0;
	} else if (prop == "width"){
		_currWidth = data;
	} else if (prop == "height"){
		_currHeight = data;
	}
}

int DirectDrawFullScreen::getProperty(std::string prop) const
{ 
	if (prop == "preSelectedMode"){
		return (_preSelectedMode) ? 1 : 0;
	} else if (prop == "width"){
		return _currWidth;
	} else if (prop == "height"){
		return _currHeight;
	}

	return -1; 
};