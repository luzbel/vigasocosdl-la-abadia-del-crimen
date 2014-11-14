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
		fprintf(stderr, "Couldn't set %dx%dx%d video mode: %s\n",
				vi->width,vi->height,_bpp,SDL_GetError());
		return false;
	}

	surface=screen;

	_originalPalette=pal;
	pal->attach(this);

	return true;
};
