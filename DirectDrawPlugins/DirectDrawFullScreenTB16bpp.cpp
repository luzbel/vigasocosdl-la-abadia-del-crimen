// DirectDrawFullScreenTB16bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Bitmap.h"
#include <cassert>
#include "DirectDrawFullScreenTB16bpp.h"
#include "IPalette.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

DirectDrawFullScreenTB16bpp::DirectDrawFullScreenTB16bpp(Win32Settings *settings) : DirectDrawFullScreen(settings)
{
	_bpp = 16;
	_palette = 0;
}

DirectDrawFullScreenTB16bpp::~DirectDrawFullScreenTB16bpp()
{
}

/////////////////////////////////////////////////////////////////////////////
// Direct Draw initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

bool DirectDrawFullScreenTB16bpp::init(const VideoInfo *vi, IPalette *pal)
{
	// default DirectDraw initialization in FullScreen mode
	if (!DirectDrawFullScreen::init(vi, pal)){
		return false;
	}

	// set video mode
	if (!DirectDrawFullScreen::setBestMode()){
		return false;
	}

	DDSURFACEDESC ddsd;

	// sets surface description
	memset(&ddsd, 0, sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);
	ddsd.dwFlags = DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
	ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE | DDSCAPS_FLIP | DDSCAPS_COMPLEX | DDSCAPS_VIDEOMEMORY;
	ddsd.dwBackBufferCount = 2;	// triple buffering

	// creates primary surface
	if (FAILED(_pIDD2->CreateSurface(&ddsd, &_screenBuf, 0))){
		_errorMsg = "DirectDrawFullScreenTB16bpp ERROR: can't create primary surface";
		return false;
	}

	DDSCAPS ddscaps;
	memset(&ddscaps, 0, sizeof(ddscaps));
	ddscaps.dwCaps = DDSCAPS_BACKBUFFER;

	// get a pointer to the backbuffer
	if (FAILED(_screenBuf->GetAttachedSurface(&ddscaps, &_backBuf))){
		_errorMsg = "DirectDrawFullScreenTB32bpp ERROR: can't get back surface";
		return false;
	}

	// clear the buffers
	clearBuf(_backBuf, 0);
	_screenBuf->Flip(0, DDFLIP_WAIT);
	clearBuf(_backBuf, 0);
	_screenBuf->Flip(0, DDFLIP_WAIT);
	clearBuf(_backBuf, 0);
	_screenBuf->Flip(0, DDFLIP_WAIT);

	// gets RGB mask to handle different bpp configurations
	if (!getRGBMasks()){
		_errorMsg = "DirectDrawFullScreenTP16bpp ERROR: can't get RGB masks";
		return false;
	}


	// checks that the visible area width is divisible by 2
	if (!((_visAreaWidth % 2) == 0)){
		_errorMsg = "DirectDrawWindow16TBbpp ERROR: visible area width is not divisible by 2";
		return false;
	}

	// aligns _centerX to a 16 bit boundary
	_centerX &= 0xfffe;

	// creates a 16bpp palette from the original one and suscribe for changes
	_originalPalette = pal;
	_palette = new UINT16[pal->getTotalColors()];
	pal->attach(this);
	updateFullPalette(pal);

	_isInitialized = true;

	return true;
}

void DirectDrawFullScreenTB16bpp::end()
{
	_isInitialized = false;

	if (_palette){
		delete[] _palette;
		_palette = 0;

		_originalPalette->detach(this);
	}

	DirectDrawFullScreen::end();
}

/////////////////////////////////////////////////////////////////////////////
// Palette changes
/////////////////////////////////////////////////////////////////////////////

void DirectDrawFullScreenTB16bpp::updateFullPalette(IPalette *palette)
{
	for (int i = 0; i < palette->getTotalColors(); i++){
		UINT8 r, g, b;

		palette->getColor(i, r, g, b);
		_palette[i] = DirectDrawPlugin::convertColorTo16bpp(&_palConv, r, g, b);
	}
}

void DirectDrawFullScreenTB16bpp::update(IPalette *palette, int data)
{
	if (data != -1){
		// single color update
		UINT8 r, g, b;

		palette->getColor(data, r, g, b);
		_palette[data] = DirectDrawPlugin::convertColorTo16bpp(&_palConv, r, g, b);
	} else {
		// full palette update
		updateFullPalette(palette);	
	}
}

/////////////////////////////////////////////////////////////////////////////
// Render
/////////////////////////////////////////////////////////////////////////////

// renders the screen bitmap to the screen
void DirectDrawFullScreenTB16bpp::render(bool throttle)
{
	// if any surface was lost, restore it
	if (_screenBuf->IsLost() == DDERR_SURFACELOST){
		_screenBuf->Restore();
	}

	if (_backBuf->IsLost() == DDERR_SURFACELOST){
		_backBuf->Restore();
	}

	DDSURFACEDESC ddsd;
	memset(&ddsd, 0, sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);

	// waits for exclusive acces to the back surface
	DWORD attr = throttle ? DDLOCK_SURFACEMEMORYPTR | DDLOCK_WRITEONLY | DDLOCK_WAIT : DDLOCK_SURFACEMEMORYPTR | DDLOCK_WRITEONLY;
	HRESULT result = _backBuf->Lock(0, &ddsd, attr, 0);
	if (result != DD_OK) return;

	UINT16 *pIniSurf = (UINT16 *) ddsd.lpSurface;

	// if we can't get a pointer to the surface, exit
	if (!pIniSurf){
		return;
	}

	int pitch = (ddsd.lPitch) >> 1;
	UINT32 *pSurf = (UINT32 *)&pIniSurf[_centerY*pitch + _centerX];
	UINT16 *pIni = (UINT16 *)_actualBitmap->getData();
	UINT32 *pBuf = (UINT32 *)&pIni[(_visAreaOffsY*_gameWidth) + _visAreaOffsX];

	// copy visible area to the auxiliary surface
	for (int j = 0; j < _visAreaHeight; j++){
		for (int i = 0; i < (_visAreaWidth >> 1); i++){
			pSurf[i] = pBuf[i];
		}
		pSurf += pitch >> 1;
		pBuf += _gameWidth >> 1;
	}

	// unlock back buffer
	_backBuf->Unlock(0);

	// exchange primary buffer with back buffer
	_screenBuf->Flip(0, (_vSync) ? DDFLIP_WAIT : DDFLIP_NOVSYNC);
}

/////////////////////////////////////////////////////////////////////////////
// Draw methods
/////////////////////////////////////////////////////////////////////////////

void DirectDrawFullScreenTB16bpp::setPixel(int x, int y, int color)
{
	assert((color >= 0) && (color < _numColors));

	_actualBitmap->setPixel<UINT16, 16>(x, y, _palette[color]);
}

void DirectDrawFullScreenTB16bpp::drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr)
{
	_actualBitmap->drawGfx<UINT16, 16>(gfx, _palette, code, color, x, y, attr);
}

void DirectDrawFullScreenTB16bpp::drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr)
{
	_actualBitmap->drawGfxClip<UINT16, 16>(gfx, _palette, code, color, x, y, attr);
}

void DirectDrawFullScreenTB16bpp::drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData)
{
	_actualBitmap->drawGfxTrans<UINT16, 16>(gfx, _palette, code, color, x, y, attr, transData);
}

void DirectDrawFullScreenTB16bpp::drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData)
{
	_actualBitmap->drawGfxClipTrans<UINT16, 16>(gfx, _palette, code, color, x, y, attr, transData);
}