// LinuxSDLFullScreen32bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLFullScreen32bpp.h"

bool LinuxSDLFullScreen32bpp::init(const VideoInfo *vi, IPalette *pal)  
{
	_flags |= SDL_FULLSCREEN;

	_isInitialized = LinuxSDL32bpp::init(vi,pal);

	return _isInitialized;
};
