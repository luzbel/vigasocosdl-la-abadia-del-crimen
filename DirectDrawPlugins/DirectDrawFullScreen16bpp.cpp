// DirectDrawFullScreen16bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Bitmap.h"
#include <cassert>
#include "DirectDrawFullScreen16bpp.h"
#include "IPalette.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

DirectDrawFullScreen16bpp::DirectDrawFullScreen16bpp(Win32Settings *settings) : DirectDrawFullScreen(settings)
{
	_bpp = 16;
	_palette = 0;
}

DirectDrawFullScreen16bpp::~DirectDrawFullScreen16bpp()
{
}

/////////////////////////////////////////////////////////////////////////////
// Direct Draw initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

bool DirectDrawFullScreen16bpp::init(const VideoInfo *vi, IPalette *pal)
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
	ddsd.dwFlags = DDSD_CAPS;
	ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;

	// creates primary surface
	if (FAILED(_pIDD2->CreateSurface(&ddsd, &_screenBuf, 0))){
		_errorMsg = "DirectDrawFullScreen16bpp ERROR: can't create primary surface";
		return false;
	}

	clearBuf(_screenBuf, 0);

	// gets RGB mask to handle different bpp configurations
	if (!getRGBMasks()){
		_errorMsg = "DirectDrawFullScreen16bpp ERROR: can't get RGB masks";
		return false;
	}

	// checks that the visible area width is divisible by 2
	if (!((_visAreaWidth % 2) == 0)){
		_errorMsg = "DirectDrawWindow16bpp ERROR: visible area width is not divisible by 2";
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

void DirectDrawFullScreen16bpp::end()
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

void DirectDrawFullScreen16bpp::updateFullPalette(IPalette *palette)
{
	for (int i = 0; i < palette->getTotalColors(); i++){
		UINT8 r, g, b;

		palette->getColor(i, r, g, b);
		_palette[i] = DirectDrawPlugin::convertColorTo16bpp(&_palConv, r, g, b);
	}
}

void DirectDrawFullScreen16bpp::update(IPalette *palette, int data)
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
void DirectDrawFullScreen16bpp::render(bool throttle)
{
	// if the surface was lost, restore it
	if (_screenBuf->IsLost() == DDERR_SURFACELOST){
		_screenBuf->Restore();
	}

	// wait vsync if necessary
	if (_vSync){
		BOOL isVBlank;

		// if we're not in the VBLANK, wait
		HRESULT result = _pIDD2->GetVerticalBlankStatus(&isVBlank);
		if ((result == DD_OK) && !isVBlank){
			_pIDD2->WaitForVerticalBlank(DDWAITVB_BLOCKBEGIN, 0);
		}
	}

	DDSURFACEDESC ddsd;
	memset(&ddsd, 0, sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);

	// waits for exclusive acces to the surface
	DWORD attr = throttle ? DDLOCK_SURFACEMEMORYPTR | DDLOCK_WRITEONLY | DDLOCK_WAIT : DDLOCK_SURFACEMEMORYPTR | DDLOCK_WRITEONLY;
	HRESULT result = _screenBuf->Lock(0, &ddsd, attr, 0);
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

	// unlock buffer
	_screenBuf->Unlock(0);
}

/////////////////////////////////////////////////////////////////////////////
// Draw methods
/////////////////////////////////////////////////////////////////////////////

void DirectDrawFullScreen16bpp::setPixel(int x, int y, int color)
{
	assert((color >= 0) && (color < _numColors));

	_actualBitmap->setPixel<UINT16, 16>(x, y, _palette[color]);
}

void DirectDrawFullScreen16bpp::drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr)
{
	_actualBitmap->drawGfx<UINT16, 16>(gfx, _palette, code, color, x, y, attr);
}

void DirectDrawFullScreen16bpp::drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr)
{
	_actualBitmap->drawGfxClip<UINT16, 16>(gfx, _palette, code, color, x, y, attr);
}

void DirectDrawFullScreen16bpp::drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData)
{
	_actualBitmap->drawGfxTrans<UINT16, 16>(gfx, _palette, code, color, x, y, attr, transData);
}

void DirectDrawFullScreen16bpp::drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData)
{
	_actualBitmap->drawGfxClipTrans<UINT16, 16>(gfx, _palette, code, color, x, y, attr, transData);
}