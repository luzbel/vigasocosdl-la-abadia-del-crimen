// LinuxSDL8bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDL8bpp.h"
#include "IPalette.h"

/////////////////////////////////////////////////////////////////////////////
//// Palette changes
///////////////////////////////////////////////////////////////////////////////

void LinuxSDL8bpp::updateFullPalette(IPalette *palette)
{ 
	SDL_Color colors[256];

//	fprintf(stderr,"LinuxSDL8bpp::updateFullPalette\n");
	for (int i = 0; i < palette->getTotalColors(); i++){
		UINT8 r, g, b;

		palette->getColor(i, r, g, b);
		colors[i].r=r;
		colors[i].g=g;
		colors[i].b=b;
	}
	//fprintf(stderr,"LinuxSDL8bpp::updateFullPalette %d\n",SDL_SetColors(surface, colors, 0, 256));   
	SDL_SetColors(surface, colors, 0, 256);   
}

void LinuxSDL8bpp::update(IPalette *palette, int data)
{ 
//	fprintf(stderr,"LinuxSDL8bpp::update\n");
	if (data != -1){
		// single color update
		UINT8 r, g, b;
		SDL_Color color;

		palette->getColor(data, r, g, b);
		color.r=r;
		color.g=g;
		color.b=b;

		//fprintf(stderr,"LinuxSDL8bpp::update %d\n",SDL_SetColors(surface, &color, data, 1));
		SDL_SetColors(surface, &color, data, 1);
	} else {
		// full palette update
		updateFullPalette(palette);
	} 
}

void LinuxSDL8bpp::setPixel(int x, int y, int color)
{
	// Lock the screen for direct access to the pixels 
	if ( SDL_MUSTLOCK(surface) ) {
		if ( SDL_LockSurface(surface) < 0 ) {
			fprintf(stderr, "Can't lock surface: %s\n", SDL_GetError());
			return;
		}
	}


	int bpp = surface->format->BytesPerPixel;
	// Here p is the address to the pixel we want to set 
	Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;
	*p=color;

	if ( SDL_MUSTLOCK(surface) ) {
		SDL_UnlockSurface(surface);
	}
};
