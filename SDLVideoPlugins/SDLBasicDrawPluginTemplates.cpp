// SDLBasicDrawPluginTemplates.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "SDLBasicDrawPlugin.h"
#include "IPalette.h"

template<typename T>
bool SDLBasicDrawPlugin<T>::init(const VideoInfo *vi, IPalette *pal)
{
	if ( SDL_Init(SDL_INIT_VIDEO) < 0 ) {
		fprintf(stderr,
				"Couldn't initialize SDL: %s\n", SDL_GetError());
		return false;
	}

	screen = SDL_SetVideoMode(vi->width, vi->height, _bpp, _flags);
	if ( screen == NULL ) {
		fprintf(stderr, "Couldn't set %dx%dx%d video mode: %s\n",
				vi->width,vi->height,_bpp,SDL_GetError());
		return false;
	}
	fprintf(stderr, "set %dx%dx%d video mode: %s\n",
				vi->width,vi->height,_bpp,SDL_GetError());

	surface = SDL_CreateRGBSurface(SDL_HWSURFACE,screen->w, screen->h,screen->format->BitsPerPixel, 0, 0, 0, 0);

	if (surface == NULL ) {
		fprintf(stderr, "Couldn't create surface: %s\n", SDL_GetError());
		_isInitialized=false;
		return false;
	}

	_originalPalette=pal;

	_palette = new T[pal->getTotalColors()];
	pal->attach(this);
	updateFullPalette(pal);

	_isInitialized = true;
	
	return _isInitialized;
};


template<typename T>
void SDLBasicDrawPlugin<T>::end()  { 
	if ( _originalPalette )
		_originalPalette->detach(this);
	_isInitialized = false;
};


/////////////////////////////////////////////////////////////////////////////
// Palette changes
/////////////////////////////////////////////////////////////////////////////

template<typename T>
void SDLBasicDrawPlugin<T>::updateFullPalette(IPalette *palette)
{
	for (int i = 0; i < palette->getTotalColors(); i++){
		UINT8 r, g, b;

		palette->getColor(i, r, g, b);
		_palette[i] = SDL_MapRGB(surface->format,r,g,b);
	}
}

template<typename T>
void SDLBasicDrawPlugin<T>::update(IPalette *palette, int data)
{
	if (data != -1){
		// single color update
		UINT8 r, g, b;

		palette->getColor(data, r, g, b);
		_palette[data] = SDL_MapRGB(surface->format,r,g,b);
	} else {
		// full palette update
		updateFullPalette(palette);	
	}
}

// drawing methods
template<typename T>
void SDLBasicDrawPlugin<T>::render(bool throttle)
{
	if ( SDL_BlitSurface(surface, NULL, screen, NULL) < 0 )
		fprintf(stderr, "SDL error when BlitSurface %s\n", SDL_GetError());
	SDL_Flip(screen);
};
	
template<typename T>
void SDLBasicDrawPlugin<T>::setPixel(int x, int y, int color)
{
	/* Lock the surface for direct access to the pixels */
	if ( SDL_MUSTLOCK(surface) ) {
		if ( SDL_LockSurface(surface) < 0 ) {
			fprintf(stderr, "Can't lock surface: %s\n", SDL_GetError());
			return;
		}
	}

	int __bpp = surface->format->BytesPerPixel;
	/* Here p is the address to the pixel we want to set */
	Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * __bpp;

	*(T *)p = _palette[color]; // Vale para todos los bpp, excepto 24bpp

	if ( SDL_MUSTLOCK(surface) ) {
		SDL_UnlockSurface(surface);
	}
};
