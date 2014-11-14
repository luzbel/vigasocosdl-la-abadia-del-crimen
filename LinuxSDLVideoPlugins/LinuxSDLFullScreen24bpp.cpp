// LinuxSDLFullScreen24bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLFullScreen24bpp.h"

bool LinuxSDLFullScreen24bpp::init(const VideoInfo *vi, IPalette *pal)  
{
	_flags |= SDL_FULLSCREEN;

	_isInitialized = LinuxSDL24bpp::init(vi,pal);

	return _isInitialized;
};
