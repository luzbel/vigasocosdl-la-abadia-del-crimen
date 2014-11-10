// DirectDrawWindow32bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Bitmap.h"
#include <cassert>
#include "DirectDrawWindow32bpp.h"
#include "IPalette.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

DirectDrawWindow32bpp::DirectDrawWindow32bpp(Win32Settings *settings) : DirectDrawWindow(settings)
{
	_hardware = true;
	_palette = 0;
}

DirectDrawWindow32bpp::~DirectDrawWindow32bpp()
{
}

/////////////////////////////////////////////////////////////////////////////
// Direct Draw initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

bool DirectDrawWindow32bpp::init(const VideoInfo *vi, IPalette *pal)
{
	// default DirectDraw initialization in Windowed mode
	if (!DirectDrawWindow::init(vi, pal)){
		return false;
	}

	// check bpp to see if this plugin can work
	if (_bpp != 32){
		_errorMsg = "DirectDrawWindow32bpp ERROR: desktop is not in 32bpp mode";
		return false;
	}

	// creates the auxiliary surface
	if (!DirectDrawWindow::createAuxiliarySurface((_hardware) ? 1 : _scale, _scale)){
		return false;
	}

	// gets a pointer to the game's palette
	_palette = (UINT32 *)pal->getRawPalette();

	_isInitialized = true;

	return true;
}

void DirectDrawWindow32bpp::end()
{
	_isInitialized = false;

	DirectDrawWindow::end();
}


/////////////////////////////////////////////////////////////////////////////
// Render
/////////////////////////////////////////////////////////////////////////////

// renders the screen bitmap to the window
void DirectDrawWindow32bpp::render(bool throttle)
{
	// if any surface was lost, restore it
	if (_auxBuf->IsLost() == DDERR_SURFACELOST){
		_auxBuf->Restore();
	}

	if (_screenBuf->IsLost() == DDERR_SURFACELOST){
		_screenBuf->Restore();
	}

	DDSURFACEDESC ddsd;
	memset(&ddsd, 0, sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);

	DWORD attr = throttle ? DDLOCK_SURFACEMEMORYPTR | DDLOCK_WRITEONLY | DDLOCK_WAIT : DDLOCK_SURFACEMEMORYPTR | DDLOCK_WRITEONLY;
	// gets exclusive acces to the auxiliary buffer
	HRESULT result = _auxBuf->Lock(0, &ddsd, attr, 0);
	if (result != DD_OK) return;

	UINT32 *pSurf = (UINT32 *) ddsd.lpSurface;

	// if we can't get a pointer to the surface, exit
	if (!pSurf){
		return;
	}

	UINT32 *pBuf = (UINT32 *)_actualBitmap->getData();
	pBuf = &pBuf[(_visAreaOffsY*_gameWidth) + _visAreaOffsX];
	int pitch = (ddsd.lPitch) >> 2;

	// copy visible area to the auxiliary surface
	if (_hardware){
		for (int j = 0; j < _visAreaHeight; j++){
			for (int i = 0; i < _visAreaWidth; i++){
				pSurf[i] = pBuf[i];
			}
			pSurf += pitch;
			pBuf += _gameWidth;
		}
	} else {
		for (int j = 0; j < _visAreaHeight; j++){
			for (int k = 0; k < _scale; k++){
				for (int i = 0; i < _visAreaWidth; i++){
					for (int l = 0; l < _scale; l++){
						*pSurf = pBuf[i];
						pSurf++;
					}
				}
			}
			pSurf += pitch - _visAreaWidth*_scale;
			pBuf += _gameWidth;
		}
	}

	// unlock auxiliary buffer
	_auxBuf->Unlock(0);

	// convert client coordinates to screen coordinates
	RECT rect;
	POINT corner = { 0, 0 };
	GetClientRect(_settings->getHWnd(), &rect);
	ClientToScreen(_settings->getHWnd(), &corner);
	rect.left += corner.x; rect.right += corner.x;
	rect.top += corner.y; rect.bottom += corner.y;

	// copy auxiliary buffer to the primary buffer
	_screenBuf->Blt(&rect, _auxBuf, 0, DDBLT_WAIT, 0);
}

/////////////////////////////////////////////////////////////////////////////
// Draw methods
/////////////////////////////////////////////////////////////////////////////

void DirectDrawWindow32bpp::setPixel(int x, int y, int color)
{
	assert((color >= 0) && (color < _numColors));

	_actualBitmap->setPixel<UINT32, 32>(x, y, _palette[color]);
}

void DirectDrawWindow32bpp::drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr)
{
	_actualBitmap->drawGfx<UINT32, 32>(gfx, _palette, code, color, x, y, attr);
}

void DirectDrawWindow32bpp::drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr)
{
	_actualBitmap->drawGfxClip<UINT32, 32>(gfx, _palette, code, color, x, y, attr);
}

void DirectDrawWindow32bpp::drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData)
{
	_actualBitmap->drawGfxTrans<UINT32, 32>(gfx, _palette, code, color, x, y, attr, transData);
}

void DirectDrawWindow32bpp::drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData)
{
	_actualBitmap->drawGfxClipTrans<UINT32, 32>(gfx, _palette, code, color, x, y, attr, transData);
}