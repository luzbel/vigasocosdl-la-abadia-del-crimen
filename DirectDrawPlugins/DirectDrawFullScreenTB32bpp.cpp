// DirectDrawFullScreenTB32bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Bitmap.h"
#include <cassert>
#include "DirectDrawFullScreenTB32bpp.h"
#include "IPalette.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

DirectDrawFullScreenTB32bpp::DirectDrawFullScreenTB32bpp(Win32Settings *settings) : DirectDrawFullScreen(settings)
{
	_bpp = 32;
	_palette = 0;
}

DirectDrawFullScreenTB32bpp::~DirectDrawFullScreenTB32bpp()
{
}

/////////////////////////////////////////////////////////////////////////////
// Direct Draw initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

bool DirectDrawFullScreenTB32bpp::init(const VideoInfo *vi, IPalette *pal)
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
		_errorMsg = "DirectDrawFullScreenTB32bpp ERROR: can't create primary surface";
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

	// gets a pointer to the game's palette
	_palette = (UINT32 *)pal->getRawPalette();

	_isInitialized = true;

	return true;
}

void DirectDrawFullScreenTB32bpp::end()
{
	_isInitialized = false;

	DirectDrawFullScreen::end();
}

/////////////////////////////////////////////////////////////////////////////
// Render
/////////////////////////////////////////////////////////////////////////////

// renders the screen bitmap to the screen
void DirectDrawFullScreenTB32bpp::render(bool throttle)
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

	// unlock back buffer
	_backBuf->Unlock(0);

	// exchange primary buffer with back buffer
	_screenBuf->Flip(0, (_vSync) ? DDFLIP_WAIT : DDFLIP_NOVSYNC);
}

/////////////////////////////////////////////////////////////////////////////
// Draw methods
/////////////////////////////////////////////////////////////////////////////

void DirectDrawFullScreenTB32bpp::setPixel(int x, int y, int color)
{
	assert((color >= 0) && (color < _numColors));

	_actualBitmap->setPixel<UINT32, 32>(x, y, _palette[color]);
}

void DirectDrawFullScreenTB32bpp::drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr)
{
	_actualBitmap->drawGfx<UINT32, 32>(gfx, _palette, code, color, x, y, attr);
}

void DirectDrawFullScreenTB32bpp::drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr)
{
	_actualBitmap->drawGfxClip<UINT32, 32>(gfx, _palette, code, color, x, y, attr);
}

void DirectDrawFullScreenTB32bpp::drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData)
{
	_actualBitmap->drawGfxTrans<UINT32, 32>(gfx, _palette, code, color, x, y, attr, transData);
}

void DirectDrawFullScreenTB32bpp::drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData)
{
	_actualBitmap->drawGfxClipTrans<UINT32, 32>(gfx, _palette, code, color, x, y, attr, transData);
}