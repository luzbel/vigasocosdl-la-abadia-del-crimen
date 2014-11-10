// DirectDrawWindow16bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

//#include "Bitmap.h"
#include <cassert>
#include "DirectDrawWindow16bpp.h"
#include "IPalette.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

DirectDrawWindow16bpp::DirectDrawWindow16bpp(Win32Settings *settings) : DirectDrawWindow(settings)
{
	_hardware = true;
	_originalPalette = 0;
	_palette = 0;
}

DirectDrawWindow16bpp::~DirectDrawWindow16bpp()
{
}

/////////////////////////////////////////////////////////////////////////////
// Direct Draw initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

bool DirectDrawWindow16bpp::init(const VideoInfo *vi, IPalette *pal)
{
	// default DirectDraw initialization in Windowed mode
	if (!DirectDrawWindow::init(vi, pal)){
		return false;
	}

	// check bpp to see if this plugin can work
	if ((_bpp != 16) && (_bpp != 15)){
		_errorMsg = "DirectDrawWindow32bpp ERROR: desktop is not in 16bpp mode";
		return false;
	}

	// creates the auxiliary surface
	if (!DirectDrawWindow::createAuxiliarySurface((_hardware) ? 1 : _scale, _scale)){
		return false;
	}

	// checks that the visible area width is divisible by 2
	if (!((_visAreaWidth % 2) == 0)){
		_errorMsg = "DirectDrawWindow16bpp ERROR: visible area width is not divisible by 2";
		return false;
	}

	// creates a 16bpp palette from the original one and suscribe for changes
	_originalPalette = pal;
	_palette = new UINT16[pal->getTotalColors()];
	pal->attach(this);
	updateFullPalette(pal);

	_isInitialized = true;

	return true;
}

void DirectDrawWindow16bpp::end()
{
	_isInitialized = false;

	if (_palette){
		delete[] _palette;
		_palette = 0;

		_originalPalette->detach(this);
	}

	DirectDrawWindow::end();
}

/////////////////////////////////////////////////////////////////////////////
// Palette changes
/////////////////////////////////////////////////////////////////////////////

void DirectDrawWindow16bpp::updateFullPalette(IPalette *palette)
{
	for (int i = 0; i < palette->getTotalColors(); i++){
		UINT8 r, g, b;

		palette->getColor(i, r, g, b);
		_palette[i] = DirectDrawPlugin::convertColorTo16bpp(&_palConv, r, g, b);
	}
}

void DirectDrawWindow16bpp::update(IPalette *palette, int data)
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

// renders the screen bitmap to the window
void DirectDrawWindow16bpp::render(bool throttle)
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

	// waits for exclusive acces to the auxiliary buffer
	DWORD attr = throttle ? DDLOCK_SURFACEMEMORYPTR | DDLOCK_WRITEONLY | DDLOCK_WAIT : DDLOCK_SURFACEMEMORYPTR | DDLOCK_WRITEONLY;
	HRESULT result = _auxBuf->Lock(0, &ddsd, attr, 0);
	if (result != DD_OK) return;

	UINT16 *pIni = (UINT16 *)_actualBitmap->getData();

	// copy visible area to the auxiliary surface
	if (_hardware){
		UINT32 *pSurf = (UINT32 *) ddsd.lpSurface;

		// if we can't get a pointer to the surface, exit
		if (!pSurf){
			return;
		}

		// we can blit 2 pixels in each iteration
		UINT32 *pBuf = (UINT32 *) &pIni[(_visAreaOffsY*_gameWidth) + _visAreaOffsX];
		int pitch = (ddsd.lPitch) >> 2;

		for (int j = 0; j < _visAreaHeight; j++){
			for (int i = 0; i < (_visAreaWidth >> 1); i++){
				pSurf[i] = pBuf[i];
			}
			pSurf += pitch;
			pBuf += _gameWidth >> 1;
		}
	} else {
		UINT16 *pSurf = (UINT16 *) ddsd.lpSurface;

		// if we can't get a pointer to the surface, exit
		if (!pSurf){
			return;
		}

		// we can blit only a pixel in each iteration
		UINT16 *pBuf = (UINT16 *) &pIni[(_visAreaOffsY*_gameWidth) + _visAreaOffsX];
		int pitch = (ddsd.lPitch) >> 1;

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

void DirectDrawWindow16bpp::setPixel(int x, int y, int color)
{
	assert((color >= 0) && (color < _numColors));

	_actualBitmap->setPixel<UINT16, 16>(x, y, _palette[color]);
}

void DirectDrawWindow16bpp::drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr)
{
	_actualBitmap->drawGfx<UINT16, 16>(gfx, _palette, code, color, x, y, attr);
}

void DirectDrawWindow16bpp::drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr)
{
	_actualBitmap->drawGfxClip<UINT16, 16>(gfx, _palette, code, color, x, y, attr);
}

void DirectDrawWindow16bpp::drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData)
{
	_actualBitmap->drawGfxTrans<UINT16, 16>(gfx, _palette, code, color, x, y, attr, transData);
}

void DirectDrawWindow16bpp::drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData)
{
	_actualBitmap->drawGfxClipTrans<UINT16, 16>(gfx, _palette, code, color, x, y, attr, transData);
}