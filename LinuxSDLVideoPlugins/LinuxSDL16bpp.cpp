//LinuxSDL16bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDL16bpp.h"
#include "IPalette.h"

bool LinuxSDL16bpp::init(const VideoInfo *vi, IPalette *pal)  
{
	_bpp = 16;

	_isInitialized = LinuxSDLBasicDrawPlugin::init(vi,pal);

	_palette = new UINT16[pal->getTotalColors()];
	updateFullPalette(pal);

	return _isInitialized;
};

/////////////////////////////////////////////////////////////////////////////
// Palette changes
/////////////////////////////////////////////////////////////////////////////

void LinuxSDL16bpp::updateFullPalette(IPalette *palette)
{
	for (int i = 0; i < palette->getTotalColors(); i++){
		UINT8 r, g, b;

		palette->getColor(i, r, g, b);
		//_palette[i] = SDL_MapRGB(surface->format,r,g,b);
		_palette[i] = SDL_MapRGB(screen->format,r,g,b);
	}
}

void LinuxSDL16bpp::update(IPalette *palette, int data)
{
	if (data != -1){
		// single color update
		UINT8 r, g, b;

		palette->getColor(data, r, g, b);
		//_palette[data] = SDL_MapRGB(surface->format,r,g,b);
		_palette[data] = SDL_MapRGB(screen->format,r,g,b);
	} else {
		// full palette update
		updateFullPalette(palette);	
	}
}

void LinuxSDL16bpp::setPixel(int x, int y, int color)
{
	/* Lock the surface for direct access to the pixels */
	if ( SDL_MUSTLOCK(surface) ) {
		if ( SDL_LockSurface(surface) < 0 ) {
			fprintf(stderr, "Can't lock surface: %s\n", SDL_GetError());
			return;
		}
	}


	int bpp = surface->format->BytesPerPixel;
	/* Here p is the address to the pixel we want to set */
	Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;

	*(Uint32 *)p = _palette[color];

	if ( SDL_MUSTLOCK(surface) ) {
		SDL_UnlockSurface(surface);
	}
};
