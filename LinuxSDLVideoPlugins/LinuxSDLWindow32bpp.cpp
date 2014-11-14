// LinuxSDLWindow32bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLWindow32bpp.h"
#include "IPalette.h"

#ifdef DEBUG
#include <stdio.h>
#define DEBUG_FAIL_FUNC printf("%s\n",__func__);
#else
#define DEBUG_FAIL_FUNC 
#endif


bool LinuxSDLWindow32bpp::init(const VideoInfo *vi, IPalette *pal)  
{
	_bpp = 32;

	_isInitialized = LinuxSDLBasicDrawPlugin::init(vi,pal);
//		surface = SDL_CreateRGBSurface(SDL_HWSURFACE,screen->w, screen->h,screen->format->BitsPerPixel, 0, 0, 0, 0);

	// gets a pointer to the game's palette
	_palette = (UINT32 *)pal->getRawPalette();

	return _isInitialized;
};

// drawing methods
void LinuxSDLWindow32bpp::render(bool throttle)
{
	// SDL_UpdateRect(screen, 0, 0, 0, 0);
//	SDL_BlitSurface(surface, NULL, screen, NULL);
	SDL_Flip(screen);
};

void LinuxSDLWindow32bpp::setPixel(int x, int y, int color)
{
	/* Lock the screen for direct access to the pixels */
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
