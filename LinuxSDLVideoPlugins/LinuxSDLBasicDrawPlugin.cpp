// LinuxSDLBasicDrawPlugin.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLBasicDrawPlugin.h"
#include "IPalette.h"

void LinuxSDLBasicDrawPlugin::end()  { 
	if ( _originalPalette )
		_originalPalette->detach(this);
	_isInitialized = false;
};


bool LinuxSDLBasicDrawPlugin::init(const VideoInfo *vi, IPalette *pal)
{
	if ( SDL_Init(SDL_INIT_VIDEO) < 0 ) {
		fprintf(stderr,
				"Couldn't initialize SDL: %s\n", SDL_GetError());
		return false;
	}

	_flags |= SDL_HWSURFACE|SDL_DOUBLEBUF;

	screen = SDL_SetVideoMode(vi->width, vi->height, _bpp, _flags);
	if ( screen == NULL ) {
		fprintf(stderr, "Couldn't set %dx%dx%d video mode: %s\n",
				vi->width,vi->height,_bpp,SDL_GetError());
		return false;
	}
	fprintf(stderr, "set %dx%dx%d video mode: %s\n",
				vi->width,vi->height,_bpp,SDL_GetError());


	surface = SDL_CreateRGBSurface(SDL_HWSURFACE,screen->w, screen->h,screen->format->BitsPerPixel, 0, 0, 0, 0);

	if (surface== NULL ) {
		fprintf(stderr, "Couldn't create surface: %s\n", SDL_GetError());
		_isInitialized=false;
		return false;
	}

	_originalPalette=pal;
	pal->attach(this);

	return true;
};

// drawing methods
void LinuxSDLBasicDrawPlugin::render(bool throttle)
{
	if ( SDL_BlitSurface(surface, NULL, screen, NULL) < 0 )
		fprintf(stderr, "SDL error when BlitSurface %s\n", SDL_GetError());
	SDL_Flip(screen);
};
