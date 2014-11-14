// LinuxSDLFullScreen16bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLFullScreen16bpp.h"

bool LinuxSDLFullScreen16bpp::init(const VideoInfo *vi, IPalette *pal)  
{
	_flags |= SDL_FULLSCREEN;

	_isInitialized = LinuxSDL16bpp::init(vi,pal);

	return _isInitialized;
};
