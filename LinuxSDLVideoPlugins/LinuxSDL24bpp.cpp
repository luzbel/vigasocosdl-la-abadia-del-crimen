//LinuxSDL24bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDL24bpp.h"
#include "IPalette.h"

bool LinuxSDL24bpp::init(const VideoInfo *vi, IPalette *pal)  
{
	_bpp = 24;

	_isInitialized = LinuxSDLBasicDrawPlugin::init(vi,pal);

	// gets a pointer to the game's palette
	_palette = (UINT32 *)pal->getRawPalette();

	return _isInitialized;
};

void LinuxSDL24bpp::setPixel(int x, int y, int color)
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
