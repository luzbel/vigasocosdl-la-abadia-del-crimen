// DirectDrawPlugin.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "DirectDrawPlugin.h"
#include "IPalette.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

DirectDrawPlugin::DirectDrawPlugin(Win32Settings *settings)
{
	_settings = settings;
	_pIDD2 = 0;
	_screenBuf = 0;
}

DirectDrawPlugin::~DirectDrawPlugin()
{
}

/////////////////////////////////////////////////////////////////////////////
// Direct Draw initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

// gets IDirectDraw2 interface and sets cooperative level
bool DirectDrawPlugin::init(const VideoInfo *vi, IPalette *pal)
{
	// creates the window
	if (!createWnd()){
		_errorMsg = "DirectDrawPlugin ERROR: can't create window";
		return false;
	}

	// shows the window
	ShowWindow(_settings->getHWnd(), SW_SHOWNORMAL);
	UpdateWindow(_settings->getHWnd());

	LPDIRECTDRAW pIDD = 0;

	// gets IDirectDraw interface
	if (FAILED(DirectDrawCreate(0, &pIDD, 0))){
		_errorMsg = "DirectDrawPlugin ERROR: can't get IDirectDraw interface";
		return false;
	}

	// gets IDirectDraw2 interface
	if (FAILED(pIDD->QueryInterface(IID_IDirectDraw2, (void **)&_pIDD2))){
		_errorMsg = "DirectDrawPlugin ERROR: can't get IDirectDraw2 interface";
		return false;
	}

	pIDD->Release();

	DWORD level = (_fullScreen) ? DDSCL_FULLSCREEN | DDSCL_EXCLUSIVE : DDSCL_NORMAL;

	// sets cooperative level
	if (FAILED(_pIDD2->SetCooperativeLevel(_settings->getHWnd(), level))){
		_errorMsg = "DirectDrawPlugin ERROR: can't set cooperative level";
		return false;
	}

	// saves game parameters
	_gameWidth = vi->width;
	_gameHeight = vi->height;
	_numColors = pal->getTotalColors();
	_visAreaOffsX = vi->visibleArea.left;
	_visAreaOffsY = vi->visibleArea.top;
	_visAreaWidth = vi->visibleArea.right - vi->visibleArea.left + 1;
	_visAreaHeight = vi->visibleArea.bottom - vi->visibleArea.top + 1;
	_refreshRate = vi->refreshRate;

	return true;
}

// restores cooperative level and releases DirectDraw stuff
void DirectDrawPlugin::end()
{
	// delete remaining bitmaps
	for (GameBitmaps::size_type i = 0; i < _bitmaps.size(); i++){
		delete _bitmaps[i];
	}
	_bitmaps.clear();

	_pIDD2->SetCooperativeLevel(_settings->getHWnd(), DDSCL_NORMAL);

	if (_screenBuf){
		_screenBuf->Release();
		_screenBuf = 0;
	}

	if (_pIDD2){
		_pIDD2->Release();
		_pIDD2 = 0;
	}

	// destroy the window
	ShowCursor((_fullScreen) ? TRUE : FALSE);
	DestroyWindow(_settings->getHWnd());
	_settings->setHWnd(0);
}

/////////////////////////////////////////////////////////////////////////////
// color conversion
/////////////////////////////////////////////////////////////////////////////

UINT16 DirectDrawPlugin::convertColorTo16bpp(PaletteConversion *conv, int R, int G, int B)
{
	UINT16 result = (R >> conv->BIgnoredBits) << conv->RShiftBits;
	result |= (G >> conv->GIgnoredBits) << conv->GShiftBits;
	result |= (B >> conv->BIgnoredBits) << conv->BShiftBits;

	return result;
}

void DirectDrawPlugin::getMaskInfo(UINT32 mask, int &shiftBits, int &ignoredBits)
{
	shiftBits = 0;

	// get shift bits
	while ((mask & 0x01) == 0){
		mask = mask >> 1;
		shiftBits++;
	}

	ignoredBits = 0;

	// get precision bits
	while (mask & 0x01){
		mask = mask >> 1;
		ignoredBits++;
	}

	// keep only MSB precision bits and ignore the rest
	ignoredBits = 8 - ignoredBits;
}

/////////////////////////////////////////////////////////////////////////////
// Helper methods
/////////////////////////////////////////////////////////////////////////////

// clears a surface
void DirectDrawPlugin::clearBuf(IDirectDrawSurface *buf, UINT32 color)
{
	DDBLTFX ddbltfx;
	memset(&ddbltfx, 0, sizeof(ddbltfx));
	ddbltfx.dwSize = sizeof(ddbltfx);
	ddbltfx.dwFillColor = color;

	buf->Blt(0, 0, 0, DDBLT_COLORFILL | DDBLT_WAIT, &ddbltfx);
}

bool DirectDrawPlugin::getRGBMasks()
{
	DDPIXELFORMAT ddpf;
	ddpf.dwSize = sizeof(ddpf);

	// get surface info
	if (FAILED(_screenBuf->GetPixelFormat(&ddpf))){
		return false;
	}

	// save color conversion information
	getMaskInfo(ddpf.dwRBitMask, _palConv.RShiftBits, _palConv.RIgnoredBits);
	getMaskInfo(ddpf.dwGBitMask, _palConv.GShiftBits, _palConv.GIgnoredBits);
	getMaskInfo(ddpf.dwBBitMask, _palConv.BShiftBits, _palConv.BIgnoredBits);

	return true;
}

// creates a window
bool DirectDrawPlugin::createWnd()
{
	_settings->setHWnd(CreateWindowEx(
		(_fullScreen) ? WS_EX_TOPMOST : 0,
		_settings->getAppClassName(),
		"VIGASOCO",
		(_fullScreen) ? WS_POPUP : WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, CW_USEDEFAULT,
		CW_USEDEFAULT, CW_USEDEFAULT,
		NULL,
		NULL,
		_settings->getAppInstance(),
		NULL
	));

	ShowCursor((_fullScreen) ? FALSE : TRUE);

	if (_settings->getHWnd()){
		// set window user parameter
		return (SetWindowLong(_settings->getHWnd(), GWL_USERDATA, _settings->getWndParam()) == 0);
	} else {
		return false;
	}
}
