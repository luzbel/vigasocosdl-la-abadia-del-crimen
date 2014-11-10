// DirectDrawFullScreen32bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Bitmap.h"
#include <cassert>
#include "DirectDrawFullScreen32bpp.h"
#include "IPalette.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

DirectDrawFullScreen32bpp::DirectDrawFullScreen32bpp(Win32Settings *settings) : DirectDrawFullScreen(settings)
{
	_bpp = 32;
	_palette = 0;
}

DirectDrawFullScreen32bpp::~DirectDrawFullScreen32bpp()
{
}

/////////////////////////////////////////////////////////////////////////////
// Direct Draw initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

bool DirectDrawFullScreen32bpp::init(const VideoInfo *vi, IPalette *pal)
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
		_errorMsg = "DirectDrawFullScreen32bpp ERROR: can't create primary surface";
		return false;
	}

	clearBuf(_screenBuf, 0);

	// gets a pointer to the game's palette
	_palette = (UINT32 *)pal->getRawPalette();

	_isInitialized = true;

	return true;
}

void DirectDrawFullScreen32bpp::end()
{
	_isInitialized = false;

	DirectDrawFullScreen::end();
}


/////////////////////////////////////////////////////////////////////////////
// Render
/////////////////////////////////////////////////////////////////////////////

// renders the screen bitmap to the screen
void DirectDrawFullScreen32bpp::render(bool throttle)
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

	UINT32 *pIniSurf = (UINT32 *) ddsd.lpSurface;

	// if we can't get a pointer to the surface, exit
	if (!pIniSurf){
		return;
	}

	int pitch = (ddsd.lPitch) >> 2;
	UINT32* pSurf = &pIniSurf[_centerY*pitch + _centerX];
	UINT32 *pBuf = (UINT32 *)_actualBitmap->getData();
	pBuf = &pBuf[(_visAreaOffsY*_gameWidth) + _visAreaOffsX];

	// copy visible area to the auxiliary surface
	for (int j = 0; j < _visAreaHeight; j++){
		for (int i = 0; i < _visAreaWidth; i++){
			pSurf[i] = pBuf[i];
		}
		pSurf += pitch;
		pBuf += _gameWidth;
	}

	// unlock buffer
	_screenBuf->Unlock(0);
}

/////////////////////////////////////////////////////////////////////////////
// Draw methods
/////////////////////////////////////////////////////////////////////////////

void DirectDrawFullScreen32bpp::setPixel(int x, int y, int color)
{
	assert((color >= 0) && (color < _numColors));

	_actualBitmap->setPixel<UINT32, 32>(x, y, _palette[color]);
}

void DirectDrawFullScreen32bpp::drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr)
{
	_actualBitmap->drawGfx<UINT32, 32>(gfx, _palette, code, color, x, y, attr);
}

void DirectDrawFullScreen32bpp::drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr)
{
	_actualBitmap->drawGfxClip<UINT32, 32>(gfx, _palette, code, color, x, y, attr);
}

void DirectDrawFullScreen32bpp::drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData)
{
	_actualBitmap->drawGfxTrans<UINT32, 32>(gfx, _palette, code, color, x, y, attr, transData);
}

void DirectDrawFullScreen32bpp::drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData)
{
	_actualBitmap->drawGfxClipTrans<UINT32, 32>(gfx, _palette, code, color, x, y, attr, transData);
}