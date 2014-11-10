// DirectDrawWindow.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Bitmap.h"
#include <cassert>
#include "DirectDrawWindow.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

DirectDrawWindow::DirectDrawWindow(Win32Settings *settings) : DirectDrawPlugin(settings)
{
	_settings = settings;
	_auxBuf = 0;
	_scale = 1;
	_fullScreen = false;
}

DirectDrawWindow::~DirectDrawWindow()
{
	assert(!_auxBuf);
}

/////////////////////////////////////////////////////////////////////////////
// Direct Draw initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

bool DirectDrawWindow::init(const VideoInfo *vi, IPalette *pal)
{
	// default DirectDraw initialization
	if (!DirectDrawPlugin::init(vi, pal)){
		return false;
	}

	DDSURFACEDESC ddsd;
	memset(&ddsd, 0, sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);
	ddsd.dwFlags = DDSD_PIXELFORMAT;

	// gets desktop information
	if (FAILED(_pIDD2->GetDisplayMode(&ddsd))){
		_errorMsg = "DirectDrawWindow ERROR: error calling GetDisplayMode";
		return false;
	}

	_bpp = ddsd.ddpfPixelFormat.dwRGBBitCount;

	// sets primary surface parameters
	memset(&ddsd, 0, sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);
	ddsd.dwFlags = DDSD_CAPS;
	ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;

	// creates primary surface
	if (FAILED(_pIDD2->CreateSurface(&ddsd, &_screenBuf, 0))){
		_errorMsg = "DirectDrawWindow ERROR: can't create the primary surface";
		return false;
	}

	// gets RGB mask to handle different bpp configurations
	if (!getRGBMasks()){
		_errorMsg = "DirectDrawWindow ERROR: can't get RGB masks";
		return false;
	}

	LPDIRECTDRAWCLIPPER clipper;

	// creates a clipper
	if (FAILED(DirectDrawCreateClipper(0, &clipper, 0))){
		_errorMsg = "DirectDrawWindow ERROR: can't create clipper";
		return false;
	}

	// attaches the clipper object to the window
	if (FAILED(clipper->SetHWnd(0, _settings->getHWnd()))){
		_errorMsg = "DirectDrawWindow ERROR: can't attach clipper object";
		return false;
	}

	// asociamos el objeto de recorte a la superficie primaria
	if (FAILED(_screenBuf->SetClipper(clipper))){
		_errorMsg = "DirectDrawWindow ERROR: no se pudo asociar el objeto de recorte a la superficie primaria";
		return false;
	}

	// release clipper interface
	clipper->Release();

	return true;
}

void DirectDrawWindow::end()
{
	if (_auxBuf){
		_auxBuf->Release();
		_auxBuf = 0;
	}

	DirectDrawPlugin::end();
}

/////////////////////////////////////////////////////////////////////////////
// Helper methods
/////////////////////////////////////////////////////////////////////////////

// creates the auxiliary surface, adjusts window size and creates game bitmap
bool DirectDrawWindow::createAuxiliarySurface(int scaleScreen, int scaleWin)
{
	DDCAPS ddc;

	// check graphics hardware capabilities
	memset(&ddc, 0, sizeof(ddc));
	ddc.dwSize = sizeof(ddc);
	_pIDD2->GetCaps(&ddc, 0);

	bool useVidMem = (ddc.dwCaps & DDCAPS_BLTSTRETCH) != 0;

	DDSURFACEDESC ddsd;

	// set auxiliary surface parameters
	memset(&ddsd, 0, sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);
	ddsd.dwFlags = DDSD_CAPS | DDSD_WIDTH | DDSD_HEIGHT;
	ddsd.ddsCaps.dwCaps = useVidMem ? DDSCAPS_VIDEOMEMORY : DDSCAPS_SYSTEMMEMORY;
	ddsd.dwWidth = scaleScreen*_visAreaWidth;
	ddsd.dwHeight = scaleScreen*_visAreaHeight;

	if (FAILED(_pIDD2->CreateSurface(&ddsd, &_auxBuf, 0))){
		// if the surface couldn't be created in video memory, try to use system memory
		if (useVidMem){
			memset(&ddsd, 0, sizeof(ddsd));
			ddsd.dwSize = sizeof(ddsd);
			ddsd.dwFlags = DDSD_CAPS | DDSD_WIDTH | DDSD_HEIGHT;
			ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN;
			ddsd.ddsCaps.dwCaps = DDSCAPS_SYSTEMMEMORY;
			ddsd.dwWidth = scaleScreen*_visAreaWidth;
			ddsd.dwHeight = scaleScreen*_visAreaHeight;

			// if the surface couldn't be created in system memory, error
			if (FAILED(_pIDD2->CreateSurface(&ddsd, &_auxBuf, 0))){
				_errorMsg = "DirectDrawWindow ERROR: can't create auxiliary surface";
				return false;
			}
		} else {
			_errorMsg = "DirectDrawWindow ERROR: can't create auxiliary surface in system memory";
			return false;
		}
	}

	// clears the surface
	clearBuf(_auxBuf, 0);

	// gets difference between client area and window area
	RECT winDim, clientDim;
	GetWindowRect(_settings->getHWnd(), &winDim);
	GetClientRect(_settings->getHWnd(), &clientDim);
	int difx = (winDim.right - winDim.left) - (clientDim.right - clientDim.left);
	int dify = (winDim.bottom - winDim.top) - (clientDim.bottom - clientDim.top);

	// changes window size
	MoveWindow(_settings->getHWnd(), winDim.left, winDim.top, 
		scaleWin*_visAreaWidth + difx, scaleWin*_visAreaHeight + dify, TRUE);

	// creates the game the game bitmap
	_actualBitmap = _bitmaps[createBitmap(_gameWidth, _gameHeight)];

	return true;
}

/////////////////////////////////////////////////////////////////////////////
// Custom plugin properties
/////////////////////////////////////////////////////////////////////////////

const std::string DirectDrawWindow::g_properties[] = {
	"useHardware",
	"scale"
};

const int DirectDrawWindow::g_paramTypes[] = {
	PARAM_BOOLEAN,
	PARAM_INTEGER
};

const int * DirectDrawWindow::getPropertiesType() const
{
	return DirectDrawWindow::g_paramTypes;
}

const std::string * DirectDrawWindow::getProperties(int *num) const 
{
	*num = sizeof(g_paramTypes)/sizeof(g_paramTypes[0]);
	return DirectDrawWindow::g_properties;
}

void DirectDrawWindow::setProperty(std::string prop, int data)
{
	if (prop == "useHardware"){
		_hardware = data != 0;
	} else if (prop == "scale"){
		if (data > 0) {
			_scale = data;
		}
	}
}

int DirectDrawWindow::getProperty(std::string prop) const
{ 
	if (prop == "useHardware"){
		return (_hardware) ? 1 : 0;
	} else if (prop == "scale"){
		return _scale;
	}

	return -1; 
};