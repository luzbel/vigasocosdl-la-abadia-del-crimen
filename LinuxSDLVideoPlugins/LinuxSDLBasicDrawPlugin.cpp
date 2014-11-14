// LinuxSDLBasicDrawPlugin.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLBasicDrawPlugin.h"
#include "IPalette.h"

void LinuxSDLBasicDrawPlugin::end()  { _originalPalette->detach(this); _isInitialized = false; };

// getters
bool LinuxSDLBasicDrawPlugin::isInitialized() const  { return _isInitialized; };

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
		fprintf(stderr, "Couldn't set 640x480x8 video mode: %s\n",
				SDL_GetError());
		return false;
	}

	surface=NULL;
	surface = SDL_CreateRGBSurface(SDL_HWSURFACE,screen->w, screen->h,screen->format->BitsPerPixel, 0, 0, 0, 0);

	if ( surface == NULL ) {
		fprintf(stderr, "Couldn't create surface: %s\n", SDL_GetError());
		return false;
	}
	else
	{
		fprintf(stderr, "surface ok\n");
	}

	_originalPalette=pal;
	pal->attach(this);

	return true;
};
