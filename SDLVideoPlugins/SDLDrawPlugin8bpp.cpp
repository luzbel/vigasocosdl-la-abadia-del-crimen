// SDLDrawPlugin8bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "SDLVideoPlugins.h"
#include "IPalette.h"

/////////////////////////////////////////////////////////////////////////////
//// Palette changes
///////////////////////////////////////////////////////////////////////////////

void SDLDrawPlugin8bpp::updateFullPalette(IPalette *palette)
{ 
	SDL_Color colors[256];

//	fprintf(stderr,"SDLDrawPlugin8bpp::updateFullPalette\n");
	for (int i = 0; i < palette->getTotalColors(); i++){
		UINT8 r, g, b;

		palette->getColor(i, r, g, b);
		colors[i].r=r;
		colors[i].g=g;
		colors[i].b=b;
	}
	//fprintf(stderr,"SDLDrawPlugin8bpp::updateFullPalette %d\n",SDL_SetColors(surface, colors, 0, 256));   
SDL_mutexP(cs);
	SDL_SetColors(surface, colors, 0, 256); // ?por que esto da error, si en teoria es igual a lo de abajo???   
//	SDL_SetPalette(surface, SDL_LOGPAL|SDL_PHYSPAL, colors, 0, 256);
SDL_mutexV(cs);
}

void SDLDrawPlugin8bpp::update(IPalette *palette, int data)
{ 
//	fprintf(stderr,"SDLDrawPlugin8bpp::update\n");
	if (data != -1){
		// single color update
		UINT8 r, g, b;
		SDL_Color color;

		palette->getColor(data, r, g, b);
		color.r=r;
		color.g=g;
		color.b=b;

SDL_mutexP(cs);
		//fprintf(stderr,"SDLDrawPlugin8bpp::update %d\n",SDL_SetColors(surface, &color, data, 1));
		//errSDL_SetColors(surface, &color, data, 1);
		//ok SDL_SetPalette(surface,SDL_LOGPAL, &color, data, 1);
		//errSDL_SetPalette(surface,SDL_PHYSPAL, &color, data, 1);
		//SDL_SetPalette(surface,SDL_LOGPAL, &color, data, 1);
		SDL_SetColors(surface, &color, data, 1);
		//errSDL_SetPalette(surface,SDL_LOGPAL|SDL_PHYSPAL, &color, data, 1); //?por que esto da error, si en teoria es igual a lo de arriba???
SDL_mutexV(cs);
	} else {
		// full palette update
		updateFullPalette(palette);
	} 
}
void SDLDrawPlugin8bpp::render(bool a)
{
	SDL_mutexP(cs);
	SDLBasicDrawPlugin<UINT8>::render(a);
	SDL_mutexV(cs);
}


void SDLDrawPlugin8bpp::setPixel(int x, int y, int color)
{
	// Lock the screen for direct access to the pixels 
	if ( SDL_MUSTLOCK(surface) ) {
		if ( SDL_LockSurface(surface) < 0 ) {
			fprintf(stderr, "Can't lock surface: %s\n", SDL_GetError());
			return;
		}
	}
	updated=true; 
	/* para un solo rect.
	updated=true; 
if ( x < minX ) minX=x;
if ( x>maxX ) maxX = x; 
if ( y < minY ) minY=y;
if ( y>maxY ) maxY = y;
//fprintf(stderr,"SDLDrawPlugin8bpp::setPixel %d,%d,%d -> %d , %d - %d ,%d\n",x,y,color,minX,minY,maxX,maxY);
//*/
/*
if ( y<screen->h-41 )
{
updatedr1=true;
if ( x < minX ) minX=x;
if ( x>maxX ) maxX = x; 
if ( y < minY ) minY=y;
if ( y>maxY ) maxY = y;
}
else
{
updatedr2=true;
if (x < r2.x ) r2.x=x;
if (x>r2.w) r2.w=x;
if (y<r2.y) r2.y=y;
if (y>r2.h) r2.h=y;
}
*/

	int bpp = surface->format->BytesPerPixel;
	// Here p is the address to the pixel we want to set 
	Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;
	*p=color;

	if ( SDL_MUSTLOCK(surface) ) {
		SDL_UnlockSurface(surface);
	}
};
